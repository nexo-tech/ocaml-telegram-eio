(** Update Processing Demo - Comprehensive demonstration of update handling

    This example demonstrates update processing patterns:
    - Different update types (message, edited_message, callback_query)
    - Event-based routing with matchers
    - Multiple handlers for the same update
    - Middleware for cross-cutting concerns
    - Error handling in update processing
    - Update filtering and prioritization

    Commands:
      /start - Show bot information
      /update_types - Explain different update types
      /edit_test - Send a message you can edit
      /stats - Show update statistics

    Update Handlers:
      - on_message: Logs all messages
      - on_text: Handles text messages
      - on_callback: Handles button presses
      - on_message (edited): Handles edited messages

    This example has VERBOSE LOGGING enabled for troubleshooting.

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/update_processing_demo.exe

    Try:
    - Send a message (triggers on_message and on_text)
    - Edit a message (triggers edited_message handler)
    - Press buttons (triggers on_callback)
*)

open Telegram
open Tg

(* Configure verbose logging via functor composition *)
module Verbose_log = Log.Make (Log.Console) (struct
  let src = "UpdateDemo"
  let level = Log.Debug
end)

module Verbose_session = Session.Make (Verbose_log)
module Verbose_polling = Polling.Make (Verbose_log)
module Verbose_bot = Bot.Make (Verbose_log) (Verbose_session) (Verbose_polling)

module KB = Keyboard

(** Update statistics tracking *)
module Stats = struct
  let messages = ref 0
  let edits = ref 0
  let callbacks = ref 0
  let inline_queries = ref 0

  let increment_messages () = incr messages
  let increment_edits () = incr edits
  let increment_callbacks () = incr callbacks

  let summary () =
    Printf.sprintf
      "📊 Update Statistics\n\n\
       Messages: %d\n\
       Edits: %d\n\
       Callbacks: %d\n\
       Inline Queries: %d\n\n\
       Total: %d updates processed"
      !messages
      !edits
      !callbacks
      !inline_queries
      (!messages + !edits + !callbacks + !inline_queries)

  let reset () =
    messages := 0;
    edits := 0;
    callbacks := 0;
    inline_queries := 0
end

