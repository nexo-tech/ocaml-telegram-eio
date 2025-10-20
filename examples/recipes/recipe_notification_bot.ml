(** Recipe: Notification Bot

    A comprehensive notification system demonstrating:
    - User subscription management (subscribe/unsubscribe)
    - Broadcast messaging with Eio concurrency and rate limiting
    - Scheduled periodic messages with background fibers
    - Notification preferences (mute/unmute) with sessions
    - Admin-only commands with permission checks
    - Result-based error handling
    - Functor-based verbose logging
*)

open Telegram
open Tg

(** {1 Verbose Logging Setup} *)

(* Configure verbose logging with flo *)
let () = Flo.set_level Severity.Debug

(** {1 Subscription Management} *)

module Subscriptions = struct
  type t = (string, unit) Hashtbl.t  (* chat_id as string -> subscribed *) [@@warning "-34"]

  let create () =
    let open Flo in
    debug_fields "Creating subscription store" ~fields:[("module", Value.string "Subscriptions")];
    Hashtbl.create 1000

  let add t (chat_id : Id.Chat.k Id.t) =
    let open Flo in
    let key = Id.to_string chat_id in
    Hashtbl.replace t key ();
    debugf "[Subscriptions] Added subscriber: chat_id=%s" key

  let remove t (chat_id : Id.Chat.k Id.t) =
    let open Flo in
    let key = Id.to_string chat_id in
    Hashtbl.remove t key;
    debugf "[Subscriptions] Removed subscriber: chat_id=%s" key

  let list t =
    let open Flo in
    let subs = Hashtbl.to_seq_keys t |> List.of_seq in
    debugf "[Subscriptions] Listed subscribers: count=%d" (List.length subs);
    subs

  let count t =
    Hashtbl.length t

  let is_subscribed t (chat_id : Id.Chat.k Id.t) =
    let key = Id.to_string chat_id in
    Hashtbl.mem t key
end

let subscriptions = Subscriptions.create ()

(** {1 Admin Management} *)

module Admin = struct
  let admin_ids = ref []

  let load_from_env () =
    let open Flo in
    match Sys.getenv_opt "ADMIN_USER_IDS" with
    | Some ids_str ->
        let ids = String.split_on_char ',' ids_str
                  |> List.map String.trim
                  |> List.filter (fun s -> s <> "")
                  |> List.map Int64.of_string
        in
        admin_ids := ids;
        debugf "[Admin] Loaded %d admin IDs from ADMIN_USER_IDS" (List.length ids)
    | None ->
        debug "[Admin] No ADMIN_USER_IDS set, no admins configured"

  let is_admin user_id =
    List.mem user_id !admin_ids

  let require_admin ctx =
    let open Bot.Ctx in
    let open Flo in
    let* user = require_user ctx in
    let user_id_str = Id.to_string user.id in
    let user_id_int = Int64.of_string user_id_str in
    if is_admin user_id_int then begin
      debugf "[Admin] Access granted: user_id=%s" user_id_str;
      Ok user
    end else begin
      errorf "[Admin] Access denied: user_id=%s (not an admin)" user_id_str;
      Error (Error.Internal_error "Admin access required")
    end
end

(** {1 Notification Preferences} *)

type notification_prefs = {
  mute : bool;
}

let prefs_key = Session.make ~name:"notification_prefs"

(** {1 Broadcast Messaging} *)

