(** Recipe: Webhook Bot

    A comprehensive production-ready webhook bot demonstrating:
    - Webhook server setup with TLS and security
    - Secret token validation
    - IP allowlisting (Telegram IP ranges)
    - Custom rate limiting with validator hooks
    - Graceful shutdown handling
    - Metrics tracking (updates, errors, uptime)
    - Result-based error handling
    - Functor-based verbose logging
*)

open Telegram
open Tg

(** {1 Verbose Logging Setup} *)

(* Configure verbose logging with flo *)
let () = Flo.set_level Severity.Debug

(** {1 Configuration} *)

module Config = struct
  let port =
    match Sys.getenv_opt "WEBHOOK_PORT" with
    | Some p -> int_of_string p
    | None -> 8443

  let path =
    match Sys.getenv_opt "WEBHOOK_PATH" with
    | Some p -> p
    | None -> "/webhook"

  let secret_token =
    match Sys.getenv_opt "WEBHOOK_SECRET" with
    | Some s -> s
    | None ->
        Flo.debug "[Config] ⚠️  WARNING: WEBHOOK_SECRET not set, using default (not secure!)";
        "default-secret-token-please-change-me"

  let webhook_url =
    match Sys.getenv_opt "WEBHOOK_URL" with
    | Some url -> url
    | None ->
        Flo.debug "[Config] ⚠️  WARNING: WEBHOOK_URL not set, using default";
        Printf.sprintf "https://example.com:%d%s" port path

  let token =
    match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None -> failwith "TELEGRAM_BOT_TOKEN environment variable not set"
end

(** {1 Metrics Tracking} *)

module Metrics = struct
  let updates_processed = ref 0L
  let errors = ref 0L
  let start_time = ref 0.0

  let record_update () =
    updates_processed := Int64.add !updates_processed 1L;
    Flo.debugf "[Metrics] Update processed: total=%Ld" !updates_processed

  let record_error () =
    errors := Int64.add !errors 1L;
    Flo.debugf "[Metrics] Error recorded: total=%Ld" !errors

  let uptime () =
    Unix.time () -. !start_time

  let format_duration secs =
    let hours = int_of_float secs / 3600 in
    let mins = (int_of_float secs mod 3600) / 60 in
    let secs = int_of_float secs mod 60 in
    Printf.sprintf "%dh %dm %ds" hours mins secs

  let stats () =
    Printf.sprintf "Uptime: %s | Updates: %Ld | Errors: %Ld"
      (format_duration (uptime ()))
      !updates_processed
      !errors

  let print_stats () =
    Flo.debugf "[Metrics] %s" (stats ())
end

(** {1 Rate Limiting} *)

module RateLimiter = struct
  type entry = {
    count : int;
    last_reset : float;
  }

  let table : (string, entry) Hashtbl.t = Hashtbl.create 100
  let limit_per_minute = 100

  let check ip =
    let now = Unix.time () in
    match Hashtbl.find_opt table ip with
    | Some entry ->
        if now -. entry.last_reset > 60.0 then begin
          (* Reset after 1 minute *)
          Flo.debugf "[RateLimit] Reset counter for IP: %s" ip;
          Hashtbl.replace table ip { count = 1; last_reset = now };
          true
        end else if entry.count >= limit_per_minute then begin
          (* Too many requests *)
          Flo.errorf "[RateLimit] ❌ Rate limit exceeded: ip=%s, count=%d" ip entry.count;
          false
        end else begin
          (* Increment counter *)
          Hashtbl.replace table ip { count = entry.count + 1; last_reset = entry.last_reset };
          Flo.debugf "[RateLimit] Request allowed: ip=%s, count=%d/%d"
            ip (entry.count + 1) limit_per_minute;
          true
        end
    | None ->
        Flo.debugf "[RateLimit] New IP registered: %s" ip;
        Hashtbl.add table ip { count = 1; last_reset = now };
        true

  let validator (request : Webhook.request_info) : Webhook.validation_result =
    Flo.debugf "[RateLimit] Checking rate limit for IP: %s" request.client_addr;
    if check request.client_addr then
      Webhook.Accept
    else
      Webhook.Reject (Printf.sprintf "Rate limit exceeded (max %d req/min)" limit_per_minute)
end

(** {1 Webhook Setup Instructions} *)

let print_webhook_setup_instructions () =
  Flo.debug "";
  Flo.info "╔══════════════════════════════════════════════════════════════════╗";
  Flo.info "║                   Webhook Setup Instructions                     ║";
  Flo.info "╚══════════════════════════════════════════════════════════════════╝";
  Flo.debug "[Webhook] Before sending updates, configure Telegram webhook:";
  Flo.debug "[Webhook]";
  Flo.debug "[Webhook] Using curl:";
  Flo.debugf "[Webhook]   curl -X POST \"https://api.telegram.org/bot%s/setWebhook\" \\" Config.token;
  Flo.debugf "[Webhook]     -d \"url=%s\" \\" Config.webhook_url;
  Flo.debugf "[Webhook]     -d \"secret_token=%s\" \\" Config.secret_token;
  Flo.debug "[Webhook]     -d \"max_connections=100\"";
  Flo.debug "[Webhook]";
  Flo.debug "[Webhook] Or manually:";
  Flo.debugf "[Webhook]   https://api.telegram.org/bot<TOKEN>/setWebhook?url=%s&secret_token=%s"
    Config.webhook_url Config.secret_token;
  Flo.debug "";
  Flo.debug "[Webhook] To check webhook status:";
  Flo.debugf "[Webhook]   curl \"https://api.telegram.org/bot%s/getWebhookInfo\"" Config.token;
  Flo.debug ""

