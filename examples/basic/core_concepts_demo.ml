(** Core Concepts Demo - Demonstrating fundamental patterns with FLO logging

    This example demonstrates core concepts from core_concepts.mld AND all flo features:

    CORE CONCEPTS:
    - Bot lifecycle (initialization, start, handle, shutdown)
    - High-level Bot DSL with elegant routing
    - Result-based error handling with let* syntax
    - Eio structured concurrency patterns
    - Type-safe ID handling (phantom types)
    - Clean resource management with Switch

    FLO LOGGING FEATURES (COMPREHENSIVE DEMONSTRATION):
    - All 7 severity levels (Trace, Debug, Info, Success, Warn, Error, Fatal)
    - Structured logging with type-safe fields (Value.t GADT)
    - Context binding with Flo.bind (fiber-local storage)
    - Distributed tracing with Flo.with_span (hierarchical spans)
    - Semantic conventions (Flo_semconv, Flo_telegram)
    - Log level configuration (Flo.set_level, Flo.get_level)
    - Helper functions (info_fields, debug_fields, error_fields, etc.)

    Commands:
      /start - Welcome message (demonstrates basic handler)
      /echo <text> - Echo text (demonstrates Args helpers)
      /error - Trigger error handling (demonstrates error recovery)
      /calc <a> <op> <b> - Calculate (demonstrates Result monadic composition)
      /trace - Demo TRACE level logging
      /debug - Demo DEBUG level logging
      /levels - Show all 7 log levels
      <any text> - Echo back (demonstrates event routing)

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/core_concepts_demo.exe

    What you'll see:
      - Phase 1: Initialization (Eio runtime, client creation) with INFO/SUCCESS
      - Phase 2: Start (Bot builder pattern, route registration) with DEBUG
      - Phase 3: Handle (Update processing, handler execution) with spans
      - All log levels demonstrated: TRACE, DEBUG, INFO, SUCCESS, WARN, ERROR, FATAL
      - Structured fields: user_id, chat_id, message_id, command, args
      - Context binding: fields attached to fiber-local storage
      - Spans: hierarchical tracing of operations
      - Phase 4: Shutdown (automatic cleanup via Eio.Switch)
*)

open Telegram
open Tg

(* ============================================================================
   FLO FEATURE #1: Log Level Configuration
   ============================================================================ *)

(* Configure verbose logging with flo - NO FUNCTORS! *)
let () =
  (* Set global log level to Debug to see all messages *)
  Flo.set_level Severity.Debug;

  (* We can query the current level *)
  let current_level = Flo.get_level () in
  Printf.printf "🔧 Flo log level configured: %s\n" (Severity.to_string current_level);
  Printf.printf "   This demonstrates Flo.set_level and Flo.get_level\n";
  Printf.printf "   Available levels: Trace < Debug < Info < Success < Warn < Error < Fatal\n\n"

(** Business logic layer - pure functions without Telegram-specific code *)
module Logic = struct
  type calc_op = Add | Sub | Mul | Div

  let parse_op = function
    | "+" | "add" | "plus" -> Some Add
    | "-" | "sub" | "minus" -> Some Sub
    | "*" | "mul" | "times" -> Some Mul
    | "/" | "div" | "divide" -> Some Div
    | _ -> None

  let calculate op a b =
    match op with
    | Add -> Ok (a + b)
    | Sub -> Ok (a - b)
    | Mul -> Ok (a * b)
    | Div when b = 0 -> Error "Division by zero"
    | Div -> Ok (a / b)

  let format_result a op_str b result =
    Printf.sprintf "%d %s %d = %d" a op_str b result
end