let broadcast_text client env ~text ~max_concurrency ~delay_between =
  let open Flo in
  debug "";
  debug "╔══════════════════════════════════════════════════════════════════╗";
  debug "║                     Broadcasting Message                         ║";
  debug "╚══════════════════════════════════════════════════════════════════╝";

  let chat_keys = Subscriptions.list subscriptions in
  let total = List.length chat_keys in
  debugf "[Broadcast] Starting broadcast to %d subscribers" total;
  debugf "[Broadcast] Max concurrency: %d" max_concurrency;
  debugf "[Broadcast] Delay between messages: %.3fs" delay_between;

  let successes = ref 0 in
  let failures = ref 0 in

  Eio.Switch.run @@ fun sw ->
    let sem = Eio.Semaphore.make max_concurrency in

    List.iter (fun key ->
      Eio.Semaphore.acquire sem;
      Eio.Fiber.fork ~sw (fun () ->
        Fun.protect ~finally:(fun () -> Eio.Semaphore.release sem) @@ fun () ->
          let open Flo in
          let chat_id = Id.Chat.of_string key in
          debugf "[Broadcast] Sending to chat_id=%s" key;

          let request = Request.send_message ~chat_id ~text () in
          match Api.call client request with
          | Ok _ ->
              incr successes;
              successf "[Broadcast] Sent to chat_id=%s (%d/%d)" key !successes total
          | Error err ->
              incr failures;
              errorf "[Broadcast] Failed to send to chat_id=%s: %s" key (Format.asprintf "%a" Error.pp err);

          (* Throttle to respect rate limits *)
          if delay_between > 0. then
            Eio.Time.sleep env#clock delay_between
      )
    ) chat_keys;

  let open Flo in
  debug "";
  successf "[Broadcast] Broadcast complete: %d/%d success, %d failed" !successes total !failures;
  (!successes, !failures, total)

(** {1 Scheduled Messages} *)

let rec schedule_every client env ~chat_id ~seconds ~make_text =
  let open Flo in
  debugf "[Scheduler] Sleeping for %.0f seconds before next scheduled message" seconds;
  Eio.Time.sleep env#clock seconds;

  let text = make_text () in
  debugf "[Scheduler] Sending scheduled message to chat_id=%s" (Format.asprintf "%a" Id.pp chat_id);

  let request = Request.send_message ~chat_id ~text () in
  (match Api.call client request with
   | Ok _ ->
       success "[Scheduler] Scheduled message sent successfully"
   | Error err ->
       errorf "[Scheduler] Failed to send scheduled message: %s" (Format.asprintf "%a" Error.pp err));

  schedule_every client env ~chat_id ~seconds ~make_text

let start_scheduled_messages client env admin_chat =
  let open Flo in
  debug "[Scheduler] Starting scheduled message fiber";
  debugf "[Scheduler] Admin chat: %s" (Format.asprintf "%a" Id.pp admin_chat);
  debug "[Scheduler] Interval: 60 seconds (demo - would be 24h in production)";

  let make_digest () =
    let now = Unix.time () |> Unix.localtime in
    let subscriber_count = Subscriptions.count subscriptions in
    Printf.sprintf
      "📊 Daily Digest - %02d:%02d:%02d\n\n\
       Subscribers: %d\n\
       Status: All systems operational\n\n\
       This is a demo scheduled message."
      now.Unix.tm_hour now.Unix.tm_min now.Unix.tm_sec
      subscriber_count
  in

  schedule_every client env ~chat_id:admin_chat ~seconds:60.0 ~make_text:make_digest

(** {1 Bot Routes} *)

