open Error

let string_of_chat_id (id : Id.Chat.k Id.t) =
  Id.to_string id

let encode_send_message (r : _ Request.t) =
  match r with
  | Request.Send_message { chat_id; text; parse_mode; reply_parameters } ->
      let fields =
        [ "chat_id", `String (string_of_chat_id chat_id)
        ; "text", `String text
        ] @
        (match parse_mode with None -> [] | Some pm -> [ "parse_mode", `String (Parse_mode.to_string pm) ]) @
        (match reply_parameters with
         | None -> []
         | Some rp ->
           let rp_fields =
             (match rp.message_id with None -> [] | Some mid -> [ "message_id", `Int mid ]) in
           [ "reply_parameters", `Assoc rp_fields ])
      in
      Some (`Assoc fields)
  | _ -> None

let encode_send_photo (r : _ Request.t) =
  match r with
  | Request.Send_photo { chat_id; photo; caption } ->
      let chat_id_s = string_of_chat_id chat_id in
      begin match photo with
      | `File_id fid | `Url fid ->
          let fields =
            [ "chat_id", `String chat_id_s
            ; "photo", `String fid
            ] @ (match caption with None -> [] | Some c -> [ "caption", `String c ]) in
          (`Assoc fields, `JSON)
      | `Path path ->
          let parts =
            [ ("chat_id", `String chat_id_s)
            ; ("photo", `File (Filename.basename path, Some "application/octet-stream", path))
            ] @ (match caption with None -> [] | Some c -> [ ("caption", `String c) ]) in
          (`Null, `Multipart parts)
      end
  | _ -> (`Null, `JSON)

let build_url client method_name =
  Printf.sprintf "%s/bot%s/%s" (Client.base_url client) (Client.token client) method_name

let call (type a) (client : Client.t) (req : a Request.t) : (a, Error.t) result =
  match req with
  | Request.Send_message _ ->
      begin match encode_send_message req with
      | None -> Error (Not_implemented "encode_send_message")
      | Some json ->
          let url = build_url client "sendMessage" in
          let body = Yojson.Safe.to_string json in
          let http = Http.Cohttp_eio.v () in
          match Http.Cohttp_eio.call http ~meth:`POST ~url ~headers:[ "Content-Type", "application/json" ] ~body:(Http.String body) with
          | Error e -> Error e
          | Ok resp ->
              Response.parse_json resp.body
              |> Response.bind_result (fun res ->
                  let open Yojson.Safe.Util in
                  let open Types in
                  try
                    let message_id = res |> member "message_id" |> to_int in
                    let chat_id = res |> member "chat" |> member "id" |> to_int |> Int64.of_int |> fun i -> Id.Chat.of_int i in
                    let text = res |> member "text" |> to_string_option in
                    Ok { message_id; chat_id; text }
                  with _ -> Error (Decode_error "message decode"))
      end
  | Request.Send_photo _ ->
      let url = build_url client "sendPhoto" in
      let json, body_kind = encode_send_photo req in
      let http = Http.Cohttp_eio.v () in
      let headers, body =
        match body_kind with
        | `JSON -> [ "Content-Type", "application/json" ], Http.String (Yojson.Safe.to_string json)
        | `Multipart parts -> [], Http.Multipart parts
      in
      (match Http.Cohttp_eio.call http ~meth:`POST ~url ~headers ~body with
       | Error e -> Error e
       | Ok resp ->
           Response.parse_json resp.body
           |> Response.bind_result (fun res ->
               let open Yojson.Safe.Util in
               let open Types in
               try
                 let message_id = res |> member "message_id" |> to_int in
                 let chat_id = res |> member "chat" |> member "id" |> to_int |> Int64.of_int |> fun i -> Id.Chat.of_int i in
                 let text = res |> member "text" |> to_string_option in
                 Ok { message_id; chat_id; text }
               with _ -> Error (Decode_error "message decode")))

let call_json client ~method_name body =
  let url = Printf.sprintf "%s/bot%s/%s" (Client.base_url client) (Client.token client) method_name in
  let http = Http.Cohttp_eio.v () in
  match Http.Cohttp_eio.call http ~meth:`POST ~url ~headers:[ "Content-Type", "application/json" ] ~body:(Http.String (Yojson.Safe.to_string body)) with
  | Error e -> Error e
  | Ok resp -> Response.parse_json resp.body

(* New unified call_method that auto-detects JSON vs multipart *)
let call_method client ~method_name params =
  let url = build_url client method_name in
  let http = Http.Cohttp_eio.v () in

  (* Auto-detect if we need multipart encoding *)
  if Param.has_files params then
    (* Use multipart/form-data for file uploads *)
    let parts = Param.to_multipart params in
    match Http.Cohttp_eio.call http ~meth:`POST ~url ~headers:[] ~body:(Http.Multipart parts) with
    | Error e -> Error e
    | Ok resp -> Response.parse_json resp.body
  else
    (* Use application/json for simple requests *)
    let json = Param.to_json params in
    match Http.Cohttp_eio.call http ~meth:`POST ~url ~headers:[ "Content-Type", "application/json" ] ~body:(Http.String (Yojson.Safe.to_string json)) with
    | Error e -> Error e
    | Ok resp -> Response.parse_json resp.body
