(** Currency utilities and localization helpers for Telegram payments *)

(** {1 Currency Information} *)

type code = string

type info = {
  code : code;
  name : string;
  symbol : string;
  decimal_places : int;
}

(* Currency database - comprehensive list *)
let currency_db = [
  (* Major currencies *)
  ("USD", { code = "USD"; name = "US Dollar"; symbol = "$"; decimal_places = 2 });
  ("EUR", { code = "EUR"; name = "Euro"; symbol = "€"; decimal_places = 2 });
  ("GBP", { code = "GBP"; name = "British Pound"; symbol = "£"; decimal_places = 2 });
  ("JPY", { code = "JPY"; name = "Japanese Yen"; symbol = "¥"; decimal_places = 0 });
  ("CNY", { code = "CNY"; name = "Chinese Yuan"; symbol = "¥"; decimal_places = 2 });
  ("RUB", { code = "RUB"; name = "Russian Ruble"; symbol = "₽"; decimal_places = 2 });
  ("INR", { code = "INR"; name = "Indian Rupee"; symbol = "₹"; decimal_places = 2 });
  ("BRL", { code = "BRL"; name = "Brazilian Real"; symbol = "R$"; decimal_places = 2 });
  ("CAD", { code = "CAD"; name = "Canadian Dollar"; symbol = "C$"; decimal_places = 2 });
  ("AUD", { code = "AUD"; name = "Australian Dollar"; symbol = "A$"; decimal_places = 2 });
  ("CHF", { code = "CHF"; name = "Swiss Franc"; symbol = "CHF"; decimal_places = 2 });
  ("KRW", { code = "KRW"; name = "South Korean Won"; symbol = "₩"; decimal_places = 0 });

  (* Currencies with 3 decimal places *)
  ("BHD", { code = "BHD"; name = "Bahraini Dinar"; symbol = "BD"; decimal_places = 3 });
  ("IQD", { code = "IQD"; name = "Iraqi Dinar"; symbol = "IQD"; decimal_places = 3 });
  ("JOD", { code = "JOD"; name = "Jordanian Dinar"; symbol = "JD"; decimal_places = 3 });
  ("KWD", { code = "KWD"; name = "Kuwaiti Dinar"; symbol = "KD"; decimal_places = 3 });
  ("LYD", { code = "LYD"; name = "Libyan Dinar"; symbol = "LD"; decimal_places = 3 });
  ("OMR", { code = "OMR"; name = "Omani Rial"; symbol = "OMR"; decimal_places = 3 });
  ("TND", { code = "TND"; name = "Tunisian Dinar"; symbol = "TND"; decimal_places = 3 });

  (* Currencies with 0 decimal places *)
  ("BIF", { code = "BIF"; name = "Burundian Franc"; symbol = "BIF"; decimal_places = 0 });
  ("CLP", { code = "CLP"; name = "Chilean Peso"; symbol = "CLP"; decimal_places = 0 });
  ("DJF", { code = "DJF"; name = "Djiboutian Franc"; symbol = "DJF"; decimal_places = 0 });
  ("GNF", { code = "GNF"; name = "Guinean Franc"; symbol = "GNF"; decimal_places = 0 });
  ("ISK", { code = "ISK"; name = "Icelandic Króna"; symbol = "kr"; decimal_places = 0 });
  ("VND", { code = "VND"; name = "Vietnamese Dong"; symbol = "₫"; decimal_places = 0 });

  (* Other popular currencies *)
  ("MXN", { code = "MXN"; name = "Mexican Peso"; symbol = "$"; decimal_places = 2 });
  ("SEK", { code = "SEK"; name = "Swedish Krona"; symbol = "kr"; decimal_places = 2 });
  ("NOK", { code = "NOK"; name = "Norwegian Krone"; symbol = "kr"; decimal_places = 2 });
  ("DKK", { code = "DKK"; name = "Danish Krone"; symbol = "kr"; decimal_places = 2 });
  ("PLN", { code = "PLN"; name = "Polish Złoty"; symbol = "zł"; decimal_places = 2 });
  ("TRY", { code = "TRY"; name = "Turkish Lira"; symbol = "₺"; decimal_places = 2 });
  ("ZAR", { code = "ZAR"; name = "South African Rand"; symbol = "R"; decimal_places = 2 });
  ("SGD", { code = "SGD"; name = "Singapore Dollar"; symbol = "S$"; decimal_places = 2 });
  ("HKD", { code = "HKD"; name = "Hong Kong Dollar"; symbol = "HK$"; decimal_places = 2 });
  ("NZD", { code = "NZD"; name = "New Zealand Dollar"; symbol = "NZ$"; decimal_places = 2 });
  ("THB", { code = "THB"; name = "Thai Baht"; symbol = "฿"; decimal_places = 2 });
  ("AED", { code = "AED"; name = "UAE Dirham"; symbol = "AED"; decimal_places = 2 });
  ("SAR", { code = "SAR"; name = "Saudi Riyal"; symbol = "SAR"; decimal_places = 2 });
]

