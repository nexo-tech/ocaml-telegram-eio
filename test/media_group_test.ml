(* Tests for Media_group module *)

open Telegram

let test_photo_item () =
  let file = Input_file.path "/tmp/photo.jpg" in
  let item = Media_group.photo ~caption:"Test" ~has_spoiler:true file in
  match item with
  | Media_group.Photo (f, opts) ->
      Alcotest.(check bool) "same file" true (f = file);
      Alcotest.(check (option string)) "caption" (Some "Test") opts.caption;
      Alcotest.(check bool) "has_spoiler" true opts.has_spoiler
  | _ -> Alcotest.fail "Expected Photo item"

let test_video_item () =
  let file = Input_file.path "/tmp/video.mp4" in
  let item = Media_group.video
    ~caption:"Video"
    ~width:1920
    ~height:1080
    ~duration:60
    ~supports_streaming:true
    file in
  match item with
  | Media_group.Video (f, opts) ->
      Alcotest.(check bool) "same file" true (f = file);
      Alcotest.(check (option string)) "caption" (Some "Video") opts.caption;
      Alcotest.(check (option int)) "width" (Some 1920) opts.width;
      Alcotest.(check (option int)) "height" (Some 1080) opts.height;
      Alcotest.(check (option int)) "duration" (Some 60) opts.duration;
      Alcotest.(check bool) "supports_streaming" true opts.supports_streaming
  | _ -> Alcotest.fail "Expected Video item"

let test_create_builder () =
  let photo1 = Media_group.photo (Input_file.path "photo1.jpg") in
  let photo2 = Media_group.photo (Input_file.path "photo2.jpg") in
  let builder = Media_group.create photo1 photo2 in
  let group = Media_group.build builder in
  Alcotest.(check int) "size is 2" 2 (Media_group.size group)

let test_add_items () =
  let photo1 = Media_group.photo (Input_file.path "photo1.jpg") in
  let photo2 = Media_group.photo (Input_file.path "photo2.jpg") in
  let photo3 = Media_group.photo (Input_file.path "photo3.jpg") in
  let photo4 = Media_group.photo (Input_file.path "photo4.jpg") in

  let group = Media_group.create photo1 photo2
    |> Media_group.add photo3
    |> Media_group.add photo4
    |> Media_group.build in

  Alcotest.(check int) "size is 4" 4 (Media_group.size group)

let test_max_items () =
  let photos = List.init 12 (fun i ->
    Media_group.photo (Input_file.path (Printf.sprintf "photo%d.jpg" i))
  ) in

  let photo1, photo2, rest = match photos with
    | a :: b :: rest -> (a, b, rest)
    | _ -> assert false
  in

  let builder = Media_group.create photo1 photo2 in
  let builder = List.fold_left (fun b item -> Media_group.add item b) builder rest in
  let group = Media_group.build builder in

  (* Should silently cap at 10 items *)
  Alcotest.(check int) "capped at 10" 10 (Media_group.size group)

let test_try_add_success () =
  let photo1 = Media_group.photo (Input_file.path "photo1.jpg") in
  let photo2 = Media_group.photo (Input_file.path "photo2.jpg") in
  let photo3 = Media_group.photo (Input_file.path "photo3.jpg") in

  let builder = Media_group.create photo1 photo2 in
  match Media_group.try_add photo3 builder with
  | Ok b ->
      let group = Media_group.build b in
      Alcotest.(check int) "size is 3" 3 (Media_group.size group)
  | Error _ -> Alcotest.fail "Should succeed"

let test_try_add_failure () =
  let photos = List.init 11 (fun i ->
    Media_group.photo (Input_file.path (Printf.sprintf "photo%d.jpg" i))
  ) in

  let photo1, photo2, rest = match photos with
    | a :: b :: rest -> (a, b, rest)
    | _ -> assert false
  in

  let builder = Media_group.create photo1 photo2 in
  let builder = List.fold_left (fun b item ->
    match Media_group.try_add item b with
    | Ok b -> b
    | Error _ -> b
  ) builder rest in

  let photo_extra = Media_group.photo (Input_file.path "extra.jpg") in
  match Media_group.try_add photo_extra builder with
  | Ok _ -> Alcotest.fail "Should fail when at max"
  | Error _ -> ()

