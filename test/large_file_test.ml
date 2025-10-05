(* Tests for Large_file module *)

open Tg

let test_default_config () =
  let config = Large_file.default_config in
  Alcotest.(check int) "chunk size" 16384 config.chunk_size;
  Alcotest.(check int) "retry attempts" 3 config.retry.max_attempts

let test_make_config () =
  let limits = Telegram.Limits.default |> Telegram.Limits.with_chunk_size 8192 in
  let retry = Telegram.Retry.make ~max_attempts:5 () in
  let config = Large_file.make_config ~limits ~retry () in
  Alcotest.(check int) "custom chunk size" 8192 config.chunk_size;
  Alcotest.(check int) "custom retry attempts" 5 config.retry.max_attempts

let test_with_chunk_size () =
  let config = Large_file.default_config in
  let config' = Large_file.with_chunk_size 32768 config in
  Alcotest.(check int) "updated chunk size" 32768 config'.chunk_size

let test_with_retry_attempts () =
  let config = Large_file.default_config in
  let config' = Large_file.with_retry_attempts 10 config in
  Alcotest.(check int) "updated retry attempts" 10 config'.retry.max_attempts

let test_config_builder_chain () =
  let config = Large_file.default_config
    |> Large_file.with_chunk_size 4096
    |> Large_file.with_retry_attempts 7 in
  Alcotest.(check int) "chain chunk size" 4096 config.chunk_size;
  Alcotest.(check int) "chain retry attempts" 7 config.retry.max_attempts

let () =
  let open Alcotest in
  run "Large_file" [
    "config", [
      test_case "default_config" `Quick test_default_config;
      test_case "make_config" `Quick test_make_config;
      test_case "with_chunk_size" `Quick test_with_chunk_size;
      test_case "with_retry_attempts" `Quick test_with_retry_attempts;
      test_case "builder chain" `Quick test_config_builder_chain;
    ];
  ]
