(* Tests for Webhook module *)

open Tg

let test_make_config () =
  let config = Webhook.make ~port:8080 ~path:"/bot" ~secret_token:"secret123" ~max_connections:50 () in
  Alcotest.(check int) "port" 8080 config.port;
  Alcotest.(check string) "path" "/bot" config.path;
  Alcotest.(check (option string)) "secret_token" (Some "secret123") config.secret_token;
  Alcotest.(check int) "max_connections" 50 config.max_connections

let test_make_config_with_defaults () =
  let config = Webhook.make () in
  Alcotest.(check int) "default port" 8443 config.port;
  Alcotest.(check string) "default path" "/webhook" config.path;
  Alcotest.(check (option string)) "default secret_token" None config.secret_token;
  Alcotest.(check int) "default max_connections" 100 config.max_connections

let test_default_config () =
  let config = Webhook.default in
  Alcotest.(check int) "default port" 8443 config.port;
  Alcotest.(check string) "default path" "/webhook" config.path;
  Alcotest.(check (option string)) "default secret_token" None config.secret_token;
  Alcotest.(check int) "default max_connections" 100 config.max_connections

let test_make_config_partial () =
  let config = Webhook.make ~port:443 ~secret_token:"mytoken" () in
  Alcotest.(check int) "custom port" 443 config.port;
  Alcotest.(check string) "default path" "/webhook" config.path;
  Alcotest.(check (option string)) "custom secret_token" (Some "mytoken") config.secret_token;
  Alcotest.(check int) "default max_connections" 100 config.max_connections

let () =
  let open Alcotest in
  run "Webhook" [
    "config", [
      test_case "make config with all custom values" `Quick test_make_config;
      test_case "make with defaults" `Quick test_make_config_with_defaults;
      test_case "default config" `Quick test_default_config;
      test_case "make with partial values" `Quick test_make_config_partial;
    ];
  ]
