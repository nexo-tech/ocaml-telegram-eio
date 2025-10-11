(** Hello World bot - minimal example from getting_started.mld

    This bot responds to /start command with a greeting message.
    Uses the functional builder pattern API for clean, elegant code.

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/hello_world.exe
*)

open Tg.Bot

(* Helper: Convert Result to exception for global error handler *)
let reply_or_fail ctx text =
  match Ctx.reply ctx text with
  | Ok msg -> msg
  | Error err -> raise (Failure (Format.asprintf "Reply failed: %a" Telegram.Error.pp err))

let () =
  (* Get bot token from environment *)
  let token =
    try Sys.getenv "TELEGRAM_BOT_TOKEN"
    with Not_found ->
      failwith "TELEGRAM_BOT_TOKEN environment variable not set"
  in

  (* Start the Eio event loop *)
  Eio_main.run @@ fun env ->

  (* Create HTTP client for Telegram API *)
  let client = Telegram.Client.create ~env ~token () in

  (* Print startup message *)
  Eio.traceln "🤖 Bot started! Send /start to interact...";

  (* Build bot using functional builder pattern *)
  make ~env ~client
  (* Add global error handler to catch and log all errors *)
  |> on_error (fun ctx exn ->
      Eio.traceln "❌ Error in handler: %s" (Printexc.to_string exn);
      (* Try to notify user about the error *)
      match Ctx.reply ctx "Sorry, an error occurred. Please try again." with
      | Ok _ -> ()
      | Error err -> Eio.traceln "Failed to send error message: %a" Telegram.Error.pp err
    )
  |> command "start" (fun ctx _args ->
      Eio.traceln "📨 Received /start command";
      (* Use helper to route errors to global error handler *)
      let _ = reply_or_fail ctx "👋 Hello! I'm your first OCaml Telegram bot!" in
      Eio.traceln "✅ Reply sent successfully"
    )
  |> run
