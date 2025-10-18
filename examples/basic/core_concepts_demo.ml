(** Core Concepts Demo - Demonstrating fundamental patterns

    This example demonstrates core concepts from core_concepts.mld:
    - Bot lifecycle (initialization, start, handle, shutdown)
    - High-level Bot DSL with elegant routing
    - Result-based error handling with let* syntax
    - Eio structured concurrency patterns
    - Type-safe ID handling (phantom types)
    - Clean resource management with Switch

    This example has VERBOSE LOGGING enabled to help troubleshoot issues.
    Every step is logged to stderr so you can see the lifecycle in action.

    Commands:
      /start - Welcome message (demonstrates basic handler)
      /echo <text> - Echo text (demonstrates Args helpers)
      /error - Trigger error handling (demonstrates error recovery)
      /calc <a> <op> <b> - Calculate (demonstrates Result monadic composition)
      <any text> - Echo back (demonstrates event routing)

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/core_concepts_demo.exe

    What you'll see in the logs:
      - Phase 1: Initialization (Eio runtime, client creation)
      - Phase 2: Start (Bot builder pattern, route registration)
      - Phase 3: Handle (Update processing, handler execution)
      - Error handling (Result-based error propagation)
      - Phase 4: Shutdown (automatic cleanup via Eio.Switch)
*)

open Telegram
open Tg

(* Configure verbose logging via functor composition *)
module Verbose_log = Log.Make (Log.Console) (struct
  let src = "CoreConceptsBot"
  let level = Log.Debug  (* Enable debug logging *)
end)

