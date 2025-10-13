(** Keyboard API Demo - Comprehensive demonstration of keyboard creation patterns

    This example demonstrates all keyboard creation features from the Keyboard API:
    - Inline keyboards with callback/URL buttons
    - Reply keyboards
    - Layout helpers (grid, vertical, horizontal)
    - Common patterns (yes/no, confirm, pagination, menu_with_back)

    Commands:
      /start - Main menu showing all keyboard patterns
      /inline_basic - Basic inline keyboard with callback buttons
      /inline_url - Inline keyboard with URL buttons
      /inline_mixed - Mixed callback and URL buttons
      /reply - Reply keyboard example
      /layouts - Layout helper demonstrations
      /patterns - Common keyboard patterns (yes/no, confirm, pagination)
      /menu - Menu with back button

    This example has VERBOSE LOGGING enabled for troubleshooting.

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/keyboard_api_demo.exe
*)

open Telegram
open Tg

(* Configure verbose logging via functor composition *)
module Verbose_log = Log.Make (Log.Console) (struct
  let src = "KeyboardDemo"
  let level = Log.Debug
end)

module Verbose_session = Session.Make (Verbose_log)
module Verbose_polling = Polling.Make (Verbose_log)
module Verbose_bot = Bot.Make (Verbose_log) (Verbose_session) (Verbose_polling)

(* Use the Keyboard module *)
module KB = Keyboard

