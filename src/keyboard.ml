open Telegram.Types

(* Inline keyboard buttons *)
type inline = inline_keyboard_button

(* Inline keyboard markup *)
let inline rows : inline_keyboard_markup = rows

(* Inline button constructors *)
let url ~text ~url = Url_button { text; url }
let callback ~text ~data = Callback_button { text; data }

(* Reply keyboard - using generated types directly *)
type reply_button = string  (* Simple text buttons for reply keyboards *)
type reply_keyboard = reply_button list list

(* Helper to build reply keyboard markup JSON *)
let reply ?(resize = true) ?(one_time = false) ?(selective = false) keyboard =
  let buttons_json =
    `List (List.map (fun row ->
      `List (List.map (fun text ->
        `Assoc [("text", `String text)]
      ) row)
    ) keyboard)
  in
  `Assoc [
    ("keyboard", buttons_json);
    ("resize_keyboard", `Bool resize);
    ("one_time_keyboard", `Bool one_time);
    ("selective", `Bool selective);
  ]

(* Remove keyboard *)
let remove ?(selective = false) () =
  `Assoc [
    ("remove_keyboard", `Bool true);
    ("selective", `Bool selective);
  ]

(* Force reply *)
let force_reply ?(selective = false) () =
  `Assoc [
    ("force_reply", `Bool true);
    ("selective", `Bool selective);
  ]

(* Row/grid layout helpers *)
module Layout = struct
  (* Create a single row *)
  let row buttons = [buttons]

  (* Create multiple rows *)
  let rows button_lists = button_lists

  (* Create a grid with n columns *)
  let grid ~columns buttons =
    let rec chunk n lst =
      match lst with
      | [] -> []
      | _ ->
          let take = List.filteri (fun i _ -> i < n) lst in
          let rest = List.filteri (fun i _ -> i >= n) lst in
          take :: chunk n rest
    in
    chunk columns buttons

  (* Vertical layout (one button per row) *)
  let vertical buttons = List.map (fun b -> [b]) buttons

  (* Horizontal layout (all buttons in one row) *)
  let horizontal buttons = [buttons]
end

(* Common keyboard patterns *)
module Patterns = struct
  (* Yes/No inline keyboard *)
  let yes_no ?(yes_text = "Yes") ?(no_text = "No") ~yes_data ~no_data () =
    inline [
      [callback ~text:yes_text ~data:yes_data; callback ~text:no_text ~data:no_data]
    ]

  (* Confirmation keyboard *)
  let confirm ?(confirm_text = "✓ Confirm") ?(cancel_text = "✗ Cancel") ~confirm_data ~cancel_data () =
    inline [
      [callback ~text:confirm_text ~data:confirm_data];
      [callback ~text:cancel_text ~data:cancel_data];
    ]

  (* Pagination keyboard *)
  let pagination ?(prev_text = "◀ Previous") ?(next_text = "Next ▶") ~prev_data ~next_data ~current_page ~total_pages () =
    let buttons = match current_page, total_pages with
      | 1, n when n <= 1 -> []  (* No pagination needed *)
      | 1, _ -> [callback ~text:next_text ~data:next_data]  (* First page *)
      | n, total when n >= total -> [callback ~text:prev_text ~data:prev_data]  (* Last page *)
      | _ -> [callback ~text:prev_text ~data:prev_data; callback ~text:next_text ~data:next_data]  (* Middle *)
    in
    inline [buttons]

  (* Number grid (like phone dialer) *)
  let number_grid ~callback_prefix () =
    inline [
      [callback ~text:"1" ~data:(callback_prefix ^ "1");
       callback ~text:"2" ~data:(callback_prefix ^ "2");
       callback ~text:"3" ~data:(callback_prefix ^ "3")];
      [callback ~text:"4" ~data:(callback_prefix ^ "4");
       callback ~text:"5" ~data:(callback_prefix ^ "5");
       callback ~text:"6" ~data:(callback_prefix ^ "6")];
      [callback ~text:"7" ~data:(callback_prefix ^ "7");
       callback ~text:"8" ~data:(callback_prefix ^ "8");
       callback ~text:"9" ~data:(callback_prefix ^ "9")];
      [callback ~text:"0" ~data:(callback_prefix ^ "0")];
    ]

  (* Menu with back button *)
  let menu_with_back ~back_text ~back_data items =
    let item_rows = List.map (fun item -> [item]) items in
    let back_row = [callback ~text:back_text ~data:back_data] in
    inline (item_rows @ [back_row])
end
