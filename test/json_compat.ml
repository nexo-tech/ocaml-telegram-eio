(* Tests for JSON forward compatibility *)

open Telegram

(* Test empty unknown fields *)
let test_empty_unknown_fields () =
  let uf = Json_compat.Unknown_fields.empty in
  Alcotest.(check bool) "is empty" true (Json_compat.Unknown_fields.is_empty uf);
  Alcotest.(check int) "count is 0" 0 (Json_compat.Unknown_fields.count uf);
  Alcotest.(check int) "to_assoc length" 0
    (List.length (Json_compat.Unknown_fields.to_assoc uf))

(* Test tracker captures unknown fields *)
let test_tracker_capture () =
  let tracker = Json_compat.Unknown_fields.create () in
  Json_compat.Unknown_fields.mark_known tracker "known1";
  Json_compat.Unknown_fields.mark_known tracker "known2";

  let all_fields = [
    ("known1", `String "value1");
    ("known2", `Int 42);
    ("unknown1", `String "value2");
    ("unknown2", `Bool true);
  ] in

  let unknown = Json_compat.Unknown_fields.capture tracker all_fields in
  Alcotest.(check int) "count is 2" 2 (Json_compat.Unknown_fields.count unknown);
  Alcotest.(check bool) "has unknown1" true
    (List.mem_assoc "unknown1" (Json_compat.Unknown_fields.to_assoc unknown));
  Alcotest.(check bool) "has unknown2" true
    (List.mem_assoc "unknown2" (Json_compat.Unknown_fields.to_assoc unknown));
  Alcotest.(check bool) "does not have known1" false
    (List.mem_assoc "known1" (Json_compat.Unknown_fields.to_assoc unknown))

let () =
  let open Alcotest in
  run "JSON forward compatibility" [
    "unknown_fields", [
      test_case "empty unknown fields" `Quick test_empty_unknown_fields;
      test_case "tracker captures unknown fields" `Quick test_tracker_capture;
    ];
  ]