let () =
  Printexc.record_backtrace true;
  Eio.traceln "=== Keyboard API Demo Starting ===";

  let token = match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None -> Printf.eprintf "TELEGRAM_BOT_TOKEN not set\n"; exit 1
  in

  Eio_main.run @@ fun env ->
  let client = Client.create ~env ~token () in

  Eio.traceln "🤖 Keyboard Demo Bot Started";

  let session_store = Verbose_session.Memory_store.create () in

  Verbose_bot.make ~env ~client
  |> Verbose_bot.with_sessions (module Verbose_session.Memory_store) session_store

  (* /start - Main menu *)
  |> Verbose_bot.command "start" ~desc:"Show main menu" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/start] Showing main menu";

      let keyboard = KB.inline [
        [KB.callback ~text:"📝 Basic Inline" ~data:"demo:inline_basic"];
        [KB.callback ~text:"🔗 URL Buttons" ~data:"demo:inline_url"];
        [KB.callback ~text:"🎯 Layout Helpers" ~data:"demo:layouts"];
        [KB.callback ~text:"⭐ Common Patterns" ~data:"demo:patterns"];
        [KB.callback ~text:"📱 Reply Keyboard" ~data:"demo:reply"];
      ] in

      match send ~keyboard ctx "🎹 Keyboard API Demo\n\nChoose a demonstration:" with
      | Ok _ -> Eio.traceln "[/start] ✓"; Ok ()
      | Error e -> Eio.traceln "[/start] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: demo:inline_basic *)
  |> Verbose_bot.on_callback_data "demo:inline_basic" (fun ctx ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[inline_basic] Demonstrating basic inline keyboard";

      (* Basic inline keyboard with callback buttons *)
      let keyboard = KB.inline [
        [KB.callback ~text:"Option A" ~data:"select:a"];
        [KB.callback ~text:"Option B" ~data:"select:b"];
        [KB.callback ~text:"Option C" ~data:"select:c"];
        [KB.callback ~text:"← Back to Menu" ~data:"demo:menu"];
      ] in

      match edit ~keyboard ctx
        "📝 Basic Inline Keyboard\n\n\
         This keyboard has simple callback buttons.\n\
         Each button sends a callback query when pressed."
      with
      | Ok () -> Eio.traceln "[inline_basic] ✓"; Ok ()
      | Error e -> Eio.traceln "[inline_basic] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: demo:inline_url *)
  |> Verbose_bot.on_callback_data "demo:inline_url" (fun ctx ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[inline_url] Demonstrating URL buttons";

      (* Inline keyboard with URL buttons *)
      let keyboard = KB.inline [
        [KB.url ~text:"📚 OCaml Manual" ~url:"https://ocaml.org/manual/"];
        [KB.url ~text:"🐫 OCaml.org" ~url:"https://ocaml.org"];
        [KB.callback ~text:"🔄 Mix with Callback" ~data:"select:mixed"];
        [KB.callback ~text:"← Back to Menu" ~data:"demo:menu"];
      ] in

      match edit ~keyboard ctx
        "🔗 URL Buttons\n\n\
         URL buttons open links in the browser.\n\
         You can mix callback and URL buttons."
      with
      | Ok () -> Eio.traceln "[inline_url] ✓"; Ok ()
      | Error e -> Eio.traceln "[inline_url] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: demo:layouts *)
  |> Verbose_bot.on_callback_data "demo:layouts" (fun ctx ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[layouts] Demonstrating layout helpers";

      (* Grid layout: 3 columns *)
      let grid_buttons = ["1"; "2"; "3"; "4"; "5"; "6"; "7"; "8"; "9"]
        |> List.map (fun n -> KB.callback ~text:n ~data:("num:" ^ n))
      in
      let grid_keyboard = KB.inline (
        KB.Layout.grid ~columns:3 grid_buttons @
        [[KB.callback ~text:"← Back" ~data:"demo:menu"]]
      ) in

      match edit ~keyboard:grid_keyboard ctx
        "🎯 Layout: Grid (3 columns)\n\n\
         Use KB.Layout.grid ~columns:3 to arrange buttons in a grid."
      with
      | Ok () -> Eio.traceln "[layouts] Grid shown ✓"; Ok ()
      | Error e -> Eio.traceln "[layouts] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: demo:patterns *)
  |> Verbose_bot.on_callback_data "demo:patterns" (fun ctx ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[patterns] Demonstrating common patterns";

      (* Yes/No pattern *)
      let keyboard = KB.Patterns.yes_no
        ~yes_data:"answer:yes"
        ~no_data:"answer:no"
        ()
      in

      match edit ~keyboard ctx
        "⭐ Common Pattern: Yes/No\n\n\
         Use KB.Patterns.yes_no for confirmation dialogs.\n\n\
         Do you want to see more patterns?"
      with
      | Ok () -> Eio.traceln "[patterns] Yes/No shown ✓"; Ok ()
      | Error e -> Eio.traceln "[patterns] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: answer:yes *)
  |> Verbose_bot.on_callback_data "answer:yes" (fun ctx ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[answer:yes] User chose yes, showing confirm pattern";

      (* Confirmation pattern *)
      let keyboard = KB.Patterns.confirm
        ~confirm_data:"confirmed"
        ~cancel_data:"cancelled"
        ()
      in

      match edit ~keyboard ctx
        "✅ Great! Here's another pattern: Confirm\n\n\
         KB.Patterns.confirm provides Confirm/Cancel buttons.\n\n\
         Are you ready to proceed?"
      with
      | Ok () -> Eio.traceln "[answer:yes] Confirm shown ✓"; Ok ()
      | Error e -> Eio.traceln "[answer:yes] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: answer:no *)
  |> Verbose_bot.on_callback_data "answer:no" (fun ctx ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[answer:no] User chose no, going back";

      let keyboard = KB.inline [[KB.callback ~text:"← Back to Menu" ~data:"demo:menu"]] in

      match edit ~keyboard ctx "❌ Okay, maybe next time!" with
      | Ok () -> Eio.traceln "[answer:no] ✓"; Ok ()
      | Error e -> Eio.traceln "[answer:no] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: confirmed *)
  |> Verbose_bot.on_callback_data "confirmed" (fun ctx ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[confirmed] User confirmed, showing pagination";

      (* Pagination pattern *)
      let keyboard = KB.Patterns.pagination
        ~prev_data:"page:1"
        ~next_data:"page:3"
        ~current_page:2
        ~total_pages:5
        ()
      in

      match edit ~keyboard ctx
        "📄 Pagination Pattern\n\n\
         KB.Patterns.pagination creates prev/next buttons.\n\
         Smart: hides buttons when not needed (e.g., no prev on page 1).\n\n\
         Current page: 2 of 5"
      with
      | Ok () -> Eio.traceln "[confirmed] Pagination shown ✓"; Ok ()
      | Error e -> Eio.traceln "[confirmed] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: cancelled *)
  |> Verbose_bot.on_callback_data "cancelled" (fun ctx ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[cancelled] User cancelled";

      let keyboard = KB.inline [[KB.callback ~text:"← Back to Menu" ~data:"demo:menu"]] in

      match edit ~keyboard ctx "🚫 Action cancelled" with
      | Ok () -> Eio.traceln "[cancelled] ✓"; Ok ()
      | Error e -> Eio.traceln "[cancelled] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: demo:reply *)
  |> Verbose_bot.on_callback_data "demo:reply" (fun ctx ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[reply] Demonstrating reply keyboard";

      (* Note: Reply keyboards are created with KB.reply, but we're just explaining here *)
      let inline_kb = KB.inline [[KB.callback ~text:"← Back to Menu" ~data:"demo:menu"]] in

      match edit ~keyboard:inline_kb ctx
        "📱 Reply Keyboard\n\n\
         Reply keyboards replace the user's system keyboard.\n\
         Created with KB.reply [[\"Button1\"; \"Button2\"]; ...]\n\n\
         Example:\n\
         let kb = KB.reply [\n\
         \  [\"Option 1\"; \"Option 2\"];\n\
         \  [\"Option 3\"; \"Option 4\"]\n\
         ] in\n\n\
         They send regular text messages when pressed.\n\
         Use KB.remove () to hide them."
      with
      | Ok () -> Eio.traceln "[reply] Explanation shown ✓"; Ok ()
      | Error e -> Eio.traceln "[reply] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: demo:menu - Back to main menu *)
  |> Verbose_bot.on_callback_data "demo:menu" (fun ctx ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[menu] Returning to main menu";

      let keyboard = KB.inline [
        [KB.callback ~text:"📝 Basic Inline" ~data:"demo:inline_basic"];
        [KB.callback ~text:"🔗 URL Buttons" ~data:"demo:inline_url"];
        [KB.callback ~text:"🎯 Layout Helpers" ~data:"demo:layouts"];
        [KB.callback ~text:"⭐ Common Patterns" ~data:"demo:patterns"];
        [KB.callback ~text:"📱 Reply Keyboard" ~data:"demo:reply"];
      ] in

      match edit ~keyboard ctx "🎹 Keyboard API Demo\n\nChoose a demonstration:" with
      | Ok () -> Eio.traceln "[menu] ✓"; Ok ()
      | Error e -> Eio.traceln "[menu] ✗ %a" Error.pp e; Ok ()
    )

  (* Handle number selections from grid *)
  |> Verbose_bot.on_callback (fun ctx data ->
      if String.starts_with ~prefix:"num:" data then (
        let open Verbose_bot.Ctx in
        let num = String.sub data 4 (String.length data - 4) in
        Eio.traceln "[num] User selected: %s" num;

        let keyboard = KB.inline [[KB.callback ~text:"← Back" ~data:"demo:layouts"]] in

        match edit ~keyboard ctx (Printf.sprintf "You selected: %s" num) with
        | Ok () -> Eio.traceln "[num] ✓"; Ok ()
        | Error e -> Eio.traceln "[num] ✗ %a" Error.pp e; Ok ()
      ) else Ok ()
    )

  (* Handle page navigation from pagination *)
  |> Verbose_bot.on_callback (fun ctx data ->
      if String.starts_with ~prefix:"page:" data then (
        let open Verbose_bot.Ctx in
        let page_str = String.sub data 5 (String.length data - 5) in
        let page = int_of_string page_str in
        Eio.traceln "[page] Navigating to page %d" page;

        let keyboard = KB.Patterns.pagination
          ~prev_data:(Printf.sprintf "page:%d" (page - 1))
          ~next_data:(Printf.sprintf "page:%d" (page + 1))
          ~current_page:page
          ~total_pages:5
          ()
        in

        match edit ~keyboard ctx (Printf.sprintf "📄 Current page: %d of 5" page) with
        | Ok () -> Eio.traceln "[page] ✓"; Ok ()
        | Error e -> Eio.traceln "[page] ✗ %a" Error.pp e; Ok ()
      ) else Ok ()
    )

  (* Handle generic selections *)
  |> Verbose_bot.on_callback (fun ctx data ->
      if String.starts_with ~prefix:"select:" data then (
        let open Verbose_bot.Ctx in
        let selection = String.sub data 7 (String.length data - 7) in
        Eio.traceln "[select] User selected: %s" selection;

        let keyboard = KB.inline [[KB.callback ~text:"← Back" ~data:"demo:menu"]] in

        match edit ~keyboard ctx (Printf.sprintf "✓ You selected: %s" selection) with
        | Ok () -> Eio.traceln "[select] ✓"; Ok ()
        | Error e -> Eio.traceln "[select] ✗ %a" Error.pp e; Ok ()
      ) else Ok ()
    )

  |> Verbose_bot.run
