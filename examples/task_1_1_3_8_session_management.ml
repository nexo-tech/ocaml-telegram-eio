(** Session Management Demo - Comprehensive demonstration of session handling

    This example demonstrates all session management features:
    - Creating typed session keys (phantom types)
    - Basic session operations (get, set, delete, exists, clear)
    - Session middleware integration with Bot DSL
    - User preferences storage
    - Multi-step workflows with session state
    - Session inspection and debugging
    - Session isolation per user

    Commands:
      /start - Show main menu
      /preferences - View and edit user preferences
      /counter - Increment a session counter
      /wizard - Start multi-step form wizard
      /session_info - Show current session data
      /clear_session - Clear all session data
      /set_name - Set your name in session
      /get_name - Retrieve name from session

    This example has VERBOSE LOGGING enabled for troubleshooting.

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/session_management_demo.exe
*)

open Telegram
open Tg

(* Configure verbose logging via functor composition *)
module Verbose_log = Log.Make (Log.Console) (struct
  let src = "SessionDemo"
  let level = Log.Debug
end)

module Verbose_session = Session.Make (Verbose_log)
module Verbose_polling = Polling.Make (Verbose_log)
module Verbose_bot = Bot.Make (Verbose_log) (Verbose_session) (Verbose_polling)

module KB = Keyboard

(** Session keys - typed for safety *)
let name_key = Verbose_session.make ~name:"user_name"
let counter_key = Verbose_session.make ~name:"counter"

(** Multi-step wizard state *)
type wizard_step =
  | Idle
  | AskingName
  | AskingAge
  | AskingCity

let wizard_step_key = Verbose_session.make ~name:"wizard_step"
let wizard_name_key = Verbose_session.make ~name:"wizard_name"
let wizard_age_key = Verbose_session.make ~name:"wizard_age"
let wizard_city_key = Verbose_session.make ~name:"wizard_city"

(** User preferences type *)
type preferences = {
  language: string;
  notifications: bool;
  theme: string;
}

let prefs_key = Verbose_session.make ~name:"preferences"

let default_prefs = {
  language = "English";
  notifications = true;
  theme = "Light";
}

