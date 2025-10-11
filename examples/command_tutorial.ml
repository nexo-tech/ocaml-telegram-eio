(** Command Bot Tutorial - from quick_start.mld tutorials 1-2

    This bot demonstrates:
    - Echo functionality
    - Command parsing and routing
    - Argument handling
    - Pattern matching on commands
    - Using elegant API pattern (Api.send_message + Api.call)

    Commands:
      /start - Welcome message with command list
      /help - Show help information
      /echo <text> - Echo back the text
      /add <a> <b> - Add two numbers
      <any text> - Echo it back

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/command_tutorial.exe
*)

let () =
  (* Get bot token *)
  let token =
    match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None ->
        Printf.eprintf "Error: TELEGRAM_BOT_TOKEN not set\n";
        exit 1
  in

  (* Start Eio runtime *)
  Eio_main.run @@ fun env ->

  (* Create HTTP client *)
  let client = Telegram.Client.create ~env ~token () in

  Printf.printf "Command bot started!\n";
  Printf.printf "Commands:\n";
  Printf.printf "  /start - Welcome message\n";
  Printf.printf "  /help - Show help\n";
  Printf.printf "  /echo <text> - Echo your text\n";
  Printf.printf "  /add <a> <b> - Add two numbers\n\n";
  flush stdout;

  (* Define update handler *)
  let handle_update update =
    let open Telegram_generated.Gen_types in
    match update.Update.message with
    | Some msg ->
        (* Extract chat ID and text *)
        let chat_id_raw = msg.Message.chat.Chat.id in
        let chat_id = Telegram.Id.Chat.of_int chat_id_raw in
        let text = Option.value msg.Message.text ~default:"" in

        if text <> "" then (
          (* Determine response based on message content *)
          let reply_text =
            if String.starts_with ~prefix:"/" text then
              (* Parse command *)
              match String.split_on_char ' ' text with
              | "/start" :: _ ->
                  "👋 Welcome! I can:\n\
                   /start - Show this message\n\
                   /help - Get help\n\
                   /echo <text> - Echo your text\n\
                   /add <a> <b> - Add two numbers"

              | "/help" :: _ ->
                  "Send me /echo followed by text, or /add with two numbers!"

              | "/echo" :: rest ->
                  (* Join remaining words *)
                  let echo_text = String.concat " " rest in
                  if echo_text = "" then
                    "Usage: /echo <text>\nExample: /echo Hello world"
                  else
                    echo_text

              | "/add" :: a :: b :: _ ->
                  (* Try to parse as integers *)
                  (match int_of_string_opt a, int_of_string_opt b with
                   | Some x, Some y ->
                       Printf.sprintf "%d + %d = %d" x y (x + y)
                   | _ ->
                       "❌ Please provide two numbers.\nUsage: /add 5 3")

              | "/add" :: _ ->
                  "❌ Usage: /add <number1> <number2>\nExample: /add 5 3"

              | cmd :: _ ->
                  Printf.sprintf "❌ Unknown command: %s\nTry /help" cmd

              | [] ->
                  "❌ Empty command"
            else
              (* Regular text - echo it *)
              "You said: " ^ text
          in

          (* Send reply using elegant API pattern *)
          let request = Telegram.Api.send_message ~chat_id ~text:reply_text () in
          match Telegram.Api.call client request with
          | Ok _ -> ()
          | Error err ->
              Printf.eprintf "Error: %s\n" (Format.asprintf "%a" Telegram.Error.pp err)
        )

    | _ -> ()
  in

  (* Start polling *)
  Printf.printf "Polling for updates...\n";
  flush stdout;

  Tg.Polling.run client ~handler:handle_update
