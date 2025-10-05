(* Tests for foundation types: Money, Units, Chat_action *)

open Telegram

let test_money_basics () =
  let m = Money.make ~currency:"USD" ~amount:12345L in
  Alcotest.(check string) "currency" "USD" (Money.currency m);
  Alcotest.(check int64) "amount" 12345L (Money.amount m);
  Alcotest.(check string) "to_string" "123.45 USD" (Money.to_string m)

let test_money_zero_decimal () =
  let m = Money.make ~currency:"JPY" ~amount:1234L in
  Alcotest.(check string) "JPY has 0 decimals" "1234 JPY" (Money.to_string m)

let test_money_three_decimal () =
  let m = Money.make ~currency:"BHD" ~amount:12345L in
  Alcotest.(check string) "BHD has 3 decimals" "12.345 BHD" (Money.to_string m)

let test_money_json_roundtrip () =
  let m = Money.make ~currency:"EUR" ~amount:9999L in
  let json = Money.to_yojson m in
  match Money.of_yojson json with
  | Ok m' ->
      Alcotest.(check string) "currency preserved" "EUR" (Money.currency m');
      Alcotest.(check int64) "amount preserved" 9999L (Money.amount m')
  | Error msg -> Alcotest.fail ("JSON decode failed: " ^ msg)

let test_money_equal () =
  let m1 = Money.make ~currency:"USD" ~amount:100L in
  let m2 = Money.make ~currency:"USD" ~amount:100L in
  let m3 = Money.make ~currency:"USD" ~amount:200L in
  Alcotest.(check bool) "equal" true (Money.equal m1 m2);
  Alcotest.(check bool) "not equal" false (Money.equal m1 m3)

let test_money_compare () =
  let m1 = Money.make ~currency:"USD" ~amount:100L in
  let m2 = Money.make ~currency:"USD" ~amount:200L in
  Alcotest.(check int) "compare <" (-1) (Money.compare m1 m2);
  Alcotest.(check int) "compare >" 1 (Money.compare m2 m1);
  Alcotest.(check int) "compare =" 0 (Money.compare m1 m1)

let test_duration_formatting () =
  let d1 = Units.Duration.seconds 45 in
  Alcotest.(check string) "45s" "45s" (Units.Duration.to_string d1);

  let d2 = Units.Duration.seconds 90 in
  Alcotest.(check string) "1m30s" "1m30s" (Units.Duration.to_string d2);

  let d3 = Units.Duration.seconds 3600 in
  Alcotest.(check string) "1h" "1h" (Units.Duration.to_string d3);

  let d4 = Units.Duration.seconds 3661 in
  Alcotest.(check string) "1h1m1s" "1h1m1s" (Units.Duration.to_string d4)

let test_duration_json () =
  let d = Units.Duration.seconds 120 in
  let json = Units.Duration.to_yojson d in
  match Units.Duration.of_yojson json with
  | Ok d' ->
      Alcotest.(check int) "duration preserved" 120 (Units.Duration.to_int d')
  | Error msg -> Alcotest.fail ("JSON decode failed: " ^ msg)

let test_file_size_formatting () =
  let s1 = Units.File_size.bytes 512L in
  Alcotest.(check string) "512 B" "512 B" (Units.File_size.to_string s1);

  let s2 = Units.File_size.bytes 1536L in
  Alcotest.(check string) "1.5 KB" "1.5 KB" (Units.File_size.to_string s2);

  let s3 = Units.File_size.bytes 2097152L in
  Alcotest.(check string) "2.0 MB" "2.0 MB" (Units.File_size.to_string s3);

  let s4 = Units.File_size.bytes 1073741824L in
  Alcotest.(check string) "1.0 GB" "1.0 GB" (Units.File_size.to_string s4)

let test_file_size_json () =
  let s = Units.File_size.bytes 99999L in
  let json = Units.File_size.to_yojson s in
  match Units.File_size.of_yojson json with
  | Ok s' ->
      Alcotest.(check int64) "size preserved" 99999L (Units.File_size.to_int64 s')
  | Error msg -> Alcotest.fail ("JSON decode failed: " ^ msg)

let test_chat_action_to_string () =
  Alcotest.(check string) "typing" "typing" (Chat_action.to_string `Typing);
  Alcotest.(check string) "upload_photo" "upload_photo" (Chat_action.to_string `Upload_photo);
  Alcotest.(check string) "record_video" "record_video" (Chat_action.to_string `Record_video)

let test_chat_action_roundtrip () =
  let actions = [
    `Typing;
    `Upload_photo;
    `Record_video;
    `Upload_video;
    `Record_voice;
    `Upload_voice;
    `Upload_document;
    `Choose_sticker;
    `Find_location;
    `Record_video_note;
    `Upload_video_note;
  ] in
  List.iter (fun action ->
    let s = Chat_action.to_string action in
    match Chat_action.of_string s with
    | Some a ->
        Alcotest.(check string) "roundtrip" s (Chat_action.to_string a)
    | None ->
        Alcotest.fail ("Failed to parse: " ^ s)
  ) actions

let test_chat_action_json () =
  let action = `Upload_document in
  let json = Chat_action.to_yojson action in
  match Chat_action.of_yojson json with
  | Ok a ->
      Alcotest.(check string) "action preserved"
        (Chat_action.to_string action) (Chat_action.to_string a)
  | Error msg -> Alcotest.fail ("JSON decode failed: " ^ msg)

let () =
  let open Alcotest in
  run "Foundation types" [
    "money", [
      test_case "basics" `Quick test_money_basics;
      test_case "zero decimals (JPY)" `Quick test_money_zero_decimal;
      test_case "three decimals (BHD)" `Quick test_money_three_decimal;
      test_case "JSON roundtrip" `Quick test_money_json_roundtrip;
      test_case "equality" `Quick test_money_equal;
      test_case "comparison" `Quick test_money_compare;
    ];
    "duration", [
      test_case "formatting" `Quick test_duration_formatting;
      test_case "JSON roundtrip" `Quick test_duration_json;
    ];
    "file_size", [
      test_case "formatting" `Quick test_file_size_formatting;
      test_case "JSON roundtrip" `Quick test_file_size_json;
    ];
    "chat_action", [
      test_case "to_string" `Quick test_chat_action_to_string;
      test_case "string roundtrip" `Quick test_chat_action_roundtrip;
      test_case "JSON roundtrip" `Quick test_chat_action_json;
    ];
  ]
