(* Tests for Units module *)

open Telegram

(* Duration tests *)

let test_duration_seconds () =
  let d = Units.Duration.seconds 30 in
  Alcotest.(check int) "to_int" 30 (Units.Duration.to_int d);
  Alcotest.(check int64) "to_int64" 30L (Units.Duration.to_int64 d)

let test_duration_of_int64 () =
  let d = Units.Duration.of_int64 120L in
  Alcotest.(check int) "to_int" 120 (Units.Duration.to_int d)

let test_duration_pp_seconds () =
  let d = Units.Duration.seconds 45 in
  Alcotest.(check string) "pp" "45s" (Units.Duration.to_string d)

let test_duration_pp_minutes () =
  let d = Units.Duration.seconds 120 in
  Alcotest.(check string) "pp" "2m" (Units.Duration.to_string d)

let test_duration_pp_minutes_seconds () =
  let d = Units.Duration.seconds 135 in
  Alcotest.(check string) "pp" "2m15s" (Units.Duration.to_string d)

let test_duration_pp_hours () =
  let d = Units.Duration.seconds 3600 in
  Alcotest.(check string) "pp" "1h" (Units.Duration.to_string d)

let test_duration_pp_hours_minutes () =
  let d = Units.Duration.seconds 3660 in
  Alcotest.(check string) "pp" "1h1m" (Units.Duration.to_string d)

let test_duration_pp_hours_minutes_seconds () =
  let d = Units.Duration.seconds 3665 in
  Alcotest.(check string) "pp" "1h1m5s" (Units.Duration.to_string d)

let test_duration_json_roundtrip () =
  let d = Units.Duration.seconds 300 in
  let json = Units.Duration.to_yojson d in
  match Units.Duration.of_yojson json with
  | Ok decoded ->
      Alcotest.(check int) "roundtrip" 300 (Units.Duration.to_int decoded)
  | Error msg -> Alcotest.fail msg

let test_duration_json_from_int () =
  match Units.Duration.of_yojson (`Int 60) with
  | Ok d -> Alcotest.(check int) "from_int" 60 (Units.Duration.to_int d)
  | Error msg -> Alcotest.fail msg

let test_duration_json_from_intlit () =
  match Units.Duration.of_yojson (`Intlit "120") with
  | Ok d -> Alcotest.(check int) "from_intlit" 120 (Units.Duration.to_int d)
  | Error msg -> Alcotest.fail msg

let test_duration_json_invalid () =
  match Units.Duration.of_yojson (`String "invalid") with
  | Ok _ -> Alcotest.fail "should fail"
  | Error msg ->
      Alcotest.(check bool) "error message" true (String.length msg > 0)

(* File_size tests *)

let test_file_size_bytes () =
  let fs = Units.File_size.bytes 512L in
  Alcotest.(check int64) "to_int64" 512L (Units.File_size.to_int64 fs)

let test_file_size_pp_bytes () =
  let fs = Units.File_size.bytes 512L in
  Alcotest.(check string) "pp" "512 B" (Units.File_size.to_string fs)

let test_file_size_pp_kb () =
  let fs = Units.File_size.bytes 2048L in
  Alcotest.(check string) "pp" "2.0 KB" (Units.File_size.to_string fs)

let test_file_size_pp_mb () =
  let fs = Units.File_size.bytes 5242880L in (* 5 MB *)
  Alcotest.(check string) "pp" "5.0 MB" (Units.File_size.to_string fs)

let test_file_size_pp_gb () =
  let fs = Units.File_size.bytes 3221225472L in (* 3 GB *)
  Alcotest.(check string) "pp" "3.0 GB" (Units.File_size.to_string fs)

let test_file_size_pp_tb () =
  let fs = Units.File_size.bytes 5497558138880L in (* 5 TB *)
  Alcotest.(check string) "pp" "5.0 TB" (Units.File_size.to_string fs)

let test_file_size_pp_fractional () =
  let fs = Units.File_size.bytes 1536L in (* 1.5 KB *)
  Alcotest.(check string) "pp" "1.5 KB" (Units.File_size.to_string fs)

let test_file_size_json_roundtrip () =
  let fs = Units.File_size.bytes 1048576L in (* 1 MB *)
  let json = Units.File_size.to_yojson fs in
  match Units.File_size.of_yojson json with
  | Ok decoded ->
      Alcotest.(check int64) "roundtrip" 1048576L (Units.File_size.to_int64 decoded)
  | Error msg -> Alcotest.fail msg

let test_file_size_json_from_int () =
  match Units.File_size.of_yojson (`Int 1024) with
  | Ok fs -> Alcotest.(check int64) "from_int" 1024L (Units.File_size.to_int64 fs)
  | Error msg -> Alcotest.fail msg

let test_file_size_json_from_intlit () =
  match Units.File_size.of_yojson (`Intlit "2048") with
  | Ok fs -> Alcotest.(check int64) "from_intlit" 2048L (Units.File_size.to_int64 fs)
  | Error msg -> Alcotest.fail msg

let test_file_size_json_large () =
  let fs = Units.File_size.bytes 9999999999L in
  let json = Units.File_size.to_yojson fs in
  match Units.File_size.of_yojson json with
  | Ok decoded ->
      Alcotest.(check int64) "large roundtrip" 9999999999L (Units.File_size.to_int64 decoded)
  | Error msg -> Alcotest.fail msg

let test_file_size_json_invalid () =
  match Units.File_size.of_yojson (`String "invalid") with
  | Ok _ -> Alcotest.fail "should fail"
  | Error msg ->
      Alcotest.(check bool) "error message" true (String.length msg > 0)

let () =
  let open Alcotest in
  run "Units" [
    "duration_creation", [
      test_case "seconds" `Quick test_duration_seconds;
      test_case "of_int64" `Quick test_duration_of_int64;
    ];
    "duration_formatting", [
      test_case "pp_seconds" `Quick test_duration_pp_seconds;
      test_case "pp_minutes" `Quick test_duration_pp_minutes;
      test_case "pp_minutes_seconds" `Quick test_duration_pp_minutes_seconds;
      test_case "pp_hours" `Quick test_duration_pp_hours;
      test_case "pp_hours_minutes" `Quick test_duration_pp_hours_minutes;
      test_case "pp_hours_minutes_seconds" `Quick test_duration_pp_hours_minutes_seconds;
    ];
    "duration_json", [
      test_case "roundtrip" `Quick test_duration_json_roundtrip;
      test_case "from_int" `Quick test_duration_json_from_int;
      test_case "from_intlit" `Quick test_duration_json_from_intlit;
      test_case "invalid" `Quick test_duration_json_invalid;
    ];
    "file_size_creation", [
      test_case "bytes" `Quick test_file_size_bytes;
    ];
    "file_size_formatting", [
      test_case "pp_bytes" `Quick test_file_size_pp_bytes;
      test_case "pp_kb" `Quick test_file_size_pp_kb;
      test_case "pp_mb" `Quick test_file_size_pp_mb;
      test_case "pp_gb" `Quick test_file_size_pp_gb;
      test_case "pp_tb" `Quick test_file_size_pp_tb;
      test_case "pp_fractional" `Quick test_file_size_pp_fractional;
    ];
    "file_size_json", [
      test_case "roundtrip" `Quick test_file_size_json_roundtrip;
      test_case "from_int" `Quick test_file_size_json_from_int;
      test_case "from_intlit" `Quick test_file_size_json_from_intlit;
      test_case "large" `Quick test_file_size_json_large;
      test_case "invalid" `Quick test_file_size_json_invalid;
    ];
  ]
