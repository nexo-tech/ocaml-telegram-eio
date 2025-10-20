(** Message Handling Demo - Comprehensive demonstration of message handling patterns

    This example demonstrates all message handling features:
    - Message type detection (text, photo, document, location, contact)
    - Entity extraction (mentions, URLs, hashtags, commands)
    - Text formatting (HTML, MarkdownV2)
    - Message editing and deletion
    - Reply patterns
    - Forwarding messages
    - Message composition helpers

    Commands:
      /start - Show available features
      /format_html - Demonstrate HTML formatting
      /format_markdown - Demonstrate MarkdownV2 formatting
      /entities - Extract and display message entities
      /edit_test - Send and edit a message
      /delete_test - Send and delete a message after 5 seconds
      /info - Show message metadata

    Message Handlers:
      - Text messages: Echo with entity analysis
      - Photos: Display photo info and caption
      - Documents: Display file info
      - Location: Display coordinates
      - Contact: Display contact info

    This example has VERBOSE LOGGING enabled for troubleshooting.

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/message_handling_demo.exe
*)

open Telegram
open Tg

(* Configure verbose logging with flo *)
let () = Flo.set_level Severity.Debug

(** HTML formatting helpers *)
module Html = struct
  let escape text =
    let buf = Buffer.create (String.length text) in
    String.iter (function
      | '<' -> Buffer.add_string buf "&lt;"
      | '>' -> Buffer.add_string buf "&gt;"
      | '&' -> Buffer.add_string buf "&amp;"
      | '"' -> Buffer.add_string buf "&quot;"
      | c -> Buffer.add_char buf c
    ) text;
    Buffer.contents buf

  let bold text = Printf.sprintf "<b>%s</b>" (escape text)
  let italic text = Printf.sprintf "<i>%s</i>" (escape text)
  let code text = Printf.sprintf "<code>%s</code>" (escape text)
  let pre text = Printf.sprintf "<pre>%s</pre>" (escape text)
  let link url text = Printf.sprintf "<a href=\"%s\">%s</a>" url (escape text)
  let underline text = Printf.sprintf "<u>%s</u>" (escape text)
  let strike text = Printf.sprintf "<s>%s</s>" (escape text)
end

(** Message templates *)
module Templates = struct
  let welcome username =
    Printf.sprintf
      "👋 Welcome, %s!\n\n\
       I demonstrate message handling patterns.\n\
       Send me different types of messages to see how I handle them!"
      (Html.escape username)

  let error msg = Printf.sprintf "❌ Error: %s" (Html.escape msg)
  let success msg = Printf.sprintf "✅ Success: %s" (Html.escape msg)
  let info msg = Printf.sprintf "ℹ️ %s" (Html.escape msg)
end

