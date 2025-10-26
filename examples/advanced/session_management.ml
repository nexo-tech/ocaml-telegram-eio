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

    Debugging session management:
      Enable debug logs for session operations to see how data is stored/retrieved:
        - Flo.set_level_for "telegram.session" Severity.Debug
          → See all session get/set/delete operations
        - Flo.set_level_for "telegram.session" Severity.Trace
          → See store size and internal session details

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/session_management_demo.exe
*)

open Telegram
open Tg

(* Configure logging to debug session operations *)
let () =
  Flo.set_level Severity.Info;  (* Default level *)

  (* Enable debug logs for session operations - see all get/set/delete *)
  Flo.set_level_for "telegram.session" Severity.Debug;

  (* Uncomment to see even more detail (store size, key counts): *)
  (* Flo.set_level_for "telegram.session" Severity.Trace; *)

module KB = Keyboard

(** Session keys - typed for safety *)
let name_key = Session.make ~name:"user_name"
let counter_key = Session.make ~name:"counter"

(** Multi-step wizard state *)
type wizard_step =
  | Idle
  | AskingName
  | AskingAge
  | AskingCity

let wizard_step_key = Session.make ~name:"wizard_step"
let wizard_name_key = Session.make ~name:"wizard_name"
let wizard_age_key = Session.make ~name:"wizard_age"
let wizard_city_key = Session.make ~name:"wizard_city"

(** User preferences type *)
type preferences = {
  language: string;
  notifications: bool;
  theme: string;
}

let prefs_key = Session.make ~name:"preferences"

let default_prefs = {
  language = "English";
  notifications = true;
  theme = "Light";
}

