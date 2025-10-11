# LOGGING.md

**Functor-Based Structured Logging for Bot Observability**

## Overview

Goal: Implement an idiomatic OCaml logging system with functors for modular, structured logging to enable effective debugging of the Telegram bot library.

## Master Checklist

### Phase 1: Core Logging Infrastructure

- [x] Task 1.1: Define logging types and module signatures
  - Created src/log.mli with Backend, Config, and S module types
  - Defined level type: Debug | Info | Warn | Error
  - Added structured logging signatures (debug_kv, info_kv, etc.)
  - Added lazy evaluation signatures (debug', info', etc.)

- [x] Task 1.2: Implement functor-based logger with level filtering
  - Created src/log.ml with Make functor
  - Level filtering logic implemented (level_passes function)
  - Source name injection from Config module
  - Format string support via Format.kasprintf
  - Structured logging helpers (format_kv)
  - Lazy evaluation helpers (debug', info', etc.)
  - Level check helpers (is_debug_enabled, is_info_enabled)
  - Global environment management (set_global_env)

- [x] Task 1.3: Implement Console backend with Eio
  - Console module with Eio.Mutex for thread-safety
  - Colorized output: Debug=dim, Info=default, Warn=yellow, Error=red
  - ISO 8601 timestamps
  - Format: [timestamp] [level] [source] message
  - Writes to Eio.Stdenv.stderr

- [x] Task 1.4: Add structured logging and context support
  - Key-value pair formatting implemented
  - Structured logging functions (debug_kv, info_kv, warn_kv, error_kv)
  - Format: "message [key1=val1, key2=val2]"

### Phase 2: Advanced Backends

- [ ] Task 2.1: Implement File backend with rotation
- [ ] Task 2.2: Implement Structured (JSON Lines) backend
- [ ] Task 2.3: Implement Multi backend for composing multiple backends
- [ ] Task 2.4: Implement Null backend for disabling logging

### Phase 3: Telegram Library Instrumentation

- [x] Task 3.1: Instrument src/client.ml (HTTP client, retries)
  - Instrumented src/http.ml with HTTP logging (request started, completed, failed, timeout)
  - Added request/response headers and body preview logging (debug level)
  - Instrumented src/retry.ml with retry attempt logging
  - Added backoff delay calculation logging
  - Added max retry attempts and non-retryable error logging

- [x] Task 3.2: Instrument src/api.ml (API method calls, responses)
  - Added logging for API method calls (method name)
  - Added logging for method completion (success/error)
  - Added logging for API errors (code, description)
  - Added debug logging for request parameters and response JSON

- [x] Task 3.3: Instrument src/error.ml (error construction, retry decisions)
  - Added logging for retryable error detection (type, retry_after)
  - Added logging for non-retryable errors
  - Added debug logging for is_retryable decision logic
  - Added debug logging for error parameters extraction

- [x] Task 3.4: Instrument src/upload.ml (file uploads, progress)
  - Added logging for upload started (size in bytes)
  - Added logging for upload size limit checks
  - Added debug logging for multipart construction
  - Added progress logging (every 10%)

- [x] Task 3.5: Instrument src/download.ml (file downloads)
  - Added logging for download started (file_path)
  - Added logging for download completed (size, duration)
  - Added logging for download failures
  - Added debug logging for URL construction
  - Added debug logging for download progress

### Phase 4: Polling Instrumentation

- [x] Task 4.1: Instrument src/polling.ml (long polling loop)
  - Added logging for long polling started (timeout, offset)
  - Added logging for received updates (count, update_ids)
  - Added logging for long polling stopped (graceful shutdown initiated/complete)
  - Added warn logging for getUpdates errors (will retry)
  - Added debug logging for each update received (update_id, type)
  - Added debug logging for offset calculation and update

- [x] Task 4.2: Add update deduplication logging
  - Added debug logging for deduplication check (update_id, seen_before)
  - Added debug logging for deduplication window state (size, oldest_id)
  - Added warn logging for duplicate update detected (update_id)

- [x] Task 4.3: Add offset persistence logging
  - Added info logging for offset loaded from storage (offset)
  - Added info logging for offset saved to storage (offset)
  - Added warn logging for failed to load offset (using default)
  - Added debug logging for storage operation details

- [x] Task 4.4: Add shutdown and error handling logging
  - Added info logging for graceful shutdown initiated
  - Added info logging for processing in-flight updates before shutdown
  - Added info logging for shutdown complete
  - Added debug logging for shutdown signal received
  - Added debug logging for update queue drained

### Phase 5: Webhook Instrumentation

- [x] Task 5.1: Instrument src/webhook.ml (HTTP server, request handling)
  - Added info logging for webhook server started (host, port, path)
  - Added info logging for webhook request received (source_ip)
  - Added info logging for update dispatched successfully
  - Added info logging for webhook server stopped
  - Added warn logging for invalid request (wrong method/path)
  - Added debug logging for request headers
  - Added debug logging for request body

