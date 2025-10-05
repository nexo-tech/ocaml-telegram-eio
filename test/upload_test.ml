(* Tests for Upload module *)

open Tg

let test_file_part () =
  (* Test file_part creation *)
  let (name, part) = Upload.file_part ~name:"photo" ~path:"/tmp/test.jpg" () in
  Alcotest.(check string) "field name" "photo" name;
  match part with
  | `File (filename, content_type, path) ->
      Alcotest.(check string) "filename" "test.jpg" filename;
      Alcotest.(check (option string)) "content_type" (Some "application/octet-stream") content_type;
      Alcotest.(check string) "path" "/tmp/test.jpg" path
  | _ -> Alcotest.fail "Expected `File part"

let test_file_part_custom () =
  (* Test file_part with custom filename and content type *)
  let (name, part) = Upload.file_part
    ~name:"document"
    ~filename:"custom.pdf"
    ~content_type:"application/pdf"
    ~path:"/tmp/doc.pdf" () in
  Alcotest.(check string) "field name" "document" name;
  match part with
  | `File (filename, content_type, path) ->
      Alcotest.(check string) "filename" "custom.pdf" filename;
      Alcotest.(check (option string)) "content_type" (Some "application/pdf") content_type;
      Alcotest.(check string) "path" "/tmp/doc.pdf" path
  | _ -> Alcotest.fail "Expected `File part"

let test_string_part () =
  (* Test string_part creation *)
  let (name, part) = Upload.string_part ~name:"caption" ~value:"My photo" in
  Alcotest.(check string) "field name" "caption" name;
  match part with
  | `String v ->
      Alcotest.(check string) "value" "My photo" v
  | _ -> Alcotest.fail "Expected `String part"

let test_progress_callback () =
  (* Test progress callback conversion *)
  let calls = ref [] in
  let on_progress p =
    calls := (p.Upload.bytes_sent, p.Upload.total_bytes, p.Upload.percent) :: !calls
  in
  let cb = Upload.progress_callback on_progress in

  (* Simulate progress with known total *)
  cb ~bytes_sent:50L ~total_bytes:(Some 100L);
  Alcotest.(check int) "one call" 1 (List.length !calls);
  let (sent, total, pct) = List.hd !calls in
  Alcotest.(check int64) "bytes_sent" 50L sent;
  Alcotest.(check (option int64)) "total_bytes" (Some 100L) total;
  Alcotest.(check (option (float 0.1))) "percent" (Some 50.0) pct;

  (* Simulate progress with unknown total *)
  cb ~bytes_sent:75L ~total_bytes:None;
  Alcotest.(check int) "two calls" 2 (List.length !calls);
  let (sent2, total2, pct2) = List.nth !calls 0 in
  Alcotest.(check int64) "bytes_sent" 75L sent2;
  Alcotest.(check (option int64)) "total_bytes" None total2;
  Alcotest.(check (option (float 0.1))) "percent" None pct2

let test_with_progress_no_callback () =
  (* Test with_progress without callback *)
  let parts = [
    Upload.string_part ~name:"chat_id" ~value:"123";
    Upload.file_part ~name:"photo" ~path:"/tmp/photo.jpg" ();
  ] in
  let body = Upload.with_progress parts in
  match body with
  | Telegram.Http.Multipart ps ->
      Alcotest.(check int) "parts count" 2 (List.length ps)
  | _ -> Alcotest.fail "Expected Multipart body"

let test_with_progress_with_callback () =
  (* Test with_progress with callback *)
  let called = ref false in
  let on_progress _p = called := true in
  let parts = [
    Upload.string_part ~name:"chat_id" ~value:"123";
  ] in
  let body = Upload.with_progress ~on_progress parts in
  match body with
  | Telegram.Http.Multipart_progress (ps, _cb) ->
      Alcotest.(check int) "parts count" 1 (List.length ps)
  | _ -> Alcotest.fail "Expected Multipart_progress body"

let test_progress_type () =
  (* Test progress record type *)
  let p = Upload.{
    bytes_sent = 1024L;
    total_bytes = Some 2048L;
    percent = Some 50.0;
  } in
  Alcotest.(check int64) "bytes_sent" 1024L p.Upload.bytes_sent;
  Alcotest.(check (option int64)) "total_bytes" (Some 2048L) p.Upload.total_bytes;
  Alcotest.(check (option (float 0.1))) "percent" (Some 50.0) p.Upload.percent

let () =
  let open Alcotest in
  run "Upload" [
    "parts", [
      test_case "file part" `Quick test_file_part;
      test_case "file part with custom fields" `Quick test_file_part_custom;
      test_case "string part" `Quick test_string_part;
    ];
    "progress", [
      test_case "progress callback" `Quick test_progress_callback;
      test_case "with_progress without callback" `Quick test_with_progress_no_callback;
      test_case "with_progress with callback" `Quick test_with_progress_with_callback;
      test_case "progress type" `Quick test_progress_type;
    ];
  ]
