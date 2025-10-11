(* InputFile type for Telegram Bot API file uploads. *)

type t =
  | File_id of string
  | Url of string
  | Upload of { filename : string; mime_type : string option; path : string }

let file_id fid = File_id fid

let url u = Url u

let path file_path =
  let filename = Filename.basename file_path in
  let mime_type =
    (* Simple mime type guessing based on extension *)
    match Filename.extension file_path |> String.lowercase_ascii with
    | ".jpg" | ".jpeg" -> Some "image/jpeg"
    | ".png" -> Some "image/png"
    | ".gif" -> Some "image/gif"
    | ".webp" -> Some "image/webp"
    | ".mp4" -> Some "video/mp4"
    | ".mp3" -> Some "audio/mpeg"
    | ".ogg" -> Some "audio/ogg"
    | ".pdf" -> Some "application/pdf"
    | ".zip" -> Some "application/zip"
    | _ -> None
  in
  Upload { filename; mime_type; path = file_path }

let file = path

let upload ~filename ?mime_type file_path =
  Upload { filename; mime_type; path = file_path }

let to_string = function
  | File_id fid -> fid
  | Url u -> u
  | Upload { filename; _ } ->
      (* For uploads, return placeholder - actual data goes in multipart *)
      "attach://" ^ filename

let is_upload = function
  | Upload _ -> true
  | File_id _ | Url _ -> false

let to_multipart_part ~field_name = function
  | Upload { filename; mime_type; path } ->
      Some (field_name, filename, mime_type, path)
  | File_id _ | Url _ -> None

let pp fmt = function
  | File_id fid -> Format.fprintf fmt "File_id(%s)" fid
  | Url u -> Format.fprintf fmt "Url(%s)" u
  | Upload { filename; mime_type; path } ->
      Format.fprintf fmt "Upload(%s, %s, %s)"
        filename
        (Option.value mime_type ~default:"<no mime>")
        path
