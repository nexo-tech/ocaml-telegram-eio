(** Bot Composition Demo - Comprehensive demonstration of bot composition patterns

    This example demonstrates bot composition techniques:
    - Modular route design (feature modules)
    - Plugin architecture with enable/disable
    - Bot merging and composition
    - Scope-based organization
    - Feature flags
    - Builder pattern composition

    Features:
      - User Commands Module (/profile, /settings)
      - Admin Commands Module (/admin_stats, /broadcast_test)
      - Help Module (/help, /about)
      - Games Module (/roll_dice, /flip_coin) - can be disabled
      - Utils Module (/time, /ping)

    Commands:
      /start - Show main menu
      /profile - User profile (User module)
      /settings - User settings (User module)
      /admin_stats - Admin statistics (Admin module, admin-only)
      /broadcast_test - Test broadcast (Admin module, admin-only)
      /help - Show help (Help module)
      /about - About the bot (Help module)
      /roll_dice - Roll a dice (Games module, feature flag)
      /flip_coin - Flip a coin (Games module, feature flag)
      /time - Show current time (Utils module)
      /ping - Ping pong (Utils module)
      /modules - List all modules

    Environment Variables:
      ADMIN_USER_IDS - Comma-separated admin user IDs (e.g., "123456,789012")
      ENABLE_GAMES - Set to "true" to enable games module

    This example has VERBOSE LOGGING enabled for troubleshooting.

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      export ADMIN_USER_IDS="your_user_id"
      export ENABLE_GAMES="true"
      dune exec examples/bot_composition_demo.exe
*)

open Telegram
open Tg

(* Configure verbose logging via functor composition *)
module Verbose_log = Log.Make (Log.Console) (struct
  let src = "BotComposition"
  let level = Log.Debug
end)

module Verbose_session = Session.Make (Verbose_log)
module Verbose_polling = Polling.Make (Verbose_log)
module Verbose_bot = Bot.Make (Verbose_log) (Verbose_session) (Verbose_polling)

module KB = Keyboard

(** Feature flags module *)
module FeatureFlags = struct
  let is_enabled flag =
    match Sys.getenv_opt ("ENABLE_" ^ String.uppercase_ascii flag) with
    | Some "true" ->
        Eio.traceln "[FeatureFlags] %s is ENABLED" flag;
        true
    | _ ->
        Eio.traceln "[FeatureFlags] %s is DISABLED" flag;
        false

  let games_enabled () = is_enabled "games"
end

(** Admin authorization *)
module AdminAuth = struct
  let admin_user_ids () =
    match Sys.getenv_opt "ADMIN_USER_IDS" with
    | Some ids ->
        String.split_on_char ',' ids
        |> List.filter_map (fun s ->
            match Int64.of_string_opt (String.trim s) with
            | Some id -> Some (Id.User.of_int id)
            | None -> None)
    | None -> []

  let is_admin user_id =
    let admins = admin_user_ids () in
    let user_id_str = Id.to_string user_id in
    List.exists (fun admin_id ->
      Id.to_string admin_id = user_id_str
    ) admins

  let require_admin ctx handler =
    let open Verbose_bot.Ctx in
    match user ctx with
    | Some u when is_admin u.id ->
        Eio.traceln "[AdminAuth] Access granted to user %s"
          (Option.value u.username ~default:"<unknown>");
        handler ctx
    | Some u ->
        Eio.traceln "[AdminAuth] Access denied to user %s"
          (Option.value u.username ~default:"<unknown>");
        (match reply ctx "❌ Admin access required." with
         | Ok _ -> Ok ()
         | Error e -> Eio.traceln "[AdminAuth] ✗ %a" Error.pp e; Ok ())
    | None ->
        Eio.traceln "[AdminAuth] No user in context";
        Ok ()
end

