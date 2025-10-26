(** Interactive keyboard bot with inline and reply keyboards.

    This example demonstrates:
    - Reply keyboard creation using generated types
    - Inline keyboard with callback buttons
    - Callback query handling
    - Keyboard removal
    - Hierarchical namespace-based logging

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/keyboard_bot.exe

    Debugging with hierarchical namespaces:
      The library uses hierarchical namespaces that inherit log levels:
        - "telegram" (root) - all library logs
        - "telegram.client" - client operations
        - "telegram.client.http" - HTTP operations (inherits from telegram.client)
        - "telegram.api" - API method calls
        - "telegram.polling" - polling operations

      Examples:
        - Flo.set_level_for "telegram.client" Severity.Debug
          → Also enables debug for "telegram.client.http" (child namespace)
        - Flo.set_level_for "telegram.client.http" Severity.Warn
          → Overrides parent to reduce HTTP noise
*)

(* Configure logging with hierarchical namespace control *)
let () =
  (* Default level for all logs *)
  Flo.set_level Severity.Info;

  (* Example 1: Enable debug for entire client subsystem (includes HTTP) *)
  (* Flo.set_level_for "telegram.client" Severity.Debug; *)

  (* Example 2: Hierarchical override - quiet HTTP but keep client debug *)
  (* Flo.set_level_for "telegram.client" Severity.Debug; *)
  (* Flo.set_level_for "telegram.client.http" Severity.Warn; *)

  (* Example 3: Debug only specific components *)
  (* Flo.set_level_for "telegram.polling" Severity.Debug; *)
  (* Flo.set_level_for "telegram.api" Severity.Debug; *)

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
       Flo.info_fields "Keyboard bot started" ~fields:[
         ("username", Flo.Value.string (Option.value me.Telegram_generated.Gen_types.User.username ~default:""));
       ];
       Flo.info "Commands:";
       Flo.info "  /start - Welcome message";
       Flo.info "  /help - Show help"
   | Error err ->
       Flo.error_fields "Failed to start bot" ~fields:[
         Flo_semconv.error_message (Format.asprintf "%a" Telegram.Error.pp err);
       ];
       exit 1
  );

  (* Helper to send message *)
  let send_message client chat_id text =
    match Telegram_generated.Gen_methods.send_message client ~chat_id ~text () with
    | Ok _ -> Flo.debug "Message sent successfully"
    | Error err ->
        Flo.error_fields "Failed to send message" ~fields:[
          Flo_semconv.error_message (Format.asprintf "%a" Telegram.Error.pp err);
        ]
  in

  (* Update handler *)
  let handle_update update =
    let open Telegram_generated.Gen_types in

    (* Handle callback queries (inline keyboard button presses) *)
    (match update.Update.callback_query with
     | Some callback ->
         let callback_id = callback.CallbackQuery.id in
         let data = Option.value callback.CallbackQuery.data ~default:"" in

         Flo.info_fields "Callback received" ~fields:[
           ("data", Flo.Value.string data);
         ];

         (* Answer the callback *)
         let response_text = "Button clicked: " ^ data in
         (match Telegram_generated.Gen_methods.answer_callback_query client ~callback_query_id:callback_id ~text:response_text () with
          | Ok _ -> Flo.debug "Callback answered successfully"
          | Error err ->
              Flo.error_fields "Failed to answer callback" ~fields:[
                Flo_semconv.error_message (Format.asprintf "%a" Telegram.Error.pp err);
              ])
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
           Flo.info_fields "Text message received" ~fields:[
             ("text", Flo.Value.string text);
           ];
           send_message client chat_id ("You said: " ^ text)
         )
     | None -> ())
  in

  Flo.info "Polling for updates...";

  Tg.Polling.run client ~handler:handle_update
