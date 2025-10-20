(** Telegram-specific semantic conventions for Flo logging.

    This module provides OpenTelemetry-style semantic conventions specifically
    for Telegram Bot API operations. Use these helpers to ensure consistent
    attribute names across all logging in the telegram bot library.

    All functions return [(string * Flo.Value.t)] tuples suitable for use with
    {!Flo.info_fields}, {!Flo.debug_fields}, and other structured logging functions.

    Example:
    {[
      open Flo
      open Flo_telegram

      info_fields "Update received" ~fields:[
        update_id 12345L;
        update_type "message";
        user_id "123456";
        chat_id "789012";
      ]
    ]}

    @see <https://opentelemetry.io/docs/specs/semconv/> OpenTelemetry Semantic Conventions
*)

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
