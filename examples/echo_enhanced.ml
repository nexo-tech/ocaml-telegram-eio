(** Enhanced echo bot with command routing

    This example demonstrates handling multiple commands and echoing messages.
    Based on the example from getting_started.mld (lines 232-250).

    Commands:
      /start - Welcome message
      /help - Show help text
      <any text> - Echo it back

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/echo_enhanced.exe
*)

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

  let handle_update update =
    let open Telegram_generated.Gen_types in
    match update.Update.message with
    | Some msg ->
        let chat_id_raw = msg.Message.chat.Chat.id in
        let chat_id = Telegram.Id.Chat.of_int chat_id_raw in
        let text = Option.value msg.Message.text ~default:"" in

        if text <> "" then (
          (* Handle different commands *)
          let reply = match text with
            | "/start" -> "👋 Hello! Send me any message and I'll echo it back."
            | "/help" -> "Just send me text and I'll echo it!"
            | _ -> Printf.sprintf "You said: %s" text
          in

          let request = Telegram.Api.send_message ~chat_id ~text:reply () in
          match Telegram.Api.call client request with
          | Ok _ -> ()
          | Error err ->
              Printf.eprintf "Error: %s\n" (Format.asprintf "%a" Telegram.Error.pp err)
        )

    | _ -> ()
  in

  Tg.Polling.run client ~handler:handle_update
