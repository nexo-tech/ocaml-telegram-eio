(* Tests for Retry strategies and backoff *)

open Telegram

(* Test immediate strategy *)
let test_strategy_immediate () =
  let strategy = Retry.Strategy.immediate in
  let delay = Retry.Strategy.next_delay strategy ~attempt:1 ~error:None in
  Alcotest.(check (float 0.001)) "immediate has 0 delay" 0.0 delay

(* Test fixed strategy *)
let test_strategy_fixed () =
  let strategy = Retry.Strategy.fixed 2.5 in
  let delay1 = Retry.Strategy.next_delay strategy ~attempt:1 ~error:None in
  let delay2 = Retry.Strategy.next_delay strategy ~attempt:5 ~error:None in
  Alcotest.(check (float 0.001)) "fixed delay attempt 1" 2.5 delay1;
  Alcotest.(check (float 0.001)) "fixed delay attempt 5" 2.5 delay2

(* Test exponential strategy *)
let test_strategy_exponential () =
  let strategy = Retry.Strategy.exponential ~initial:1.0 ~max:10.0 () in
  let delay1 = Retry.Strategy.next_delay strategy ~attempt:1 ~error:None in
  let delay2 = Retry.Strategy.next_delay strategy ~attempt:2 ~error:None in
  let delay3 = Retry.Strategy.next_delay strategy ~attempt:3 ~error:None in
  let delay10 = Retry.Strategy.next_delay strategy ~attempt:10 ~error:None in

  Alcotest.(check (float 0.001)) "exponential attempt 1" 1.0 delay1;
  Alcotest.(check (float 0.001)) "exponential attempt 2" 2.0 delay2;
  Alcotest.(check (float 0.001)) "exponential attempt 3" 4.0 delay3;
  (* Attempt 10 would be 1 * 2^9 = 512, but capped at max 10.0 *)
  Alcotest.(check (float 0.001)) "exponential capped at max" 10.0 delay10

(* Test telegram_aware strategy with retry_after *)
let test_strategy_telegram_aware_with_hint () =
  let strategy = Retry.Strategy.telegram_aware () in
  let error = Error.Api_error {
    code = 429;
    description = "Too Many Requests";
    parameters = Some { retry_after = Some 30; migrate_to_chat_id = None }
  } in
  let delay = Retry.Strategy.next_delay strategy ~attempt:1 ~error:(Some error) in
  Alcotest.(check (float 0.001)) "uses retry_after hint" 30.0 delay

(* Test telegram_aware strategy without retry_after (falls back to exponential) *)
let test_strategy_telegram_aware_without_hint () =
  let strategy = Retry.Strategy.telegram_aware () in
  let error = Error.Api_error {
    code = 500;
    description = "Internal Server Error";
    parameters = None
  } in
  let delay = Retry.Strategy.next_delay strategy ~attempt:1 ~error:(Some error) in
  (* Should fall back to exponential with initial=1.0 *)
  Alcotest.(check (float 0.001)) "falls back to exponential" 1.0 delay

(* Test with_config with successful first attempt *)
let test_retry_success_first_attempt () =
  let attempt_count = ref 0 in
  let config = Retry.make ~max_attempts:3 () in
  let result = Retry.with_config config (fun () ->
    incr attempt_count;
    Ok "success"
  ) in
  match result with
  | Ok value ->
      Alcotest.(check string) "returns value" "success" value;
      Alcotest.(check int) "only one attempt" 1 !attempt_count
  | Error e -> Alcotest.fail (Format.asprintf "Expected Ok, got Error: %a" Error.pp e)

(* Test with_config with retryable error then success *)
let test_retry_retryable_then_success () =
  let attempt_count = ref 0 in
  let config = Retry.make ~strategy:(Retry.Strategy.immediate) ~max_attempts:3 () in
  let result = Retry.with_config config (fun () ->
    incr attempt_count;
    if !attempt_count < 3 then
      Error (Error.Api_error { code = 429; description = "Rate limit"; parameters = None })
    else
      Ok "success"
  ) in
  match result with
  | Ok value ->
      Alcotest.(check string) "returns value" "success" value;
      Alcotest.(check int) "three attempts" 3 !attempt_count
  | Error e -> Alcotest.fail (Format.asprintf "Expected Ok, got Error: %a" Error.pp e)

(* Test with_config exhausts max_attempts *)
let test_retry_exhausts_attempts () =
  let attempt_count = ref 0 in
  let config = Retry.make ~strategy:(Retry.Strategy.immediate) ~max_attempts:3 () in
  let result = Retry.with_config config (fun () ->
    incr attempt_count;
    Error (Error.Api_error { code = 500; description = "Server error"; parameters = None })
  ) in
  match result with
  | Ok _ -> Alcotest.fail "Expected Error, got Ok"
  | Error (Error.Api_error { code = 500; _ }) ->
      Alcotest.(check int) "all attempts used" 3 !attempt_count
  | Error e -> Alcotest.fail (Format.asprintf "Expected Api_error 500, got: %a" Error.pp e)

(* Test with_config doesn't retry non-retryable errors *)
let test_retry_non_retryable () =
  let attempt_count = ref 0 in
  let config = Retry.make ~max_attempts:3 () in
  let result = Retry.with_config config (fun () ->
    incr attempt_count;
    Error (Error.Api_error { code = 400; description = "Bad Request"; parameters = None })
  ) in
  match result with
  | Ok _ -> Alcotest.fail "Expected Error, got Ok"
  | Error (Error.Api_error { code = 400; _ }) ->
      (* Should only attempt once since 400 is not retryable *)
      Alcotest.(check int) "only one attempt" 1 !attempt_count
  | Error e -> Alcotest.fail (Format.asprintf "Expected Api_error 400, got: %a" Error.pp e)

(* Test on_retry callback is invoked *)
let test_retry_callback () =
  let callback_count = ref 0 in
  let last_delay = ref 0.0 in
  let config = Retry.make
    ~strategy:(Retry.Strategy.fixed 0.5)
    ~max_attempts:3
    ~on_retry:(fun ~attempt:_ ~error:_ ~delay ->
        incr callback_count;
        last_delay := delay)
    ()
  in
  let attempt_count = ref 0 in
  let _result = Retry.with_config config (fun () ->
    incr attempt_count;
    if !attempt_count < 2 then
      Error (Error.Timeout)
    else
      Ok "success"
  ) in
  (* Callback should be invoked once (before second attempt) *)
  Alcotest.(check int) "callback invoked once" 1 !callback_count;
  Alcotest.(check (float 0.001)) "callback received delay" 0.5 !last_delay

let () =
  let open Alcotest in
  run "Retry strategies and backoff" [
    "strategy", [
      test_case "immediate strategy" `Quick test_strategy_immediate;
      test_case "fixed strategy" `Quick test_strategy_fixed;
      test_case "exponential strategy" `Quick test_strategy_exponential;
      test_case "telegram_aware with hint" `Quick test_strategy_telegram_aware_with_hint;
      test_case "telegram_aware without hint" `Quick test_strategy_telegram_aware_without_hint;
    ];
    "retry", [
      test_case "success on first attempt" `Quick test_retry_success_first_attempt;
      test_case "retryable then success" `Quick test_retry_retryable_then_success;
      test_case "exhausts max attempts" `Quick test_retry_exhausts_attempts;
      test_case "doesn't retry non-retryable" `Quick test_retry_non_retryable;
      test_case "on_retry callback" `Quick test_retry_callback;
    ];
  ]
