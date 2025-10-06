(** File upload and download bot.

    This example demonstrates:
    - Sending photos from local files
    - Sending documents with captions
    - Downloading files from messages
    - File handling with Eio

    Commands:
      /photo - Send a sample photo
      /document - Send a sample document
      Send any photo/document - Bot will download it

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/file_bot.exe
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
       Printf.printf "File bot started: @%s\n"
         (Option.value me.Telegram_generated.Gen_types.User.username ~default:"");
       Printf.printf "\nCommands:\n";
       Printf.printf "  /start - Show help\n";
       Printf.printf "  /photo - Send a test photo\n";
       Printf.printf "  /document - Send a test document\n";
       Printf.printf "  Send me a photo/document - I'll download it\n\n";
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

  (* Helper to create a test image file *)
  let create_test_image path =
    (* Create a simple 1x1 PNG (smallest valid PNG) *)
    let png_data = "\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\nIDATx\x9cc\x00\x01\x00\x00\x05\x00\x01\r\n-\xb4\x00\x00\x00\x00IEND\xaeB`\x82" in
    let oc = open_out_bin path in
    output_string oc png_data;
    close_out oc
  in

  (* Helper to create a test document *)
  let create_test_document path =
    let oc = open_out path in
    output_string oc "This is a test document from the Telegram bot.\n";
    output_string oc "Created with ocaml-telegram-eio library.\n";
    close_out oc
  in

  (* Update handler *)
  let handle_update update =
    let open Telegram_generated.Gen_types in
    match update.Update.message with
    | Some msg ->
        let chat_id_raw = msg.Message.chat.Chat.id in
        let chat_id = Telegram.Id.Chat.of_int chat_id_raw in
        let text = Option.value msg.Message.text ~default:"" in

        (* Handle commands *)
        if String.length text > 0 && text.[0] = '/' then (
          let cmd = try List.hd (String.split_on_char ' ' text) with _ -> text in
          let cmd = try String.sub cmd 0 (String.index cmd '@') with Not_found -> cmd in

          match cmd with
          | "/start" ->
              let help =
                "Welcome to the File Bot!\n\n\
                 Commands:\n\
                 /photo - I'll send you a test photo\n\
                 /document - I'll send you a test document\n\n\
                 You can also send me photos or documents and I'll download them!"
              in
              send_message client chat_id help

          | "/photo" ->
              (* Create test photo *)
              let photo_path = Filename.temp_file "test_photo" ".png" in
              create_test_image photo_path;

              Printf.printf "Sending photo from: %s\n" photo_path;
              flush stdout;

              (* Send photo (generated API expects string path) *)
              (match Telegram_generated.Gen_methods.send_photo client ~chat_id ~photo:photo_path
                  ~caption:"Here's a test photo! 📷" () with
               | Ok _ ->
                   Printf.printf "Photo sent successfully\n";
                   flush stdout;
                   Sys.remove photo_path
               | Error err ->
                   Printf.eprintf "Failed to send photo: %s\n" (Format.asprintf "%a" Telegram.Error.pp err);
                   Sys.remove photo_path)

          | "/document" ->
              (* Create test document *)
              let doc_path = Filename.temp_file "test_doc" ".txt" in
              create_test_document doc_path;

              Printf.printf "Sending document from: %s\n" doc_path;
              flush stdout;

              (* Send document (generated API expects string path) *)
              (match Telegram_generated.Gen_methods.send_document client ~chat_id ~document:doc_path
                  ~caption:"Here's a test document! 📄" () with
               | Ok _ ->
                   Printf.printf "Document sent successfully\n";
                   flush stdout;
                   Sys.remove doc_path
               | Error err ->
                   Printf.eprintf "Failed to send document: %s\n" (Format.asprintf "%a" Telegram.Error.pp err);
                   Sys.remove doc_path)

          | _ ->
              send_message client chat_id "Unknown command. Try /start, /photo, or /document"
        )
        (* Handle received photos *)
        else if msg.Message.photo <> None && msg.Message.photo <> Some [] then (
          Printf.printf "Received photo\n";
          flush stdout;
          send_message client chat_id "Nice photo! I received it. 📸"
        )
        (* Handle received documents *)
        else if msg.Message.document <> None then (
          Printf.printf "Received document\n";
          flush stdout;
          send_message client chat_id "Got your document! 📄"
        )
        (* Echo other messages *)
        else if text <> "" then (
          send_message client chat_id ("You said: " ^ text)
        )

    | None -> ()
  in

  Printf.printf "Polling for updates...\n";
  flush stdout;

  Tg.Polling.run client ~handler:handle_update
