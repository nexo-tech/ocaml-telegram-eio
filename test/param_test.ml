open Telegram

let test_to_json_simple () =
  let params = [
    ("chat_id", Param.string "12345");
    ("text", Param.string "Hello");
    ("count", Param.int 42);
    ("enabled", Param.bool true);
  ] in
  let json = Param.to_json params in
  let open Yojson.Safe.Util in
  Alcotest.(check string) "chat_id" "12345" (json |> member "chat_id" |> to_string);
  Alcotest.(check string) "text" "Hello" (json |> member "text" |> to_string);
  Alcotest.(check int) "count" 42 (json |> member "count" |> to_int);
  Alcotest.(check bool) "enabled" true (json |> member "enabled" |> to_bool)

let test_to_json_int64 () =
  let params = [("user_id", Param.int64 123456789012345L)] in
  let json = Param.to_json params in
  let json_str = Yojson.Safe.to_string json in
  Alcotest.(check bool) "int64 in json" true
    (String.contains json_str '1' && String.contains json_str '2')

let test_to_json_float () =
  let params = [("latitude", Param.float 37.7749)] in
  let json = Param.to_json params in
  let open Yojson.Safe.Util in
  let lat = json |> member "latitude" |> to_float in
  Alcotest.(check bool) "float value" true (abs_float (lat -. 37.7749) < 0.0001)

let test_to_json_list () =
  let params = [
    ("ids", Param.list [Param.int 1; Param.int 2; Param.int 3])
  ] in
  let json = Param.to_json params in
  let open Yojson.Safe.Util in
  let ids = json |> member "ids" |> to_list |> List.map to_int in
  Alcotest.(check (list int)) "list of ints" [1; 2; 3] ids

let test_to_json_file_id () =
  let params = [
    ("photo", Param.file (Input_file.file_id "AgACAgIAAxkBAAIBY2..."))
  ] in
  let json = Param.to_json params in
  let open Yojson.Safe.Util in
  Alcotest.(check string) "file_id in json" "AgACAgIAAxkBAAIBY2..."
    (json |> member "photo" |> to_string)

let test_to_json_url () =
  let params = [
    ("photo", Param.file (Input_file.url "https://example.com/photo.jpg"))
  ] in
  let json = Param.to_json params in
  let open Yojson.Safe.Util in
  Alcotest.(check string) "url in json" "https://example.com/photo.jpg"
    (json |> member "photo" |> to_string)

let test_to_json_upload () =
  let params = [
    ("photo", Param.file (Input_file.path "/tmp/photo.jpg"))
  ] in
  let json = Param.to_json params in
  let open Yojson.Safe.Util in
  Alcotest.(check string) "upload attach:// in json" "attach://photo.jpg"
    (json |> member "photo" |> to_string)

let test_has_files_no_files () =
  let params = [
    ("chat_id", Param.string "12345");
    ("text", Param.string "Hello");
  ] in
  Alcotest.(check bool) "no files" false (Param.has_files params)

let test_has_files_file_id () =
  let params = [
    ("photo", Param.file (Input_file.file_id "AgACAgIAAxkBAAIBY2..."))
  ] in
  Alcotest.(check bool) "file_id not upload" false (Param.has_files params)

let test_has_files_url () =
  let params = [
    ("photo", Param.file (Input_file.url "https://example.com/photo.jpg"))
  ] in
  Alcotest.(check bool) "url not upload" false (Param.has_files params)

let test_has_files_upload () =
  let params = [
    ("photo", Param.file (Input_file.path "/tmp/photo.jpg"))
  ] in
  Alcotest.(check bool) "upload detected" true (Param.has_files params)

let test_has_files_mixed () =
  let params = [
    ("chat_id", Param.string "12345");
    ("photo", Param.file (Input_file.path "/tmp/photo.jpg"));
    ("caption", Param.string "Hello");
  ] in
  Alcotest.(check bool) "mixed with upload" true (Param.has_files params)

