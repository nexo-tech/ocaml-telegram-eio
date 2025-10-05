open Telegram.Types

type t

val text : string -> t
val photo : [ `File_id of string | `Url of string | `Path of string ] -> t

val caption : string -> t -> t
val parse_mode : parse_mode -> t -> t

val to_ : Telegram.Id.Chat.k Telegram.Id.t -> t -> Telegram.Types.message Telegram.Request.t