let () =
  Printexc.record_backtrace true;
  Flo.info "=== Message Handling Demo Starting ===";

  let token = match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None -> Printf.eprintf "TELEGRAM_BOT_TOKEN not set\n"; exit 1
  in

  Eio_main.run @@ fun env ->
  let client = Client.create ~env ~token () in

  Flo.info "🤖 Message Handling Demo Bot Started";

  Bot.make ~env ~client

  (* /start - Welcome *)
  |> Bot.command "start" ~desc:"Show welcome message" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/start] Sending welcome";

      let user_opt = user ctx in
      let username = match user_opt with
        | Some u -> Option.value u.username ~default:"friend"
        | None -> "friend"
      in

      let text = Templates.welcome username in

      match reply ctx text with
      | Ok _ -> Flo.debug "[/start] ✓"; Ok ()
      | Error e -> Flo.debugf "[/start] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /format_html - Demonstrate HTML formatting *)
  |> Bot.command "format_html" ~desc:"Show HTML formatting examples" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/format_html] Demonstrating HTML formatting";

      let text =
        Html.bold "Bold text" ^ "\n" ^
        Html.italic "Italic text" ^ "\n" ^
        Html.underline "Underlined text" ^ "\n" ^
        Html.strike "Strikethrough text" ^ "\n" ^
        Html.code "inline code" ^ "\n" ^
        Html.pre "preformatted\nmultiple lines" ^ "\n" ^
        Html.link "https://ocaml.org" "OCaml Website"
      in

      match reply ctx text with
      | Ok _ -> Flo.debug "[/format_html] ✓"; Ok ()
      | Error e -> Flo.debugf "[/format_html] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /format_markdown - Demonstrate MarkdownV2 formatting *)
  |> Bot.command "format_markdown" ~desc:"Show MarkdownV2 examples" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/format_markdown] Demonstrating MarkdownV2";

      (* MarkdownV2 requires escaping special chars *)
      let text =
        "*Bold text*\n\
         _Italic text_\n\
         __Underlined text__\n\
         ~Strikethrough text~\n\
         `inline code`\n\
         ```ocaml\n\
         let x = 42\n\
         ```\n\
         [OCaml Website](https://ocaml\\.org)"
      in

      match reply ctx text with
      | Ok _ -> Flo.debug "[/format_markdown] ✓"; Ok ()
      | Error e -> Flo.debugf "[/format_markdown] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /entities - Extract and display entities from next message *)
  |> Bot.command "entities" ~desc:"Show entity extraction" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/entities] Requesting entities";

      match reply ctx
        "Send me a message with:\n\
         • @mentions\n\
         • #hashtags\n\
         • https://urls.com\n\
         • /commands\n\n\
         I'll extract and show all entities!"
      with
      | Ok _ -> Flo.debug "[/entities] ✓"; Ok ()
      | Error e -> Flo.debugf "[/entities] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /edit_test - Send and edit message *)
  |> Bot.command "edit_test" ~desc:"Demonstrate message editing" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/edit_test] Testing message editing";

      match reply ctx "⏳ Original message... (will be edited in 2 seconds)" with
      | Ok msg ->
          Flo.debug "[/edit_test] Message sent, waiting 2s";
          let open Telegram_generated.Gen_types.Message in
          Eio.Time.sleep (env ctx)#clock 2.0;

          let chat_id = chat ctx in
          let edited_text = "✅ Message edited successfully!\n\nThis demonstrates edit_message_text API." in

          (match Telegram_generated.Gen_methods.edit_message_text
            (client ctx)
            ~chat_id:(Id.to_string chat_id)
            ~message_id:msg.message_id
            ~text:edited_text
            () with
           | Ok _ -> Flo.debug "[/edit_test] Edited ✓"; Ok ()
           | Error e -> Flo.debugf "[/edit_test] Edit failed: %s" (Format.asprintf "%a" Error.pp e); Ok ())
      | Error e ->
          Flo.debugf "[/edit_test] Send failed: %s" (Format.asprintf "%a" Error.pp e);
          Ok ()
    )

  (* /delete_test - Send and delete after delay *)
  |> Bot.command "delete_test" ~desc:"Send and auto-delete message" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/delete_test] Testing message deletion";

      match reply ctx "🗑️ This message will self-destruct in 5 seconds..." with
      | Ok msg ->
          Flo.debug "[/delete_test] Message sent, will delete in 5s";
          let open Telegram_generated.Gen_types.Message in

          (* Schedule deletion *)
          let chat_id = chat ctx in

          Eio.Time.sleep (env ctx)#clock 5.0;

          (match Telegram_generated.Gen_methods.delete_message
            (client ctx)
            ~chat_id
            ~message_id:msg.message_id
            () with
           | Ok _ -> Flo.debug "[/delete_test] Deleted ✓"; Ok ()
           | Error e -> Flo.debugf "[/delete_test] Delete failed: %s" (Format.asprintf "%a" Error.pp e); Ok ())
      | Error e ->
          Flo.debugf "[/delete_test] Send failed: %s" (Format.asprintf "%a" Error.pp e);
          Ok ()
    )

  (* /info - Show message metadata *)
  |> Bot.command "info" ~desc:"Show bot and message information" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/info] Showing message info";

      let msg = message ctx in
      let user_opt = user ctx in

      let user_info = match user_opt with
        | Some u ->
            Printf.sprintf "User: %s"
              (Option.value u.username ~default:"<no username>")
        | None -> "User: <unknown>"
      in

      let text = Printf.sprintf
        "%s\n\
         %s\n\
         Message ID: %d\n\n\
         This message has metadata you can access via the context."
        (Html.bold "Message Information")
        user_info
        msg.message_id
      in

      match reply ctx text with
      | Ok _ -> Flo.debug "[/info] ✓"; Ok ()
      | Error e -> Flo.debugf "[/info] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /template_demo - Demonstrate message templates *)
  |> Bot.command "template_demo" ~desc:"Show message template examples" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/template_demo] Showing templates";

      let text = Printf.sprintf
        "%s\n\n%s\n\n%s"
        (Templates.info "This demonstrates message templates")
        (Templates.success "Operation completed successfully!")
        (Templates.error "Something went wrong")
      in

      match reply ctx text with
      | Ok _ -> Flo.debug "[/template_demo] ✓"; Ok ()
      | Error e -> Flo.debugf "[/template_demo] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* Handle text messages - echo with entity analysis *)
  |> Bot.on_text (fun ctx text ->
      let open Bot.Ctx in
      Flo.debugf "[on_text] Received text: %s" text;

      (* Extract entities using Bot.Entity *)
      let entities_list = entities ctx in
      Flo.debugf "[on_text] Found %d entities" (List.length entities_list);

      let entity_summary = if List.length entities_list > 0 then
        let entity_lines = List.map (fun ent ->
          let open Bot.Entity in
          match ent.entity_type with
          | Mention -> Printf.sprintf "• @mention: %s" (Html.escape ent.text)
          | Hashtag -> Printf.sprintf "• #hashtag: %s" (Html.escape ent.text)
          | Cashtag -> Printf.sprintf "• $cashtag: %s" (Html.escape ent.text)
          | Url -> Printf.sprintf "• URL: %s" (Html.escape ent.text)
          | BotCommand -> Printf.sprintf "• Command: %s" (Html.escape ent.text)
          | Email -> Printf.sprintf "• Email: %s" (Html.escape ent.text)
          | PhoneNumber -> Printf.sprintf "• Phone: %s" (Html.escape ent.text)
          | Code -> Printf.sprintf "• Code: %s" (Html.code ent.text)
          | Bold -> Printf.sprintf "• Bold: %s" (Html.bold ent.text)
          | Italic -> Printf.sprintf "• Italic: %s" (Html.italic ent.text)
          | Underline -> Printf.sprintf "• Underline: %s" (Html.escape ent.text)
          | Strikethrough -> Printf.sprintf "• Strikethrough: %s" (Html.escape ent.text)
          | Spoiler -> Printf.sprintf "• Spoiler: %s" (Html.escape ent.text)
          | Pre -> Printf.sprintf "• Pre: %s" (Html.pre ent.text)
          | TextLink url -> Printf.sprintf "• Link to %s: %s" url (Html.escape ent.text)
          | TextMention _ -> Printf.sprintf "• Mention: %s" (Html.escape ent.text)
          | CustomEmoji id -> Printf.sprintf "• Custom emoji %s: %s" id (Html.escape ent.text)
          | Other t -> Printf.sprintf "• %s: %s" t (Html.escape ent.text)
        ) entities_list
        |> String.concat "\n"
        in
        "\n\n" ^ Html.bold "Entities found:" ^ "\n" ^ entity_lines
      else ""
      in

      let response = Printf.sprintf
        "📨 %s\n\n%s%s"
        (Html.bold "Text Message Received")
        (Html.code text)
        entity_summary
      in

      match reply ctx response with
      | Ok _ -> Flo.debug "[on_text] ✓"; Ok ()
      | Error e -> Flo.debugf "[on_text] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* Handle photo messages *)
  |> Bot.on_photo (fun ctx photos ->
      let open Bot.Ctx in
      Flo.debugf "[on_photo] Received %d photo sizes" (List.length photos);

      let msg = message ctx in
      let caption = Option.value msg.text ~default:"<no caption>" in

      (* Get largest photo *)
      let largest = List.fold_left (fun acc p ->
        let open Telegram_generated.Gen_types.PhotoSize in
        if p.file_size > acc.file_size then p else acc
      ) (List.hd photos) photos
      in

      let open Telegram_generated.Gen_types.PhotoSize in
      let size_kb = Int64.div (Option.value largest.file_size ~default:0L) 1024L in

      let response = Printf.sprintf
        "%s\n\n\
         Sizes available: %d\n\
         Largest: %dx%d (%Ld KB)\n\
         File ID: %s\n\
         Caption: %s"
        (Html.bold "📷 Photo Received")
        (List.length photos)
        (Int64.to_int largest.width)
        (Int64.to_int largest.height)
        size_kb
        (Html.code largest.file_id)
        (Html.escape caption)
      in

      match reply ctx response with
      | Ok _ -> Flo.debug "[on_photo] ✓"; Ok ()
      | Error e -> Flo.debugf "[on_photo] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* Handle document messages *)
  |> Bot.on_message (fun ctx msg ->
      let open Bot.Ctx in
      let open Telegram_generated.Gen_types.Message in

      match msg.document with
      | Some doc ->
          Flo.debug "[on_document] Received document";

          let open Telegram_generated.Gen_types.Document in
          let filename = Option.value doc.file_name ~default:"<unknown>" in
          let size_kb = Int64.div (Option.value doc.file_size ~default:0L) 1024L in
          let mime = Option.value doc.mime_type ~default:"application/octet-stream" in

          let response = Printf.sprintf
            "%s\n\n\
             Filename: %s\n\
             Size: %Ld KB\n\
             MIME: %s\n\
             File ID: %s"
            (Html.bold "📄 Document Received")
            (Html.escape filename)
            size_kb
            (Html.code mime)
            (Html.code doc.file_id)
          in

          (match reply ctx response with
           | Ok _ -> Flo.debug "[on_document] ✓"; Ok ()
           | Error e -> Flo.debugf "[on_document] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ())

      | None ->
          (* Not a document, skip *)
          Ok ()
    )

  (* Handle location messages *)
  |> Bot.on_message (fun ctx msg ->
      let open Bot.Ctx in
      let open Telegram_generated.Gen_types.Message in

      match msg.location with
      | Some loc ->
          Flo.debug "[on_location] Received location";

          let open Telegram_generated.Gen_types.Location in
          let response = Printf.sprintf
            "%s\n\n\
             Latitude: %.6f\n\
             Longitude: %.6f"
            (Html.bold "📍 Location Received")
            loc.latitude
            loc.longitude
          in

          (match reply ctx response with
           | Ok _ -> Flo.debug "[on_location] ✓"; Ok ()
           | Error e -> Flo.debugf "[on_location] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ())

      | None ->
          Ok ()
    )

  (* Handle contact messages *)
  |> Bot.on_message (fun ctx msg ->
      let open Bot.Ctx in
      let open Telegram_generated.Gen_types.Message in

      match msg.contact with
      | Some contact ->
          Flo.debug "[on_contact] Received contact";

          let open Telegram_generated.Gen_types.Contact in
          let response = Printf.sprintf
            "%s\n\n\
             Name: %s\n\
             Phone: %s\n\
             User ID: %s"
            (Html.bold "👤 Contact Received")
            (Html.escape (contact.first_name ^ " " ^ Option.value contact.last_name ~default:""))
            (Html.escape contact.phone_number)
            (match contact.user_id with
             | Some id -> Int64.to_string id
             | None -> "<not linked>")
          in

          (match reply ctx response with
           | Ok _ -> Flo.debug "[on_contact] ✓"; Ok ()
           | Error e -> Flo.debugf "[on_contact] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ())

      | None ->
          Ok ()
    )

  |> Bot.run
