[@@@warning "-69"] (* Allow unused record fields *)

(** Recipe: Command Bot with Help System and Admin Commands

    This example demonstrates command bot patterns from recipe_command_bot.mld:
    - Command registry for auto-generated help
    - Command aliases (e.g., /h for /help)
    - Admin-only commands with permission checks
    - Structured argument parsing and validation
    - Command statistics tracking
    - User feedback and error messages

    This example has VERBOSE LOGGING enabled to help troubleshoot issues.
    Every step is logged using the flo library with structured fields.

    Commands:
      /start - Welcome message
      /help [command] - Show all commands or specific command help
      /h - Alias for /help
      /echo <text> - Echo back text
      /e <text> - Alias for /echo
      /time - Show current UTC time
      /calc <a> <op> <b> - Calculator (e.g., /calc 5 + 3)
      /about - About this bot
      /stats - Show bot statistics (admin only)
      /broadcast <msg> - Send message to all users (admin only)

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      export ADMIN_USER_IDS="123456789,987654321"  # Optional
      dune exec examples/recipe_command_bot.exe

    What you'll see in the logs:
      - Command registry initialization
      - Admin list loading
      - Route registration for each command
      - Help text generation
      - Admin permission checks
      - Argument parsing and validation
      - Command execution tracking
*)

open Telegram
open Tg

(* Configure verbose logging with flo *)
let () = Flo.set_level Severity.Debug

(** Command registry for auto-generated help *)
module Command_registry = struct
  type command_info = {
    name : string;
    aliases : string list;
    description : string;
    usage : string;
    category : string;
    admin_only : bool;
  }

  let commands : command_info list ref = ref []

  let register cmd =
    Flo.debug_fields "Registering command" ~fields:[
      ("command", Value.string cmd.name);
      ("aliases", Value.string (String.concat ", " cmd.aliases));
      ("admin_only", Value.bool cmd.admin_only);
    ];
    commands := cmd :: !commands

  let find_command name =
    List.find_opt (fun cmd ->
      cmd.name = name || List.mem name cmd.aliases
    ) !commands

  let get_user_commands () =
    List.filter (fun cmd -> not cmd.admin_only) !commands

  let get_admin_commands () =
    List.filter (fun cmd -> cmd.admin_only) !commands

  let format_command cmd =
    let aliases =
      if cmd.aliases = [] then ""
      else " (aliases: /" ^ String.concat ", /" cmd.aliases ^ ")"
    in
    Printf.sprintf "/%s%s\n%s\n\nUsage: %s"
      cmd.name aliases cmd.description cmd.usage

  let format_help_text ~is_admin () =
    Flo.debugf "[Registry] Generating help text (admin=%b)" is_admin;
    let user_cmds = get_user_commands () in
    let admin_cmds = if is_admin then get_admin_commands () else [] in

    Flo.debugf "[Registry] User commands: %d, Admin commands: %d"
      (List.length user_cmds) (List.length admin_cmds);

    let format_section title cmds =
      if cmds = [] then ""
      else
        title ^ ":\n\n" ^
        (cmds
         |> List.map (fun cmd -> Printf.sprintf "/%s - %s" cmd.name cmd.description)
         |> String.concat "\n")
    in

    let sections = [
      format_section "📖 Available Commands" user_cmds;
      format_section "🔧 Admin Commands" admin_cmds;
    ] in

    String.concat "\n\n" (List.filter (fun s -> s <> "") sections)
end

