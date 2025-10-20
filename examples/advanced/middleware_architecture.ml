(** Middleware Architecture Demo - Comprehensive demonstration of middleware patterns

    This example demonstrates middleware architecture:
    - Custom middleware with before/after/error hooks
    - Middleware composition and layering
    - Authentication middleware
    - Rate limiting middleware
    - Logging middleware
    - Context enrichment middleware
    - Scoped middleware application

    Commands:
      /start - Show main menu (no middleware)
      /public - Public command (logging middleware only)
      /user - User command (requires user middleware)
      /admin - Admin command (admin middleware)
      /premium - Premium command (subscription check middleware)
      /logged - Command with before/after logging
      /enriched - Command with context enrichment
      /error_test - Test error middleware
      /middleware_info - Show middleware stack info

    Environment Variables:
      ADMIN_USER_IDS - Comma-separated admin user IDs
      PREMIUM_USER_IDS - Comma-separated premium user IDs

    This example has VERBOSE LOGGING enabled for troubleshooting.

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      export ADMIN_USER_IDS="your_user_id"
      export PREMIUM_USER_IDS="your_user_id"
      dune exec examples/middleware_architecture_demo.exe
*)

open Telegram
open Tg

(* Configure verbose logging with flo *)
let () = Flo.set_level Severity.Debug

module KB = Keyboard

(** Custom middleware implementations *)
module CustomMiddleware = struct
  open Bot

  (** Logging middleware - logs before and after handler *)
  let logging_mw name =
    Eio.traceln "[CustomMiddleware] Creating logging middleware: %s" name;
    Middleware.make
      ~before:(fun ctx ->
        Eio.traceln "[Middleware:%s] BEFORE hook - Handler starting" name;
        Ok ctx
      )
      ~after:(fun _ctx ->
        Eio.traceln "[Middleware:%s] AFTER hook - Handler completed successfully" name
      )
      ~on_error:(fun _ctx exn ->
        Eio.traceln "[Middleware:%s] ERROR hook - Handler failed: %s" name (Printexc.to_string exn)
      )
      name

  (** Admin check middleware *)
  let admin_only_mw admin_ids =
    Eio.traceln "[CustomMiddleware] Creating admin-only middleware (%d admins)" (List.length admin_ids);
    Middleware.make
      ~before:(fun ctx ->
        Eio.traceln "[Middleware:admin_only] Checking admin status";
        match Ctx.user ctx with
        | Some user ->
            let user_id_str = Id.to_string user.id in
            let is_admin = List.exists (fun admin_id ->
              Id.to_string admin_id = user_id_str
            ) admin_ids in

            if is_admin then (
              Eio.traceln "[Middleware:admin_only] ✓ Admin access granted to %s"
                (Option.value user.username ~default:"<unknown>");
              Ok ctx
            ) else (
              Eio.traceln "[Middleware:admin_only] ✗ Admin access denied to %s"
                (Option.value user.username ~default:"<unknown>");
              let _ = Ctx.reply ctx "❌ Admin access required." in
              Error "Not admin"
            )
        | None ->
            Eio.traceln "[Middleware:admin_only] ✗ No user in context";
            Error "No user"
      )
      "admin_only"

  (** Premium user check middleware *)
  let premium_only_mw premium_ids =
    Eio.traceln "[CustomMiddleware] Creating premium-only middleware (%d premium users)" (List.length premium_ids);
    Middleware.make
      ~before:(fun ctx ->
        Eio.traceln "[Middleware:premium_only] Checking premium status";
        match Ctx.user ctx with
        | Some user ->
            let user_id_str = Id.to_string user.id in
            let is_premium = List.exists (fun premium_id ->
              Id.to_string premium_id = user_id_str
            ) premium_ids in

            if is_premium then (
              Eio.traceln "[Middleware:premium_only] ✓ Premium access granted";
              Ok ctx
            ) else (
              Eio.traceln "[Middleware:premium_only] ✗ Premium access denied";
              let _ = Ctx.reply ctx "❌ Premium subscription required." in
              Error "Not premium"
            )
        | None ->
            Error "No user"
      )
      "premium_only"

  (** Context enrichment middleware - adds request timestamp *)
  let enrich_timestamp_mw =
    let timestamp_key = Session.make ~name:"request_timestamp" in
    Eio.traceln "[CustomMiddleware] Creating timestamp enrichment middleware";
    Middleware.make
      ~before:(fun ctx ->
        let timestamp = Unix.time () in
        Eio.traceln "[Middleware:enrich_timestamp] Adding timestamp: %.0f" timestamp;
        Ctx.session_set ctx timestamp_key timestamp;
        Ok ctx
      )
      ~after:(fun ctx ->
        match Ctx.session_get ctx timestamp_key with
        | Some start_time ->
            let duration = Unix.time () -. start_time in
            Eio.traceln "[Middleware:enrich_timestamp] Request duration: %.3fs" duration
        | None -> ()
      )
      "enrich_timestamp"

  (** Request counter middleware *)
  let request_counter_mw =
    let counter_key = Session.make ~name:"request_count" in
    Eio.traceln "[CustomMiddleware] Creating request counter middleware";
    Middleware.make
      ~before:(fun ctx ->
        let current = Ctx.session_get_or ctx counter_key ~default:0 in
        let new_count = current + 1 in
        Eio.traceln "[Middleware:request_counter] Request #%d for this user" new_count;
        Ctx.session_set ctx counter_key new_count;
        Ok ctx
      )
      "request_counter"
