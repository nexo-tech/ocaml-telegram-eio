(* Response parsing and error mapping for Telegram Bot API. *)

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
  match Yojson.Safe.from_string body with
  | exception Yojson.Json_error msg -> Error (Error.Decode_error ("Invalid JSON: " ^ msg))
  | exception exn -> Error (Error.Decode_error ("JSON parse error: " ^ Printexc.to_string exn))
  | json -> of_yojson json

let bind_result decoder result =
  match result with
  | Error e -> Error e
  | Ok result_json -> decoder result_json

let parse_and_decode body decoder =
  parse_json body |> bind_result (fun json ->
    match decoder json with
    | Ok value -> Ok value
    | Error msg -> Error (Error.Decode_error msg))
