(** Message text/caption parse modes for formatting. *)

type t = [ `Markdown | `MarkdownV2 | `HTML ]

val to_string : t -> string
(** Convert to Telegram API string ("Markdown", "MarkdownV2", or "HTML"). *)

val of_string : string -> t option
(** Parse from API string. Returns [None] for unknown values. *)

val to_yojson : t -> Yojson.Safe.t
val of_yojson : Yojson.Safe.t -> (t, string) result

val pp : Format.formatter -> t -> unit

