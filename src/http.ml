open Error

type method_ = [ `GET | `POST ]
type header = string * string

type part_value =
  [ `String of string
  | `File of string * string option * string ]

type progress_callback = bytes_sent:int64 -> total_bytes:int64 option -> unit

type body =
  | Empty
  | String of string
  | Multipart of (string * part_value) list
  | Multipart_progress of (string * part_value) list * progress_callback

type response = { status : int; headers : header list; body : string }

module type S = sig
  type t
  val call : t -> meth:method_ -> url:string -> headers:header list -> body:body -> (response, Error.t) result
end

module Cohttp_eio = struct
  type t = { chunk_size : int }

  let v ?(chunk_size = 16384) () = { chunk_size }

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
        | Multipart parts | Multipart_progress (parts, _) ->
            (* Streaming multipart builder as a Flow source *)
            let progress_cb = match body with Multipart_progress (_, cb) -> Some cb | _ -> None in
            let boundary = "ocamltelegrameio" in
            let module Multipart_flow = struct
              type file_state = { path : string; ic : in_channel option }
              type segment =
                | S of string * int (* string with current offset *)
                | F of file_state   (* file to stream *)
              type t = {
                mutable segs : segment list;
                mutable bytes_sent : int64;
                total_bytes : int64 option;
                progress_cb : progress_callback option;
              }

              let of_parts parts =
                let segments = ref [] in
                let total_size = ref 0L in
                let crlf = "\r\n" in
                let emit s =
                  total_size := Int64.add !total_size (Int64.of_int (String.length s));
                  segments := S (s, 0) :: !segments
                in
                let emit_header name filename content_type =
                  emit ("--" ^ boundary ^ crlf);
                  (match filename with
                   | None -> emit (Printf.sprintf "Content-Disposition: form-data; name=\"%s\"%s" name crlf)
                   | Some fn ->
                       emit (Printf.sprintf "Content-Disposition: form-data; name=\"%s\"; filename=\"%s\"%s" name fn crlf));
                  (match content_type with
                   | None -> ()
                   | Some ct -> emit ("Content-Type: " ^ ct ^ crlf));
                  emit crlf
                in
                List.iter (fun (name, pv) ->
                  match pv with
                  | `String v ->
                      emit_header name None None;
                      emit v; emit crlf
                  | `File (filename, content_type, path) ->
                      emit_header name (Some filename) content_type;
                      (* Add file size to total if possible *)
                      (try
                        let st = Unix.stat path in
                        total_size := Int64.add !total_size (Int64.of_int st.Unix.st_size)
                      with _ -> ());
                      segments := F { path; ic = None } :: !segments;
                      emit crlf
                ) parts;
                emit ("--" ^ boundary ^ "--" ^ crlf);
                {
                  segs = List.rev !segments;
                  bytes_sent = 0L;
                  total_bytes = (if !total_size > 0L then Some !total_size else None);
                  progress_cb;
                }

              let single_read t dst =
                let open Cstruct in
                if t.segs = [] then raise End_of_file;
                let rec loop segs written =
                  if written = length dst then (List.rev segs, written)
                  else match segs with
                  | [] -> (List.rev segs, written)
                  | S (s, off) :: tl ->
                      let rem = String.length s - off in
                      if rem <= 0 then loop tl written
                      else
                        let to_copy = min rem (length dst - written) in
                        blit_from_string s off dst written to_copy;
                        let off' = off + to_copy in
                        let segs' = if off' = String.length s then tl else S (s, off') :: tl in
                        loop segs' (written + to_copy)
                  | F st :: tl ->
                      let ic = match st.ic with None -> open_in_bin st.path | Some ic -> ic in
                      let buf_len = min _t.chunk_size (length dst - written) in
                      let bytes = Bytes.create buf_len in
                      let n = input ic bytes 0 buf_len in
                      if n = 0 then begin
                        close_in_noerr ic;
                        loop tl written
                      end else begin
                        blit_from_bytes bytes 0 dst written n;
                        let segs' = F { path = st.path; ic = Some ic } :: tl in
                        loop segs' (written + n)
                      end
                in
                let segs', n = loop t.segs 0 in
                t.segs <- segs';
                (* Update progress *)
                t.bytes_sent <- Int64.add t.bytes_sent (Int64.of_int n);
                (match t.progress_cb with
                 | Some cb -> cb ~bytes_sent:t.bytes_sent ~total_bytes:t.total_bytes
                 | None -> ());
                n

              let read_methods = []
            end in
            let handler = Eio.Flow.Pi.source (module Multipart_flow) in
            let body = Eio.Resource.T (Multipart_flow.of_parts parts, handler) in
            let h = Cohttp.Header.replace h "Content-Type" ("multipart/form-data; boundary=" ^ boundary) in
            (h, Some body)
      in
      let run_request () =
        Eio.Switch.run @@ fun sw ->
        let resp, resp_body = Cohttp_eio.Client.call client ~sw ~headers ?body cohttp_meth uri in
        let status = Cohttp.Code.code_of_status (Cohttp.Response.status resp) in
        let headers = Cohttp.Header.to_list (Cohttp.Response.headers resp) in
        (* Read full body into string *)
        let body_str =
          let buf = Buffer.create 4096 in
          let chunk = Cstruct.create _t.chunk_size in
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