end

(** Authorization utilities *)
module Auth = struct
  let admin_user_ids () =
    match Sys.getenv_opt "ADMIN_USER_IDS" with
    | Some ids ->
        String.split_on_char ',' ids
        |> List.filter_map (fun s ->
            match Int64.of_string_opt (String.trim s) with
            | Some id -> Some (Id.User.of_int id)
            | None -> None)
    | None -> []

  let premium_user_ids () =
    match Sys.getenv_opt "PREMIUM_USER_IDS" with
    | Some ids ->
        String.split_on_char ',' ids
        |> List.filter_map (fun s ->
            match Int64.of_string_opt (String.trim s) with
            | Some id -> Some (Id.User.of_int id)
            | None -> None)
    | None -> []
end

let () =
  Printexc.record_backtrace true;
  Eio.traceln "=== Middleware Architecture Demo Starting ===";

  let token = match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None -> Printf.eprintf "TELEGRAM_BOT_TOKEN not set\n"; exit 1
  in

  Eio_main.run @@ fun env ->
  let client = Client.create ~env ~token () in

  Eio.traceln "🤖 Middleware Architecture Demo Bot Started";
  Eio.traceln "";
  Eio.traceln "=== Configuration ===";
  Eio.traceln "Admin users: %d configured" (List.length (Auth.admin_user_ids ()));
  Eio.traceln "Premium users: %d configured" (List.length (Auth.premium_user_ids ()));
  Eio.traceln "";

  let session_store = Session.Memory_store.create () in

  (* Create middleware instances *)
  let admin_mw = CustomMiddleware.admin_only_mw (Auth.admin_user_ids ()) in
  let premium_mw = CustomMiddleware.premium_only_mw (Auth.premium_user_ids ()) in
  let logging_mw = CustomMiddleware.logging_mw "global" in
  let enrich_mw = CustomMiddleware.enrich_timestamp_mw in
  let counter_mw = CustomMiddleware.request_counter_mw in

  Eio.traceln "=== Building Bot with Middleware ===";

  Bot.make ~env ~client
  |> Bot.with_sessions (module Session.Memory_store) session_store

  (* /start - No middleware *)
  |> Bot.command "start" ~desc:"Show main menu" (fun ctx _args ->
      let open Bot.Ctx in
      Eio.traceln "[Handler] /start (no middleware)";

      let text =
        "🛡️ <b>Middleware Architecture Demo</b>\n\n\
         This demonstrates middleware patterns:\n\n\
         <b>Commands by Middleware:</b>\n\
         /public - Logging middleware\n\
         /user - Require user middleware\n\
         /admin - Admin middleware\n\
         /premium - Premium middleware\n\
         /logged - Before/after logging\n\
         /enriched - Context enrichment\n\
         /error_test - Error middleware\n\
         /middleware_info - Middleware stack info\n\n\
         Check logs to see middleware execution!"
      in

      match reply ctx text with
      | Ok _ -> Eio.traceln "[Handler] /start ✓"; Ok ()
      | Error e -> Eio.traceln "[Handler] /start ✗ %a" Error.pp e; Ok ()
    )

  (* /public - Logging middleware only *)
  |> Bot.command "public" ~desc:"Public command with logging" (fun ctx _args ->
      let open Bot.Ctx in
      Eio.traceln "[Handler] /public executing";

      match reply ctx
        "✅ Public command executed!\n\n\
         This command has logging middleware.\n\
         Check logs to see before/after hooks."
      with
      | Ok _ -> Eio.traceln "[Handler] /public ✓"; Ok ()
      | Error e -> Eio.traceln "[Handler] /public ✗ %a" Error.pp e; Ok ()
    )
  |> Bot.use logging_mw

  (* /logged - Detailed logging *)
  |> Bot.command "logged" ~desc:"Command with detailed logging" (fun ctx _args ->
      let open Bot.Ctx in
      Eio.traceln "[Handler] /logged executing";

      match reply ctx
        "📝 Logged command executed!\n\n\
         Before hook logged entry.\n\
         After hook will log exit.\n\
         Check logs for full execution trace."
      with
      | Ok _ -> Eio.traceln "[Handler] /logged ✓"; Ok ()
      | Error e -> Eio.traceln "[Handler] /logged ✗ %a" Error.pp e; Ok ()
    )
  |> Bot.use (CustomMiddleware.logging_mw "detailed")

  (* /enriched - Context enrichment *)
  |> Bot.command "enriched" ~desc:"Context enrichment middleware" (fun ctx _args ->
      let open Bot.Ctx in
      Eio.traceln "[Handler] /enriched executing";

      let timestamp_key = Session.make ~name:"request_timestamp" in
      let timestamp = session_get ctx timestamp_key in

      let timestamp_str = match timestamp with
        | Some ts -> Printf.sprintf "%.0f" ts
        | None -> "<not set>"
      in

      let text = Printf.sprintf
        "🔮 Context Enriched!\n\n\
         Request timestamp: %s\n\n\
         Middleware added this to your session before the handler ran."
        timestamp_str
      in

      match reply ctx text with
      | Ok _ -> Eio.traceln "[Handler] /enriched ✓"; Ok ()
      | Error e -> Eio.traceln "[Handler] /enriched ✗ %a" Error.pp e; Ok ()
    )
  |> Bot.use enrich_mw

  (* /admin - Admin-only command *)
  |> Bot.command "admin" ~desc:"Admin-only command" (fun ctx _args ->
      let open Bot.Ctx in
      Eio.traceln "[Handler] /admin executing (admin-only)";

      match reply ctx
        "👑 Admin command executed!\n\n\
         Admin middleware verified your permissions.\n\
         Non-admins will be rejected before this handler runs."
      with
      | Ok _ -> Eio.traceln "[Handler] /admin ✓"; Ok ()
      | Error e -> Eio.traceln "[Handler] /admin ✗ %a" Error.pp e; Ok ()
    )
  |> Bot.use admin_mw

  (* /premium - Premium-only command *)
  |> Bot.command "premium" ~desc:"Premium-only command" (fun ctx _args ->
      let open Bot.Ctx in
      Eio.traceln "[Handler] /premium executing (premium-only)";

      match reply ctx
        "💎 Premium command executed!\n\n\
         Premium middleware verified your subscription.\n\
         Set PREMIUM_USER_IDS to test this feature."
      with
      | Ok _ -> Eio.traceln "[Handler] /premium ✓"; Ok ()
      | Error e -> Eio.traceln "[Handler] /premium ✗ %a" Error.pp e; Ok ()
    )
  |> Bot.use premium_mw

  (* /counted - Request counter middleware *)
  |> Bot.command "counted" ~desc:"Command with request counter" (fun ctx _args ->
      let open Bot.Ctx in
      Eio.traceln "[Handler] /counted executing";

      let counter_key = Session.make ~name:"request_count" in
      let count = session_get_or ctx counter_key ~default:0 in

      let text = Printf.sprintf
        "🔢 Request Counter\n\n\
         This is your request #%d\n\n\
         Counter middleware incremented this before the handler ran."
        count
      in

      match reply ctx text with
      | Ok _ -> Eio.traceln "[Handler] /counted ✓"; Ok ()
      | Error e -> Eio.traceln "[Handler] /counted ✗ %a" Error.pp e; Ok ()
    )
  |> Bot.use counter_mw

  (* /error_test - Test error middleware *)
  |> Bot.command "error_test" ~desc:"Test error handling middleware" (fun _ctx _args ->
      Eio.traceln "[Handler] /error_test throwing exception";
      failwith "This is a test exception to demonstrate error middleware!"
    )
  |> Bot.use (CustomMiddleware.logging_mw "error_handler")

  (* /layered - Multiple middleware layers *)
  |> Bot.command "layered" ~desc:"Multiple middleware layers" (fun ctx _args ->
      let open Bot.Ctx in
      Eio.traceln "[Handler] /layered executing";

      let counter_key = Session.make ~name:"request_count" in
      let count = session_get_or ctx counter_key ~default:0 in

      let timestamp_key = Session.make ~name:"request_timestamp" in
      let timestamp = session_get_or ctx timestamp_key ~default:0.0 in

      let text = Printf.sprintf
        "📚 Layered Middleware\n\n\
         This command has 3 middleware:\n\
         1. Logging (before/after)\n\
         2. Request counter (request #%d)\n\
         3. Timestamp enrichment (%.0f)\n\n\
         Check logs to see execution order!"
        count timestamp
      in

      match reply ctx text with
      | Ok _ -> Eio.traceln "[Handler] /layered ✓"; Ok ()
      | Error e -> Eio.traceln "[Handler] /layered ✗ %a" Error.pp e; Ok ()
    )
  |> Bot.use (CustomMiddleware.logging_mw "layer1")
  |> Bot.use counter_mw
  |> Bot.use enrich_mw

  (* /middleware_info - Show middleware information *)
  |> Bot.command "middleware_info" ~desc:"Middleware stack information" (fun ctx _args ->
      let open Bot.Ctx in
      Eio.traceln "[Handler] /middleware_info showing info";

      let text =
        "📋 <b>Middleware Architecture</b>\n\n\
         <b>Available Middleware:</b>\n\
         • logging - Before/after logging\n\
         • admin_only - Admin authorization\n\
         • premium_only - Premium subscription\n\
         • enrich_timestamp - Add request time\n\
         • request_counter - Count requests\n\n\
         <b>Command Middleware:</b>\n\
         /public → logging\n\
         /admin → admin_only\n\
         /premium → premium_only\n\
         /enriched → enrich_timestamp\n\
         /counted → request_counter\n\
         /layered → logging + counter + timestamp\n\n\
         <b>Execution Order:</b>\n\
         before(mw1) → before(mw2) → handler → after(mw2) → after(mw1)"
      in

      match reply ctx text with
      | Ok _ -> Eio.traceln "[Handler] /middleware_info ✓"; Ok ()
      | Error e -> Eio.traceln "[Handler] /middleware_info ✗ %a" Error.pp e; Ok ()
    )

  |> Bot.run
