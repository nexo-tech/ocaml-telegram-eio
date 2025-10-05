(* Tests for Limits module *)

open Telegram

let test_size_limit_bytes () =
  Alcotest.(check (option int64)) "Unlimited" None (Limits.size_limit_bytes Limits.Unlimited);
  Alcotest.(check (option int64)) "Max_bytes" (Some 1024L) (Limits.size_limit_bytes (Limits.Max_bytes 1024L));
  Alcotest.(check (option int64)) "Max_mb 1" (Some 1_048_576L) (Limits.size_limit_bytes (Limits.Max_mb 1));
  Alcotest.(check (option int64)) "Max_mb 50" (Some 52_428_800L) (Limits.size_limit_bytes (Limits.Max_mb 50))

let test_check_size () =
  (* Unlimited - always OK *)
  (match Limits.check_size Limits.Unlimited 999_999_999L with
   | Ok () -> ()
   | Error _ -> Alcotest.fail "Unlimited should allow any size");

  (* Max_bytes - exact limit *)
  (match Limits.check_size (Limits.Max_bytes 100L) 100L with
   | Ok () -> ()
   | Error _ -> Alcotest.fail "Should allow size equal to limit");

  (* Max_bytes - under limit *)
  (match Limits.check_size (Limits.Max_bytes 100L) 50L with
   | Ok () -> ()
   | Error _ -> Alcotest.fail "Should allow size under limit");

  (* Max_bytes - over limit *)
  (match Limits.check_size (Limits.Max_bytes 100L) 101L with
   | Ok () -> Alcotest.fail "Should reject size over limit"
   | Error _ -> ());

  (* Max_mb *)
  (match Limits.check_size (Limits.Max_mb 1) 1_048_576L with
   | Ok () -> ()
   | Error _ -> Alcotest.fail "Should allow 1MB when limit is 1MB");

  (match Limits.check_size (Limits.Max_mb 1) 1_048_577L with
   | Ok () -> Alcotest.fail "Should reject size over 1MB"
   | Error _ -> ())

let test_default_policy () =
  let p = Limits.default in
  Alcotest.(check bool) "unlimited upload" true (Limits.size_limit_bytes p.max_upload_size = None);
  Alcotest.(check bool) "unlimited download" true (Limits.size_limit_bytes p.max_download_size = None);
  Alcotest.(check (option string)) "no temp dir" None p.temp_dir;
  Alcotest.(check (option (float 0.1))) "no timeout" None p.request_timeout;
  Alcotest.(check int) "chunk size" 16384 p.chunk_size

let test_telegram_limits_policy () =
  let p = Limits.telegram_limits in
  Alcotest.(check (option int64)) "50MB upload" (Some 52_428_800L) (Limits.size_limit_bytes p.max_upload_size);
  Alcotest.(check (option int64)) "20MB download" (Some 20_971_520L) (Limits.size_limit_bytes p.max_download_size);
  Alcotest.(check (option string)) "no temp dir" None p.temp_dir;
  Alcotest.(check (option (float 0.1))) "60s timeout" (Some 60.0) p.request_timeout;
  Alcotest.(check int) "chunk size" 16384 p.chunk_size

let test_with_max_upload () =
  let p = Limits.default |> Limits.with_max_upload 100 in
  Alcotest.(check (option int64)) "100MB upload" (Some 104_857_600L) (Limits.size_limit_bytes p.max_upload_size)

let test_with_max_download () =
  let p = Limits.default |> Limits.with_max_download 50 in
  Alcotest.(check (option int64)) "50MB download" (Some 52_428_800L) (Limits.size_limit_bytes p.max_download_size)

let test_with_temp_dir () =
  let p = Limits.default |> Limits.with_temp_dir "/custom/temp" in
  Alcotest.(check (option string)) "custom temp dir" (Some "/custom/temp") p.temp_dir

let test_with_timeout () =
  let p = Limits.default |> Limits.with_timeout 30.0 in
  Alcotest.(check (option (float 0.1))) "30s timeout" (Some 30.0) p.request_timeout

let test_with_chunk_size () =
  let p = Limits.default |> Limits.with_chunk_size 32768 in
  Alcotest.(check int) "32KB chunk" 32768 p.chunk_size

let test_builder_chain () =
  let p = Limits.default
    |> Limits.with_max_upload 25
    |> Limits.with_max_download 10
    |> Limits.with_temp_dir "/tmp/bot"
    |> Limits.with_timeout 45.0
    |> Limits.with_chunk_size 8192 in
  Alcotest.(check (option int64)) "25MB upload" (Some 26_214_400L) (Limits.size_limit_bytes p.max_upload_size);
  Alcotest.(check (option int64)) "10MB download" (Some 10_485_760L) (Limits.size_limit_bytes p.max_download_size);
  Alcotest.(check (option string)) "temp dir" (Some "/tmp/bot") p.temp_dir;
  Alcotest.(check (option (float 0.1))) "timeout" (Some 45.0) p.request_timeout;
  Alcotest.(check int) "chunk size" 8192 p.chunk_size

let test_check_upload_size () =
  let p = Limits.telegram_limits in
  (* Under limit *)
  (match Limits.check_upload_size p 1_000_000L with
   | Ok () -> ()
   | Error _ -> Alcotest.fail "Should allow 1MB upload");
  (* Over limit *)
  (match Limits.check_upload_size p 100_000_000L with
   | Ok () -> Alcotest.fail "Should reject 100MB upload"
   | Error _ -> ())

let test_check_download_size () =
  let p = Limits.telegram_limits in
  (* Under limit *)
  (match Limits.check_download_size p 10_000_000L with
   | Ok () -> ()
   | Error _ -> Alcotest.fail "Should allow 10MB download");
  (* Over limit *)
  (match Limits.check_download_size p 30_000_000L with
   | Ok () -> Alcotest.fail "Should reject 30MB download"
   | Error _ -> ())

let test_get_temp_dir () =
  let p1 = Limits.default in
  let default_temp = Limits.get_temp_dir p1 in
  Alcotest.(check bool) "system default is non-empty" true (String.length default_temp > 0);

  let p2 = Limits.default |> Limits.with_temp_dir "/my/temp" in
  Alcotest.(check string) "custom temp dir" "/my/temp" (Limits.get_temp_dir p2)

let test_get_chunk_size () =
  let p = Limits.default in
  Alcotest.(check int) "default chunk size" 16384 (Limits.get_chunk_size p);

  let p2 = p |> Limits.with_chunk_size 4096 in
  Alcotest.(check int) "custom chunk size" 4096 (Limits.get_chunk_size p2)

let () =
  let open Alcotest in
  run "Limits" [
    "size_limit", [
      test_case "size_limit_bytes" `Quick test_size_limit_bytes;
      test_case "check_size" `Quick test_check_size;
    ];
    "policies", [
      test_case "default policy" `Quick test_default_policy;
      test_case "telegram_limits policy" `Quick test_telegram_limits_policy;
    ];
    "builders", [
      test_case "with_max_upload" `Quick test_with_max_upload;
      test_case "with_max_download" `Quick test_with_max_download;
      test_case "with_temp_dir" `Quick test_with_temp_dir;
      test_case "with_timeout" `Quick test_with_timeout;
      test_case "with_chunk_size" `Quick test_with_chunk_size;
      test_case "builder chain" `Quick test_builder_chain;
    ];
    "application", [
      test_case "check_upload_size" `Quick test_check_upload_size;
      test_case "check_download_size" `Quick test_check_download_size;
      test_case "get_temp_dir" `Quick test_get_temp_dir;
      test_case "get_chunk_size" `Quick test_get_chunk_size;
    ];
  ]
