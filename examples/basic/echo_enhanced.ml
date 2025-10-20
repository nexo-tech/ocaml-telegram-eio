(** Enhanced echo bot with command routing

    This example demonstrates handling multiple commands and echoing messages.
    Based on the example from getting_started.mld (lines 232-250).
    Uses the functional builder pattern API for clean, elegant code.

    This example has VERBOSE LOGGING enabled to help troubleshoot issues.
    Every step is logged using the flo library with structured fields.

    Commands:
      /start - Welcome message
      /help - Show help text
      <any text> - Echo it back

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/echo_enhanced.exe

    What you'll see in the logs:
      - Bot initialization and configuration loading
      - Route registration (commands and text handler)
      - Polling loop with update IDs
      - Route matching for each update
      - Handler execution with timing
      - API calls (sendMessage) with results
*)

open Telegram
open Tg

(* Configure verbose logging with flo *)
let () = Flo.set_level Severity.Debug  (* Enable debug logging *)

let () =
  (* Open flo for convenient logging functions *)
  let open Flo in

  info "=== Enhanced Echo Bot Starting ===";
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
        debug_fields "Token details" ~fields:[
          ("prefix", Value.string (String.sub t 0 (min 8 (String.length t))));
          ("suffix", Value.string (if String.length t > 8 then String.sub t (String.length t - 4) 4 else ""));
        ];
        t
    | None ->
        fatal "TELEGRAM_BOT_TOKEN environment variable not set";
        Printf.eprintf "Error: TELEGRAM_BOT_TOKEN not set\n";
        exit 1
  in

  info "Starting Eio event loop...";
  Eio_main.run @@ fun env ->

  info "Creating Telegram HTTP client...";
  let client = Client.create ~env ~token () in
  success_fields "HTTP client created" ~fields:[
    ("base_url", Value.string (Client.base_url client));
  ];

  info "🤖 Enhanced Echo Bot Started!";
  info "📋 Available commands:";
  info "   /start - Welcome message";
  info "   /help  - Show help text";
  info "   <text> - Echo any message back";
  info "🔍 Watching for updates (long polling)...";

  (* Build bot using functional builder pattern *)
  debug "Registering routes...";
  Bot.make ~env ~client
  (* Add global error handler to catch and log all errors *)
  |> Bot.on_error (fun ctx exn ->
      error_fields "Uncaught error in handler" ~fields:[
        Flo_semconv.error_type (Printexc.to_string exn);
        Flo_semconv.error_message (Printexc.to_string exn);
        Flo_semconv.error_stack_trace (Printexc.get_backtrace ());
        ("user_id", Value.string (match Bot.Ctx.user ctx with
         | Some u -> Id.to_string u.id
         | None -> "none"));
        ("username", Value.string (match Bot.Ctx.user ctx with
         | Some u -> Option.value ~default:"<none>" u.username
         | None -> "none"));
        ("chat_id", Value.string (Id.to_string (Bot.Ctx.chat ctx)));
        ("message_id", Value.string (string_of_int (Bot.Ctx.message ctx).message_id));
        ("message_text", Value.string (Option.value ~default:"<none>" (Bot.Ctx.message ctx).text));
      ];
      (* Try to notify user about the error *)
      debug "Attempting to send error notification to user...";
      match Bot.Ctx.reply ctx "❌ Sorry, an error occurred. Please try again." with
      | Ok _ -> success "Error notification sent"
      | Error e -> warn_fields "Failed to send error message" ~fields:[
          Flo_semconv.error_message (Format.asprintf "%a" Error.pp e);
        ]
    )
  |> (fun bot -> debug "Registering route: command 'start'"; bot)
  |> Bot.command "start" (fun ctx _args ->
      (* Use span for distributed tracing *)
      Flo.with_span "command_start" (fun () ->
        (* Bind handler context for structured logging *)
        Bot.Ctx.with_handler_context ctx (fun () ->
          info "Received /start command";
          debug_fields "Request context" ~fields:[
            ("username", Value.string (match Bot.Ctx.user ctx with
             | Some u -> Option.value ~default:"<none>" u.username
             | None -> "<none>"));
          ];

          let open Bot.Ctx in
          let* () = reply_ ctx "👋 Hello! Send me any message and I'll echo it back." in
          success "Handler completed successfully";
          Ok ()
        )
      )
    )
  |> (fun bot -> debug "Registering route: command 'help'"; bot)
  |> Bot.command "help" (fun ctx _args ->
      (* Use span for distributed tracing *)
      Flo.with_span "command_help" (fun () ->
        (* Bind handler context for structured logging *)
        Bot.Ctx.with_handler_context ctx (fun () ->
          info "Received /help command";
          debug_fields "Request context" ~fields:[
            ("username", Value.string (match Bot.Ctx.user ctx with
             | Some u -> Option.value ~default:"<none>" u.username
             | None -> "<none>"));
          ];

          let open Bot.Ctx in
          let* () = reply_ ctx "Just send me text and I'll echo it!" in
          success "Handler completed successfully";
          Ok ()
        )
      )
    )
  |> (fun bot -> debug "Registering route: on_text (echo handler)"; bot)
  |> Bot.on_text (fun ctx text ->
      (* Use span for distributed tracing *)
      Flo.with_span "echo_enhanced" (fun () ->
        (* Bind handler context for structured logging *)
        Bot.Ctx.with_handler_context ctx (fun () ->
          info_fields "Received text message" ~fields:[
            ("text_length", Value.int (String.length text));
            ("username", Value.string (match Bot.Ctx.user ctx with
             | Some u -> Option.value ~default:"<none>" u.username
             | None -> "<none>"));
          ];
          debug_fields "Message content" ~fields:[
            ("text_preview", Value.string (if String.length text > 50
              then String.sub text 0 50 ^ "..."
              else text));
          ];

          (* Check for entities in the message *)
          let entities = Bot.Ctx.entities ctx in
          if List.length entities > 0 then (
            debug_fields "Message contains entities" ~fields:[
              ("entity_count", Value.int (List.length entities));
            ];
            List.iter (fun entity ->
              let entity_type_str = match entity.Bot.Entity.entity_type with
                | Bot.Entity.Mention -> "mention"
                | Bot.Entity.Hashtag -> "hashtag"
                | Bot.Entity.Cashtag -> "cashtag"
                | Bot.Entity.BotCommand -> "bot_command"
                | Bot.Entity.Url -> "url"
                | Bot.Entity.Email -> "email"
                | Bot.Entity.PhoneNumber -> "phone_number"
                | Bot.Entity.Bold -> "bold"
                | Bot.Entity.Italic -> "italic"
                | Bot.Entity.Underline -> "underline"
                | Bot.Entity.Strikethrough -> "strikethrough"
                | Bot.Entity.Spoiler -> "spoiler"
                | Bot.Entity.Code -> "code"
                | Bot.Entity.Pre -> "pre"
                | Bot.Entity.TextLink _ -> "text_link"
                | Bot.Entity.TextMention _ -> "text_mention"
                | Bot.Entity.CustomEmoji _ -> "custom_emoji"
                | Bot.Entity.Other _ -> "other"
              in
              trace_fields "Entity parsed" ~fields:[
                ("entity_type", Value.string entity_type_str);
                ("offset", Value.int entity.offset);
                ("length", Value.int entity.length);
                ("text", Value.string entity.text);
              ]
            ) entities
          );

          (* Echo all non-command text messages *)
          let response = Printf.sprintf "You said: %s" text in
          debug "Echoing message back to user...";

          let open Bot.Ctx in
          let* () = reply_ ctx response in
          success "Echo handler completed successfully";
          Ok ()
        )
      )
    )
  |> (fun bot ->
      debug "All routes registered";
      info "Starting bot...";
      bot
    )
  |> Bot.run