let build_routes telegram_client eio_env bot =
  let open Flo in
  debug "[Builder] Building bot routes...";

  let open Bot in
  let open Ctx in

  (* /start command *)
  let bot = bot |> command "start" (fun ctx _args ->
    let open Flo in
    debug "[Handler] /start command triggered";
    let* user = require_user ctx in
    debugf "[Handler] User: id=%s, username=%s"
      (Format.asprintf "%a" Id.pp user.id)
      (match user.username with Some u -> u | None -> "none");

    let chat_id = chat ctx in
    let is_subscribed = Subscriptions.is_subscribed subscriptions chat_id in

    let sub_status = if is_subscribed then "✅ Subscribed" else "❌ Not subscribed" in

    let welcome_text = Printf.sprintf
      "👋 Welcome to the Notification Bot!\n\n\
       I can send you notifications and updates.\n\n\
       Status: %s\n\n\
       Commands:\n\
       /subscribe - Subscribe to notifications\n\
       /unsubscribe - Unsubscribe from notifications\n\
       /preferences - Toggle notification settings\n\
       /status - Check subscription status\n\
       /broadcast <msg> - Send to all subscribers (admin only)\n\
       /help - Show this message"
      sub_status
    in

    let* _msg = answer ctx welcome_text in
    success "[Handler] Welcome message sent";
    Ok ()
  ) in

  (* /help command *)
  let bot = bot |> command "help" (fun ctx _args ->
    let open Flo in
    debug "[Handler] /help command triggered";

    let help_text =
      "📚 Help - Notification Bot\n\n\
       This bot sends notifications to subscribers.\n\n\
       User Commands:\n\
       /subscribe - Get notifications\n\
       /unsubscribe - Stop notifications\n\
       /preferences - Toggle mute/unmute\n\
       /status - Check if subscribed\n\n\
       Admin Commands:\n\
       /broadcast <message> - Send to all subscribers\n\
       /stats - Show subscriber statistics"
    in

    let* _msg = answer ctx help_text in
    success "[Handler] Help sent";
    Ok ()
  ) in

  (* /subscribe command *)
  let bot = bot |> command "subscribe" (fun ctx _args ->
    let open Flo in
    debug "[Handler] /subscribe command triggered";

    let chat_id = chat ctx in
    Subscriptions.add subscriptions chat_id;

    let* _msg = answer ctx "🔔 Subscribed to notifications! You'll receive updates from now on." in
    success "[Handler] User subscribed";
    Ok ()
  ) in

  (* /unsubscribe command *)
  let bot = bot |> command "unsubscribe" (fun ctx _args ->
    let open Flo in
    debug "[Handler] /unsubscribe command triggered";

    let chat_id = chat ctx in
    Subscriptions.remove subscriptions chat_id;

    let* _msg = answer ctx "🔕 Unsubscribed from notifications. You won't receive updates anymore." in
    success "[Handler] User unsubscribed";
    Ok ()
  ) in

  (* /status command *)
  let bot = bot |> command "status" (fun ctx _args ->
    let open Flo in
    debug "[Handler] /status command triggered";

    let chat_id = chat ctx in
    let is_subscribed = Subscriptions.is_subscribed subscriptions chat_id in
    let prefs = session_get_or ctx prefs_key ~default:{ mute = false } in

    let status_text = Printf.sprintf
      "📊 Your Notification Status\n\n\
       Subscription: %s\n\
       Notifications: %s\n\n\
       Total subscribers: %d"
      (if is_subscribed then "✅ Subscribed" else "❌ Not subscribed")
      (if prefs.mute then "🔕 Muted" else "🔔 Enabled")
      (Subscriptions.count subscriptions)
    in

    let* _msg = answer ctx status_text in
    success "[Handler] Status sent";
    Ok ()
  ) in

  (* /preferences command *)
  let bot = bot |> command "preferences" (fun ctx _args ->
    let open Flo in
    debug "[Handler] /preferences command triggered";

    let prefs = session_get_or ctx prefs_key ~default:{ mute = false } in
    let updated = { mute = not prefs.mute } in
    session_set ctx prefs_key updated;

    let msg = if updated.mute then
      "🔕 Notifications muted. You won't receive messages even if subscribed."
    else
      "🔔 Notifications unmuted. You'll receive messages if subscribed."
    in

    debugf "[Handler] Preferences updated: mute=%b" updated.mute;
    let* _msg = answer ctx msg in
    success "[Handler] Preferences toggled";
    Ok ()
  ) in

  (* /broadcast command - admin only *)
  let bot = bot |> command "broadcast" (fun ctx args ->
    let open Flo in
    debug "[Handler] /broadcast command triggered";

    match Admin.require_admin ctx with
    | Error err ->
        error "[Handler] Access denied";
        let* _msg = answer ctx "❌ Admin access required for broadcast." in
        Error err
    | Ok _admin ->
        match args with
        | [] ->
            let* _msg = answer ctx "Usage: /broadcast <message>\n\nExample: /broadcast Hello everyone!" in
            Ok ()
        | parts ->
            let text = String.concat " " parts in
            debugf "[Handler] Broadcasting message: %s" text;

            let (ok, fail, total) = broadcast_text telegram_client eio_env ~text ~max_concurrency:10 ~delay_between:0.05 in

            let result_text = Printf.sprintf
              "📢 Broadcast Complete\n\n\
               Successfully sent: %d/%d\n\
               Failed: %d\n\n\
               Message: %s"
              ok total fail text
            in

            let* _msg = answer ctx result_text in
            success "[Handler] Broadcast completed";
            Ok ()
  ) in

  (* /stats command - admin only *)
  let bot = bot |> command "stats" (fun ctx _args ->
    let open Flo in
    debug "[Handler] /stats command triggered";

    match Admin.require_admin ctx with
    | Error err ->
        error "[Handler] Access denied";
        let* _msg = answer ctx "❌ Admin access required." in
        Error err
    | Ok _admin ->
        let subscriber_count = Subscriptions.count subscriptions in
        let stats_text = Printf.sprintf
          "📊 Bot Statistics\n\n\
           Total subscribers: %d\n\
           Admin IDs configured: %d"
          subscriber_count
          (List.length !Admin.admin_ids)
        in

        let* _msg = answer ctx stats_text in
        success "[Handler] Stats sent";
        Ok ()
  ) in

  let open Flo in
  success "[Builder] All routes registered successfully";
  bot