module Verbose_session = Session.Make (Verbose_log)
module Verbose_polling = Polling.Make (Verbose_log)
module Verbose_bot = Bot.Make (Verbose_log) (Verbose_session) (Verbose_polling)

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
  Eio.traceln "=== Core Concepts Demo Bot Starting ===";
  Eio.traceln "";
  Eio.traceln "📚 This bot demonstrates fundamental patterns:";
  Eio.traceln "   • Bot lifecycle (init → start → handle → shutdown)";
  Eio.traceln "   • Bot DSL with elegant routing";
  Eio.traceln "   • Result-based error handling";
  Eio.traceln "   • Type-safe ID handling (phantom types)";
  Eio.traceln "   • Clean resource management with Eio.Switch";
  Eio.traceln "";

  (* Phase 1: INITIALIZATION *)
  Eio.traceln "┌─────────────────────────────────────┐";
  Eio.traceln "│ Phase 1: INITIALIZATION             │";
  Eio.traceln "└─────────────────────────────────────┘";
  Eio.traceln "[Init] Loading bot token from environment...";

  let token =
    match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t ->
        Eio.traceln "[Init] ✓ Bot token loaded from TELEGRAM_BOT_TOKEN";
        Eio.traceln "[Init]   Token: %s...%s (length=%d)"
          (String.sub t 0 (min 8 (String.length t)))
          (if String.length t > 8 then String.sub t (String.length t - 4) 4 else "")
          (String.length t);
        t
    | None ->
        Eio.traceln "[Init] ✗ TELEGRAM_BOT_TOKEN environment variable not set";
        Printf.eprintf "Error: TELEGRAM_BOT_TOKEN not set\n";
        exit 1
  in

  Eio.traceln "[Init] Starting Eio event loop (structured concurrency runtime)...";
  (* Create Eio runtime - all async operations happen within this context *)
  Eio_main.run @@ fun env ->

  Eio.traceln "[Init] Creating Telegram HTTP client...";
  let client = Client.create ~env ~token () in
  Eio.traceln "[Init] ✓ HTTP client created (base_url=%s)" (Client.base_url client);
  Eio.traceln "[Init] ✓ Initialization complete";
  Eio.traceln "";

  (* Phase 2: START *)
  Eio.traceln "┌─────────────────────────────────────┐";
  Eio.traceln "│ Phase 2: START (Build Bot DSL)     │";
  Eio.traceln "└─────────────────────────────────────┘";
  Eio.traceln "[Start] Building bot with functional builder pattern...";
  Eio.traceln "";

  Eio.traceln "🤖 Core Concepts Demo Bot Started!";
  Eio.traceln "";
  Eio.traceln "📋 Available commands:";
  Eio.traceln "   /start - Welcome message";
  Eio.traceln "   /echo <text> - Echo text back";
  Eio.traceln "   /error - Trigger error handling demo";
  Eio.traceln "   /calc <a> <op> <b> - Calculate (e.g., /calc 5 + 3)";
  Eio.traceln "   <text> - Echo any message back";
  Eio.traceln "";
  Eio.traceln "🔍 Watching for updates (long polling)...";
  Eio.traceln "";

  (* Build bot using functional builder pattern (Bot DSL) *)
  Verbose_bot.make ~env ~client
  (* Add global error handler - demonstrates error recovery *)
  |> Verbose_bot.on_error (fun ctx exn ->
      Eio.traceln "";
      Eio.traceln "┌─────────────────────────────────────┐";
      Eio.traceln "│ ERROR RECOVERY                      │";
      Eio.traceln "└─────────────────────────────────────┘";
      Eio.traceln "[Error] ❌ Uncaught error in handler: %s" (Printexc.to_string exn);
      Eio.traceln "[Error] User: %s"
        (match Verbose_bot.Ctx.user ctx with
         | Some u -> Printf.sprintf "id=%s username=%s"
             (Id.to_string u.id)
             (Option.value ~default:"<none>" u.username)
         | None -> "none");
      Eio.traceln "[Error] Chat: %s (phantom type: Id.Chat.k Id.t)"
        (Id.to_string (Verbose_bot.Ctx.chat ctx));

      (* Error recovery: try to notify user *)
      Eio.traceln "[Error] Attempting error recovery: notifying user...";
      match Verbose_bot.Ctx.reply ctx "❌ Sorry, an error occurred. Please try again." with
      | Ok _ -> Eio.traceln "[Error] ✓ Error notification sent successfully"
      | Error e -> Eio.traceln "[Error] ✗ Failed to send error notification: %a" Error.pp e;
      Eio.traceln "";
    )

  (* Register /start command *)
  |> (fun bot -> Eio.traceln "[Start] Registering route: command 'start'"; bot)
  |> Verbose_bot.command "start" ~desc:"Welcome message" (fun ctx _args ->
      Eio.traceln "";
      Eio.traceln "┌─────────────────────────────────────┐";
      Eio.traceln "│ Phase 3: HANDLE UPDATE (/start)    │";
      Eio.traceln "└─────────────────────────────────────┘";
      Eio.traceln "[Handler:start] >>> /start command received";
      Eio.traceln "[Handler:start] User: %s"
        (match Verbose_bot.Ctx.user ctx with
         | Some u -> Printf.sprintf "id=%s username=%s"
             (Id.to_string u.id)
             (Option.value ~default:"<none>" u.username)
         | None -> "<none>");

      Eio.traceln "[Handler:start] Demonstrating Result-based error handling...";
      (* Result-based handler with let* syntax for clean error propagation *)
      let open Verbose_bot.Ctx in
      let* () = reply_ ctx
        "👋 Welcome to Core Concepts Demo!\n\n\
         This bot demonstrates:\n\
         • Bot lifecycle phases\n\
         • Bot DSL routing\n\
         • Result-based error handling\n\
         • Type-safe IDs (phantom types)\n\n\
         Commands:\n\
         /echo <text> - Echo text\n\
         /error - See error handling\n\
         /calc 5 + 3 - Calculate" in
      Eio.traceln "[Handler:start] ✓ Message sent successfully (Result = Ok)";
      Eio.traceln "[Handler:start] <<< /start handler completed";
      Eio.traceln "";
      Ok ()
    )

  (* Register /echo command - demonstrates Args helpers *)
  |> (fun bot -> Eio.traceln "[Start] Registering route: command 'echo'"; bot)
  |> Verbose_bot.command "echo" ~desc:"Echo back text" (fun ctx args ->
      Eio.traceln "";
      Eio.traceln "┌─────────────────────────────────────┐";
      Eio.traceln "│ Phase 3: HANDLE UPDATE (/echo)     │";
      Eio.traceln "└─────────────────────────────────────┘";
      Eio.traceln "[Handler:echo] >>> /echo command received";
      Eio.traceln "[Handler:echo] Args (raw): %s" (String.concat " " args);

      let text = Bot.Args.join_rest args 0 in
      Eio.traceln "[Handler:echo] Args (joined): \"%s\"" text;

      let open Verbose_bot.Ctx in
      let* () =
        if text = "" then (
          Eio.traceln "[Handler:echo] No text provided, sending usage message";
          reply_ ctx "Usage: /echo <text>\nExample: /echo Hello, world!"
        ) else (
          Eio.traceln "[Handler:echo] Echoing: \"%s\"" text;
          reply_ ctx text
        )
      in
      Eio.traceln "[Handler:echo] <<< /echo handler completed";
      Eio.traceln "";
      Ok ()
    )

  (* Register /error command - demonstrates error handling *)
  |> (fun bot -> Eio.traceln "[Start] Registering route: command 'error'"; bot)
  |> Verbose_bot.command "error" ~desc:"Trigger error handling demo" (fun ctx _args ->
      Eio.traceln "";
      Eio.traceln "┌─────────────────────────────────────┐";
      Eio.traceln "│ Phase 3: HANDLE UPDATE (/error)    │";
      Eio.traceln "└─────────────────────────────────────┘";
      Eio.traceln "[Handler:error] >>> /error command received";
      Eio.traceln "[Handler:error] This demonstrates Result-based error handling";

      let open Verbose_bot.Ctx in

      (* First, send a message explaining what will happen *)
      let* () = reply_ ctx "I will now demonstrate error handling..." in
      Eio.traceln "[Handler:error] ✓ First message sent";

      (* Now trigger an intentional error to demonstrate recovery *)
      Eio.traceln "[Handler:error] Intentionally triggering error for demonstration...";
      failwith "Intentional error to demonstrate error recovery pattern"
    )

  (* Register /calc command - demonstrates monadic composition *)
  |> (fun bot -> Eio.traceln "[Start] Registering route: command 'calc'"; bot)
  |> Verbose_bot.command "calc" ~desc:"Calculate expression" (fun ctx args ->
      Eio.traceln "";
      Eio.traceln "┌─────────────────────────────────────┐";
      Eio.traceln "│ Phase 3: HANDLE UPDATE (/calc)     │";
      Eio.traceln "└─────────────────────────────────────┘";
      Eio.traceln "[Handler:calc] >>> /calc command received";
      Eio.traceln "[Handler:calc] Args: %s" (String.concat " " args);
      Eio.traceln "[Handler:calc] Demonstrating monadic Result composition...";

      let open Verbose_bot.Ctx in
      let* () =
        match Bot.Args.expect_3 args with
        | Some (a_str, op_str, b_str) ->
            Eio.traceln "[Handler:calc] Parsing: a='%s', op='%s', b='%s'" a_str op_str b_str;

            (* Monadic composition with let* - each step can fail *)
            (match Bot.Args.parse_int a_str, Logic.parse_op op_str, Bot.Args.parse_int b_str with
             | Some a, Some op, Some b ->
                 Eio.traceln "[Handler:calc] ✓ Parsed: a=%d, op=%s, b=%d" a op_str b;
                 Eio.traceln "[Handler:calc] Calling business logic: Logic.calculate";

                 (* Business logic returns Result - error propagates automatically *)
                 (match Logic.calculate op a b with
                  | Ok result ->
                      Eio.traceln "[Handler:calc] ✓ Result: %d" result;
                      let response = Logic.format_result a op_str b result in
                      reply_ ctx response
                  | Error msg ->
                      Eio.traceln "[Handler:calc] ✗ Error from business logic: %s" msg;
                      reply_ ctx (Printf.sprintf "❌ Error: %s" msg))

             | None, _, _ ->
                 Eio.traceln "[Handler:calc] ✗ Failed to parse first number";
                 reply_ ctx "❌ First argument must be a number"
             | _, None, _ ->
                 Eio.traceln "[Handler:calc] ✗ Invalid operator";
                 reply_ ctx "❌ Invalid operator. Use: +, -, *, /"
             | _, _, None ->
                 Eio.traceln "[Handler:calc] ✗ Failed to parse second number";
                 reply_ ctx "❌ Second argument must be a number")

        | None ->
            Eio.traceln "[Handler:calc] ✗ Expected 3 arguments, got %d" (List.length args);
            reply_ ctx "❌ Usage: /calc <number> <operator> <number>\nExample: /calc 5 + 3"
      in
      Eio.traceln "[Handler:calc] <<< /calc handler completed";
      Eio.traceln "";
      Ok ()
    )

  (* Register on_text handler - demonstrates event routing *)
  |> (fun bot -> Eio.traceln "[Start] Registering route: on_text (fallback)"; bot)
  |> Verbose_bot.on_text (fun ctx text ->
      Eio.traceln "";
      Eio.traceln "┌─────────────────────────────────────┐";
      Eio.traceln "│ Phase 3: HANDLE UPDATE (text)      │";
      Eio.traceln "└─────────────────────────────────────┘";
      Eio.traceln "[Handler:text] >>> Non-command text message received";
      Eio.traceln "[Handler:text] User: %s"
        (match Verbose_bot.Ctx.user ctx with
         | Some u -> Printf.sprintf "id=%s (phantom type: Id.User.k Id.t) username=%s"
             (Id.to_string u.id)
             (Option.value ~default:"<none>" u.username)
         | None -> "<none>");
      Eio.traceln "[Handler:text] Text: \"%s\" (length=%d)" text (String.length text);

      let response = Printf.sprintf "You said: %s\n\nTry /calc 5 + 3 or /help" text in

      let open Verbose_bot.Ctx in
      let* () = reply_ ctx response in
      Eio.traceln "[Handler:text] <<< Text handler completed";
      Eio.traceln "";
      Ok ()
    )

  |> (fun bot ->
      Eio.traceln "[Start] ✓ All routes registered";
      Eio.traceln "[Start] Bot builder pattern complete";
      Eio.traceln "";
      Eio.traceln "┌─────────────────────────────────────┐";
      Eio.traceln "│ Phase 3: HANDLE (Starting Loop)    │";
      Eio.traceln "└─────────────────────────────────────┘";
      Eio.traceln "[Handle] Starting long polling loop...";
      Eio.traceln "[Handle] Bot will process updates until Ctrl-C";
      Eio.traceln "";
      bot)
  |> Verbose_bot.run
  (* When this exits (Ctrl-C or error), Eio automatically cleans up resources *)

  (* Phase 4: SHUTDOWN *)
  (* This code is unreachable in normal operation (bot runs forever) *)
  (* But if it exits, Eio handles cleanup automatically via structured concurrency *)
