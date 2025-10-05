(* Tests for Polling module *)

open Tg

let test_make_config () =
  let config = Polling.make ~timeout:60 ~limit:50 ~allowed_updates:["message"] () in
  Alcotest.(check int) "timeout" 60 config.timeout;
  Alcotest.(check int) "limit" 50 config.limit;
  Alcotest.(check (option (list string))) "allowed_updates" (Some ["message"]) config.allowed_updates

let test_make_config_limit_clamped () =
  (* Telegram API max is 100, should be clamped *)
  let config = Polling.make ~limit:200 () in
  Alcotest.(check int) "limit clamped to 100" 100 config.limit

let test_default_config () =
  let config = Polling.default in
  Alcotest.(check int) "default timeout" 30 config.timeout;
  Alcotest.(check int) "default limit" 100 config.limit;
  Alcotest.(check (option (list string))) "default allowed_updates" None config.allowed_updates

let test_make_config_with_defaults () =
  let config = Polling.make () in
  Alcotest.(check int) "timeout default" 30 config.timeout;
  Alcotest.(check int) "limit default" 100 config.limit

let () =
  let open Alcotest in
  run "Polling" [
    "config", [
      test_case "make config with custom values" `Quick test_make_config;
      test_case "limit clamped to API max" `Quick test_make_config_limit_clamped;
      test_case "default config" `Quick test_default_config;
      test_case "make with defaults" `Quick test_make_config_with_defaults;
    ];
  ]