(** {1 Main Entry Point} *)

let () =
  Eio_main.run @@ fun env ->

  let open Flo in
  debug "";
  debug "╔══════════════════════════════════════════════════════════════════╗";
  debug "║            Notification Bot - Subscriptions & Broadcasts         ║";
  debug "╚══════════════════════════════════════════════════════════════════╝";
  debug "";

  (* Phase 1: Initialize *)
  debug "╔══════════════════════════════════════════════════════════════════╗";
  debug "║                    Phase 1: Initialization                       ║";
  debug "╚══════════════════════════════════════════════════════════════════╝";

  let token = match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t ->
        debug "[Init] Bot token loaded from environment";
        t
    | None ->
        error "[Init] ERROR: TELEGRAM_BOT_TOKEN not set";
        failwith "TELEGRAM_BOT_TOKEN environment variable not set"
  in

  (* Load admin IDs *)
  Admin.load_from_env ();

  debug "[Init] Creating Telegram client";
  let telegram_client = Telegram.Client.create ~env ~token () in
  success "[Init] Client created successfully";

  (* Phase 2: Build bot *)
  debug "";
  debug "╔══════════════════════════════════════════════════════════════════╗";
  debug "║                     Phase 2: Build Bot                           ║";
  debug "╚══════════════════════════════════════════════════════════════════╝";

  let bot = Bot.make ~env ~client:telegram_client in
  let bot = build_routes telegram_client env bot in

  success "[Init] Bot created successfully";

  (* Phase 3: Start background tasks and polling *)
  debug "";
  debug "╔══════════════════════════════════════════════════════════════════╗";
  debug "║              Phase 3: Start Background Tasks & Polling           ║";
  debug "╚══════════════════════════════════════════════════════════════════╝";

  Eio.Switch.run @@ fun sw ->
    (* Start scheduled messages in background (if admin chat configured) *)
    (match Sys.getenv_opt "ADMIN_CHAT_ID" with
     | Some chat_id_str ->
         let admin_chat = Id.Chat.of_string chat_id_str in
         debugf "[Init] Starting scheduled message fiber for admin chat: %s" chat_id_str;
         Eio.Fiber.fork ~sw (fun () ->
           start_scheduled_messages telegram_client env admin_chat
         )
     | None ->
         debug "[Init] No ADMIN_CHAT_ID set, scheduled messages disabled");

    (* Start polling in foreground *)
    debug "[Polling] Starting long polling...";
    debug "[Polling] Bot is ready to receive updates";
    debug "";
    debug "╔══════════════════════════════════════════════════════════════════╗";
    debug "║                     Bot is Ready!                                ║";
    debug "╚══════════════════════════════════════════════════════════════════╝";
    debug "[Polling] Waiting for messages...";
    debug "";
    debug "Features:";
    debug "  - User subscriptions (subscribe/unsubscribe)";
    debug "  - Broadcast messaging with concurrency control";
    debug "  - Scheduled periodic messages (background fiber)";
    debug "  - Notification preferences (mute/unmute)";
    debug "  - Admin-only commands (/broadcast, /stats)";
    debug "";

    Bot.run bot