(** Admin permission management *)
module Admin = struct
  let admin_users : string list ref = ref []

  let load_from_env () =
    match Sys.getenv_opt "ADMIN_USER_IDS" with
    | Some ids_str ->
        let ids = String.split_on_char ',' ids_str
                  |> List.map String.trim
                  |> List.filter (fun s -> s <> "") in
        admin_users := ids;
        Flo.debugf "[Admin] Loaded %d admin user IDs from ADMIN_USER_IDS" (List.length ids);
        List.iter (fun id -> Flo.debugf "[Admin]   - %s" id) ids
    | None ->
        Flo.debug "[Admin] No ADMIN_USER_IDS set, no admins configured";
        Flo.debug "[Admin] Set ADMIN_USER_IDS=123456789,987654321 to configure admins"

  let is_admin user_id_str =
    let result = List.mem user_id_str !admin_users in
    Flo.debugf "[Admin] Permission check: user_id=%s, is_admin=%b" user_id_str result;
    result

  let require_admin handler =
    fun ctx args ->
      Flo.debug "[Admin] Checking admin permission...";
      match Bot.Ctx.user ctx with
      | Some user ->
          let user_id_str = Id.to_string user.id in
          if is_admin user_id_str then (
            Flo.debugf "[Admin] ✓ User %s is admin, allowing access" user_id_str;
            handler ctx args
          ) else (
            Flo.errorf "[Admin] ✗ User %s is not admin, denying access" user_id_str;
            let open Bot.Ctx in
            let* () = reply_ ctx "⛔ This command requires administrator privileges." in
            Ok ()
          )
      | None ->
          Flo.error "[Admin] ✗ No user info available";
          let open Bot.Ctx in
          let* () = reply_ ctx "⛔ User information not available." in
          Ok ()
end

(** Calculator logic with structured argument parsing *)
module Calculator = struct
  type operation =
    | Add of float * float
    | Subtract of float * float
    | Multiply of float * float
    | Divide of float * float

  let parse_args args =
    Flo.debugf "[Calc] Parsing args: %s" (String.concat " " args);
    match args with
    | [a; op; b] ->
        Flo.debugf "[Calc] Got 3 args: a='%s', op='%s', b='%s'" a op b;
        (match Float.of_string_opt a, Float.of_string_opt b with
         | Some x, Some y ->
             Flo.debugf "[Calc] Parsed floats: x=%f, y=%f" x y;
             (match op with
              | "+" -> Ok (Add (x, y))
              | "-" -> Ok (Subtract (x, y))
              | "*" | "x" -> Ok (Multiply (x, y))
              | "/" ->
                  if y = 0.0 then (
                    Flo.error "[Calc] ✗ Division by zero";
                    Error "Division by zero"
                  ) else
                    Ok (Divide (x, y))
              | _ ->
                  Flo.errorf "[Calc] ✗ Invalid operator: '%s'" op;
                  Error "Invalid operator. Use: +, -, *, /")
         | None, _ ->
             Flo.errorf "[Calc] ✗ First argument is not a number: '%s'" a;
             Error "First argument must be a number"
         | _, None ->
             Flo.errorf "[Calc] ✗ Second argument is not a number: '%s'" b;
             Error "Second argument must be a number")
    | _ ->
        Flo.errorf "[Calc] ✗ Expected 3 args, got %d" (List.length args);
        Error "Usage: /calc <number> <operator> <number>\nExample: /calc 5 + 3"

  let execute = function
    | Add (a, b) -> a +. b
    | Subtract (a, b) -> a -. b
    | Multiply (a, b) -> a *. b
    | Divide (a, b) -> a /. b

  let format_result op =
    match op with
    | Add (a, b) -> Printf.sprintf "%.2f + %.2f = %.2f" a b (execute op)
    | Subtract (a, b) -> Printf.sprintf "%.2f - %.2f = %.2f" a b (execute op)
    | Multiply (a, b) -> Printf.sprintf "%.2f × %.2f = %.2f" a b (execute op)
    | Divide (a, b) -> Printf.sprintf "%.2f ÷ %.2f = %.2f" a b (execute op)
end

