(** Migration Guide Demo - Migration patterns and before/after examples

    This example demonstrates migration patterns to ocaml_telegram_eio:
    - Migration from Lwt/Async to Eio
    - Migration from raw Telegram API to typed methods
    - Migration from callback-based to direct-style
    - Key differences and design decisions
    - Code comparison examples

    Commands:
      /start - Show main menu
      /lwt_to_eio - Lwt to Eio migration guide
      /raw_to_typed - Raw API to typed methods
      /sync_to_async - Sync to async migration
      /bot_dsl - Bot DSL migration
      /concurrency - Concurrency patterns comparison
      /error_handling - Error handling migration
      /id_types - ID type migration
      /key_differences - Key design differences

    This example demonstrates MIGRATION PATTERNS with verbose logging.

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/migration_guide_demo.exe
*)

open Telegram
open Tg

(* Configure verbose logging with flo *)
let () = Flo.set_level Severity.Debug

module KB = Keyboard

(** Migration guide templates *)
module Templates = struct
  let lwt_to_eio =
    "🔄 <b>Lwt to Eio Migration</b>\n\n\
     <b>Sequential operations:</b>\n\
     <code>\n\
     (* Lwt *)\n\
     let%lwt r1 = fetch1 () in\n\
     let%lwt r2 = fetch2 () in\n\
     Lwt.return (r1 + r2)\n\n\
     (* Eio - direct style *)\n\
     let r1 = fetch1 () in\n\
     let r2 = fetch2 () in\n\
     r1 + r2\n\
     </code>\n\n\
     <b>Parallel operations:</b>\n\
     <code>\n\
     (* Lwt *)\n\
     let%lwt r1, r2 = Lwt.both\n\
       (fetch1 ()) (fetch2 ()) in\n\
     Lwt.return (r1 + r2)\n\n\
     (* Eio *)\n\
     Eio.Fiber.both\n\
       (fun () -&gt; fetch1 ())\n\
       (fun () -&gt; fetch2 ())\n\
     |&gt; fun (r1, r2) -&gt; r1 + r2\n\
     </code>\n\n\
     <b>Key changes:</b>\n\
     • No monadic bind needed\n\
     • Direct-style code (looks sync)\n\
     • Structured concurrency\n\
     • Better error traces"

  let raw_to_typed =
    "📝 <b>Raw API to Typed Methods</b>\n\n\
     <b>Before (raw HTTP/JSON):</b>\n\
     <code>\n\
     let json = `Assoc [\n\
       (\"chat_id\", `Int 123);\n\
       (\"text\", `String \"Hello\");\n\
     ] in\n\
     post \"https://api.telegram.org/bot{token}/sendMessage\" json\n\
     </code>\n\n\
     <b>After (typed methods):</b>\n\
     <code>\n\
     Gen_methods.send_message\n\
       client\n\
       ~chat_id\n\
       ~text:\"Hello\"\n\
       ()\n\
     </code>\n\n\
     <b>Advantages:</b>\n\
     • Type safety\n\
     • Autocomplete\n\
     • No manual JSON\n\
     • Compile-time errors\n\
     • Generated from spec"

  let id_types_guide =
    "🔑 <b>ID Type Migration</b>\n\n\
     <b>Before (raw int64):</b>\n\
     <code>\n\
     let chat_id = 123456789L\n\
     let user_id = 987654321L\n\
     (* Easy to mix up! *)\n\
     send_message ~chat_id:user_id (* BUG! *)\n\
     </code>\n\n\
     <b>After (phantom types):</b>\n\
     <code>\n\
     let chat_id = Id.Chat.of_int 123456789L\n\
     let user_id = Id.User.of_int 987654321L\n\
     (* Type error if mixed! *)\n\
     send_message ~chat_id:user_id\n\
     (* ^ Compile error! *)\n\
     </code>\n\n\
     <b>Also supports:</b>\n\
     • Usernames: Id.Chat.of_string \"@channel\"\n\
     • String IDs: Id.Chat.of_string \"123\"\n\
     • Type-safe conversions"

  let error_handling_migration =
    "❌ <b>Error Handling Migration</b>\n\n\
     <b>Before (exceptions):</b>\n\
     <code>\n\
     try\n\
       send_message ~chat_id ~text\n\
     with\n\
     | Api_error msg -&gt; handle_error msg\n\
     | exn -&gt; failwith \"Unknown error\"\n\
     </code>\n\n\
     <b>After (Result types):</b>\n\
     <code>\n\
     match send_message client ~chat_id ~text () with\n\
     | Ok msg -&gt; (* Success *)\n\
     | Error err -&gt;\n\
         match err with\n\
         | Api_error { code; description; _ } -&gt;\n\
             handle_error code description\n\
         | Timeout -&gt; retry ()\n\
         | _ -&gt; log_error err\n\
     </code>\n\n\
     <b>Advantages:</b>\n\
     • Explicit in types\n\
     • No hidden control flow\n\
     • Compiler ensures handling\n\
     • Better composition"

  let concurrency_patterns =
    "⚡ <b>Concurrency Patterns</b>\n\n\
     <b>Spawning tasks:</b>\n\
     <code>\n\
     (* Lwt *)\n\
     Lwt.async (fun () -&gt; background_task ())\n\n\
     (* Eio *)\n\
     Eio.Switch.run @@ fun sw -&gt;\n\
       Eio.Fiber.fork ~sw background_task\n\
     </code>\n\n\
     <b>Timeouts:</b>\n\
     <code>\n\
     (* Lwt *)\n\
     Lwt.pick [task (); Lwt_unix.sleep 5.0]\n\n\
     (* Eio *)\n\
     Eio.Time.with_timeout clock 5.0 task\n\
     </code>\n\n\
     <b>Synchronization:</b>\n\
     <code>\n\
     (* Lwt *)\n\
     Lwt_mvar, Lwt_mutex\n\n\
     (* Eio *)\n\
     Eio.Mutex, Eio.Semaphore,\n\
     Eio.Condition, Promise\n\
     </code>\n\n\
     <b>Key: Structured concurrency!</b>"

  let bot_dsl_migration =
    "🤖 <b>Bot DSL Migration</b>\n\n\
     <b>Before (manual routing):</b>\n\
     <code>\n\
     let handle_update u =\n\
       match u.message with\n\
       | Some m -&gt;\n\
           match m.text with\n\
           | Some t when starts_with t \"/start\" -&gt;\n\
               send_message ~chat_id ~text:\"Hi\"\n\
           | Some t when starts_with t \"/help\" -&gt;\n\
               send_message ~chat_id ~text:\"Help\"\n\
           | _ -&gt; ()\n\
       | None -&gt; ()\n\
     </code>\n\n\
     <b>After (Bot DSL):</b>\n\
     <code>\n\
     Bot.make ~env ~client\n\
     |&gt; Bot.command \"start\" handler_start\n\
     |&gt; Bot.command \"help\" handler_help\n\
     |&gt; Bot.run\n\
     </code>\n\n\
     <b>Advantages:</b>\n\
     • Declarative routing\n\
     • No manual parsing\n\
     • Type-safe handlers\n\
     • Composable middleware"

  let key_differences =
    "🔑 <b>Key Design Differences</b>\n\n\
     <b>1. Direct-style code:</b>\n\
     • No let%lwt or &gt;&gt;= needed\n\
     • Code looks synchronous\n\
     • Easier to read and debug\n\n\
     <b>2. Structured concurrency:</b>\n\
     • Switches manage fiber lifetimes\n\
     • Automatic cleanup\n\
     • Cancellation propagates\n\n\
     <b>3. Result types:</b>\n\
     • Explicit error handling\n\
     • No hidden exceptions\n\
     • Better composition\n\n\
     <b>4. Phantom types:</b>\n\
     • Chat.k Id.t vs User.k Id.t\n\
     • Prevent ID mixups\n\
     • Type-safe API\n\n\
     <b>5. Bot DSL:</b>\n\
     • Declarative routing\n\
     • Middleware support\n\
     • Builder pattern"
