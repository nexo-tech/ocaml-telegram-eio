(* Tests for Parse_mode module *)

open Telegram

let test_to_string_markdown () =
  Alcotest.(check string) "Markdown" "Markdown" (Parse_mode.to_string `Markdown)

let test_to_string_markdownv2 () =
  Alcotest.(check string) "MarkdownV2" "MarkdownV2" (Parse_mode.to_string `MarkdownV2)

let test_to_string_html () =
  Alcotest.(check string) "HTML" "HTML" (Parse_mode.to_string `HTML)

let test_of_string_markdown () =
  match Parse_mode.of_string "Markdown" with
  | Some `Markdown -> ()
  | _ -> Alcotest.fail "should parse Markdown"

let test_of_string_markdownv2 () =
  match Parse_mode.of_string "MarkdownV2" with
  | Some `MarkdownV2 -> ()
  | _ -> Alcotest.fail "should parse MarkdownV2"

let test_of_string_html () =
  match Parse_mode.of_string "HTML" with
  | Some `HTML -> ()
  | _ -> Alcotest.fail "should parse HTML"

let test_of_string_invalid () =
  match Parse_mode.of_string "invalid" with
  | None -> ()
  | Some _ -> Alcotest.fail "should return None for invalid"

let test_roundtrip_markdown () =
  let mode = `Markdown in
  let s = Parse_mode.to_string mode in
  match Parse_mode.of_string s with
  | Some m -> Alcotest.(check bool) "roundtrip" true (m = mode)
  | None -> Alcotest.fail "roundtrip failed"

let test_roundtrip_markdownv2 () =
  let mode = `MarkdownV2 in
  let s = Parse_mode.to_string mode in
  match Parse_mode.of_string s with
  | Some m -> Alcotest.(check bool) "roundtrip" true (m = mode)
  | None -> Alcotest.fail "roundtrip failed"

let test_roundtrip_html () =
  let mode = `HTML in
  let s = Parse_mode.to_string mode in
  match Parse_mode.of_string s with
  | Some m -> Alcotest.(check bool) "roundtrip" true (m = mode)
  | None -> Alcotest.fail "roundtrip failed"

let test_json_markdown () =
  let json = Parse_mode.to_yojson `Markdown in
  match Parse_mode.of_yojson json with
  | Ok `Markdown -> ()
  | Ok _ -> Alcotest.fail "wrong mode"
  | Error msg -> Alcotest.fail msg

let test_json_markdownv2 () =
  let json = Parse_mode.to_yojson `MarkdownV2 in
  match Parse_mode.of_yojson json with
  | Ok `MarkdownV2 -> ()
  | Ok _ -> Alcotest.fail "wrong mode"
  | Error msg -> Alcotest.fail msg

let test_json_html () =
  let json = Parse_mode.to_yojson `HTML in
  match Parse_mode.of_yojson json with
  | Ok `HTML -> ()
  | Ok _ -> Alcotest.fail "wrong mode"
  | Error msg -> Alcotest.fail msg

let test_json_from_string () =
  match Parse_mode.of_yojson (`String "HTML") with
  | Ok `HTML -> ()
  | Ok _ -> Alcotest.fail "wrong mode"
  | Error msg -> Alcotest.fail msg

let test_json_invalid_string () =
  match Parse_mode.of_yojson (`String "invalid") with
  | Ok _ -> Alcotest.fail "should fail"
  | Error msg ->
      Alcotest.(check bool) "error contains 'Unknown'" true
        (String.sub msg 0 7 = "Unknown")

let test_json_invalid_type () =
  match Parse_mode.of_yojson (`Int 123) with
  | Ok _ -> Alcotest.fail "should fail"
  | Error msg ->
      Alcotest.(check string) "error message" "Parse_mode: expected string" msg

let test_pp_markdown () =
  let s = Format.asprintf "%a" Parse_mode.pp `Markdown in
  Alcotest.(check string) "pp" "Markdown" s

let test_pp_html () =
  let s = Format.asprintf "%a" Parse_mode.pp `HTML in
  Alcotest.(check string) "pp" "HTML" s

let () =
  let open Alcotest in
  run "Parse_mode" [
    "to_string", [
      test_case "markdown" `Quick test_to_string_markdown;
      test_case "markdownv2" `Quick test_to_string_markdownv2;
      test_case "html" `Quick test_to_string_html;
    ];
    "of_string", [
      test_case "markdown" `Quick test_of_string_markdown;
      test_case "markdownv2" `Quick test_of_string_markdownv2;
      test_case "html" `Quick test_of_string_html;
      test_case "invalid" `Quick test_of_string_invalid;
    ];
    "roundtrip", [
      test_case "markdown" `Quick test_roundtrip_markdown;
      test_case "markdownv2" `Quick test_roundtrip_markdownv2;
      test_case "html" `Quick test_roundtrip_html;
    ];
    "json", [
      test_case "markdown" `Quick test_json_markdown;
      test_case "markdownv2" `Quick test_json_markdownv2;
      test_case "html" `Quick test_json_html;
      test_case "from_string" `Quick test_json_from_string;
      test_case "invalid_string" `Quick test_json_invalid_string;
      test_case "invalid_type" `Quick test_json_invalid_type;
    ];
    "formatting", [
      test_case "pp_markdown" `Quick test_pp_markdown;
      test_case "pp_html" `Quick test_pp_html;
    ];
  ]
