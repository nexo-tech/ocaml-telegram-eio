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
*)

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
}

(** Create a webhook configuration with custom parameters.
    All parameters are optional with sensible defaults. *)
val make :
  ?port:int ->
  ?path:string ->
  ?secret_token:string ->
  ?max_connections:int ->
  ?on_error:(Telegram.Error.t -> unit) ->
  unit ->
  config

(** Default webhook configuration.
    - port: 8443
    - path: "/webhook"
    - secret_token: None (not recommended for production!)
    - max_connections: 100
    - on_error: ignore errors *)
val default : config

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