let () =
  Printexc.record_backtrace true;
  Eio.traceln "=== Session Management Demo Starting ===";

  let token = match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None -> Printf.eprintf "TELEGRAM_BOT_TOKEN not set\n"; exit 1
  in

  Eio_main.run @@ fun env ->
  let client = Client.create ~env ~token () in

  Eio.traceln "🤖 Session Management Demo Bot Started";

  let session_store = Verbose_session.Memory_store.create () in

  Verbose_bot.make ~env ~client
  |> Verbose_bot.with_sessions (module Verbose_session.Memory_store) session_store

  (* /start - Main menu *)
  |> Verbose_bot.command "start" ~desc:"Show main menu" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/start] Showing main menu";

      let text =
        "💾 Session Management Demo\n\n\
         This bot demonstrates session management patterns.\n\n\
         📝 Commands:\n\
         /set_name <name> - Store your name\n\
         /get_name - Retrieve stored name\n\
         /counter - Increment session counter\n\
         /preferences - Manage preferences\n\
         /wizard - Multi-step form wizard\n\
         /session_info - Inspect session data\n\
         /clear_session - Clear all data"
      in

      match reply ctx text with
      | Ok _ -> Eio.traceln "[/start] ✓"; Ok ()
      | Error e -> Eio.traceln "[/start] ✗ %a" Error.pp e; Ok ()
    )

  (* /set_name - Set name in session *)
  |> Verbose_bot.command "set_name" ~desc:"Store your name" (fun ctx args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/set_name] Setting name in session";

      match args with
      | [] ->
          (match reply ctx "Usage: /set_name <your name>\n\nExample: /set_name Alice" with
           | Ok _ -> Ok ()
           | Error e -> Eio.traceln "[/set_name] ✗ %a" Error.pp e; Ok ())
      | _ ->
          let name = String.concat " " args in
          Eio.traceln "[/set_name] Storing name: %s" name;

          (* Store in session *)
          session_set ctx name_key name;

          let response = Printf.sprintf "✅ Name saved: %s\n\nTry /get_name to retrieve it!" name in

          (match reply ctx response with
           | Ok _ -> Eio.traceln "[/set_name] ✓"; Ok ()
           | Error e -> Eio.traceln "[/set_name] ✗ %a" Error.pp e; Ok ())
    )

  (* /get_name - Retrieve name from session *)
  |> Verbose_bot.command "get_name" ~desc:"Retrieve stored name" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/get_name] Retrieving name from session";

      match session_get ctx name_key with
      | Some name ->
          Eio.traceln "[/get_name] Found name: %s" name;
          (match reply ctx (Printf.sprintf "👋 Hello, %s!" name) with
           | Ok _ -> Eio.traceln "[/get_name] ✓"; Ok ()
           | Error e -> Eio.traceln "[/get_name] ✗ %a" Error.pp e; Ok ())
      | None ->
          Eio.traceln "[/get_name] No name in session";
          (match reply ctx "No name stored yet. Use /set_name <name> first!" with
           | Ok _ -> Ok ()
           | Error e -> Eio.traceln "[/get_name] ✗ %a" Error.pp e; Ok ())
    )

  (* /counter - Increment session counter *)
  |> Verbose_bot.command "counter" ~desc:"Increment session counter" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/counter] Incrementing counter";

      (* Get current value or default to 0 *)
      let current = session_get_or ctx counter_key ~default:0 in
      let new_value = current + 1 in

      Eio.traceln "[/counter] %d → %d" current new_value;

      (* Store new value *)
      session_set ctx counter_key new_value;

      let response = Printf.sprintf
        "🔢 Counter: %d → %d\n\n\
         This counter is stored in your session.\n\
         Each user has their own counter."
        current new_value
      in

      match reply ctx response with
      | Ok _ -> Eio.traceln "[/counter] ✓"; Ok ()
      | Error e -> Eio.traceln "[/counter] ✗ %a" Error.pp e; Ok ()
    )

  (* /preferences - Manage user preferences *)
  |> Verbose_bot.command "preferences" ~desc:"Manage preferences" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/preferences] Showing preferences";

      let prefs = session_get_or ctx prefs_key ~default:default_prefs in

      Eio.traceln "[/preferences] Language: %s, Notifications: %b, Theme: %s"
        prefs.language prefs.notifications prefs.theme;

      let notif_text = if prefs.notifications then "🔔 ON" else "🔕 OFF" in

      let keyboard = KB.inline [
        [KB.callback ~text:(Printf.sprintf "Language: %s" prefs.language) ~data:"pref:language"];
        [KB.callback ~text:(Printf.sprintf "Notifications: %s" notif_text) ~data:"pref:toggle_notif"];
        [KB.callback ~text:(Printf.sprintf "Theme: %s" prefs.theme) ~data:"pref:theme"];
      ] in

      let text = Printf.sprintf
        "⚙️ User Preferences\n\n\
         Language: %s\n\
         Notifications: %s\n\
         Theme: %s\n\n\
         Click a button to change."
        prefs.language
        notif_text
        prefs.theme
      in

      match send ~keyboard ctx text with
      | Ok _ -> Eio.traceln "[/preferences] ✓"; Ok ()
      | Error e -> Eio.traceln "[/preferences] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: pref:toggle_notif *)
  |> Verbose_bot.on_callback_data "pref:toggle_notif" (fun ctx ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[pref:toggle_notif] Toggling notifications";

      let prefs = session_get_or ctx prefs_key ~default:default_prefs in
      let updated = { prefs with notifications = not prefs.notifications } in

      Eio.traceln "[pref:toggle_notif] %b → %b" prefs.notifications updated.notifications;

      session_set ctx prefs_key updated;

      let notif_text = if updated.notifications then "🔔 ON" else "🔕 OFF" in

      let keyboard = KB.inline [
        [KB.callback ~text:(Printf.sprintf "Language: %s" updated.language) ~data:"pref:language"];
        [KB.callback ~text:(Printf.sprintf "Notifications: %s" notif_text) ~data:"pref:toggle_notif"];
        [KB.callback ~text:(Printf.sprintf "Theme: %s" updated.theme) ~data:"pref:theme"];
      ] in

      let text = Printf.sprintf
        "⚙️ User Preferences\n\n\
         Language: %s\n\
         Notifications: %s (toggled!)\n\
         Theme: %s"
        updated.language
        notif_text
        updated.theme
      in

      match edit ~keyboard ctx text with
      | Ok () -> Eio.traceln "[pref:toggle_notif] ✓"; Ok ()
      | Error e -> Eio.traceln "[pref:toggle_notif] ✗ %a" Error.pp e; Ok ()
    )

  (* /wizard - Multi-step form wizard *)
  |> Verbose_bot.command "wizard" ~desc:"Start multi-step wizard" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/wizard] Starting wizard";

      (* Initialize wizard state *)
      session_set ctx wizard_step_key AskingName;

      Eio.traceln "[/wizard] State: Idle → AskingName";

      let keyboard = KB.inline [
        [KB.callback ~text:"❌ Cancel" ~data:"wizard:cancel"];
      ] in

      match send ~keyboard ctx
        "📝 Multi-Step Wizard\n\n\
         Step 1/3: What's your name?"
      with
      | Ok _ -> Eio.traceln "[/wizard] ✓"; Ok ()
      | Error e -> Eio.traceln "[/wizard] ✗ %a" Error.pp e; Ok ()
    )

  (* Handle wizard text input *)
  |> Verbose_bot.on_text (fun ctx text ->
      let open Verbose_bot.Ctx in

      let step = session_get_or ctx wizard_step_key ~default:Idle in

      match step with
      | Idle ->
          (* Not in wizard mode *)
          Ok ()

      | AskingName ->
          Eio.traceln "[wizard] Received name: %s" text;

          session_set ctx wizard_name_key text;
          session_set ctx wizard_step_key AskingAge;

          Eio.traceln "[wizard] State: AskingName → AskingAge";

          (match reply ctx "Step 2/3: How old are you?" with
           | Ok _ -> Ok ()
           | Error e -> Eio.traceln "[wizard] ✗ %a" Error.pp e; Ok ())

      | AskingAge ->
          Eio.traceln "[wizard] Received age: %s" text;

          (match int_of_string_opt text with
           | Some age ->
               session_set ctx wizard_age_key age;
               session_set ctx wizard_step_key AskingCity;

               Eio.traceln "[wizard] State: AskingAge → AskingCity";

               (match reply ctx "Step 3/3: What city are you from?" with
                | Ok _ -> Ok ()
                | Error e -> Eio.traceln "[wizard] ✗ %a" Error.pp e; Ok ())

           | None ->
               (match reply ctx "Please enter a valid number for your age." with
                | Ok _ -> Ok ()
                | Error e -> Eio.traceln "[wizard] ✗ %a" Error.pp e; Ok ()))

      | AskingCity ->
          Eio.traceln "[wizard] Received city: %s" text;

          session_set ctx wizard_city_key text;
          session_set ctx wizard_step_key Idle;

          Eio.traceln "[wizard] State: AskingCity → Idle (completed)";

          (* Retrieve all collected data *)
          let name = session_get_or ctx wizard_name_key ~default:"<unknown>" in
          let age = session_get_or ctx wizard_age_key ~default:0 in
          let city = text in

          let summary = Printf.sprintf
            "✅ <b>Wizard Complete!</b>\n\n\
             Name: %s\n\
             Age: %d\n\
             City: %s\n\n\
             All data stored in session."
            name age city
          in

          (match reply ctx summary with
           | Ok _ -> Ok ()
           | Error e -> Eio.traceln "[wizard] ✗ %a" Error.pp e; Ok ())
    )

  (* Callback: wizard:cancel *)
  |> Verbose_bot.on_callback_data "wizard:cancel" (fun ctx ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[wizard:cancel] Cancelling wizard";

      session_set ctx wizard_step_key Idle;
      session_delete ctx wizard_name_key;
      session_delete ctx wizard_age_key;
      session_delete ctx wizard_city_key;

      Eio.traceln "[wizard:cancel] Wizard state cleared";

      match edit ctx "❌ Wizard cancelled. Session data cleared." with
      | Ok () -> Eio.traceln "[wizard:cancel] ✓"; Ok ()
      | Error e -> Eio.traceln "[wizard:cancel] ✗ %a" Error.pp e; Ok ()
    )

  (* /session_info - Show current session contents *)
  |> Verbose_bot.command "session_info" ~desc:"Inspect session data" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/session_info] Inspecting session";

      let name = session_get ctx name_key in
      let counter = session_get ctx counter_key in
      let prefs = session_get ctx prefs_key in
      let wizard_step = session_get ctx wizard_step_key in

      let name_str = match name with
        | Some n -> Printf.sprintf "✓ %s" n
        | None -> "✗ Not set"
      in

      let counter_str = match counter with
        | Some c -> Printf.sprintf "✓ %d" c
        | None -> "✗ Not set"
      in

      let prefs_str = match prefs with
        | Some p -> Printf.sprintf "✓ %s, %s, %b" p.language p.theme p.notifications
        | None -> "✗ Not set"
      in

      let wizard_str = match wizard_step with
        | Some Idle -> "Idle"
        | Some AskingName -> "AskingName"
        | Some AskingAge -> "AskingAge"
        | Some AskingCity -> "AskingCity"
        | None -> "✗ Not set"
      in

      let text = Printf.sprintf
        "🔍 <b>Session Inspection</b>\n\n\
         <b>Stored Keys:</b>\n\
         Name: %s\n\
         Counter: %s\n\
         Preferences: %s\n\
         Wizard Step: %s\n\n\
         Each user has isolated session data."
        name_str
        counter_str
        prefs_str
        wizard_str
      in

      match reply ctx text with
      | Ok _ -> Eio.traceln "[/session_info] ✓"; Ok ()
      | Error e -> Eio.traceln "[/session_info] ✗ %a" Error.pp e; Ok ()
    )

  (* /clear_session - Clear all session data *)
  |> Verbose_bot.command "clear_session" ~desc:"Clear all session data" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/clear_session] Clearing session";

      session_clear ctx;

      Eio.traceln "[/clear_session] All session data cleared";

      match reply ctx
        "🗑️ Session cleared!\n\n\
         All your data has been removed from the session.\n\
         Try /session_info to verify."
      with
      | Ok _ -> Eio.traceln "[/clear_session] ✓"; Ok ()
      | Error e -> Eio.traceln "[/clear_session] ✗ %a" Error.pp e; Ok ()
    )

  (* /modify_demo - Demonstrate session_modify *)
  |> Verbose_bot.command "modify_demo" ~desc:"Demonstrate modify function" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/modify_demo] Demonstrating modify";

      (* Use modify to increment counter (creates if missing) *)
      session_modify ctx counter_key ~default:0 (fun n -> n + 1);

      let new_value = session_get_or ctx counter_key ~default:0 in

      Eio.traceln "[/modify_demo] Counter after modify: %d" new_value;

      let response = Printf.sprintf
        "🔧 Session.modify Demo\n\n\
         Counter incremented to: %d\n\n\
         session_modify ~default:0 (fun n -> n + 1)\n\
         Creates key if missing, updates if present."
        new_value
      in

      match reply ctx response with
      | Ok _ -> Eio.traceln "[/modify_demo] ✓"; Ok ()
      | Error e -> Eio.traceln "[/modify_demo] ✗ %a" Error.pp e; Ok ()
    )

  (* /exists_demo - Demonstrate session_exists *)
  |> Verbose_bot.command "exists_demo" ~desc:"Check if keys exist" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/exists_demo] Checking key existence";

      let name_exists = session_exists ctx name_key in
      let counter_exists = session_exists ctx counter_key in
      let prefs_exists = session_exists ctx prefs_key in

      Eio.traceln "[/exists_demo] name=%b counter=%b prefs=%b"
        name_exists counter_exists prefs_exists;

      let text = Printf.sprintf
        "🔍 Key Existence Check\n\n\
         name_key: %s\n\
         counter_key: %s\n\
         prefs_key: %s\n\n\
         Use session_exists to check before accessing."
        (if name_exists then "✓ Exists" else "✗ Missing")
        (if counter_exists then "✓ Exists" else "✗ Missing")
        (if prefs_exists then "✓ Exists" else "✗ Missing")
      in

      match reply ctx text with
      | Ok _ -> Eio.traceln "[/exists_demo] ✓"; Ok ()
      | Error e -> Eio.traceln "[/exists_demo] ✗ %a" Error.pp e; Ok ()
    )

  |> Verbose_bot.run