let get_info code =
  List.assoc_opt code currency_db

let decimal_places code =
  match get_info code with
  | Some info -> info.decimal_places
  | None ->
      (* Fallback logic for unknown currencies *)
      match code with
      | "BHD" | "IQD" | "JOD" | "KWD" | "LYD" | "OMR" | "TND" -> 3
      | "BIF" | "CLP" | "DJF" | "GNF" | "ISK" | "JPY" | "KMF" |
        "KRW" | "PYG" | "RWF" | "UGX" | "VND" | "VUV" | "XAF" |
        "XOF" | "XPF" -> 0
      | _ -> 2

let symbol code =
  match get_info code with
  | Some info -> info.symbol
  | None -> code

(** {1 Formatting} *)

type format_style =
  | Symbol_before
  | Symbol_after
  | Code_before
  | Code_after
  | Symbol_space
  | Code_space

let add_thousands_sep sep str =
  if sep = "" then str else
  let len = String.length str in
  let rec loop acc i count =
    if i < 0 then acc
    else
      let char = String.sub str i 1 in
      let new_acc =
        if count > 0 && count mod 3 = 0 then
          char ^ sep ^ acc
        else
          char ^ acc
      in
      loop new_acc (i - 1) (count + 1)
  in
  loop "" (len - 1) 0

let format_amount ?(thousands_sep = "") money =
  let places = decimal_places (Money.currency money) in
  let amount = Money.amount money in

  if places = 0 then
    let whole = Int64.to_string amount in
    add_thousands_sep thousands_sep whole
  else
    let divisor = Int64.of_int (int_of_float (10. ** float_of_int places)) in
    let whole = Int64.div amount divisor |> Int64.to_string in
    let frac = Int64.rem amount divisor |> Int64.abs in
    let frac_str = Printf.sprintf "%0*Ld" places frac in
    let whole_sep = add_thousands_sep thousands_sep whole in
    whole_sep ^ "." ^ frac_str

let format ?style ?thousands_sep money =
  let curr_code = Money.currency money in
  let curr_symbol = symbol curr_code in

  (* Auto-detect style: default to Symbol_before for known symbols, Code_after otherwise *)
  let actual_style = match style with
    | None -> if curr_symbol <> curr_code then Symbol_before else Code_after
    | Some s -> s
  in

  (* Auto-detect thousands separator based on style *)
  let sep = match thousands_sep with
    | Some s -> s
    | None -> match actual_style with
      | Symbol_before | Symbol_after | Symbol_space -> ","
      | Code_before | Code_after | Code_space -> ""
  in

  let amount_str = format_amount ~thousands_sep:sep money in

  match actual_style with
  | Symbol_before -> curr_symbol ^ amount_str
  | Symbol_after -> amount_str ^ curr_symbol
  | Code_before -> curr_code ^ " " ^ amount_str
  | Code_after -> amount_str ^ " " ^ curr_code
  | Symbol_space -> curr_symbol ^ " " ^ amount_str
  | Code_space -> curr_code ^ " " ^ amount_str

(** {1 Common Currencies} *)

let usd = "USD"
let eur = "EUR"
let gbp = "GBP"
let jpy = "JPY"
let cny = "CNY"
let rub = "RUB"
let inr = "INR"
let brl = "BRL"

(** {1 Currency List} *)

let all_supported = currency_db

let is_supported code =
  List.mem_assoc code currency_db