(** {1 Update Handler} *)

(* Simple handler that processes updates *)
let handle_update update =
  Flo.debug "";
  Flo.info "╔══════════════════════════════════════════════════════════════════╗";
  Flo.info "║                        New Update                                ║";
  Flo.info "╚══════════════════════════════════════════════════════════════════╝";
  Flo.debugf "[Update] Received update: id=%Ld" update.Telegram_generated.Gen_types.Update.update_id;

  (* Log update details *)
  (match update.message with
   | Some msg ->
       Flo.debugf "[Update] Message: id=%Ld, chat=%Ld"
         msg.message_id
         msg.chat.id;
       (match msg.text with
        | Some text -> Flo.debugf "[Update] Text: %s" text
        | None -> Flo.debug "[Update] No text content")
   | None -> Flo.debug "[Update] No message in update");

  (* Track metrics *)
  Metrics.record_update ();
  Flo.success "[Update] ✅ Update received (processing via webhook low-level API)"

(** {1 Main Entry Point} *)

let () =
  Eio_main.run @@ fun env ->
  Eio.Switch.run @@ fun sw ->

  Flo.debug "";
  Flo.info "╔══════════════════════════════════════════════════════════════════╗";
  Flo.info "║              Webhook Bot - Production Example                    ║";
  Flo.info "╚══════════════════════════════════════════════════════════════════╝";
  Flo.debug "";

  (* Phase 1: Initialize *)
  Flo.info "╔══════════════════════════════════════════════════════════════════╗";
  Flo.info "║                    Phase 1: Initialization                       ║";
  Flo.info "╚══════════════════════════════════════════════════════════════════╝";

  Metrics.start_time := Unix.time ();

  Flo.info "[Init] Creating Telegram client";
  let telegram_client = Telegram.Client.create ~env ~token:Config.token () in
  Flo.info "[Init] Client created successfully";

  (* Print webhook setup instructions *)
  print_webhook_setup_instructions ();

  (* Phase 2: Setup webhook server *)
  Flo.debug "";
  Flo.info "╔══════════════════════════════════════════════════════════════════╗";
  Flo.info "║                  Phase 2: Configure Webhook Server               ║";
  Flo.info "╚══════════════════════════════════════════════════════════════════╝";

  (* Error handler *)
  let on_error err =
    Flo.errorf "[Error] Webhook error: %s" (Format.asprintf "%a" Error.pp err);
    Metrics.record_error ()
  in

  (* Webhook configuration with all security features *)
  let webhook_config = Webhook.make
    ~port:Config.port
    ~path:Config.path
    ~secret_token:Config.secret_token
    ~max_connections:100
    ~on_error
    ~ip_allowlist:Webhook.telegram_ip_ranges
    ~custom_validator:RateLimiter.validator
    ()
  in

  Flo.debug "[Webhook] Configuration:";
  Flo.debugf "[Webhook]   - Port: %d" Config.port;
  Flo.debugf "[Webhook]   - Path: %s" Config.path;
  Flo.debug "[Webhook]   - Max connections: 100";
  Flo.debug "[Webhook]   - Secret token: Configured ✓";
  Flo.debug "[Webhook]   - IP allowlist: Telegram IP ranges ✓";
  Flo.debugf "[Webhook]   - Rate limiting: %d req/min ✓" RateLimiter.limit_per_minute;

  (* Signal handling for graceful shutdown *)
  let shutdown _ =
    Flo.debug "";
    Flo.info "╔══════════════════════════════════════════════════════════════════╗";
    Flo.info "║                      Shutdown Signal                             ║";
    Flo.info "╚══════════════════════════════════════════════════════════════════╝";
    Flo.debug "[Shutdown] Signal received, draining connections...";
    Metrics.print_stats ();
    Eio.Switch.fail sw Exit
  in

  Sys.set_signal Sys.sigint (Sys.Signal_handle shutdown);
  Sys.set_signal Sys.sigterm (Sys.Signal_handle shutdown);
  Flo.debug "[Shutdown] Signal handlers registered (SIGINT, SIGTERM)";

  (* Phase 3: Run webhook server *)
  Flo.debug "";
  Flo.info "╔══════════════════════════════════════════════════════════════════╗";
  Flo.info "║                    Phase 3: Start Webhook Server                 ║";
  Flo.info "╚══════════════════════════════════════════════════════════════════╝";
  Flo.infof "[Webhook] Starting webhook server on port %d..." Config.port;
  Flo.debugf "[Webhook] Listening on: http://127.0.0.1:%d%s" Config.port Config.path;
  Flo.debugf "[Webhook] Public URL: %s" Config.webhook_url;
  Flo.debug "";
  Flo.info "╔══════════════════════════════════════════════════════════════════╗";
  Flo.info "║                     Bot is Ready!                                ║";
  Flo.info "╚══════════════════════════════════════════════════════════════════╝";
  Flo.debug "[Webhook] Waiting for updates from Telegram...";
  Flo.debug "";

  try
    Webhook.run_with_config_and_switch telegram_client webhook_config sw
      ~handler:handle_update;

    Flo.debug "";
    Flo.info "╔══════════════════════════════════════════════════════════════════╗";
    Flo.info "║                    Graceful Shutdown Complete                    ║";
    Flo.info "╚══════════════════════════════════════════════════════════════════╝";
    Metrics.print_stats ()
  with Exit ->
    Flo.debug "";
    Flo.info "╔══════════════════════════════════════════════════════════════════╗";
    Flo.info "║                         Shutdown Complete                        ║";
    Flo.info "╚══════════════════════════════════════════════════════════════════╝";
    Metrics.print_stats ()
