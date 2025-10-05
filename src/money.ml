type currency = string

type t = {
  currency : currency;
  amount : int64;
}

let make ~currency ~amount = { currency; amount }

let zero currency = { currency; amount = 0L }

let currency t = t.currency

let amount t = t.amount

let check_same_currency a b =
  if a.currency <> b.currency then
    invalid_arg (Printf.sprintf "Money.%s: currency mismatch (%s vs %s)"
      "operation" a.currency b.currency)

let equal a b =
  check_same_currency a b;
  Int64.equal a.amount b.amount

let compare a b =
  check_same_currency a b;
  Int64.compare a.amount b.amount

(* Get decimal places for common currencies *)
let decimal_places = function
  | "BHD" | "IQD" | "JOD" | "KWD" | "LYD" | "OMR" | "TND" -> 3  (* 3 decimal places *)
  | "BIF" | "CLP" | "DJF" | "GNF" | "ISK" | "JPY" | "KMF" |
    "KRW" | "PYG" | "RWF" | "UGX" | "VND" | "VUV" | "XAF" |
    "XOF" | "XPF" -> 0  (* No decimal places *)
  | _ -> 2  (* Default: 2 decimal places (USD, EUR, etc.) *)

let pp fmt t =
  let places = decimal_places t.currency in
  if places = 0 then
    Format.fprintf fmt "%Ld %s" t.amount t.currency
  else
    let divisor = Int64.of_int (int_of_float (10. ** float_of_int places)) in
    let whole = Int64.div t.amount divisor in
    let frac = Int64.rem t.amount divisor |> Int64.abs in
    let frac_str = Printf.sprintf "%0*Ld" places frac in
    Format.fprintf fmt "%Ld.%s %s" whole frac_str t.currency

let to_string t =
  Format.asprintf "%a" pp t

let to_yojson t =
  `Assoc [
    ("currency", `String t.currency);
    ("amount", `Intlit (Int64.to_string t.amount));
  ]

let of_yojson = function
  | `Assoc fields ->
      (try
        let currency =
          match List.assoc "currency" fields with
          | `String s -> s
          | _ -> raise (Failure "currency must be string")
        in
        let amount =
          match List.assoc "amount" fields with
          | `Int i -> Int64.of_int i
          | `Intlit s -> Int64.of_string s
          | _ -> raise (Failure "amount must be int or intlit")
        in
        Ok { currency; amount }
      with
      | Not_found -> Error "Money: missing required field"
      | Failure msg -> Error ("Money: " ^ msg))
  | _ -> Error "Money: expected JSON object"
