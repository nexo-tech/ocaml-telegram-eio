(** Enhanced echo bot with command routing

    This example demonstrates handling multiple commands and echoing messages.
    Based on the example from getting_started.mld (lines 232-250).
    Uses the functional builder pattern API for clean, elegant code.

    This example has VERBOSE LOGGING enabled to help troubleshoot issues.
    Every step is logged to stderr so you can see exactly what's happening.

    Commands:
      /start - Welcome message
      /help - Show help text
      <any text> - Echo it back

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/echo_enhanced.exe

    What you'll see in the logs:
      - Bot initialization and configuration loading
      - Route registration (commands and text handler)
      - Polling loop with update IDs
      - Route matching for each update
      - Handler execution with timing
      - API calls (sendMessage) with results
*)

open Tg.Bot

(* Helper: Convert Result to exception for global error handler *)
let reply_or_fail ctx text =
  Eio.traceln "[API] → sendMessage: %s" text;
  match Ctx.reply ctx text with
  | Ok msg ->
      Eio.traceln "[API] ← sendMessage: ✓ success (message_id=%Ld)" msg.message_id;
      msg
  | Error err ->
      Eio.traceln "[API] ← sendMessage: ✗ error - %a" Telegram.Error.pp err;
      raise (Failure (Format.asprintf "Reply failed: %a" Telegram.Error.pp err))

let () =
  Eio.traceln "=== Enhanced Echo Bot Starting ===";
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
  let client = Telegram.Client.create ~env ~token () in
  Eio.traceln "[Init] ✓ HTTP client created (base_url=%s)" (Telegram.Client.base_url client);

  Eio.traceln "";
  Eio.traceln "🤖 Enhanced Echo Bot Started!";
  Eio.traceln "";
  Eio.traceln "📋 Available commands:";
  Eio.traceln "   /start - Welcome message";
  Eio.traceln "   /help  - Show help text";
  Eio.traceln "   <text> - Echo any message back";
  Eio.traceln "";
  Eio.traceln "🔍 Watching for updates (long polling)...";
  Eio.traceln "";

  (* Build bot using functional builder pattern *)
  Eio.traceln "[Builder] Registering routes...";
  make ~env ~client
  (* Add global error handler to catch and log all errors *)
  |> on_error (fun ctx err ->
      Eio.traceln "";
      Eio.traceln "[Error] ❌❌❌ Uncaught error in handler ❌❌❌";
      Eio.traceln "[Error] Error type: %a" Telegram.Error.pp err;
      Eio.traceln "[Error] User: %s"
        (match Ctx.user ctx with
         | Some u -> Printf.sprintf "id=%s username=%s"
             (Telegram.Id.to_string u.id)
             (Option.value ~default:"<none>" u.username)
         | None -> "none");
      Eio.traceln "[Error] Chat: %s"
        (match Ctx.chat ctx with
         | Ok c -> Telegram.Id.to_string c
         | Error _ -> "none");
      Eio.traceln "[Error] Message: %s"
        (match Ctx.message ctx with
         | Ok m -> Printf.sprintf "id=%d text=%s" m.message_id (Option.value ~default:"<none>" m.text)
         | Error _ -> "none");
      (* Try to notify user about the error *)
      Eio.traceln "[Error] Attempting to send error notification to user...";
      match Ctx.reply ctx "❌ Sorry, an error occurred. Please try again." with
      | Ok _ -> Eio.traceln "[Error] ✓ Error notification sent"
      | Error e -> Eio.traceln "[Error] ✗ Failed to send error message: %a" Telegram.Error.pp e;
      Eio.traceln "";
    )
  |> (fun bot -> Eio.traceln "[Builder] Registering route: command 'start'"; bot)
  |> command "start" (fun ctx _args ->
      Eio.traceln "";
      Eio.traceln "[Handler:start] >>> /start command received";
      Eio.traceln "[Handler:start] User: %s"
        (match Ctx.user ctx with
         | Some u -> Printf.sprintf "id=%s username=%s"
             (Telegram.Id.to_string u.id)
             (Option.value ~default:"<none>" u.username)
         | None -> "<none>");
      let _ = reply_or_fail ctx "👋 Hello! Send me any message and I'll echo it back." in
      Eio.traceln "[Handler:start] <<< /start handler completed";
      Eio.traceln "";
      Ok ()
    )
  |> (fun bot -> Eio.traceln "[Builder] Registering route: command 'help'"; bot)
  |> command "help" (fun ctx _args ->
      Eio.traceln "";
      Eio.traceln "[Handler:help] >>> /help command received";
      Eio.traceln "[Handler:help] User: %s"
        (match Ctx.user ctx with
         | Some u -> Printf.sprintf "id=%s username=%s"
             (Telegram.Id.to_string u.id)
             (Option.value ~default:"<none>" u.username)
         | None -> "<none>");
      let _ = reply_or_fail ctx "Just send me text and I'll echo it!" in
      Eio.traceln "[Handler:help] <<< /help handler completed";
      Eio.traceln "";
      Ok ()
    )
  |> (fun bot -> Eio.traceln "[Builder] Registering route: on_text (echo handler)"; bot)
  |> on_text (fun ctx text ->
      Eio.traceln "";
      Eio.traceln "[Handler:echo] >>> Text message received";
      Eio.traceln "[Handler:echo] User: %s"
        (match Ctx.user ctx with
         | Some u -> Printf.sprintf "id=%s username=%s"
             (Telegram.Id.to_string u.id)
             (Option.value ~default:"<none>" u.username)
         | None -> "<none>");
      Eio.traceln "[Handler:echo] Text: \"%s\" (length=%d)" text (String.length text);
      (* Echo all non-command text messages *)
      let response = Printf.sprintf "You said: %s" text in
      Eio.traceln "[Handler:echo] Echoing message back to user...";
      let _ = reply_or_fail ctx response in
      Eio.traceln "[Handler:echo] <<< Echo handler completed";
      Eio.traceln "";
      Ok ()
    )
  |> (fun bot -> Eio.traceln "[Builder] ✓ All routes registered"; Eio.traceln "[Builder] Starting bot..."; Eio.traceln ""; bot)
  |> run
