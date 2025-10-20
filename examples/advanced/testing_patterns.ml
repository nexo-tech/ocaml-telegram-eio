(** Testing Patterns Demo - Demonstration of testable bot design

    This example demonstrates how to write testable bot code:
    - Pure business logic separated from I/O
    - Testable validation functions
    - Testable argument parsing
    - Testable state transitions
    - Self-testing commands that verify logic

    Commands:
      /start - Show main menu
      /test_validation - Test validation functions
      /test_args - Test argument parsing
      /test_calculation - Test business calculations
      /register <name> <email> - Testable registration flow
      /calculate <price> <is_premium> - Testable discount calculation
      /validate_email <email> - Test email validation
      /validate_name <name> - Test name validation
      /self_test - Run all self-tests

    This example demonstrates TESTABLE DESIGN PATTERNS with verbose logging.

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/testing_patterns_demo.exe
*)

open Telegram
open Tg

(* Configure verbose logging with flo *)
let () = Flo.set_level Severity.Debug

(** Pure business logic - Fully testable without I/O *)
module BusinessLogic = struct
  type validation_error =
    | EmptyName
    | NameTooLong
    | InvalidEmail
    | InvalidPrice
    | InvalidBoolean

  (** Validate name - pure function, easily testable *)
  let validate_name name =
    Flo.debugf "[BusinessLogic] validate_name: %s" name;
    if String.length name = 0 then
      Error EmptyName
    else if String.length name > 50 then
      Error NameTooLong
    else
      Ok name

  (** Validate email - pure function *)
  let validate_email email =
    Flo.debugf "[BusinessLogic] validate_email: %s" email;
    if String.contains email '@' && String.contains email '.' then
      Ok email
    else
      Error InvalidEmail

  (** Parse price from string - pure function *)
  let parse_price s =
    Flo.debugf "[BusinessLogic] parse_price: %s" s;
    try
      let price = float_of_string s in
      if price >= 0.0 then Ok price else Error InvalidPrice
    with _ -> Error InvalidPrice

  (** Parse boolean from string - pure function *)
  let parse_bool s =
    Flo.debugf "[BusinessLogic] parse_bool: %s" s;
    match String.lowercase_ascii s with
    | "true" | "yes" | "1" | "premium" -> Ok true
    | "false" | "no" | "0" | "regular" -> Ok false
    | _ -> Error InvalidBoolean

  (** Calculate discount - pure function *)
  let calculate_discount price is_premium =
    Flo.debugf "[BusinessLogic] calculate_discount: price=%.2f, premium=%b" price is_premium;
    if is_premium then
      price *. 0.8  (* 20% discount for premium *)
    else
      price

  (** Format greeting - pure function *)
  let format_greeting name =
    Printf.sprintf "👋 Hello, %s! Welcome to our bot." name

  (** Validation error to user message *)
  let error_to_message = function
    | EmptyName -> "❌ Name cannot be empty"
    | NameTooLong -> "❌ Name is too long (max 50 characters)"
    | InvalidEmail -> "❌ Invalid email address (must contain @ and .)"
    | InvalidPrice -> "❌ Invalid price (must be a positive number)"
    | InvalidBoolean -> "❌ Invalid boolean (use: true/false, yes/no, 1/0, premium/regular)"
end

