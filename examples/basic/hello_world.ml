(** Hello World bot - minimal example from getting_started.mld

    This bot responds to /start command with a greeting message.
    Uses the functional builder pattern API for clean, elegant code.

    This example has VERBOSE LOGGING enabled to help troubleshoot issues.
    Every step is logged using the flo library with structured fields.

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/hello_world.exe

    What you'll see in the logs:
      - Bot initialization and token loading
      - Polling loop start
      - Each update received (update_id, type)
      - Command routing (matched/unmatched)
      - Handler execution (entry/exit)
      - API call results (success/error)
*)

open Telegram
open Tg

(* Configure verbose logging with flo *)
let () = Flo.set_level Severity.Debug  (* Enable debug logging *)

let () =
  (* Open flo for convenient logging functions *)
  let open Flo in

  (* PPX extension for simple logs - automatic location capture *)
  [%log.info "=== Hello World Bot Starting ==="];
  info_fields "Initializing bot" ~fields:[
    ("stage", Value.string "startup");
  ];

  (* Get bot token from environment *)
  let token =
    try
      let t = Sys.getenv "TELEGRAM_BOT_TOKEN" in
      info_fields "Bot token loaded" ~fields:[
        ("source", Value.string "TELEGRAM_BOT_TOKEN");
        ("token_length", Value.int (String.length t));
      ];
      debug_fields "Token details" ~fields:[
        ("prefix", Value.string (String.sub t 0 (min 8 (String.length t))));
        ("suffix", Value.string (if String.length t > 8 then String.sub t (String.length t - 4) 4 else ""));
      ];
      t
    with Not_found ->
      [%log.fatal "TELEGRAM_BOT_TOKEN environment variable not set"];
      failwith "TELEGRAM_BOT_TOKEN environment variable not set"
  in

  [%log.info "Starting Eio event loop..."];
  (* Start the Eio event loop *)
  Eio_main.run @@ fun env ->

  [%log.info "Creating Telegram HTTP client..."];
  (* Create HTTP client for Telegram API *)
  let client = Client.create ~env ~token () in
  success_fields "HTTP client created" ~fields:[
    ("base_url", Value.string (Client.base_url client));
  ];

  (* Print startup message *)
  [%log.info "🤖 Bot started successfully!"];
  [%log.info "📱 Send /start to the bot to interact"];
  [%log.info "🔍 Watching for updates (long polling)..."];

  (* Build bot using functional builder pattern with flo logging *)
  [%log.debug "Building bot with functional API..."];
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
        ("chat_id", Value.string (Id.to_string (Bot.Ctx.chat ctx)));
      ];
      (* Try to notify user about the error *)
      [%log.debug "Attempting to send error notification to user..."];
      match Bot.Ctx.reply ctx "Sorry, an error occurred. Please try again." with
      | Ok _ -> [%log.success "Error notification sent to user"]
      | Error e -> warn_fields "Failed to send error message" ~fields:[
          Flo_semconv.error_message (Format.asprintf "%a" Error.pp e);
        ]
    )
  |> Bot.command "start" (fun ctx _args ->
      (* Use span for distributed tracing *)
      Flo.with_span "handle_start" (fun () ->
        (* Bind handler context for structured logging *)
        Bot.Ctx.with_handler_context ctx (fun () ->
          [%log.info "Received /start command"];
          debug_fields "Request context" ~fields:[
            ("username", Value.string (match Bot.Ctx.user ctx with
             | Some u -> Option.value ~default:"<none>" u.username
             | None -> "<none>"));
          ];

          [%log.debug "Executing handler logic..."];
          (* Use Result-based error handling *)
          let open Bot.Ctx in
          let* () = reply_ ctx "👋 Hello! I'm your first OCaml Telegram bot!" in
          [%log.success "Handler completed successfully"];
          Ok ()
        )
      )
    )
  |> Bot.run
