(** Hello World bot - minimal example from getting_started.mld

    This bot responds to /start command with a greeting message.

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/hello_world.exe
*)

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

  (* Define how to handle incoming updates *)
  let handle_update update =
    let open Telegram_generated.Gen_types in
    (* Pattern match on update type *)
    match update.Update.message with
    | Some msg ->
        (* Extract chat ID and message text *)
        let chat_id_raw = msg.Message.chat.Chat.id in
        let chat_id = Telegram.Id.Chat.of_int chat_id_raw in
        let text = Option.value msg.Message.text ~default:"" in

        (* Respond to /start command *)
        if text = "/start" then
          let reply = "👋 Hello! I'm your first OCaml Telegram bot!" in
          let request = Telegram.Api.send_message ~chat_id ~text:reply () in
          (match Telegram.Api.call client request with
           | Ok _ -> ()
           | Error err ->
               Eio.traceln "Error: %s" (Format.asprintf "%a" Telegram.Error.pp err))

    | _ -> ()  (* Ignore non-message updates *)
  in

  (* Start long polling (blocking call) *)
  Tg.Polling.run client ~handler:handle_update
