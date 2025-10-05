(** Webhook server implementation for Telegram Bot API. *)

open Telegram

type config = {
  port : int;
  path : string;
  secret_token : string option;
  max_connections : int;
  on_error : (Error.t -> unit) option;
}

let make ?(port = 8443) ?(path = "/webhook") ?secret_token ?(max_connections = 100) ?on_error () =
  { port; path; secret_token; max_connections; on_error }

let default = make ()

(* Parse JSON body and decode Update *)
let parse_update body =
  try
    match Yojson.Safe.from_string body with
    | exception _ -> Error (Error.Decode_error "Invalid JSON in webhook body")
    | json ->
        (match Telegram_generated.Gen_types.Update.of_yojson json with
         | Ok update -> Ok update
         | Error msg -> Error (Error.Decode_error ("Failed to decode Update: " ^ msg)))
  with exn ->
    Error (Error.Decode_error ("Exception parsing webhook body: " ^ Printexc.to_string exn))

(* Simple HTTP server using Eio directly *)
let run_server client config sw ~handler =
  let env = Client.env client in
  let on_error = config.on_error in

  (* Start HTTP server *)
  let socket = Eio.Net.listen env#net
    ~sw
    ~reuse_addr:true
    ~backlog:config.max_connections
    (`Tcp (Eio.Net.Ipaddr.V4.loopback, config.port))
  in

  (* Accept connections in a loop *)
  let rec accept_loop () =
    Eio.Net.accept_fork socket ~sw ~on_error:(fun exn ->
      let err = Error.Decode_error ("Connection error: " ^ Printexc.to_string exn) in
      match on_error with
      | Some f -> f err
      | None -> ()
    ) (fun flow _addr ->
      (* Simple HTTP request parsing - just get body for POST *)
      try
        (* Read the request *)
        let chunk = Cstruct.create 4096 in
        let headers_done = ref false in
        let content_length = ref 0 in
        let path_info = ref "" in
        let method_type = ref "" in
        let secret_token_header = ref None in

        (* Read headers *)
        let rec read_headers current_line =
          match Eio.Flow.single_read flow chunk with
          | 0 -> ()
          | n ->
              let data = Cstruct.to_string (Cstruct.sub chunk 0 n) in
              let combined = current_line ^ data in
              let lines = String.split_on_char '\n' combined in
              List.iteri (fun i line ->
                let line = String.trim line in
                if i = 0 && not !headers_done then (
                  (* Parse request line *)
                  match String.split_on_char ' ' line with
                  | meth :: path :: _ ->
                      method_type := meth;
                      path_info := path
                  | _ -> ()
                );
                if line = "" || line = "\r" then
                  headers_done := true
                else if String.lowercase_ascii line |> String.starts_with ~prefix:"content-length:" then (
                  match String.split_on_char ':' line with
                  | _ :: len :: _ -> content_length := int_of_string (String.trim len)
                  | _ -> ()
                ) else if String.lowercase_ascii line |> String.starts_with ~prefix:"x-telegram-bot-api-secret-token:" then (
                  match String.split_on_char ':' line with
                  | _ :: token :: _ -> secret_token_header := Some (String.trim token)
                  | _ -> ()
                )
              ) lines;
              if not !headers_done then
                read_headers (List.nth lines (List.length lines - 1))
        in
        read_headers "";

        (* Validate request *)
        let response_status, response_body =
          if !method_type <> "POST" || !path_info <> config.path then
            ("404 Not Found", "Not Found")
          else if not (match config.secret_token with
                       | None -> true
                       | Some expected -> !secret_token_header = Some expected) then
            ("403 Forbidden", "Forbidden: Invalid secret token")
          else (
            (* Read body *)
            let body_buf = Buffer.create !content_length in
            let remaining = ref !content_length in
            while !remaining > 0 do
              match Eio.Flow.single_read flow chunk with
              | 0 -> remaining := 0
              | n ->
                  let to_read = min n !remaining in
                  Buffer.add_string body_buf (Cstruct.to_string (Cstruct.sub chunk 0 to_read));
                  remaining := !remaining - to_read
            done;
            let body_str = Buffer.contents body_buf in

            (* Parse and handle update *)
            match parse_update body_str with
            | Error err ->
                (match on_error with
                 | Some f -> f err
                 | None -> ());
                ("400 Bad Request", "Bad Request: Invalid update format")
            | Ok update ->
                (try
                   handler update
                 with exn ->
                   let err = Error.Decode_error ("Handler exception: " ^ Printexc.to_string exn) in
                   (match on_error with
                    | Some f -> f err
                    | None -> ()));
                ("200 OK", "OK")
          )
        in

        (* Send response *)
        let response = Printf.sprintf "HTTP/1.1 %s\r\nContent-Type: text/plain\r\nContent-Length: %d\r\n\r\n%s"
          response_status (String.length response_body) response_body in
        Eio.Flow.copy_string response flow

      with exn ->
        let err = Error.Decode_error ("Request handling error: " ^ Printexc.to_string exn) in
        (match on_error with
         | Some f -> f err
         | None -> ())
    );
    accept_loop ()
  in
  accept_loop ()

let run_with_config_and_switch client config sw ~handler =
  run_server client config sw ~handler

let run_with_config client config ~handler =
  Eio.Switch.run @@ fun sw ->
  run_server client config sw ~handler

let run_with_switch client sw ?secret_token ?port ?path ~handler =
  let config = make ?secret_token ?port ?path () in
  run_server client config sw ~handler

let run client ?secret_token ?port ?path ~handler =
  let config = make ?secret_token ?port ?path () in
  Eio.Switch.run @@ fun sw ->
  run_server client config sw ~handler