let () =
  Printexc.record_backtrace true;
  Flo.info "=== Session Management Demo Starting ===";

  let token = match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None -> Printf.eprintf "TELEGRAM_BOT_TOKEN not set\n"; exit 1
  in

  Eio_main.run @@ fun env ->
  let client = Client.create ~env ~token () in

  Flo.info "🤖 Session Management Demo Bot Started";

  let session_store = Session.Memory_store.create () in

  Bot.make ~env ~client
  |> Bot.with_sessions (module Session.Memory_store) session_store

  (* /start - Main menu *)
  |> Bot.command "start" ~desc:"Show main menu" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/start] Showing main menu";

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
      | Ok _ -> Flo.debug "[/start] ✓"; Ok ()
      | Error e -> Flo.debugf "[/start] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /set_name - Set name in session *)
  |> Bot.command "set_name" ~desc:"Store your name" (fun ctx args ->
      let open Bot.Ctx in
      Flo.debug "[/set_name] Setting name in session";

      match args with
      | [] ->
          (match reply ctx "Usage: /set_name <your name>\n\nExample: /set_name Alice" with
           | Ok _ -> Ok ()
           | Error e -> Flo.debugf "[/set_name] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ())
      | _ ->
          let name = String.concat " " args in
          Flo.debugf "[/set_name] Storing name: %s" name;

          (* Store in session *)
          session_set ctx name_key name;

          let response = Printf.sprintf "✅ Name saved: %s\n\nTry /get_name to retrieve it!" name in

          (match reply ctx response with
           | Ok _ -> Flo.debug "[/set_name] ✓"; Ok ()
           | Error e -> Flo.debugf "[/set_name] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ())
    )

  (* /get_name - Retrieve name from session *)
  |> Bot.command "get_name" ~desc:"Retrieve stored name" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/get_name] Retrieving name from session";

      match session_get ctx name_key with
      | Some name ->
          Flo.debugf "[/get_name] Found name: %s" name;
          (match reply ctx (Printf.sprintf "👋 Hello, %s!" name) with
           | Ok _ -> Flo.debug "[/get_name] ✓"; Ok ()
           | Error e -> Flo.debugf "[/get_name] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ())
      | None ->
          Flo.debug "[/get_name] No name in session";
          (match reply ctx "No name stored yet. Use /set_name <name> first!" with
           | Ok _ -> Ok ()
           | Error e -> Flo.debugf "[/get_name] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ())
    )

  (* /counter - Increment session counter *)
  |> Bot.command "counter" ~desc:"Increment session counter" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/counter] Incrementing counter";

      (* Get current value or default to 0 *)
      let current = session_get_or ctx counter_key ~default:0 in
      let new_value = current + 1 in

      Flo.debugf "[/counter] %d → %d" current new_value;

      (* Store new value *)
      session_set ctx counter_key new_value;

      let response = Printf.sprintf
        "🔢 Counter: %d → %d\n\n\
         This counter is stored in your session.\n\
         Each user has their own counter."
        current new_value
      in

      match reply ctx response with
      | Ok _ -> Flo.debug "[/counter] ✓"; Ok ()
      | Error e -> Flo.debugf "[/counter] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /preferences - Manage user preferences *)
  |> Bot.command "preferences" ~desc:"Manage preferences" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/preferences] Showing preferences";

      let prefs = session_get_or ctx prefs_key ~default:default_prefs in

      Flo.debugf "[/preferences] Language: %s, Notifications: %b, Theme: %s"
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
      | Ok _ -> Flo.debug "[/preferences] ✓"; Ok ()
      | Error e -> Flo.debugf "[/preferences] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* Callback: pref:toggle_notif *)
  |> Bot.on_callback_data "pref:toggle_notif" (fun ctx ->
      let open Bot.Ctx in
      Flo.debug "[pref:toggle_notif] Toggling notifications";

      let prefs = session_get_or ctx prefs_key ~default:default_prefs in
      let updated = { prefs with notifications = not prefs.notifications } in

      Flo.debugf "[pref:toggle_notif] %b → %b" prefs.notifications updated.notifications;

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
      | Ok () -> Flo.debug "[pref:toggle_notif] ✓"; Ok ()
      | Error e -> Flo.debugf "[pref:toggle_notif] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /wizard - Multi-step form wizard *)
  |> Bot.command "wizard" ~desc:"Start multi-step wizard" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/wizard] Starting wizard";

      (* Initialize wizard state *)
      session_set ctx wizard_step_key AskingName;

      Flo.debug "[/wizard] State: Idle → AskingName";

      let keyboard = KB.inline [
        [KB.callback ~text:"❌ Cancel" ~data:"wizard:cancel"];
      ] in

      match send ~keyboard ctx
        "📝 Multi-Step Wizard\n\n\
         Step 1/3: What's your name?"
      with
      | Ok _ -> Flo.debug "[/wizard] ✓"; Ok ()
      | Error e -> Flo.debugf "[/wizard] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* Handle wizard text input *)
  |> Bot.on_text (fun ctx text ->
      let open Bot.Ctx in

      let step = session_get_or ctx wizard_step_key ~default:Idle in

      match step with
      | Idle ->
          (* Not in wizard mode *)
          Ok ()

      | AskingName ->
          Flo.debugf "[wizard] Received name: %s" text;

          session_set ctx wizard_name_key text;
          session_set ctx wizard_step_key AskingAge;

          Flo.debug "[wizard] State: AskingName → AskingAge";

          (match reply ctx "Step 2/3: How old are you?" with
           | Ok _ -> Ok ()
           | Error e -> Flo.debugf "[wizard] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ())

      | AskingAge ->
          Flo.debugf "[wizard] Received age: %s" text;

          (match int_of_string_opt text with
           | Some age ->
               session_set ctx wizard_age_key age;
               session_set ctx wizard_step_key AskingCity;

               Flo.debug "[wizard] State: AskingAge → AskingCity";

               (match reply ctx "Step 3/3: What city are you from?" with
                | Ok _ -> Ok ()
                | Error e -> Flo.debugf "[wizard] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ())

           | None ->
               (match reply ctx "Please enter a valid number for your age." with
                | Ok _ -> Ok ()
                | Error e -> Flo.debugf "[wizard] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()))

      | AskingCity ->
          Flo.debugf "[wizard] Received city: %s" text;

          session_set ctx wizard_city_key text;
          session_set ctx wizard_step_key Idle;

          Flo.debug "[wizard] State: AskingCity → Idle (completed)";

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
           | Error e -> Flo.debugf "[wizard] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ())
    )

  (* Callback: wizard:cancel *)
  |> Bot.on_callback_data "wizard:cancel" (fun ctx ->
      let open Bot.Ctx in
      Flo.debug "[wizard:cancel] Cancelling wizard";

      session_set ctx wizard_step_key Idle;
      session_delete ctx wizard_name_key;
      session_delete ctx wizard_age_key;
      session_delete ctx wizard_city_key;

      Flo.debug "[wizard:cancel] Wizard state cleared";

      match edit ctx "❌ Wizard cancelled. Session data cleared." with
      | Ok () -> Flo.debug "[wizard:cancel] ✓"; Ok ()
      | Error e -> Flo.debugf "[wizard:cancel] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /session_info - Show current session contents *)
  |> Bot.command "session_info" ~desc:"Inspect session data" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/session_info] Inspecting session";

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
      | Ok _ -> Flo.debug "[/session_info] ✓"; Ok ()
      | Error e -> Flo.debugf "[/session_info] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /clear_session - Clear all session data *)
  |> Bot.command "clear_session" ~desc:"Clear all session data" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/clear_session] Clearing session";

      session_clear ctx;

      Flo.debug "[/clear_session] All session data cleared";

      match reply ctx
        "🗑️ Session cleared!\n\n\
         All your data has been removed from the session.\n\
         Try /session_info to verify."
      with
      | Ok _ -> Flo.debug "[/clear_session] ✓"; Ok ()
      | Error e -> Flo.debugf "[/clear_session] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /modify_demo - Demonstrate session_modify *)
  |> Bot.command "modify_demo" ~desc:"Demonstrate modify function" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/modify_demo] Demonstrating modify";

      (* Use modify to increment counter (creates if missing) *)
      session_modify ctx counter_key ~default:0 (fun n -> n + 1);

      let new_value = session_get_or ctx counter_key ~default:0 in

      Flo.debugf "[/modify_demo] Counter after modify: %d" new_value;

      let response = Printf.sprintf
        "🔧 Session.modify Demo\n\n\
         Counter incremented to: %d\n\n\
         session_modify ~default:0 (fun n -> n + 1)\n\
         Creates key if missing, updates if present."
        new_value
      in

      match reply ctx response with
      | Ok _ -> Flo.debug "[/modify_demo] ✓"; Ok ()
      | Error e -> Flo.debugf "[/modify_demo] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /exists_demo - Demonstrate session_exists *)
  |> Bot.command "exists_demo" ~desc:"Check if keys exist" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/exists_demo] Checking key existence";

      let name_exists = session_exists ctx name_key in
      let counter_exists = session_exists ctx counter_key in
      let prefs_exists = session_exists ctx prefs_key in

      Flo.debugf "[/exists_demo] name=%b counter=%b prefs=%b"
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
      | Ok _ -> Flo.debug "[/exists_demo] ✓"; Ok ()
      | Error e -> Flo.debugf "[/exists_demo] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  |> Bot.run
