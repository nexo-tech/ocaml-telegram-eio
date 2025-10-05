open Error

type method_ = [ `GET | `POST ]
type header = string * string

type part_value =
  [ `String of string
  | `File of string * string option * string ]

type body =
  | Empty
  | String of string
  | Multipart of (string * part_value) list

type response = { status : int; headers : header list; body : string }

module type S = sig
  type t
  val call : t -> meth:method_ -> url:string -> headers:header list -> body:body -> (response, Error.t) result
end

module Cohttp_eio = struct
  type t = unit

  let v () = ()

  let call _t ~meth ~url ~headers ~body : (response, Error.t) result =
    try
      Eio_main.run @@ fun env ->
      (* Ensure RNG for TLS handshakes *)
      Mirage_crypto_rng_eio.run (module Mirage_crypto_rng.Fortuna) env @@ fun () ->
      let net = env#net in
      let https_wrapper (uri:Uri.t) (socket : _ Eio.Flow.two_way) =
        let host =
          match Uri.host uri with
          | Some h ->
              let raw = Domain_name.of_string_exn h in
              Domain_name.host_exn raw
          | None -> failwith "HTTPS URI missing host"
        in
        let authenticator = match Ca_certs.authenticator () with Ok a -> a | Error (`Msg m) -> failwith m in
        let cfg = Tls.Config.client ~authenticator () in
        (Tls_eio.client_of_flow cfg ~host socket :> _ Eio.Flow.two_way)
      in
      let client = Cohttp_eio.Client.make ~https:(Some https_wrapper) net in
      let uri = Uri.of_string url in
      let cohttp_meth : Cohttp.Code.meth = (match meth with `GET -> `GET | `POST -> `POST) in
      let headers, body =
        let h = Cohttp.Header.of_list headers in
        match body with
        | Empty -> (h, None)
        | String s -> (h, Some (Cohttp_eio.Body.of_string s))
        | Multipart parts ->
            let boundary = "ocamltelegrameio" in
            let b = Buffer.create 1024 in
            let add_line s = Buffer.add_string b s; Buffer.add_string b "\r\n" in
            List.iter (fun (name, pv) ->
              match pv with
              | `String v ->
                  add_line ("--" ^ boundary);
                  add_line (Printf.sprintf "Content-Disposition: form-data; name=\"%s\"" name);
                  add_line ""; add_line v
              | `File (filename, content_type, path) ->
                  let ct = Option.value ~default:"application/octet-stream" content_type in
                  add_line ("--" ^ boundary);
                  add_line (Printf.sprintf
                              "Content-Disposition: form-data; name=\"%s\"; filename=\"%s\""
                              name filename);
                  add_line ("Content-Type: " ^ ct);
                  add_line "";
                  let ic = Stdlib.open_in_bin path in
                  let len = in_channel_length ic in
                  let content = really_input_string ic len in
                  close_in ic;
                  add_line content)
              parts;
            add_line ("--" ^ boundary ^ "--");
            let h = Cohttp.Header.replace h "Content-Type" ("multipart/form-data; boundary=" ^ boundary) in
            (h, Some (Cohttp_eio.Body.of_string (Buffer.contents b)))
      in
      let run_request () =
        Eio.Switch.run @@ fun sw ->
        let resp, resp_body = Cohttp_eio.Client.call client ~sw ~headers ?body cohttp_meth uri in
        let status = Cohttp.Code.code_of_status (Cohttp.Response.status resp) in
        let headers = Cohttp.Header.to_list (Cohttp.Response.headers resp) in
        (* Read full body into string *)
        let body_str =
          let buf = Buffer.create 4096 in
          let chunk = Cstruct.create 16384 in
          (try
             while true do
               let n = Eio.Flow.single_read resp_body chunk in
               if n = 0 then raise End_of_file;
               Buffer.add_string buf (Cstruct.to_string (Cstruct.sub chunk 0 n))
             done
           with End_of_file -> ());
          Buffer.contents buf
        in
        Ok { status; headers; body = body_str }
      in
      (try
         match Sys.getenv_opt "TELEGRAM_HTTP_TIMEOUT" with
         | None -> run_request ()
         | Some s ->
             let seconds = float_of_string s in
             Eio.Time.with_timeout_exn env#clock seconds run_request
       with Eio.Time.Timeout -> Error Timeout)
    with exn -> Error (Http_error (0, Printexc.to_string exn))
end
