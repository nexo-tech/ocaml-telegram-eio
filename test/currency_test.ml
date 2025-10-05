(* Tests for Currency module *)

open Telegram

let test_get_info () =
  match Currency.get_info "USD" with
  | Some info ->
      Alcotest.(check string) "USD name" "US Dollar" info.name;
      Alcotest.(check string) "USD symbol" "$" info.symbol;
      Alcotest.(check int) "USD decimals" 2 info.decimal_places
  | None -> Alcotest.fail "USD should be supported"

let test_decimal_places () =
  Alcotest.(check int) "USD decimals" 2 (Currency.decimal_places "USD");
  Alcotest.(check int) "EUR decimals" 2 (Currency.decimal_places "EUR");
  Alcotest.(check int) "JPY decimals" 0 (Currency.decimal_places "JPY");
  Alcotest.(check int) "BHD decimals" 3 (Currency.decimal_places "BHD");
  Alcotest.(check int) "Unknown defaults to 2" 2 (Currency.decimal_places "XYZ")

let test_symbol () =
  Alcotest.(check string) "USD symbol" "$" (Currency.symbol "USD");
  Alcotest.(check string) "EUR symbol" "€" (Currency.symbol "EUR");
  Alcotest.(check string) "GBP symbol" "£" (Currency.symbol "GBP");
  Alcotest.(check string) "JPY symbol" "¥" (Currency.symbol "JPY");
  Alcotest.(check string) "Unknown returns code" "XYZ" (Currency.symbol "XYZ")

let test_format_symbol_before () =
  let usd = Money.make ~currency:"USD" ~amount:123456L in
  let result = Currency.format ~style:Symbol_before usd in
  Alcotest.(check string) "symbol before" "$1,234.56" result

let test_format_symbol_after () =
  let eur = Money.make ~currency:"EUR" ~amount:987654L in
  let result = Currency.format ~style:Symbol_after eur in
  Alcotest.(check string) "symbol after" "9,876.54€" result

let test_format_code_after () =
  let gbp = Money.make ~currency:"GBP" ~amount:50000L in
  let result = Currency.format ~style:Code_after gbp in
  Alcotest.(check string) "code after" "500.00 GBP" result

let test_format_code_before () =
  let jpy = Money.make ~currency:"JPY" ~amount:1000L in
  let result = Currency.format ~style:Code_before jpy in
  Alcotest.(check string) "code before JPY" "JPY 1000" result

let test_format_default () =
  let usd = Money.make ~currency:"USD" ~amount:100L in
  let result = Currency.format usd in
  (* Default should be Symbol_before for USD since it has a known symbol *)
  Alcotest.(check string) "default USD" "$1.00" result

let test_format_unknown_currency () =
  let xyz = Money.make ~currency:"XYZ" ~amount:12345L in
  let result = Currency.format xyz in
  Alcotest.(check string) "unknown currency" "123.45 XYZ" result

let test_format_no_decimals () =
  let jpy = Money.make ~currency:"JPY" ~amount:1234L in
  let result = Currency.format jpy in
  Alcotest.(check string) "JPY no decimals" "¥1,234" result

let test_format_three_decimals () =
  let bhd = Money.make ~currency:"BHD" ~amount:12345L in
  let result = Currency.format ~style:Code_after bhd in
  Alcotest.(check string) "BHD 3 decimals" "12.345 BHD" result

let test_format_custom_separator () =
  let usd = Money.make ~currency:"USD" ~amount:1234567L in
  let result = Currency.format ~thousands_sep:"_" usd in
  Alcotest.(check string) "custom separator" "$12_345.67" result

let test_format_no_separator () =
  let usd = Money.make ~currency:"USD" ~amount:1234567L in
  let result = Currency.format ~style:Code_after ~thousands_sep:"" usd in
  Alcotest.(check string) "no separator" "12345.67 USD" result

let test_common_currency_constants () =
  Alcotest.(check string) "USD constant" "USD" Currency.usd;
  Alcotest.(check string) "EUR constant" "EUR" Currency.eur;
  Alcotest.(check string) "GBP constant" "GBP" Currency.gbp;
  Alcotest.(check string) "JPY constant" "JPY" Currency.jpy

let test_is_supported () =
  Alcotest.(check bool) "USD supported" true (Currency.is_supported "USD");
  Alcotest.(check bool) "EUR supported" true (Currency.is_supported "EUR");
  Alcotest.(check bool) "XYZ not supported" false (Currency.is_supported "XYZ")

let test_all_supported () =
  let currencies = Currency.all_supported in
  Alcotest.(check bool) "has currencies" true (List.length currencies > 0);
  Alcotest.(check bool) "has USD" true (List.mem_assoc "USD" currencies);
  Alcotest.(check bool) "has EUR" true (List.mem_assoc "EUR" currencies)

let () =
  let open Alcotest in
  run "Currency" [
    "info", [
      test_case "get_info" `Quick test_get_info;
      test_case "decimal_places" `Quick test_decimal_places;
      test_case "symbol" `Quick test_symbol;
    ];
    "formatting", [
      test_case "symbol_before" `Quick test_format_symbol_before;
      test_case "symbol_after" `Quick test_format_symbol_after;
      test_case "code_after" `Quick test_format_code_after;
      test_case "code_before" `Quick test_format_code_before;
      test_case "default" `Quick test_format_default;
      test_case "unknown_currency" `Quick test_format_unknown_currency;
      test_case "no_decimals" `Quick test_format_no_decimals;
      test_case "three_decimals" `Quick test_format_three_decimals;
      test_case "custom_separator" `Quick test_format_custom_separator;
      test_case "no_separator" `Quick test_format_no_separator;
    ];
    "utilities", [
      test_case "common_constants" `Quick test_common_currency_constants;
      test_case "is_supported" `Quick test_is_supported;
      test_case "all_supported" `Quick test_all_supported;
    ];
  ]
