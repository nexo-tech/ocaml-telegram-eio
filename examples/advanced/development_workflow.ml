(** Development Workflow Demo - Development and debugging workflow patterns

    This example demonstrates development workflow patterns:
    - Local development setup
    - Logging and debugging techniques
    - Testing workflows
    - Performance monitoring
    - Error investigation
    - Self-testing and diagnostics

    Commands:
      /start - Show main menu
      /setup - Local development setup guide
      /logging - Logging techniques and examples
      /debugging - Debugging strategies
      /testing - Testing workflow
      /monitoring - Performance monitoring
      /env_check - Check environment configuration
      /diagnostics - Run bot diagnostics
      /log_example - Trigger logging example
      /error_example - Trigger error for debugging

    This example demonstrates DEVELOPMENT WORKFLOW with verbose logging.

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      export DEBUG="true"  # Optional: Enable debug mode
      dune exec examples/development_workflow_demo.exe
*)

open Telegram
open Tg

(* Configure verbose logging with flo *)
let () = Flo.set_level Severity.Debug

module KB = Keyboard

(** Workflow documentation templates *)
module Templates = struct
  let local_setup =
    "🔧 <b>Local Development Setup</b>\n\n\
     <b>1. Build the project:</b>\n\
     <code>dune build</code>\n\n\
     <b>2. Run your bot:</b>\n\
     <code>\n\
     export TELEGRAM_BOT_TOKEN=\"your_token\"\n\
     dune exec bin/main.exe\n\
     </code>\n\n\
     <b>3. Watch mode (auto-rebuild):</b>\n\
     <code>dune build --watch</code>\n\n\
     <b>4. Run with environment file:</b>\n\
     <code>\n\
     export $(cat .env.dev | xargs)\n\
     dune exec bin/main.exe\n\
     </code>\n\n\
     <b>5. Auto-restart on changes:</b>\n\
     <code>\n\
     find . -name \"*.ml\" | entr -r dune exec bin/main.exe\n\
     </code>"

  let logging_guide =
    "📝 <b>Logging Techniques</b>\n\n\
     <b>1. Simple logging with Eio.traceln:</b>\n\
     <code>\n\
     Eio.traceln \"Processing update %Ld\" update_id;\n\
     Eio.traceln \"User: %s\" username;\n\
     </code>\n\n\
     <b>2. Functor-based logging:</b>\n\
     <code>\n\
     module MyLog = Log.Make (Log.Console)\n\
       (struct\n\
         let src = \"MyBot\"\n\
         let level = Log.Debug\n\
       end)\n\
     </code>\n\n\
     <b>3. Log levels:</b>\n\
     • Debug - Detailed execution\n\
     • Info - Important events\n\
     • Warn - Potential issues\n\
     • Error - Failures\n\n\
     <b>4. Conditional debug mode:</b>\n\
     <code>\n\
     let debug = Sys.getenv_opt \"DEBUG\" = Some \"true\"\n\
     if debug then Eio.traceln \"Debug: %s\" msg\n\
     </code>"

  let debugging_guide =
    "🐛 <b>Debugging Strategies</b>\n\n\
     <b>1. Print full update JSON:</b>\n\
     <code>\n\
     let json = Update.to_yojson update in\n\
     Yojson.Safe.pretty_print Format.std_formatter json\n\
     </code>\n\n\
     <b>2. Interactive REPL testing:</b>\n\
     <code>\n\
     dune utop lib\n\
     open My_bot_lib;;\n\
     (* Test functions interactively *)\n\
     </code>\n\n\
     <b>3. Breakpoints with assert:</b>\n\
     <code>\n\
     if suspicious_condition then (\n\
       Eio.traceln \"Stopping here\";\n\
       assert false\n\
     )\n\
     </code>\n\n\
     <b>4. Exception backtraces:</b>\n\
     <code>\n\
     Printexc.record_backtrace true;\n\
     (* Get backtrace on error *)\n\
     Printexc.get_backtrace ()\n\
     </code>\n\n\
     <b>5. Save problematic updates:</b>\n\
     <code>\n\
     Yojson.Safe.to_file\n\
       \"update_error.json\"\n\
       (Update.to_yojson update)\n\
     </code>"

  let testing_workflow =
    "🧪 <b>Testing Workflow</b>\n\n\
     <b>1. Run all tests:</b>\n\
     <code>dune runtest</code>\n\n\
     <b>2. Run specific test:</b>\n\
     <code>dune exec test/test_commands.exe</code>\n\n\
     <b>3. Watch mode for tests:</b>\n\
     <code>dune runtest --watch</code>\n\n\
     <b>4. Test with coverage:</b>\n\
     <code>\n\
     dune runtest --instrument-with bisect_ppx\n\
     bisect-ppx-report html\n\
     </code>\n\n\
     <b>5. Interactive testing:</b>\n\
     <code>\n\
     dune utop lib\n\
     (* Test functions in REPL *)\n\
     </code>\n\n\
     <b>Best Practices:</b>\n\
     • Write tests for business logic\n\
     • Test edge cases\n\
     • Keep tests fast\n\
     • Use property-based testing\n\
     • Test error paths"

  let monitoring_guide =
    "📊 <b>Performance Monitoring</b>\n\n\
     <b>1. Request timing:</b>\n\
     <code>\n\
     let start = Unix.gettimeofday () in\n\
     let result = handle_request () in\n\
     let duration = Unix.gettimeofday () -. start in\n\
     Eio.traceln \"Handler took %.3fs\" duration\n\
     </code>\n\n\
     <b>2. Memory usage:</b>\n\
     <code>\n\
     let gc = Gc.stat () in\n\
     Eio.traceln \"Heap: %.1f MB\" (float_of_int gc.heap_words *. 8. /. 1024. /. 1024.)\n\
     </code>\n\n\
     <b>3. Update statistics:</b>\n\
     <code>\n\
     let total = ref 0 in\n\
     let errors = ref 0 in\n\
     let handle_update u =\n\
       incr total;\n\
       match process u with\n\
       | Ok _ -> ()\n\
       | Error _ -> incr errors\n\
     </code>\n\n\
     <b>4. Rate tracking:</b>\n\
     <code>\n\
     let updates_per_minute = !total / elapsed_minutes\n\
     Eio.traceln \"Rate: %d updates/min\" updates_per_minute\n\
     </code>"
