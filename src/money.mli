(** Money and currency handling for Telegram payments.

    Amounts are stored in the smallest currency units (e.g., cents for USD).
    This ensures precise arithmetic without floating-point errors. *)

(** Currency code (ISO 4217, 3-letter uppercase). *)
type currency = string

(** Money amount in smallest currency units (e.g., cents). *)
type t

(** {1 Construction} *)

val make : currency:currency -> amount:int64 -> t
(** [make ~currency ~amount] creates a money value.
    @param currency ISO 4217 code (e.g., "USD", "EUR", "RUB")
    @param amount Value in smallest units (cents, kopeks, etc.) *)

val zero : currency -> t
(** [zero currency] creates a zero amount in the given currency. *)

(** {1 Accessors} *)

val currency : t -> currency
(** Get the currency code. *)

val amount : t -> int64
(** Get the amount in smallest units. *)

(** {1 Comparison} *)

val equal : t -> t -> bool
(** [equal a b] checks if amounts are equal.
    Raises [Invalid_argument] if currencies differ. *)

val compare : t -> t -> int
(** [compare a b] compares amounts.
    Raises [Invalid_argument] if currencies differ. *)

(** {1 Formatting} *)

val pp : Format.formatter -> t -> unit
(** Pretty-printer: formats as "123.45 USD" with proper decimal placement. *)

val to_string : t -> string
(** Convert to string representation. *)

(** {1 JSON Codecs} *)

val to_yojson : t -> Yojson.Safe.t
(** Encode as JSON object: [{"currency": "USD", "amount": 12345}] *)

val of_yojson : Yojson.Safe.t -> (t, string) result
(** Decode from JSON object. *)
