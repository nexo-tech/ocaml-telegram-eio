(** Debug Logging Recipe - Comprehensive guide to namespace-based logging

    This example demonstrates:
    - How to enable debug logs for specific library components
    - Hierarchical namespace inheritance
    - Dynamic log level adjustment at runtime
    - Common debugging scenarios

    Commands:
      /start - Show main menu
      /debug_all - Enable debug for all telegram library logs
      /debug_polling - Enable debug for polling subsystem only
      /debug_sessions - Enable debug for session management only
      /debug_http - Enable debug for HTTP requests/responses
      /debug_off - Disable all debug logs (back to Info)
      /show_config - Show current logging configuration
      /help - Show this help message

    Debugging scenarios covered:
      1. Hierarchical namespaces - parent/child inheritance
      2. Component-specific debugging - enable only what you need
      3. Dynamic adjustment - change log levels at runtime
      4. Performance impact - when to use different log levels

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/debug_logging_recipe.exe
*)

open Telegram
open Tg

(* Initial logging configuration - default to Info level *)
let () =
  Flo.set_level Severity.Info;
  Flo.info "Debug Logging Recipe started - log level: Info"

module KB = Keyboard

(** Helper to show current logging config *)
let show_config ctx =
  Bot.Ctx.with_handler_context ctx (fun () ->
    let open Flo in
    let open Bot.Ctx in

    let config_info =
      "📊 Current Logging Configuration:\n\n\
       Global level: Info (default)\n\n\
       Namespace hierarchy:\n\
       • telegram (root)\n\
       • telegram.client\n\
       •   telegram.client.http\n\
       •   telegram.client.session\n\
       • telegram.api\n\
       •   telegram.api.response\n\
       • telegram.polling\n\
       • telegram.webhook\n\
       • telegram.bot\n\
       •   telegram.bot.dispatch\n\
       •   telegram.bot.middleware\n\
       •   telegram.bot.context\n\
       • telegram.upload\n\
       • telegram.download\n\
       • telegram.retry\n\
       • telegram.session\n\
       • telegram.error\n\n\
       Try /debug_* commands to enable specific logs!"
    in

    let* () = reply_ ctx config_info in
    [%log.success "Configuration displayed"];
    Ok ()
  )

(** Command handlers with context logging *)
let handle_debug_all ctx _args =
  Bot.Ctx.with_handler_context ctx (fun () ->
    let open Flo in
    let open Bot.Ctx in

    [%log.info "Enabling debug for all telegram library logs"];
    Flo.set_level_for "telegram" Severity.Debug;

    let* () = reply_ ctx
      "✅ Debug enabled for all telegram library components!\n\n\
       You'll now see:\n\
       • HTTP requests/responses\n\
       • Polling loop details\n\
       • Session get/set operations\n\
       • Route matching\n\
       • All internal operations\n\n\
       Use /debug_off to disable." in

    [%log.success "Debug enabled globally"];
    Ok ()
  )

let handle_debug_polling ctx _args =
  Bot.Ctx.with_handler_context ctx (fun () ->
    let open Flo in
    let open Bot.Ctx in

    [%log.info "Enabling debug for polling subsystem"];
    Flo.set_level_for "telegram.polling" Severity.Debug;

    let* () = reply_ ctx
      "✅ Debug enabled for polling subsystem!\n\n\
       You'll now see:\n\
       • Update fetching details\n\
       • Offset calculations\n\
       • Timeout handling\n\
       • Deduplication logic\n\n\
       This helps debug update delivery issues." in

    [%log.success "Polling debug enabled"];
    Ok ()
  )

let handle_debug_sessions ctx _args =
  Bot.Ctx.with_handler_context ctx (fun () ->
    let open Flo in
    let open Bot.Ctx in

    [%log.info "Enabling debug for session management"];
    Flo.set_level_for "telegram.session" Severity.Debug;

    let* () = reply_ ctx
      "✅ Debug enabled for session management!\n\n\
       You'll now see:\n\
       • Session get/set/delete operations\n\
       • Session key access patterns\n\
       • Session loading/saving\n\n\
       Useful for debugging state machines and user data." in

    [%log.success "Session debug enabled"];
    Ok ()
  )

let handle_debug_http ctx _args =
  Bot.Ctx.with_handler_context ctx (fun () ->
    let open Flo in
    let open Bot.Ctx in

    [%log.info "Enabling debug for HTTP subsystem"];
    Flo.set_level_for "telegram.client.http" Severity.Debug;

    let* () = reply_ ctx
      "✅ Debug enabled for HTTP subsystem!\n\n\
       You'll now see:\n\
       • HTTP request details (method, URL)\n\
       • Response status codes\n\
       • Request/response timing\n\
       • Connection errors\n\n\
       ⚠️  Can be verbose during high traffic!" in

    [%log.success "HTTP debug enabled"];
    Ok ()
  )

