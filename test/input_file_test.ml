open Telegram

let test_file_id () =
  let f = Input_file.file_id "AgACAgIAAxkBAAIBY2..." in
  Alcotest.(check string) "file_id to_string" "AgACAgIAAxkBAAIBY2..." (Input_file.to_string f);
  Alcotest.(check bool) "file_id is not upload" false (Input_file.is_upload f)

let test_url () =
  let f = Input_file.url "https://example.com/photo.jpg" in
  Alcotest.(check string) "url to_string" "https://example.com/photo.jpg" (Input_file.to_string f);
  Alcotest.(check bool) "url is not upload" false (Input_file.is_upload f)

let test_path_jpg () =
  let f = Input_file.path "/tmp/photo.jpg" in
  Alcotest.(check string) "path jpg to_string" "attach://photo.jpg" (Input_file.to_string f);
  Alcotest.(check bool) "path is upload" true (Input_file.is_upload f);
  match Input_file.to_multipart_part ~field_name:"photo" f with
  | Some (_fn, filename, mime, path) ->
      Alcotest.(check string) "filename" "photo.jpg" filename;
      Alcotest.(check (option string)) "mime jpg" (Some "image/jpeg") mime;
      Alcotest.(check string) "path" "/tmp/photo.jpg" path
  | None -> Alcotest.fail "Expected multipart part for upload"

let test_path_png () =
  let f = Input_file.path "/home/user/images/screenshot.png" in
  Alcotest.(check string) "path png to_string" "attach://screenshot.png" (Input_file.to_string f);
  match Input_file.to_multipart_part ~field_name:"photo" f with
  | Some (_fn, _filename, mime, _path) ->
      Alcotest.(check (option string)) "mime png" (Some "image/png") mime
  | None -> Alcotest.fail "Expected multipart part"

let test_path_mp4 () =
  let f = Input_file.path "/videos/demo.mp4" in
  match Input_file.to_multipart_part ~field_name:"video" f with
  | Some (_fn, _filename, mime, _path) ->
      Alcotest.(check (option string)) "mime mp4" (Some "video/mp4") mime
  | None -> Alcotest.fail "Expected multipart part"

let test_path_pdf () =
  let f = Input_file.path "/docs/report.pdf" in
  match Input_file.to_multipart_part ~field_name:"document" f with
  | Some (_fn, _filename, mime, _path) ->
      Alcotest.(check (option string)) "mime pdf" (Some "application/pdf") mime
  | None -> Alcotest.fail "Expected multipart part"

let test_path_unknown () =
  let f = Input_file.path "/data/file.xyz" in
  match Input_file.to_multipart_part ~field_name:"document" f with
  | Some (_fn, _filename, mime, _path) ->
      Alcotest.(check (option string)) "mime unknown" None mime
  | None -> Alcotest.fail "Expected multipart part"

let test_upload () =
  let f = Input_file.upload ~filename:"custom.jpg" ~mime_type:"image/jpeg" "/tmp/file.dat" in
  Alcotest.(check string) "upload to_string" "attach://custom.jpg" (Input_file.to_string f);
  Alcotest.(check bool) "upload is upload" true (Input_file.is_upload f);
  match Input_file.to_multipart_part ~field_name:"photo" f with
  | Some (_fn, filename, mime, path) ->
      Alcotest.(check string) "custom filename" "custom.jpg" filename;
      Alcotest.(check (option string)) "custom mime" (Some "image/jpeg") mime;
      Alcotest.(check string) "path" "/tmp/file.dat" path
  | None -> Alcotest.fail "Expected multipart part"

let test_multipart_field_name () =
  let f = Input_file.path "/tmp/test.jpg" in
  match Input_file.to_multipart_part ~field_name:"photo" f with
  | Some (fn, _filename, _mime, _path) ->
      Alcotest.(check string) "field name matches" "photo" fn
  | None -> Alcotest.fail "Expected multipart part"

let () =
  let open Alcotest in
  run "InputFile" [
    "basic", [
      test_case "file_id" `Quick test_file_id;
      test_case "url" `Quick test_url;
      test_case "path jpg" `Quick test_path_jpg;
      test_case "path png" `Quick test_path_png;
      test_case "path mp4" `Quick test_path_mp4;
      test_case "path pdf" `Quick test_path_pdf;
      test_case "path unknown" `Quick test_path_unknown;
      test_case "upload" `Quick test_upload;
      test_case "multipart field name" `Quick test_multipart_field_name;
    ];
  ]
