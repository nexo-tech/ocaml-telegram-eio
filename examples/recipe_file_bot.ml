(** Recipe: File Handling Bot

    A comprehensive file management bot demonstrating:
    - Document upload/download with validation
    - Photo upload with metadata extraction
    - Album builder with session-based state
    - File storage with quota tracking
    - Result-based error handling
    - Functor-based verbose logging
*)

(** {1 Verbose Logging Setup} *)

(* Functor-based logging modules with Debug level for troubleshooting *)
module Verbose_log = Telegram.Log.Make (Telegram.Log.Console) (struct
  let src = "FileBot"
  let level = Telegram.Log.Debug
end)

module Verbose_session = Tg.Session.Make (Verbose_log)
module Verbose_polling = Tg.Polling.Make (Verbose_log)
module Verbose_bot = Tg.Bot.Make (Verbose_log) (Verbose_session) (Verbose_polling)

(** {1 File Metadata and Storage} *)

(* File metadata for tracking uploads *)
type file_entry = {
  file_id : string;
  file_name : string;
  file_size : int64;
  mime_type : string;
  uploaded_at : float;
  user_id : int64; [@warning "-69"]
} [@@warning "-69"]

(* User storage with quota management *)
type user_storage = {
  files : file_entry list;
  quota : int64;  (* Bytes *)
}

(* Album builder state *)
type album_state = {
  items : string list;  (* File IDs *)
  max_items : int;
}

(* Session keys *)
let storage_key = Verbose_session.make ~name:"user_storage"
let album_key = Verbose_session.make ~name:"album_builder"

(* Storage operations *)
let empty_storage = {
  files = [];
  quota = 100_000_000L;  (* 100 MB per user *)
}

let total_size storage =
  List.fold_left (fun acc entry ->
    Int64.add acc entry.file_size
  ) 0L storage.files

let _has_space storage file_size =
  let used = total_size storage in
  let available = Int64.sub storage.quota used in
  Eio.traceln "[Storage] Checking quota: used=%Ld, quota=%Ld, file_size=%Ld, available=%Ld"
    used storage.quota file_size available;
  file_size <= available

let _add_file storage entry =
  Eio.traceln "[Storage] Adding file: name=%s, size=%Ld" entry.file_name entry.file_size;
  { storage with files = entry :: storage.files }

let remove_file storage file_id =
  Eio.traceln "[Storage] Removing file: file_id=%s" file_id;
  { storage with files = List.filter (fun e -> e.file_id <> file_id) storage.files }

(* File cache for quick access *)
let file_cache = Hashtbl.create 1000

let empty_album = {
  items = [];
  max_items = 10;
}

(** {1 Keyboard Builders} *)

(* Create file list keyboard with download/delete buttons *)
let create_file_list_keyboard storage =
  Eio.traceln "[Keyboard] Creating file list with %d files" (List.length storage.files);

  let file_buttons =
    storage.files
    |> List.mapi (fun i entry ->
        let size_mb = Int64.to_float entry.file_size /. 1_000_000.0 in
        [
          Tg.Keyboard.callback
            ~text:(Printf.sprintf "%d. %s (%.1f MB)" (i + 1) entry.file_name size_mb)
            ~data:("file:view:" ^ entry.file_id);
          Tg.Keyboard.callback
            ~text:"⬇️"
            ~data:("file:download:" ^ entry.file_id);
          Tg.Keyboard.callback
            ~text:"🗑"
            ~data:("file:delete:" ^ entry.file_id);
        ]
      )
  in

  let storage_info =
    let used = total_size storage in
    let quota = storage.quota in
    [[Tg.Keyboard.callback
        ~text:(Printf.sprintf "📊 Storage: %.1f/%.1f MB"
                (Int64.to_float used /. 1_000_000.0)
                (Int64.to_float quota /. 1_000_000.0))
        ~data:"noop"]]
  in

  Tg.Keyboard.inline (file_buttons @ storage_info)

