(** Command Bot Tutorial - Using the elegant Bot DSL

    This example demonstrates the high-level Bot DSL pattern from
    quick_start.mld Tutorial 3. It shows how to build clean, elegant
    bots using the functional builder API.

    This example has VERBOSE LOGGING enabled to help troubleshoot issues.
    Every step is logged to stderr so you can see exactly what's happening.

    Commands:
      /start - Welcome message with command list
      /help - Show available commands
      /echo <text> - Echo back the text
      /add <a> <b> - Add two numbers
      /upper <text> - Convert text to uppercase
      <any text> - Echo it back with "You said:" prefix

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/command_tutorial.exe

    What you'll see in the logs:
      - Bot initialization and configuration loading
      - Route registration (each command)
      - Update reception and routing
      - Handler execution with arguments
      - API calls (sendMessage) with results
      - Argument parsing (for /add command)
*)

open Telegram
open Tg

(* Configure verbose logging with flo *)
let () = Flo.set_level Severity.Debug

let () =
  let open Flo in
  [%log.info "=== Command Tutorial Bot Starting ==="];
  Eio.traceln "[Init] Loading configuration...";

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

  Eio.traceln "[Init] Starting Eio event loop...";
  Eio_main.run @@ fun env ->

  Eio.traceln "[Init] Creating Telegram HTTP client...";
  let client = Client.create ~env ~token () in
  Eio.traceln "[Init] ✓ HTTP client created (base_url=%s)" (Client.base_url client);

  Eio.traceln "";
  Eio.traceln "🤖 Command Tutorial Bot Started!";
  Eio.traceln "";
  Eio.traceln "📋 Available commands:";
  Eio.traceln "   /start - Welcome message with command list";
  Eio.traceln "   /help  - Show available commands";
  Eio.traceln "   /echo <text> - Echo back the text";
  Eio.traceln "   /add <a> <b> - Add two numbers";
  Eio.traceln "   /upper <text> - Convert text to uppercase";
  Eio.traceln "   <text> - Echo any message back with prefix";
  Eio.traceln "";
  Eio.traceln "🔍 Watching for updates (long polling)...";
  Eio.traceln "";

  (* Build bot using functional builder pattern with Bot DSL *)
  Eio.traceln "[Builder] Building bot with Bot DSL...";
  Bot.make ~env ~client
  (* Add global error handler to catch and log all errors *)
  |> Bot.on_error (fun ctx exn ->
      Eio.traceln "";
      Eio.traceln "[Error] ❌❌❌ Uncaught error in handler ❌❌❌";
      Eio.traceln "[Error] Error: %s" (Printexc.to_string exn);
      Eio.traceln "[Error] User: %s"
        (match Bot.Ctx.user ctx with
         | Some u -> Printf.sprintf "id=%s username=%s"
             (Id.to_string u.id)
             (Option.value ~default:"<none>" u.username)
         | None -> "none");
      Eio.traceln "[Error] Chat: %s"
        (Id.to_string (Bot.Ctx.chat ctx));
      (* Try to notify user about the error *)
      Eio.traceln "[Error] Attempting to send error notification to user...";
      match Bot.Ctx.reply ctx "❌ Sorry, an error occurred. Please try again." with
      | Ok _ -> Eio.traceln "[Error] ✓ Error notification sent"
      | Error e -> Eio.traceln "[Error] ✗ Failed to send error message: %a" Error.pp e;
      Eio.traceln "";
    )
  (* Register /start command *)
  |> (fun bot -> Eio.traceln "[Builder] Registering route: command 'start'"; bot)
  |> Bot.command "start" ~desc:"Show welcome message" (fun ctx _args ->
      Eio.traceln "";
      Eio.traceln "[Handler:start] >>> /start command received";
      Eio.traceln "[Handler:start] User: %s"
        (match Bot.Ctx.user ctx with
         | Some u -> Printf.sprintf "id=%s username=%s"
             (Id.to_string u.id)
             (Option.value ~default:"<none>" u.username)
         | None -> "<none>");

      let open Bot.Ctx in
      let* () = reply_ ctx
        "👋 Welcome! I can:\n\
         /start - Show this message\n\
         /help - Get help\n\
         /echo <text> - Echo your text\n\
         /add <a> <b> - Add two numbers\n\
         /upper <text> - Convert to uppercase" in
      Eio.traceln "[Handler:start] <<< /start handler completed";
      Eio.traceln "";
      Ok ()
    )
  (* Register /help command *)
  |> (fun bot -> Eio.traceln "[Builder] Registering route: command 'help'"; bot)
  |> Bot.command "help" ~desc:"Show help information" (fun ctx _args ->
      Eio.traceln "";
      Eio.traceln "[Handler:help] >>> /help command received";
      Eio.traceln "[Handler:help] User: %s"
        (match Bot.Ctx.user ctx with
         | Some u -> Printf.sprintf "id=%s username=%s"
             (Id.to_string u.id)
             (Option.value ~default:"<none>" u.username)
         | None -> "<none>");

      let open Bot.Ctx in
      let* () = reply_ ctx
        "Available commands:\n\
         /echo <text> - Echo text\n\
         /add <a> <b> - Add numbers\n\
         /upper <text> - Uppercase\n\n\
         Just send me text and I'll echo it!" in
      Eio.traceln "[Handler:help] <<< /help handler completed";
      Eio.traceln "";
      Ok ()
    )
  (* Register /echo command *)
  |> (fun bot -> Eio.traceln "[Builder] Registering route: command 'echo'"; bot)
  |> Bot.command "echo" ~desc:"Echo back text" (fun ctx args ->
      Eio.traceln "";
      Eio.traceln "[Handler:echo] >>> /echo command received";
      Eio.traceln "[Handler:echo] Args: %s" (String.concat " " args);

      let text = Bot.Args.join_rest args 0 in
      Eio.traceln "[Handler:echo] Joined text: \"%s\"" text;

      let open Bot.Ctx in
      let* () =
        if text = "" then
          reply_ ctx "Usage: /echo <text>\nExample: /echo Hello world"
        else
          reply_ ctx text
      in
      Eio.traceln "[Handler:echo] <<< /echo handler completed";
      Eio.traceln "";
      Ok ()
    )
  (* Register /add command with argument parsing *)
  |> (fun bot -> Eio.traceln "[Builder] Registering route: command 'add'"; bot)
  |> Bot.command "add" ~desc:"Add two numbers" (fun ctx args ->
      Eio.traceln "";
      Eio.traceln "[Handler:add] >>> /add command received";
      Eio.traceln "[Handler:add] Args: %s" (String.concat " " args);

      let open Bot.Ctx in
      let* () =
        match Bot.Args.expect_2 args with
        | Some (a, b) ->
            Eio.traceln "[Handler:add] Parsing arguments: a='%s', b='%s'" a b;
            (match Bot.Args.parse_int a, Bot.Args.parse_int b with
             | Some x, Some y ->
                 Eio.traceln "[Handler:add] Parsed: x=%d, y=%d" x y;
                 let result = x + y in
                 Eio.traceln "[Handler:add] Result: %d + %d = %d" x y result;
                 reply_ ctx (Printf.sprintf "%d + %d = %d" x y result)
             | _ ->
                 Eio.traceln "[Handler:add] ✗ Failed to parse as integers";
                 reply_ ctx "❌ Both arguments must be numbers.\nUsage: /add 5 3")
        | None ->
            Eio.traceln "[Handler:add] ✗ Expected 2 arguments, got %d" (List.length args);
            reply_ ctx "❌ Usage: /add <number1> <number2>\nExample: /add 5 3"
      in
      Eio.traceln "[Handler:add] <<< /add handler completed";
      Eio.traceln "";
      Ok ()
    )
  (* Register /upper command *)
  |> (fun bot -> Eio.traceln "[Builder] Registering route: command 'upper'"; bot)
  |> Bot.command "upper" ~desc:"Convert text to uppercase" (fun ctx args ->
      Eio.traceln "";
      Eio.traceln "[Handler:upper] >>> /upper command received";
      Eio.traceln "[Handler:upper] Args: %s" (String.concat " " args);

      let text = Bot.Args.join_rest args 0 in
      Eio.traceln "[Handler:upper] Joined text: \"%s\"" text;

      let open Bot.Ctx in
      let* () =
        if text = "" then
          reply_ ctx "Usage: /upper <text>\nExample: /upper hello world"
        else
          let uppercased = String.uppercase_ascii text in
          Eio.traceln "[Handler:upper] Converted: \"%s\" -> \"%s\"" text uppercased;
          reply_ ctx uppercased
      in
      Eio.traceln "[Handler:upper] <<< /upper handler completed";
      Eio.traceln "";
      Ok ()
    )
  (* Register on_text handler for non-command text *)
  |> (fun bot -> Eio.traceln "[Builder] Registering route: on_text (fallback handler)"; bot)
  |> Bot.on_text (fun ctx text ->
      Eio.traceln "";
      Eio.traceln "[Handler:text] >>> Non-command text message received";
      Eio.traceln "[Handler:text] User: %s"
        (match Bot.Ctx.user ctx with
         | Some u -> Printf.sprintf "id=%s username=%s"
             (Id.to_string u.id)
             (Option.value ~default:"<none>" u.username)
         | None -> "<none>");
      Eio.traceln "[Handler:text] Text: \"%s\" (length=%d)" text (String.length text);

      (* Echo all non-command text messages with prefix *)
      let response = Printf.sprintf "You said: %s" text in
      Eio.traceln "[Handler:text] Echoing message back to user...";

      let open Bot.Ctx in
      let* () = reply_ ctx response in
      Eio.traceln "[Handler:text] <<< Text handler completed";
      Eio.traceln "";
      Ok ()
    )
  |> (fun bot ->
      Eio.traceln "[Builder] ✓ All routes registered";
      Eio.traceln "[Builder] Starting bot...";
      Eio.traceln "";
      bot)
  |> Bot.run
