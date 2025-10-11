(** Hello World bot - minimal example from getting_started.mld

    This bot responds to /start command with a greeting message.
    Uses the functional builder pattern API for clean, elegant code.

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/hello_world.exe
*)

open Tg.Bot

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
  |> command "start" (fun ctx _args ->
      (* Reply to /start command - handle errors *)
      match Ctx.reply ctx "👋 Hello! I'm your first OCaml Telegram bot!" with
      | Ok _ -> ()
      | Error err ->
          Eio.traceln "Error sending message: %a" Telegram.Error.pp err
    )
  |> run
