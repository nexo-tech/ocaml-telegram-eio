(** Telegram-specific semantic conventions and scoped loggers for Flo logging.

    This module provides:
    1. {b Scoped loggers} with hierarchical namespaces for internal library use
    2. {b Semantic conventions} for consistent structured logging

    {1 Usage in Library Code}

    Internal library code should use the scoped loggers to allow applications
    fine-grained control over log verbosity:

    {[
      (* Use root logger *)
      module Log = Flo_telegram.Log

      let connect () =
        Log.debug "Connecting to Telegram API";
        Log.info "Connected successfully"

      (* Or create sub-namespace logger *)
      let logger = Flo_telegram.create_logger "polling"
      let module PollLog = (val logger : Flo_scoped.LOGGER) in

      let poll () =
        PollLog.debug "Fetching updates"
    ]}

    {1 Usage in Applications}

    Applications configure library verbosity using namespace-based levels:

    {[
      let () =
        Eio_main.run @@ fun env ->
          (* Default: Info level (hides debug logs) *)
          Flo.set_level Severity.Info;

          (* Enable debug for entire telegram library *)
          Flo.set_level_for "telegram" Severity.Debug;

          (* Or fine-grained control *)
          Flo.set_level_for "telegram.polling" Severity.Debug;
          Flo.set_level_for "telegram.client.http" Severity.Warn;

          (* Your bot code *)
          let client = Telegram.Client.create ~env ~token () in
          Telegram.Polling.run client bot
    ]}

    {1 Structured Logging with Semantic Conventions}

    Use the semantic convention helpers for consistent field names:

    {[
      open Flo_telegram

      Log.info_fields "Update received" ~fields:[
        update_id 12345L;
        update_type "message";
        user_id "123456";
        chat_id "789012";
      ]
    ]}

    @see <https://opentelemetry.io/docs/specs/semconv/> OpenTelemetry Semantic Conventions
*)

(** {1 Scoped Loggers} *)

(** Root logger for the telegram library.

    Use this logger for general telegram library logs. For component-specific
    logging, create sub-namespace loggers with {!create_logger}.

    Namespace: ["telegram"]

    Example:
    {[
      module Log = Flo_telegram.Log

      let init () =
        Log.info "Telegram library initialized";
        Log.debug "Debug information"
    ]}
*)
module Log : Flo_scoped.LOGGER

(** Create a scoped logger for a telegram sub-component.

    The component name is appended to ["telegram."] to form the full namespace.
    Sub-namespaces inherit level configuration from parent namespaces.

    @param component Component name (e.g., ["polling"], ["client.http"])
    @return First-class module implementing {!Flo_scoped.LOGGER}

    Example:
    {[
      (* Creates logger with namespace "telegram.polling" *)
      let logger = Flo_telegram.create_logger "polling"
      let module Log = (val logger : Flo_scoped.LOGGER) in

      let poll () =
        Log.debug "Polling for updates";
        Log.info_fields "Updates received" ~fields:[
          Flo_telegram.polling_updates_received 5;
        ]
    ]}
*)
val create_logger : string -> (module Flo_scoped.LOGGER)

(** Create a scoped logger with explicit namespace.

    Use when you need full control over the namespace path.

    @param namespace Full namespace path (e.g., ["telegram.bot.middleware.auth"])
    @return First-class module implementing {!Flo_scoped.LOGGER}

    Example:
    {[
      let logger = Flo_telegram.create_logger_with_namespace "telegram.bot.dispatch"
      let module Log = (val logger : Flo_scoped.LOGGER) in
      Log.debug "Dispatching update"
    ]}
*)
val create_logger_with_namespace : string -> (module Flo_scoped.LOGGER)

(** {1 Semantic Conventions}

    The following functions provide OpenTelemetry-style semantic conventions
    for structured logging. All functions return [(string * Flo.Value.t)] tuples
    suitable for use with [~fields] parameters. *)

(** {1 Update Attributes} *)

val update_id : int64 -> string * Flo.Value.t
(** Update ID from Telegram Bot API *)

val update_type : string -> string * Flo.Value.t
(** Type of update (message, edited_message, callback_query, etc.) *)

(** {1 User Attributes} *)

val user_id : string -> string * Flo.Value.t
(** Telegram user ID *)

val username : string -> string * Flo.Value.t
(** Telegram username (without @) *)

