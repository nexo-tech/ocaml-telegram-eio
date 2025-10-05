(** Chat action types for sendChatAction.

    These indicate what the bot is doing (typing, uploading, etc.). *)

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

val to_string : t -> string
(** Convert to Telegram API string (e.g., "typing", "upload_photo"). *)

val of_string : string -> t option
(** Parse from API string. Returns [None] for unknown actions. *)

val to_yojson : t -> Yojson.Safe.t

val of_yojson : Yojson.Safe.t -> (t, string) result

val pp : Format.formatter -> t -> unit