(** User Commands Module *)
module UserCommands = struct
  let build bot =
    Eio.traceln "[UserCommands] Building user commands module";

    bot
    |> Verbose_bot.command "profile" ~desc:"View your profile" (fun ctx _args ->
        let open Verbose_bot.Ctx in
        Eio.traceln "[UserCommands] /profile command";

        let user_opt = user ctx in
        let username = match user_opt with
          | Some u -> Option.value u.username ~default:"<no username>"
          | None -> "Unknown"
        in

        let text = Printf.sprintf
          "👤 <b>Your Profile</b>\n\n\
           Username: %s\n\n\
           This is from the User Commands module."
          username
        in

        match reply ctx text with
        | Ok _ -> Eio.traceln "[UserCommands] /profile ✓"; Ok ()
        | Error e -> Eio.traceln "[UserCommands] /profile ✗ %a" Error.pp e; Ok ()
      )

    |> Verbose_bot.command "settings" ~desc:"Manage settings" (fun ctx _args ->
        let open Verbose_bot.Ctx in
        Eio.traceln "[UserCommands] /settings command";

        let keyboard = KB.inline [
          [KB.callback ~text:"🔔 Notifications" ~data:"setting:notifications"];
          [KB.callback ~text:"🌐 Language" ~data:"setting:language"];
        ] in

        let text =
          "⚙️ <b>Settings</b>\n\n\
           Configure your preferences.\n\n\
           This is from the User Commands module."
        in

        match send ~keyboard ctx text with
        | Ok _ -> Eio.traceln "[UserCommands] /settings ✓"; Ok ()
        | Error e -> Eio.traceln "[UserCommands] /settings ✗ %a" Error.pp e; Ok ()
      )
end

(** Admin Commands Module *)
module AdminCommands = struct
  let build bot =
    Eio.traceln "[AdminCommands] Building admin commands module";

    bot
    |> Verbose_bot.command "admin_stats" ~desc:"Admin statistics" (fun ctx _args ->
        AdminAuth.require_admin ctx (fun ctx ->
          let open Verbose_bot.Ctx in
          Eio.traceln "[AdminCommands] /admin_stats command";

          let text =
            "📊 <b>Admin Statistics</b>\n\n\
             Users: 42\n\
             Messages: 1337\n\
             Uptime: 24h\n\n\
             This is from the Admin Commands module."
          in

          match reply ctx text with
          | Ok _ -> Eio.traceln "[AdminCommands] /admin_stats ✓"; Ok ()
          | Error e -> Eio.traceln "[AdminCommands] /admin_stats ✗ %a" Error.pp e; Ok ()
        )
      )

    |> Verbose_bot.command "broadcast_test" ~desc:"Test broadcast" (fun ctx _args ->
        AdminAuth.require_admin ctx (fun ctx ->
          let open Verbose_bot.Ctx in
          Eio.traceln "[AdminCommands] /broadcast_test command";

          let text =
            "📢 <b>Broadcast Test</b>\n\n\
             This would send a message to all users.\n\n\
             This is from the Admin Commands module."
          in

          match reply ctx text with
          | Ok _ -> Eio.traceln "[AdminCommands] /broadcast_test ✓"; Ok ()
          | Error e -> Eio.traceln "[AdminCommands] /broadcast_test ✗ %a" Error.pp e; Ok ()
        )
      )
end

(** Help Module *)
module HelpCommands = struct
  let build bot =
    Eio.traceln "[HelpCommands] Building help commands module";

    bot
    |> Verbose_bot.command "help" ~desc:"Show help" (fun ctx _args ->
        let open Verbose_bot.Ctx in
        Eio.traceln "[HelpCommands] /help command";

        let text =
          "📚 <b>Help</b>\n\n\
           <b>User Commands:</b>\n\
           /profile - View profile\n\
           /settings - Settings\n\n\
           <b>Admin Commands:</b>\n\
           /admin_stats - Statistics\n\
           /broadcast_test - Broadcast\n\n\
           <b>Games:</b>\n\
           /roll_dice - Roll dice\n\
           /flip_coin - Flip coin\n\n\
           <b>Utils:</b>\n\
           /time - Current time\n\
           /ping - Ping pong\n\n\
           This is from the Help Commands module."
        in

        match reply ctx text with
        | Ok _ -> Eio.traceln "[HelpCommands] /help ✓"; Ok ()
        | Error e -> Eio.traceln "[HelpCommands] /help ✗ %a" Error.pp e; Ok ()
      )

    |> Verbose_bot.command "about" ~desc:"About this bot" (fun ctx _args ->
        let open Verbose_bot.Ctx in
        Eio.traceln "[HelpCommands] /about command";

        let text =
          "ℹ️ <b>About</b>\n\n\
           This bot demonstrates composition patterns:\n\
           • Modular route design\n\
           • Feature flags\n\
           • Admin authorization\n\
           • Builder pattern\n\n\
           This is from the Help Commands module."
        in

        match reply ctx text with
        | Ok _ -> Eio.traceln "[HelpCommands] /about ✓"; Ok ()
        | Error e -> Eio.traceln "[HelpCommands] /about ✗ %a" Error.pp e; Ok ()
      )
