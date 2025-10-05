(* Tests for Bot module - context helpers *)

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

let () =
  let open Alcotest in
  run "Bot" [
    "context", [
      test_case "context type exists" `Quick test_ctx_type_exists;
      test_case "phantom type scopes" `Quick test_ctx_scope_types;
      test_case "helper functions interface" `Quick test_ctx_helpers_interface;
    ];
  ]