end

(** Bot diagnostics *)
module Diagnostics = struct
  let check_env () =
    let token_set = Sys.getenv_opt "TELEGRAM_BOT_TOKEN" <> None in
    let debug_mode = Sys.getenv_opt "DEBUG" = Some "true" in
    let log_level = Sys.getenv_opt "LOG_LEVEL" in

    Printf.sprintf
      "🔍 <b>Environment Check</b>\n\n\
       TELEGRAM_BOT_TOKEN: %s\n\
       DEBUG: %s\n\
       LOG_LEVEL: %s\n\n\
       <b>Status:</b> %s"
      (if token_set then "✅ Set" else "❌ Not set")
      (if debug_mode then "✅ Enabled" else "❌ Disabled")
      (match log_level with Some l -> l | None -> "default")
      (if token_set then "Ready" else "Missing TELEGRAM_BOT_TOKEN!")

  let runtime_info () =
    let gc = Gc.stat () in
    let heap_mb = float_of_int gc.heap_words *. 8.0 /. 1024.0 /. 1024.0 in

    Printf.sprintf
      "📊 <b>Runtime Diagnostics</b>\n\n\
       OCaml version: %s\n\
       Heap size: %.1f MB\n\
       Minor collections: %d\n\
       Major collections: %d\n\n\
       <b>Status:</b> Running normally"
      Sys.ocaml_version
      heap_mb
      gc.minor_collections
      gc.major_collections
end