val user_first_name : string -> string * Flo.Value.t
(** User's first name *)

val user_last_name : string -> string * Flo.Value.t
(** User's last name *)

val user_is_bot : bool -> string * Flo.Value.t
(** Whether the user is a bot *)

val user_language_code : string -> string * Flo.Value.t
(** User's language code (e.g., "en", "ru") *)

(** {1 Chat Attributes} *)

val chat_id : string -> string * Flo.Value.t
(** Telegram chat ID *)

val chat_type : string -> string * Flo.Value.t
(** Chat type (private, group, supergroup, channel) *)

val chat_title : string -> string * Flo.Value.t
(** Chat title (for groups/channels) *)

val chat_username : string -> string * Flo.Value.t
(** Chat username (for public groups/channels) *)

(** {1 Message Attributes} *)

val message_id : string -> string * Flo.Value.t
(** Telegram message ID *)

val message_text : string -> string * Flo.Value.t
(** Message text content *)

val message_caption : string -> string * Flo.Value.t
(** Message caption (for media) *)

val message_type : string -> string * Flo.Value.t
(** Type of message content (text, photo, video, document, etc.) *)

(** {1 Command Attributes} *)

val command_name : string -> string * Flo.Value.t
(** Command name (without leading /) *)

val command_args : 'a list -> string * Flo.Value.t
(** Number of command arguments *)

val command_text : string -> string * Flo.Value.t
(** Full command text (command + args) *)

(** {1 Callback Query Attributes} *)

val callback_query_id : string -> string * Flo.Value.t
(** Callback query ID *)

val callback_data : string -> string * Flo.Value.t
(** Callback data attached to button *)

(** {1 File Attributes} *)

val file_id : string -> string * Flo.Value.t
(** Telegram file ID *)

val file_unique_id : string -> string * Flo.Value.t
(** Telegram unique file ID *)

val file_size : int -> string * Flo.Value.t
(** File size in bytes *)

val file_mime_type : string -> string * Flo.Value.t
(** File MIME type *)

val file_name : string -> string * Flo.Value.t
(** File name *)

(** {1 Bot API Method Attributes} *)

val api_method : string -> string * Flo.Value.t
(** Telegram Bot API method name (e.g., "sendMessage", "getUpdates") *)

val api_response_ok : bool -> string * Flo.Value.t
(** Whether API response was successful *)

val api_error_code : int -> string * Flo.Value.t
(** API error code from error response *)

val api_error_description : string -> string * Flo.Value.t
(** API error description *)

(** {1 Bot Attributes} *)

val bot_id : string -> string * Flo.Value.t
(** Bot's Telegram ID *)

val bot_username : string -> string * Flo.Value.t
(** Bot's username *)

val bot_first_name : string -> string * Flo.Value.t
(** Bot's first name *)

(** {1 Polling Attributes} *)

val polling_timeout : int -> string * Flo.Value.t
(** Polling timeout in seconds *)

val polling_limit : int -> string * Flo.Value.t
(** Polling limit (max updates per request) *)

val polling_offset : int64 -> string * Flo.Value.t
(** Polling offset *)

val polling_updates_received : int -> string * Flo.Value.t
(** Number of updates received *)

(** {1 Webhook Attributes} *)

val webhook_url : string -> string * Flo.Value.t
(** Webhook URL *)

val webhook_secret_token : string -> string * Flo.Value.t
(** Webhook secret token *)

(** {1 Session Attributes} *)

val session_key : string -> string * Flo.Value.t
(** Session key name *)

val session_operation : string -> string * Flo.Value.t
(** Session operation (get, set, delete, clear) *)

(** {1 Inline Query Attributes} *)

val inline_query_id : string -> string * Flo.Value.t
(** Inline query ID *)

val inline_query_text : string -> string * Flo.Value.t
(** Inline query text *)

val inline_query_offset : string -> string * Flo.Value.t
(** Inline query offset *)

(** {1 Payment Attributes} *)

val payment_invoice_payload : string -> string * Flo.Value.t
(** Payment invoice payload *)

val payment_currency : string -> string * Flo.Value.t
(** Payment currency code (e.g., "USD", "EUR") *)

val payment_total_amount : int -> string * Flo.Value.t
(** Payment total amount *)

(** {1 Media Group Attributes} *)

val media_group_id : string -> string * Flo.Value.t
(** Media group ID (for grouped media) *)

val media_group_count : int -> string * Flo.Value.t
(** Number of media items in group *)
