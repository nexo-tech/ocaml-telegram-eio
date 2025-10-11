module Log = Telegram.Log.Make (Telegram.Log.Console) (struct
  let src = "Download"
  let level = Telegram.Log.Info
end)

(* File information type *)
type file_info = {
  file_id : string;
  file_unique_id : string;
  file_size : int64 option;
  file_path : string option;
}

(* Convert generated File type to our file_info *)
let file_info_of_telegram_file (f : Telegram_generated.Gen_types.File.t) : file_info =
  {
    file_id = f.file_id;
    file_unique_id = f.file_unique_id;
    file_size = f.file_size;
    file_path = f.file_path;
  }

(* Get file information from Telegram *)
let get_file client ~file_id =
  (* Call the API directly since Gen_methods.get_file has wrong return type *)
  let params = [ "file_id", `String file_id ] in
  match Telegram.Api.call_json client ~method_name:"getFile" (`Assoc params) with
  | Error e -> Error e
  | Ok j ->
      match Telegram_generated.Gen_types.File.of_yojson j with
      | Ok file -> Ok (file_info_of_telegram_file file)
      | Error msg -> Error (Telegram.Error.Decode_error msg)

(* Build download URL from file_path *)
let download_url client ~file_path =
  let base = Telegram.Client.base_url client in
  let token = Telegram.Client.token client in
  let url = Printf.sprintf "%s/file/bot%s/%s" base token file_path in
  Log.debug "URL construction: %s" url;
  url

(* Build download URL from file_info *)
let download_url_from_info client info =
  match info.file_path with
  | None -> None
  | Some path -> Some (download_url client ~file_path:path)

(* Download file contents to a buffer *)
let to_buffer client ~file_path buffer =
  let start_time = Unix.gettimeofday () in
  let url = download_url client ~file_path in
  let http = Telegram.Http.Cohttp_eio.v () in

  Log.info "Download started: file_path=%s" file_path;

  let result =
    match Telegram.Http.Cohttp_eio.call http ~meth:`GET ~url ~headers:[] ~body:Telegram.Http.Empty with
    | Error e ->
        Log.error "Download failed: file_path=%s - %a" file_path Telegram.Error.pp e;
        Error e
    | Ok response ->
        let body = response.Telegram.Http.body in
        let size = Int64.of_int (String.length body) in
        Log.debug "Download progress: received %Ld bytes" size;

        (* Check download size limit *)
        let limits = Telegram.Client.limits client in
        (match Telegram.Limits.check_download_size limits size with
         | Error msg ->
             Log.error "Download size limit exceeded: %s (size=%Ld bytes)" msg size;
             Error (Telegram.Error.Decode_error ("Download size limit exceeded: " ^ msg))
         | Ok () ->
             Buffer.add_string buffer body;
             let duration = (Unix.gettimeofday () -. start_time) *. 1000.0 in
             Log.info "Download completed: size=%Ld bytes, duration=%.1fms" size duration;
             Ok size)
  in
  result

(* Download file contents as a string *)
let to_string client ~file_path =
  let buf = Buffer.create 4096 in
  match to_buffer client ~file_path buf with
  | Ok _ -> Ok (Buffer.contents buf)
  | Error e -> Error e

(* Get file info and download to buffer *)
let get_and_download client ~file_id buffer =
  match get_file client ~file_id with
  | Error e -> Error e
  | Ok info ->
      match info.file_path with
      | None -> Error (Telegram.Error.Decode_error "File has no file_path (may need to call getFile first)")
      | Some path -> to_buffer client ~file_path:path buffer

(* Get file info and download as string *)
let get_and_download_string client ~file_id =
  let buf = Buffer.create 4096 in
  match get_and_download client ~file_id buf with
  | Ok _ -> Ok (Buffer.contents buf)
  | Error e -> Error e
