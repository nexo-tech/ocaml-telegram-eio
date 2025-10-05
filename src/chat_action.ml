type t = [
  | `Typing
  | `Upload_photo
  | `Record_video
  | `Upload_video
  | `Record_voice
  | `Upload_voice
  | `Upload_document
  | `Choose_sticker
  | `Find_location
  | `Record_video_note
  | `Upload_video_note
]

let to_string = function
  | `Typing -> "typing"
  | `Upload_photo -> "upload_photo"
  | `Record_video -> "record_video"
  | `Upload_video -> "upload_video"
  | `Record_voice -> "record_voice"
  | `Upload_voice -> "upload_voice"
  | `Upload_document -> "upload_document"
  | `Choose_sticker -> "choose_sticker"
  | `Find_location -> "find_location"
  | `Record_video_note -> "record_video_note"
  | `Upload_video_note -> "upload_video_note"

let of_string = function
  | "typing" -> Some `Typing
  | "upload_photo" -> Some `Upload_photo
  | "record_video" -> Some `Record_video
  | "upload_video" -> Some `Upload_video
  | "record_voice" -> Some `Record_voice
  | "upload_voice" -> Some `Upload_voice
  | "upload_document" -> Some `Upload_document
  | "choose_sticker" -> Some `Choose_sticker
  | "find_location" -> Some `Find_location
  | "record_video_note" -> Some `Record_video_note
  | "upload_video_note" -> Some `Upload_video_note
  | _ -> None

let to_yojson t = `String (to_string t)

let of_yojson = function
  | `String s -> (
      match of_string s with
      | Some action -> Ok action
      | None -> Error ("Unknown chat action: " ^ s)
    )
  | _ -> Error "Chat_action: expected string"

let pp fmt t = Format.fprintf fmt "%s" (to_string t)