(** Self-testing module - demonstrates how to write tests *)
module SelfTest = struct
  type test_result = {
    name: string;
    passed: bool;
    message: string;
  }

  let run_test name test_fn =
    Flo.debugf "[SelfTest] Running: %s" name;
    try
      test_fn ();
      Flo.debugf "[SelfTest] ✓ %s PASSED" name;
      { name; passed = true; message = "✓ PASSED" }
    with
    | Failure msg ->
        Flo.debugf "[SelfTest] ✗ %s FAILED: %s" name msg;
        { name; passed = false; message = "✗ FAILED: " ^ msg }
    | exn ->
        let msg = Printexc.to_string exn in
        Flo.debugf "[SelfTest] ✗ %s ERROR: %s" name msg;
        { name; passed = false; message = "✗ ERROR: " ^ msg }

  let test_name_validation () =
    let open BusinessLogic in

    (* Valid name *)
    (match validate_name "Alice" with
     | Ok "Alice" -> ()
     | _ -> failwith "valid name should succeed");

    (* Empty name *)
    (match validate_name "" with
     | Error EmptyName -> ()
     | _ -> failwith "empty name should fail");

    (* Long name *)
    (match validate_name (String.make 51 'x') with
     | Error NameTooLong -> ()
     | _ -> failwith "long name should fail")

  let test_email_validation () =
    let open BusinessLogic in

    (* Valid email *)
    (match validate_email "user@example.com" with
     | Ok _ -> ()
     | _ -> failwith "valid email should succeed");

    (* Invalid email (no @) *)
    (match validate_email "notanemail" with
     | Error InvalidEmail -> ()
     | _ -> failwith "email without @ should fail");

    (* Invalid email (no .) *)
    (match validate_email "user@domain" with
     | Error InvalidEmail -> ()
     | _ -> failwith "email without . should fail")

  let test_discount_calculation () =
    let open BusinessLogic in

    (* Premium discount *)
    let discounted = calculate_discount 100.0 true in
    if discounted = 80.0 then ()
    else failwith (Printf.sprintf "expected 80.0, got %.2f" discounted);

    (* Regular price *)
    let regular = calculate_discount 100.0 false in
    if regular = 100.0 then ()
    else failwith (Printf.sprintf "expected 100.0, got %.2f" regular)

  let test_args_parsing () =
    (* Test expect_1 *)
    (match Bot.Args.expect_1 ["hello"] with
     | Some "hello" -> ()
     | _ -> failwith "expect_1 should work with 1 arg");

    (match Bot.Args.expect_1 ["a"; "b"] with
     | None -> ()
     | _ -> failwith "expect_1 should fail with 2 args");

    (* Test parse_int *)
    (match Bot.Args.parse_int "42" with
     | Some 42 -> ()
     | _ -> failwith "parse_int should parse 42");

    (match Bot.Args.parse_int "not-a-number" with
     | None -> ()
     | _ -> failwith "parse_int should fail on invalid input");

    (* Test join_rest *)
    let joined = Bot.Args.join_rest ["hello"; "world"; "test"] 0 in
    if joined = "hello world test" then ()
    else failwith "join_rest should join with spaces"

  let run_all_tests () =
    [
      run_test "name_validation" test_name_validation;
      run_test "email_validation" test_email_validation;
      run_test "discount_calculation" test_discount_calculation;
      run_test "args_parsing" test_args_parsing;
    ]

  let format_results results =
    let passed_count = List.filter (fun r -> r.passed) results |> List.length in
    let total_count = List.length results in

    let result_lines = List.map (fun r ->
      Printf.sprintf "%s %s" r.message r.name
    ) results |> String.concat "\n" in

    Printf.sprintf
      "🧪 <b>Self-Test Results</b>\n\n\
       %s\n\n\
       <b>Summary:</b> %d/%d tests passed\n\n\
       These are unit tests for pure business logic.\n\
       All validation and calculation functions are testable without I/O."
      result_lines passed_count total_count
end

