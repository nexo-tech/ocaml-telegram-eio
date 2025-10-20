(** Error Handling Demo - Comprehensive demonstration of error handling patterns

    This example demonstrates all error handling strategies:
    - Result type patterns with match and monadic bind
    - Error classification (retryable vs non-retryable)
    - User-friendly error messages
    - Graceful degradation and fallbacks
    - Global error handlers (on_error)
    - Error recovery patterns
    - Error logging and reporting

    Commands:
      /start - Show available features
      /send_ok - Successful message (no error)
      /send_invalid - Trigger API error (invalid chat_id)
      /send_with_fallback - Demonstrate fallback pattern
      /trigger_error - Throw exception to test error handler
      /error_types - Explain error types
      /monadic - Demonstrate monadic error propagation

    This example has VERBOSE LOGGING enabled for troubleshooting.

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/error_handling_demo.exe
*)

open Telegram
open Tg

(* Configure verbose logging with flo *)
let () = Flo.set_level Severity.Debug

(** Error message formatting for users *)
module ErrorMessages = struct
  let contains s sub =
    try ignore (Str.search_forward (Str.regexp_string sub) s 0); true
    with Not_found -> false

  let from_error err =
    match err with
    | Error.Api_error { code = 403; description; _ } ->
        if contains description "blocked" then
          "❌ I cannot send you messages. Please unblock me and try /start again."
        else if contains description "bot was kicked" then
          "❌ I was removed from this chat."
        else
          "❌ I don't have permission to perform this action."

    | Error.Api_error { code = 400; description; _ } ->
        if contains description "message is not modified" then
          "ℹ️ This message is already up to date."
        else if contains description "message to edit not found" then
          "❌ The message to edit was not found (may have been deleted)."
        else if contains description "chat not found" then
          "❌ Chat not found."
        else
          Printf.sprintf "❌ Invalid request: %s" description

    | Error.Api_error { code = 429; parameters = Some { retry_after = Some sec; _ }; _ } ->
        Printf.sprintf "⏳ Too many requests. Please try again in %d seconds." sec

    | Error.Timeout ->
        "⏱️ Request timed out. Please try again."

    | Error.Http_error (code, _msg) when code >= 500 ->
        Printf.sprintf "🔧 Telegram servers are temporarily unavailable (HTTP %d). Please try again later." code

    | Error.Http_error (code, msg) ->
        Printf.sprintf "🌐 Network error (HTTP %d): %s" code msg

    | Error.Decode_error msg ->
        Printf.sprintf "⚠️ Response parsing error: %s" msg

    | Error.Internal_error msg ->
        Printf.sprintf "🐛 Internal error: %s" msg

    | _ ->
        "❌ Sorry, an unexpected error occurred. Please try again."

  let is_retryable = Error.is_retryable
end

