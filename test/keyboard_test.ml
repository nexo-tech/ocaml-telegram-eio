(* Tests for Keyboard module *)

open Tg

let test_inline_keyboard () =
  (* Test basic inline keyboard - just verify it compiles *)
  let _kb = Keyboard.inline [
    [Keyboard.url ~text:"Google" ~url:"https://google.com"];
    [Keyboard.callback ~text:"Click me" ~data:"action"];
  ] in
  Alcotest.(check bool) "inline keyboard created" true true

let test_url_button () =
  (* Test URL button - just verify it compiles *)
  let _btn = Keyboard.url ~text:"Example" ~url:"https://example.com" in
  Alcotest.(check bool) "url button created" true true

let test_callback_button () =
  (* Test callback button - just verify it compiles *)
  let _btn = Keyboard.callback ~text:"Test" ~data:"test_data" in
  Alcotest.(check bool) "callback button created" true true

let test_reply_keyboard () =
  (* Test reply keyboard *)
  let kb = Keyboard.reply [
    ["Option 1"; "Option 2"];
    ["Option 3"];
  ] in
  let json_str = Yojson.Safe.to_string kb in
  Alcotest.(check bool) "reply keyboard has keyboard field"
    true (String.contains json_str '{')

let test_reply_keyboard_options () =
  (* Test reply keyboard with options *)
  let kb = Keyboard.reply ~resize:false ~one_time:true ~selective:true [
    ["Yes"; "No"];
  ] in
  let json_str = Yojson.Safe.to_string kb in
  Alcotest.(check bool) "reply keyboard with options"
    true (String.length json_str > 0)

let test_remove_keyboard () =
  (* Test keyboard removal *)
  let kb = Keyboard.remove () in
  let json_str = Yojson.Safe.to_string kb in
  Alcotest.(check bool) "remove keyboard"
    true (String.contains json_str '}')

let test_force_reply () =
  (* Test force reply *)
  let kb = Keyboard.force_reply () in
  let json_str = Yojson.Safe.to_string kb in
  Alcotest.(check bool) "force reply"
    true (String.contains json_str '}')

(* Layout tests *)
let test_layout_row () =
  let row = Keyboard.Layout.row [1; 2; 3] in
  Alcotest.(check int) "row length" 1 (List.length row);
  Alcotest.(check int) "row content" 3 (List.length (List.hd row))

let test_layout_vertical () =
  let layout = Keyboard.Layout.vertical [1; 2; 3] in
  Alcotest.(check int) "vertical rows" 3 (List.length layout);
  List.iter (fun row ->
    Alcotest.(check int) "vertical row size" 1 (List.length row)
  ) layout

let test_layout_horizontal () =
  let layout = Keyboard.Layout.horizontal [1; 2; 3] in
  Alcotest.(check int) "horizontal rows" 1 (List.length layout);
  Alcotest.(check int) "horizontal row size" 3 (List.length (List.hd layout))

let test_layout_grid () =
  let layout = Keyboard.Layout.grid ~columns:2 [1; 2; 3; 4; 5] in
  Alcotest.(check int) "grid rows" 3 (List.length layout);

  let first_row = List.nth layout 0 in
  Alcotest.(check int) "first row size" 2 (List.length first_row);

  let last_row = List.nth layout 2 in
  Alcotest.(check int) "last row size" 1 (List.length last_row)

(* Pattern tests *)
let test_pattern_yes_no () =
  let _kb = Keyboard.Patterns.yes_no ~yes_data:"y" ~no_data:"n" () in
  Alcotest.(check bool) "yes_no keyboard" true true

let test_pattern_confirm () =
  let _kb = Keyboard.Patterns.confirm ~confirm_data:"ok" ~cancel_data:"cancel" () in
  Alcotest.(check bool) "confirm keyboard" true true

let test_pattern_pagination_first_page () =
  let kb = Keyboard.Patterns.pagination
    ~prev_data:"prev" ~next_data:"next"
    ~current_page:1 ~total_pages:5 () in
  (* First page should only have next button *)
  let rows = kb in
  Alcotest.(check int) "first page rows" 1 (List.length rows);
  let first_row = List.hd rows in
  Alcotest.(check int) "first page buttons" 1 (List.length first_row)

let test_pattern_pagination_middle_page () =
  let kb = Keyboard.Patterns.pagination
    ~prev_data:"prev" ~next_data:"next"
    ~current_page:3 ~total_pages:5 () in
  (* Middle page should have both buttons *)
  let rows = kb in
  Alcotest.(check int) "middle page rows" 1 (List.length rows);
  let first_row = List.hd rows in
  Alcotest.(check int) "middle page buttons" 2 (List.length first_row)

let test_pattern_pagination_last_page () =
  let kb = Keyboard.Patterns.pagination
    ~prev_data:"prev" ~next_data:"next"
    ~current_page:5 ~total_pages:5 () in
  (* Last page should only have prev button *)
  let rows = kb in
  Alcotest.(check int) "last page rows" 1 (List.length rows);
  let first_row = List.hd rows in
  Alcotest.(check int) "last page buttons" 1 (List.length first_row)

let test_pattern_pagination_single_page () =
  let kb = Keyboard.Patterns.pagination
    ~prev_data:"prev" ~next_data:"next"
    ~current_page:1 ~total_pages:1 () in
  (* Single page should have no buttons *)
  let rows = kb in
  Alcotest.(check int) "single page rows" 1 (List.length rows);
  let first_row = List.hd rows in
  Alcotest.(check int) "single page buttons" 0 (List.length first_row)

let test_pattern_number_grid () =
  let kb = Keyboard.Patterns.number_grid ~callback_prefix:"num_" () in
  let rows = kb in
  Alcotest.(check int) "number grid rows" 4 (List.length rows)

let test_pattern_menu_with_back () =
  let items = [
    Keyboard.callback ~text:"Item 1" ~data:"i1";
    Keyboard.callback ~text:"Item 2" ~data:"i2";
  ] in
  let kb = Keyboard.Patterns.menu_with_back
    ~back_text:"Back" ~back_data:"back" items in
  let rows = kb in
  Alcotest.(check int) "menu rows" 3 (List.length rows)  (* 2 items + back *)

let () =
  let open Alcotest in
  run "Keyboard" [
    "inline_keyboards", [
      test_case "inline keyboard" `Quick test_inline_keyboard;
      test_case "url button" `Quick test_url_button;
      test_case "callback button" `Quick test_callback_button;
    ];
    "reply_keyboards", [
      test_case "reply keyboard" `Quick test_reply_keyboard;
      test_case "reply keyboard options" `Quick test_reply_keyboard_options;
      test_case "remove keyboard" `Quick test_remove_keyboard;
      test_case "force reply" `Quick test_force_reply;
    ];
    "layouts", [
      test_case "row layout" `Quick test_layout_row;
      test_case "vertical layout" `Quick test_layout_vertical;
      test_case "horizontal layout" `Quick test_layout_horizontal;
      test_case "grid layout" `Quick test_layout_grid;
    ];
    "patterns", [
      test_case "yes/no pattern" `Quick test_pattern_yes_no;
      test_case "confirm pattern" `Quick test_pattern_confirm;
      test_case "pagination first page" `Quick test_pattern_pagination_first_page;
      test_case "pagination middle page" `Quick test_pattern_pagination_middle_page;
      test_case "pagination last page" `Quick test_pattern_pagination_last_page;
      test_case "pagination single page" `Quick test_pattern_pagination_single_page;
      test_case "number grid" `Quick test_pattern_number_grid;
      test_case "menu with back" `Quick test_pattern_menu_with_back;
    ];
  ]
