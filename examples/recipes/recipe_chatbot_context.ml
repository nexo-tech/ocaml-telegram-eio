(** Recipe: Chatbot With Context

    A comprehensive multi-turn contextual chatbot demonstrating:
    - Multi-step conversation flows (profile setup wizard)
    - Session-based state management with typed keys
    - Context expiration with TTL (time-to-live)
    - Mixed input handling (text + buttons)
    - Confirmation keyboards
    - Cancellation and fallback handlers
    - Result-based error handling
    - Functor-based verbose logging
*)

open Telegram
open Tg

(** {1 Verbose Logging Setup} *)

(* Configure verbose logging with flo *)
let () = Flo.set_level Severity.Debug

(** {1 Conversation State Machine} *)

(* Profile data being collected *)
type profile = {
  name : string option;
  email : string option;
  timezone : string option;
}

(* Conversation steps *)
type step =
  | Idle
  | AskName
  | AskEmail of { name : string }
  | AskTimezone of { name : string; email : string }
  | Confirm of { name : string; email : string; timezone : string }

(* Context state with TTL *)
type context_state = {
  step : step;
  data : profile;
  started_at : float;     (* Unix timestamp *)
  ttl_seconds : int;      (* Expire after this many seconds *)
}

(* Session keys *)
let state_key = Session.make ~name:"profile_wizard"

(* Helper functions *)
let now () = Unix.gettimeofday ()

let expired (s : context_state) =
  now () -. s.started_at > float_of_int s.ttl_seconds

let begin_flow () =
  let state = {
    step = AskName;
    data = { name = None; email = None; timezone = None };
    started_at = now ();
    ttl_seconds = 900; (* 15 minutes *)
  } in
  Flo.infof "[Flow] Starting new profile wizard flow: ttl=%d seconds" state.ttl_seconds;
  state

let step_name = function
  | Idle -> "Idle"
  | AskName -> "AskName"
  | AskEmail _ -> "AskEmail"
  | AskTimezone _ -> "AskTimezone"
  | Confirm _ -> "Confirm"

(** {1 Bot Routes} *)

