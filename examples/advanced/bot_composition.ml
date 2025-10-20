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

(* Configure verbose logging with flo *)
let () = Flo.set_level Severity.Debug

module KB = Keyboard

(** Feature flags module *)
module FeatureFlags = struct
  let is_enabled flag =
    match Sys.getenv_opt ("ENABLE_" ^ String.uppercase_ascii flag) with
    | Some "true" ->
        Flo.debugf "[FeatureFlags] %s is ENABLED" flag;
        true
    | _ ->
        Flo.debugf "[FeatureFlags] %s is DISABLED" flag;
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
    let open Bot.Ctx in
    match user ctx with
    | Some u when is_admin u.id ->
        Flo.debugf "[AdminAuth] Access granted to user %s"
          (Option.value u.username ~default:"<unknown>");
        handler ctx
    | Some u ->
        Flo.debugf "[AdminAuth] Access denied to user %s"
          (Option.value u.username ~default:"<unknown>");
        (match reply ctx "❌ Admin access required." with
         | Ok _ -> Ok ()
         | Error e -> Flo.debugf "[AdminAuth] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ())
    | None ->
        Flo.debug "[AdminAuth] No user in context";
        Ok ()
end

(** User Commands Module *)
module UserCommands = struct
  let build bot =
    Flo.debug "[UserCommands] Building user commands module";

    bot
    |> Bot.command "profile" ~desc:"View your profile" (fun ctx _args ->
        let open Bot.Ctx in
        Flo.debug "[UserCommands] /profile command";

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
        | Ok _ -> Flo.debug "[UserCommands] /profile ✓"; Ok ()
        | Error e -> Flo.debugf "[UserCommands] /profile ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
      )

    |> Bot.command "settings" ~desc:"Manage settings" (fun ctx _args ->
        let open Bot.Ctx in
        Flo.debug "[UserCommands] /settings command";

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
        | Ok _ -> Flo.debug "[UserCommands] /settings ✓"; Ok ()
        | Error e -> Flo.debugf "[UserCommands] /settings ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
      )
end

(** Admin Commands Module *)
module AdminCommands = struct
  let build bot =
    Flo.debug "[AdminCommands] Building admin commands module";

    bot
    |> Bot.command "admin_stats" ~desc:"Admin statistics" (fun ctx _args ->
        AdminAuth.require_admin ctx (fun ctx ->
          let open Bot.Ctx in
          Flo.debug "[AdminCommands] /admin_stats command";

          let text =
            "📊 <b>Admin Statistics</b>\n\n\
             Users: 42\n\
             Messages: 1337\n\
             Uptime: 24h\n\n\
             This is from the Admin Commands module."
          in

          match reply ctx text with
          | Ok _ -> Flo.debug "[AdminCommands] /admin_stats ✓"; Ok ()
          | Error e -> Flo.debugf "[AdminCommands] /admin_stats ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
        )
      )

    |> Bot.command "broadcast_test" ~desc:"Test broadcast" (fun ctx _args ->
        AdminAuth.require_admin ctx (fun ctx ->
          let open Bot.Ctx in
          Flo.debug "[AdminCommands] /broadcast_test command";

          let text =
            "📢 <b>Broadcast Test</b>\n\n\
             This would send a message to all users.\n\n\
             This is from the Admin Commands module."
          in

          match reply ctx text with
          | Ok _ -> Flo.debug "[AdminCommands] /broadcast_test ✓"; Ok ()
          | Error e -> Flo.debugf "[AdminCommands] /broadcast_test ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
        )
      )
end

(** Help Module *)
module HelpCommands = struct
  let build bot =
    Flo.debug "[HelpCommands] Building help commands module";

    bot
    |> Bot.command "help" ~desc:"Show help" (fun ctx _args ->
        let open Bot.Ctx in
        Flo.debug "[HelpCommands] /help command";

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
        | Ok _ -> Flo.debug "[HelpCommands] /help ✓"; Ok ()
        | Error e -> Flo.debugf "[HelpCommands] /help ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
      )

    |> Bot.command "about" ~desc:"About this bot" (fun ctx _args ->
        let open Bot.Ctx in
        Flo.debug "[HelpCommands] /about command";

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
        | Ok _ -> Flo.debug "[HelpCommands] /about ✓"; Ok ()
        | Error e -> Flo.debugf "[HelpCommands] /about ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
      )
end

(** Games Module (can be disabled via feature flag) *)
module GamesCommands = struct
  let build bot =
    if not (FeatureFlags.games_enabled ()) then (
      Flo.debug "[GamesCommands] Module DISABLED (ENABLE_GAMES not set)";
      bot
    ) else (
      Flo.debug "[GamesCommands] Building games commands module";

      bot
      |> Bot.command "roll_dice" ~desc:"Roll a dice" (fun ctx _args ->
          let open Bot.Ctx in
          Flo.debug "[GamesCommands] /roll_dice command";

          let result = Random.int 6 + 1 in

          let text = Printf.sprintf
            "🎲 You rolled a %d!\n\n\
             This is from the Games Commands module."
            result
          in

          match reply ctx text with
          | Ok _ -> Flo.debug "[GamesCommands] /roll_dice ✓"; Ok ()
          | Error e -> Flo.debugf "[GamesCommands] /roll_dice ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
        )

      |> Bot.command "flip_coin" ~desc:"Flip a coin" (fun ctx _args ->
          let open Bot.Ctx in
          Flo.debug "[GamesCommands] /flip_coin command";

          let result = if Random.bool () then "Heads" else "Tails" in

          let text = Printf.sprintf
            "🪙 %s!\n\n\
             This is from the Games Commands module."
            result
          in

          match reply ctx text with
          | Ok _ -> Flo.debug "[GamesCommands] /flip_coin ✓"; Ok ()
          | Error e -> Flo.debugf "[GamesCommands] /flip_coin ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
        )
    )
end

(** Utils Module *)
module UtilsCommands = struct
  let build bot =
    Flo.debug "[UtilsCommands] Building utils commands module";

    bot
    |> Bot.command "time" ~desc:"Show current time" (fun ctx _args ->
        let open Bot.Ctx in
        Flo.debug "[UtilsCommands] /time command";

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
        | Ok _ -> Flo.debug "[UtilsCommands] /time ✓"; Ok ()
        | Error e -> Flo.debugf "[UtilsCommands] /time ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
      )

    |> Bot.command "ping" ~desc:"Ping pong" (fun ctx _args ->
        let open Bot.Ctx in
        Flo.debug "[UtilsCommands] /ping command";

        match reply ctx "🏓 Pong!\n\nThis is from the Utils Commands module." with
        | Ok _ -> Flo.debug "[UtilsCommands] /ping ✓"; Ok ()
        | Error e -> Flo.debugf "[UtilsCommands] /ping ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
      )
end

let () =
  Printexc.record_backtrace true;
  Random.self_init ();
  Flo.info "=== Bot Composition Demo Starting ===";

  let token = match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None -> Printf.eprintf "TELEGRAM_BOT_TOKEN not set\n"; exit 1
  in

  Eio_main.run @@ fun env ->
  let client = Client.create ~env ~token () in

  Flo.info "🤖 Bot Composition Demo Bot Started";
  Flo.debug "";
  Flo.info "=== Module Configuration ===";
  Flo.debugf "Games module: %s" (if FeatureFlags.games_enabled () then "ENABLED" else "DISABLED");
  Flo.debugf "Admin users: %d configured" (List.length (AdminAuth.admin_user_ids ()));
  Flo.debug "";

  let session_store = Session.Memory_store.create () in

  (* Build bot by composing modules using builder pattern *)
  Flo.info "=== Building Bot via Composition ===";

  let bot =
    Bot.make ~env ~client
    |> Bot.with_sessions (module Session.Memory_store) session_store

    (* /start - Main entry point *)
    |> Bot.command "start" ~desc:"Show main menu" (fun ctx _args ->
        let open Bot.Ctx in
        Flo.debug "[Main] /start command";

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
        | Ok _ -> Flo.debug "[Main] /start ✓"; Ok ()
        | Error e -> Flo.debugf "[Main] /start ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
      )

    (* /modules - List all modules *)
    |> Bot.command "modules" ~desc:"List bot modules" (fun ctx _args ->
        let open Bot.Ctx in
        Flo.debug "[Main] /modules command";

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
        | Ok _ -> Flo.debug "[Main] /modules ✓"; Ok ()
        | Error e -> Flo.debugf "[Main] /modules ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
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
    |> Bot.on_callback_data "setting:notifications" (fun ctx ->
        let open Bot.Ctx in
        Flo.debug "[UserCommands] Notifications callback";

        match edit ctx "🔔 Notification settings\n\n(Demo - not implemented)" with
        | Ok () -> Ok ()
        | Error e -> Flo.debugf "[UserCommands] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
      )

    |> Bot.on_callback_data "setting:language" (fun ctx ->
        let open Bot.Ctx in
        Flo.debug "[UserCommands] Language callback";

        match edit ctx "🌐 Language settings\n\n(Demo - not implemented)" with
        | Ok () -> Ok ()
        | Error e -> Flo.debugf "[UserCommands] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
      )
  in

  Flo.debug "";
  Flo.info "=== Bot Composition Complete ===";
  Flo.debug "Starting polling...";
  Flo.debug "";

  Bot.run bot
