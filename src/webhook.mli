(** Webhook server for Telegram Bot API updates.

    This module provides an elegant, production-ready HTTP server for receiving
    updates via webhooks. It handles request validation, secret token verification,
    JSON parsing, and concurrent update processing with Eio.

    {1 Basic Usage}

    {[
      let handler update =
        match update.message with
        | Some msg -> Printf.printf "Got message: %Ld\n" msg.message_id
        | None -> ()
      in

      Webhook.run client
        ~secret_token:"my-secret-token"
        ~port:8443
        ~path:"/webhook"
        ~handler
    ]}

    {1 Advanced Usage with Custom Config}

    {[
      let config = Webhook.make
        ~port:8443
        ~path:"/webhook"
        ~secret_token:(Some "my-secret-token")
        ~max_connections:100
        ~on_error:(fun err -> Logs.warn (fun m -> m "Error: %a" Error.pp err))
        ()
      in

      Webhook.run_with_config client config ~handler
    ]}

    {1 Security}

    - Always use a secret token in production
    - Run behind a reverse proxy (Nginx, Caddy) with TLS
    - Telegram only sends requests with X-Telegram-Bot-Api-Secret-Token header

    {1 Reverse Proxy Configuration (Nginx/TLS Offload)}

    When running behind a reverse proxy like Nginx with TLS termination:

    {2 Basic Nginx Configuration}

    {[
      server {
        listen 443 ssl;
        server_name bot.example.com;

        ssl_certificate /etc/ssl/certs/bot.crt;
        ssl_certificate_key /etc/ssl/private/bot.key;

        location /webhook {
          proxy_pass http://127.0.0.1:8080/webhook;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        }
      }
    ]}

    {2 Security Best Practices}

    1. {b IP Allowlist}: Restrict to Telegram's IP ranges at Nginx level:
    {[
      # In nginx.conf or site config
      geo $telegram_ip {
        default 0;
        149.154.160.0/20 1;
        91.108.4.0/22 1;
      }

      server {
        location /webhook {
          if ($telegram_ip = 0) {
            return 403;
          }
          proxy_pass http://127.0.0.1:8080/webhook;
        }
      }
    ]}

    Alternatively, use application-level IP filtering:
    {[
      let config = Webhook.make
        ~port:8080
        ~path:"/webhook"
        ~secret_token:"secret"
        ~ip_allowlist:Webhook.telegram_ip_ranges  (* Use Telegram's official ranges *)
        ()
      in
      Webhook.run_with_config client config ~handler
    ]}

    2. {b Secret Token}: Always verify the secret token (both at Nginx and app level):
    {[
      # Nginx example
      if ($http_x_telegram_bot_api_secret_token != "your-secret-token") {
        return 403;
      }
    ]}

    3. {b Custom Validation}: Implement rate limiting or additional checks:
    {[
      let rate_limiter = (* your rate limiter implementation *) in
      let custom_validator request =
        if rate_limiter.check request.client_addr then
          Webhook.Accept
        else
          Webhook.Reject "Rate limit exceeded"
      in
      let config = Webhook.make
        ~secret_token:"secret"
        ~custom_validator
        ()
    ]}

    {2 Real Client IP with Proxy}

    When behind a reverse proxy, the client IP address will be the proxy's IP (typically 127.0.0.1).
    To get the real client IP:

    - Configure Nginx to pass X-Forwarded-For or X-Real-IP headers (shown above)
    - Use a custom validator to extract the real IP from headers:
    {[
      let extract_real_ip request =
        match List.assoc_opt "X-Real-IP" request.headers with
        | Some ip -> ip
        | None ->
            (* Fallback to X-Forwarded-For, take first IP *)
            match List.assoc_opt "X-Forwarded-For" request.headers with
            | Some ips -> (match String.split_on_char ',' ips with
                          | first :: _ -> String.trim first
                          | [] -> request.client_addr)
            | None -> request.client_addr
      in

      let custom_validator request =
        let real_ip = extract_real_ip request in
        if Webhook.ip_in_range real_ip "149.154.160.0/20" ||
           Webhook.ip_in_range real_ip "91.108.4.0/22" then
          Webhook.Accept
        else
          Webhook.Reject ("Invalid source IP: " ^ real_ip)
    ]}

    Note: When using X-Forwarded-For, ensure your reverse proxy is configured to prevent
    header spoofing by clients. Only trust these headers from your trusted proxy.

    {1 Graceful Shutdown}

    {2 Shutdown Semantics}

    The webhook server provides automatic graceful shutdown through Eio's switch mechanism:

    1. {b Stop accepting}: No new connections accepted after shutdown signal
    2. {b Drain in-flight}: All active requests complete before shutdown
    3. {b Clean exit}: Return normally when all requests are finished

    {2 Shutdown Trigger}

    Cancel the Eio switch to trigger shutdown:

    {[
      Eio_main.run @@ fun env ->
      Eio.Switch.run @@ fun sw ->

      (* Handle signals *)
      let shutdown _ =
        Logs.info (fun m -> m "Shutdown signal received, draining connections...");
        Eio.Switch.fail sw Exit
      in
      Sys.set_signal Sys.sigint (Sys.Signal_handle shutdown);
      Sys.set_signal Sys.sigterm (Sys.Signal_handle shutdown);

      (* Run webhook *)
      try
        Webhook.run_with_config_and_switch client config sw ~handler;
        Logs.info (fun m -> m "Webhook server stopped")
      with Exit ->
        Logs.info (fun m -> m "Shutdown complete")
    ]}

    {2 Draining Behavior}

    When shutdown is triggered:

    {v
    Timeline:
    1. Shutdown signal received
    2. Stop accepting new connections (listen socket closed)
    3. Wait for all in-flight HTTP requests to complete
    4. Each request processes its update and sends response
    5. Return from run function
    v}

    Active connections are handled by Eio fibers attached to the switch:
    - Each [accept_fork] creates a fiber for the connection
    - Fibers continue running until request completes
    - Switch waits for all child fibers before returning
    - Clean shutdown guaranteed by Eio's structured concurrency

    {2 Connection Timeout}

    To prevent slow requests from blocking shutdown indefinitely:

    {[
      let handler update =
        (* Wrap handler with timeout *)
        Eio.Time.with_timeout clock 10.0
          (fun () -> process_update update)
          ~on_timeout:(fun () ->
            Logs.warn (fun m -> m "Handler timeout during request")
          )
    ]}

    Or configure a global request timeout in your reverse proxy (Nginx):
    {v
      proxy_read_timeout 30s;
      proxy_send_timeout 30s;
    v}

    {2 Max Shutdown Time}

    Worst-case shutdown time:
    - max_connections × request_timeout
    - Example: 100 connections × 10s = 1000s (16 minutes) worst case
    - Typical: Most requests complete in <1s, shutdown in seconds

    To reduce shutdown time:
    1. Lower max_connections for faster draining
    2. Add request timeouts in handler
    3. Use reverse proxy timeouts
    4. Implement handler cancellation on shutdown

    {2 Non-graceful Functions}

    [run] and [run_with_config] create their own switch:
    - Less control over shutdown timing
    - Process termination will kill in-flight requests
    - Use switch-based variants for production

    {2 Production Example}

    Complete webhook server with graceful shutdown:

    {[
      let run_production client config handler =
        Eio_main.run @@ fun env ->
        Eio.Switch.run @@ fun sw ->

        (* Signal handling *)
        let shutdown _ =
          Logs.info (fun m -> m "Shutdown requested, draining...");
          Eio.Switch.fail sw Exit
        in
        Sys.set_signal Sys.sigint (Sys.Signal_handle shutdown);
        Sys.set_signal Sys.sigterm (Sys.Signal_handle shutdown);

        (* Timeout wrapper for handler *)
        let handler_with_timeout update =
          try
            Eio.Time.with_timeout (env#clock) 10.0
              (fun () -> handler update)
              ~on_timeout:(fun () ->
                Logs.warn (fun m -> m "Handler timeout for update %Ld"
                  (get_update_id update))
              )
          with exn ->
            Logs.err (fun m -> m "Handler error: %s" (Printexc.to_string exn))
        in

        (* Run server *)
        try
          Logs.info (fun m -> m "Starting webhook on port %d" config.port);
          Webhook.run_with_config_and_switch client config sw
            ~handler:handler_with_timeout;
          Logs.info (fun m -> m "Webhook stopped gracefully")
        with Exit ->
          Logs.info (fun m -> m "Shutdown complete")
    ]}

    {2 Kubernetes/Docker}

    For containerized deployments:
    - Handle SIGTERM for graceful pod shutdown
    - Set terminationGracePeriodSeconds appropriately
    - Implement readiness/liveness probes
    - Example terminationGracePeriodSeconds: 30-60s
*)

(** Request information passed to validation hooks. *)
type request_info = {
  client_addr : string;
    (** Client IP address (string representation). *)
  headers : (string * string) list;
    (** HTTP headers as name-value pairs. *)
  path : string;
    (** Request path. *)
  method_ : string;
    (** HTTP method (e.g., "POST"). *)
}

(** Result of validation hook: Accept or Reject with reason. *)
type validation_result =
  | Accept
  | Reject of string  (** Rejection reason for logging *)

(** Configuration for webhook server. *)
type config = {
  port : int;
    (** Port to listen on (default: 8443).
        Telegram supports: 443, 80, 88, 8443. *)
  path : string;
    (** URL path to receive updates (default: "/webhook").
        Example: "/bot<token>" or "/my-bot" *)
  secret_token : string option;
    (** Secret token for request validation (default: None).
        Highly recommended for production! Sent via X-Telegram-Bot-Api-Secret-Token header. *)
  max_connections : int;
    (** Maximum concurrent connections (default: 100). *)
  on_error : (Telegram.Error.t -> unit) option;
    (** Optional callback for handling errors (default: ignore errors). *)
  ip_allowlist : string list option;
    (** IP allowlist (default: None = allow all).
        Example: ["149.154.160.0/20"; "91.108.4.0/22"]
        Telegram's IP ranges as of 2024. *)
  custom_validator : (request_info -> validation_result) option;
    (** Custom validation hook (default: None).
        Called after IP and secret token checks.
        Useful for additional security like rate limiting, custom auth, etc. *)
}

(** Create a webhook configuration with custom parameters.
    All parameters are optional with sensible defaults. *)
val make :
  ?port:int ->
  ?path:string ->
  ?secret_token:string ->
  ?max_connections:int ->
  ?on_error:(Telegram.Error.t -> unit) ->
  ?ip_allowlist:string list ->
  ?custom_validator:(request_info -> validation_result) ->
  unit ->
  config

(** Default webhook configuration.
    - port: 8443
    - path: "/webhook"
    - secret_token: None (not recommended for production!)
    - max_connections: 100
    - on_error: ignore errors
    - ip_allowlist: None (allow all IPs)
    - custom_validator: None *)
val default : config

(** {1 Security Helpers} *)

(** Telegram's official IP ranges (as of 2024).
    Use this for ip_allowlist to restrict to Telegram servers only.
    Source: https://core.telegram.org/bots/webhooks *)
val telegram_ip_ranges : string list

(** Check if an IP address is in a CIDR range.
    Example: [ip_in_range "149.154.160.5" "149.154.160.0/20"] returns [true] *)
val ip_in_range : string -> string -> bool

(** Create an IP validator from a list of CIDR ranges.
    Returns a custom_validator function that checks IP against allowlist. *)
val make_ip_validator : string list -> (request_info -> validation_result)

(** Run webhook server with minimal configuration.

    This is the simplest way to start receiving updates via webhooks.

    Important: You must call setWebhook to tell Telegram where to send updates:
    {[
      let url = "https://example.com:8443/webhook" in
      Api.call_method client ~method_name:"setWebhook"
        [ ("url", Param.string url)
        ; ("secret_token", Param.string "my-secret") ]
    ]}

    @param client The Telegram client
    @param secret_token Secret token for validation (highly recommended!)
    @param port Port to listen on (default: 8443)
    @param path URL path (default: "/webhook")
    @param handler Function called for each update
*)
val run :
  Telegram.Client.t ->
  ?secret_token:string ->
  ?port:int ->
  ?path:string ->
  handler:(Telegram_generated.Gen_types.Update.t -> unit) ->
  unit

(** Run webhook server with custom configuration.

    Provides full control over server parameters.

    @param client The Telegram client
    @param config Custom webhook configuration
    @param handler Function called for each update
*)
val run_with_config :
  Telegram.Client.t ->
  config ->
  handler:(Telegram_generated.Gen_types.Update.t -> unit) ->
  unit

(** Run webhook server with Eio switch for graceful shutdown.

    The server will stop when the switch is cancelled, allowing graceful
    shutdown of in-flight requests.

    {[
      Eio.Switch.run @@ fun sw ->
      Webhook.run_with_switch client sw
        ~secret_token:"my-secret"
        ~handler;
      (* Cancelling sw will stop the server *)
    ]}

    @param client The Telegram client
    @param sw Eio switch for cancellation
    @param secret_token Secret token for validation
    @param port Port to listen on
    @param path URL path
    @param handler Function called for each update
*)
val run_with_switch :
  Telegram.Client.t ->
  Eio.Switch.t ->
  ?secret_token:string ->
  ?port:int ->
  ?path:string ->
  handler:(Telegram_generated.Gen_types.Update.t -> unit) ->
  unit

(** Run webhook server with full control: custom config and switch.

    Combines custom configuration with Eio switch-based cancellation.

    @param client The Telegram client
    @param config Custom webhook configuration
    @param sw Eio switch for cancellation
    @param handler Function called for each update
*)
val run_with_config_and_switch :
  Telegram.Client.t ->
  config ->
  Eio.Switch.t ->
  handler:(Telegram_generated.Gen_types.Update.t -> unit) ->
  unit