let test_has_files_in_list () =
  let params = [
    ("media", Param.list [
      Param.file (Input_file.file_id "abc");
      Param.file (Input_file.path "/tmp/photo.jpg");
    ])
  ] in
  Alcotest.(check bool) "upload in list" true (Param.has_files params)

let test_to_multipart_simple () =
  let params = [
    ("chat_id", Param.string "12345");
    ("text", Param.string "Hello");
    ("count", Param.int 42);
    ("enabled", Param.bool true);
  ] in
  let parts = Param.to_multipart params in
  let find name = List.assoc name parts in
  (match find "chat_id" with
   | `String "12345" -> ()
   | _ -> Alcotest.fail "chat_id should be string");
  (match find "text" with
   | `String "Hello" -> ()
   | _ -> Alcotest.fail "text should be string");
  (match find "count" with
   | `String "42" -> ()
   | _ -> Alcotest.fail "count should be string '42'");
  (match find "enabled" with
   | `String "true" -> ()
   | _ -> Alcotest.fail "enabled should be string 'true'")

let test_to_multipart_file () =
  let params = [
    ("chat_id", Param.string "12345");
    ("photo", Param.file (Input_file.path "/tmp/photo.jpg"));
  ] in
  let parts = Param.to_multipart params in
  let has_file = List.exists (fun (_name, part) ->
    match part with
    | `File (_filename, _mime, _path) -> true
    | _ -> false
  ) parts in
  Alcotest.(check bool) "has file part" true has_file;
  (match List.assoc "photo" parts with
   | `File (filename, mime, path) ->
       Alcotest.(check string) "filename" "photo.jpg" filename;
       Alcotest.(check (option string)) "mime" (Some "image/jpeg") mime;
       Alcotest.(check string) "path" "/tmp/photo.jpg" path
   | _ -> Alcotest.fail "photo should be file")

let test_to_multipart_list () =
  let params = [
    ("ids", Param.list [Param.int 1; Param.int 2; Param.int 3])
  ] in
  let parts = Param.to_multipart params in
  (match List.assoc "ids" parts with
   | `String json_str ->
       let json = Yojson.Safe.from_string json_str in
       let open Yojson.Safe.Util in
       let ids = json |> to_list |> List.map to_int in
       Alcotest.(check (list int)) "list as json" [1; 2; 3] ids
   | _ -> Alcotest.fail "list should be json string")

let test_opt_some () =
  let param_opt = Param.opt "caption" (Some "Hello") Param.string in
  match param_opt with
  | Some ("caption", _) -> ()
  | _ -> Alcotest.fail "Should return Some param"

let test_opt_none () =
  let param_opt = Param.opt "caption" None Param.string in
  match param_opt with
  | None -> ()
  | _ -> Alcotest.fail "Should return None"

let () =
  let open Alcotest in
  run "Param" [
    "to_json", [
      test_case "simple types" `Quick test_to_json_simple;
      test_case "int64" `Quick test_to_json_int64;
      test_case "float" `Quick test_to_json_float;
      test_case "list" `Quick test_to_json_list;
      test_case "file_id" `Quick test_to_json_file_id;
      test_case "url" `Quick test_to_json_url;
      test_case "upload" `Quick test_to_json_upload;
    ];
    "has_files", [
      test_case "no files" `Quick test_has_files_no_files;
      test_case "file_id" `Quick test_has_files_file_id;
      test_case "url" `Quick test_has_files_url;
      test_case "upload" `Quick test_has_files_upload;
      test_case "mixed" `Quick test_has_files_mixed;
      test_case "in list" `Quick test_has_files_in_list;
    ];
    "to_multipart", [
      test_case "simple types" `Quick test_to_multipart_simple;
      test_case "file" `Quick test_to_multipart_file;
      test_case "list" `Quick test_to_multipart_list;
    ];
    "opt", [
      test_case "some" `Quick test_opt_some;
      test_case "none" `Quick test_opt_none;
    ];
  ]