let build_routes _client bot =
  Flo.debug "[Builder] Building bot routes...";

  let open Bot in
  let open Ctx in

  (* /start command *)
  let bot = bot |> command "start" (fun ctx _args ->
    Flo.debug "[Handler] /start command triggered";
    let* user = require_user ctx in
    Flo.debugf "[Handler] User: id=%s, username=%s"
      (Format.asprintf "%a" Id.pp user.id)
      (match user.username with Some u -> u | None -> "none");

    let welcome_text =
      "👋 Welcome to the Contextual Chatbot!\n\n\
       I can help you set up your profile with a multi-step conversation.\n\n\
       Commands:\n\
       /start_profile - Start profile setup wizard\n\
       /cancel - Cancel current conversation\n\
       /status - Show current conversation state\n\
       /help - Show this message"
    in

    Flo.debug "[Handler] Sending welcome message";
    let* _msg = answer ctx welcome_text in
    Flo.success "[Handler] ✅ Welcome message sent";
    Ok ()
  ) in

  (* /help command *)
  let bot = bot |> command "help" (fun ctx _args ->
    Flo.debug "[Handler] /help command triggered";

    let help_text =
      "📚 Help - Contextual Chatbot\n\n\
       This bot demonstrates multi-turn conversations:\n\n\
       /start - Welcome message\n\
       /start_profile - Begin profile setup (Name → Email → Timezone)\n\
       /status - Check current conversation state\n\
       /cancel - Cancel current conversation\n\
       /help - Show this help\n\n\
       The conversation will expire after 15 minutes of inactivity."
    in

    let* _msg = answer ctx help_text in
    Flo.success "[Handler] ✅ Help sent";
    Ok ()
  ) in

  (* /start_profile command *)
  let bot = bot |> command "start_profile" (fun ctx _args ->
    Flo.debug "[Handler] /start_profile command triggered";

    let state = begin_flow () in
    session_set ctx state_key state;
    Flo.debugf "[Handler] Session state initialized: step=%s" (step_name state.step);

    let* _msg = answer ctx "👋 Let's set up your profile!\n\nWhat is your name?" in
    Flo.success "[Handler] ✅ Profile wizard started, waiting for name";
    Ok ()
  ) in

  (* /status command *)
  let bot = bot |> command "status" (fun ctx _args ->
    Flo.debug "[Handler] /status command triggered";

    match session_get ctx state_key with
    | None ->
        Flo.debug "[Handler] No active conversation";
        let* _msg = answer ctx "No active conversation. Send /start_profile to begin." in
        Ok ()
    | Some state ->
        let elapsed = now () -. state.started_at in
        let remaining = float_of_int state.ttl_seconds -. elapsed in
        let status_text = Printf.sprintf
          "📊 Conversation Status\n\n\
           Current step: %s\n\
           Started: %.0f seconds ago\n\
           Expires in: %.0f seconds\n\n\
           Data collected:\n\
           Name: %s\n\
           Email: %s\n\
           Timezone: %s"
          (step_name state.step)
          elapsed
          remaining
          (match state.data.name with Some n -> n | None -> "(not set)")
          (match state.data.email with Some e -> e | None -> "(not set)")
          (match state.data.timezone with Some tz -> tz | None -> "(not set)")
        in
        Flo.debugf "[Handler] Current step: %s, elapsed: %.0fs" (step_name state.step) elapsed;
        let* _msg = answer ctx status_text in
        Ok ()
  ) in

  (* /cancel command *)
  let bot = bot |> command "cancel" (fun ctx _args ->
    Flo.debug "[Handler] /cancel command triggered";

    if session_exists ctx state_key then begin
      Flo.debug "[Handler] Cancelling active conversation";
      session_delete ctx state_key;
      let* _msg = answer ctx "🛑 Conversation cancelled. Send /start_profile to begin again." in
      Flo.success "[Handler] ✅ Conversation cancelled";
      Ok ()
    end else begin
      Flo.debug "[Handler] No active conversation to cancel";
      let* _msg = answer ctx "Nothing to cancel. You don't have an active conversation." in
      Ok ()
    end
  ) in

  (* on_text - Multi-step conversation handler *)
  let bot = bot |> on_text (fun ctx text ->
    Flo.debugf "[Handler] on_text triggered: text_length=%d" (String.length text);

    let default_state = {
      step = Idle;
      data = { name = None; email = None; timezone = None };
      started_at = 0.;
      ttl_seconds = 0;
    } in

    let state = session_get_or ctx state_key ~default:default_state in
    Flo.debugf "[Handler] Current step: %s" (step_name state.step);

    (* Check expiration *)
    if (match state.step with Idle -> false | _ -> expired state) then begin
      Flo.debugf "[Handler] ⏳ Session expired: elapsed=%.0fs, ttl=%d"
        (now () -. state.started_at) state.ttl_seconds;
      session_delete ctx state_key;
      let* _msg = answer ctx "⏳ Session expired (15 minutes). Send /start_profile to begin again." in
      Ok ()
    end else

    match state.step with
    | Idle ->
        Flo.debug "[Handler] Idle state, ignoring text";
        Ok () (* Ignore random text when idle *)

    | AskName ->
        let name = String.trim text in
        Flo.debugf "[Handler] Collected name: %s" name;

        let state' = {
          state with
          step = AskEmail { name };
          data = { state.data with name = Some name };
        } in
        session_set ctx state_key state';
        Flo.debugf "[Handler] Updated step: %s" (step_name state'.step);

        let* _msg = answer ctx (Printf.sprintf "Great, %s! What's your email address?" name) in
        Flo.success "[Handler] ✅ Waiting for email";
        Ok ()

    | AskEmail { name } ->
        let email = String.trim text in
        Flo.debugf "[Handler] Collected email: %s" email;

        let state' = {
          state with
          step = AskTimezone { name; email };
          data = { state.data with email = Some email };
        } in
        session_set ctx state_key state';
        Flo.debugf "[Handler] Updated step: %s" (step_name state'.step);

        let* _msg = answer ctx "And your timezone? (e.g., UTC, CET, PST, EST)" in
        Flo.success "[Handler] ✅ Waiting for timezone";
        Ok ()

    | AskTimezone { name; email } ->
        let timezone = String.uppercase_ascii (String.trim text) in
        Flo.debugf "[Handler] Collected timezone: %s" timezone;

        let state' = {
          state with
          step = Confirm { name; email; timezone };
          data = { state.data with timezone = Some timezone };
        } in
        session_set ctx state_key state';
        Flo.debugf "[Handler] Updated step: %s" (step_name state'.step);

        (* Show confirmation keyboard *)
        let keyboard = Keyboard.inline [
          [ Keyboard.callback ~text:"✅ Confirm" ~data:"profile:confirm" ];
          [ Keyboard.callback ~text:"✏️  Restart" ~data:"profile:restart" ];
          [ Keyboard.callback ~text:"✖️  Cancel" ~data:"profile:cancel" ];
        ] in

        let confirmation_text = Printf.sprintf
          "📋 Please confirm your profile:\n\n\
           Name: %s\n\
           Email: %s\n\
           Timezone: %s\n\n\
           Use the buttons below to confirm or edit."
          name email timezone
        in

        Flo.debug "[Handler] Showing confirmation keyboard";
        let* _msg = send ~keyboard ctx confirmation_text in
        Flo.success "[Handler] ✅ Confirmation shown";
        Ok ()

    | Confirm _ ->
        Flo.debug "[Handler] In confirm state, asking user to use buttons";
        let* _msg = answer ctx "Please use the buttons above to confirm, restart, or cancel." in
        Ok ()
  ) in

  (* on_callback - Handle confirmation buttons *)
  let bot = bot |> on_callback (fun ctx callback_data ->
    Flo.debugf "[Handler] on_callback triggered: data=%s" callback_data;

    match callback_data with
    | "profile:confirm" ->
        Flo.debug "[Handler] Handling profile:confirm";
        (match session_get ctx state_key with
         | Some { step = Confirm { name; email; timezone }; _ } ->
             Flo.debugf "[Handler] Confirming profile: name=%s, email=%s, tz=%s"
               name email timezone;

             (* In a real app, persist to database here *)
             session_delete ctx state_key;
             Flo.debug "[Handler] Session cleared after confirmation";

             let success_text = Printf.sprintf
               "✅ Profile saved successfully!\n\n\
                Name: %s\n\
                Email: %s\n\
                Timezone: %s\n\n\
                Your profile is now complete. Send /start_profile to update it."
               name email timezone
             in

             let* _msg = edit ctx success_text in
             Flo.success "[Handler] ✅ Profile confirmed and saved";
             Ok ()

         | _ ->
             Flo.error "[Handler] ❌ Invalid state for confirmation";
             let* _msg = edit ctx "❌ Session expired or invalid. Send /start_profile to begin." in
             Ok ())

    | "profile:restart" ->
        Flo.debug "[Handler] Handling profile:restart";
        let state = begin_flow () in
        session_set ctx state_key state;
        let* _msg = edit ctx "🔁 Profile setup restarted. What's your name?" in
        Flo.success "[Handler] ✅ Profile wizard restarted";
        Ok ()

    | "profile:cancel" ->
        Flo.debug "[Handler] Handling profile:cancel";
        session_delete ctx state_key;
        let* _msg = edit ctx "❌ Profile setup cancelled." in
        Flo.success "[Handler] ✅ Profile wizard cancelled";
        Ok ()

    | _ ->
        Flo.debugf "[Handler] Unknown callback data: %s" callback_data;
        Ok ()
  ) in

  Flo.success "[Builder] ✅ All routes registered successfully";
  bot