- [x] Task 5.2: Add IP validation logging
  - Added warn logging for IP validation failed (source_ip, allowed_ranges)
  - Added debug logging for IP validation check (source_ip, is_allowed)

- [x] Task 5.3: Add secret token validation logging
  - Added warn logging for secret token mismatch (redacted for security)
  - Added debug logging for secret token validation (is_valid)
  - Added debug logging for when no token is configured

- [x] Task 5.4: Add request parsing and error logging
  - Added error logging for JSON parse error (reason, body_preview)
  - Added error logging for update decode error (reason)
  - Added debug logging for Content-Type header check
  - Added warn logging for custom validator rejections

### Phase 6: Bot Core Instrumentation

- [x] Task 6.1: Instrument src/bot.ml dispatch_update (route matching)
  - Added info logging for dispatching update (update_id, type)
  - Added info logging for route matched (route_index)
  - Added info logging for handler execution completed (duration)
  - Added warn logging for no route matched for update
  - Added error logging for handler returned error (Error.t)
  - Added debug logging for trying route (route_index, event_type)
  - Added debug logging for route match result (matched: bool)

- [x] Task 6.2: Instrument command routing and parsing
  - Added info logging for command received (command_name, user_id, args_count)
  - Added debug logging for command parsing (raw_text, entities)
  - Added debug logging for arguments extracted (args)
  - Added debug logging for command name normalization (@botname stripping)

- [x] Task 6.3: Instrument event matching system
  - Added debug logging for Event.match_event called (event_type, update_type)
  - Added debug logging for filter predicate evaluated (result)
  - Logs provided for all event types (Message, Text, Command, etc.)

- [x] Task 6.4: Instrument handler execution and results
  - Added info logging for handler executing (handler_type)
  - Added info logging for handler returned Ok
  - Added error logging for handler returned Error (error_details)
  - Added debug logging for context preparation (has_user, has_chat, has_message)
  - Added debug logging for handler result (Ok | Error)
  - Added warn logging for middleware rejected

### Phase 7: Middleware Instrumentation

- [x] Task 7.1: Instrument middleware execution (before/after/on_error)
- [x] Task 7.2: Instrument session middleware (load/save/access)
- [x] Task 7.3: Instrument rate limiting middleware
- [x] Task 7.4: Instrument authorization middleware

### Phase 8: Session System Instrumentation

- [ ] Task 8.1: Instrument src/session.ml (session operations)
- [ ] Task 8.2: Instrument memory store operations
- [ ] Task 8.3: Add session serialization logging

### Phase 9: Performance and Metrics

- [ ] Task 9.1: Add timing combinators (with_timing)
- [ ] Task 9.2: Add metrics aggregation (counters, histograms)
- [ ] Task 9.3: Add periodic metrics reporting

### Phase 10: Testing and Examples

- [ ] Task 10.1: Create logging tests
- [ ] Task 10.2: Create logging examples
- [ ] Task 10.3: Update documentation and cookbook
- [ ] Task 10.4: Add debugging guide

**Total Tasks**: 40
**Completed**: 25
**In Progress**: 0
**Remaining**: 15
**Progress**: 62.5% (25/40)

---

## Design Philosophy

### Core Principles

1. **Idiomatic OCaml**: Use OCaml conventions and style
2. **Functor-Based**: Logger as module functor for flexibility
3. **Eio-Native**: Built on Eio effects for concurrent logging
4. **Structured**: Support for key-value contexts
5. **Configurable in Code**: No environment variables, pure OCaml configuration
6. **Debug-Focused**: Designed for Claude to debug issues effectively

### Purpose

This logging system exists to help debug:
- Why updates aren't being processed
- Where API calls are failing
- How middleware chains execute
- What data flows through the system
- Performance bottlenecks

## Log Levels (OCaml Style)

```ocaml
type level =
  | Debug     (* Detailed diagnostic information *)
  | Info      (* General informational messages *)
  | Warn      (* Warning messages for potential issues *)
  | Error     (* Error messages for failures *)

(* Level hierarchy: Debug < Info < Warn < Error *)
```

### Level Usage Guidelines

- **Debug**: Detailed diagnostics (HTTP bodies, entity parsing, state dumps)
- **Info**: High-level operations (bot started, command received, API calls)
- **Warn**: Potential issues (rate limits, retries, deprecated usage)
- **Error**: Failures (API errors, handler errors, validation failures)

## Architecture

### Module Signatures

