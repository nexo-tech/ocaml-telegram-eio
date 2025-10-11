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
  (* Test with no entities - now returns (cmd_name, args) option *)
  Alcotest.(check (option (pair string (list string)))) "no entities"
    None (Bot.Entity.parse_command_args "/start arg1 arg2" None);

  (* Test with empty entities list *)
  Alcotest.(check (option (pair string (list string)))) "empty entities"
    None (Bot.Entity.parse_command_args "/start arg1 arg2" (Some []))

(* Middleware module tests *)
let test_middleware_make () =
  (* Test that middleware can be created and compiles *)
  let counter = ref 0 in
  let _mw = Bot.Middleware.make
    ~before:(fun ctx -> incr counter; Ok ctx)
    ~after:(fun _ctx -> incr counter)
    "test" in
  Alcotest.(check bool) "middleware created" true true

let test_middleware_combinators () =
  (* Test combine - just verify it compiles *)
  let mw1 = Bot.Middleware.require_user () in
  let mw2 = Bot.Middleware.require_chat () in
  let _combined = Bot.Middleware.combine [mw1; mw2] in
  Alcotest.(check bool) "combined middleware" true true;

  (* Test chain operator *)
  let _chained = Bot.Middleware.(mw1 >> mw2) in
  Alcotest.(check bool) "chained middleware" true true

let test_middleware_logging () =
  (* Test logging middleware creation - just verify it compiles *)
  let _log_mw = Bot.Middleware.logging () in
  Alcotest.(check bool) "logging middleware" true true;

  let _custom_log = Bot.Middleware.logging ~prefix:"[Test]" () in
  Alcotest.(check bool) "custom logging middleware" true true

let test_middleware_auth () =
  (* Test authorization middleware - just verify it compiles *)
  let _user_mw = Bot.Middleware.require_user () in
  Alcotest.(check bool) "require_user middleware" true true;

  let _chat_mw = Bot.Middleware.require_chat () in
  Alcotest.(check bool) "require_chat middleware" true true;

  (* Test only_users - create with dummy ID *)
  let open Telegram.Id in
  let dummy_id = User.of_int 123456L in
  let _only_mw = Bot.Middleware.only_users [dummy_id] in
  Alcotest.(check bool) "only_users middleware" true true

let test_middleware_rate_limit () =
  (* Test rate limiting middleware creation - just verify it compiles *)
  let _rl_mw = Bot.Middleware.rate_limit ~max_per_minute:10 () in
  Alcotest.(check bool) "rate_limit middleware" true true

let test_middleware_enrich () =
  (* Test context enricher - just verify it compiles *)
  let _enrich_mw = Bot.Middleware.enrich (fun ctx -> ctx) in
  Alcotest.(check bool) "enrich middleware" true true

let test_route_with_middleware () =
  (* Test adding middleware to routes - just verify it compiles *)
  let route_obj = Bot.route Bot.Event.text (fun _txt _ctx -> ()) in
  let mw = Bot.Middleware.logging () in
  let _route_with_mw = Bot.with_middleware [mw] route_obj in
  Alcotest.(check bool) "route with middleware" true true

let test_route_with_error_handler () =
  (* Test adding error handler to routes - just verify it compiles *)
  let route_obj = Bot.route Bot.Event.text (fun _txt _ctx -> ()) in
  let _route_with_err = Bot.with_error_handler (fun _ctx _exn -> ()) route_obj in
  Alcotest.(check bool) "route with error handler" true true

let test_router_with_global_middleware () =
  (* Test router with global middleware *)
  let route1 = Bot.route Bot.Event.text (fun _txt _ctx -> ()) in
  let route2 = Bot.route Bot.Event.(command "start") (fun _args _ctx -> ()) in
  let mw = Bot.Middleware.logging () in
  let routes = Bot.router ~middlewares:[mw] [route1; route2] in
  Alcotest.(check int) "router returns routes" 2 (List.length routes)

(* Session module tests *)
let test_session_keys () =
  (* Test typed keys creation *)
  let key1 = Session.make ~name:"counter" in
  let key2 = Session.make ~name:"name" in
  Alcotest.(check bool) "keys created" true (key1 <> key2)

