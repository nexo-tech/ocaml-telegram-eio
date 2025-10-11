(** Webhook server implementation for Telegram Bot API. *)

open Telegram

module Log = Telegram.Log.Make (Telegram.Log.Console) (struct
  let src = "Webhook"
  let level = Telegram.Log.Info
end)

type request_info = {
  client_addr : string;
  headers : (string * string) list;
  path : string;
  method_ : string;
}

type validation_result =
  | Accept
  | Reject of string

type config = {
  port : int;
  path : string;
  secret_token : string option;
  max_connections : int;
  on_error : (Error.t -> unit) option;
  ip_allowlist : string list option;
  custom_validator : (request_info -> validation_result) option;
}

let make ?(port = 8443) ?(path = "/webhook") ?secret_token ?(max_connections = 100) ?on_error ?ip_allowlist ?custom_validator () =
  { port; path; secret_token; max_connections; on_error; ip_allowlist; custom_validator }

let default = make ()

(* Telegram's official IP ranges as of 2024 *)
let telegram_ip_ranges = [
  "149.154.160.0/20";
  "91.108.4.0/22";
]

(* Parse CIDR notation into (base_ip, prefix_length) *)
let parse_cidr cidr =
  match String.split_on_char '/' cidr with
  | [ip; prefix] ->
      let prefix_len = int_of_string prefix in
      (* Convert IP string to int32 *)
      let parse_ip ip_str =
        match String.split_on_char '.' ip_str with
        | [a; b; c; d] ->
            let open Int32 in
            let a = of_int (int_of_string a) in
            let b = of_int (int_of_string b) in
            let c = of_int (int_of_string c) in
            let d = of_int (int_of_string d) in
            logor (shift_left a 24)
              (logor (shift_left b 16)
                (logor (shift_left c 8) d))
        | _ -> 0l
      in
      (parse_ip ip, prefix_len)
  | _ -> (0l, 0)

(* Check if IP is in CIDR range *)
let ip_in_range ip cidr =
  try
    let (base_ip, prefix_len) = parse_cidr cidr in
    let ip_int =
      match String.split_on_char '.' ip with
      | [a; b; c; d] ->
          let open Int32 in
          let a = of_int (int_of_string a) in
          let b = of_int (int_of_string b) in
          let c = of_int (int_of_string c) in
          let d = of_int (int_of_string d) in
          logor (shift_left a 24)
            (logor (shift_left b 16)
              (logor (shift_left c 8) d))
      | _ -> 0l
    in
    (* Create mask from prefix length *)
    let mask = Int32.shift_left (-1l) (32 - prefix_len) in
    let masked_base = Int32.logand base_ip mask in
    let masked_ip = Int32.logand ip_int mask in
    masked_base = masked_ip
  with _ -> false

(* Create IP validator from allowlist *)
let make_ip_validator allowlist request =
  let ip_allowed = List.exists (fun cidr -> ip_in_range request.client_addr cidr) allowlist in
  Log.debug "IP validation check: source_ip=%s, is_allowed=%b" request.client_addr ip_allowed;
  if ip_allowed then
    Accept
  else (
    Log.warn "IP validation failed: source_ip=%s, allowed_ranges=[%s]"
      request.client_addr (String.concat ", " allowlist);
    Reject ("IP not in allowlist: " ^ request.client_addr)
  )

(* Parse JSON body and decode Update *)
let parse_update body =
  try
    match Yojson.Safe.from_string body with
    | exception exn ->
        let preview = if String.length body > 200 then String.sub body 0 200 ^ "..." else body in
        Log.error "JSON parse error: reason=%s, body_preview=%s"
          (Printexc.to_string exn) preview;
        Error (Error.Decode_error "Invalid JSON in webhook body")
    | json ->
        (match Telegram_generated.Gen_types.Update.of_yojson json with
         | Ok update -> Ok update
         | Error msg ->
             Log.error "Update decode error: reason=%s" msg;
             Error (Error.Decode_error ("Failed to decode Update: " ^ msg)))
  with exn ->
    Log.error "Exception parsing webhook body: %s" (Printexc.to_string exn);
    Error (Error.Decode_error ("Exception parsing webhook body: " ^ Printexc.to_string exn))

(* Helper to read body and handle update *)
let handle_update_body flow chunk content_length handler on_error =
  let body_buf = Buffer.create content_length in
  let remaining = ref content_length in
  while !remaining > 0 do
    match Eio.Flow.single_read flow chunk with
    | 0 -> remaining := 0
    | n ->
        let to_read = min n !remaining in
        Buffer.add_string body_buf (Cstruct.to_string (Cstruct.sub chunk 0 to_read));
        remaining := !remaining - to_read
  done;
  let body_str = Buffer.contents body_buf in

  Log.debug' (fun () ->
    let preview = if String.length body_str > 500 then String.sub body_str 0 500 ^ "..." else body_str in
    Format.asprintf "Request body: %s" preview
  );

  (* Parse and handle update *)
  match parse_update body_str with
  | Error err ->
      (match on_error with
       | Some f -> f err
       | None -> ());
      ("400 Bad Request", "Bad Request: Invalid update format")
  | Ok update ->
      (try
         handler update;
         Log.info "Update dispatched successfully";
       with exn ->
         let err = Error.Decode_error ("Handler exception: " ^ Printexc.to_string exn) in
         (match on_error with
          | Some f -> f err
          | None -> ()));
      ("200 OK", "OK")

