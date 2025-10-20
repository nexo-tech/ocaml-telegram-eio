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

(* Configure verbose logging with flo *)
let () = Flo.set_level Severity.Debug

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
  Flo.info "=== Update Processing Demo Starting ===";

  let token = match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None -> Printf.eprintf "TELEGRAM_BOT_TOKEN not set\n"; exit 1
  in

  Eio_main.run @@ fun env ->
  let client = Client.create ~env ~token () in

  Flo.info "🤖 Update Processing Demo Bot Started";

  let session_store = Session.Memory_store.create () in

  Bot.make ~env ~client
  |> Bot.with_sessions (module Session.Memory_store) session_store

  (* /start - Show bot information *)
  |> Bot.command "start" ~desc:"Show bot information" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/start] Showing information";

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
      | Ok _ -> Flo.debug "[/start] ✓"; Ok ()
      | Error e -> Flo.debugf "[/start] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /update_types - Explain update types *)
  |> Bot.command "update_types" ~desc:"Explain update types" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/update_types] Explaining update types";

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
      | Ok _ -> Flo.debug "[/update_types] ✓"; Ok ()
      | Error e -> Flo.debugf "[/update_types] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /edit_test - Send editable message *)
  |> Bot.command "edit_test" ~desc:"Send message you can edit" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/edit_test] Sending editable message";

      Stats.increment_messages ();

      let text =
        "✏️ Edit This Message\n\n\
         Try editing this message in Telegram.\n\
         I'll detect the edit and log it!\n\n\
         (Long-press the message → Edit)"
      in

      match reply ctx text with
      | Ok _ -> Flo.debug "[/edit_test] ✓"; Ok ()
      | Error e -> Flo.debugf "[/edit_test] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /stats - Show update statistics *)
  |> Bot.command "stats" ~desc:"Show update statistics" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/stats] Showing statistics";

      Stats.increment_messages ();

      let text = Stats.summary () in

      let keyboard = KB.inline [
        [KB.callback ~text:"🔄 Reset Stats" ~data:"reset:stats"];
        [KB.callback ~text:"📊 Refresh" ~data:"show:stats"];
      ] in

      match send ~keyboard ctx text with
      | Ok _ -> Flo.debug "[/stats] ✓"; Ok ()
      | Error e -> Flo.debugf "[/stats] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* Handle ALL messages for logging/stats *)
  |> Bot.on_message (fun _ctx msg ->
      let open Telegram_generated.Gen_types.Message in

      (* Increment stats for non-command messages *)
      let is_command = match msg.text with
        | Some text when String.length text > 0 && text.[0] = '/' -> true
        | _ -> false
      in

      if not is_command then (
        Stats.increment_messages ();
        Flo.debugf "[on_message] Update type: message, message_id=%Ld" msg.message_id
      );

      Ok ()
    )

  (* Handle edited messages *)
  |> Bot.on (Bot.Event.when_ Bot.Event.any (fun upd ->
      let open Telegram_generated.Gen_types.Update in
      upd.edited_message <> None
    )) (fun ctx upd ->
      let open Bot.Ctx in
      let open Telegram_generated.Gen_types.Update in

      match upd.edited_message with
      | Some msg ->
          Stats.increment_edits ();

          let open Telegram_generated.Gen_types.Message in
          Flo.debugf "[edited_message] Update type: edited_message, message_id=%Ld" msg.message_id;

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
           | Ok _ -> Flo.debug "[edited_message] ✓"; Ok ()
           | Error e -> Flo.debugf "[edited_message] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ())

      | None -> Ok ()
    )

  (* Callback: test:button *)
  |> Bot.on_callback_data "test:button" (fun ctx ->
      let open Bot.Ctx in

      Stats.increment_callbacks ();

      Flo.debug "[test:button] Button pressed";

      match edit ctx "✅ Button pressed!\n\nThis was a callback_query update." with
      | Ok () -> Flo.debug "[test:button] ✓"; Ok ()
      | Error e -> Flo.debugf "[test:button] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* Callback: show:stats *)
  |> Bot.on_callback_data "show:stats" (fun ctx ->
      let open Bot.Ctx in

      Stats.increment_callbacks ();

      Flo.debug "[show:stats] Refreshing statistics";

      let text = Stats.summary () in

      let keyboard = KB.inline [
        [KB.callback ~text:"🔄 Reset Stats" ~data:"reset:stats"];
        [KB.callback ~text:"📊 Refresh" ~data:"show:stats"];
      ] in

      match edit ~keyboard ctx text with
      | Ok () -> Flo.debug "[show:stats] ✓"; Ok ()
      | Error e -> Flo.debugf "[show:stats] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* Callback: reset:stats *)
  |> Bot.on_callback_data "reset:stats" (fun ctx ->
      let open Bot.Ctx in

      Flo.debug "[reset:stats] Resetting statistics";

      Stats.reset ();

      let keyboard = KB.inline [
        [KB.callback ~text:"📊 View Stats" ~data:"show:stats"];
      ] in

      match edit ~keyboard ctx "🔄 Statistics reset!\n\nAll counters set to zero." with
      | Ok () -> Flo.debug "[reset:stats] ✓"; Ok ()
      | Error e -> Flo.debugf "[reset:stats] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* Log all callbacks for demonstration *)
  |> Bot.on_callback (fun _ctx data ->
      Flo.debugf "[on_callback] Received callback_query with data: %s" data;
      Ok ()
    )

  |> Bot.run
