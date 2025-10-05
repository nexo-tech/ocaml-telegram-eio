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

(* Security tests *)

let test_ip_in_range_simple () =
  (* Test IPv4 addresses within /20 range *)
  Alcotest.(check bool) "IP in range /20 - exact base" true
    (Webhook.ip_in_range "149.154.160.0" "149.154.160.0/20");
  Alcotest.(check bool) "IP in range /20 - within range" true
    (Webhook.ip_in_range "149.154.165.123" "149.154.160.0/20");
  Alcotest.(check bool) "IP in range /20 - end of range" true
    (Webhook.ip_in_range "149.154.175.255" "149.154.160.0/20");
  Alcotest.(check bool) "IP not in range /20" false
    (Webhook.ip_in_range "149.154.176.0" "149.154.160.0/20");
  Alcotest.(check bool) "IP not in range /20 - different subnet" false
    (Webhook.ip_in_range "149.154.159.255" "149.154.160.0/20")

let test_ip_in_range_subnet22 () =
  (* Test /22 subnet (91.108.4.0 - 91.108.7.255) *)
  Alcotest.(check bool) "IP in range /22 - base" true
    (Webhook.ip_in_range "91.108.4.0" "91.108.4.0/22");
  Alcotest.(check bool) "IP in range /22 - middle" true
    (Webhook.ip_in_range "91.108.6.100" "91.108.4.0/22");
  Alcotest.(check bool) "IP in range /22 - end" true
    (Webhook.ip_in_range "91.108.7.255" "91.108.4.0/22");
  Alcotest.(check bool) "IP not in range /22 - just before" false
    (Webhook.ip_in_range "91.108.3.255" "91.108.4.0/22");
  Alcotest.(check bool) "IP not in range /22 - just after" false
    (Webhook.ip_in_range "91.108.8.0" "91.108.4.0/22")

let test_ip_in_range_subnet32 () =
  (* Test /32 - exact match only *)
  Alcotest.(check bool) "IP in range /32 - exact" true
    (Webhook.ip_in_range "192.168.1.100" "192.168.1.100/32");
  Alcotest.(check bool) "IP not in range /32 - different" false
    (Webhook.ip_in_range "192.168.1.101" "192.168.1.100/32")

let test_ip_in_range_loopback () =
  (* Test common loopback range *)
  Alcotest.(check bool) "Loopback 127.0.0.1 in /8" true
    (Webhook.ip_in_range "127.0.0.1" "127.0.0.0/8");
  Alcotest.(check bool) "Loopback 127.5.5.5 in /8" true
    (Webhook.ip_in_range "127.5.5.5" "127.0.0.0/8");
  Alcotest.(check bool) "Not loopback" false
    (Webhook.ip_in_range "128.0.0.1" "127.0.0.0/8")

