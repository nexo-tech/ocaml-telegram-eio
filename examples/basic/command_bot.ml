(** Command bot with routing and argument parsing.

    This example demonstrates:
    - Bot DSL with event routing
    - Command parsing with arguments
    - Multiple command handlers
    - Help command generation
    - Error handling in handlers

    This example has VERBOSE LOGGING enabled to help troubleshoot issues.
    Every step is logged using the flo library with structured fields.

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

(* Configure verbose logging with flo *)
let () = Flo.set_level Severity.Debug  (* Enable debug logging *)

let () =
  let open Flo in

  [%log.info "=== Command Bot Starting ==="];
  info_fields "Initializing bot" ~fields:[
    ("stage", Value.string "startup");
  ];

  let token =
    match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t ->
        info_fields "Bot token loaded" ~fields:[
          ("source", Value.string "TELEGRAM_BOT_TOKEN");
          ("token_length", Value.int (String.length t));
        ];
        t
    | None ->
        fatal "TELEGRAM_BOT_TOKEN environment variable not set";
        Printf.eprintf "Error: TELEGRAM_BOT_TOKEN not set\n";
        exit 1
  in

  [%log.info "Starting Eio event loop..."];
  Eio_main.run @@ fun env ->

  [%log.info "Creating Telegram HTTP client..."];
  let client = Telegram.Client.create ~env ~token () in
  success_fields "HTTP client created" ~fields:[
    ("base_url", Value.string (Telegram.Client.base_url client));
  ];

  (* Get bot info and display commands *)
  (match Telegram_generated.Gen_methods.get_me client () with
   | Ok me ->
       let username = Option.value me.Telegram_generated.Gen_types.User.username ~default:"" in
       success_fields "Bot started" ~fields:[
         ("username", Value.string ("@" ^ username));
       ];
       info "Available commands:";
       info "  /start - Welcome message";
       info "  /help - List all commands";
       info "  /echo <text> - Echo the text";
       info "  /add <num1> <num2> - Add two numbers";
       info "  /upper <text> - Convert to uppercase";
   | Error err ->
       fatal_fields "Failed to get bot info" ~fields:[
         Flo_semconv.error_message (Format.asprintf "%a" Telegram.Error.pp err);
       ];
       exit 1
  );

  (* Helper to send reply *)
  let send_reply client chat_id text =
    match Telegram_generated.Gen_methods.send_message client ~chat_id ~text () with
    | Ok msg ->
        success_fields "Message sent" ~fields:[
          ("message_id", Value.int (Int64.to_int msg.Telegram_generated.Gen_types.Message.message_id));
          ("chat_id", Value.string (Telegram.Id.to_string chat_id));
        ]
    | Error err ->
        error_fields "Send error" ~fields:[
          Flo_semconv.error_message (Format.asprintf "%a" Telegram.Error.pp err);
          ("chat_id", Value.string (Telegram.Id.to_string chat_id));
        ]
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

          info_fields "Command received" ~fields:[
            ("command", Value.string cmd);
            ("args_count", Value.int (List.length args));
            ("chat_id", Value.string (Telegram.Id.to_string chat_id));
          ];

          match cmd with
          | "/start" ->
              (* Use span for distributed tracing *)
              Flo.with_span "command_start" (fun () ->
                debug "Executing /start command";
                let welcome = Printf.sprintf
                  "Welcome! I'm a command bot.\n\n\
                   Try these commands:\n\
                   /help - Show all commands\n\
                   /echo <text> - Echo your message\n\
                   /add <num1> <num2> - Add numbers\n\
                   /upper <text> - Uppercase text"
                in
                send_reply client chat_id welcome;
                success "Command /start completed"
              )

          | "/help" ->
              Flo.with_span "command_help" (fun () ->
                debug "Executing /help command";
                let help_text =
                  "Available commands:\n\n\
                   /start - Welcome message\n\
                   /help - Show this help\n\
                   /echo <text> - Echo back your text\n\
                   /add <num1> <num2> - Add two numbers\n\
                   /upper <text> - Convert text to UPPERCASE\n\n\
                   Example: /add 5 3"
                in
                send_reply client chat_id help_text;
                success "Command /help completed"
              )

          | "/echo" ->
              Flo.with_span "command_echo" (fun () ->
                let text = String.concat " " args in
                debug_fields "Executing /echo command" ~fields:[
                  ("text_length", Value.int (String.length text));
                ];
                if text = "" then (
                  send_reply client chat_id "Usage: /echo <text>";
                  warn "Echo command called without arguments"
                ) else (
                  send_reply client chat_id text;
                  success_fields "Command /echo completed" ~fields:[
                    ("echoed_text_length", Value.int (String.length text));
                  ]
                )
              )

          | "/add" ->
              Flo.with_span "command_add" (fun () ->
                debug_fields "Executing /add command" ~fields:[
                  ("args", Value.string (String.concat " " args));
                ];
                match args with
                | [a; b] ->
                    (match int_of_string_opt a, int_of_string_opt b with
                     | Some x, Some y ->
                         let result = x + y in
                         debug_fields "Addition calculation" ~fields:[
                           ("operand1", Value.int x);
                           ("operand2", Value.int y);
                           ("result", Value.int result);
                         ];
                         send_reply client chat_id (Printf.sprintf "%d + %d = %d" x y result);
                         success_fields "Command /add completed" ~fields:[
                           ("result", Value.int result);
                         ]
                     | _ ->
                         send_reply client chat_id "Error: Both arguments must be numbers";
                         warn_fields "Add command failed - invalid arguments" ~fields:[
                           ("arg1", Value.string a);
                           ("arg2", Value.string b);
                         ])
                | _ ->
                    send_reply client chat_id "Usage: /add <number1> <number2>\nExample: /add 5 3";
                    warn_fields "Add command called with wrong number of arguments" ~fields:[
                      ("args_count", Value.int (List.length args));
                    ]
              )

          | "/upper" ->
              Flo.with_span "command_upper" (fun () ->
                let text = String.concat " " args in
                debug_fields "Executing /upper command" ~fields:[
                  ("text_length", Value.int (String.length text));
                ];
                if text = "" then (
                  send_reply client chat_id "Usage: /upper <text>";
                  warn "Upper command called without arguments"
                ) else (
                  let uppercase = String.uppercase_ascii text in
                  send_reply client chat_id uppercase;
                  success_fields "Command /upper completed" ~fields:[
                    ("original_length", Value.int (String.length text));
                  ]
                )
              )

          | _ ->
              warn_fields "Unknown command" ~fields:[
                ("command", Value.string cmd);
              ];
              send_reply client chat_id "Unknown command. Try /help"
        )

    | None -> ()
  in

  [%log.info "🤖 Command Bot Started!"];
  [%log.info "🔍 Watching for updates (long polling)..."];

  Tg.Polling.run client ~handler:handle_update