```ocaml
(** Backend signature for implementing log outputs *)
module type Backend = sig
  type t

  val create : Eio.Stdenv.t -> t
  val write : t -> level:level -> src:string -> msg:string -> unit
  val writef : t -> level:level -> src:string -> ('a, Format.formatter, unit, unit) format4 -> 'a
  val close : t -> unit
end

(** Configuration for logger behavior *)
module type Config = sig
  val src : string           (* Source name: "Polling", "Api", etc. *)
  val level : level          (* Minimum level to log *)
end

(** Logger signature - the interface you use *)
module type S = sig
  val debug : ('a, Format.formatter, unit, unit) format4 -> 'a
  val info : ('a, Format.formatter, unit, unit) format4 -> 'a
  val warn : ('a, Format.formatter, unit, unit) format4 -> 'a
  val error : ('a, Format.formatter, unit, unit) format4 -> 'a

  (* Structured logging with key-value pairs *)
  val debug_kv : string -> (string * string) list -> unit
  val info_kv : string -> (string * string) list -> unit
  val warn_kv : string -> (string * string) list -> unit
  val error_kv : string -> (string * string) list -> unit

  (* Lazy evaluation for expensive computations *)
  val debug' : (unit -> string) -> unit
  val info' : (unit -> string) -> unit
  val warn' : (unit -> string) -> unit
  val error' : (unit -> string) -> unit

  (* Check if level is enabled *)
  val is_debug_enabled : unit -> bool
  val is_info_enabled : unit -> bool
end

module Make (B : Backend) (C : Config) : S
```

### Functor Usage

```ocaml
(* Create a logger for a module *)
module Log = Telegram.Log.Make (Telegram.Log.Console) (struct
  let src = "Polling"
  let level = Info
end)

(* Use it *)
let () =
  Log.info "Starting long polling";
  Log.debug "Update received: id=%Ld" update_id;
  Log.warn "Rate limit approaching: %d/%d" current_count limit;
  Log.error "API call failed: %a" Error.pp err
```

## Implementation Plan Details

### Phase 1: Core Logging Infrastructure

- [ ] Task 1.1: Define logging types and signatures
  - Create `src/log.mli` with module types
  - Define `level` type: `Debug | Info | Warn | Error`
  - Define `Backend` signature (write, writef, close)
  - Define `Config` signature (src, level)
  - Define `S` signature (debug, info, warn, error + variants)
  - Add structured logging support with key-value pairs

- [ ] Task 1.2: Implement functor-based logger
  - Create `src/log.ml` with `Make` functor
  - Level filtering logic in functor body
  - Source name injection from Config module
  - Format string support via Format module
  - Structured logging helpers (format_kv)
  - Lazy evaluation helpers (debug', info', etc.)
  - Level check helpers (is_debug_enabled, is_info_enabled)

- [ ] Task 1.3: Implement Console backend (Eio-based)
  - Create `Console` module in `src/log.ml`
  - Use `Eio.Stdenv.t#stderr` for output
  - Colorized output based on level:
    - Debug: dim/gray
    - Info: default
    - Warn: yellow
    - Error: red
  - Thread-safe via Eio.Mutex.t
  - Format: `[timestamp] [level] [source] message`
  - ISO 8601 timestamps

- [ ] Task 1.4: Add structured logging and context support
  - Implement key-value formatting
  - Add context stack for nested operations
  - Support for timing blocks
  - Pretty-printing for common types (Error.t, Id.t, etc.)

### Phase 2: Advanced Backends

- [ ] Task 2.1: Implement File backend with rotation
  - Module: `File` with configurable path
  - Write to file with rotation support
  - Config: `max_size_bytes`, `max_backup_files`
  - No colors in file output
  - Async writes with Eio.Path
  - Rotation on size threshold

- [ ] Task 2.2: Implement Structured (JSON Lines) backend
  - Module: `Json_lines`
  - Output JSON lines format (one JSON per line)
  - Schema: `{timestamp, level, src, msg, kvs}`
  - Compatible with jq, elasticsearch, etc.
  - No color codes in JSON

- [ ] Task 2.3: Implement Multi backend for composing multiple backends
  - Module: `Multi`
  - Combine multiple backends
  - Example: Console + File
  - Each backend receives all log messages
  - Different backends can be configured independently

- [ ] Task 2.4: Implement Null backend for disabling logging
  - Module: `Null`
  - No-op backend for production
  - Zero overhead - all functions are empty

### Phase 3: Telegram Library Instrumentation

- [ ] Task 3.1: Instrument src/client.ml (HTTP client, retries)
  - Create `Client_log` module
  - Info: HTTP request started (method, url)
  - Info: HTTP request completed (status, duration)
  - Warn: Retry attempt (attempt N of M, reason)
  - Error: HTTP request failed (status, error)
  - Debug: Request headers, body preview
  - Debug: Response headers, body preview
  - Debug: Backoff delay calculation

- [ ] Task 3.2: Instrument src/api.ml (API method calls, responses)
  - Create `Api_log` module
  - Info: Telegram method called (name, chat_id if present)
  - Info: Method completed successfully
  - Warn: API returned error response (code, description)
  - Error: Method failed after retries
  - Debug: Full request parameters
  - Debug: Full response JSON
  - Debug: Response parsing and validation