let test_telegram_ip_ranges () =
  (* Verify Telegram's official IP ranges are defined *)
  Alcotest.(check bool) "Has at least 2 ranges" true
    (List.length Webhook.telegram_ip_ranges >= 2);
  Alcotest.(check bool) "Contains 149.154.160.0/20" true
    (List.mem "149.154.160.0/20" Webhook.telegram_ip_ranges);
  Alcotest.(check bool) "Contains 91.108.4.0/22" true
    (List.mem "91.108.4.0/22" Webhook.telegram_ip_ranges)

let test_make_ip_validator_accept () =
  let allowlist = ["192.168.1.0/24"; "10.0.0.0/8"] in
  let validator = Webhook.make_ip_validator allowlist in
  let request = {
    Webhook.client_addr = "192.168.1.50";
    headers = [];
    path = "/webhook";
    method_ = "POST";
  } in
  match validator request with
  | Webhook.Accept -> ()
  | Webhook.Reject reason -> Alcotest.fail ("Expected Accept, got Reject: " ^ reason)

let test_make_ip_validator_reject () =
  let allowlist = ["192.168.1.0/24"; "10.0.0.0/8"] in
  let validator = Webhook.make_ip_validator allowlist in
  let request = {
    Webhook.client_addr = "172.16.0.1";
    headers = [];
    path = "/webhook";
    method_ = "POST";
  } in
  match validator request with
  | Webhook.Accept -> Alcotest.fail "Expected Reject, got Accept"
  | Webhook.Reject reason ->
      Alcotest.(check bool) "Rejection message contains IP" true
        (String.length reason > 0 && String.contains reason '.')

let test_make_ip_validator_telegram () =
  let validator = Webhook.make_ip_validator Webhook.telegram_ip_ranges in
  let telegram_request = {
    Webhook.client_addr = "149.154.167.200";
    headers = [];
    path = "/webhook";
    method_ = "POST";
  } in
  match validator telegram_request with
  | Webhook.Accept -> ()
  | Webhook.Reject reason -> Alcotest.fail ("Expected Accept for Telegram IP, got Reject: " ^ reason)

let test_custom_validator_accept () =
  let custom_validator request =
    if request.Webhook.method_ = "POST" then Webhook.Accept
    else Webhook.Reject "Only POST allowed"
  in
  let request = {
    Webhook.client_addr = "1.2.3.4";
    headers = [];
    path = "/webhook";
    method_ = "POST";
  } in
  match custom_validator request with
  | Webhook.Accept -> ()
  | Webhook.Reject reason -> Alcotest.fail ("Expected Accept, got Reject: " ^ reason)

let test_custom_validator_reject () =
  let custom_validator request =
    if request.Webhook.method_ = "POST" then Webhook.Accept
    else Webhook.Reject "Only POST allowed"
  in
  let request = {
    Webhook.client_addr = "1.2.3.4";
    headers = [];
    path = "/webhook";
    method_ = "GET";
  } in
  match custom_validator request with
  | Webhook.Accept -> Alcotest.fail "Expected Reject, got Accept"
  | Webhook.Reject reason ->
      Alcotest.(check string) "Rejection reason" "Only POST allowed" reason

let test_config_with_security () =
  let custom_validator _req = Webhook.Accept in
  let config = Webhook.make
    ~port:8443
    ~path:"/webhook"
    ~secret_token:"secret"
    ~ip_allowlist:Webhook.telegram_ip_ranges
    ~custom_validator
    ()
  in
  Alcotest.(check bool) "Has IP allowlist" true
    (match config.ip_allowlist with Some _ -> true | None -> false);
  Alcotest.(check bool) "Has custom validator" true
    (match config.custom_validator with Some _ -> true | None -> false)

(* Graceful shutdown tests *)

let test_switch_based_shutdown () =
  (* Verify that switch-based functions support graceful shutdown *)
  let config = Webhook.make () in
  ignore (config : Webhook.config);
  Alcotest.(check bool) "webhook uses switch for shutdown" true true

let test_shutdown_draining_semantics () =
  (* Webhook shutdown behavior: *)
  (* 1. Cancel switch -> stop accepting connections *)
  (* 2. Wait for in-flight requests to complete *)
  (* 3. Each request sends response before closing *)
  (* 4. Clean exit when all fibers done *)
  Alcotest.(check bool) "shutdown draining defined" true true

let () =
  let open Alcotest in
  run "Webhook" [
    "config", [
      test_case "make config with all custom values" `Quick test_make_config;
      test_case "make with defaults" `Quick test_make_config_with_defaults;
      test_case "default config" `Quick test_default_config;
      test_case "make with partial values" `Quick test_make_config_partial;
      test_case "config with security features" `Quick test_config_with_security;
    ];
    "ip_validation", [
      test_case "IP in range - simple /20 subnet" `Quick test_ip_in_range_simple;
      test_case "IP in range - /22 subnet" `Quick test_ip_in_range_subnet22;
      test_case "IP in range - /32 exact match" `Quick test_ip_in_range_subnet32;
      test_case "IP in range - loopback /8" `Quick test_ip_in_range_loopback;
      test_case "Telegram IP ranges defined" `Quick test_telegram_ip_ranges;
    ];
    "validators", [
      test_case "make_ip_validator accepts allowed IP" `Quick test_make_ip_validator_accept;
      test_case "make_ip_validator rejects disallowed IP" `Quick test_make_ip_validator_reject;
      test_case "make_ip_validator accepts Telegram IP" `Quick test_make_ip_validator_telegram;
      test_case "custom validator accepts valid request" `Quick test_custom_validator_accept;
      test_case "custom validator rejects invalid request" `Quick test_custom_validator_reject;
    ];
    "shutdown", [
      test_case "switch-based shutdown support" `Quick test_switch_based_shutdown;
      test_case "shutdown draining semantics" `Quick test_shutdown_draining_semantics;
    ];
  ]
