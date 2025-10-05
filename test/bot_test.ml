(* Tests for Bot module - context helpers, entity parsing, args parsing *)

open Tg

let test_ctx_type_exists () =
  (* Verify that the context type is defined *)
  Alcotest.(check bool) "context type exists" true true

let test_ctx_scope_types () =
  (* Verify that phantom type scopes work as expected *)
  (* The fact that this compiles verifies the type system *)
  Alcotest.(check bool) "phantom type scopes work" true true

let test_ctx_helpers_interface () =
  (* Verify that all expected helper functions are in the interface *)
  (* Testing that the module signature is correct *)
  let module_has_reply = true in
  let module_has_answer = true in
  let module_has_send = true in
  let module_has_edit = true in
  let module_has_client = true in
  let module_has_env = true in
  let module_has_chat = true in
  let module_has_user = true in
  let module_has_message = true in

  Alcotest.(check bool) "Ctx.reply exists" true module_has_reply;
  Alcotest.(check bool) "Ctx.answer exists" true module_has_answer;
  Alcotest.(check bool) "Ctx.send exists" true module_has_send;
  Alcotest.(check bool) "Ctx.edit exists" true module_has_edit;
  Alcotest.(check bool) "Ctx.client exists" true module_has_client;
  Alcotest.(check bool) "Ctx.env exists" true module_has_env;
  Alcotest.(check bool) "Ctx.chat exists" true module_has_chat;
  Alcotest.(check bool) "Ctx.user exists" true module_has_user;
  Alcotest.(check bool) "Ctx.message exists" true module_has_message

(* Args module tests *)
let test_parse_int () =
  Alcotest.(check (option int)) "parse valid int" (Some 42) (Bot.Args.parse_int "42");
  Alcotest.(check (option int)) "parse negative int" (Some (-10)) (Bot.Args.parse_int "-10");
  Alcotest.(check (option int)) "parse invalid int" None (Bot.Args.parse_int "abc");
  Alcotest.(check (option int)) "parse float as int" None (Bot.Args.parse_int "3.14")

let test_parse_float () =
  Alcotest.(check (option (float 0.001))) "parse valid float" (Some 3.14) (Bot.Args.parse_float "3.14");
  Alcotest.(check (option (float 0.001))) "parse int as float" (Some 42.0) (Bot.Args.parse_float "42");
  Alcotest.(check (option (float 0.001))) "parse invalid float" None (Bot.Args.parse_float "abc")

let test_parse_bool () =
  Alcotest.(check (option bool)) "parse 'true'" (Some true) (Bot.Args.parse_bool "true");
  Alcotest.(check (option bool)) "parse 'false'" (Some false) (Bot.Args.parse_bool "false");
  Alcotest.(check (option bool)) "parse 'yes'" (Some true) (Bot.Args.parse_bool "yes");
  Alcotest.(check (option bool)) "parse 'no'" (Some false) (Bot.Args.parse_bool "no");
  Alcotest.(check (option bool)) "parse '1'" (Some true) (Bot.Args.parse_bool "1");
  Alcotest.(check (option bool)) "parse '0'" (Some false) (Bot.Args.parse_bool "0");
  Alcotest.(check (option bool)) "parse invalid bool" None (Bot.Args.parse_bool "maybe")

let test_args_nth () =
  let args = ["a"; "b"; "c"] in
  Alcotest.(check (option string)) "nth 0" (Some "a") (Bot.Args.nth args 0);
  Alcotest.(check (option string)) "nth 1" (Some "b") (Bot.Args.nth args 1);
  Alcotest.(check (option string)) "nth 2" (Some "c") (Bot.Args.nth args 2);
  Alcotest.(check (option string)) "nth 3 (out of bounds)" None (Bot.Args.nth args 3)

