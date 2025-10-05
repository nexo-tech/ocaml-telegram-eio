(* Tests for Download module *)

open Tg

let test_download_url_builder () =
  (* Create a mock client *)
  let env = Eio_main.run (fun env -> env) in
  let client = Telegram.Client.create ~env ~token:"123456:ABC-DEF" () in

  (* Test download URL building *)
  let url = Download.download_url client ~file_path:"photos/file_0.jpg" in
  let expected = "https://api.telegram.org/file/bot123456:ABC-DEF/photos/file_0.jpg" in
  Alcotest.(check string) "download URL" expected url

let test_download_url_from_info_some () =
  let env = Eio_main.run (fun env -> env) in
  let client = Telegram.Client.create ~env ~token:"test_token" () in

  let info = Download.{
    file_id = "file_123";
    file_unique_id = "unique_123";
    file_size = Some 1024L;
    file_path = Some "documents/doc.pdf";
  } in

  match Download.download_url_from_info client info with
  | Some url ->
      let expected = "https://api.telegram.org/file/bottest_token/documents/doc.pdf" in
      Alcotest.(check string) "URL from info" expected url
  | None ->
      Alcotest.fail "Expected Some URL, got None"

let test_download_url_from_info_none () =
  let env = Eio_main.run (fun env -> env) in
  let client = Telegram.Client.create ~env ~token:"test_token" () in

  let info = Download.{
    file_id = "file_123";
    file_unique_id = "unique_123";
    file_size = Some 1024L;
    file_path = None;  (* No file_path *)
  } in

  match Download.download_url_from_info client info with
  | None -> Alcotest.(check bool) "No URL when no file_path" true true
  | Some _ -> Alcotest.fail "Expected None, got Some URL"

let test_file_info_type () =
  (* Test that file_info type compiles correctly *)
  let info = Download.{
    file_id = "test_id";
    file_unique_id = "unique_id";
    file_size = Some 2048L;
    file_path = Some "path/to/file.txt";
  } in
  Alcotest.(check string) "file_id" "test_id" info.file_id;
  Alcotest.(check string) "file_unique_id" "unique_id" info.file_unique_id;
  Alcotest.(check (option int64)) "file_size" (Some 2048L) info.file_size;
  Alcotest.(check (option string)) "file_path" (Some "path/to/file.txt") info.file_path

let () =
  let open Alcotest in
  run "Download" [
    "url_building", [
      test_case "download URL builder" `Quick test_download_url_builder;
      test_case "URL from info with file_path" `Quick test_download_url_from_info_some;
      test_case "URL from info without file_path" `Quick test_download_url_from_info_none;
    ];
    "types", [
      test_case "file_info type" `Quick test_file_info_type;
    ];
  ]
