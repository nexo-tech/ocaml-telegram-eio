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
  info "=== Command Tutorial Bot Starting ===";
  debug "[Init] Loading configuration...";

  let token =
    match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t ->
        info "[Init] ✓ Bot token loaded from TELEGRAM_BOT_TOKEN";
        debugf "[Init]   Token: %s...%s (length=%d)"
          (String.sub t 0 (min 8 (String.length t)))
          (if String.length t > 8 then String.sub t (String.length t - 4) 4 else "")
          (String.length t);
        t
    | None ->
        error "[Init] ✗ TELEGRAM_BOT_TOKEN environment variable not set";
        Printf.eprintf "Error: TELEGRAM_BOT_TOKEN not set\n";
        exit 1
  in

  debug "[Init] Starting Eio event loop...";
  Eio_main.run @@ fun env ->

  debug "[Init] Creating Telegram HTTP client...";
  let client = Client.create ~env ~token () in
  infof "[Init] ✓ HTTP client created (base_url=%s)" (Client.base_url client);

  info "";
  info "🤖 Command Tutorial Bot Started!";
  info "";
  info "📋 Available commands:";
  info "   /start - Welcome message with command list";
  info "   /help  - Show available commands";
  info "   /echo <text> - Echo back the text";
  info "   /add <a> <b> - Add two numbers";
  info "   /upper <text> - Convert text to uppercase";
  info "   <text> - Echo any message back with prefix";
  info "";
  info "🔍 Watching for updates (long polling)...";
  info "";

  (* Build bot using functional builder pattern with Bot DSL *)
  debug "[Builder] Building bot with Bot DSL...";
  Bot.make ~env ~client
  (* Add global error handler to catch and log all errors *)
  |> Bot.on_error (fun ctx exn ->
      error "";
      error "[Error] ❌❌❌ Uncaught error in handler ❌❌❌";
      errorf "[Error] Error: %s" (Printexc.to_string exn);
      errorf "[Error] User: %s"
        (match Bot.Ctx.user ctx with
         | Some u -> Printf.sprintf "id=%s username=%s"
             (Id.to_string u.id)
             (Option.value ~default:"<none>" u.username)
         | None -> "none");
      errorf "[Error] Chat: %s"
        (Id.to_string (Bot.Ctx.chat ctx));
      (* Try to notify user about the error *)
      debug "[Error] Attempting to send error notification to user...";
      match Bot.Ctx.reply ctx "❌ Sorry, an error occurred. Please try again." with
      | Ok _ -> debug "[Error] ✓ Error notification sent"
      | Error e -> errorf "[Error] ✗ Failed to send error message: %s"
          (Format.asprintf "%a" Error.pp e);
      error "";
    )
  (* Register /start command *)
  |> (fun bot -> debug "[Builder] Registering route: command 'start'"; bot)
  |> Bot.command "start" ~desc:"Show welcome message" (fun ctx _args ->
      debug "";
      info "[Handler:start] >>> /start command received";
      debugf "[Handler:start] User: %s"
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
      debug "[Handler:start] <<< /start handler completed";
      debug "";
      Ok ()
    )
  (* Register /help command *)
  |> (fun bot -> debug "[Builder] Registering route: command 'help'"; bot)
  |> Bot.command "help" ~desc:"Show help information" (fun ctx _args ->
      debug "";
      info "[Handler:help] >>> /help command received";
      debugf "[Handler:help] User: %s"
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
      debug "[Handler:help] <<< /help handler completed";
      debug "";
      Ok ()
    )
  (* Register /echo command *)
  |> (fun bot -> debug "[Builder] Registering route: command 'echo'"; bot)
  |> Bot.command "echo" ~desc:"Echo back text" (fun ctx args ->
      debug "";
      info "[Handler:echo] >>> /echo command received";
      debugf "[Handler:echo] Args: %s" (String.concat " " args);

      let text = Bot.Args.join_rest args 0 in
      debugf "[Handler:echo] Joined text: \"%s\"" text;

      let open Bot.Ctx in
      let* () =
        if text = "" then
          reply_ ctx "Usage: /echo <text>\nExample: /echo Hello world"
        else
          reply_ ctx text
      in
      debug "[Handler:echo] <<< /echo handler completed";
      debug "";
      Ok ()
    )
  (* Register /add command with argument parsing *)
  |> (fun bot -> debug "[Builder] Registering route: command 'add'"; bot)
  |> Bot.command "add" ~desc:"Add two numbers" (fun ctx args ->
      debug "";
      info "[Handler:add] >>> /add command received";
      debugf "[Handler:add] Args: %s" (String.concat " " args);

      let open Bot.Ctx in
      let* () =
        match Bot.Args.expect_2 args with
        | Some (a, b) ->
            debugf "[Handler:add] Parsing arguments: a='%s', b='%s'" a b;
            (match Bot.Args.parse_int a, Bot.Args.parse_int b with
             | Some x, Some y ->
                 debugf "[Handler:add] Parsed: x=%d, y=%d" x y;
                 let result = x + y in
                 debugf "[Handler:add] Result: %d + %d = %d" x y result;
                 reply_ ctx (Printf.sprintf "%d + %d = %d" x y result)
             | _ ->
                 debug "[Handler:add] ✗ Failed to parse as integers";
                 reply_ ctx "❌ Both arguments must be numbers.\nUsage: /add 5 3")
        | None ->
            debugf "[Handler:add] ✗ Expected 2 arguments, got %d" (List.length args);
            reply_ ctx "❌ Usage: /add <number1> <number2>\nExample: /add 5 3"
      in
      debug "[Handler:add] <<< /add handler completed";
      debug "";
      Ok ()
    )
  (* Register /upper command *)
  |> (fun bot -> debug "[Builder] Registering route: command 'upper'"; bot)
  |> Bot.command "upper" ~desc:"Convert text to uppercase" (fun ctx args ->
      debug "";
      info "[Handler:upper] >>> /upper command received";
      debugf "[Handler:upper] Args: %s" (String.concat " " args);

      let text = Bot.Args.join_rest args 0 in
      debugf "[Handler:upper] Joined text: \"%s\"" text;

      let open Bot.Ctx in
      let* () =
        if text = "" then
          reply_ ctx "Usage: /upper <text>\nExample: /upper hello world"
        else
          let uppercased = String.uppercase_ascii text in
          debugf "[Handler:upper] Converted: \"%s\" -> \"%s\"" text uppercased;
          reply_ ctx uppercased
      in
      debug "[Handler:upper] <<< /upper handler completed";
      debug "";
      Ok ()
    )
  (* Register on_text handler for non-command text *)
  |> (fun bot -> debug "[Builder] Registering route: on_text (fallback handler)"; bot)
  |> Bot.on_text (fun ctx text ->
      debug "";
      info "[Handler:text] >>> Non-command text message received";
      debugf "[Handler:text] User: %s"
        (match Bot.Ctx.user ctx with
         | Some u -> Printf.sprintf "id=%s username=%s"
             (Id.to_string u.id)
             (Option.value ~default:"<none>" u.username)
         | None -> "<none>");
      debugf "[Handler:text] Text: \"%s\" (length=%d)" text (String.length text);

      (* Echo all non-command text messages with prefix *)
      let response = Printf.sprintf "You said: %s" text in
      debug "[Handler:text] Echoing message back to user...";

      let open Bot.Ctx in
      let* () = reply_ ctx response in
      debug "[Handler:text] <<< Text handler completed";
      debug "";
      Ok ()
    )
  |> (fun bot ->
      debug "[Builder] ✓ All routes registered";
      debug "[Builder] Starting bot...";
      debug "";
      bot)
  |> Bot.run