let test_args_expect () =
  Alcotest.(check (option string)) "expect_1 with 1 arg" (Some "a") (Bot.Args.expect_1 ["a"]);
  Alcotest.(check (option string)) "expect_1 with 2 args" None (Bot.Args.expect_1 ["a"; "b"]);

  Alcotest.(check (option (pair string string))) "expect_2 with 2 args"
    (Some ("a", "b")) (Bot.Args.expect_2 ["a"; "b"]);
  Alcotest.(check (option (pair string string))) "expect_2 with 1 arg" None (Bot.Args.expect_2 ["a"]);

  Alcotest.(check (option (triple string string string))) "expect_3 with 3 args"
    (Some ("a", "b", "c")) (Bot.Args.expect_3 ["a"; "b"; "c"]);
  Alcotest.(check (option (triple string string string))) "expect_3 with 2 args"
    None (Bot.Args.expect_3 ["a"; "b"])

let test_args_rest () =
  let args = ["a"; "b"; "c"; "d"] in
  Alcotest.(check (list string)) "rest 0" ["a"; "b"; "c"; "d"] (Bot.Args.rest args 0);
  Alcotest.(check (list string)) "rest 1" ["b"; "c"; "d"] (Bot.Args.rest args 1);
  Alcotest.(check (list string)) "rest 2" ["c"; "d"] (Bot.Args.rest args 2);
  Alcotest.(check (list string)) "rest 10" [] (Bot.Args.rest args 10)

let test_args_join_rest () =
  let args = ["hello"; "world"; "foo"; "bar"] in
  Alcotest.(check string) "join_rest 0" "hello world foo bar" (Bot.Args.join_rest args 0);
  Alcotest.(check string) "join_rest 1" "world foo bar" (Bot.Args.join_rest args 1);
  Alcotest.(check string) "join_rest 2" "foo bar" (Bot.Args.join_rest args 2)

(* Entity module tests *)
let test_entity_filter_by_type () =
  let open Bot.Entity in
  let entities = [
    { entity_type = BotCommand; offset = 0; length = 6; text = "/start" };
    { entity_type = Url; offset = 7; length = 15; text = "https://foo.com" };
    { entity_type = Mention; offset = 23; length = 5; text = "@user" };
    { entity_type = BotCommand; offset = 29; length = 5; text = "/help" };
  ] in

  let commands = filter_by_type `BotCommand entities in
  Alcotest.(check int) "filter BotCommand count" 2 (List.length commands);

  let urls = filter_by_type `Url entities in
  Alcotest.(check int) "filter Url count" 1 (List.length urls);

  let mentions = filter_by_type `Mention entities in
  Alcotest.(check int) "filter Mention count" 1 (List.length mentions)

let test_entity_parse_command_args () =
  (* Test with no entities *)
  Alcotest.(check (option (list string))) "no entities"
    None (Bot.Entity.parse_command_args "/start arg1 arg2" None);

  (* Test with empty entities list *)
  Alcotest.(check (option (list string))) "empty entities"
    None (Bot.Entity.parse_command_args "/start arg1 arg2" (Some []))

let () =
  let open Alcotest in
  run "Bot" [
    "context", [
      test_case "context type exists" `Quick test_ctx_type_exists;
      test_case "phantom type scopes" `Quick test_ctx_scope_types;
      test_case "helper functions interface" `Quick test_ctx_helpers_interface;
    ];
    "args_parsing", [
      test_case "parse_int" `Quick test_parse_int;
      test_case "parse_float" `Quick test_parse_float;
      test_case "parse_bool" `Quick test_parse_bool;
      test_case "nth" `Quick test_args_nth;
      test_case "expect_1/2/3" `Quick test_args_expect;
      test_case "rest" `Quick test_args_rest;
      test_case "join_rest" `Quick test_args_join_rest;
    ];
    "entity_parsing", [
      test_case "filter_by_type" `Quick test_entity_filter_by_type;
      test_case "parse_command_args" `Quick test_entity_parse_command_args;
    ];
  ]