(** Bot state for statistics *)
module Bot_state = struct
  type t = {
    mutable total_commands : int;
    mutable unique_users : (string, unit) Hashtbl.t;
    start_time : float;
  }

  let create () = {
    total_commands = 0;
    unique_users = Hashtbl.create 100;
    start_time = Unix.gettimeofday ();
  }

  let track_command state user_id_str =
    state.total_commands <- state.total_commands + 1;
    if not (Hashtbl.mem state.unique_users user_id_str) then
      Hashtbl.add state.unique_users user_id_str ();
    Flo.debugf "[Stats] Command tracked: total=%d, unique_users=%d"
      state.total_commands (Hashtbl.length state.unique_users)

  let get_stats state =
    let uptime = Unix.gettimeofday () -. state.start_time in
    (state.total_commands, Hashtbl.length state.unique_users, uptime)

  let format_uptime seconds =
    let hours = int_of_float (seconds /. 3600.0) in
    let minutes = int_of_float ((mod_float seconds 3600.0) /. 60.0) in
    Printf.sprintf "%dh %dm" hours minutes
end

let () =
  Flo.info "=== Recipe: Command Bot Starting ===";
  Flo.info "[Init] Loading configuration...";

  let token =
    match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t ->
        Flo.info "[Init] ✓ Bot token loaded from TELEGRAM_BOT_TOKEN";
        Flo.infof "[Init]   Token: %s...%s (length=%d)"
          (String.sub t 0 (min 8 (String.length t)))
          (if String.length t > 8 then String.sub t (String.length t - 4) 4 else "")
          (String.length t);
        t
    | None ->
        Flo.info "[Init] ✗ TELEGRAM_BOT_TOKEN environment variable not set";
        Printf.eprintf "Error: TELEGRAM_BOT_TOKEN not set\n";
        exit 1
  in

  (* Load admin users from environment *)
  Flo.info "[Init] Loading admin configuration...";
  Admin.load_from_env ();

  Flo.info "[Init] Starting Eio event loop...";
  Eio_main.run @@ fun env ->

  Flo.info "[Init] Creating Telegram HTTP client...";
  let client = Client.create ~env ~token () in
  Flo.infof "[Init] ✓ HTTP client created (base_url=%s)" (Client.base_url client);

  (* Initialize bot state *)
  let state = Bot_state.create () in
  Flo.info "[Init] Bot state initialized";

  (* Register commands in the registry *)
  Flo.debug "";
  Flo.debug "[Registry] Registering commands...";
  Command_registry.register {
    name = "start";
    aliases = [];
    description = "Get started with the bot";
    usage = "/start";
    category = "general";
    admin_only = false;
  };
  Command_registry.register {
    name = "help";
    aliases = ["h"];
    description = "Show all commands or get help for a specific command";
    usage = "/help [command]";
    category = "general";
    admin_only = false;
  };
  Command_registry.register {
    name = "echo";
    aliases = ["e"];
    description = "Echo back your message";
    usage = "/echo <text>";
    category = "utility";
    admin_only = false;
  };
  Command_registry.register {
    name = "time";
    aliases = [];
    description = "Show current UTC time";
    usage = "/time";
    category = "utility";
    admin_only = false;
  };
  Command_registry.register {
    name = "calc";
    aliases = [];
    description = "Calculate mathematical expression";
    usage = "/calc <number> <op> <number>";
    category = "utility";
    admin_only = false;
  };
  Command_registry.register {
    name = "about";
    aliases = ["info"];
    description = "About this bot";
    usage = "/about";
    category = "general";
    admin_only = false;
  };
  Command_registry.register {
    name = "stats";
    aliases = [];
    description = "Show bot statistics (admin only)";
    usage = "/stats";
    category = "admin";
    admin_only = true;
  };
  Command_registry.register {
    name = "broadcast";
    aliases = [];
    description = "Broadcast message to all users (admin only)";
    usage = "/broadcast <message>";
    category = "admin";
    admin_only = true;
  };

  Flo.debugf "[Registry] ✓ Registered %d commands" (List.length !Command_registry.commands);
  Flo.debug "";

  Flo.info "🤖 Command Bot Started!";
  Flo.debug "";
  Flo.info "📋 Features:";
  Flo.debugf "   • %d registered commands" (List.length !Command_registry.commands);
  Flo.debug "   • Auto-generated help system";
  Flo.debug "   • Command aliases (/h, /e)";
  Flo.debugf "   • Admin commands (%d admins configured)" (List.length !Admin.admin_users);
  Flo.debug "   • Argument parsing and validation";
  Flo.debug "   • Statistics tracking";
  Flo.debug "";
  Flo.debug "🔍 Watching for updates (long polling)...";
  Flo.debug "";

  (* Build bot using functional builder pattern *)
  Flo.debug "[Builder] Building bot with functional API...";
  Bot.make ~env ~client
  (* Add global error handler *)
  |> Bot.on_error (fun ctx exn ->
      Flo.debug "";
      Flo.error "[Error] ❌❌❌ Uncaught error in handler ❌❌❌";
      Flo.errorf "[Error] Error: %s" (Printexc.to_string exn);
      match Bot.Ctx.reply ctx "❌ Sorry, an error occurred. Please try again." with
      | Ok _ -> Flo.error "[Error] ✓ Error notification sent"
      | Error e -> Flo.errorf "[Error] ✗ Failed to send error: %s" (Format.asprintf "%a" Error.pp e);
      Flo.debug "";
    )

  (* /start command *)
  |> (fun bot -> Flo.debug "[Builder] Registering route: command 'start'"; bot)
  |> Bot.command "start" ~desc:"Get started" (fun ctx _args ->
      Flo.debug "";
      Flo.debug "[Handler:start] >>> /start command";
      (* Track command *)
      (match Bot.Ctx.user ctx with
       | Some u -> Bot_state.track_command state (Id.to_string u.id)
       | None -> ());

      let open Bot.Ctx in
      let* () = reply_ ctx
        "👋 Welcome to CommandBot!\n\n\
         I'm a feature-rich bot with multiple commands.\n\
         Use /help to see what I can do.\n\n\
         Quick commands:\n\
         /echo <text> - Echo your message\n\
         /calc 5 + 3 - Calculate\n\
         /time - Current time" in
      Flo.debug "[Handler:start] <<< completed";
      Flo.debug "";
      Ok ()
    )

  (* /help command with detailed help for specific commands *)
  |> (fun bot -> Flo.debug "[Builder] Registering route: command 'help'"; bot)
  |> Bot.command "help" ~desc:"Show help" (fun ctx args ->
      Flo.debug "";
      Flo.debug "[Handler:help] >>> /help command";
      Flo.debugf "[Handler:help] Args: %s" (String.concat " " args);

      (* Track command *)
      (match Bot.Ctx.user ctx with
       | Some u -> Bot_state.track_command state (Id.to_string u.id)
       | None -> ());

      let is_admin = match Bot.Ctx.user ctx with
        | Some user -> Admin.is_admin (Id.to_string user.id)
        | None -> false
      in

      let open Bot.Ctx in
      let* () =
        match args with
        | [] ->
            Flo.debug "[Handler:help] Generating full help text";
            let help_text = Command_registry.format_help_text ~is_admin () in
            reply_ ctx help_text
        | [cmd_name] ->
            Flo.debugf "[Handler:help] Looking up command: '%s'" cmd_name;
            (match Command_registry.find_command cmd_name with
             | Some cmd ->
                 Flo.debugf "[Handler:help] ✓ Found command: %s" cmd.name;
                 reply_ ctx (Command_registry.format_command cmd)
             | None ->
                 Flo.errorf "[Handler:help] ✗ Command not found: '%s'" cmd_name;
                 reply_ ctx ("❌ Unknown command: " ^ cmd_name))
        | _ ->
            Flo.error "[Handler:help] ✗ Too many arguments";
            reply_ ctx "Usage: /help [command]"
      in
      Flo.debug "[Handler:help] <<< completed";
      Flo.debug "";
      Ok ()
    )

  (* /h alias for /help *)
  |> (fun bot -> Flo.debug "[Builder] Registering route: alias 'h' -> 'help'"; bot)
  |> Bot.command "h" ~desc:"Help alias" (fun ctx _args ->
      Flo.debug "[Alias] /h -> /help";
      (* Track command *)
      (match Bot.Ctx.user ctx with
       | Some u -> Bot_state.track_command state (Id.to_string u.id)
       | None -> ());

      let is_admin = match Bot.Ctx.user ctx with
        | Some user -> Admin.is_admin (Id.to_string user.id)
        | None -> false
      in

      let help_text = Command_registry.format_help_text ~is_admin () in
      let open Bot.Ctx in
      reply_ ctx help_text
    )

  (* /echo command *)
  |> (fun bot -> Flo.debug "[Builder] Registering route: command 'echo'"; bot)
  |> Bot.command "echo" ~desc:"Echo text" (fun ctx args ->
      Flo.debug "";
      Flo.debug "[Handler:echo] >>> /echo command";
      Flo.debugf "[Handler:echo] Args: %s" (String.concat " " args);

      (* Track command *)
      (match Bot.Ctx.user ctx with
       | Some u -> Bot_state.track_command state (Id.to_string u.id)
       | None -> ());

      let text = Bot.Args.join_rest args 0 in
      Flo.debugf "[Handler:echo] Joined text: \"%s\"" text;

      let open Bot.Ctx in
      let* () =
        if text = "" then
          reply_ ctx "Usage: /echo <text>\nExample: /echo Hello, world!"
        else
          reply_ ctx text
      in
      Flo.debug "[Handler:echo] <<< completed";
      Flo.debug "";
      Ok ()
    )

  (* /e alias for /echo *)
  |> (fun bot -> Flo.debug "[Builder] Registering route: alias 'e' -> 'echo'"; bot)
  |> Bot.command "e" ~desc:"Echo alias" (fun ctx args ->
      Flo.debug "[Alias] /e -> /echo";
      (* Track command *)
      (match Bot.Ctx.user ctx with
       | Some u -> Bot_state.track_command state (Id.to_string u.id)
       | None -> ());

      let text = Bot.Args.join_rest args 0 in
      let open Bot.Ctx in
      if text = "" then
        reply_ ctx "Usage: /e <text>"
      else
        reply_ ctx text
    )

  (* /time command *)
  |> (fun bot -> Flo.debug "[Builder] Registering route: command 'time'"; bot)
  |> Bot.command "time" ~desc:"Show current time" (fun ctx _args ->
      Flo.debug "";
      Flo.debug "[Handler:time] >>> /time command";

      (* Track command *)
      (match Bot.Ctx.user ctx with
       | Some u -> Bot_state.track_command state (Id.to_string u.id)
       | None -> ());

      let now = Unix.time () |> Unix.gmtime in
      let time_str = Printf.sprintf "⏰ %04d-%02d-%02d %02d:%02d:%02d UTC"
        (now.Unix.tm_year + 1900)
        (now.Unix.tm_mon + 1)
        now.Unix.tm_mday
        now.Unix.tm_hour
        now.Unix.tm_min
        now.Unix.tm_sec
      in
      Flo.debugf "[Handler:time] Generated time: %s" time_str;

      let open Bot.Ctx in
      let* () = reply_ ctx time_str in
      Flo.debug "[Handler:time] <<< completed";
      Flo.debug "";
      Ok ()
    )

  (* /calc command with structured argument parsing *)
  |> (fun bot -> Flo.debug "[Builder] Registering route: command 'calc'"; bot)
  |> Bot.command "calc" ~desc:"Calculator" (fun ctx args ->
      Flo.debug "";
      Flo.debug "[Handler:calc] >>> /calc command";
      Flo.debugf "[Handler:calc] Args: %s" (String.concat " " args);

      (* Track command *)
      (match Bot.Ctx.user ctx with
       | Some u -> Bot_state.track_command state (Id.to_string u.id)
       | None -> ());

      let open Bot.Ctx in
      let* () =
        match Calculator.parse_args args with
        | Ok operation ->
            Flo.success "[Handler:calc] ✓ Parsed operation successfully";
            let result = Calculator.format_result operation in
            Flo.debugf "[Handler:calc] Result: %s" result;
            reply_ ctx ("🔢 " ^ result)
        | Error msg ->
            Flo.errorf "[Handler:calc] ✗ Parse error: %s" msg;
            reply_ ctx ("❌ " ^ msg)
      in
      Flo.debug "[Handler:calc] <<< completed";
      Flo.debug "";
      Ok ()
    )

  (* /about command *)
  |> (fun bot -> Flo.debug "[Builder] Registering route: command 'about'"; bot)
  |> Bot.command "about" ~desc:"About bot" (fun ctx _args ->
      Flo.debug "";
      Flo.debug "[Handler:about] >>> /about command";

      (* Track command *)
      (match Bot.Ctx.user ctx with
       | Some u -> Bot_state.track_command state (Id.to_string u.id)
       | None -> ());

      let open Bot.Ctx in
      let* () = reply_ ctx
        "ℹ️ CommandBot v1.0\n\n\
         A multi-command bot demonstrating:\n\
         • Command registry and auto-help\n\
         • Command aliases\n\
         • Admin commands\n\
         • Argument parsing\n\
         • Statistics tracking\n\n\
         Built with ocaml-telegram-eio" in
      Flo.debug "[Handler:about] <<< completed";
      Flo.debug "";
      Ok ()
    )

  (* /info alias for /about *)
  |> (fun bot -> Flo.debug "[Builder] Registering route: alias 'info' -> 'about'"; bot)
  |> Bot.command "info" ~desc:"About alias" (fun ctx _args ->
      Flo.debug "[Alias] /info -> /about";
      (* Track command *)
      (match Bot.Ctx.user ctx with
       | Some u -> Bot_state.track_command state (Id.to_string u.id)
       | None -> ());

      let open Bot.Ctx in
      reply_ ctx
        "ℹ️ CommandBot v1.0\n\n\
         Built with ocaml-telegram-eio"
    )

  (* /stats command - admin only *)
  |> (fun bot -> Flo.debug "[Builder] Registering route: command 'stats' (admin)"; bot)
  |> Bot.command "stats" ~desc:"Bot statistics" (Admin.require_admin (fun ctx _args ->
      Flo.debug "";
      Flo.debug "[Handler:stats] >>> /stats command (admin)";

      let (cmds, users, uptime) = Bot_state.get_stats state in
      Flo.debugf "[Handler:stats] Stats: commands=%d, users=%d, uptime=%fs" cmds users uptime;

      let text = Printf.sprintf
        "📊 Bot Statistics\n\n\
         Commands executed: %d\n\
         Unique users: %d\n\
         Uptime: %s"
        cmds users (Bot_state.format_uptime uptime)
      in

      let open Bot.Ctx in
      let* () = reply_ ctx text in
      Flo.debug "[Handler:stats] <<< completed";
      Flo.debug "";
      Ok ()
    ))

  (* /broadcast command - admin only *)
  |> (fun bot -> Flo.debug "[Builder] Registering route: command 'broadcast' (admin)"; bot)
  |> Bot.command "broadcast" ~desc:"Broadcast message" (Admin.require_admin (fun ctx args ->
      Flo.debug "";
      Flo.debug "[Handler:broadcast] >>> /broadcast command (admin)";
      Flo.debugf "[Handler:broadcast] Args: %s" (String.concat " " args);

      let msg_text = Bot.Args.join_rest args 0 in
      Flo.debugf "[Handler:broadcast] Message: \"%s\"" msg_text;

      let open Bot.Ctx in
      let* () =
        if msg_text = "" then (
          Flo.error "[Handler:broadcast] ✗ No message provided";
          reply_ ctx "Usage: /broadcast <message>\nExample: /broadcast Server maintenance in 1 hour"
        ) else (
          Flo.debug "[Handler:broadcast] Would broadcast to all users (not implemented in example)";
          reply_ ctx ("📢 Broadcast message:\n\n" ^ msg_text ^ "\n\n(Note: Actual broadcast not implemented in this example)")
        )
      in
      Flo.debug "[Handler:broadcast] <<< completed";
      Flo.debug "";
      Ok ()
    ))

  |> (fun bot ->
      Flo.debug "[Builder] ✓ All routes registered";
      Flo.info "[Builder] Starting bot...";
      Flo.debug "";
      bot)
  |> Bot.run