end

(** Games Module (can be disabled via feature flag) *)
module GamesCommands = struct
  let build bot =
    if not (FeatureFlags.games_enabled ()) then (
      Eio.traceln "[GamesCommands] Module DISABLED (ENABLE_GAMES not set)";
      bot
    ) else (
      Eio.traceln "[GamesCommands] Building games commands module";

      bot
      |> Verbose_bot.command "roll_dice" ~desc:"Roll a dice" (fun ctx _args ->
          let open Verbose_bot.Ctx in
          Eio.traceln "[GamesCommands] /roll_dice command";

          let result = Random.int 6 + 1 in

          let text = Printf.sprintf
            "🎲 You rolled a %d!\n\n\
             This is from the Games Commands module."
            result
          in

          match reply ctx text with
          | Ok _ -> Eio.traceln "[GamesCommands] /roll_dice ✓"; Ok ()
          | Error e -> Eio.traceln "[GamesCommands] /roll_dice ✗ %a" Error.pp e; Ok ()
        )

      |> Verbose_bot.command "flip_coin" ~desc:"Flip a coin" (fun ctx _args ->
          let open Verbose_bot.Ctx in
          Eio.traceln "[GamesCommands] /flip_coin command";

          let result = if Random.bool () then "Heads" else "Tails" in

          let text = Printf.sprintf
            "🪙 %s!\n\n\
             This is from the Games Commands module."
            result
          in

          match reply ctx text with
          | Ok _ -> Eio.traceln "[GamesCommands] /flip_coin ✓"; Ok ()
          | Error e -> Eio.traceln "[GamesCommands] /flip_coin ✗ %a" Error.pp e; Ok ()
        )
    )
end

(** Utils Module *)
module UtilsCommands = struct
  let build bot =
    Eio.traceln "[UtilsCommands] Building utils commands module";

    bot
    |> Verbose_bot.command "time" ~desc:"Show current time" (fun ctx _args ->
        let open Verbose_bot.Ctx in
        Eio.traceln "[UtilsCommands] /time command";

        let time = Unix.time () |> int_of_float in
        let tm = Unix.localtime (Unix.time ()) in

        let text = Printf.sprintf
          "🕐 <b>Current Time</b>\n\n\
           Unix timestamp: %d\n\
           Local: %02d:%02d:%02d\n\n\
           This is from the Utils Commands module."
          time
          tm.tm_hour tm.tm_min tm.tm_sec
        in

        match reply ctx text with
        | Ok _ -> Eio.traceln "[UtilsCommands] /time ✓"; Ok ()
        | Error e -> Eio.traceln "[UtilsCommands] /time ✗ %a" Error.pp e; Ok ()
      )

    |> Verbose_bot.command "ping" ~desc:"Ping pong" (fun ctx _args ->
        let open Verbose_bot.Ctx in
        Eio.traceln "[UtilsCommands] /ping command";

        match reply ctx "🏓 Pong!\n\nThis is from the Utils Commands module." with
        | Ok _ -> Eio.traceln "[UtilsCommands] /ping ✓"; Ok ()
        | Error e -> Eio.traceln "[UtilsCommands] /ping ✗ %a" Error.pp e; Ok ()
      )
end