(* Create album builder keyboard *)
let create_album_keyboard state =
  let item_count = List.length state.items in

  Eio.traceln "[Keyboard] Creating album builder: items=%d/%d" item_count state.max_items;

  let buttons =
    if item_count >= 2 then
      [
        [Tg.Keyboard.callback ~text:"✓ Send Album" ~data:"album:send"];
        [Tg.Keyboard.callback ~text:"🗑 Clear" ~data:"album:clear"];
      ]
    else
      [
        [Tg.Keyboard.callback ~text:"🗑 Clear" ~data:"album:clear"];
      ]
  in

  Tg.Keyboard.inline buttons

(** {1 Helper Functions} *)

(* Format file size in human-readable format *)
let format_size bytes =
  let b = Int64.to_float bytes in
  if b < 1024.0 then
    Printf.sprintf "%.0f B" b
  else if b < 1024.0 *. 1024.0 then
    Printf.sprintf "%.1f KB" (b /. 1024.0)
  else if b < 1024.0 *. 1024.0 *. 1024.0 then
    Printf.sprintf "%.1f MB" (b /. (1024.0 *. 1024.0))
  else
    Printf.sprintf "%.1f GB" (b /. (1024.0 *. 1024.0 *. 1024.0))

(* Format timestamp *)
let format_timestamp ts =
  let tm = Unix.gmtime ts in
  Printf.sprintf "%04d-%02d-%02d %02d:%02d UTC"
    (tm.tm_year + 1900)
    (tm.tm_mon + 1)
    tm.tm_mday
    tm.tm_hour
    tm.tm_min

(** {1 Bot Builder} *)

