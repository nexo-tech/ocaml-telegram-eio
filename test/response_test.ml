(* Tests for Response parsing and error mapping *)

open Telegram

(* Test successful response parsing *)
let test_parse_success () =
  let json_body = {|{"ok": true, "result": {"foo": "bar"}}|} in
  match Response.parse_json json_body with
  | Error e -> Alcotest.fail (Format.asprintf "Expected Ok, got Error: %a" Error.pp e)
  | Ok result ->
      match result with
      | `Assoc fields ->
          Alcotest.(check bool) "has foo field" true (List.mem_assoc "foo" fields);
          (match List.assoc "foo" fields with
           | `String "bar" -> ()
           | _ -> Alcotest.fail "Expected foo='bar'")
      | _ -> Alcotest.fail "Expected object result"

(* Test error response with error_code and description *)
let test_parse_error_basic () =
  let json_body = {|{"ok": false, "error_code": 400, "description": "Bad Request: test error"}|} in
  match Response.parse_json json_body with
  | Ok _ -> Alcotest.fail "Expected Error, got Ok"
  | Error (Error.Api_error { code; description; parameters }) ->
      Alcotest.(check int) "error code" 400 code;
      Alcotest.(check string) "description" "Bad Request: test error" description;
      Alcotest.(check bool) "no parameters" true (parameters = None)
  | Error e -> Alcotest.fail (Format.asprintf "Expected Api_error, got: %a" Error.pp e)

(* Test error response with retry_after parameter *)
let test_parse_error_retry_after () =
  let json_body = {|{
    "ok": false,
    "error_code": 429,
    "description": "Too Many Requests: retry after 30",
    "parameters": {"retry_after": 30}
  }|} in
  match Response.parse_json json_body with
  | Ok _ -> Alcotest.fail "Expected Error, got Ok"
  | Error (Error.Api_error { code; description; parameters }) ->
      Alcotest.(check int) "error code" 429 code;
      Alcotest.(check bool) "description non-empty" true
        (String.length description > 0);
      (match parameters with
       | None -> Alcotest.fail "Expected parameters"
       | Some { retry_after; _ } ->
           (match retry_after with
            | None -> Alcotest.fail "Expected retry_after"
            | Some secs -> Alcotest.(check int) "retry_after is 30" 30 secs))
  | Error e -> Alcotest.fail (Format.asprintf "Expected Api_error, got: %a" Error.pp e)

(* Test error response with migrate_to_chat_id parameter *)
let test_parse_error_migrate () =
  let json_body = {|{
    "ok": false,
    "error_code": 400,
    "description": "Bad Request: group chat was upgraded to a supergroup chat",
    "parameters": {"migrate_to_chat_id": -1001234567890}
  }|} in
  match Response.parse_json json_body with
  | Ok _ -> Alcotest.fail "Expected Error, got Ok"
  | Error (Error.Api_error { parameters; _ }) ->
      (match parameters with
       | None -> Alcotest.fail "Expected parameters"
       | Some { migrate_to_chat_id; _ } ->
           (match migrate_to_chat_id with
            | None -> Alcotest.fail "Expected migrate_to_chat_id"
            | Some chat_id ->
                (* Verify it's the correct ID by converting to string *)
                let id_str = Id.to_string chat_id in
                Alcotest.(check string) "migrate_to_chat_id" "-1001234567890" id_str))
  | Error e -> Alcotest.fail (Format.asprintf "Expected Api_error, got: %a" Error.pp e)

(* Test invalid JSON *)
let test_parse_invalid_json () =
  let json_body = {|{invalid json}|} in
  match Response.parse_json json_body with
  | Ok _ -> Alcotest.fail "Expected Error, got Ok"
  | Error (Error.Decode_error msg) ->
      Alcotest.(check bool) "error message mentions JSON" true
        (String.length msg > 0 && (String.lowercase_ascii msg |> fun s -> String.contains s 'j'))
  | Error e -> Alcotest.fail (Format.asprintf "Expected Decode_error, got: %a" Error.pp e)

(* Test parse_and_decode with successful decode *)
let test_parse_and_decode_success () =
  let json_body = {|{"ok": true, "result": {"id": 123, "name": "test"}}|} in
  let decoder json =
    try
      let open Yojson.Safe.Util in
      let id = json |> member "id" |> to_int in
      let name = json |> member "name" |> to_string in
      Ok (id, name)
    with _ -> Error "decode failed"
  in
  match Response.parse_and_decode json_body decoder with
  | Error e -> Alcotest.fail (Format.asprintf "Expected Ok, got Error: %a" Error.pp e)
  | Ok (id, name) ->
      Alcotest.(check int) "id" 123 id;
      Alcotest.(check string) "name" "test" name

(* Test parse_and_decode with decode failure *)
let test_parse_and_decode_failure () =
  let json_body = {|{"ok": true, "result": {}}|} in
  let decoder _json = Error "intentional decode error" in
  match Response.parse_and_decode json_body decoder with
  | Ok _ -> Alcotest.fail "Expected Error, got Ok"
  | Error (Error.Decode_error msg) ->
      Alcotest.(check string) "error message" "intentional decode error" msg
  | Error e -> Alcotest.fail (Format.asprintf "Expected Decode_error, got: %a" Error.pp e)

(* Test Error.is_retryable *)
let test_is_retryable () =
  (* 429 is retryable *)
  Alcotest.(check bool) "429 is retryable" true
    (Error.is_retryable (Error.Api_error { code = 429; description = ""; parameters = None }));

  (* 500-599 is retryable *)
  Alcotest.(check bool) "500 is retryable" true
    (Error.is_retryable (Error.Api_error { code = 500; description = ""; parameters = None }));

  (* 400 is not retryable *)
  Alcotest.(check bool) "400 is not retryable" false
    (Error.is_retryable (Error.Api_error { code = 400; description = ""; parameters = None }));

  (* Decode_error is not retryable *)
  Alcotest.(check bool) "Decode_error is not retryable" false
    (Error.is_retryable (Error.Decode_error "test"));

  (* Timeout is retryable *)
  Alcotest.(check bool) "Timeout is retryable" true
    (Error.is_retryable Error.Timeout)

(* Test Error.retry_after extraction *)
let test_retry_after_extraction () =
  let err_with_retry = Error.Api_error {
    code = 429;
    description = "";
    parameters = Some { retry_after = Some 30; migrate_to_chat_id = None }
  } in
  Alcotest.(check (option int)) "extracts retry_after" (Some 30)
    (Error.retry_after err_with_retry);

  let err_without_retry = Error.Api_error {
    code = 400;
    description = "";
    parameters = None
  } in
  Alcotest.(check (option int)) "no retry_after" None
    (Error.retry_after err_without_retry)

let () =
  let open Alcotest in
  run "Response parsing and error mapping" [
    "response", [
      test_case "parse success" `Quick test_parse_success;
      test_case "parse error basic" `Quick test_parse_error_basic;
      test_case "parse error with retry_after" `Quick test_parse_error_retry_after;
      test_case "parse error with migrate_to_chat_id" `Quick test_parse_error_migrate;
      test_case "parse invalid JSON" `Quick test_parse_invalid_json;
      test_case "parse_and_decode success" `Quick test_parse_and_decode_success;
      test_case "parse_and_decode failure" `Quick test_parse_and_decode_failure;
      test_case "is_retryable" `Quick test_is_retryable;
      test_case "retry_after extraction" `Quick test_retry_after_extraction;
    ];
  ]