let () =
  Printexc.record_backtrace true;
  Random.self_init ();
  Eio.traceln "=== Bot Composition Demo Starting ===";

  let token = match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None -> Printf.eprintf "TELEGRAM_BOT_TOKEN not set\n"; exit 1
  in

  Eio_main.run @@ fun env ->
  let client = Client.create ~env ~token () in

  Eio.traceln "🤖 Bot Composition Demo Bot Started";
  Eio.traceln "";
  Eio.traceln "=== Module Configuration ===";
  Eio.traceln "Games module: %s" (if FeatureFlags.games_enabled () then "ENABLED" else "DISABLED");
  Eio.traceln "Admin users: %d configured" (List.length (AdminAuth.admin_user_ids ()));
  Eio.traceln "";

  let session_store = Verbose_session.Memory_store.create () in

  (* Build bot by composing modules using builder pattern *)
  Eio.traceln "=== Building Bot via Composition ===";

  let bot =
    Verbose_bot.make ~env ~client
    |> Verbose_bot.with_sessions (module Verbose_session.Memory_store) session_store

    (* /start - Main entry point *)
    |> Verbose_bot.command "start" ~desc:"Show main menu" (fun ctx _args ->
        let open Verbose_bot.Ctx in
        Eio.traceln "[Main] /start command";

        let games_status = if FeatureFlags.games_enabled () then
          "✅ Enabled"
        else
          "❌ Disabled (set ENABLE_GAMES=true)"
        in

        let text = Printf.sprintf
          "🤖 <b>Bot Composition Demo</b>\n\n\
           This bot is built from multiple modules:\n\n\
           📦 <b>Active Modules:</b>\n\
           • User Commands (/profile, /settings)\n\
           • Admin Commands (/admin_stats, /broadcast_test)\n\
           • Help Module (/help, /about)\n\
           • Games Module (%s)\n\
           • Utils Module (/time, /ping)\n\n\
           Try /modules to see module details.\n\
           Try /help for all commands."
          games_status
        in

        match reply ctx text with
        | Ok _ -> Eio.traceln "[Main] /start ✓"; Ok ()
        | Error e -> Eio.traceln "[Main] /start ✗ %a" Error.pp e; Ok ()
      )

    (* /modules - List all modules *)
    |> Verbose_bot.command "modules" ~desc:"List bot modules" (fun ctx _args ->
        let open Verbose_bot.Ctx in
        Eio.traceln "[Main] /modules command";

        let modules = [
          ("User Commands", "Always enabled", true);
          ("Admin Commands", "Always enabled", true);
          ("Help Module", "Always enabled", true);
          ("Games Module", "Feature flag: ENABLE_GAMES", FeatureFlags.games_enabled ());
          ("Utils Module", "Always enabled", true);
        ] in

        let module_lines = List.map (fun (name, desc, enabled) ->
          let status = if enabled then "✅" else "❌" in
          Printf.sprintf "%s <b>%s</b>\n   %s" status name desc
        ) modules |> String.concat "\n\n" in

        let text = Printf.sprintf
          "📦 <b>Bot Modules</b>\n\n\
           %s\n\n\
           This demonstrates modular bot architecture."
          module_lines
        in

        match reply ctx text with
        | Ok _ -> Eio.traceln "[Main] /modules ✓"; Ok ()
        | Error e -> Eio.traceln "[Main] /modules ✗ %a" Error.pp e; Ok ()
      )

    (* Compose User Commands module *)
    |> UserCommands.build

    (* Compose Admin Commands module *)
    |> AdminCommands.build

    (* Compose Help module *)
    |> HelpCommands.build

    (* Compose Games module (conditional) *)
    |> GamesCommands.build

    (* Compose Utils module *)
    |> UtilsCommands.build

    (* Settings callbacks *)
    |> Verbose_bot.on_callback_data "setting:notifications" (fun ctx ->
        let open Verbose_bot.Ctx in
        Eio.traceln "[UserCommands] Notifications callback";

        match edit ctx "🔔 Notification settings\n\n(Demo - not implemented)" with
        | Ok () -> Ok ()
        | Error e -> Eio.traceln "[UserCommands] ✗ %a" Error.pp e; Ok ()
      )

    |> Verbose_bot.on_callback_data "setting:language" (fun ctx ->
        let open Verbose_bot.Ctx in
        Eio.traceln "[UserCommands] Language callback";

        match edit ctx "🌐 Language settings\n\n(Demo - not implemented)" with
        | Ok () -> Ok ()
        | Error e -> Eio.traceln "[UserCommands] ✗ %a" Error.pp e; Ok ()
      )
  in

  Eio.traceln "";
  Eio.traceln "=== Bot Composition Complete ===";
  Eio.traceln "Starting polling...";
  Eio.traceln "";

  Verbose_bot.run bot