end

let () =
  Printexc.record_backtrace true;
  Flo.info "=== Migration Guide Demo Starting ===";

  let token = match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None -> Printf.eprintf "TELEGRAM_BOT_TOKEN not set\n"; exit 1
  in

  Eio_main.run @@ fun env ->
  let client = Client.create ~env ~token () in

  Flo.info "🤖 Migration Guide Demo Started";

  let session_store = Session.Memory_store.create () in

  Bot.make ~env ~client
  |> Bot.with_sessions (module Session.Memory_store) session_store

  (* /start - Main menu *)
  |> Bot.command "start" ~desc:"Show main menu" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/start] Showing main menu";

      let keyboard = KB.inline [
        [KB.callback ~text:"🔄 Lwt to Eio" ~data:"guide:lwt_eio"];
        [KB.callback ~text:"📝 Raw to Typed" ~data:"guide:raw_typed"];
        [KB.callback ~text:"🔑 ID Types" ~data:"guide:id_types"];
        [KB.callback ~text:"❌ Error Handling" ~data:"guide:errors"];
        [KB.callback ~text:"⚡ Concurrency" ~data:"guide:concurrency"];
        [KB.callback ~text:"🤖 Bot DSL" ~data:"guide:bot_dsl"];
        [KB.callback ~text:"🔑 Key Differences" ~data:"guide:differences"];
      ] in

      let text =
        "📚 <b>Migration Guide</b>\n\n\
         Learn how to migrate to ocaml_telegram_eio:\n\n\
         🔄 Lwt/Async to Eio\n\
         📝 Raw API to typed methods\n\
         🔑 ID type safety\n\
         ❌ Error handling patterns\n\
         ⚡ Concurrency migration\n\
         🤖 Bot DSL usage\n\n\
         Choose a topic to explore:"
      in

      match send ~keyboard ctx text with
      | Ok _ -> Flo.debug "[/start] ✓"; Ok ()
      | Error e -> Flo.debugf "[/start] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /lwt_to_eio - Lwt to Eio guide *)
  |> Bot.command "lwt_to_eio" ~desc:"Lwt to Eio migration" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/lwt_to_eio] Showing Lwt to Eio guide";

      match reply ctx Templates.lwt_to_eio with
      | Ok _ -> Flo.debug "[/lwt_to_eio] ✓"; Ok ()
      | Error e -> Flo.debugf "[/lwt_to_eio] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /raw_to_typed - Raw to typed guide *)
  |> Bot.command "raw_to_typed" ~desc:"Raw API to typed methods" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/raw_to_typed] Showing raw to typed guide";

      match reply ctx Templates.raw_to_typed with
      | Ok _ -> Flo.debug "[/raw_to_typed] ✓"; Ok ()
      | Error e -> Flo.debugf "[/raw_to_typed] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /id_types - ID types guide *)
  |> Bot.command "id_types" ~desc:"ID type safety migration" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/id_types] Showing ID types guide";

      match reply ctx Templates.id_types_guide with
      | Ok _ -> Flo.debug "[/id_types] ✓"; Ok ()
      | Error e -> Flo.debugf "[/id_types] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /error_handling - Error handling guide *)
  |> Bot.command "error_handling" ~desc:"Error handling migration" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/error_handling] Showing error handling guide";

      match reply ctx Templates.error_handling_migration with
      | Ok _ -> Flo.debug "[/error_handling] ✓"; Ok ()
      | Error e -> Flo.debugf "[/error_handling] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /concurrency - Concurrency patterns *)
  |> Bot.command "concurrency" ~desc:"Concurrency migration" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/concurrency] Showing concurrency patterns";

      match reply ctx Templates.concurrency_patterns with
      | Ok _ -> Flo.debug "[/concurrency] ✓"; Ok ()
      | Error e -> Flo.debugf "[/concurrency] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /bot_dsl - Bot DSL guide *)
  |> Bot.command "bot_dsl" ~desc:"Bot DSL migration" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/bot_dsl] Showing Bot DSL guide";

      match reply ctx Templates.bot_dsl_migration with
      | Ok _ -> Flo.debug "[/bot_dsl] ✓"; Ok ()
      | Error e -> Flo.debugf "[/bot_dsl] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /key_differences - Key differences *)
  |> Bot.command "key_differences" ~desc:"Key design differences" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/key_differences] Showing key differences";

      match reply ctx Templates.key_differences with
      | Ok _ -> Flo.debug "[/key_differences] ✓"; Ok ()
      | Error e -> Flo.debugf "[/key_differences] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* Callback handlers for guides *)
  |> Bot.on_callback_data "guide:lwt_eio" (fun ctx ->
      let open Bot.Ctx in
      match edit ctx Templates.lwt_to_eio with
      | Ok () -> Ok ()
      | Error e -> Flo.debugf "[guide:lwt_eio] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  |> Bot.on_callback_data "guide:raw_typed" (fun ctx ->
      let open Bot.Ctx in
      match edit ctx Templates.raw_to_typed with
      | Ok () -> Ok ()
      | Error e -> Flo.debugf "[guide:raw_typed] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  |> Bot.on_callback_data "guide:id_types" (fun ctx ->
      let open Bot.Ctx in
      match edit ctx Templates.id_types_guide with
      | Ok () -> Ok ()
      | Error e -> Flo.debugf "[guide:id_types] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  |> Bot.on_callback_data "guide:errors" (fun ctx ->
      let open Bot.Ctx in
      match edit ctx Templates.error_handling_migration with
      | Ok () -> Ok ()
      | Error e -> Flo.debugf "[guide:errors] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  |> Bot.on_callback_data "guide:concurrency" (fun ctx ->
      let open Bot.Ctx in
      match edit ctx Templates.concurrency_patterns with
      | Ok () -> Ok ()
      | Error e -> Flo.debugf "[guide:concurrency] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  |> Bot.on_callback_data "guide:bot_dsl" (fun ctx ->
      let open Bot.Ctx in
      match edit ctx Templates.bot_dsl_migration with
      | Ok () -> Ok ()
      | Error e -> Flo.debugf "[guide:bot_dsl] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  |> Bot.on_callback_data "guide:differences" (fun ctx ->
      let open Bot.Ctx in
      match edit ctx Templates.key_differences with
      | Ok () -> Ok ()
      | Error e -> Flo.debugf "[guide:differences] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  |> Bot.run
