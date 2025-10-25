(* Response parsing and error mapping for Telegram Bot API. *)

(** Scoped logger for response parsing operations *)
module Log = Flo_scoped.Make(struct
  let namespace = "telegram.api.response"
end)

let extract_error json =
  let open Yojson.Safe.Util in
  let description = json |> member "description" |> to_string_option |> Option.value ~default:"Unknown error" in
  let error_code = json |> member "error_code" |> to_int_option |> Option.value ~default:400 in

  let parameters =
    try
      let p = json |> member "parameters" in
      match p with
      | `Null -> None
      | _ ->
          let retry_after = p |> member "retry_after" |> to_int_option in
          let migrate_to_chat_id =
            p |> member "migrate_to_chat_id" |> to_int_option
            |> Option.map (fun i -> Id.Chat.of_int (Int64.of_int i))
          in
          Some { Error.migrate_to_chat_id; retry_after }
    with _ -> None
  in

  Error.Api_error { code = error_code; description; parameters }

let of_yojson json =
  let open Yojson.Safe.Util in
  try
    let ok = json |> member "ok" |> to_bool_option |> Option.value ~default:false in
    if ok then
      Ok (member "result" json)
    else
      Error (extract_error json)
  with
  | Type_error (msg, _) -> Error (Error.Decode_error ("Response parse error: " ^ msg))
  | exn -> Error (Error.Decode_error ("Unexpected error: " ^ Printexc.to_string exn))

let parse_json body =
  let open Flo in
  (* Debug level: parsing details (hidden by default) *)
  Log.debugf "Parsing Telegram API response (%d bytes)" (String.length body);

  match Yojson.Safe.from_string body with
  | exception Yojson.Json_error msg ->
      (* Warn level: validation errors (visible by default) *)
      Log.warn_fields "Invalid JSON in API response" ~fields:[
        Flo_semconv.error_type "JsonError";
        Flo_semconv.error_message msg;
        ("body_length", Value.int (String.length body));
      ];
      Error (Error.Decode_error ("Invalid JSON: " ^ msg))
  | exception exn ->
      (* Warn level: validation errors (visible by default) *)
      Log.warn_fields "JSON parse error" ~fields:[
        Flo_semconv.error_type (Printexc.to_string exn);
        Flo_semconv.error_message (Printexc.to_string exn);
      ];
      Error (Error.Decode_error ("JSON parse error: " ^ Printexc.to_string exn))
  | json ->
      let result = of_yojson json in
      (match result with
       | Ok _ ->
           (* Debug level: successful parsing (hidden by default) *)
           Log.debug "API response parsed successfully"
       | Error (Error.Api_error { code; description; _ }) ->
           (* Debug level: API errors are logged at API layer (hidden by default) *)
           Log.debugf "API returned error: %d - %s" code description
       | Error (Error.Decode_error msg) ->
           (* Warn level: decode errors (visible by default) *)
           Log.warn_fields "Response decode error" ~fields:[
             Flo_semconv.error_type "DecodeError";
             Flo_semconv.error_message msg;
           ]
       | Error _ ->
           (* Warn level: other errors (visible by default) *)
           Log.warn "Response parsing returned error");
      result

let bind_result decoder result =
  match result with
  | Error e -> Error e
  | Ok result_json -> decoder result_json

let parse_and_decode body decoder =
  parse_json body |> bind_result (fun json ->
    match decoder json with
    | Ok value -> Ok value
    | Error msg -> Error (Error.Decode_error msg))