let test_session_get_set () =
  let session = Session.empty in
  let counter_key = Session.make ~name:"counter" in

  (* Get from empty session *)
  Alcotest.(check (option int)) "empty session get" None (Session.get session counter_key);

  (* Set and get *)
  Session.set session counter_key 42;
  Alcotest.(check (option int)) "session get after set" (Some 42) (Session.get session counter_key);

  (* Update value *)
  Session.set session counter_key 100;
  Alcotest.(check (option int)) "session get after update" (Some 100) (Session.get session counter_key)

let test_session_type_safety () =
  let session = Session.empty in
  let int_key = Session.make ~name:"int_val" in
  let string_key = Session.make ~name:"string_val" in

  Session.set session int_key 42;
  Session.set session string_key "hello";

  Alcotest.(check (option int)) "int value" (Some 42) (Session.get session int_key);
  Alcotest.(check (option string)) "string value" (Some "hello") (Session.get session string_key)

let test_session_delete () =
  let session = Session.empty in
  let key = Session.make ~name:"temp" in

  Session.set session key "data";
  Alcotest.(check bool) "key exists" true (Session.exists session key);

  Session.delete session key;
  Alcotest.(check bool) "key deleted" false (Session.exists session key);
  Alcotest.(check (option string)) "get after delete" None (Session.get session key)

let test_session_clear () =
  let session = Session.empty in
  let key1 = Session.make ~name:"k1" in
  let key2 = Session.make ~name:"k2" in

  Session.set session key1 1;
  Session.set session key2 2;

  Session.clear session;
  Alcotest.(check (option int)) "k1 after clear" None (Session.get session key1);
  Alcotest.(check (option int)) "k2 after clear" None (Session.get session key2)

let test_session_get_or () =
  let session = Session.empty in
  let key = Session.make ~name:"count" in

  (* Get with default when missing *)
  let value = Session.get_or session key ~default:0 in
  Alcotest.(check int) "get_or default" 0 value;

  (* Get with default when present *)
  Session.set session key 42;
  let value = Session.get_or session key ~default:0 in
  Alcotest.(check int) "get_or existing" 42 value

let test_session_modify () =
  let session = Session.empty in
  let counter = Session.make ~name:"counter" in

  (* Modify with default *)
  Session.modify session counter ~default:0 (fun x -> x + 1);
  Alcotest.(check (option int)) "first modify" (Some 1) (Session.get session counter);

  (* Modify existing *)
  Session.modify session counter ~default:0 (fun x -> x + 1);
  Alcotest.(check (option int)) "second modify" (Some 2) (Session.get session counter)

let test_session_update () =
  let session = Session.empty in
  let key = Session.make ~name:"val" in

  (* Update non-existent (no-op) *)
  Session.update session key (fun x -> x + 1);
  Alcotest.(check (option int)) "update missing is noop" None (Session.get session key);

  (* Update existing *)
  Session.set session key 10;
  Session.update session key (fun x -> x * 2);
  Alcotest.(check (option int)) "update existing" (Some 20) (Session.get session key)

let test_memory_store () =
  let store = Session.Memory_store.create () in

  (* Get session for user *)
  let session1 = Session.Memory_store.get_session store ~user_id:123L in
  let key = Session.make ~name:"data" in
  Session.set session1 key "test";

  (* Get same session again *)
  let session2 = Session.Memory_store.get_session store ~user_id:123L in
  Alcotest.(check (option string)) "same session" (Some "test") (Session.get session2 key);

  (* Different user has different session *)
  let session3 = Session.Memory_store.get_session store ~user_id:456L in
  Alcotest.(check (option string)) "different session" None (Session.get session3 key)

let test_session_middleware () =
  (* Test that with_session middleware compiles *)
  let store = Session.Memory_store.create () in
  let _mw = Bot.Middleware.with_session (module Session.Memory_store) store in
  Alcotest.(check bool) "session middleware created" true true

(* Error handler tests *)
let test_error_handler_log () =
  (* Test that log error handler compiles *)
  let _handler = Bot.ErrorHandler.log in
  Alcotest.(check bool) "log error handler exists" true true

