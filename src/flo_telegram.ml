(** Telegram-specific semantic conventions for Flo logging.

    This module provides OpenTelemetry-style semantic conventions specifically
    for Telegram Bot API operations. Use these helpers to ensure consistent
    attribute names across all logging in the telegram bot library.

    See: https://opentelemetry.io/docs/specs/semconv/ for semantic convention patterns
*)

open Flo

(** {1 Update Attributes} *)

(** Update ID from Telegram Bot API.
    @param id The update ID (int64)
    @return ("telegram.update.id", Value.int64 id)
*)
let update_id id = ("telegram.update.id", Value.int64 id)

(** Type of update (message, edited_message, callback_query, etc.).
    @param t Update type as string
    @return ("telegram.update.type", Value.string t)
*)
let update_type t = ("telegram.update.type", Value.string t)

(** {1 User Attributes} *)

(** Telegram user ID.
    @param id User ID as string (for consistent typing)
    @return ("telegram.user.id", Value.string id)
*)
let user_id id = ("telegram.user.id", Value.string id)

(** Telegram username (without @).
    @param u Username
    @return ("telegram.user.username", Value.string u)
*)
let username u = ("telegram.user.username", Value.string u)

(** User's first name.
    @param n First name
    @return ("telegram.user.first_name", Value.string n)
*)
let user_first_name n = ("telegram.user.first_name", Value.string n)

(** User's last name.
    @param n Last name
    @return ("telegram.user.last_name", Value.string n)
*)
let user_last_name n = ("telegram.user.last_name", Value.string n)

(** Whether the user is a bot.
    @param b true if bot, false otherwise
    @return ("telegram.user.is_bot", Value.bool b)
*)
let user_is_bot b = ("telegram.user.is_bot", Value.bool b)

(** User's language code (e.g., "en", "ru").
    @param code Language code
    @return ("telegram.user.language_code", Value.string code)
*)
let user_language_code code = ("telegram.user.language_code", Value.string code)

(** {1 Chat Attributes} *)

(** Telegram chat ID.
    @param id Chat ID as string
    @return ("telegram.chat.id", Value.string id)
*)
let chat_id id = ("telegram.chat.id", Value.string id)

(** Chat type (private, group, supergroup, channel).
    @param t Chat type
    @return ("telegram.chat.type", Value.string t)
*)
let chat_type t = ("telegram.chat.type", Value.string t)

(** Chat title (for groups/channels).
    @param t Title
    @return ("telegram.chat.title", Value.string t)
*)
let chat_title t = ("telegram.chat.title", Value.string t)

(** Chat username (for public groups/channels).
    @param u Username
    @return ("telegram.chat.username", Value.string u)
*)
let chat_username u = ("telegram.chat.username", Value.string u)

(** {1 Message Attributes} *)

(** Telegram message ID.
    @param id Message ID as string
    @return ("telegram.message.id", Value.string id)
*)
let message_id id = ("telegram.message.id", Value.string id)

(** Message text content.
    @param t Text
    @return ("telegram.message.text", Value.string t)
*)
let message_text t = ("telegram.message.text", Value.string t)

(** Message caption (for media).
    @param c Caption
    @return ("telegram.message.caption", Value.string c)
*)
let message_caption c = ("telegram.message.caption", Value.string c)

(** Type of message content (text, photo, video, document, etc.).
    @param t Message type
    @return ("telegram.message.type", Value.string t)
*)
let message_type t = ("telegram.message.type", Value.string t)

(** {1 Command Attributes} *)

(** Command name (without leading /).
    @param cmd Command name (e.g., "start", "help")
    @return ("telegram.command.name", Value.string cmd)
*)
let command_name cmd = ("telegram.command.name", Value.string cmd)

(** Number of command arguments.
    @param args Argument list
    @return ("telegram.command.args", Value.int (List.length args))
*)
let command_args args = ("telegram.command.args", Value.int (List.length args))

(** Full command text (command + args).
    @param text Full command text
    @return ("telegram.command.text", Value.string text)
*)
let command_text text = ("telegram.command.text", Value.string text)

(** {1 Callback Query Attributes} *)

(** Callback query ID.
    @param id Callback query ID
    @return ("telegram.callback_query.id", Value.string id)
*)
let callback_query_id id = ("telegram.callback_query.id", Value.string id)

(** Callback data attached to button.
    @param data Callback data
    @return ("telegram.callback_query.data", Value.string data)
*)
let callback_data data = ("telegram.callback_query.data", Value.string data)

(** {1 File Attributes} *)

(** Telegram file ID.
    @param id File ID
    @return ("telegram.file.id", Value.string id)
*)
let file_id id = ("telegram.file.id", Value.string id)

(** Telegram unique file ID.
    @param id Unique file ID
    @return ("telegram.file.unique_id", Value.string id)
*)
let file_unique_id id = ("telegram.file.unique_id", Value.string id)

(** File size in bytes.
    @param size File size
    @return ("telegram.file.size", Value.int size)
*)
let file_size size = ("telegram.file.size", Value.int size)

