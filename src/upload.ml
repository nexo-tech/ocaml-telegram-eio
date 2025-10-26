open Flo

(* Scoped logger for upload operations *)
module Log = Flo_scoped.Make(struct
  let namespace = "telegram.upload"
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

  (* Log progress every 10% - guarded for contexts without Eio *)
  (try
    match percent with
    | Some pct ->
        let rounded = Float.floor (pct /. 10.0) *. 10.0 in
        if Float.rem pct 10.0 < 1.0 then
          Log.debug_fields "Upload progress" ~fields:[
            ("percent", Value.float rounded);
            ("bytes_sent", Value.int (Int64.to_int bytes_sent));
          ]
    | None ->
        Log.debugf "Upload progress: %Ld bytes" bytes_sent
   with Stdlib.Effect.Unhandled _ -> ()
  );

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
  let file_count = List.filter (fun (_, pv) -> match pv with `File _ -> true | _ -> false) parts |> List.length in

  Log.info_fields "Upload started" ~fields:[
    ("size_bytes", Value.int (Int64.to_int size));
    ("part_count", Value.int (List.length parts));
    ("file_count", Value.int file_count);
  ];

  Log.debug_fields "Multipart construction" ~fields:[
    ("part_count", Value.int (List.length parts));
    ("file_count", Value.int file_count);
  ];

  match Telegram.Limits.check_upload_size limits size with
  | Error msg ->
      Log.warn_fields "Upload exceeds size limit" ~fields:[
        ("size_bytes", Value.int (Int64.to_int size));
        Flo_semconv.error_type "SizeLimitExceeded";
        Flo_semconv.error_message msg;
      ];
      Error msg
  | Ok () ->
      Log.debug_fields "Upload size check passed" ~fields:[
        ("size_bytes", Value.string (Int64.to_string size));
      ];
      Ok (with_progress ?on_progress parts)
