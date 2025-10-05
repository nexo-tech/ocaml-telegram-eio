(** Currency utilities and localization helpers for Telegram payments *)

(** {1 Currency Information} *)

type code = string
(** ISO 4217 currency code (3-letter uppercase) *)

type info = {
  code : code;
  name : string;
  symbol : string;
  decimal_places : int;
}
(** Currency metadata *)

val get_info : code -> info option
(** Get currency information by code.

    Example:
    {[
      match Currency.get_info "USD" with
      | Some info -> Printf.printf "%s (%s)\n" info.name info.symbol
      | None -> Printf.printf "Unknown currency\n"
    ]} *)

val decimal_places : code -> int
(** Get decimal places for a currency (0-3).

    - 0 for currencies like JPY (Japanese Yen)
    - 2 for most currencies like USD, EUR
    - 3 for currencies like BHD (Bahraini Dinar) *)

val symbol : code -> string
(** Get currency symbol if known, otherwise returns code.

    Example: "USD" → "$", "EUR" → "€", "XYZ" → "XYZ" *)

(** {1 Formatting} *)

type format_style =
  | Symbol_before     (** $12.34 *)
  | Symbol_after      (** 12.34$ *)
  | Code_before       (** USD 12.34 *)
  | Code_after        (** 12.34 USD *)
  | Symbol_space      (** $ 12.34 *)
  | Code_space        (** USD 12.34 *)

val format :
  ?style:format_style ->
  ?thousands_sep:string ->
  Money.t ->
  string
(** Format money with various styles and separators.

    @param style Formatting style (default: Symbol_before for known symbols, Code_after otherwise)
    @param thousands_sep Thousands separator (default: "," for Symbol styles, "" for Code styles)

    Example:
    {[
      let usd = Money.make ~currency:"USD" ~amount:123456L in
      Currency.format usd (* "$1,234.56" *)
      Currency.format ~style:Code_after usd (* "1234.56 USD" *)
      Currency.format ~thousands_sep:"_" usd (* "$1_234.56" *)
    ]} *)

(** {1 Common Currencies} *)

val usd : code
val eur : code
val gbp : code
val jpy : code
val cny : code
val rub : code
val inr : code
val brl : code

(** {1 Currency List} *)

val all_supported : (code * info) list
(** List of all supported currencies with metadata *)

val is_supported : code -> bool
(** Check if a currency code is supported *)
