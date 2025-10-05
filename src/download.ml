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
  Printf.sprintf "%s/file/bot%s/%s" base token file_path

(* Build download URL from file_info *)
let download_url_from_info client info =
  match info.file_path with
  | None -> None
  | Some path -> Some (download_url client ~file_path:path)

(* Download file contents to a buffer *)
let to_buffer client ~file_path buffer =
  let url = download_url client ~file_path in
  let http = Telegram.Http.Cohttp_eio.v () in

  match Telegram.Http.Cohttp_eio.call http ~meth:`GET ~url ~headers:[] ~body:Telegram.Http.Empty with
  | Error e -> Error e
  | Ok response ->
      let body = response.Telegram.Http.body in
      let size = Int64.of_int (String.length body) in
      (* Check download size limit *)
      let limits = Telegram.Client.limits client in
      (match Telegram.Limits.check_download_size limits size with
       | Error msg -> Error (Telegram.Error.Decode_error ("Download size limit exceeded: " ^ msg))
       | Ok () ->
           Buffer.add_string buffer body;
           Ok size)

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