- [ ] Task 3.3: Instrument src/error.ml (error construction, retry decisions)
  - Create `Error_log` module
  - Warn: Retryable error detected (type, retry_after if present)
  - Info: Non-retryable error (type)
  - Debug: Error parameters extraction
  - Debug: is_retryable decision logic

- [ ] Task 3.4: Instrument src/upload.ml (file uploads, progress)
  - Create `Upload_log` module
  - Info: Upload started (file_path, size_bytes)
  - Info: Upload completed (duration, speed_mbps)
  - Warn: Upload exceeds size limit
  - Error: Upload failed (reason)
  - Debug: Multipart construction
  - Debug: Chunk upload progress (every 10%)

- [ ] Task 3.5: Instrument src/download.ml (file downloads)
  - Create `Download_log` module
  - Info: Download started (file_id, destination)
  - Info: Download completed (size_bytes, duration)
  - Error: Download failed (reason)
  - Debug: URL construction
  - Debug: Download progress

### Phase 4: Polling Instrumentation

- [ ] Task 4.1: Instrument src/polling.ml (long polling loop)
  - Create `Polling_log` module
  - Info: Long polling started (timeout, offset)
  - Info: Received updates (count, update_ids)
  - Info: Long polling stopped (reason)
  - Warn: getUpdates error (will retry)
  - Error: Persistent polling failure
  - Debug: Each update received (update_id, type)
  - Debug: Offset calculation and update

- [ ] Task 4.2: Add update deduplication logging
  - Debug: Deduplication check (update_id, seen_before)
  - Debug: Deduplication window state (size, oldest_id)
  - Warn: Duplicate update detected (update_id)

- [ ] Task 4.3: Add offset persistence logging
  - Info: Offset loaded from storage (offset)
  - Info: Offset saved to storage (offset)
  - Warn: Failed to load offset (using default)
  - Debug: Storage operation details

- [ ] Task 4.4: Add shutdown and error handling logging
  - Info: Graceful shutdown initiated
  - Info: Processing in-flight updates before shutdown
  - Info: Shutdown complete
  - Debug: Shutdown signal received
  - Debug: Update queue drained

### Phase 5: Webhook Instrumentation

- [ ] Task 5.1: Instrument src/webhook.ml (HTTP server, request handling)
  - Create `Webhook_log` module
  - Info: Webhook server started (host, port, path)
  - Info: Webhook request received (source_ip)
  - Info: Update dispatched successfully
  - Info: Webhook server stopped
  - Warn: Invalid request (reason)
  - Error: Failed to parse update JSON
  - Debug: Request headers
  - Debug: Request body

- [ ] Task 5.2: Add IP validation logging
  - Warn: IP validation failed (source_ip, allowed_ranges)
  - Debug: IP validation check (source_ip, is_allowed)

- [ ] Task 5.3: Add secret token validation logging
  - Warn: Secret token mismatch (expected vs received)
  - Debug: Secret token validation (is_valid)

- [ ] Task 5.4: Add request parsing and error logging
  - Error: JSON parse error (reason, body_preview)
  - Error: Update decode error (reason)
  - Debug: Content-Type header check

### Phase 6: Bot Core Instrumentation

- [ ] Task 6.1: Instrument src/bot.ml dispatch_update (route matching)
  - Create `Bot_log` module
  - Info: Dispatching update (update_id, type)
  - Info: Route matched (route_index)
  - Info: Handler execution completed (duration)
  - Warn: No route matched for update
  - Error: Handler returned error (Error.t)
  - Debug: Trying route (route_index, event_type)
  - Debug: Route match result (matched: bool)

- [ ] Task 6.2: Instrument command routing and parsing
  - Info: Command received (command_name, user_id, args_count)
  - Debug: Command parsing (raw_text, entities)
  - Debug: Arguments extracted (args)
  - Debug: Command name normalization (@botname stripping)

- [ ] Task 6.3: Instrument event matching system
  - Debug: Event.match_event called (event_type, update_type)
  - Debug: Filter predicate evaluated (predicate_name, result)
  - Debug: Event.when_ combinator (condition_result)

- [ ] Task 6.4: Instrument handler execution and results
  - Info: Handler executing (handler_type)
  - Info: Handler returned Ok
  - Error: Handler returned Error (error_details)
  - Debug: Context preparation (has_user, has_chat, has_message)
  - Debug: Handler result (Ok | Error)

### Phase 7: Middleware Instrumentation

- [x] Task 7.1: Instrument middleware execution (before/after/on_error)
  - Instrumented src/bot.ml dispatch_update function
  - Info: Middleware chain started (middleware_count)
  - Info: Middleware chain completed
  - Debug: Middleware.before (middleware_name)
  - Debug: Middleware.after (middleware_name)
  - Debug: Middleware.on_error (middleware_name, error)
  - Debug: Middleware rejected request (middleware_name, reason)