(** File MIME type.
    @param mime MIME type
    @return ("telegram.file.mime_type", Value.string mime)
*)
let file_mime_type mime = ("telegram.file.mime_type", Value.string mime)

(** File name.
    @param name File name
    @return ("telegram.file.name", Value.string name)
*)
let file_name name = ("telegram.file.name", Value.string name)

(** {1 Bot API Method Attributes} *)

(** Telegram Bot API method name.
    @param m Method name (e.g., "sendMessage", "getUpdates")
    @return ("telegram.api.method", Value.string m)
*)
let api_method m = ("telegram.api.method", Value.string m)

(** Whether API response was successful.
    @param ok true if ok field in response is true
    @return ("telegram.api.response.ok", Value.bool ok)
*)
let api_response_ok ok = ("telegram.api.response.ok", Value.bool ok)

(** API error code from error response.
    @param code Error code
    @return ("telegram.api.error.code", Value.int code)
*)
let api_error_code code = ("telegram.api.error.code", Value.int code)

(** API error description.
    @param desc Error description
    @return ("telegram.api.error.description", Value.string desc)
*)
let api_error_description desc = ("telegram.api.error.description", Value.string desc)

(** {1 Bot Attributes} *)

(** Bot's Telegram ID.
    @param id Bot ID
    @return ("telegram.bot.id", Value.string id)
*)
let bot_id id = ("telegram.bot.id", Value.string id)

(** Bot's username.
    @param u Bot username
    @return ("telegram.bot.username", Value.string u)
*)
let bot_username u = ("telegram.bot.username", Value.string u)

(** Bot's first name.
    @param n Bot first name
    @return ("telegram.bot.first_name", Value.string n)
*)
let bot_first_name n = ("telegram.bot.first_name", Value.string n)

(** {1 Polling Attributes} *)

(** Polling timeout in seconds.
    @param timeout Timeout
    @return ("telegram.polling.timeout", Value.int timeout)
*)
let polling_timeout timeout = ("telegram.polling.timeout", Value.int timeout)

(** Polling limit (max updates per request).
    @param limit Limit
    @return ("telegram.polling.limit", Value.int limit)
*)
let polling_limit limit = ("telegram.polling.limit", Value.int limit)

(** Polling offset.
    @param offset Offset
    @return ("telegram.polling.offset", Value.int64 offset)
*)
let polling_offset offset = ("telegram.polling.offset", Value.int64 offset)

(** Number of updates received.
    @param count Update count
    @return ("telegram.polling.updates_received", Value.int count)
*)
let polling_updates_received count = ("telegram.polling.updates_received", Value.int count)

(** {1 Webhook Attributes} *)

(** Webhook URL.
    @param url Webhook URL
    @return ("telegram.webhook.url", Value.string url)
*)
let webhook_url url = ("telegram.webhook.url", Value.string url)

(** Webhook secret token.
    @param token Secret token (should be sanitized in production logs)
    @return ("telegram.webhook.secret_token", Value.string token)
*)
let webhook_secret_token token = ("telegram.webhook.secret_token", Value.string token)

(** {1 Session Attributes} *)

(** Session key name.
    @param key Session key
    @return ("telegram.session.key", Value.string key)
*)
let session_key key = ("telegram.session.key", Value.string key)

(** Session operation (get, set, delete, clear).
    @param op Operation
    @return ("telegram.session.operation", Value.string op)
*)
let session_operation op = ("telegram.session.operation", Value.string op)

(** {1 Inline Query Attributes} *)

(** Inline query ID.
    @param id Inline query ID
    @return ("telegram.inline_query.id", Value.string id)
*)
let inline_query_id id = ("telegram.inline_query.id", Value.string id)

(** Inline query text.
    @param text Query text
    @return ("telegram.inline_query.query", Value.string text)
*)
let inline_query_text text = ("telegram.inline_query.query", Value.string text)

(** Inline query offset.
    @param offset Offset
    @return ("telegram.inline_query.offset", Value.string offset)
*)
let inline_query_offset offset = ("telegram.inline_query.offset", Value.string offset)

(** {1 Payment Attributes} *)

(** Payment invoice payload.
    @param payload Invoice payload
    @return ("telegram.payment.invoice_payload", Value.string payload)
*)
let payment_invoice_payload payload = ("telegram.payment.invoice_payload", Value.string payload)

(** Payment currency code.
    @param currency Currency code (e.g., "USD", "EUR")
    @return ("telegram.payment.currency", Value.string currency)
*)
let payment_currency currency = ("telegram.payment.currency", Value.string currency)

(** Payment total amount.
    @param amount Total amount
    @return ("telegram.payment.total_amount", Value.int amount)
*)
let payment_total_amount amount = ("telegram.payment.total_amount", Value.int amount)

(** {1 Media Group Attributes} *)

(** Media group ID (for grouped media).
    @param id Media group ID
    @return ("telegram.media_group.id", Value.string id)
*)
let media_group_id id = ("telegram.media_group.id", Value.string id)

(** Number of media items in group.
    @param count Media count
    @return ("telegram.media_group.count", Value.int count)
*)
let media_group_count count = ("telegram.media_group.count", Value.int count)
