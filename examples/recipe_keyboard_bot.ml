(** Recipe: Keyboard Bot with Interactive Menus

    This example demonstrates keyboard bot patterns from recipe_keyboard_bot.mld:
    - Inline keyboards for menu navigation
    - Multi-level menu hierarchies with back navigation
    - Session-based settings with toggle buttons
    - Callback query handling
    - Dynamic keyboard generation
    - State management across interactions

    This example has VERBOSE LOGGING enabled to help troubleshoot issues.
    Every step is logged to stderr so you can see exactly what's happening.

    Commands:
      /start - Show main menu
      /menu - Show main menu
      /settings - Show settings menu

    Menu structure:
      Main Menu
        ├─ ⚙️ Settings
        │   ├─ 🔔 Notifications (toggle)
        │   ├─ 🌐 Language (selection)
        │   └─ 🎨 Theme (selection)
        ├─ 👤 Profile
        ├─ ❓ Help
        └─ ℹ️ About

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/recipe_keyboard_bot.exe

    What you'll see in the logs:
      - Keyboard creation and button layout
      - Callback data routing (menu:*, settings:*, etc.)
      - Session state management (get/set preferences)
      - Menu navigation (forward/back)
      - Toggle state changes
*)

open Telegram
open Tg

(* Configure verbose logging via functor composition *)
module Verbose_log = Log.Make (Log.Console) (struct
  let src = "KeyboardBot"
  let level = Log.Debug
end)

module Verbose_session = Session.Make (Verbose_log)
module Verbose_polling = Polling.Make (Verbose_log)
module Verbose_bot = Bot.Make (Verbose_log) (Verbose_session) (Verbose_polling)

(* Use the ergonomic Keyboard module from the library *)
module KB = Keyboard

(** Settings state *)
module Settings = struct
  type t = {
    notifications: bool;
    language: string;
    theme: string;
  }

  let default = { notifications = true; language = "English"; theme = "Light" }
  let toggle_notif s = { s with notifications = not s.notifications }
end

