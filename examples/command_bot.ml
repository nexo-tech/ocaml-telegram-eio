(** Command bot with routing and argument parsing.

    This example demonstrates:
    - Bot DSL with event routing
    - Command parsing with arguments
    - Multiple command handlers
    - Help command generation
    - Error handling in handlers

    Commands:
      /start - Welcome message
      /help - List all commands
      /echo <text> - Echo back the text
      /add <num1> <num2> - Add two numbers
      /upper <text> - Convert text to uppercase

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/command_bot.exe
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

  (* Get bot info and display commands *)
  (match Telegram_generated.Gen_methods.get_me client () with
   | Ok me ->
       let username = Option.value me.Telegram_generated.Gen_types.User.username ~default:"" in
       Printf.printf "Bot started: @%s\n" username;
       Printf.printf "Available commands:\n";
       Printf.printf "  /start - Welcome message\n";
       Printf.printf "  /help - List all commands\n";
       Printf.printf "  /echo <text> - Echo the text\n";
       Printf.printf "  /add <num1> <num2> - Add two numbers\n";
       Printf.printf "  /upper <text> - Convert to uppercase\n\n";
       flush stdout
   | Error err ->
       Printf.eprintf "Failed to get bot info: %s\n" (Format.asprintf "%a" Telegram.Error.pp err);
       exit 1
  );

  (* Helper to send reply *)
  let send_reply client chat_id text =
    match Telegram_generated.Gen_methods.send_message client ~chat_id ~text () with
    | Ok _ -> ()
    | Error err ->
        Printf.eprintf "Send error: %s\n" (Format.asprintf "%a" Telegram.Error.pp err)
  in

  (* Define update handler *)
  let handle_update update =
    let open Telegram_generated.Gen_types in
    match update.Update.message with
    | Some msg ->
        let chat_id_raw = msg.Message.chat.Chat.id in
        let chat_id = Telegram.Id.Chat.of_int chat_id_raw in
        let text = Option.value msg.Message.text ~default:"" in

        (* Parse command *)
        if String.length text > 0 && text.[0] = '/' then (
          (* Extract command and args *)
          let parts = String.split_on_char ' ' text in
          let cmd = List.hd parts in
          let args = List.tl parts in

          (* Remove bot username from command if present (e.g., /start@botname) *)
          let cmd =
            try
              let at_idx = String.index cmd '@' in
              String.sub cmd 0 at_idx
            with Not_found -> cmd
          in

          Printf.printf "Command: %s, Args: %d\n" cmd (List.length args);
          flush stdout;

          match cmd with
          | "/start" ->
              let welcome = Printf.sprintf
                "Welcome! I'm a command bot.\n\n\
                 Try these commands:\n\
                 /help - Show all commands\n\
                 /echo <text> - Echo your message\n\
                 /add <num1> <num2> - Add numbers\n\
                 /upper <text> - Uppercase text"
              in
              send_reply client chat_id welcome

          | "/help" ->
              let help_text =
                "Available commands:\n\n\
                 /start - Welcome message\n\
                 /help - Show this help\n\
                 /echo <text> - Echo back your text\n\
                 /add <num1> <num2> - Add two numbers\n\
                 /upper <text> - Convert text to UPPERCASE\n\n\
                 Example: /add 5 3"
              in
              send_reply client chat_id help_text

          | "/echo" ->
              let text = String.concat " " args in
              if text = "" then
                send_reply client chat_id "Usage: /echo <text>"
              else
                send_reply client chat_id text

          | "/add" ->
              (match args with
               | [a; b] ->
                   (match int_of_string_opt a, int_of_string_opt b with
                    | Some x, Some y ->
                        let result = x + y in
                        send_reply client chat_id (Printf.sprintf "%d + %d = %d" x y result)
                    | _ ->
                        send_reply client chat_id "Error: Both arguments must be numbers")
               | _ ->
                   send_reply client chat_id "Usage: /add <number1> <number2>\nExample: /add 5 3")

          | "/upper" ->
              let text = String.concat " " args in
              if text = "" then
                send_reply client chat_id "Usage: /upper <text>"
              else
                send_reply client chat_id (String.uppercase_ascii text)

          | _ ->
              send_reply client chat_id "Unknown command. Try /help"
        )

    | None -> ()
  in

  Printf.printf "Polling for updates...\n";
  flush stdout;

  Tg.Polling.run client ~handler:handle_update