let test_of_list_success () =
  let items = [
    Media_group.photo (Input_file.path "photo1.jpg");
    Media_group.photo (Input_file.path "photo2.jpg");
    Media_group.photo (Input_file.path "photo3.jpg");
  ] in

  match Media_group.of_list items with
  | Ok group -> Alcotest.(check int) "size is 3" 3 (Media_group.size group)
  | Error _ -> Alcotest.fail "Should succeed"

let test_of_list_too_few () =
  let items = [Media_group.photo (Input_file.path "photo1.jpg")] in

  match Media_group.of_list items with
  | Ok _ -> Alcotest.fail "Should fail with < 2 items"
  | Error msg ->
      Alcotest.(check bool) "error mentions minimum"
        true (String.length msg > 0)

let test_of_list_too_many () =
  let items = List.init 11 (fun i ->
    Media_group.photo (Input_file.path (Printf.sprintf "photo%d.jpg" i))
  ) in

  match Media_group.of_list items with
  | Ok _ -> Alcotest.fail "Should fail with > 10 items"
  | Error msg ->
      Alcotest.(check bool) "error mentions maximum"
        true (String.length msg > 0)

let test_to_list () =
  let photo1 = Media_group.photo (Input_file.path "photo1.jpg") in
  let photo2 = Media_group.photo (Input_file.path "photo2.jpg") in
  let group = Media_group.create photo1 photo2 |> Media_group.build in
  let items = Media_group.to_list group in
  Alcotest.(check int) "list has 2 items" 2 (List.length items)

let test_mixed_media () =
  let photo = Media_group.photo ~caption:"A photo" (Input_file.path "photo.jpg") in
  let video = Media_group.video ~caption:"A video" (Input_file.path "video.mp4") in

  let group = Media_group.create photo video |> Media_group.build in
  Alcotest.(check int) "size is 2" 2 (Media_group.size group);

  let items = Media_group.items group in
  match items with
  | [Media_group.Photo _; Media_group.Video _] -> ()
  | [Media_group.Video _; Media_group.Photo _] -> ()
  | _ -> Alcotest.fail "Expected one photo and one video"

let test_to_yojson () =
  let photo = Media_group.photo ~caption:"Test" (Input_file.file_id "file123") in
  let video = Media_group.video (Input_file.url "https://example.com/video.mp4") in

  let group = Media_group.create photo video |> Media_group.build in
  let json = Media_group.to_yojson group in

  match json with
  | `List items ->
      Alcotest.(check int) "2 items in JSON" 2 (List.length items)
  | _ -> Alcotest.fail "Expected JSON array"

let test_input_file_conversion () =
  (* Test file_id *)
  let photo1 = Media_group.photo (Input_file.file_id "ABC123") in
  (* Test URL *)
  let photo2 = Media_group.photo (Input_file.url "https://example.com/photo.jpg") in
  (* Test path *)
  let photo3 = Media_group.photo (Input_file.path "/tmp/local.jpg") in

  let group = Media_group.create photo1 photo2
    |> Media_group.add photo3
    |> Media_group.build in

  let json = Media_group.to_yojson group in
  match json with
  | `List _ -> ()
  | _ -> Alcotest.fail "Expected JSON array"

let () =
  let open Alcotest in
  run "Media_group" [
    "items", [
      test_case "photo item" `Quick test_photo_item;
      test_case "video item" `Quick test_video_item;
    ];
    "builder", [
      test_case "create builder" `Quick test_create_builder;
      test_case "add items" `Quick test_add_items;
      test_case "max items capping" `Quick test_max_items;
      test_case "try_add success" `Quick test_try_add_success;
      test_case "try_add failure" `Quick test_try_add_failure;
    ];
    "from_list", [
      test_case "of_list success" `Quick test_of_list_success;
      test_case "of_list too few" `Quick test_of_list_too_few;
      test_case "of_list too many" `Quick test_of_list_too_many;
      test_case "to_list" `Quick test_to_list;
    ];
    "mixed", [
      test_case "mixed photo and video" `Quick test_mixed_media;
    ];
    "serialization", [
      test_case "to_yojson" `Quick test_to_yojson;
      test_case "input_file conversion" `Quick test_input_file_conversion;
    ];
  ]