let () =
  Printexc.record_backtrace true;
  Flo.info "=== Testing Patterns Demo Starting ===";

  let token = match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None -> Printf.eprintf "TELEGRAM_BOT_TOKEN not set\n"; exit 1
  in

  Eio_main.run @@ fun env ->
  let client = Client.create ~env ~token () in

  Flo.info "🤖 Testing Patterns Demo Bot Started";

  let session_store = Session.Memory_store.create () in

  Bot.make ~env ~client
  |> Bot.with_sessions (module Session.Memory_store) session_store

  (* /start - Main menu *)
  |> Bot.command "start" ~desc:"Show main menu" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/start] Showing main menu";

      let text =
        "🧪 <b>Testing Patterns Demo</b>\n\n\
         This demonstrates testable bot design:\n\n\
         <b>Self-Test Commands:</b>\n\
         /self_test - Run all tests\n\
         /test_validation - Test validators\n\
         /test_args - Test arg parsing\n\
         /test_calculation - Test calculations\n\n\
         <b>Testable Handlers:</b>\n\
         /register <name> <email>\n\
         /calculate <price> <premium/regular>\n\
         /validate_email <email>\n\
         /validate_name <name>\n\n\
         Pure business logic is separated from I/O for easy testing."
      in

      match reply ctx text with
      | Ok _ -> Flo.debug "[/start] ✓"; Ok ()
      | Error e -> Flo.debugf "[/start] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /self_test - Run all self-tests *)
  |> Bot.command "self_test" ~desc:"Run all self-tests" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/self_test] Running all tests";

      let results = SelfTest.run_all_tests () in
      let summary = SelfTest.format_results results in

      match reply ctx summary with
      | Ok _ -> Flo.debug "[/self_test] ✓"; Ok ()
      | Error e -> Flo.debugf "[/self_test] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /test_validation - Test validation functions *)
  |> Bot.command "test_validation" ~desc:"Test validators" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/test_validation] Testing validators";

      let result = SelfTest.run_test "name_validation" SelfTest.test_name_validation in
      let result2 = SelfTest.run_test "email_validation" SelfTest.test_email_validation in

      let summary = SelfTest.format_results [result; result2] in

      match reply ctx summary with
      | Ok _ -> Flo.debug "[/test_validation] ✓"; Ok ()
      | Error e -> Flo.debugf "[/test_validation] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /test_args - Test Args module *)
  |> Bot.command "test_args" ~desc:"Test argument parsing" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/test_args] Testing Args module";

      let result = SelfTest.run_test "args_parsing" SelfTest.test_args_parsing in
      let summary = SelfTest.format_results [result] in

      match reply ctx summary with
      | Ok _ -> Flo.debug "[/test_args] ✓"; Ok ()
      | Error e -> Flo.debugf "[/test_args] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /test_calculation - Test business calculations *)
  |> Bot.command "test_calculation" ~desc:"Test calculations" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/test_calculation] Testing calculations";

      let result = SelfTest.run_test "discount_calculation" SelfTest.test_discount_calculation in
      let summary = SelfTest.format_results [result] in

      match reply ctx summary with
      | Ok _ -> Flo.debug "[/test_calculation] ✓"; Ok ()
      | Error e -> Flo.debugf "[/test_calculation] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /register - Testable registration handler *)
  |> Bot.command "register" ~desc:"Register with name and email" (fun ctx args ->
      let open Bot.Ctx in
      Flo.debugf "[/register] Registration request with %d args" (List.length args);

      match Bot.Args.expect_2 args with
      | None ->
          Flo.debug "[/register] Invalid arg count";
          (match reply ctx
            "Usage: /register <name> <email>\n\n\
             Example: /register Alice alice@example.com"
           with
           | Ok _ -> Ok ()
           | Error e -> Flo.debugf "[/register] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ())

      | Some (name, email) ->
          Flo.debugf "[/register] Validating: name=%s, email=%s" name email;

          (* Use pure validation functions *)
          (match BusinessLogic.validate_name name with
           | Error err ->
               let msg = BusinessLogic.error_to_message err in
               (match reply ctx msg with
                | Ok _ -> Ok ()
                | Error e -> Flo.debugf "[/register] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ())

           | Ok valid_name ->
               (match BusinessLogic.validate_email email with
                | Error err ->
                    let msg = BusinessLogic.error_to_message err in
                    (match reply ctx msg with
                     | Ok _ -> Ok ()
                     | Error e -> Flo.debugf "[/register] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ())

                | Ok valid_email ->
                    Flo.debug "[/register] Validation passed";

                    let greeting = BusinessLogic.format_greeting valid_name in
                    let response = Printf.sprintf
                      "%s\n\n\
                       Email: %s\n\n\
                       Registration successful!\n\
                       (This is a demo - data not actually saved)"
                      greeting valid_email
                    in

                    (match reply ctx response with
                     | Ok _ -> Flo.debug "[/register] ✓"; Ok ()
                     | Error e -> Flo.debugf "[/register] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ())))
    )

  (* /calculate - Testable calculation handler *)
  |> Bot.command "calculate" ~desc:"Calculate discounted price" (fun ctx args ->
      let open Bot.Ctx in
      Flo.debug "[/calculate] Calculation request";

      match Bot.Args.expect_2 args with
      | None ->
          (match reply ctx
            "Usage: /calculate <price> <premium/regular>\n\n\
             Example: /calculate 100 premium"
           with
           | Ok _ -> Ok ()
           | Error e -> Flo.debugf "[/calculate] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ())

      | Some (price_str, premium_str) ->
          (* Use pure parsing and calculation functions *)
          (match BusinessLogic.parse_price price_str with
           | Error err ->
               let msg = BusinessLogic.error_to_message err in
               (match reply ctx msg with
                | Ok _ -> Ok ()
                | Error e -> Flo.debugf "[/calculate] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ())

           | Ok price ->
               (match BusinessLogic.parse_bool premium_str with
                | Error err ->
                    let msg = BusinessLogic.error_to_message err in
                    (match reply ctx msg with
                     | Ok _ -> Ok ()
                     | Error e -> Flo.debugf "[/calculate] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ())

                | Ok is_premium ->
                    let final_price = BusinessLogic.calculate_discount price is_premium in

                    let response = Printf.sprintf
                      "💰 <b>Price Calculation</b>\n\n\
                       Original: $%.2f\n\
                       Premium: %s\n\
                       Discount: %s\n\
                       Final: $%.2f\n\n\
                       This uses pure, testable business logic."
                      price
                      (if is_premium then "Yes" else "No")
                      (if is_premium then "20%" else "0%")
                      final_price
                    in

                    (match reply ctx response with
                     | Ok _ -> Flo.debug "[/calculate] ✓"; Ok ()
                     | Error e -> Flo.debugf "[/calculate] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ())))
    )

  (* /validate_email - Test email validation *)
  |> Bot.command "validate_email" ~desc:"Validate an email address" (fun ctx args ->
      let open Bot.Ctx in
      Flo.debug "[/validate_email] Validating email";

      match Bot.Args.expect_1 args with
      | None ->
          (match reply ctx "Usage: /validate_email <email>" with
           | Ok _ -> Ok ()
           | Error e -> Flo.debugf "[/validate_email] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ())

      | Some email ->
          let result = BusinessLogic.validate_email email in
          let response = match result with
            | Ok valid_email ->
                Printf.sprintf "✅ Valid email: %s" valid_email
            | Error err ->
                BusinessLogic.error_to_message err
          in

          (match reply ctx response with
           | Ok _ -> Flo.debug "[/validate_email] ✓"; Ok ()
           | Error e -> Flo.debugf "[/validate_email] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ())
    )

  (* /validate_name - Test name validation *)
  |> Bot.command "validate_name" ~desc:"Validate a name" (fun ctx args ->
      let open Bot.Ctx in
      Flo.debug "[/validate_name] Validating name";

      match Bot.Args.expect_1 args with
      | None ->
          (match reply ctx "Usage: /validate_name <name>" with
           | Ok _ -> Ok ()
           | Error e -> Flo.debugf "[/validate_name] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ())

      | Some name ->
          let result = BusinessLogic.validate_name name in
          let response = match result with
            | Ok valid_name ->
                Printf.sprintf "✅ Valid name: %s (length: %d)" valid_name (String.length valid_name)
            | Error err ->
                BusinessLogic.error_to_message err
          in

          (match reply ctx response with
           | Ok _ -> Flo.debug "[/validate_name] ✓"; Ok ()
           | Error e -> Flo.debugf "[/validate_name] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ())
    )

  |> Bot.run
