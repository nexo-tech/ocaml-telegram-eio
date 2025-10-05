(* Tests for Id module *)

open Telegram

let test_chat_of_int () =
  let id = Id.Chat.of_int 12345L in
  Alcotest.(check string) "to_string" "12345" (Id.to_string id)

let test_chat_of_username () =
  let id = Id.Chat.of_username "my_channel" in
  Alcotest.(check string) "to_string" "my_channel" (Id.to_string id)

let test_chat_of_string_numeric () =
  let id = Id.Chat.of_string "12345" in
  Alcotest.(check string) "to_string" "12345" (Id.to_string id)

let test_chat_of_string_username () =
  let id = Id.Chat.of_string "my_channel" in
  Alcotest.(check string) "to_string" "my_channel" (Id.to_string id)

let test_user_of_int () =
  let id = Id.User.of_int 67890L in
  Alcotest.(check string) "to_string" "67890" (Id.to_string id)

let test_user_of_username () =
  let id = Id.User.of_username "john_doe" in
  Alcotest.(check string) "to_string" "john_doe" (Id.to_string id)

let test_message_of_int () =
  let id = Id.Message.of_int 42 in
  Alcotest.(check string) "to_string" "42" (Id.to_string id)

let test_update_of_int () =
  let id = Id.Update.of_int 999L in
  Alcotest.(check string) "to_string" "999" (Id.to_string id)

let test_token_of_string () =
  let token = Id.Token.of_string "123456:ABC-DEF" in
  Alcotest.(check string) "to_string" "123456:ABC-DEF" (Id.Token.to_string token)

let test_file_id_of_string () =
  let file_id = Id.File_id.of_string "AgADBAADGTo4Gz8cZAeR-ouu4XBx78EeqRkABHahi76pN-aO0UoD" in
  Alcotest.(check string) "to_string" "AgADBAADGTo4Gz8cZAeR-ouu4XBx78EeqRkABHahi76pN-aO0UoD"
    (Id.File_id.to_string file_id)

let test_pp_int64 () =
  let id = Id.Chat.of_int 12345L in
  let s = Format.asprintf "%a" Id.pp id in
  Alcotest.(check string) "pp format" "12345" s

let test_pp_username () =
  let id = Id.Chat.of_username "test" in
  let s = Format.asprintf "%a" Id.pp id in
  Alcotest.(check string) "pp format" "test" s

let () =
  let open Alcotest in
  run "Id" [
    "chat", [
      test_case "of_int" `Quick test_chat_of_int;
      test_case "of_username" `Quick test_chat_of_username;
      test_case "of_string_numeric" `Quick test_chat_of_string_numeric;
      test_case "of_string_username" `Quick test_chat_of_string_username;
    ];
    "user", [
      test_case "of_int" `Quick test_user_of_int;
      test_case "of_username" `Quick test_user_of_username;
    ];
    "message", [
      test_case "of_int" `Quick test_message_of_int;
    ];
    "update", [
      test_case "of_int" `Quick test_update_of_int;
    ];
    "token", [
      test_case "of_string" `Quick test_token_of_string;
    ];
    "file_id", [
      test_case "of_string" `Quick test_file_id_of_string;
    ];
    "formatting", [
      test_case "pp_int64" `Quick test_pp_int64;
      test_case "pp_username" `Quick test_pp_username;
    ];
  ]