- [x] Task 7.2: Instrument session middleware (load/save/access)
  - Instrumented src/session.ml
  - Info: Session loaded (user_id, keys_count)
  - Info: Session saved (user_id, keys_count)
  - Debug: Session load failed (user_id, reason=not found, creating new)
  - Debug: Session key access (operation=get, key_id, found)
  - Debug: Session state modified (operation=set|delete, key_id)

- [x] Task 7.3: Instrument rate limiting middleware
  - Instrumented Middleware.rate_limit in src/bot.ml
  - Warn: Rate limit exceeded (user_id, current, limit)
  - Debug: Rate check (user_id, count, limit, window)
  - Debug: Rate counter incremented (user_id, new_count)
  - Debug: Rate limit window expired (user_id, resetting counter)

- [x] Task 7.4: Instrument authorization middleware
  - Instrumented Middleware.only_users, require_user, require_chat in src/bot.ml
  - Warn: Unauthorized access attempt (user_id, required_role)
  - Debug: Authorization check (user_id|chat_id, has_permission)
  - Debug: User whitelist check (user_id, is_allowed)

### Phase 8: Session System Instrumentation

- [ ] Task 8.1: Instrument src/session.ml (session operations)
  - Create `Session_log` module
  - Info: Session created (chat_id)
  - Info: Session deleted (chat_id)
  - Debug: Session.get (chat_id, key)
  - Debug: Session.set (chat_id, key)
  - Debug: Session.delete (chat_id, key)
  - Debug: Session.modify (chat_id, key, has_value)

- [ ] Task 8.2: Instrument memory store operations
  - Debug: Store size (session_count, total_keys)
  - Debug: Store access (chat_id, operation)
  - Debug: Store eviction (chat_id, reason)

- [ ] Task 8.3: Add session serialization logging
  - Warn: Serialization failed (chat_id, key, reason)
  - Warn: Deserialization failed (chat_id, key, reason)
  - Debug: Session encode (chat_id, size_bytes)
  - Debug: Session decode (chat_id, size_bytes)

### Phase 9: Performance and Metrics

- [ ] Task 9.1: Add timing combinators (with_timing)
  - Helper: `with_timing : string -> (unit -> 'a) -> 'a`
  - Logs duration at Debug level
  - Example: "Operation completed in 45ms"
  - Wraps any operation with timing
  - Returns result of wrapped function

- [ ] Task 9.2: Add metrics aggregation (counters, histograms)
  - Module: `Metrics` with aggregation
  - Counter: updates_processed
  - Counter: errors_by_type
  - Counter: commands_by_name
  - Histogram: handler_latency_ms
  - Histogram: api_call_latency_ms
  - Configurable reporting interval

- [ ] Task 9.3: Add periodic metrics reporting
  - Info: Periodic metrics summary (every N minutes)
  - Info: Total counts, percentiles, error rates
  - Debug: Detailed metric breakdowns
  - Configurable report format (text, JSON)

### Phase 10: Testing and Examples

