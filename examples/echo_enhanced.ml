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
  |> command "start" (fun ctx _args ->
      ignore (Ctx.reply ctx "👋 Hello! Send me any message and I'll echo it back.")
    )
  |> command "help" (fun ctx _args ->
      ignore (Ctx.reply ctx "Just send me text and I'll echo it!")
    )
  |> on_text (fun ctx text ->
      (* Echo all non-command text messages *)
      ignore (Ctx.reply ctx (Printf.sprintf "You said: %s" text))
    )
  |> run