let () =
  Printexc.record_backtrace true;
  Flo.info "=== Error Handling Demo Starting ===";

  let token = match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None -> Printf.eprintf "TELEGRAM_BOT_TOKEN not set\n"; exit 1
  in

  Eio_main.run @@ fun env ->
  let client = Client.create ~env ~token () in

  Flo.info "🤖 Error Handling Demo Bot Started";

  let session_store = Session.Memory_store.create () in

  Bot.make ~env ~client
  |> Bot.with_sessions (module Session.Memory_store) session_store

  (* Global error handler - catches all uncaught exceptions *)
  |> Bot.on_error (fun ctx exn ->
      let open Bot.Ctx in
      Flo.debugf "[on_error] Caught exception: %s" (Printexc.to_string exn);
      Flo.debugf "[on_error] Backtrace: %s" (Printexc.get_backtrace ());

      (* Try to notify user *)
      match reply ctx "❌ An unexpected error occurred. The error has been logged." with
      | Ok _ -> Flo.debug "[on_error] User notified ✓"
      | Error e -> Flo.debugf "[on_error] Failed to notify user: %s" (Format.asprintf "%a" Error.pp e)
    )

  (* /start - Show available features *)
  |> Bot.command "start" ~desc:"Show available features" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/start] Showing main menu";

      let text =
        "🛡️ Error Handling Demo\n\n\
         This bot demonstrates error handling patterns.\n\n\
         📝 Commands:\n\
         /send_ok - Successful operation\n\
         /send_invalid - API error (invalid chat_id)\n\
         /send_with_fallback - Fallback pattern\n\
         /trigger_error - Test exception handler\n\
         /error_types - Learn about error types\n\
         /monadic - Monadic error propagation"
      in

      match reply ctx text with
      | Ok _ -> Flo.debug "[/start] ✓"; Ok ()
      | Error e ->
          Flo.debugf "[/start] ✗ Error: %s" (Format.asprintf "%a" Error.pp e);
          Ok ()
    )

  (* /send_ok - Successful operation *)
  |> Bot.command "send_ok" ~desc:"Successful message send" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/send_ok] Sending successful message";

      (* This will succeed *)
      match reply ctx "✅ Success! This message was sent without errors." with
      | Ok _ ->
          Flo.debug "[/send_ok] ✓ Success";
          Ok ()
      | Error e ->
          Flo.debugf "[/send_ok] ✗ Unexpected error: %s" (Format.asprintf "%a" Error.pp e);
          Ok ()
    )

  (* /send_invalid - Trigger API error *)
  |> Bot.command "send_invalid" ~desc:"Trigger API error" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/send_invalid] Attempting to send to invalid chat";

      (* Try to send to invalid chat_id (will fail) *)
      let invalid_chat_id = Id.Chat.of_int 0L in

      match Telegram_generated.Gen_methods.send_message
        (client ctx)
        ~chat_id:invalid_chat_id
        ~text:"This will fail"
        () with
      | Ok _ ->
          Flo.debug "[/send_invalid] Unexpected success!";
          (match reply ctx "Unexpected: message sent to invalid chat!" with
           | Ok _ -> Ok ()
           | Error e -> Flo.debugf "[/send_invalid] Reply error: %s" (Format.asprintf "%a" Error.pp e); Ok ())
      | Error e ->
          Flo.debugf "[/send_invalid] Expected error: %s" (Format.asprintf "%a" Error.pp e);

          (* Convert to user-friendly message *)
          let user_msg = ErrorMessages.from_error e in
          Flo.debugf "[/send_invalid] User message: %s" user_msg;

          let technical_details = Format.asprintf "%a" Error.pp e in
          let response = Printf.sprintf "Caught API error:\n\n%s\n\nTechnical details: %s" user_msg technical_details in

          (match reply ctx response with
           | Ok _ -> Flo.debug "[/send_invalid] ✓"; Ok ()
           | Error e2 -> Flo.debugf "[/send_invalid] Reply error: %s" (Format.asprintf "%a" Error.pp e2); Ok ())
    )

  (* /send_with_fallback - Demonstrate fallback pattern *)
  |> Bot.command "send_with_fallback" ~desc:"Fallback error handling" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/send_with_fallback] Demonstrating fallback pattern";

      (* Try primary method *)
      let result = reply ctx "⏳ Attempting to send..." in

      match result with
      | Ok _ ->
          Flo.debug "[/send_with_fallback] Primary method succeeded ✓";
          Ok ()
      | Error e1 ->
          Flo.debugf "[/send_with_fallback] Primary failed: %s" (Format.asprintf "%a" Error.pp e1);

          (* Fallback: Try alternative method *)
          let fallback_text = Printf.sprintf
            "⚠️ Primary method failed.\n\n\
             Error: %s\n\n\
             Using fallback method..."
            (ErrorMessages.from_error e1)
          in

          (match reply ctx fallback_text with
           | Ok _ ->
               Flo.debug "[/send_with_fallback] Fallback succeeded ✓";
               Ok ()
           | Error e2 ->
               Flo.debugf "[/send_with_fallback] Fallback also failed: %s" (Format.asprintf "%a" Error.pp e2);
               Ok ())
    )

  (* /trigger_error - Test global error handler *)
  |> Bot.command "trigger_error" ~desc:"Test exception handler" (fun _ctx _args ->
      Flo.debug "[/trigger_error] Throwing exception to test error handler";

      (* This will trigger the global on_error handler *)
      failwith "This is a test exception to demonstrate the global error handler!"
    )

  (* /error_types - Explain error types *)
  |> Bot.command "error_types" ~desc:"Explain Telegram error types" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/error_types] Explaining error types";

      let text =
        "📋 Telegram Error Types\n\n\
         <b>API Errors (Error.Api_error):</b>\n\
         • 400 Bad Request - Invalid parameters\n\
         • 401 Unauthorized - Invalid token\n\
         • 403 Forbidden - Bot blocked or kicked\n\
         • 404 Not Found - Chat/message doesn't exist\n\
         • 429 Too Many Requests - Rate limited\n\n\
         <b>Network Errors:</b>\n\
         • Timeout - Request timed out\n\
         • Network_error - Connection failed\n\
         • Http_error 5xx - Server errors\n\n\
         <b>Library Errors:</b>\n\
         • Decode_error - JSON parsing failed\n\
         • Not_implemented - Feature not supported\n\n\
         <b>Retryable:</b> Network errors, 5xx, 429\n\
         <b>Non-retryable:</b> 400, 401, 403, 404"
      in

      match reply ctx text with
      | Ok _ -> Flo.debug "[/error_types] ✓"; Ok ()
      | Error e -> Flo.debugf "[/error_types] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /monadic - Demonstrate monadic error propagation *)
  |> Bot.command "monadic" ~desc:"Monadic error handling" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/monadic] Demonstrating monadic error propagation";

      (* Chain multiple operations - error stops propagation *)
      let operation () =
        (* Step 1: Send initial message *)
        match reply ctx "Step 1: Initial message ✓" with
        | Error e -> Error e
        | Ok _msg1 ->
            Flo.debug "[/monadic] Step 1 complete";

            (* Step 2: Send second message *)
            match reply ctx "Step 2: Second message ✓" with
            | Error e -> Error e
            | Ok _msg2 ->
                Flo.debug "[/monadic] Step 2 complete";

                (* Step 3: Send final message *)
                match reply ctx
                  "Step 3: Final message ✓\n\n\
                   All three operations succeeded!\n\
                   If any had failed, the chain would have stopped." with
                | Error e -> Error e
                | Ok _msg3 ->
                    Flo.debug "[/monadic] Step 3 complete";
                    Ok ()
      in

      match operation () with
      | Ok () ->
          Flo.debug "[/monadic] All steps succeeded ✓";
          Ok ()
      | Error e ->
          Flo.debugf "[/monadic] Chain stopped at error: %s" (Format.asprintf "%a" Error.pp e);

          let user_msg = ErrorMessages.from_error e in
          (match reply ctx (Printf.sprintf "❌ Operation failed:\n\n%s" user_msg) with
           | Ok _ -> Ok ()
           | Error e2 -> Flo.debugf "[/monadic] Error reply failed: %s" (Format.asprintf "%a" Error.pp e2); Ok ())
    )

  (* /recover - Demonstrate error recovery *)
  |> Bot.command "recover" ~desc:"Error recovery pattern" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/recover] Demonstrating error recovery";

      (* Simulate operation that might fail *)
      let attempt_risky_operation () =
        (* For demo: randomly succeed or fail *)
        if Random.bool () then
          Ok "Operation succeeded!"
        else
          Error (Error.Api_error {
            code = 500;
            description = "Simulated server error";
            parameters = None;
          })
      in

      (* Try with recovery *)
      let rec try_with_recovery attempts_left =
        match attempt_risky_operation () with
        | Ok result ->
            Flo.debugf "[/recover] Success: %s" result;
            reply ctx (Printf.sprintf "✅ %s" result)

        | Error e when ErrorMessages.is_retryable e && attempts_left > 0 ->
            Flo.debugf "[/recover] Retryable error, %d attempts left" attempts_left;
            Eio.Time.sleep (env ctx)#clock 1.0;
            try_with_recovery (attempts_left - 1)

        | Error e ->
            Flo.debugf "[/recover] Non-retryable or max attempts reached: %s" (Format.asprintf "%a" Error.pp e);
            let user_msg = ErrorMessages.from_error e in
            reply ctx (Printf.sprintf "❌ Operation failed after retries:\n\n%s" user_msg)
      in

      match try_with_recovery 3 with
      | Ok _ -> Flo.debug "[/recover] ✓"; Ok ()
      | Error e -> Flo.debugf "[/recover] Final error: %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /partial - Demonstrate partial success handling *)
  |> Bot.command "partial" ~desc:"Partial success pattern" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/partial] Demonstrating partial success";

      (* Simulate multiple operations *)
      let operations = [
        ("Operation 1", Ok "Success");
        ("Operation 2", Error (Error.Api_error { code = 400; description = "Simulated error"; parameters = None }));
        ("Operation 3", Ok "Success");
        ("Operation 4", Error (Error.Timeout));
        ("Operation 5", Ok "Success");
      ] in

      let successes = List.filter_map (fun (name, result) ->
        match result with
        | Ok _ -> Some name
        | Error _ -> None
      ) operations in

      let failures = List.filter_map (fun (name, result) ->
        match result with
        | Error e -> Some (name, e)
        | Ok _ -> None
      ) operations in

      Flo.debugf "[/partial] Successes: %d, Failures: %d"
        (List.length successes) (List.length failures);

      let success_text = String.concat "\n" (List.map (fun n -> "  ✓ " ^ n) successes) in
      let failure_text = String.concat "\n" (List.map (fun (n, e) ->
        Printf.sprintf "  ✗ %s: %s" n (ErrorMessages.from_error e)
      ) failures) in

      let response = Printf.sprintf
        "📊 Partial Success Pattern\n\n\
         <b>Succeeded (%d):</b>\n%s\n\n\
         <b>Failed (%d):</b>\n%s\n\n\
         This demonstrates handling operations where some succeed and some fail."
        (List.length successes)
        success_text
        (List.length failures)
        failure_text
      in

      match reply ctx response with
      | Ok _ -> Flo.debug "[/partial] ✓"; Ok ()
      | Error e -> Flo.debugf "[/partial] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /help - Show all commands *)
  |> Bot.command "help" ~desc:"Show all commands" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/help] Showing help";

      let text =
        "📚 Error Handling Demo Commands\n\n\
         /start - Show main menu\n\
         /send_ok - Successful operation\n\
         /send_invalid - Trigger API error\n\
         /send_with_fallback - Fallback pattern\n\
         /trigger_error - Test exception handler\n\
         /error_types - Explain error types\n\
         /monadic - Monadic error propagation\n\
         /recover - Error recovery with retries\n\
         /partial - Partial success handling\n\
         /help - This message"
      in

      match reply ctx text with
      | Ok _ -> Flo.debug "[/help] ✓"; Ok ()
      | Error e -> Flo.debugf "[/help] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  |> Bot.run