let handle_debug_off ctx _args =
  Bot.Ctx.with_handler_context ctx (fun () ->
    let open Flo in
    let open Bot.Ctx in

    [%log.info "Disabling debug logs, reverting to Info"];
    Flo.set_level Severity.Info;
    Flo.clear_level_for "telegram";
    Flo.clear_level_for "telegram.polling";
    Flo.clear_level_for "telegram.session";
    Flo.clear_level_for "telegram.client.http";

    let* () = reply_ ctx
      "✅ Debug logs disabled - back to Info level.\n\n\
       Only important events will be logged:\n\
       • Bot start/stop\n\
       • Errors and warnings\n\
       • Upload/download completion\n\n\
       Use /debug_* commands to re-enable specific components." in

    [%log.success "Debug disabled"];
    Ok ()
  )

let handle_start ctx _args =
  Bot.Ctx.with_handler_context ctx (fun () ->
    let open Flo in
    let open Bot.Ctx in

    [%log.info "Processing /start command"];

    let welcome =
      "🔍 Debug Logging Recipe Bot\n\n\
       This bot demonstrates namespace-based logging.\n\n\
       📚 Learn how to:\n\
       • Enable debug for specific components\n\
       • Use hierarchical namespaces\n\
       • Adjust log levels dynamically\n\n\
       Try these commands:\n\
       /debug_all - All library logs\n\
       /debug_polling - Polling only\n\
       /debug_sessions - Sessions only\n\
       /debug_http - HTTP only\n\
       /debug_off - Disable debug\n\
       /show_config - Show namespaces\n\
       /help - Full help"
    in

    let* () = reply_ ctx welcome in
    [%log.success "Welcome message sent"];
    Ok ()
  )

let handle_help ctx _args =
  Bot.Ctx.with_handler_context ctx (fun () ->
    let open Flo in
    let open Bot.Ctx in

    let help_text =
      "🔍 Debug Logging Recipe - Help\n\n\
       HIERARCHICAL NAMESPACES:\n\
       The library uses hierarchical namespaces that inherit log levels.\n\
       Example: \"telegram.client.http\" inherits from \"telegram.client\"\n\n\
       COMMON DEBUGGING SCENARIOS:\n\n\
       1️⃣  Bot not responding to messages?\n\
       → /debug_polling (check update delivery)\n\n\
       2️⃣  State machine issues?\n\
       → /debug_sessions (see state persistence)\n\n\
       3️⃣  API calls failing?\n\
       → /debug_http (see request/response)\n\n\
       4️⃣  General debugging?\n\
       → /debug_all (see everything)\n\n\
       PERFORMANCE TIPS:\n\
       • Debug logs have minimal overhead when disabled\n\
       • Enable only components you need\n\
       • Use /debug_off in production\n\n\
       Try /show_config to see all namespaces!"
    in

    let* () = reply_ ctx help_text in
    [%log.success "Help message sent"];
    Ok ()
  )

(** Main bot setup *)
let () =
  let token =
    match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None ->
        Printf.eprintf "Error: TELEGRAM_BOT_TOKEN not set\n";
        exit 1
  in

  Eio_main.run @@ fun env ->

  let client = Client.create ~env ~token () in

  (* Announce bot startup *)
  Flo.info_fields "Debug Logging Recipe Bot starting" ~fields:[
    ("log_level", Flo.Value.string "Info");
    ("namespaces", Flo.Value.string "hierarchical");
  ];

  Bot.make ~env ~client
  |> Bot.command "start" ~desc:"Show welcome message" handle_start
  |> Bot.command "help" ~desc:"Show detailed help" handle_help
  |> Bot.command "debug_all" ~desc:"Enable debug for all telegram logs" handle_debug_all
  |> Bot.command "debug_polling" ~desc:"Enable debug for polling only" handle_debug_polling
  |> Bot.command "debug_sessions" ~desc:"Enable debug for sessions only" handle_debug_sessions
  |> Bot.command "debug_http" ~desc:"Enable debug for HTTP only" handle_debug_http
  |> Bot.command "debug_off" ~desc:"Disable all debug logs" handle_debug_off
  |> Bot.command "show_config" ~desc:"Show logging configuration" show_config
  |> Bot.run