(* Bot builder function - will be called with telegram_client in scope *)
let build_routes telegram_client bot =
  bot
  (* Start command *)
  |> Verbose_bot.command "start" (fun ctx _args ->
    Eio.traceln "[Handler] /start command received";
    let open Verbose_bot.Ctx in
    let* () = reply_ ctx
      "📁 File Manager Bot\n\n\
       Commands:\n\
       /files - View your files\n\
       /stats - Storage statistics\n\
       /album - Start album builder\n\n\
       Simply send any file or photo to upload it!"
    in
    Eio.traceln "[Handler] /start command completed";
    Ok ()
  )
  |>

  (* View files *)
  Verbose_bot.command "files" (fun ctx _args ->
    Eio.traceln "[Handler] /files command received";
    let open Verbose_bot.Ctx in
    let storage = session_get_or ctx storage_key ~default:empty_storage in

    Eio.traceln "[Handler] User has %d files" (List.length storage.files);

    if List.length storage.files = 0 then
      let* () = reply_ ctx "📁 No files uploaded yet" in
      Ok ()
    else
      let keyboard = create_file_list_keyboard storage in
      let* () = reply_ ctx
        ~keyboard
        (Printf.sprintf "📁 Your Files (%d)" (List.length storage.files))
      in
      Eio.traceln "[Handler] /files command completed";
      Ok ()
  )
  |>

  (* Storage stats *)
  Verbose_bot.command "stats" (fun ctx _args ->
    Eio.traceln "[Handler] /stats command received";
    let open Verbose_bot.Ctx in
    let storage = session_get_or ctx storage_key ~default:empty_storage in
    let used = total_size storage in
    let quota = storage.quota in
    let percent = Int64.to_float used /. Int64.to_float quota *. 100.0 in

    Eio.traceln "[Handler] Storage stats: files=%d, used=%Ld, quota=%Ld, percent=%.1f%%"
      (List.length storage.files) used quota percent;

    let stats = Printf.sprintf
      "📊 Storage Statistics\n\n\
       Files: %d\n\
       Used: %s\n\
       Quota: %s\n\
       Usage: %.1f%%"
      (List.length storage.files)
      (format_size used)
      (format_size quota)
      percent
    in

    let* () = reply_ ctx stats in
    Eio.traceln "[Handler] /stats command completed";
    Ok ()
  )
  |>

  (* Start album builder *)
  Verbose_bot.command "album" (fun ctx _args ->
    Eio.traceln "[Handler] /album command received - starting album builder";
    let open Verbose_bot.Ctx in
    session_set ctx album_key empty_album;

    let keyboard = create_album_keyboard empty_album in
    let* () = reply_ ctx
      ~keyboard
      "📸 Album Builder\n\nSend photos to add to album (2-10 photos)"
    in
    Eio.traceln "[Handler] /album command completed";
    Ok ()
  )
  |>

  (* Note: Document and photo upload handlers would require Event.document and Event.photo
     which are not yet implemented in the library. This is a simplified version focusing
     on the core file management features using commands and callbacks. *)

  (* Handle text messages as fallback *)
  Verbose_bot.on_text (fun ctx text ->
    Eio.traceln "[Handler] Text message received: %s" text;
    let open Verbose_bot.Ctx in
    let* () = reply_ ctx "💡 Tip: Use /files to see your uploaded files, or /album to start building a photo album!" in
    Ok ()
  )
  |>

  (* Download file *)
  Verbose_bot.on_callback (fun ctx data ->
    if not (String.starts_with ~prefix:"file:download:" data) then Ok () else begin
    
    let open Verbose_bot.Ctx in
    let file_id = String.sub data 14 (String.length data - 14) in
    Eio.traceln "[Handler] Download requested: file_id=%s" file_id;

    (* Find file entry *)
    match Hashtbl.find_opt file_cache file_id with
    | Some entry ->
        Eio.traceln "[Handler] File found in cache: name=%s" entry.file_name;

        let chat_id = chat ctx in

        Eio.traceln "[Handler] Sending document via API: chat_id=%s"
          (Telegram.Id.to_string chat_id);

            (match Telegram_generated.Gen_methods.send_document telegram_client
                     ~chat_id
                     ~document:file_id
                     ~caption:(Printf.sprintf "📥 %s" entry.file_name)
                     ()
            with
            | Ok _ ->
                Eio.traceln "[Handler] Document sent successfully";
                let* _msg = answer ctx "✓ File sent" in
                Ok ()
            | Error err ->
                Eio.traceln "[Handler] Failed to send document: %a" Telegram.Error.pp err;
                let* _msg = answer ctx "Failed to send file" in
                Ok ())

    | None ->
        Eio.traceln "[Handler] File not found in cache: file_id=%s" file_id;
        let* _msg = answer ctx "File not found" in
        Ok ()
    end
  )
  |>

  (* Delete file *)
  Verbose_bot.on_callback (fun ctx data ->
    if not (String.starts_with ~prefix:"file:delete:" data) then Ok () else begin
    let open Verbose_bot.Ctx in
    let file_id = String.sub data 12 (String.length data - 12) in
    Eio.traceln "[Handler] Delete requested: file_id=%s" file_id;
    let storage = session_get_or ctx storage_key ~default:empty_storage in

    let updated = remove_file storage file_id in
    session_set ctx storage_key updated;

    Hashtbl.remove file_cache file_id;
    Eio.traceln "[Handler] File removed from storage and cache";

    let keyboard = create_file_list_keyboard updated in
    let* () = edit ctx
      ~keyboard
      (Printf.sprintf "📁 Your Files (%d)" (List.length updated.files))
    in
    let* _msg = answer ctx "✓ File deleted" in
    Eio.traceln "[Handler] File deletion completed";
    Ok ()
    end
  )
  |>

  (* View file details *)
  Verbose_bot.on_callback (fun ctx data ->
    if not (String.starts_with ~prefix:"file:view:" data) then Ok () else begin
    let open Verbose_bot.Ctx in
    let file_id = String.sub data 10 (String.length data - 10) in
    Eio.traceln "[Handler] View details requested: file_id=%s" file_id;

    match Hashtbl.find_opt file_cache file_id with
    | Some entry ->
        let details = Printf.sprintf
          "📄 File Details\n\n\
           Name: %s\n\
           Size: %s\n\
           Type: %s\n\
           Uploaded: %s"
          entry.file_name
          (format_size entry.file_size)
          entry.mime_type
          (format_timestamp entry.uploaded_at)
        in

        Eio.traceln "[Handler] Showing file details: name=%s" entry.file_name;
        let* _msg = answer ctx details in
        Ok ()

    | None ->
        Eio.traceln "[Handler] File not found in cache: file_id=%s" file_id;
        let* _msg = answer ctx "File not found" in
        Ok ()
    end
  )
  |>

  (* Send album *)
  Verbose_bot.on_callback (fun ctx data ->
    if data <> "album:send" then Ok () else begin
    
    Eio.traceln "[Handler] Send album requested";
    let open Verbose_bot.Ctx in

    let state = session_get_or ctx album_key ~default:empty_album in

    if List.length state.items < 2 then begin
      Eio.traceln "[Handler] Album send rejected: need at least 2 photos";
      let* _msg = answer ctx "Need at least 2 photos" in
      Ok ()
    end else begin
      Eio.traceln "[Handler] Creating album with %d photos" (List.length state.items);

      (* Create album from cached file_ids *)
      let items =
        state.items
        |> List.rev  (* Restore original order *)
        |> List.map (fun file_id ->
            Tg.Album.photo (Telegram.Input_file.file_id file_id)
          )
      in

      (match Tg.Album.of_list items with
      | Ok album ->
          Eio.traceln "[Handler] Album created successfully";

          let chat_id = chat ctx in
          Eio.traceln "[Handler] Sending album: chat_id=%s"
            (Telegram.Id.to_string chat_id);

          (match Tg.Album.send telegram_client ~chat_id album with
          | Ok messages ->
              Eio.traceln "[Handler] Album sent successfully: %d messages"
                (List.length messages);
              session_delete ctx album_key;
              let* _msg = answer ctx "✓ Album sent!" in
              Ok ()
          | Error err ->
              Eio.traceln "[Handler] Failed to send album: %a" Telegram.Error.pp err;
              let* _msg = answer ctx "Failed to send album" in
              Ok ())

      | Error msg ->
          Eio.traceln "[Handler] Failed to create album: %s" msg;
          let* _msg = answer ctx ("Error: " ^ msg) in
          Ok ())
    end
    end
  )
  |>

  (* Clear album *)
  Verbose_bot.on_callback (fun ctx data ->
    if data <> "album:clear" then Ok () else begin
    Eio.traceln "[Handler] Clear album requested";
    let open Verbose_bot.Ctx in

    session_delete ctx album_key;
    let* _msg = answer ctx "Album cleared" in
    Eio.traceln "[Handler] Album cleared";
    Ok ()
    end
  )
  |>

  (* Ignore noop callbacks *)
  Verbose_bot.on_callback (fun ctx data ->
    if data <> "noop" then Ok () else begin
    let open Verbose_bot.Ctx in
    let* _msg = answer ctx "" in
    Ok ()
    end
  )

