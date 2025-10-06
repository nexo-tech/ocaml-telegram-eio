(** Simple echo bot using long polling.

    This example demonstrates:
    - Setting up a bot client with environment token
    - Using long polling to receive updates
    - Basic message handling and responding
    - Clean error handling

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/echo_bot.exe
*)

let () =
  (* Get bot token from environment *)
  let token =
    match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None ->
        Printf.eprintf "Error: TELEGRAM_BOT_TOKEN environment variable not set\n";
        Printf.eprintf "Usage: export TELEGRAM_BOT_TOKEN=\"your_token\" && dune exec examples/echo_bot.exe\n";
        exit 1
  in

  (* Run with Eio *)
  Eio_main.run @@ fun env ->

  (* Create bot client *)
  let client = Telegram.Client.create ~env ~token () in

  (* Print bot info *)
  (match Telegram_generated.Gen_methods.get_me client () with
   | Ok me ->
       Printf.printf "Bot started: @%s (%s)\n"
         (Option.value me.Telegram_generated.Gen_types.User.username ~default:"unknown")
         me.Telegram_generated.Gen_types.User.first_name;
       Printf.printf "Send me a message and I'll echo it back!\n";
       flush stdout
   | Error err ->
       Printf.eprintf "Failed to get bot info: %s\n" (Format.asprintf "%a" Telegram.Error.pp err);
       exit 1
  );

  (* Define message handler *)
  let handle_update update =
    let open Telegram_generated.Gen_types in
    match update.Update.message with
    | Some msg ->
        (* Extract chat and text *)
        let chat_id_raw = msg.Message.chat.Chat.id in
        let chat_id = Telegram.Id.Chat.of_int chat_id_raw in
        let text = Option.value msg.Message.text ~default:"" in

        (* Ignore empty messages *)
        if text <> "" then (
          Printf.printf "Received: %s\n" text;
          flush stdout;

          (* Echo back *)
          let response_text = "You said: " ^ text in

          match Telegram_generated.Gen_methods.send_message client ~chat_id ~text:response_text () with
          | Ok _ -> ()
          | Error err ->
              Printf.eprintf "Failed to send message: %s\n" (Format.asprintf "%a" Telegram.Error.pp err)
        )
    | None -> ()
  in

  (* Start polling *)
  Printf.printf "Polling for updates...\n";
  flush stdout;

  Tg.Polling.run client ~handler:handle_update
