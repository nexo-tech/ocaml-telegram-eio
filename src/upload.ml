(* Progress tracking *)
type progress = {
  bytes_sent : int64;
  total_bytes : int64 option;
  percent : float option;
}

let progress_callback f ~bytes_sent ~total_bytes =
  let percent = match total_bytes with
    | None -> None
    | Some total when total > 0L ->
        let pct = (Int64.to_float bytes_sent /. Int64.to_float total) *. 100.0 in
        Some pct
    | Some _ -> None
  in
  f { bytes_sent; total_bytes; percent }

(* File upload helpers *)
let file_part ~name ?filename ?content_type ~path () =
  let filename = match filename with
    | Some fn -> fn
    | None -> Filename.basename path
  in
  let content_type = match content_type with
    | Some ct -> Some ct
    | None -> Some "application/octet-stream"
  in
  (name, `File (filename, content_type, path))

let string_part ~name ~value =
  (name, `String value)

(* Convenience functions *)
let with_progress ?on_progress parts =
  match on_progress with
  | None -> Telegram.Http.Multipart parts
  | Some f -> Telegram.Http.Multipart_progress (parts, progress_callback f)
