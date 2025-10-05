type response_parameters = {
  migrate_to_chat_id : Id.Chat.k Id.t option;
  retry_after : int option;
}

type t =
  | Http_error of int * string
  | Api_error of { code : int; description : string; parameters : response_parameters option }
  | Decode_error of string
  | Timeout
  | Canceled
  | Not_implemented of string

val pp : t Fmt.t
val is_retryable : t -> bool
val retry_after : t -> int option
val parameters : t -> response_parameters option

val or_fail : ('a, t) result -> 'a
