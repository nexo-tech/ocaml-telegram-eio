# API Reference

This document provides reference documentation for the ocaml-telegram-eio library.

## Table of Contents

- [Logging & Namespaces](#logging--namespaces)
- [Core Modules](#core-modules)
- [Bot DSL](#bot-dsl)
- [Error Handling](#error-handling)

## Logging & Namespaces

The library uses hierarchical namespace-based logging powered by [Flo](https://github.com/c-cube/ocaml-flo). This allows fine-grained control over log verbosity per component.

### Namespace Hierarchy

The library organizes logs into a hierarchical namespace structure:

```
telegram                           Root namespace (all library logs)
├── telegram.client                Client initialization and configuration
│   └── telegram.client.http       HTTP requests/responses and connection handling
├── telegram.api                   Telegram API method calls
│   └── telegram.api.response      Response parsing and validation
├── telegram.polling               Long polling update delivery
├── telegram.webhook               Webhook server and request handling
├── telegram.bot                   Bot framework
│   ├── telegram.bot.dispatch      Event routing and handler execution
│   ├── telegram.bot.middleware    Middleware chain execution
│   └── telegram.bot.context       Context operations (reply, send, edit)
├── telegram.upload                File upload operations
├── telegram.download              File download operations
├── telegram.retry                 Retry logic and backoff strategies
├── telegram.session               Session management and persistence
└── telegram.error                 Error analysis and retry decisions
```

### Namespace Inheritance

Child namespaces inherit log levels from their parents unless explicitly overridden:

```ocaml
(* Enable debug for entire client subsystem *)
Flo.set_level_for "telegram.client" Severity.Debug;
(* ↑ This enables Debug for BOTH telegram.client AND telegram.client.http *)

(* Override child to reduce noise *)
Flo.set_level_for "telegram.client" Severity.Debug;
Flo.set_level_for "telegram.client.http" Severity.Warn;
(* ↑ Client logs at Debug, but HTTP logs only at Warn or higher *)
```

### Log Levels by Component

Each component logs different types of events at different severity levels:

| Level | Used For | Examples |
|-------|----------|----------|
| **Trace** | Very detailed internal state | Offset calculations, retry_after extraction, store size |
| **Debug** | Internal operations (hidden by default) | Route matching, HTTP requests, session operations |
| **Info** | User-visible lifecycle events | Bot started, upload/download complete, polling started |
| **Warn** | Recoverable errors | Retry attempts, rate limiting, unauthorized access |
| **Error** | Critical errors requiring attention | Connection failures, decode errors, handler exceptions |

### Configuration API

#### Set Global Log Level

```ocaml
(* Set default level for all logs *)
Flo.set_level Severity.Info;
```

#### Set Namespace-Specific Level

```ocaml
(* Enable debug for specific namespace *)
Flo.set_level_for "telegram.polling" Severity.Debug;

(* Enable trace for very detailed logging *)
Flo.set_level_for "telegram.session" Severity.Trace;
```

#### Clear Namespace Override

```ocaml
(* Remove namespace-specific override, revert to global/parent *)
Flo.clear_level_for "telegram.polling";
```

### Effective Log Levels

The effective log level for a namespace is determined by:

1. Explicit namespace configuration (highest priority)
2. Parent namespace configuration (inherited)
3. Global log level (fallback)

**Examples:**

```ocaml
(* Example 1: Global configuration *)
Flo.set_level Severity.Info;
(* Effective levels:
   - telegram.* → Info (global default)
   - All logs at Info or higher are shown
*)

(* Example 2: Parent configuration *)
Flo.set_level Severity.Info;
Flo.set_level_for "telegram.bot" Severity.Debug;
(* Effective levels:
   - telegram.bot → Debug (explicit)
   - telegram.bot.dispatch → Debug (inherited from parent)
   - telegram.bot.middleware → Debug (inherited from parent)
   - telegram.bot.context → Debug (inherited from parent)
   - telegram.client → Info (global default)
*)

(* Example 3: Child override *)
Flo.set_level Severity.Info;
Flo.set_level_for "telegram.bot" Severity.Debug;
Flo.set_level_for "telegram.bot.dispatch" Severity.Trace;
(* Effective levels:
   - telegram.bot → Debug (explicit)
   - telegram.bot.dispatch → Trace (explicit override)
   - telegram.bot.middleware → Debug (inherited from telegram.bot)
   - telegram.bot.context → Debug (inherited from telegram.bot)
*)

(* Example 4: Silencing verbose component *)
Flo.set_level Severity.Debug;  (* Debug everything *)
Flo.set_level_for "telegram.client.http" Severity.Warn;  (* But silence HTTP *)
(* Effective levels:
   - telegram.* → Debug (global)
   - telegram.client.http → Warn (explicit override to reduce noise)
*)
```

### Component-Specific Logging Details

#### `telegram.client` - Client Operations

- **Info**: Client creation with configuration
- **Debug**: Configuration details (token length, base URL, custom limits)

**When to enable:**
- Debugging client initialization issues
- Verifying configuration

#### `telegram.client.http` - HTTP Operations

- **Debug**: HTTP request/response details (method, URL, headers, body preview)
- **Error**: Connection errors, timeout errors

**When to enable:**
- Debugging API call failures
- Investigating network issues
- Inspecting request/response payloads

**Performance note:** Can be very verbose during high traffic. Use `Warn` in production.

#### `telegram.api` - API Method Calls

- **Debug**: API method calls, success responses
- **Warn**: API errors (error code, description, retry_after)
- **Error**: Connection errors, parse errors

**When to enable:**
- Debugging specific API method failures
- Investigating rate limiting (429 errors)

#### `telegram.api.response` - Response Parsing

- **Debug**: Response parsing (body size)
- **Warn**: Invalid JSON
- **Error**: Decode errors

**When to enable:**
- Debugging unexpected response formats
- Investigating decode errors

#### `telegram.polling` - Long Polling

- **Info**: Polling started, graceful shutdown
- **Debug**: Update fetching, update counts, offset updates
- **Trace**: Offset calculations, deduplication, storage operations
- **Warn**: getUpdates errors (will retry)

**When to enable:**
- Bot not receiving updates
- Debugging update delivery issues
- Investigating duplicate update handling

#### `telegram.webhook` - Webhook Server

- **Info**: Server started/stopped (host, port, path)
- **Debug**: Request received (source IP, method, body preview)
- **Warn**: Validation failures (invalid IP, token)
- **Error**: Parse errors, handler exceptions

**When to enable:**
- Debugging webhook setup
- Investigating request validation issues
- Security monitoring (see rejected requests)

#### `telegram.bot.dispatch` - Event Routing

- **Debug**: Route matching, handler execution, filter evaluation
- **Warn**: No route matched for update
- **Error**: Handler errors

**When to enable:**
- Commands not triggering
- Investigating route matching issues
- Debugging filter predicates

#### `telegram.bot.middleware` - Middleware Execution

- **Debug**: Middleware chain execution, authorization checks, rate limiting
- **Warn**: Middleware rejection, unauthorized access

**When to enable:**
- Debugging authorization issues
- Investigating rate limiting
- Troubleshooting middleware chain

#### `telegram.bot.context` - Context Operations

- **Debug**: Message sending/editing (chat_id, message_id, text length)
- **Error**: Decode errors

**When to enable:**
- Debugging message sending failures
- Investigating reply/send/edit issues

#### `telegram.upload` - File Uploads

- **Info**: Upload started/completed (size, part count)
- **Debug**: Upload progress (every 10%), multipart construction, size checks
- **Warn**: Upload size limit exceeded

**When to enable:**
- Debugging upload failures
- Monitoring upload progress

#### `telegram.download` - File Downloads

- **Info**: Download started/completed (size, duration)
- **Debug**: URL construction, download progress
- **Error**: Download failures, size limit exceeded

**When to enable:**
- Debugging download failures
- Monitoring download progress

#### `telegram.retry` - Retry Logic

- **Debug**: Retry attempts (attempt number, delay, strategy)
- **Trace**: Backoff delay calculations
- **Warn**: Max retries exhausted

**When to enable:**
- Debugging retry behavior
- Investigating backoff strategies
- Monitoring retry exhaustion

#### `telegram.session` - Session Management

- **Debug**: Session operations (get/set/delete), session loaded/saved
- **Trace**: Store size, key counts

**When to enable:**
- Debugging state machines
- Investigating session persistence issues
- Monitoring session storage

#### `telegram.error` - Error Analysis

- **Trace**: Retryability decisions, retry_after extraction
- **Debug**: Retryable error detection

**When to enable:**
- Debugging retry decisions
- Investigating error classification

## Core Modules

### `Telegram.Client`

**Module:** `Telegram.Client`

Client initialization and configuration.

```ocaml
val create : env:Eio.Stdenv.t -> token:string -> ?base_url:string ->
             ?limits:Limits.t -> unit -> t
```

Creates a new Telegram Bot API client.

**Logging:**
- Namespace: `telegram.client`
- Info: Client creation
- Debug: Configuration details

### `Telegram.Api`

**Module:** `Telegram.Api`

Low-level API call interface.

```ocaml
val call_method : Client.t -> method_name:string ->
                  (string * Param.t) list -> (Yojson.Safe.t, Error.t) result
```

**Logging:**
- Namespace: `telegram.api`
- Debug: API calls, success responses
- Warn: API errors
- Error: Connection/parse errors

### `Telegram.Polling`

**Module:** `Telegram.Polling`

Long polling update delivery.

```ocaml
val run : Client.t -> ?config:config ->
          handler:(Types.update -> unit) -> unit
```

**Logging:**
- Namespace: `telegram.polling`
- Info: Polling started, shutdown
- Debug: Update fetching, offset updates
- Trace: Internal state

## Bot DSL

### `Bot.make`

```ocaml
val make : env:Eio.Stdenv.t -> client:Client.t -> 'a t
```

Create a new bot instance.

### `Bot.command`

```ocaml
val command : string -> ?desc:string ->
              ([ `Chat ] Ctx.t -> string list -> (unit, Error.t) result) ->
              'a t -> 'a t
```

Register a command handler.

**Logging:**
- Namespace: `telegram.bot.dispatch`
- Debug: Command matching, handler execution
- Error: Handler errors

### `Bot.Ctx.with_handler_context`

```ocaml
val with_handler_context : 's Ctx.t -> (unit -> 'a) -> 'a
```

Bind handler context (user_id, chat_id, message_id) to fiber-local storage.
All logs within the function will automatically include these fields.

**Usage:**
```ocaml
|> Bot.command "start" (fun ctx _args ->
    Bot.Ctx.with_handler_context ctx (fun () ->
      let open Flo in
      [%log.info "Processing /start command"];
      (* All logs here include user_id, chat_id, message_id *)
      let* () = Bot.Ctx.reply_ ctx "Hello!" in
      [%log.success "Reply sent"];
      Ok ()
    )
  )
```

## Error Handling

### `Telegram.Error`

**Module:** `Telegram.Error`

Error types and analysis.

```ocaml
type t =
  | Http_error of int * string
  | Api_error of { code : int; description : string; parameters : response_parameters option }
  | Decode_error of string
  | Timeout
  | Canceled
  | Not_implemented of string
  | Internal_error of string

val is_retryable : t -> bool
val retry_after : t -> int option
val parameters : t -> response_parameters option
```

**Logging:**
- Namespace: `telegram.error`
- Trace: Retryability decisions, parameter extraction
- Debug: Retryable error detection

**See Also:**
- [LOGGING.md](LOGGING.md) - Comprehensive logging guide
- [examples/recipes/debug_logging.ml](examples/recipes/debug_logging.ml) - Interactive debugging tutorial
