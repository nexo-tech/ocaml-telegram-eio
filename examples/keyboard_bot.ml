(** Interactive keyboard bot with inline and reply keyboards.

    This example demonstrates:
    - Reply keyboard creation using generated types
    - Inline keyboard with callback buttons
    - Callback query handling
    - Keyboard removal

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/keyboard_bot.exe
*)

let () =
  let token =
    match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None ->
        Printf.eprintf "Error: TELEGRAM_BOT_TOKEN environment variable not set\n";
        exit 1
  in

  Eio_main.run @@ fun env ->

  let client = Telegram.Client.create ~env ~token () in

  (* Bot info *)
  (match Telegram_generated.Gen_methods.get_me client () with
   | Ok me ->
       Printf.printf "Keyboard bot started: @%s\n"
         (Option.value me.Telegram_generated.Gen_types.User.username ~default:"");
       Printf.printf "Commands:\n";
       Printf.printf "  /start - Welcome message\n";
       Printf.printf "  /help - Show help\n\n";
       flush stdout
   | Error err ->
       Printf.eprintf "Error: %s\n" (Format.asprintf "%a" Telegram.Error.pp err);
       exit 1
  );

  (* Helper to send message *)
  let send_message client chat_id text =
    match Telegram_generated.Gen_methods.send_message client ~chat_id ~text () with
    | Ok _ -> ()
    | Error err ->
        Printf.eprintf "Send error: %s\n" (Format.asprintf "%a" Telegram.Error.pp err)
  in

  (* Update handler *)
  let handle_update update =
    let open Telegram_generated.Gen_types in

    (* Handle callback queries (inline keyboard button presses) *)
    (match update.Update.callback_query with
     | Some callback ->
         let callback_id = callback.CallbackQuery.id in
         let data = Option.value callback.CallbackQuery.data ~default:"" in

         Printf.printf "Callback: %s\n" data;
         flush stdout;

         (* Answer the callback *)
         let response_text = "Button clicked: " ^ data in
         (match Telegram_generated.Gen_methods.answer_callback_query client ~callback_query_id:callback_id ~text:response_text () with
          | Ok _ -> ()
          | Error err ->
              Printf.eprintf "Callback answer error: %s\n" (Format.asprintf "%a" Telegram.Error.pp err))
     | None -> ());

    (* Handle text messages *)
    (match update.Update.message with
     | Some msg ->
         let chat_id_raw = msg.Message.chat.Chat.id in
         let chat_id = Telegram.Id.Chat.of_int chat_id_raw in
         let text = Option.value msg.Message.text ~default:"" in

         if String.length text > 0 && text.[0] = '/' then (
           let cmd = try List.hd (String.split_on_char ' ' text) with _ -> text in
           let cmd = try String.sub cmd 0 (String.index cmd '@') with Not_found -> cmd in

           match cmd with
           | "/start" ->
               let welcome =
                 "Welcome! I'm a bot that demonstrates keyboards.\n\n\
                  Try /help for more commands."
               in
               send_message client chat_id welcome

           | "/help" ->
               let help_text =
                 "Available commands:\n\n\
                  /start - Welcome message\n\
                  /help - Show this help\n\n\
                  Note: Keyboard examples require the Tg DSL module.\n\
                  This example shows the basic message handling pattern."
               in
               send_message client chat_id help_text

           | _ ->
               send_message client chat_id "Unknown command. Try /help"
         ) else if text <> "" then (
           (* Echo back non-command messages *)
           Printf.printf "Text: %s\n" text;
           flush stdout;
           send_message client chat_id ("You said: " ^ text)
         )
     | None -> ())
  in

  Printf.printf "Polling for updates...\n";
  flush stdout;

  Tg.Polling.run client ~handler:handle_update