let () =
  Printexc.record_backtrace true;
  Eio.traceln "=== Development Workflow Demo Starting ===";

  (* Check environment *)
  let debug_mode = Sys.getenv_opt "DEBUG" = Some "true" in
  Eio.traceln "Debug mode: %s" (if debug_mode then "ENABLED" else "disabled");

  let token = match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None -> Printf.eprintf "TELEGRAM_BOT_TOKEN not set\n"; exit 1
  in

  Eio_main.run @@ fun env ->
  let client = Client.create ~env ~token () in

  Eio.traceln "🤖 Development Workflow Demo Started";

  let session_store = Session.Memory_store.create () in

  (* Statistics tracking *)
  let total_updates = ref 0 in
  let start_time = Unix.time () in

  Bot.make ~env ~client
  |> Bot.with_sessions (module Session.Memory_store) session_store

  (* /start - Main menu *)
  |> Bot.command "start" ~desc:"Show main menu" (fun ctx _args ->
      let open Bot.Ctx in
      Eio.traceln "[/start] Showing main menu";
      incr total_updates;

      let keyboard = KB.inline [
        [KB.callback ~text:"🔧 Setup Guide" ~data:"guide:setup"];
        [KB.callback ~text:"📝 Logging" ~data:"guide:logging"];
        [KB.callback ~text:"🐛 Debugging" ~data:"guide:debugging"];
        [KB.callback ~text:"🧪 Testing" ~data:"guide:testing"];
        [KB.callback ~text:"📊 Monitoring" ~data:"guide:monitoring"];
        [KB.callback ~text:"⚙️ Env Check" ~data:"action:env_check"];
        [KB.callback ~text:"🔍 Diagnostics" ~data:"action:diagnostics"];
      ] in

      let text =
        "🛠️ <b>Development Workflow Demo</b>\n\n\
         Learn bot development workflows:\n\n\
         🔧 Setup - Local development\n\
         📝 Logging - Log techniques\n\
         🐛 Debugging - Debug strategies\n\
         🧪 Testing - Test workflows\n\
         📊 Monitoring - Performance tracking\n\n\
         Choose a topic to explore:"
      in

      match send ~keyboard ctx text with
      | Ok _ -> Eio.traceln "[/start] ✓"; Ok ()
      | Error e -> Eio.traceln "[/start] ✗ %a" Error.pp e; Ok ()
    )

  (* /env_check - Check environment *)
  |> Bot.command "env_check" ~desc:"Check environment configuration" (fun ctx _args ->
      let open Bot.Ctx in
      Eio.traceln "[/env_check] Checking environment";

      let env_status = Diagnostics.check_env () in

      match reply ctx env_status with
      | Ok _ -> Eio.traceln "[/env_check] ✓"; Ok ()
      | Error e -> Eio.traceln "[/env_check] ✗ %a" Error.pp e; Ok ()
    )

  (* /diagnostics - Runtime diagnostics *)
  |> Bot.command "diagnostics" ~desc:"Run bot diagnostics" (fun ctx _args ->
      let open Bot.Ctx in
      Eio.traceln "[/diagnostics] Running diagnostics";

      let runtime_info = Diagnostics.runtime_info () in

      let uptime = Unix.time () -. start_time in
      let rate = if uptime > 0.0 then
        float_of_int !total_updates /. uptime *. 60.0
      else 0.0 in

      let full_report = Printf.sprintf
        "%s\n\n\
         <b>Bot Statistics:</b>\n\
         Uptime: %.0f seconds\n\
         Total updates: %d\n\
         Rate: %.1f updates/min"
        runtime_info
        uptime
        !total_updates
        rate
      in

      match reply ctx full_report with
      | Ok _ -> Eio.traceln "[/diagnostics] ✓"; Ok ()
      | Error e -> Eio.traceln "[/diagnostics] ✗ %a" Error.pp e; Ok ()
    )

  (* /log_example - Demonstrate logging *)
  |> Bot.command "log_example" ~desc:"Logging example" (fun ctx _args ->
      let open Bot.Ctx in

      Eio.traceln "[/log_example] === Logging Example Start ===";
      Eio.traceln "[/log_example] Debug: This is a debug message";
      Eio.traceln "[/log_example] Info: Processing request";
      Eio.traceln "[/log_example] Warn: This is a warning";

      incr total_updates;

      Eio.traceln "[/log_example] Update counter: %d" !total_updates;
      Eio.traceln "[/log_example] === Logging Example End ===";

      let text =
        "📝 <b>Logging Example</b>\n\n\
         Check your console to see:\n\
         • Debug messages\n\
         • Info messages\n\
         • Warning messages\n\
         • Update counter\n\n\
         All logged with Eio.traceln and functor-based logging."
      in

      match reply ctx text with
      | Ok _ -> Eio.traceln "[/log_example] ✓"; Ok ()
      | Error e -> Eio.traceln "[/log_example] ✗ %a" Error.pp e; Ok ()
    )

  (* /error_example - Demonstrate error handling *)
  |> Bot.command "error_example" ~desc:"Error handling example" (fun ctx _args ->
      let open Bot.Ctx in

      Eio.traceln "[/error_example] Demonstrating error handling";

      (* Simulate an error *)
      let result = Error (Error.Api_error {
        code = 400;
        description = "Simulated error for demonstration";
        parameters = None;
      }) in

      match result with
      | Ok _ ->
          (match reply ctx "This won't happen" with
           | Ok _ -> Ok ()
           | Error e -> Eio.traceln "[/error_example] ✗ %a" Error.pp e; Ok ())

      | Error err ->
          Eio.traceln "[/error_example] Caught error: %a" Error.pp err;
          Eio.traceln "[/error_example] Error is retryable: %b" (Error.is_retryable err);

          let text = Printf.sprintf
            "❌ <b>Error Handling Example</b>\n\n\
             Simulated error caught:\n\
             %s\n\n\
             Check logs to see:\n\
             • Error logging\n\
             • Error details\n\
             • Retryability check"
            (Format.asprintf "%a" Error.pp err)
          in

          (match reply ctx text with
           | Ok _ -> Eio.traceln "[/error_example] ✓"; Ok ()
           | Error e -> Eio.traceln "[/error_example] ✗ %a" Error.pp e; Ok ())
    )

  (* /performance - Show performance stats *)
  |> Bot.command "performance" ~desc:"Show performance statistics" (fun ctx _args ->
      let open Bot.Ctx in
      Eio.traceln "[/performance] Showing performance stats";

      let uptime = Unix.time () -. start_time in
      let rate = if uptime > 0.0 then
        float_of_int !total_updates /. uptime *. 60.0
      else 0.0 in

      let gc = Gc.stat () in
      let heap_mb = float_of_int gc.heap_words *. 8.0 /. 1024.0 /. 1024.0 in

      let text = Printf.sprintf
        "📊 <b>Performance Statistics</b>\n\n\
         <b>Uptime:</b> %.0f seconds\n\
         <b>Total updates:</b> %d\n\
         <b>Rate:</b> %.1f updates/min\n\
         <b>Heap size:</b> %.1f MB\n\
         <b>GC minor:</b> %d collections\n\
         <b>GC major:</b> %d collections"
        uptime
        !total_updates
        rate
        heap_mb
        gc.minor_collections
        gc.major_collections
      in

      match reply ctx text with
      | Ok _ -> Eio.traceln "[/performance] ✓"; Ok ()
      | Error e -> Eio.traceln "[/performance] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: guide:* *)
  |> Bot.on_callback_data "guide:setup" (fun ctx ->
      let open Bot.Ctx in
      match edit ctx Templates.local_setup with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[guide:setup] ✗ %a" Error.pp e; Ok ()
    )

  |> Bot.on_callback_data "guide:logging" (fun ctx ->
      let open Bot.Ctx in
      match edit ctx Templates.logging_guide with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[guide:logging] ✗ %a" Error.pp e; Ok ()
    )

  |> Bot.on_callback_data "guide:debugging" (fun ctx ->
      let open Bot.Ctx in
      match edit ctx Templates.debugging_guide with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[guide:debugging] ✗ %a" Error.pp e; Ok ()
    )

  |> Bot.on_callback_data "guide:testing" (fun ctx ->
      let open Bot.Ctx in
      match edit ctx Templates.testing_workflow with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[guide:testing] ✗ %a" Error.pp e; Ok ()
    )

  |> Bot.on_callback_data "guide:monitoring" (fun ctx ->
      let open Bot.Ctx in
      match edit ctx Templates.monitoring_guide with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[guide:monitoring] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: action:env_check *)
  |> Bot.on_callback_data "action:env_check" (fun ctx ->
      let open Bot.Ctx in
      let env_status = Diagnostics.check_env () in
      match edit ctx env_status with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[action:env_check] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: action:diagnostics *)
  |> Bot.on_callback_data "action:diagnostics" (fun ctx ->
      let open Bot.Ctx in

      let runtime_info = Diagnostics.runtime_info () in
      let uptime = Unix.time () -. start_time in
      let rate = if uptime > 0.0 then
        float_of_int !total_updates /. uptime *. 60.0
      else 0.0 in

      let full_report = Printf.sprintf
        "%s\n\n\
         <b>Bot Statistics:</b>\n\
         Uptime: %.0f seconds\n\
         Total updates: %d\n\
         Rate: %.1f updates/min"
        runtime_info
        uptime
        !total_updates
        rate
      in

      match edit ctx full_report with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[action:diagnostics] ✗ %a" Error.pp e; Ok ()
    )

  |> Bot.run
