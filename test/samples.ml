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

let () =
  run "Curated samples" [
    ("roundtrip", [
      test_case "user" `Quick test_user_roundtrip;
      test_case "chat" `Quick test_chat_roundtrip;
    ])
  ]
