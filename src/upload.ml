module Log = Telegram.Log.Make (Telegram.Log.Console) (struct
  let src = "Upload"
  let level = Telegram.Log.Info
end)

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

  (* Log progress every 10% *)
  (match percent with
   | Some pct ->
       let rounded = Float.floor (pct /. 10.0) *. 10.0 in
       if Float.rem pct 10.0 < 1.0 then
         Log.debug "Upload progress: %.0f%% (%Ld bytes)" rounded bytes_sent
   | None ->
       Log.debug "Upload progress: %Ld bytes" bytes_sent);

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

(* Calculate total size of parts *)
let calculate_size parts =
  List.fold_left (fun acc (_, pv) ->
    match pv with
    | `String s -> Int64.add acc (Int64.of_int (String.length s))
    | `File (_, _, path) ->
        (try
          let st = Unix.stat path in
          Int64.add acc (Int64.of_int st.Unix.st_size)
        with _ -> acc)
  ) 0L parts

(* Convenience functions *)
let with_progress ?on_progress parts =
  match on_progress with
  | None -> Telegram.Http.Multipart parts
  | Some f -> Telegram.Http.Multipart_progress (parts, progress_callback f)

let with_limits ?on_progress ~limits parts =
  let size = calculate_size parts in
  Log.info "Upload started: size=%Ld bytes" size;
  Log.debug' (fun () ->
    let file_count = List.filter (fun (_, pv) -> match pv with `File _ -> true | _ -> false) parts |> List.length in
    Format.asprintf "Multipart construction: %d parts (%d files)" (List.length parts) file_count
  );

  match Telegram.Limits.check_upload_size limits size with
  | Error msg ->
      Log.warn "Upload exceeds size limit: %s (size=%Ld bytes)" msg size;
      Error msg
  | Ok () ->
      Log.debug "Upload size check passed: %Ld bytes" size;
      Ok (with_progress ?on_progress parts)
