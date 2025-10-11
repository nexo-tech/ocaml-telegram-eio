(** Hello World bot - minimal example from getting_started.mld

    This bot responds to /start command with a greeting message.
    Uses the functional builder pattern API for clean, elegant code.

    This example has VERBOSE LOGGING enabled to help troubleshoot issues.
    Every step is logged to stderr so you can see exactly what's happening.

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/hello_world.exe

    What you'll see in the logs:
      - Bot initialization and token loading
      - Polling loop start
      - Each update received (update_id, type)
      - Command routing (matched/unmatched)
      - Handler execution (entry/exit)
      - API call results (success/error)
*)

open Telegram
open Tg

(* Configure verbose logging via functor composition *)
module Verbose_log = Log.Make (Log.Console) (struct
  let src = "HelloBot"
  let level = Log.Debug  (* Enable debug logging *)
end)

module Verbose_session = Session.Make (Verbose_log)
module Verbose_polling = Polling.Make (Verbose_log)
module Verbose_bot = Bot.Make (Verbose_log) (Verbose_session) (Verbose_polling)

let () =
  Eio.traceln "=== Hello World Bot Starting ===";
  Eio.traceln "[Init] Loading configuration...";

  (* Get bot token from environment *)
  let token =
    try
      let t = Sys.getenv "TELEGRAM_BOT_TOKEN" in
      Eio.traceln "[Init] ✓ Bot token loaded from TELEGRAM_BOT_TOKEN";
      Eio.traceln "[Init]   Token: %s...%s (length=%d)"
        (String.sub t 0 (min 8 (String.length t)))
        (if String.length t > 8 then String.sub t (String.length t - 4) 4 else "")
        (String.length t);
      t
    with Not_found ->
      Eio.traceln "[Init] ✗ TELEGRAM_BOT_TOKEN environment variable not set";
      failwith "TELEGRAM_BOT_TOKEN environment variable not set"
  in

  Eio.traceln "[Init] Starting Eio event loop...";
  (* Start the Eio event loop *)
  Eio_main.run @@ fun env ->

  Eio.traceln "[Init] Creating Telegram HTTP client...";
  (* Create HTTP client for Telegram API *)
  let client = Client.create ~env ~token () in
  Eio.traceln "[Init] ✓ HTTP client created (base_url=%s)" (Client.base_url client);

  (* Print startup message *)
  Eio.traceln "";
  Eio.traceln "🤖 Bot started successfully!";
  Eio.traceln "📱 Send /start to the bot to interact";
  Eio.traceln "🔍 Watching for updates (long polling)...";
  Eio.traceln "";

  (* Build bot using functional builder pattern with verbose logging *)
  Eio.traceln "[Builder] Building bot with functional API...";
  Verbose_bot.make ~env ~client
  (* Add global error handler to catch and log all errors *)
  |> Verbose_bot.on_error (fun ctx exn ->
      Eio.traceln "[Error] ❌ Uncaught error in handler: %s" (Printexc.to_string exn);
      Eio.traceln "[Error] Context: user=%s, chat=%s"
        (match Verbose_bot.Ctx.user ctx with
         | Some u -> Printf.sprintf "id=%s" (Id.to_string u.id)
         | None -> "none")
        (match Verbose_bot.Ctx.chat ctx with
         | ch_id -> Id.to_string ch_id);
      (* Try to notify user about the error *)
      Eio.traceln "[Error] Attempting to send error notification to user...";
      match Verbose_bot.Ctx.reply ctx "Sorry, an error occurred. Please try again." with
      | Ok _ -> Eio.traceln "[Error] ✓ Error notification sent to user"
      | Error e -> Eio.traceln "[Error] ✗ Failed to send error message: %a" Error.pp e
    )
  |> Verbose_bot.command "start" (fun ctx _args ->
      Eio.traceln "";
      Eio.traceln "[Handler] >>> Received /start command";
      Eio.traceln "[Handler] User: %s"
        (match Verbose_bot.Ctx.user ctx with
         | Some u -> Printf.sprintf "id=%s, username=%s"
             (Id.to_string u.id)
             (Option.value ~default:"<none>" u.username)
         | None -> "<none>");
      Eio.traceln "[Handler] Chat: %s"
        (Id.to_string (Verbose_bot.Ctx.chat ctx));

      Eio.traceln "[Handler] Executing handler logic...";
      (* Use Result-based error handling *)
      let open Verbose_bot.Ctx in
      let* () = reply_ ctx "👋 Hello! I'm your first OCaml Telegram bot!" in
      Eio.traceln "[Handler] <<< Handler completed successfully";
      Eio.traceln "";
      Ok ()
    )
  |> Verbose_bot.run