- [ ] Task 10.1: Create logging tests
  - Test level filtering (Debug vs Info vs Warn vs Error)
  - Test functor instantiation with different backends
  - Test structured logging (key-value pairs)
  - Test backend composition (Multi)
  - Test lazy evaluation (debug')

- [ ] Task 10.2: Create logging examples
  - `examples/logging_basic.ml` - Console logging
  - `examples/logging_debug.ml` - Debug level examples
  - `examples/logging_structured.ml` - Structured (kv) logging
  - `examples/logging_custom_backend.ml` - Custom backend

- [ ] Task 10.3: Update documentation and cookbook
  - Add logging section to README.md
  - Add logging patterns to cookbook
  - Best practices for handler logging
  - Performance considerations
  - When to use debug vs info

- [ ] Task 10.4: Add debugging guide
  - How to enable debug logs
  - How to debug specific modules (Polling, Api, etc.)
  - How to trace update flow
  - Common debugging scenarios
  - Production logging recommendations

## Instrumentation Points Summary

### Info Level - High-Level Operations

1. **Bot Lifecycle**
   - Bot started, bot stopped
   - Polling/webhook mode selected
   - Server started/stopped

2. **Request Processing**
   - Update received (update_id, type)
   - Command executed (command, user)
   - Handler completed (duration)
   - Route matched

3. **API Calls**
   - Telegram method called (name, chat_id)
   - HTTP request completed (status, duration)
   - Method succeeded

4. **Sessions**
   - Session loaded/saved (chat_id)
   - Session created/deleted

### Warn Level - Potential Issues

1. **Errors with Recovery**
   - Retry attempts (attempt N of M)
   - Rate limits approaching
   - API errors (will retry)

2. **Validation Failures**
   - Webhook IP validation failed
   - Secret token mismatch
   - Unauthorized access attempts

3. **Data Issues**
   - Session serialization failed
   - Offset load failed (using default)
   - Duplicate update detected

### Error Level - Failures

1. **Handler Errors**
   - Handler returned Error.t
   - Handler execution failed

2. **API Failures**
   - HTTP request failed
   - Method failed after retries
   - Upload/download failed

3. **Parsing Errors**
   - JSON parse error
   - Update decode error

### Debug Level - Detailed Diagnostics

1. **Data Flow**
   - Request/response bodies
   - Entity parsing details
   - Context transformations
   - Full JSON payloads

2. **Execution Details**
   - Route matching attempts
   - Middleware execution (before/after)
   - Session key access
   - Filter predicate evaluation

3. **Performance**
   - Operation timing
   - Backoff delay calculation
   - Progress updates (uploads/downloads)

## Usage Examples

### Basic Usage

```ocaml
(* Create a logger for a module *)
module Log = Telegram.Log.Make (Telegram.Log.Console) (struct
  let src = "MyBot"
  let level = Info
end)

(* Use in your code *)
let start_bot () =
  Log.info "Bot started";
  Log.info "User count: %d" user_count;

  (* Warn about issues *)
  Log.warn "Rate limit approaching: %d/%d" current_count limit;

  (* Error on failures *)
  Log.error "Failed to send message: %a" Telegram.Error.pp err;

  (* Debug for detailed info - only shown if level = Debug *)
  Log.debug "Full update: %s" (Yojson.Safe.to_string json)
```

### Structured Logging

```ocaml
(* Log with key-value pairs for structured data *)
Log.info_kv "user_action" [
  ("user_id", "12345");
  ("action", "button_press");
  ("button_id", "confirm");
  ("timestamp", "2025-01-11T10:30:00Z");
];

(* Debug with structured data *)
Log.debug_kv "api_call" [
  ("method", "sendMessage");
  ("chat_id", "67890");
  ("status", "200");
  ("duration_ms", "145");
]
```

### Lazy Evaluation for Expensive Operations

```ocaml
(* Use primed functions for expensive computations *)
(* Only evaluated if debug level is enabled *)
Log.debug' (fun () ->
  let json = complicated_serialization data in
  Format.asprintf "Full state: %s" json
);

(* Avoid this - always evaluates even if not logged *)
Log.debug "Full state: %s" (complicated_serialization data)
```

### Configuration in Code

```ocaml
(* Production: Info level *)
module Log = Telegram.Log.Make (Telegram.Log.Console) (struct
  let src = "Bot"
  let level = Info
end)

(* Development: Debug level *)
module Log = Telegram.Log.Make (Telegram.Log.Console) (struct
  let src = "Bot"
  let level = Debug
end)

(* Silent: Error only *)
module Log = Telegram.Log.Make (Telegram.Log.Console) (struct
  let src = "Bot"
  let level = Error
end)
```

### Multiple Loggers for Different Modules

```ocaml
(* Polling module with Debug level *)
module Polling_log = Telegram.Log.Make (Telegram.Log.Console) (struct
  let src = "Polling"
  let level = Debug
end)

(* API module with Info level *)
module Api_log = Telegram.Log.Make (Telegram.Log.Console) (struct
  let src = "Api"
  let level = Info
end)

(* Bot module with Info level *)
module Bot_log = Telegram.Log.Make (Telegram.Log.Console) (struct
  let src = "Bot"
  let level = Info
end)
```

### Custom Backend

```ocaml
(* Simple file backend *)
module File_backend : Telegram.Log.Backend = struct
  type t = out_channel

  let create _env =
    open_out_gen [Open_creat; Open_append] 0o644 "bot.log"

  let write t ~level ~src ~msg =
    let timestamp = Unix.gettimeofday () in
    let level_str = match level with
      | Debug -> "DEBUG"
      | Info -> "INFO"
      | Warn -> "WARN"
      | Error -> "ERROR"
    in
    Printf.fprintf t "[%.3f] [%s] [%s] %s\n"
      timestamp level_str src msg;
    flush t

  let writef t ~level ~src fmt =
    let timestamp = Unix.gettimeofday () in
    let level_str = match level with
      | Debug -> "DEBUG"
      | Info -> "INFO"
      | Warn -> "WARN"
      | Error -> "ERROR"
    in
    Printf.fprintf t "[%.3f] [%s] [%s] "
      timestamp level_str src;
    Printf.fprintf t fmt;
    output_char t '\n';
    flush t

  let close t = close_out t
end

(* Use custom backend *)
module Log = Telegram.Log.Make (File_backend) (struct
  let src = "Bot"
  let level = Info
end)
```

### Combining Multiple Backends

```ocaml
(* Multi backend: log to console AND file *)
module Multi = Telegram.Log.Multi.make [
  (module Telegram.Log.Console : Telegram.Log.Backend);
  (module My_file_backend : Telegram.Log.Backend);
]

module Log = Telegram.Log.Make (Multi) (struct
  let src = "Bot"
  let level = Info
end)
```

## Configuration

### Level Configuration

Configure log level per-module using the Config module:

```ocaml
(* Debug: See everything *)
module Log = Telegram.Log.Make (Telegram.Log.Console) (struct
  let src = "Polling"
  let level = Debug  (* Show: Debug, Info, Warn, Error *)
end)

(* Info: Standard operations *)
module Log = Telegram.Log.Make (Telegram.Log.Console) (struct
  let src = "Api"
  let level = Info  (* Show: Info, Warn, Error *)
end)

(* Warn: Only issues *)
module Log = Telegram.Log.Make (Telegram.Log.Console) (struct
  let src = "Bot"
  let level = Warn  (* Show: Warn, Error *)
end)

(* Error: Only failures *)
module Log = Telegram.Log.Make (Telegram.Log.Console) (struct
  let src = "Webhook"
  let level = Error  (* Show: Error only *)
end)
```

### Console Backend Configuration

The Console backend outputs colored logs to stderr:

- **Debug**: dim/gray text
- **Info**: default terminal color
- **Warn**: yellow text
- **Error**: red text

Format: `[timestamp] [level] [source] message`

Example: `[2025-01-11T10:30:15] [INFO] [Polling] Long polling started`

### File Backend Configuration

```ocaml
module File_backend = Telegram.Log.File.make ~path:"bot.log" ~max_size:10_485_760L ~max_files:5

module Log = Telegram.Log.Make (File_backend) (struct
  let src = "Bot"
  let level = Info
end)
```

### JSON Lines Backend Configuration

```ocaml
module Json_backend = Telegram.Log.Json_lines.make ~path:"bot.jsonl"

module Log = Telegram.Log.Make (Json_backend) (struct
  let src = "Bot"
  let level = Info
end)
```

Output format:
```json
{"timestamp":"2025-01-11T10:30:15Z","level":"info","src":"Polling","msg":"Long polling started"}
{"timestamp":"2025-01-11T10:30:16Z","level":"debug","src":"Api","msg":"Request sent","kvs":{"method":"sendMessage","chat_id":"12345"}}
```

## Priority Implementation Order

### High Priority - Foundation (Start Here)
1. **Phase 1**: Core logging infrastructure (Tasks 1.1-1.4)
   - Module signatures, functor, Console backend, structured logging
2. **Phase 3**: Telegram library instrumentation (Tasks 3.1-3.5)
   - client.ml, api.ml, error.ml - the HTTP layer
3. **Phase 4**: Polling instrumentation (Tasks 4.1-4.4)
   - Long polling loop, critical for debugging update flow

### Medium Priority - Visibility (Next)
4. **Phase 6**: Bot core instrumentation (Tasks 6.1-6.4)
   - dispatch_update, command routing, event matching
5. **Phase 7**: Middleware instrumentation (Tasks 7.1-7.4)
   - Middleware chain, session middleware, rate limiting
6. **Phase 2**: File backend (Task 2.1)
   - Persistent logs for production debugging

### Low Priority - Polish (Later)
7. **Phase 5**: Webhook instrumentation (Tasks 5.1-5.4)
   - Webhook server, IP/token validation
8. **Phase 8**: Session system instrumentation (Tasks 8.1-8.3)
   - Session operations, memory store
9. **Phase 9**: Performance and metrics (Tasks 9.1-9.3)
   - Timing, aggregation, periodic reports
10. **Phase 2**: Advanced backends (Tasks 2.2-2.4)
    - JSON Lines, Multi, Null backends
11. **Phase 10**: Testing and examples (Tasks 10.1-10.4)
    - Tests, examples, documentation

## Integration with Existing Code

### No Breaking Changes

- Logging is **opt-in** via functor instantiation
- Existing code continues to work without modification
- Add logging incrementally, one module at a time
- Can configure per-module level (Debug, Info, Warn, Error)

### Migration Path

1. Implement Phase 1 (core logging infrastructure)
2. Instrument src/client.ml first (all HTTP traffic)
3. Instrument src/api.ml (Telegram method calls)
4. Instrument src/polling.ml (update reception)
5. Instrument src/bot.ml (route matching and dispatch)
6. Gradually add logging to other modules as needed

### Adding Logging to a Module

```ocaml
(* At top of module file *)
module Log = Telegram.Log.Make (Telegram.Log.Console) (struct
  let src = "MyModule"
  let level = Info  (* or Debug for development *)
end)

(* Use throughout the module *)
let my_function x =
  Log.info "Function called with x=%d" x;
  Log.debug "Detailed state: %s" (show_state ());
  try
    do_work x
  with exn ->
    Log.error "Function failed: %s" (Printexc.to_string exn);
    raise exn
```

## Performance Considerations

### Zero-Cost When Filtered

```ocaml
(* If level = Info, this debug call has zero cost *)
Log.debug "Expensive: %s" (expensive_computation ());

(* Use lazy evaluation to avoid computing when filtered *)
Log.debug' (fun () ->
  let result = expensive_computation () in
  Format.asprintf "Result: %s" result
);

(* Level check before expensive operations *)
if Log.is_debug_enabled () then
  let data = serialize_everything () in
  Log.debug "Full state: %s" data
```

### Format String Compilation

- Format strings are compiled by OCaml compiler
- No runtime parsing or interpretation
- Type-safe formatting (compiler checks arguments)

### Eio-Based Async Logging

- Backend writes use Eio (non-blocking)
- Logging doesn't block bot message processing
- Thread-safe via Eio.Mutex.t

## Best Practices

### 1. Choose Appropriate Levels

```ocaml
(* Debug: Detailed diagnostics, data dumps *)
Log.debug "Parsed entities: %d" (List.length entities);
Log.debug "Request body: %s" body;

(* Info: High-level operations *)
Log.info "Command received: /%s from user %s" cmd_name username;
Log.info "Long polling started (offset=%Ld)" offset;

(* Warn: Potential issues, will retry *)
Log.warn "Rate limit approaching: %d/%d" current limit;
Log.warn "Retry attempt %d/%d" attempt max_attempts;

(* Error: Failures, need attention *)
Log.error "Handler failed: %a" Telegram.Error.pp err;
Log.error "Upload failed after retries: %s" reason;
```

### 2. Include Context

```ocaml
(* Always include relevant IDs *)
Log.info "Processing update: update_id=%Ld, chat_id=%s"
  update_id (Id.to_string chat_id);

(* Use structured logging for queryable data *)
Log.info_kv "user_action" [
  ("update_id", Int64.to_string update_id);
  ("user_id", user_id);
  ("command", cmd_name);
];
```

### 3. Use Lazy Evaluation

```ocaml
(* BAD: Always evaluates even if not logged *)
Log.debug "Full JSON: %s" (Yojson.Safe.to_string big_json);

(* GOOD: Only evaluates if debug enabled *)
Log.debug' (fun () ->
  Format.asprintf "Full JSON: %s" (Yojson.Safe.to_string big_json)
);
```

### 4. Protect Sensitive Data

```ocaml
(* NEVER log tokens *)
(* BAD: *) Log.debug "Token: %s" bot_token;

(* NEVER log full user messages in production *)
(* OK for debug: *)
if Log.is_debug_enabled () then
  Log.debug "User message: %s" (String.sub text 0 (min 100 (String.length text)))

(* OK: Log message metadata *)
Log.info "Text message received: length=%d, user=%s"
  (String.length text) user_id;
```

### 5. Performance in Hot Paths

```ocaml
(* AVOID: Logging in tight loops *)
List.iter (fun item ->
  Log.info "Processing item: %s" item;  (* Don't do this! *)
  process item
) items;

(* BETTER: Log summary *)
Log.info "Processing %d items" (List.length items);
List.iter process items;
Log.info "Processed all items";

(* OK: Debug level for high-frequency *)
List.iter (fun item ->
  Log.debug "Item: %s" item;  (* Only in debug mode *)
  process item
) items;
```

## Debugging Workflows

### Tracing Update Flow

```ocaml
(* Enable Debug on all relevant modules *)
module Client_log = Telegram.Log.Make (Telegram.Log.Console) (struct let src = "Client"; let level = Debug end)
module Api_log = Telegram.Log.Make (Telegram.Log.Console) (struct let src = "Api"; let level = Debug end)
module Polling_log = Telegram.Log.Make (Telegram.Log.Console) (struct let src = "Polling"; let level = Debug end)
module Bot_log = Telegram.Log.Make (Telegram.Log.Console) (struct let src = "Bot"; let level = Debug end)

(* Now you'll see:
   [Polling] Received update: id=12345
   [Bot] Dispatching update: id=12345
   [Bot] Route matched: route_index=0
   [Api] Method called: sendMessage, chat_id=67890
   [Client] HTTP request: POST https://api.telegram.org/bot.../sendMessage
   [Client] HTTP response: 200 OK
   [Bot] Handler completed in 145ms
*)
```

### Finding API Errors

```ocaml
(* Enable Warn on Api module *)
module Api_log = Telegram.Log.Make (Telegram.Log.Console) (struct let src = "Api"; let level = Warn end)

(* You'll see warnings when API calls fail:
   [Api] API error: code=429, desc="Too Many Requests", retry_after=30
   [Api] Retry attempt 2/3
*)
```

---

## Implementation Notes

- All logging uses Eio effects (non-blocking I/O)
- Functor design enables compile-time optimization
- Level filtering at both compile-time and runtime
- Compatible with existing `Eio.traceln` calls
- No dependencies on environment variables
- Pure OCaml configuration