let () =
  Printexc.record_backtrace true;
  Eio.traceln "=== Update Processing Demo Starting ===";

  let token = match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None -> Printf.eprintf "TELEGRAM_BOT_TOKEN not set\n"; exit 1
  in

  Eio_main.run @@ fun env ->
  let client = Client.create ~env ~token () in

  Eio.traceln "🤖 Update Processing Demo Bot Started";

  let session_store = Verbose_session.Memory_store.create () in

  Verbose_bot.make ~env ~client
  |> Verbose_bot.with_sessions (module Verbose_session.Memory_store) session_store

  (* /start - Show bot information *)
  |> Verbose_bot.command "start" ~desc:"Show bot information" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/start] Showing information";

      Stats.increment_messages ();

      let text =
        "🔄 Update Processing Demo\n\n\
         This bot demonstrates how updates are processed and routed.\n\n\
         📝 Try these:\n\
         • Send a message - See message update processing\n\
         • Edit a message - See edited_message update\n\
         • Press buttons below - See callback_query update\n\
         • /stats - View update statistics\n\
         • /update_types - Learn about update types"
      in

      let keyboard = KB.inline [
        [KB.callback ~text:"🔘 Press Me" ~data:"test:button"];
        [KB.callback ~text:"📊 Stats" ~data:"show:stats"];
      ] in

      match send ~keyboard ctx text with
      | Ok _ -> Eio.traceln "[/start] ✓"; Ok ()
      | Error e -> Eio.traceln "[/start] ✗ %a" Error.pp e; Ok ()
    )

  (* /update_types - Explain update types *)
  |> Verbose_bot.command "update_types" ~desc:"Explain update types" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/update_types] Explaining update types";

      Stats.increment_messages ();

      let text =
        "📋 Telegram Update Types\n\n\
         <b>Message Updates:</b>\n\
         • message - New message\n\
         • edited_message - Message was edited\n\
         • channel_post - New channel post\n\
         • edited_channel_post - Channel post edited\n\n\
         <b>Interactive Updates:</b>\n\
         • callback_query - Button pressed\n\
         • inline_query - Inline mode query\n\
         • chosen_inline_result - Inline result chosen\n\n\
         <b>Group Management:</b>\n\
         • my_chat_member - Bot status changed\n\
         • chat_member - Member status changed\n\
         • chat_join_request - Join request\n\n\
         <b>Payments:</b>\n\
         • pre_checkout_query - Before checkout\n\
         • shipping_query - Shipping info\n\n\
         Each update contains exactly ONE of these types."
      in

      match reply ctx text with
      | Ok _ -> Eio.traceln "[/update_types] ✓"; Ok ()
      | Error e -> Eio.traceln "[/update_types] ✗ %a" Error.pp e; Ok ()
    )

  (* /edit_test - Send editable message *)
  |> Verbose_bot.command "edit_test" ~desc:"Send message you can edit" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/edit_test] Sending editable message";

      Stats.increment_messages ();

      let text =
        "✏️ Edit This Message\n\n\
         Try editing this message in Telegram.\n\
         I'll detect the edit and log it!\n\n\
         (Long-press the message → Edit)"
      in

      match reply ctx text with
      | Ok _ -> Eio.traceln "[/edit_test] ✓"; Ok ()
      | Error e -> Eio.traceln "[/edit_test] ✗ %a" Error.pp e; Ok ()
    )

  (* /stats - Show update statistics *)
  |> Verbose_bot.command "stats" ~desc:"Show update statistics" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/stats] Showing statistics";

      Stats.increment_messages ();

      let text = Stats.summary () in

      let keyboard = KB.inline [
        [KB.callback ~text:"🔄 Reset Stats" ~data:"reset:stats"];
        [KB.callback ~text:"📊 Refresh" ~data:"show:stats"];
      ] in

      match send ~keyboard ctx text with
      | Ok _ -> Eio.traceln "[/stats] ✓"; Ok ()
      | Error e -> Eio.traceln "[/stats] ✗ %a" Error.pp e; Ok ()
    )

  (* Handle ALL messages for logging/stats *)
  |> Verbose_bot.on_message (fun _ctx msg ->
      let open Telegram_generated.Gen_types.Message in

      (* Increment stats for non-command messages *)
      let is_command = match msg.text with
        | Some text when String.length text > 0 && text.[0] = '/' -> true
        | _ -> false
      in

      if not is_command then (
        Stats.increment_messages ();
        Eio.traceln "[on_message] Update type: message, message_id=%Ld" msg.message_id
      );

      Ok ()
    )

  (* Handle edited messages *)
  |> Verbose_bot.on (Verbose_bot.Event.when_ Verbose_bot.Event.any (fun upd ->
      let open Telegram_generated.Gen_types.Update in
      upd.edited_message <> None
    )) (fun ctx upd ->
      let open Verbose_bot.Ctx in
      let open Telegram_generated.Gen_types.Update in

      match upd.edited_message with
      | Some msg ->
          Stats.increment_edits ();

          let open Telegram_generated.Gen_types.Message in
          Eio.traceln "[edited_message] Update type: edited_message, message_id=%Ld" msg.message_id;

          let text = match msg.text with
            | Some t -> t
            | None -> "<no text>"
          in

          let response = Printf.sprintf
            "✏️ <b>Message Edited!</b>\n\n\
             Message ID: %Ld\n\
             New text: %s\n\n\
             I detected your edit via the edited_message update type."
            msg.message_id
            text
          in

          (match reply ctx response with
           | Ok _ -> Eio.traceln "[edited_message] ✓"; Ok ()
           | Error e -> Eio.traceln "[edited_message] ✗ %a" Error.pp e; Ok ())

      | None -> Ok ()
    )

  (* Callback: test:button *)
  |> Verbose_bot.on_callback_data "test:button" (fun ctx ->
      let open Verbose_bot.Ctx in

      Stats.increment_callbacks ();

      Eio.traceln "[test:button] Button pressed";

      match edit ctx "✅ Button pressed!\n\nThis was a callback_query update." with
      | Ok () -> Eio.traceln "[test:button] ✓"; Ok ()
      | Error e -> Eio.traceln "[test:button] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: show:stats *)
  |> Verbose_bot.on_callback_data "show:stats" (fun ctx ->
      let open Verbose_bot.Ctx in

      Stats.increment_callbacks ();

      Eio.traceln "[show:stats] Refreshing statistics";

      let text = Stats.summary () in

      let keyboard = KB.inline [
        [KB.callback ~text:"🔄 Reset Stats" ~data:"reset:stats"];
        [KB.callback ~text:"📊 Refresh" ~data:"show:stats"];
      ] in

      match edit ~keyboard ctx text with
      | Ok () -> Eio.traceln "[show:stats] ✓"; Ok ()
      | Error e -> Eio.traceln "[show:stats] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: reset:stats *)
  |> Verbose_bot.on_callback_data "reset:stats" (fun ctx ->
      let open Verbose_bot.Ctx in

      Eio.traceln "[reset:stats] Resetting statistics";

      Stats.reset ();

      let keyboard = KB.inline [
        [KB.callback ~text:"📊 View Stats" ~data:"show:stats"];
      ] in

      match edit ~keyboard ctx "🔄 Statistics reset!\n\nAll counters set to zero." with
      | Ok () -> Eio.traceln "[reset:stats] ✓"; Ok ()
      | Error e -> Eio.traceln "[reset:stats] ✗ %a" Error.pp e; Ok ()
    )

  (* Log all callbacks for demonstration *)
  |> Verbose_bot.on_callback (fun _ctx data ->
      Eio.traceln "[on_callback] Received callback_query with data: %s" data;
      Ok ()
    )

  |> Verbose_bot.run
