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

(* Configure verbose logging *)
let () = Flo.set_level Severity.Info

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
       Flo.info_fields "Bot started" ~fields:[
         ("username", Flo.Value.string (Option.value me.Telegram_generated.Gen_types.User.username ~default:"unknown"));
         ("first_name", Flo.Value.string me.Telegram_generated.Gen_types.User.first_name);
       ];
       Flo.info "Send me a message and I'll echo it back!"
   | Error err ->
       Flo.error_fields "Failed to get bot info" ~fields:[
         Flo_semconv.error_message (Format.asprintf "%a" Telegram.Error.pp err);
       ];
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
          Flo.info_fields "Received message" ~fields:[
            ("text", Flo.Value.string text);
          ];

          (* Echo back *)
          let response_text = "You said: " ^ text in

          match Telegram_generated.Gen_methods.send_message client ~chat_id ~text:response_text () with
          | Ok _ -> Flo.debug "Echo sent successfully"
          | Error err ->
              Flo.error_fields "Failed to send message" ~fields:[
                Flo_semconv.error_message (Format.asprintf "%a" Telegram.Error.pp err);
              ]
        )
    | None -> ()
  in

  (* Start polling *)
  Flo.info "Polling for updates...";

  Tg.Polling.run client ~handler:handle_update