let () =
  let open Flo in

  (* ============================================================================
     FLO FEATURE #2: Basic Logging (All 7 Levels)
     ============================================================================ *)

  info "=== Core Concepts Demo Bot Starting ===";
  info "";
  info "📚 This bot demonstrates fundamental patterns:";
  info "   • Bot lifecycle (init → start → handle → shutdown)";
  info "   • Bot DSL with elegant routing";
  info "   • Result-based error handling";
  info "   • Type-safe ID handling (phantom types)";
  info "   • Clean resource management with Eio.Switch";
  info "";
  info "🔥 AND demonstrates ALL flo logging features:";
  info "   • All 7 severity levels (Trace/Debug/Info/Success/Warn/Error/Fatal)";
  info "   • Structured logging with type-safe fields";
  info "   • Context binding (Flo.bind for fiber-local storage)";
  info "   • Distributed tracing (Flo.with_span for hierarchical spans)";
  info "   • Semantic conventions (Flo_semconv, Flo_telegram)";
  info "   • Log level configuration";
  info "";

  (* ============================================================================
     Phase 1: INITIALIZATION with FLO SPANS
     ============================================================================ *)

  (* FLO FEATURE #3: Distributed Tracing with Spans *)
  Flo.with_span "bot_initialization" (fun () ->
    info "┌─────────────────────────────────────┐";
    info "│ Phase 1: INITIALIZATION             │";
    info "└─────────────────────────────────────┘";
    debug "Loading bot token from environment...";

    let token =
      match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
      | Some t ->
          (* FLO FEATURE #4: Structured Logging with Fields *)
          success_fields "Bot token loaded" ~fields:[
            ("source", Value.string "TELEGRAM_BOT_TOKEN");
            ("token_length", Value.int (String.length t));
          ];
          debug_fields "Token details" ~fields:[
            ("prefix", Value.string (String.sub t 0 (min 8 (String.length t))));
            ("suffix", Value.string (if String.length t > 8 then String.sub t (String.length t - 4) 4 else ""));
          ];
          t
      | None ->
          (* Demonstrate FATAL level *)
          fatal "TELEGRAM_BOT_TOKEN environment variable not set";
          Printf.eprintf "Error: TELEGRAM_BOT_TOKEN not set\n";
          exit 1
    in

    debug "Starting Eio event loop (structured concurrency runtime)...";

    (* Create Eio runtime - all async operations happen within this context *)
    Eio_main.run @@ fun env ->

    (* Continue in initialization span *)
    debug "Creating Telegram HTTP client...";
    let client = Client.create ~env ~token () in
    success_fields "HTTP client created" ~fields:[
      ("base_url", Value.string (Client.base_url client));
    ];
    success "Initialization complete";
    info "";

    (* ============================================================================
       Phase 2: START (Build Bot DSL)
       ============================================================================ *)

    Flo.with_span "bot_building" (fun () ->
      info "┌─────────────────────────────────────┐";
      info "│ Phase 2: START (Build Bot DSL)     │";
      info "└─────────────────────────────────────┘";
      debug "Building bot with functional builder pattern...";
      info "";

      info "🤖 Core Concepts Demo Bot Started!";
      info "";
      info "📋 Available commands:";
      info "   /start - Welcome message";
      info "   /echo <text> - Echo text back";
      info "   /error - Trigger error handling demo";
      info "   /calc <a> <op> <b> - Calculate (e.g., /calc 5 + 3)";
      info "   /trace - Demo TRACE level logging";
      info "   /debug - Demo DEBUG level logging";
      info "   /levels - Show all 7 log levels";
      info "   <text> - Echo any message back";
      info "";
      info "🔍 Watching for updates (long polling)...";
      info "";

      (* Build bot using functional builder pattern (Bot DSL) - NO FUNCTORS! *)
      Bot.make ~env ~client

      (* Add global error handler - demonstrates error recovery *)
      |> Bot.on_error (fun ctx exn ->
          info "";
          info "┌─────────────────────────────────────┐";
          info "│ ERROR RECOVERY                      │";
          info "└─────────────────────────────────────┘";

          (* FLO FEATURE #5: Semantic Conventions for Errors *)
          error_fields "Uncaught error in handler" ~fields:[
            Flo_semconv.error_type (Printexc.to_string exn);
            Flo_semconv.error_message (Printexc.to_string exn);
            Flo_semconv.error_stack_trace (Printexc.get_backtrace ());
            Flo_telegram.user_id (match Bot.Ctx.user ctx with
             | Some u -> Id.to_string u.id
             | None -> "none");
            Flo_telegram.chat_id (Id.to_string (Bot.Ctx.chat ctx));
          ];

          (* Error recovery: try to notify user *)
          debug "Attempting error recovery: notifying user...";
          match Bot.Ctx.reply ctx "❌ Sorry, an error occurred. Please try again." with
          | Ok _ -> success "Error notification sent successfully"
          | Error e -> warn_fields "Failed to send error notification" ~fields:[
              Flo_semconv.error_message (Format.asprintf "%a" Error.pp e);
            ];
          info "";
        )

      (* Register /start command *)
      |> (fun bot -> debug "Registering route: command 'start'"; bot)
      |> Bot.command "start" ~desc:"Welcome message" (fun ctx _args ->
          (* FLO FEATURE #6: Context Binding - attach fields to fiber-local storage *)
          Flo.with_span "command_start" (fun () ->
            Bot.Ctx.with_handler_context ctx (fun () ->
              info "";
              info "┌─────────────────────────────────────┐";
              info "│ Phase 3: HANDLE UPDATE (/start)    │";
              info "└─────────────────────────────────────┘";

              (* All logs in this block will include user_id, chat_id, message_id automatically! *)
              info "Received /start command";
              debug "Demonstrating Result-based error handling...";

              (* Result-based handler with let* syntax for clean error propagation *)
              let open Bot.Ctx in
              let* () = reply_ ctx
                "👋 Welcome to Core Concepts Demo!\n\n\
                 This bot demonstrates:\n\
                 • Bot lifecycle phases\n\
                 • Bot DSL routing\n\
                 • Result-based error handling\n\
                 • Type-safe IDs (phantom types)\n\
                 • ALL flo logging features!\n\n\
                 Commands:\n\
                 /echo <text> - Echo text\n\
                 /error - See error handling\n\
                 /calc 5 + 3 - Calculate\n\
                 /levels - See all log levels" in
              success "Message sent successfully (Result = Ok)";
              success "Handler /start completed";
              info "";
              Ok ()
            )
          )
        )

      (* Register /echo command - demonstrates Args helpers *)
      |> (fun bot -> debug "Registering route: command 'echo'"; bot)
      |> Bot.command "echo" ~desc:"Echo back text" (fun ctx args ->
          Flo.with_span "command_echo" (fun () ->
            Bot.Ctx.with_handler_context ctx (fun () ->
              info "";
              info "┌─────────────────────────────────────┐";
              info "│ Phase 3: HANDLE UPDATE (/echo)     │";
              info "└─────────────────────────────────────┘";

              debug_fields "Command echo received" ~fields:[
                ("args_raw", Value.string (String.concat " " args));
                ("args_count", Value.int (List.length args));
              ];

              let text = Bot.Args.join_rest args 0 in
              debug_fields "Args joined" ~fields:[
                ("text", Value.string text);
                ("text_length", Value.int (String.length text));
              ];

              let open Bot.Ctx in
              let* () =
                if text = "" then (
                  warn "No text provided for echo command";
                  reply_ ctx "Usage: /echo <text>\nExample: /echo Hello, world!"
                ) else (
                  debug_fields "Echoing text" ~fields:[
                    ("text_preview", Value.string (if String.length text > 50
                      then String.sub text 0 50 ^ "..."
                      else text));
                  ];
                  reply_ ctx text
                )
              in
              success "Handler /echo completed";
              info "";
              Ok ()
            )
          )
        )

      (* Register /error command - demonstrates error handling *)
      |> (fun bot -> debug "Registering route: command 'error'"; bot)
      |> Bot.command "error" ~desc:"Trigger error handling demo" (fun ctx _args ->
          Flo.with_span "command_error" (fun () ->
            Bot.Ctx.with_handler_context ctx (fun () ->
              info "";
              info "┌─────────────────────────────────────┐";
              info "│ Phase 3: HANDLE UPDATE (/error)    │";
              info "└─────────────────────────────────────┘";

              info "Command /error received - demonstrating error handling";
              debug "This demonstrates Result-based error handling and error recovery";

              let open Bot.Ctx in

              (* First, send a message explaining what will happen *)
              let* () = reply_ ctx "I will now demonstrate error handling..." in
              success "First message sent";

              (* Now trigger an intentional error to demonstrate recovery *)
              warn "Intentionally triggering error for demonstration...";
              failwith "Intentional error to demonstrate error recovery pattern"
            )
          )
        )

      (* Register /calc command - demonstrates monadic composition *)
      |> (fun bot -> debug "Registering route: command 'calc'"; bot)
      |> Bot.command "calc" ~desc:"Calculate expression" (fun ctx args ->
          Flo.with_span "command_calc" (fun () ->
            Bot.Ctx.with_handler_context ctx (fun () ->
              info "";
              info "┌─────────────────────────────────────┐";
              info "│ Phase 3: HANDLE UPDATE (/calc)     │";
              info "└─────────────────────────────────────┘";

              info_fields "Command calc received" ~fields:[
                ("args", Value.string (String.concat " " args));
                ("args_count", Value.int (List.length args));
              ];
              debug "Demonstrating monadic Result composition...";

              let open Bot.Ctx in
              let* () =
                match Bot.Args.expect_3 args with
                | Some (a_str, op_str, b_str) ->
                    debug_fields "Parsing arguments" ~fields:[
                      ("a", Value.string a_str);
                      ("op", Value.string op_str);
                      ("b", Value.string b_str);
                    ];

                    (* Monadic composition with let* - each step can fail *)
                    (match Bot.Args.parse_int a_str, Logic.parse_op op_str, Bot.Args.parse_int b_str with
                     | Some a, Some op, Some b ->
                         success_fields "Parsed successfully" ~fields:[
                           ("a_value", Value.int a);
                           ("operator", Value.string op_str);
                           ("b_value", Value.int b);
                         ];
                         debug "Calling business logic: Logic.calculate";

                         (* Business logic returns Result - error propagates automatically *)
                         (match Logic.calculate op a b with
                          | Ok result ->
                              success_fields "Calculation successful" ~fields:[
                                ("result", Value.int result);
                              ];
                              let response = Logic.format_result a op_str b result in
                              reply_ ctx response
                          | Error msg ->
                              error_fields "Calculation failed" ~fields:[
                                Flo_semconv.error_message msg;
                              ];
                              reply_ ctx (Printf.sprintf "❌ Error: %s" msg))

                     | None, _, _ ->
                         warn "Failed to parse first number";
                         reply_ ctx "❌ First argument must be a number"
                     | _, None, _ ->
                         warn "Invalid operator provided";
                         reply_ ctx "❌ Invalid operator. Use: +, -, *, /"
                     | _, _, None ->
                         warn "Failed to parse second number";
                         reply_ ctx "❌ Second argument must be a number")

                | None ->
                    warn_fields "Wrong number of arguments" ~fields:[
                      ("expected", Value.int 3);
                      ("got", Value.int (List.length args));
                    ];
                    reply_ ctx "❌ Usage: /calc <number> <operator> <number>\nExample: /calc 5 + 3"
              in
              success "Handler /calc completed";
              info "";
              Ok ()
            )
          )
        )

      (* Register /trace command - demonstrates TRACE level *)
      |> (fun bot -> debug "Registering route: command 'trace'"; bot)
      |> Bot.command "trace" ~desc:"Demo TRACE level logging" (fun ctx _args ->
          Flo.with_span "command_trace" (fun () ->
            Bot.Ctx.with_handler_context ctx (fun () ->
              info "Demonstrating TRACE level logging";

              (* TRACE is the most verbose level - for fine-grained debugging *)
              trace "This is TRACE level - finest granularity";
              trace_fields "TRACE with fields" ~fields:[
                ("level_number", Value.int 0);
                ("use_case", Value.string "Fine-grained internal state, loops, iterations");
              ];

              let open Bot.Ctx in
              let* () = reply_ ctx
                "📊 TRACE level demonstration:\n\n\
                 TRACE is the most verbose level.\n\
                 Use for: fine-grained internal state,\n\
                 loop iterations, detailed step-by-step.\n\n\
                 See the console output!" in
              Ok ()
            )
          )
        )

      (* Register /debug command - demonstrates DEBUG level *)
      |> (fun bot -> debug "Registering route: command 'debug'"; bot)
      |> Bot.command "debug" ~desc:"Demo DEBUG level logging" (fun ctx _args ->
          Flo.with_span "command_debug" (fun () ->
            Bot.Ctx.with_handler_context ctx (fun () ->
              info "Demonstrating DEBUG level logging";

              (* DEBUG is for development diagnostics *)
              debug "This is DEBUG level - development diagnostics";
              debug_fields "DEBUG with fields" ~fields:[
                ("level_number", Value.int 1);
                ("use_case", Value.string "Development diagnostics, parsing, state changes");
              ];

              let open Bot.Ctx in
              let* () = reply_ ctx
                "📊 DEBUG level demonstration:\n\n\
                 DEBUG is for development diagnostics.\n\
                 Use for: parsing details, session state,\n\
                 context binding, route matching.\n\n\
                 See the console output!" in
              Ok ()
            )
          )
        )

      (* Register /levels command - demonstrates ALL 7 levels *)
      |> (fun bot -> debug "Registering route: command 'levels'"; bot)
      |> Bot.command "levels" ~desc:"Show all 7 log levels" (fun ctx _args ->
          Flo.with_span "command_levels" (fun () ->
            Bot.Ctx.with_handler_context ctx (fun () ->
              info "Demonstrating ALL 7 severity levels";

              (* Demonstrate all 7 levels in order *)
              trace "1/7 TRACE - Finest granularity (loops, iterations)";
              debug "2/7 DEBUG - Development diagnostics (parsing, state)";
              info "3/7 INFO - Important events (bot started, command received)";
              success "4/7 SUCCESS - Successful operations (message sent, handler complete)";
              warn "5/7 WARN - Warnings (invalid input, missing data)";
              error "6/7 ERROR - Errors (failed API calls, exceptions caught)";
              (* Fatal would exit, so we just mention it *)
              info "7/7 FATAL - Critical errors (exits process, not safe to demo!)";

              let open Bot.Ctx in
              let* () = reply_ ctx
                "📊 All 7 severity levels demonstrated:\n\n\
                 1. TRACE - Finest granularity\n\
                 2. DEBUG - Development diagnostics\n\
                 3. INFO - Important events\n\
                 4. SUCCESS - Successful operations\n\
                 5. WARN - Warnings\n\
                 6. ERROR - Errors\n\
                 7. FATAL - Critical (exits process)\n\n\
                 Check your console to see them all!" in
              success "All 7 levels demonstrated successfully";
              Ok ()
            )
          )
        )

      (* Register on_text handler - demonstrates event routing *)
      |> (fun bot -> debug "Registering route: on_text (fallback)"; bot)
      |> Bot.on_text (fun ctx text ->
          Flo.with_span "text_message" (fun () ->
            Bot.Ctx.with_handler_context ctx (fun () ->
              info "";
              info "┌─────────────────────────────────────┐";
              info "│ Phase 3: HANDLE UPDATE (text)      │";
              info "└─────────────────────────────────────┘";

              info_fields "Non-command text message received" ~fields:[
                ("text_length", Value.int (String.length text));
                ("text_preview", Value.string (if String.length text > 50
                  then String.sub text 0 50 ^ "..."
                  else text));
              ];

              let response = Printf.sprintf "You said: %s\n\nTry /calc 5 + 3 or /levels" text in

              let open Bot.Ctx in
              let* () = reply_ ctx response in
              success "Text handler completed";
              info "";
              Ok ()
            )
          )
        )

      |> (fun bot ->
          success "All routes registered";
          debug "Bot builder pattern complete";
          info "";
          info "┌─────────────────────────────────────┐";
          info "│ Phase 3: HANDLE (Starting Loop)    │";
          info "└─────────────────────────────────────┘";
          debug "Starting long polling loop...";
          info "Bot will process updates until Ctrl-C";
          info "";
          bot)
      |> Bot.run
      (* When this exits (Ctrl-C or error), Eio automatically cleans up resources *)
    )
  );

  (* Phase 4: SHUTDOWN *)
  (* This code is unreachable in normal operation (bot runs forever) *)
  (* But if it exits, Eio handles cleanup automatically via structured concurrency *)
  info "┌─────────────────────────────────────┐";
  info "│ Phase 4: SHUTDOWN                   │";
  info "└─────────────────────────────────────┘";
  success "Bot shutdown complete (Eio automatic cleanup)"
