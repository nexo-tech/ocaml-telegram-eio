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
      match Ctx.reply ctx "👋 Hello! Send me any message and I'll echo it back." with
      | Ok _ -> ()
      | Error err -> Eio.traceln "Error: %a" Telegram.Error.pp err
    )
  |> command "help" (fun ctx _args ->
      match Ctx.reply ctx "Just send me text and I'll echo it!" with
      | Ok _ -> ()
      | Error err -> Eio.traceln "Error: %a" Telegram.Error.pp err
    )
  |> on_text (fun ctx text ->
      (* Echo all non-command text messages *)
      match Ctx.reply ctx (Printf.sprintf "You said: %s" text) with
      | Ok _ -> ()
      | Error err -> Eio.traceln "Error: %a" Telegram.Error.pp err
    )
  |> run
