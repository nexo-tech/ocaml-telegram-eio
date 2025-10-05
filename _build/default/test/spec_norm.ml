open Alcotest

let check_parse name s expected =
  let got = Telegram.Spec_norm.parse_type s |> Telegram.Spec_norm.to_string in
  check string name expected got

let test_parse_types () =
  check_parse "Integer" "Integer" "int64";
  check_parse "String" "String" "string";
  check_parse "Boolean" "Boolean" "bool";
  check_parse "Array" "Array of Integer" "int64 list";
  check_parse "Union" "Integer or String" "int64 | string";
  check_parse "Nested Array" "Array of Array of String" "string list list";
  check_parse "Custom" "Message" "Message";
  ()

let test_names () =
  let f = Telegram.Spec_norm.ocaml_field_name in
  check string "reserved" "type_" (f "type");
  let t = Telegram.Spec_norm.ocaml_type_name in
  check string "Camel" "message_entity" (t "MessageEntity");
  ()

let () =
  run "spec_norm" [
    ("parse", [ test_case "basic" `Quick test_parse_types ]);
    ("names", [ test_case "idents" `Quick test_names ]);
  ]
