(* Tests for Chat_action module *)

open Telegram

let test_to_string_typing () =
  Alcotest.(check string) "typing" "typing" (Chat_action.to_string `Typing)

let test_to_string_upload_photo () =
  Alcotest.(check string) "upload_photo" "upload_photo"
    (Chat_action.to_string `Upload_photo)

let test_to_string_record_video () =
  Alcotest.(check string) "record_video" "record_video"
    (Chat_action.to_string `Record_video)

let test_to_string_upload_video () =
  Alcotest.(check string) "upload_video" "upload_video"
    (Chat_action.to_string `Upload_video)

let test_to_string_record_voice () =
  Alcotest.(check string) "record_voice" "record_voice"
    (Chat_action.to_string `Record_voice)

let test_to_string_upload_voice () =
  Alcotest.(check string) "upload_voice" "upload_voice"
    (Chat_action.to_string `Upload_voice)

let test_to_string_upload_document () =
  Alcotest.(check string) "upload_document" "upload_document"
    (Chat_action.to_string `Upload_document)

let test_to_string_choose_sticker () =
  Alcotest.(check string) "choose_sticker" "choose_sticker"
    (Chat_action.to_string `Choose_sticker)

let test_to_string_find_location () =
  Alcotest.(check string) "find_location" "find_location"
    (Chat_action.to_string `Find_location)

let test_to_string_record_video_note () =
  Alcotest.(check string) "record_video_note" "record_video_note"
    (Chat_action.to_string `Record_video_note)

let test_to_string_upload_video_note () =
  Alcotest.(check string) "upload_video_note" "upload_video_note"
    (Chat_action.to_string `Upload_video_note)

let test_of_string_typing () =
  match Chat_action.of_string "typing" with
  | Some `Typing -> ()
  | _ -> Alcotest.fail "should parse typing"

let test_of_string_upload_photo () =
  match Chat_action.of_string "upload_photo" with
  | Some `Upload_photo -> ()
  | _ -> Alcotest.fail "should parse upload_photo"

let test_of_string_invalid () =
  match Chat_action.of_string "invalid_action" with
  | None -> ()
  | Some _ -> Alcotest.fail "should return None for invalid"

let test_roundtrip_typing () =
  let action = `Typing in
  let s = Chat_action.to_string action in
  match Chat_action.of_string s with
  | Some a -> Alcotest.(check bool) "roundtrip" true (a = action)
  | None -> Alcotest.fail "roundtrip failed"

let test_roundtrip_upload_document () =
  let action = `Upload_document in
  let s = Chat_action.to_string action in
  match Chat_action.of_string s with
  | Some a -> Alcotest.(check bool) "roundtrip" true (a = action)
  | None -> Alcotest.fail "roundtrip failed"

let test_roundtrip_all_actions () =
  let actions = [
    `Typing; `Upload_photo; `Record_video; `Upload_video;
    `Record_voice; `Upload_voice; `Upload_document; `Choose_sticker;
    `Find_location; `Record_video_note; `Upload_video_note
  ] in
  List.iter (fun action ->
    let s = Chat_action.to_string action in
    match Chat_action.of_string s with
    | Some a -> Alcotest.(check bool) "roundtrip" true (a = action)
    | None -> Alcotest.failf "roundtrip failed for %s" s
  ) actions

let test_json_typing () =
  let json = Chat_action.to_yojson `Typing in
  match Chat_action.of_yojson json with
  | Ok `Typing -> ()
  | Ok _ -> Alcotest.fail "wrong action"
  | Error msg -> Alcotest.fail msg

let test_json_upload_photo () =
  let json = Chat_action.to_yojson `Upload_photo in
  match Chat_action.of_yojson json with
  | Ok `Upload_photo -> ()
  | Ok _ -> Alcotest.fail "wrong action"
  | Error msg -> Alcotest.fail msg

let test_json_from_string () =
  match Chat_action.of_yojson (`String "typing") with
  | Ok `Typing -> ()
  | Ok _ -> Alcotest.fail "wrong action"
  | Error msg -> Alcotest.fail msg

let test_json_invalid_string () =
  match Chat_action.of_yojson (`String "invalid") with
  | Ok _ -> Alcotest.fail "should fail"
  | Error msg ->
      Alcotest.(check bool) "error contains 'Unknown'" true
        (String.sub msg 0 7 = "Unknown")

let test_json_invalid_type () =
  match Chat_action.of_yojson (`Int 123) with
  | Ok _ -> Alcotest.fail "should fail"
  | Error msg ->
      Alcotest.(check string) "error message" "Chat_action: expected string" msg

let test_json_roundtrip_all () =
  let actions = [
    `Typing; `Upload_photo; `Record_video; `Upload_video;
    `Record_voice; `Upload_voice; `Upload_document; `Choose_sticker;
    `Find_location; `Record_video_note; `Upload_video_note
  ] in
  List.iter (fun action ->
    let json = Chat_action.to_yojson action in
    match Chat_action.of_yojson json with
    | Ok a -> Alcotest.(check bool) "json roundtrip" true (a = action)
    | Error msg -> Alcotest.failf "json roundtrip failed: %s" msg
  ) actions

let test_pp_typing () =
  let s = Format.asprintf "%a" Chat_action.pp `Typing in
  Alcotest.(check string) "pp" "typing" s

let test_pp_upload_document () =
  let s = Format.asprintf "%a" Chat_action.pp `Upload_document in
  Alcotest.(check string) "pp" "upload_document" s

let () =
  let open Alcotest in
  run "Chat_action" [
    "to_string", [
      test_case "typing" `Quick test_to_string_typing;
      test_case "upload_photo" `Quick test_to_string_upload_photo;
      test_case "record_video" `Quick test_to_string_record_video;
      test_case "upload_video" `Quick test_to_string_upload_video;
      test_case "record_voice" `Quick test_to_string_record_voice;
      test_case "upload_voice" `Quick test_to_string_upload_voice;
      test_case "upload_document" `Quick test_to_string_upload_document;
      test_case "choose_sticker" `Quick test_to_string_choose_sticker;
      test_case "find_location" `Quick test_to_string_find_location;
      test_case "record_video_note" `Quick test_to_string_record_video_note;
      test_case "upload_video_note" `Quick test_to_string_upload_video_note;
    ];
    "of_string", [
      test_case "typing" `Quick test_of_string_typing;
      test_case "upload_photo" `Quick test_of_string_upload_photo;
      test_case "invalid" `Quick test_of_string_invalid;
    ];
    "roundtrip", [
      test_case "typing" `Quick test_roundtrip_typing;
      test_case "upload_document" `Quick test_roundtrip_upload_document;
      test_case "all_actions" `Quick test_roundtrip_all_actions;
    ];
    "json", [
      test_case "typing" `Quick test_json_typing;
      test_case "upload_photo" `Quick test_json_upload_photo;
      test_case "from_string" `Quick test_json_from_string;
      test_case "invalid_string" `Quick test_json_invalid_string;
      test_case "invalid_type" `Quick test_json_invalid_type;
      test_case "roundtrip_all" `Quick test_json_roundtrip_all;
    ];
    "formatting", [
      test_case "pp_typing" `Quick test_pp_typing;
      test_case "pp_upload_document" `Quick test_pp_upload_document;
    ];
  ]
