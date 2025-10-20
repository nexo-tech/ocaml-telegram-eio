(** File upload and download bot.

    This example demonstrates:
    - Sending photos from local files
    - Sending documents with captions
    - Downloading files from messages
    - File handling with Eio

    This example has VERBOSE LOGGING enabled to help troubleshoot issues.
    Every step is logged using the flo library with structured fields.

    Commands:
      /photo - Send a sample photo
      /document - Send a sample document
      Send any photo/document - Bot will download it

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/file_bot.exe
*)

(* Configure verbose logging with flo *)
let () = Flo.set_level Severity.Debug  (* Enable debug logging *)

let () =
  let open Flo in

  info "=== File Bot Starting ===";
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

  info "Starting Eio event loop...";
  Eio_main.run @@ fun env ->

  info "Creating Telegram HTTP client...";
  let client = Telegram.Client.create ~env ~token () in
  success_fields "HTTP client created" ~fields:[
    ("base_url", Value.string (Telegram.Client.base_url client));
  ];

  (* Bot info *)
  (match Telegram_generated.Gen_methods.get_me client () with
   | Ok me ->
       let username = Option.value me.Telegram_generated.Gen_types.User.username ~default:"" in
       success_fields "File bot started" ~fields:[
         ("username", Value.string ("@" ^ username));
       ];
       info "Commands:";
       info "  /start - Show help";
       info "  /photo - Send a test photo";
       info "  /document - Send a test document";
       info "  Send me a photo/document - I'll download it";
   | Error err ->
       fatal_fields "Failed to get bot info" ~fields:[
         Flo_semconv.error_message (Format.asprintf "%a" Telegram.Error.pp err);
       ];
       exit 1
  );

  (* Helper to send message *)
  let send_message client chat_id text =
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

  (* Helper to create a test image file *)
  let create_test_image path =
    (* Create a simple 1x1 PNG (smallest valid PNG) *)
    let png_data = "\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\nIDATx\x9cc\x00\x01\x00\x00\x05\x00\x01\r\n-\xb4\x00\x00\x00\x00IEND\xaeB`\x82" in
    let oc = open_out_bin path in
    output_string oc png_data;
    close_out oc;
    debug_fields "Test image created" ~fields:[
      ("path", Value.string path);
      ("size_bytes", Value.int (String.length png_data));
    ]
  in

  (* Helper to create a test document *)
  let create_test_document path =
    let content = "This is a test document from the Telegram bot.\nCreated with ocaml-telegram-eio library.\n" in
    let oc = open_out path in
    output_string oc content;
    close_out oc;
    debug_fields "Test document created" ~fields:[
      ("path", Value.string path);
      ("size_bytes", Value.int (String.length content));
    ]
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

          info_fields "Command received" ~fields:[
            ("command", Value.string cmd);
            ("chat_id", Value.string (Telegram.Id.to_string chat_id));
          ];

          match cmd with
          | "/start" ->
              Flo.with_span "command_start" (fun () ->
                debug "Executing /start command";
                let help =
                  "Welcome to the File Bot!\n\n\
                   Commands:\n\
                   /photo - I'll send you a test photo\n\
                   /document - I'll send you a test document\n\n\
                   You can also send me photos or documents and I'll download them!"
                in
                send_message client chat_id help;
                success "Command /start completed"
              )

          | "/photo" ->
              Flo.with_span "upload_photo" (fun () ->
                debug "Executing /photo command - creating test photo";
                (* Create test photo *)
                let photo_path = Filename.temp_file "test_photo" ".png" in
                create_test_image photo_path;

                debug_fields "Uploading photo" ~fields:[
                  ("file_path", Value.string photo_path);
                ];

                (* Send photo (generated API expects string path) *)
                match Telegram_generated.Gen_methods.send_photo client ~chat_id ~photo:photo_path
                    ~caption:"Here's a test photo! 📷" () with
                | Ok sent_msg ->
                    (* Extract photo metadata if available *)
                    (match sent_msg.Message.photo with
                     | Some photos when List.length photos > 0 ->
                         let largest = List.hd (List.rev photos) in
                         success_fields "Photo sent successfully" ~fields:[
                           ("message_id", Value.int (Int64.to_int sent_msg.Message.message_id));
                           ("file_id", Value.string largest.PhotoSize.file_id);
                           ("width", Value.int (Int64.to_int largest.PhotoSize.width));
                           ("height", Value.int (Int64.to_int largest.PhotoSize.height));
                           ("file_size", Value.int (Int64.to_int (Option.value ~default:0L largest.PhotoSize.file_size)));
                         ]
                     | _ ->
                         success "Photo sent successfully (no metadata)");
                    Sys.remove photo_path
                | Error err ->
                    error_fields "Failed to send photo" ~fields:[
                      Flo_semconv.error_message (Format.asprintf "%a" Telegram.Error.pp err);
                      ("file_path", Value.string photo_path);
                    ];
                    Sys.remove photo_path
              )

          | "/document" ->
              Flo.with_span "upload_document" (fun () ->
                debug "Executing /document command - creating test document";
                (* Create test document *)
                let doc_path = Filename.temp_file "test_doc" ".txt" in
                create_test_document doc_path;

                debug_fields "Uploading document" ~fields:[
                  ("file_path", Value.string doc_path);
                ];

                (* Send document (generated API expects string path) *)
                match Telegram_generated.Gen_methods.send_document client ~chat_id ~document:doc_path
                    ~caption:"Here's a test document! 📄" () with
                | Ok sent_msg ->
                    (* Extract document metadata if available *)
                    (match sent_msg.Message.document with
                     | Some doc ->
                         success_fields "Document sent successfully" ~fields:[
                           ("message_id", Value.int (Int64.to_int sent_msg.Message.message_id));
                           ("file_id", Value.string doc.Document.file_id);
                           ("file_name", Value.string (Option.value ~default:"<none>" doc.Document.file_name));
                           ("mime_type", Value.string (Option.value ~default:"<none>" doc.Document.mime_type));
                           ("file_size", Value.int (Int64.to_int (Option.value ~default:0L doc.Document.file_size)));
                         ]
                     | None ->
                         success "Document sent successfully (no metadata)");
                    Sys.remove doc_path
                | Error err ->
                    error_fields "Failed to send document" ~fields:[
                      Flo_semconv.error_message (Format.asprintf "%a" Telegram.Error.pp err);
                      ("file_path", Value.string doc_path);
                    ];
                    Sys.remove doc_path
              )

          | _ ->
              warn_fields "Unknown command" ~fields:[
                ("command", Value.string cmd);
              ];
              send_message client chat_id "Unknown command. Try /start, /photo, or /document"
        )
        (* Handle received photos *)
        else if msg.Message.photo <> None && msg.Message.photo <> Some [] then (
          Flo.with_span "download_photo" (fun () ->
            match msg.Message.photo with
            | Some photos when List.length photos > 0 ->
                let largest = List.hd (List.rev photos) in
                info_fields "Received photo" ~fields:[
                  ("file_id", Value.string largest.PhotoSize.file_id);
                  ("width", Value.int (Int64.to_int largest.PhotoSize.width));
                  ("height", Value.int (Int64.to_int largest.PhotoSize.height));
                  ("file_size", Value.int (Int64.to_int (Option.value ~default:0L largest.PhotoSize.file_size)));
                ];
                send_message client chat_id "Nice photo! I received it. 📸";
                success "Photo download completed"
            | _ ->
                warn "Photo message received but no photo data available"
          )
        )
        (* Handle received documents *)
        else if msg.Message.document <> None then (
          Flo.with_span "download_document" (fun () ->
            match msg.Message.document with
            | Some doc ->
                info_fields "Received document" ~fields:[
                  ("file_id", Value.string doc.Document.file_id);
                  ("file_name", Value.string (Option.value ~default:"<none>" doc.Document.file_name));
                  ("mime_type", Value.string (Option.value ~default:"<none>" doc.Document.mime_type));
                  ("file_size", Value.int (Int64.to_int (Option.value ~default:0L doc.Document.file_size)));
                ];
                send_message client chat_id "Got your document! 📄";
                success "Document download completed"
            | None ->
                warn "Document message received but no document data available"
          )
        )
        (* Echo other messages *)
        else if text <> "" then (
          debug_fields "Echoing text message" ~fields:[
            ("text_length", Value.int (String.length text));
          ];
          send_message client chat_id ("You said: " ^ text)
        )

    | None -> ()
  in

  info "🤖 File Bot Started!";
  info "🔍 Watching for updates (long polling)...";

  Tg.Polling.run client ~handler:handle_update