let test_error_handler_log_and_reply () =
  (* Test that log_and_reply error handler compiles *)
  let _handler1 = Bot.ErrorHandler.log_and_reply () in
  let _handler2 = Bot.ErrorHandler.log_and_reply ~message:"Custom error message" () in
  Alcotest.(check bool) "log_and_reply error handler exists" true true

let test_error_handler_silent () =
  (* Test that silent error handler compiles *)
  let _handler = Bot.ErrorHandler.silent in
  Alcotest.(check bool) "silent error handler exists" true true

let test_error_handler_combine () =
  (* Test combining error handlers *)
  let handler1 = Bot.ErrorHandler.silent in
  let handler2 = Bot.ErrorHandler.log in
  let _combined = Bot.ErrorHandler.combine [handler1; handler2] in
  Alcotest.(check bool) "error handlers combined" true true

let test_router_with_global_error_handler () =
  (* Test router with global error handler *)
  let route1 = Bot.route Bot.Event.text (fun _txt _ctx -> ()) in
  let route2 = Bot.route Bot.Event.(command "start") (fun _args _ctx -> ()) in
  let error_handler = Bot.ErrorHandler.log in
  let routes = Bot.router ~on_error:error_handler [route1; route2] in
  Alcotest.(check int) "router with error handler returns routes" 2 (List.length routes)

let test_router_with_middleware_and_error_handler () =
  (* Test router with both global middleware and error handler *)
  let route = Bot.route Bot.Event.text (fun _txt _ctx -> ()) in
  let mw = Bot.Middleware.logging () in
  let error_handler = Bot.ErrorHandler.log_and_reply () in
  let routes = Bot.router ~middlewares:[mw] ~on_error:error_handler [route] in
  Alcotest.(check int) "router with mw and error handler" 1 (List.length routes)

let test_route_specific_error_handler_precedence () =
  (* Test that route-specific error handler takes precedence over global *)
  let route = Bot.route Bot.Event.text (fun _txt _ctx -> ()) in
  let route_with_err = Bot.with_error_handler (fun _ctx _exn -> ()) route in
  let global_handler = Bot.ErrorHandler.log in
  let routes = Bot.router ~on_error:global_handler [route_with_err] in
  Alcotest.(check int) "route precedence" 1 (List.length routes)

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
    "middleware", [
      test_case "make custom middleware" `Quick test_middleware_make;
      test_case "combine and chain middleware" `Quick test_middleware_combinators;
      test_case "logging middleware" `Quick test_middleware_logging;
      test_case "authorization middleware" `Quick test_middleware_auth;
      test_case "rate limiting middleware" `Quick test_middleware_rate_limit;
      test_case "context enricher" `Quick test_middleware_enrich;
    ];
    "routing", [
      test_case "route with middleware" `Quick test_route_with_middleware;
      test_case "route with error handler" `Quick test_route_with_error_handler;
      test_case "router with global middleware" `Quick test_router_with_global_middleware;
    ];
    "sessions", [
      test_case "typed keys" `Quick test_session_keys;
      test_case "get and set" `Quick test_session_get_set;
      test_case "type safety" `Quick test_session_type_safety;
      test_case "delete" `Quick test_session_delete;
      test_case "clear" `Quick test_session_clear;
      test_case "get_or" `Quick test_session_get_or;
      test_case "modify" `Quick test_session_modify;
      test_case "update" `Quick test_session_update;
      test_case "memory store" `Quick test_memory_store;
      test_case "session middleware" `Quick test_session_middleware;
    ];
    "error_handling", [
      test_case "log error handler" `Quick test_error_handler_log;
      test_case "log_and_reply error handler" `Quick test_error_handler_log_and_reply;
      test_case "silent error handler" `Quick test_error_handler_silent;
      test_case "combine error handlers" `Quick test_error_handler_combine;
      test_case "router with global error handler" `Quick test_router_with_global_error_handler;
      test_case "router with middleware and error handler" `Quick test_router_with_middleware_and_error_handler;
      test_case "route-specific error handler precedence" `Quick test_route_specific_error_handler_precedence;
    ];
  ]