(** {1 Main Entry Point} *)

let () =
  Eio_main.run @@ fun env ->

  Flo.debug "";
  Flo.info "╔══════════════════════════════════════════════════════════════════╗";
  Flo.info "║           Contextual Chatbot - Multi-Turn Conversations         ║";
  Flo.info "╚══════════════════════════════════════════════════════════════════╝";
  Flo.debug "";

  (* Phase 1: Initialize *)
  Flo.info "╔══════════════════════════════════════════════════════════════════╗";
  Flo.info "║                    Phase 1: Initialization                       ║";
  Flo.info "╚══════════════════════════════════════════════════════════════════╝";

  let token = match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t ->
        Flo.info "[Init] Bot token loaded from environment";
        t
    | None ->
        Flo.info "[Init] ❌ ERROR: TELEGRAM_BOT_TOKEN not set";
        failwith "TELEGRAM_BOT_TOKEN environment variable not set"
  in

  Flo.info "[Init] Creating Telegram client";
  let telegram_client = Telegram.Client.create ~env ~token () in
  Flo.info "[Init] Client created successfully";

  (* Phase 2: Build bot *)
  Flo.debug "";
  Flo.info "╔══════════════════════════════════════════════════════════════════╗";
  Flo.info "║                     Phase 2: Build Bot                           ║";
  Flo.info "╚══════════════════════════════════════════════════════════════════╝";

  let bot = Bot.make ~env ~client:telegram_client in
  let bot = build_routes telegram_client bot in

  Flo.info "[Init] Bot created successfully";

  (* Phase 3: Run polling *)
  Flo.debug "";
  Flo.info "╔══════════════════════════════════════════════════════════════════╗";
  Flo.info "║                    Phase 3: Start Polling                        ║";
  Flo.info "╚══════════════════════════════════════════════════════════════════╝";
  Flo.info "[Polling] Starting long polling...";
  Flo.info "[Polling] Bot is ready to receive updates";
  Flo.debug "";
  Flo.info "╔══════════════════════════════════════════════════════════════════╗";
  Flo.info "║                     Bot is Ready!                                ║";
  Flo.info "╚══════════════════════════════════════════════════════════════════╝";
  Flo.info "[Polling] Waiting for messages...";
  Flo.debug "";
  Flo.info "Features:";
  Flo.debug "  - Multi-step profile wizard (Name → Email → Timezone)";
  Flo.debug "  - Session-based state management";
  Flo.debug "  - 15-minute TTL (time-to-live) expiration";
  Flo.debug "  - Confirmation keyboard";
  Flo.debug "  - /cancel command";
  Flo.debug "";

  Bot.run bot
