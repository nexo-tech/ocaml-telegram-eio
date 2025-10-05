open Telegram.Types

type kind =
  | Text of string * parse_mode option
  | Photo of [ `File_id of string | `Url of string | `Path of string ] * string option

type t = kind

let text s : t = Text (s, None)

let photo p : t = Photo (p, None)

let caption c (b : t) : t =
  match b with
  | Photo (p, _) -> Photo (p, Some c)
  | x -> x

let parse_mode (pm : parse_mode) (b : t) : t =
  match b with
  | Text (s, _) -> Text (s, Some pm)
  | x -> x

let to_ chat_id (b : t) =
  match b with
  | Text (s, pm) -> Telegram.Request.send_message ~chat_id ~text:s ?parse_mode:pm ()
  | Photo (p, cap) -> Telegram.Request.send_photo ~chat_id ~photo:p ?caption:cap ()
