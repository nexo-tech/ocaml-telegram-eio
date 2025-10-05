(* Tests for Money module *)

open Telegram

let test_make () =
  let money = Money.make ~currency:"USD" ~amount:12345L in
  Alcotest.(check string) "currency" "USD" (Money.currency money);
  Alcotest.(check int64) "amount" 12345L (Money.amount money)

let test_zero () =
  let money = Money.zero "EUR" in
  Alcotest.(check string) "currency" "EUR" (Money.currency money);
  Alcotest.(check int64) "amount" 0L (Money.amount money)

let test_equal_same () =
  let a = Money.make ~currency:"USD" ~amount:100L in
  let b = Money.make ~currency:"USD" ~amount:100L in
  Alcotest.(check bool) "equal" true (Money.equal a b)

let test_equal_different () =
  let a = Money.make ~currency:"USD" ~amount:100L in
  let b = Money.make ~currency:"USD" ~amount:200L in
  Alcotest.(check bool) "not equal" false (Money.equal a b)

let test_equal_currency_mismatch () =
  let a = Money.make ~currency:"USD" ~amount:100L in
  let b = Money.make ~currency:"EUR" ~amount:100L in
  Alcotest.check_raises "currency mismatch"
    (Invalid_argument "Money.operation: currency mismatch (USD vs EUR)")
    (fun () -> ignore (Money.equal a b))

let test_compare_less () =
  let a = Money.make ~currency:"USD" ~amount:100L in
  let b = Money.make ~currency:"USD" ~amount:200L in
  Alcotest.(check int) "compare less" (-1) (Money.compare a b)

let test_compare_greater () =
  let a = Money.make ~currency:"USD" ~amount:200L in
  let b = Money.make ~currency:"USD" ~amount:100L in
  Alcotest.(check int) "compare greater" 1 (Money.compare a b)

let test_compare_equal () =
  let a = Money.make ~currency:"USD" ~amount:100L in
  let b = Money.make ~currency:"USD" ~amount:100L in
  Alcotest.(check int) "compare equal" 0 (Money.compare a b)

let test_compare_currency_mismatch () =
  let a = Money.make ~currency:"USD" ~amount:100L in
  let b = Money.make ~currency:"EUR" ~amount:100L in
  Alcotest.check_raises "currency mismatch"
    (Invalid_argument "Money.operation: currency mismatch (USD vs EUR)")
    (fun () -> ignore (Money.compare a b))

let test_to_string_usd () =
  let money = Money.make ~currency:"USD" ~amount:12345L in
  Alcotest.(check string) "USD format" "123.45 USD" (Money.to_string money)

let test_to_string_jpy () =
  let money = Money.make ~currency:"JPY" ~amount:1234L in
  Alcotest.(check string) "JPY format" "1234 JPY" (Money.to_string money)

let test_to_string_bhd () =
  let money = Money.make ~currency:"BHD" ~amount:12345L in
  Alcotest.(check string) "BHD format" "12.345 BHD" (Money.to_string money)

let test_to_string_negative () =
  let money = Money.make ~currency:"USD" ~amount:(-12345L) in
  Alcotest.(check string) "negative amount" "-123.45 USD" (Money.to_string money)

let test_json_roundtrip_usd () =
  let money = Money.make ~currency:"USD" ~amount:12345L in
  let json = Money.to_yojson money in
  match Money.of_yojson json with
  | Ok decoded ->
      Alcotest.(check string) "currency" "USD" (Money.currency decoded);
      Alcotest.(check int64) "amount" 12345L (Money.amount decoded)
  | Error msg -> Alcotest.fail msg

let test_json_roundtrip_large () =
  let money = Money.make ~currency:"EUR" ~amount:9999999999L in
  let json = Money.to_yojson money in
  match Money.of_yojson json with
  | Ok decoded ->
      Alcotest.(check string) "currency" "EUR" (Money.currency decoded);
      Alcotest.(check int64) "amount" 9999999999L (Money.amount decoded)
  | Error msg -> Alcotest.fail msg

let test_json_from_int () =
  let json = `Assoc [("currency", `String "USD"); ("amount", `Int 123)] in
  match Money.of_yojson json with
  | Ok money ->
      Alcotest.(check string) "currency" "USD" (Money.currency money);
      Alcotest.(check int64) "amount" 123L (Money.amount money)
  | Error msg -> Alcotest.fail msg

let test_json_from_intlit () =
  let json = `Assoc [("currency", `String "USD"); ("amount", `Intlit "12345")] in
  match Money.of_yojson json with
  | Ok money ->
      Alcotest.(check string) "currency" "USD" (Money.currency money);
      Alcotest.(check int64) "amount" 12345L (Money.amount money)
  | Error msg -> Alcotest.fail msg

let test_json_missing_field () =
  let json = `Assoc [("currency", `String "USD")] in
  match Money.of_yojson json with
  | Ok _ -> Alcotest.fail "should fail with missing field"
  | Error msg -> Alcotest.(check bool) "error message" true (String.length msg > 0)

let test_json_invalid_type () =
  let json = `String "not an object" in
  match Money.of_yojson json with
  | Ok _ -> Alcotest.fail "should fail with invalid type"
  | Error msg ->
      Alcotest.(check string) "error message" "Money: expected JSON object" msg

let () =
  let open Alcotest in
  run "Money" [
    "creation", [
      test_case "make" `Quick test_make;
      test_case "zero" `Quick test_zero;
    ];
    "equality", [
      test_case "equal_same" `Quick test_equal_same;
      test_case "equal_different" `Quick test_equal_different;
      test_case "equal_currency_mismatch" `Quick test_equal_currency_mismatch;
    ];
    "comparison", [
      test_case "compare_less" `Quick test_compare_less;
      test_case "compare_greater" `Quick test_compare_greater;
      test_case "compare_equal" `Quick test_compare_equal;
      test_case "compare_currency_mismatch" `Quick test_compare_currency_mismatch;
    ];
    "formatting", [
      test_case "to_string_usd" `Quick test_to_string_usd;
      test_case "to_string_jpy" `Quick test_to_string_jpy;
      test_case "to_string_bhd" `Quick test_to_string_bhd;
      test_case "to_string_negative" `Quick test_to_string_negative;
    ];
    "json", [
      test_case "json_roundtrip_usd" `Quick test_json_roundtrip_usd;
      test_case "json_roundtrip_large" `Quick test_json_roundtrip_large;
      test_case "json_from_int" `Quick test_json_from_int;
      test_case "json_from_intlit" `Quick test_json_from_intlit;
      test_case "json_missing_field" `Quick test_json_missing_field;
      test_case "json_invalid_type" `Quick test_json_invalid_type;
    ];
  ]