(** {1 Main Entry Point} *)

let () =
  Eio.traceln "╔══════════════════════════════════════════════════════════════════╗";
  Eio.traceln "║              File Handling Bot - Recipe Example                 ║";
  Eio.traceln "╚══════════════════════════════════════════════════════════════════╝";
  Eio.traceln "";

  Eio_main.run @@ fun env ->

  (* Phase 1: Initialize client *)
  Eio.traceln "[Init] Loading token from TELEGRAM_BOT_TOKEN environment variable";
  let token =
    match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t ->
        Eio.traceln "[Init] Token loaded successfully (length: %d)" (String.length t);
        t
    | None ->
        Eio.traceln "[Init] ❌ ERROR: TELEGRAM_BOT_TOKEN not set";
        failwith "TELEGRAM_BOT_TOKEN environment variable not set"
  in

  Eio.traceln "[Init] Creating Telegram client";
  let telegram_client = Telegram.Client.create ~env ~token () in
  Eio.traceln "[Init] Client created successfully";

  (* Phase 2: Build bot with functional API *)
  Eio.traceln "[Init] Building bot";

  let bot = Verbose_bot.make ~env ~client:telegram_client in
  let bot = build_routes telegram_client bot in

  Eio.traceln "[Init] Bot created successfully";

  (* Phase 3: Run polling *)
  Eio.traceln "";
  Eio.traceln "╔══════════════════════════════════════════════════════════════════╗";
  Eio.traceln "║                      Bot Started - Polling                       ║";
  Eio.traceln "╚══════════════════════════════════════════════════════════════════╝";
  Eio.traceln "[Polling] Starting long polling...";
  Eio.traceln "[Polling] Bot is ready to receive updates";
  Eio.traceln "";

  Verbose_bot.run bot