let () =
  Eio.traceln "=== Keyboard Bot Starting ===";

  let token = match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None -> Printf.eprintf "TELEGRAM_BOT_TOKEN not set\n"; exit 1
  in

  Eio_main.run @@ fun env ->
  let client = Client.create ~env ~token () in
  let settings_key = Verbose_session.make ~name:"settings" in

  Eio.traceln "🤖 Keyboard Bot Started";

  Verbose_bot.make ~env ~client

  (* /start - main menu *)
  |> Verbose_bot.command "start" ~desc:"Show main menu" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/start] Showing main menu";

      let keyboard = KB.inline [
        [KB.callback ~text:"⚙️ Settings" ~data:"menu:settings"];
        [KB.callback ~text:"👤 Profile" ~data:"menu:profile"];
        [KB.callback ~text:"❓ Help" ~data:"menu:help"];
      ] in

      match send ~keyboard ctx "👋 Welcome! Choose an option:" with
      | Ok _ -> Eio.traceln "[/start] ✓ Sent"; Ok ()
      | Error e -> Eio.traceln "[/start] ✗ Error: %a" Error.pp e; Ok ()
    )

  (* /settings - settings menu *)
  |> Verbose_bot.command "settings" ~desc:"Show settings" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      let settings = session_get_or ctx settings_key ~default:Settings.default in
      Eio.traceln "[/settings] notifications=%b lang=%s theme=%s"
        settings.notifications settings.language settings.theme;

      let notif_text = if settings.notifications
        then "🔔 Notifications: ON" else "🔕 Notifications: OFF" in

      let keyboard = KB.inline [
        [KB.callback ~text:notif_text ~data:"toggle_notif"];
        [KB.callback ~text:("🌐 " ^ settings.language) ~data:"lang"];
        [KB.callback ~text:("🎨 " ^ settings.theme) ~data:"theme"];
        [KB.callback ~text:"← Back" ~data:"menu:main"];
      ] in

      match send ~keyboard ctx "⚙️ Settings" with
      | Ok _ -> Ok ()
      | Error e -> Eio.traceln "[/settings] Error: %a" Error.pp e; Ok ()
    )

  (* Callback: menu:main *)
  |> Verbose_bot.on_callback (fun ctx data ->
      if data = "menu:main" then (
        let open Verbose_bot.Ctx in

        let keyboard = KB.inline [
          [KB.callback ~text:"⚙️ Settings" ~data:"menu:settings"];
          [KB.callback ~text:"👤 Profile" ~data:"menu:profile"];
          [KB.callback ~text:"❓ Help" ~data:"menu:help"];
        ] in

        match edit ~keyboard ctx "📱 Main Menu" with
        | Ok _ -> Eio.traceln "[menu:main] ✓"; Ok ()
        | Error e -> Eio.traceln "[menu:main] ✗ %a" Error.pp e; Ok ()
      ) else Ok ()
    )

  (* Callback: menu:settings *)
  |> Verbose_bot.on_callback (fun ctx data ->
      if data = "menu:settings" then (
        let open Verbose_bot.Ctx in
        let settings = session_get_or ctx settings_key ~default:Settings.default in

        let notif_text = if settings.notifications
          then "🔔 Notifications: ON" else "🔕 Notifications: OFF" in

        let keyboard = KB.inline [
          [KB.callback ~text:notif_text ~data:"toggle_notif"];
          [KB.callback ~text:("🌐 " ^ settings.language) ~data:"lang"];
          [KB.callback ~text:("🎨 " ^ settings.theme) ~data:"theme"];
          [KB.callback ~text:"← Back" ~data:"menu:main"];
        ] in

        match edit ~keyboard ctx "⚙️ Settings" with
        | Ok _ -> Ok ()
        | Error e -> Eio.traceln "[menu:settings] Error: %a" Error.pp e; Ok ()
      ) else Ok ()
    )

  (* Callback: toggle_notif *)
  |> Verbose_bot.on_callback (fun ctx data ->
      if data = "toggle_notif" then (
        let open Verbose_bot.Ctx in
        let settings = session_get_or ctx settings_key ~default:Settings.default in
        let updated = Settings.toggle_notif settings in
        session_set ctx settings_key updated;
        Eio.traceln "[toggle_notif] %b → %b" settings.notifications updated.notifications;

        let notif_text = if updated.notifications
          then "🔔 Notifications: ON" else "🔕 Notifications: OFF" in

        let keyboard = KB.inline [
          [KB.callback ~text:notif_text ~data:"toggle_notif"];
          [KB.callback ~text:("🌐 " ^ updated.language) ~data:"lang"];
          [KB.callback ~text:("🎨 " ^ updated.theme) ~data:"theme"];
          [KB.callback ~text:"← Back" ~data:"menu:main"];
        ] in

        match edit ~keyboard ctx "⚙️ Settings (toggled!)" with
        | Ok _ -> Ok ()
        | Error e -> Eio.traceln "[toggle_notif] Error: %a" Error.pp e; Ok ()
      ) else Ok ()
    )

  (* Callback: menu:profile *)
  |> Verbose_bot.on_callback (fun ctx data ->
      if data = "menu:profile" then (
        let open Verbose_bot.Ctx in

        let keyboard = KB.inline [
          [KB.callback ~text:"← Back" ~data:"menu:main"];
        ] in

        match edit ~keyboard ctx "👤 Profile\n\nProfile features coming soon!" with
        | Ok _ -> Ok ()
        | Error e -> Eio.traceln "[menu:profile] Error: %a" Error.pp e; Ok ()
      ) else Ok ()
    )

  (* Callback: menu:help *)
  |> Verbose_bot.on_callback (fun ctx data ->
      if data = "menu:help" then (
        let open Verbose_bot.Ctx in

        let keyboard = KB.inline [
          [KB.callback ~text:"← Back" ~data:"menu:main"];
        ] in

        match edit ~keyboard ctx "❓ Help\n\nCommands:\n/start - Main menu\n/settings - Settings" with
        | Ok _ -> Ok ()
        | Error e -> Eio.traceln "[menu:help] Error: %a" Error.pp e; Ok ()
      ) else Ok ()
    )

  |> Verbose_bot.run
