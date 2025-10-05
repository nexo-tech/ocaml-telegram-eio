(* Tests for Album module *)

open Tg

let test_album_create () =
  let photo1 = Album.photo (Telegram.Input_file.path "photo1.jpg") in
  let photo2 = Album.photo (Telegram.Input_file.path "photo2.jpg") in
  let _album = Album.create photo1 photo2 |> Album.build in
  () (* just check it compiles *)

let test_album_builder_chain () =
  let _album = Album.create
    (Album.photo ~caption:"First" (Telegram.Input_file.path "photo1.jpg"))
    (Album.photo ~caption:"Second" (Telegram.Input_file.path "photo2.jpg"))
    |> Album.add (Album.photo (Telegram.Input_file.path "photo3.jpg"))
    |> Album.add (Album.video (Telegram.Input_file.path "video.mp4"))
    |> Album.build in
  () (* just check it compiles *)

let test_album_of_list () =
  let items = [
    Album.photo (Telegram.Input_file.path "photo1.jpg");
    Album.photo (Telegram.Input_file.path "photo2.jpg");
  ] in
  match Album.of_list items with
  | Ok _ -> ()
  | Error _ -> Alcotest.fail "Should succeed"

let test_album_of_list_validation () =
  (* Too few items *)
  let items = [Album.photo (Telegram.Input_file.path "photo1.jpg")] in
  match Album.of_list items with
  | Ok _ -> Alcotest.fail "Should fail with 1 item"
  | Error _ -> ()

let test_album_try_add () =
  let builder = Album.create
    (Album.photo (Telegram.Input_file.path "photo1.jpg"))
    (Album.photo (Telegram.Input_file.path "photo2.jpg")) in

  match Album.try_add (Album.photo (Telegram.Input_file.path "photo3.jpg")) builder with
  | Ok _ -> ()
  | Error _ -> Alcotest.fail "Should succeed"

let () =
  let open Alcotest in
  run "Album" [
    "builder", [
      test_case "create" `Quick test_album_create;
      test_case "builder chain" `Quick test_album_builder_chain;
      test_case "try_add" `Quick test_album_try_add;
    ];
    "validation", [
      test_case "of_list success" `Quick test_album_of_list;
      test_case "of_list validation" `Quick test_album_of_list_validation;
    ];
  ]