(* Simple HTTP server using Eio directly *)
let run_server client config sw ~handler =
  let env = Client.env client in
  let on_error = config.on_error in

  Log.info "Webhook server started: host=127.0.0.1, port=%d, path=%s" config.port config.path;

  (* Register cleanup on switch release *)
  Eio.Switch.on_release sw (fun () ->
    Log.info "Webhook server stopped"
  );

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
    ) (fun flow addr ->
      (* Extract client IP address *)
      let client_ip =
        match addr with
        | `Tcp (ip_addr, _port) ->
            Ipaddr.of_octets_exn (ip_addr :> string) |> Ipaddr.to_string
        | `Unix _ -> "unix"
      in

      (* Simple HTTP request parsing - just get body for POST *)
      try
        (* Read the request *)
        let chunk = Cstruct.create 4096 in
        let headers_done = ref false in
        let content_length = ref 0 in
        let path_info = ref "" in
        let method_type = ref "" in
        let secret_token_header = ref None in
        let all_headers = ref [] in

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
                );
                (* Collect all headers for custom validator *)
                if line <> "" && line <> "\r" && String.contains line ':' then (
                  match String.split_on_char ':' line with
                  | name :: rest ->
                      let value = String.trim (String.concat ":" rest) in
                      all_headers := (String.trim name, value) :: !all_headers
                  | _ -> ()
                )
              ) lines;
              if not !headers_done then
                read_headers (List.nth lines (List.length lines - 1))
        in
        read_headers "";

        (* Build request info for validation *)
        let request_info = {
          client_addr = client_ip;
          headers = List.rev !all_headers;
          path = !path_info;
          method_ = !method_type;
        } in

        Log.info "Webhook request received: source_ip=%s" client_ip;
        Log.debug' (fun () ->
          let headers_str = List.map (fun (k, v) -> k ^ ": " ^ v) request_info.headers
                           |> String.concat ", " in
          Format.asprintf "Request headers: %s" headers_str
        );

        (* Validate request *)
        let response_status, response_body =
          if !method_type <> "POST" || !path_info <> config.path then (
            Log.warn "Invalid request: reason=wrong method or path (method=%s, path=%s)" !method_type !path_info;
            ("404 Not Found", "Not Found")
          ) else (
            (* Check Content-Type header *)
            let has_json_ct = List.exists (fun (name, value) ->
              String.lowercase_ascii name = "content-type" &&
              String.contains (String.lowercase_ascii value) 'j'  (* contains 'j' for json *)
            ) request_info.headers in
            Log.debug "Content-Type header check: has_json=%b" has_json_ct;

            (* Check secret token *)
            let token_valid = match config.secret_token with
              | None ->
                  Log.debug "Secret token validation: no token configured, accepting";
                  true
              | Some expected ->
                  let is_valid = !secret_token_header = Some expected in
                  Log.debug "Secret token validation: is_valid=%b" is_valid;
                  if not is_valid then (
                    Log.warn "Secret token mismatch: expected=[REDACTED], received=%s"
                      (match !secret_token_header with Some _ -> "[REDACTED]" | None -> "[none]")
                  );
                  is_valid
            in

            if not token_valid then
              ("403 Forbidden", "Forbidden: Invalid secret token")
          else (
            (* Check IP allowlist if configured *)
            match config.ip_allowlist with
            | Some allowlist ->
                let ip_allowed = List.exists (fun cidr -> ip_in_range client_ip cidr) allowlist in
                Log.debug "IP validation check: source_ip=%s, is_allowed=%b" client_ip ip_allowed;
                if not ip_allowed then (
                  Log.warn "IP validation failed: source_ip=%s, allowed_ranges=[%s]"
                    client_ip (String.concat ", " allowlist);
                  ("403 Forbidden", "Forbidden: IP not in allowlist")
                ) else (
                  (* Check custom validator if configured *)
                  match config.custom_validator with
                  | Some validator ->
                      (match validator request_info with
                       | Accept ->
                           (* Proceed to handle update *)
                           handle_update_body flow chunk !content_length handler on_error
                       | Reject reason ->
                           Log.warn "Invalid request: reason=custom validator rejected - %s" reason;
                           ("403 Forbidden", "Forbidden: " ^ reason))
                  | None ->
                      (* No custom validator, proceed *)
                      handle_update_body flow chunk !content_length handler on_error
                )
            | None ->
                (* No IP allowlist, check custom validator *)
                (match config.custom_validator with
                 | Some validator ->
                     (match validator request_info with
                      | Accept ->
                          handle_update_body flow chunk !content_length handler on_error
                      | Reject reason ->
                          Log.warn "Invalid request: reason=custom validator rejected - %s" reason;
                          ("403 Forbidden", "Forbidden: " ^ reason))
                 | None ->
                     (* No validators, proceed *)
                     handle_update_body flow chunk !content_length handler on_error)
          )
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
