(** Enhanced echo bot with command routing

    This example demonstrates handling multiple commands and echoing messages.
    Based on the example from getting_started.mld (lines 232-250).
    Uses the functional builder pattern API for clean, elegant code.

    Commands:
      /start - Welcome message
      /help - Show help text
      <any text> - Echo it back

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/echo_enhanced.exe
*)

open Tg.Bot

(* Helper: Convert Result to exception for global error handler *)
let reply_or_fail ctx text =
  match Ctx.reply ctx text with
  | Ok msg -> msg
  | Error err -> raise (Failure (Format.asprintf "Reply failed: %a" Telegram.Error.pp err))

let () =
  let token =
    match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None ->
        Printf.eprintf "Error: TELEGRAM_BOT_TOKEN not set\n";
        exit 1
  in

  Eio_main.run @@ fun env ->

  let client = Telegram.Client.create ~env ~token () in

  Printf.printf "Bot started! Try these commands:\n";
  Printf.printf "  /start - Welcome message\n";
  Printf.printf "  /help - Show help\n";
  Printf.printf "  Any text - Echo it back\n\n";
  flush stdout;

  (* Build bot using functional builder pattern *)
  make ~env ~client
  (* Add global error handler to catch and log all errors *)
  |> on_error (fun ctx exn ->
      Eio.traceln "❌ Error in handler: %s" (Printexc.to_string exn);
      Eio.traceln "Backtrace: %s" (Printexc.get_backtrace ());
      (* Try to notify user about the error *)
      match Ctx.reply ctx "❌ Sorry, an error occurred. Please try again." with
      | Ok _ -> ()
      | Error err -> Eio.traceln "Failed to send error message: %a" Telegram.Error.pp err
    )
  |> command "start" (fun ctx _args ->
      Eio.traceln "📨 Received /start command";
      let _ = reply_or_fail ctx "👋 Hello! Send me any message and I'll echo it back." in
      ()
    )
  |> command "help" (fun ctx _args ->
      Eio.traceln "📨 Received /help command";
      let _ = reply_or_fail ctx "Just send me text and I'll echo it!" in
      ()
    )
  |> on_text (fun ctx text ->
      Eio.traceln "📨 Received text: %s" text;
      (* Echo all non-command text messages *)
      let _ = reply_or_fail ctx (Printf.sprintf "You said: %s" text) in
      ()
    )
  |> run
