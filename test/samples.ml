open Alcotest

module G = Telegram_generated.Gen_types

let test_user_roundtrip () =
  let json = `Assoc [
    ("id", `Int 123456);
    ("is_bot", `Bool false);
    ("first_name", `String "John");
    ("username", `String "john");
  ] in
  match G.User.of_yojson json with
  | Error msg -> fail msg
  | Ok u ->
      let j2 = G.User.to_yojson u in
      let open Yojson.Safe.Util in
      let id = (match member "id" j2 with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> -1L) in
      let is_bot = to_bool (member "is_bot" j2) in
      let first_name = to_string (member "first_name" j2) in
      let username = to_string_option (member "username" j2) in
      check int64 "id" 123456L id;
      check bool "is_bot" false is_bot;
      check string "first_name" "John" first_name;
      check (option string) "username" (Some "john") username;
      (* roundtrip decode again *)
      (match G.User.of_yojson j2 with
       | Ok _ -> ()
       | Error msg -> fail ("roundtrip decode failed: " ^ msg))

let test_chat_roundtrip () =
  let json = `Assoc [
    ("id", `Int 1);
    ("type", `String "private");
    ("username", `String "john_doe");
  ] in
  match G.Chat.of_yojson json with
  | Error msg -> fail msg
  | Ok c ->
      let j2 = G.Chat.to_yojson c in
      let open Yojson.Safe.Util in
      let id = (match member "id" j2 with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> -1L) in
      let typ = to_string (member "type" j2) in
      let username = to_string_option (member "username" j2) in
      check int64 "chat id" 1L id;
      check string "type" "private" typ;
      check (option string) "username" (Some "john_doe") username;
      (match G.Chat.of_yojson j2 with
       | Ok _ -> ()
       | Error msg -> fail ("roundtrip decode failed: " ^ msg))

let test_user_with_unknown_fields () =
  (* JSON with known fields + unknown future fields *)
  let json = `Assoc [
    ("id", `Int 123456);
    ("is_bot", `Bool false);
    ("first_name", `String "John");
    ("username", `String "john");
    (* Future fields not yet in our schema *)
    ("future_field_1", `String "future_value");
    ("future_field_2", `Int 42);
    ("nested_future", `Assoc [("key", `String "value")]);
  ] in
  match G.User.of_yojson json with
  | Error msg -> fail msg
  | Ok u ->
      (* Check that known fields are parsed correctly *)
      let j2 = G.User.to_yojson u in
      let open Yojson.Safe.Util in
      let id = (match member "id" j2 with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> -1L) in
      let first_name = to_string (member "first_name" j2) in
      check int64 "id" 123456L id;
      check string "first_name" "John" first_name;

      (* Check that unknown fields are preserved *)
      (match j2 with
       | `Assoc fields ->
           check bool "has future_field_1" true (List.mem_assoc "future_field_1" fields);
           check bool "has future_field_2" true (List.mem_assoc "future_field_2" fields);
           check bool "has nested_future" true (List.mem_assoc "nested_future" fields);

           (* Verify values are preserved correctly *)
           (match List.assoc "future_field_1" fields with
            | `String "future_value" -> ()
            | _ -> fail "future_field_1 value not preserved");
           (match List.assoc "future_field_2" fields with
            | `Int 42 -> ()
            | _ -> fail "future_field_2 value not preserved");
       | _ -> fail "Expected JSON object");

      (* Verify roundtrip preserves unknown fields *)
      (match G.User.of_yojson j2 with
       | Ok u2 ->
           let j3 = G.User.to_yojson u2 in
           (match j3 with
            | `Assoc fields ->
                check bool "roundtrip preserves future_field_1" true (List.mem_assoc "future_field_1" fields);
                check bool "roundtrip preserves future_field_2" true (List.mem_assoc "future_field_2" fields)
            | _ -> fail "Expected JSON object after roundtrip")
       | Error msg -> fail ("roundtrip decode failed: " ^ msg))

let test_chat_with_unknown_fields () =
  let json = `Assoc [
    ("id", `Int 1);
    ("type", `String "private");
    ("username", `String "john_doe");
    ("future_chat_field", `Bool true);
  ] in
  match G.Chat.of_yojson json with
  | Error msg -> fail msg
  | Ok c ->
      let j2 = G.Chat.to_yojson c in
      let open Yojson.Safe.Util in
      let id = (match member "id" j2 with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> -1L) in
      check int64 "chat id" 1L id;

      (* Verify unknown field is preserved *)
      (match j2 with
       | `Assoc fields ->
           check bool "has future_chat_field" true (List.mem_assoc "future_chat_field" fields)
       | _ -> fail "Expected JSON object")

let test_unknown_fields_dont_break_decoding () =
  (* Even with many unknown fields, decoding should succeed if required fields are present *)
  let json = `Assoc [
    ("id", `Int 999);
    ("is_bot", `Bool true);
    ("first_name", `String "Bot");
    ("unknown1", `String "a");
    ("unknown2", `String "b");
    ("unknown3", `String "c");
    ("unknown4", `String "d");
    ("unknown5", `String "e");
  ] in
  match G.User.of_yojson json with
  | Error msg -> fail ("Decoding should succeed with unknown fields: " ^ msg)
  | Ok u ->
      let j2 = G.User.to_yojson u in
      let open Yojson.Safe.Util in
      let id = (match member "id" j2 with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> -1L) in
      check int64 "id preserved" 999L id;
      (* All 5 unknown fields should be preserved *)
      (match j2 with
       | `Assoc fields ->
           let unknown_count = List.fold_left (fun acc (k, _) ->
             if String.starts_with ~prefix:"unknown" k then acc + 1 else acc
           ) 0 fields in
           check int "unknown fields count" 5 unknown_count
       | _ -> fail "Expected JSON object")

let () =
  run "Curated samples" [
    ("roundtrip", [
      test_case "user" `Quick test_user_roundtrip;
      test_case "chat" `Quick test_chat_roundtrip;
    ]);
    ("unknown_fields", [
      test_case "user with unknown fields" `Quick test_user_with_unknown_fields;
      test_case "chat with unknown fields" `Quick test_chat_with_unknown_fields;
      test_case "unknown fields don't break decoding" `Quick test_unknown_fields_dont_break_decoding;
    ]);
  ]
