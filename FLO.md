# Flo Logging Integration Plan

This document outlines the complete migration from the current functor-based logging system to the [flo](https://github.com/nexo-tech/flo) library with comprehensive instrumentation.

## Table of Contents

1. [Motivation](#motivation)
2. [Flo Library Deep Dive](#flo-library-deep-dive)
3. [Instrumentation Strategy](#instrumentation-strategy)
4. [Master Checklist](#master-checklist)
5. [Migration Patterns](#migration-patterns)
6. [Best Practices](#best-practices)

---

## Motivation

### Current Problems

1. **Verbose Functor Composition**: Every example requires creating multiple functor instances:
   ```ocaml
   module Verbose_log = Log.Make (Log.Console) (struct let src = "..." let level = Debug end)
   module Verbose_session = Session.Make (Verbose_log)
   module Verbose_polling = Polling.Make (Verbose_log)
   module Verbose_bot = Bot.Make (Verbose_log) (Verbose_session) (Verbose_polling)
   ```

2. **Inconsistent Logging**: Mix of structured logging (`Log.info`), ad-hoc tracing (`Eio.traceln`), and print statements (`Printf.printf`)

3. **Hard to Configure**: Each module needs its own log configuration passed via functor parameters

4. **No Context Propagation**: No automatic request/user context propagation across operations

5. **No Distributed Tracing**: Cannot track requests across components or services

### Benefits of Flo

1. **✨ Zero-Configuration**: Pre-configured singleton, works immediately with `open Flo`
2. **🎯 Type-Safe Structured Logging**: GADT-based Value.t for compile-time safety
3. **🔗 Distributed Tracing**: W3C Trace Context and OpenTelemetry compliance
4. **🧵 Fiber-Local Context**: Automatic context propagation with Eio
5. **🎨 Better Severity Levels**: `Trace`, `Debug`, `Info`, `Success` 🎉, `Warn`, `Error`, `Fatal`
6. **📊 Semantic Conventions**: OpenTelemetry standard attributes via `Flo_semconv`
7. **🔧 PPX Extensions**: Automatic location capture and ergonomic syntax with `ppx_flo`
8. **⚡ Performance**: Async sinks, batching, non-blocking writes
9. **📁 File Rotation**: Built-in size/time-based rotation with retention policies

---

## Flo Library Deep Dive

### Core API

#### 1. Basic Logging (Zero Configuration)

```ocaml
open Flo

(* Works immediately - no setup required! *)
trace "Fine-grained debug information"       (* Severity 1 *)
debug "Debug diagnostic information"          (* Severity 5 *)
info "Informational events"                   (* Severity 9 *)
success "Celebrate when things work! 🎉"     (* Severity 10 - Loguru-inspired *)
warn "Warning conditions"                     (* Severity 13 *)
error "Error events that need attention"      (* Severity 17 *)
fatal "Critical system failures"              (* Severity 21 *)
```

#### 2. Printf-Style Formatting

```ocaml
(* All severity levels support printf-style formatting *)
debugf "Processing user_id=%s chat_id=%s" user_id chat_id
infof "Received update %Ld from %s" update_id username
successf "Sent message in %.2fms" duration_ms
errorf "API error: %s (code=%d)" error_msg code
```

#### 3. Structured Logging with Fields

```ocaml
(* Type-safe structured fields *)
info_fields "Telegram update received" ~fields:[
  ("update_id", Value.int64 update_id);
  ("update_type", Value.string "message");
  ("from_user", Value.string username);
  ("chat_id", Value.int64 chat_id);
]

(* Using semantic conventions *)
info_fields "HTTP API call" ~fields:[
  Flo_semconv.http_method "POST";
  Flo_semconv.http_status_code 200;
  Flo_semconv.http_target "/bot<token>/sendMessage";
  Flo_semconv.duration_ms 42.5;
]
```

#### 4. Fiber-Local Context Propagation

```ocaml
(* Bind context for current fiber - all logs inherit it *)
Flo.bind [
  ("user_id", Value.string "123456");
  ("chat_id", Value.string "789");
  ("update_id", Value.int64 12345L);
]

(* All subsequent logs automatically include user_id, chat_id, update_id *)
info "Processing command"
debug "Validating arguments"
success "Command executed"

(* Scoped context with automatic cleanup *)
Flo.with_user "alice" (fun () ->
  (* All logs in this scope include user_id="alice" *)
  info "User action logged"
)
```

#### 5. Distributed Tracing with Spans

```ocaml
(* Create span hierarchy for request tracing *)
Flo.with_span "handle_update" (fun () ->
  info "Update received";

  (* Nested span - inherits trace_id, new span_id *)
  Flo.with_span "process_command" (fun () ->
    debug "Parsing command";
    success "Command processed"
  );

  success "Update handled"
)

(* More control with Flo_structured *)
Flo_structured.in_span "send_message" (fun span ->
  let trace_id = Flo_structured.span_trace_id span in
  let span_id = Flo_structured.span_id span in

  debug_fields "Span info" ~fields:[
    ("trace_id", Value.string trace_id);
    ("span_id", Value.string span_id);
  ];

  (* do work *)
  success "Message sent"
)
```

#### 6. PPX Extensions (Automatic Location Capture)

```ocaml
(* Add (preprocess (pps ppx_flo)) to dune file *)

(* Automatic file, line, column, module name capture *)
[%log.info "Bot started"]
(* Expands to: Flo.info ~location:(Location.make_full ...) "Bot started" *)

(* Structured logging with variables - PPX handles type conversion! *)
let user_id = "alice" in
let count = 42 in
[%log.info "Processing" ~user_id ~count]
(* Variables automatically converted to Value.t *)

(* Span annotation *)
let result = [%span
  begin
    [%log.info "Computing result"];
    expensive_computation ()
  end
]
(* Automatic span creation, timing, and cleanup *)
```

#### 7. Semantic Conventions (OpenTelemetry Standard)

```ocaml
(* Flo_semconv provides OpenTelemetry standard attribute names *)

(* Service attributes *)
Flo_semconv.service_name "telegram-bot"
Flo_semconv.service_version "1.0.0"
Flo_semconv.deployment_environment "production"

(* User attributes *)
Flo_semconv.user_id user_id
Flo_semconv.user_name username
Flo_semconv.user_email email

(* HTTP attributes *)
Flo_semconv.http_method "POST"
Flo_semconv.http_status_code 200
Flo_semconv.http_url "https://api.telegram.org/bot.../sendMessage"

(* Error attributes *)
Flo_semconv.error_type "ApiError"
Flo_semconv.error_message error_msg
Flo_semconv.error_stack_trace (Printexc.get_backtrace ())

(* Performance attributes *)
Flo_semconv.duration_ms 42.5
Flo_semconv.duration 0.0425

(* Session/Request attributes *)
Flo_semconv.session_id session_id
Flo_semconv.request_id request_id
```

#### 8. Configuration

```ocaml
(* Set global minimum log level *)
Flo.set_level Severity.Debug   (* Development: show Debug and above *)
Flo.set_level Severity.Info    (* Production: show Info and above *)
Flo.set_level Severity.Warn    (* High-traffic: show Warn and above *)

(* Get current level *)
let current = Flo.get_level () in
Printf.printf "Current level: %s\n" (Severity.to_string current)
```

---

## Instrumentation Strategy

### Telegram Bot Event Taxonomy

We'll instrument the bot with semantic, structured logging at every layer:

```
┌─────────────────────────────────────────────────────────┐
│ Layer 1: Transport (HTTP, Polling, Webhook)            │
├─────────────────────────────────────────────────────────┤
│ Layer 2: Protocol (Update parsing, API calls)          │
├─────────────────────────────────────────────────────────┤
│ Layer 3: Bot Framework (Routing, Context, Session)     │
├─────────────────────────────────────────────────────────┤
│ Layer 4: Handlers (Commands, Messages, Callbacks)      │
└─────────────────────────────────────────────────────────┘
```

### Log Level Strategy

| Level | Use Case | Examples |
|-------|----------|----------|
| **Trace** | Fine-grained internal state | Deduplication checks, offset storage, retry backoff calculation |
| **Debug** | Development diagnostics | Update JSON parsing, session state changes, context binding |
| **Info** | Normal operations | Update received, command executed, message sent, polling started |
| **Success** | Positive outcomes | Command completed successfully, file uploaded, payment processed |
| **Warn** | Recoverable issues | Retry attempt, rate limit approaching, deprecated API used |
| **Error** | Errors needing attention | API error, parse failure, handler exception |
| **Fatal** | Critical failures | Bot startup failure, invalid token, unrecoverable error |

### Context Binding Patterns

Every bot handler should bind context at entry:

```ocaml
|> Bot.command "start" (fun ctx _args ->
    (* PATTERN 1: Bind context at handler entry *)
    let user_id = match Ctx.user ctx with
      | Some u -> Id.to_string u.id
      | None -> "unknown"
    in
    let chat_id = Id.to_string (Ctx.chat ctx) in

    Flo.bind [
      ("handler", Value.string "command");
      ("command", Value.string "start");
      ("user_id", Value.string user_id);
      ("chat_id", Value.string chat_id);
    ];

    (* All logs now include handler, command, user_id, chat_id *)
    info "Processing /start command";

    (* Handler logic *)
    match Ctx.reply_ ctx "👋 Hello!" with
    | Ok () ->
        success "Welcome message sent"
        Ok ()
    | Error err ->
        error_fields "Failed to send message" ~fields:[
          Flo_semconv.error_type "ReplyError";
          Flo_semconv.error_message (Format.asprintf "%a" Error.pp err);
        ];
        Error err
  )
```

### Span Hierarchy for Requests

Use spans to create distributed traces across operations:

```ocaml
(* Top-level span for entire update *)
Flo.with_span "handle_update" (fun () ->
  Flo.bind [
    ("update_id", Value.int64 update_id);
    ("update_type", Value.string "message");
  ];

  info "Update received";

  (* Nested span for routing *)
  Flo.with_span "route_update" (fun () ->
    debug "Matching routes";
    (* routing logic *)
  );

  (* Nested span for handler execution *)
  Flo.with_span "execute_handler" (fun () ->
    (* Handler span *)
    Flo.with_span "command_start" (fun () ->
      debug "Executing /start command";

      (* Nested span for API call *)
      Flo.with_span "api_send_message" (fun () ->
        info_fields "Sending message" ~fields:[
          Flo_semconv.http_method "POST";
          ("method", Value.string "sendMessage");
        ];
        (* API call *)
        success "Message sent"
      )
    )
  );

  success "Update handled"
)
```

### Custom Semantic Conventions for Telegram

Define domain-specific attributes:

```ocaml
(* lib/flo_telegram.ml - Telegram-specific semantic conventions *)
module Flo_telegram = struct
  open Flo

  (* Update attributes *)
  let update_id id = ("telegram.update.id", Value.int64 id)
  let update_type t = ("telegram.update.type", Value.string t)

  (* User attributes *)
  let user_id id = ("telegram.user.id", Value.string id)
  let username u = ("telegram.user.username", Value.string u)
  let user_first_name n = ("telegram.user.first_name", Value.string n)
  let user_is_bot b = ("telegram.user.is_bot", Value.bool b)

  (* Chat attributes *)
  let chat_id id = ("telegram.chat.id", Value.string id)
  let chat_type t = ("telegram.chat.type", Value.string t)
  let chat_title t = ("telegram.chat.title", Value.string t)

  (* Message attributes *)
  let message_id id = ("telegram.message.id", Value.string id)
  let message_text t = ("telegram.message.text", Value.string t)
  let message_type t = ("telegram.message.type", Value.string t)

  (* Command attributes *)
  let command_name cmd = ("telegram.command.name", Value.string cmd)
  let command_args args = ("telegram.command.args", Value.int (List.length args))

  (* API method attributes *)
  let api_method m = ("telegram.api.method", Value.string m)
  let api_response_ok ok = ("telegram.api.response.ok", Value.bool ok)

  (* Bot attributes *)
  let bot_username u = ("telegram.bot.username", Value.string u)
  let bot_id id = ("telegram.bot.id", Value.string id)
end
```

---

## Master Checklist

### Phase 1: Dependencies & Setup
- [x] **Task 1.1**: Add flo to dune-project and opam files
  - Add `(flo (>= 0.1.0))` to dependencies
  - Add `(ppx_flo (>= 0.1.0))` for PPX extensions
- [x] **Task 1.2**: Update src/dune to include flo library
  - Add `flo` to libraries list
  - Add `(preprocess (pps ppx_flo))` for PPX support
- [x] **Task 1.3**: Install flo and verify compilation
  - Run `opam pin add flo ./flo && opam pin add ppx_flo ./flo`
  - Verify with `dune build src/telegram.cma src/tg.cma`
- [x] **Task 1.4**: Create src/flo_telegram.ml with custom semantic conventions
  - Define Telegram-specific attribute helpers
  - Export via src/dune

### Phase 2: Library Core Refactoring (Internal Modules)
- [x] **Task 2.1**: Refactor src/http.ml
  - Remove `Log.Make` functor
  - Add `open Flo` at top
  - Replace `Log.debug` → `Flo.debugf`
  - Add structured fields for HTTP requests
- [x] **Task 2.2**: Refactor src/api.ml
  - Remove `Log.Make` functor
  - Use `Flo.with_span "api_call"` for each method call
  - Add semantic conventions for HTTP method, status, duration
  - Bind `api_method` to context
- [x] **Task 2.3**: Refactor src/retry.ml
  - Remove `Log.Make` functor
  - Use `Flo.debug` for retry attempts
  - Use `Flo.warn` for backoff delays
  - Add structured fields: attempt, max_attempts, delay_ms
- [x] **Task 2.4**: Refactor src/error.ml
  - Remove `Log.Make` functor
  - Use `Flo.error_fields` with semantic conventions
  - Add error_type, error_message fields
- [x] **Task 2.5**: Refactor src/download.ml
  - Remove `Log.Make` functor
  - Use `Flo.with_span "download_file"` for downloads
  - Add file_id, file_size, duration_ms fields
  - Use `success` for successful downloads
- [x] **Task 2.6**: Refactor src/upload.ml
  - Remove `Log.Make` functor
  - Use `Flo.with_span "upload_file"` for uploads
  - Add filename, file_size, mime_type fields
  - Use `success` for successful uploads
- [x] **Task 2.7**: Refactor src/webhook.ml
  - Remove `Log.Make` functor
  - Use `Flo_eio.with_http_context` to extract trace headers
  - Add HTTP semantic conventions
  - Bind webhook-specific context
- [x] **Task 2.8**: Remove src/log.ml and src/log.mli entirely
  - Delete files
  - Remove from dune modules list

### Phase 3: Session Module Defunctorization
- [x] **Task 3.1**: Update src/session.ml
  - Remove `Log` functor parameter from `Make`
  - Add `open Flo` at top
  - Replace all `Log.*` calls with `Flo.*`
  - Use `trace` for low-level session operations
  - Use `debug` for session state changes
- [x] **Task 3.2**: Update src/session.mli
  - Remove `Log.S` from signature
  - Update documentation to mention flo
  - Simplify `Make` functor (no logging param)
- [x] **Task 3.3**: Create Session module without functor wrapper
  - Export `Session` directly instead of via functor

### Phase 4: Polling Module Defunctorization
- [x] **Task 4.1**: Update src/polling.ml
  - Remove `Log` functor parameter from `Make`
  - Add `open Flo` at top
  - Use `Flo.with_span "polling_cycle"` for each getUpdates call
  - Bind offset, timeout, limit to context
  - Use `info` for updates received
  - Use `debug` for deduplication checks
  - Use `trace` for offset storage
- [x] **Task 4.2**: Update src/polling.mli
  - Remove `Log.S` from signature
  - Simplify `Make` functor
- [x] **Task 4.3**: Add comprehensive logging
  - Log polling start with configuration
  - Log each update batch received
  - Log update processing errors
  - Use semantic conventions for duration, count

### Phase 5: Bot Module Defunctorization
- [x] **Task 5.1**: Update src/bot.ml
  - Remove `Log`, `Session`, `Polling` functor parameters
  - Add `open Flo` at top
  - Use `Flo.with_span "dispatch_update"` for routing
  - Bind update context at dispatch entry
  - Use `info` for successful routing
  - Use `warn` for no route matched
  - Use `error` for handler exceptions
- [x] **Task 5.2**: Add context binding in Bot.Ctx
  - Helper to bind user/chat/message context automatically
  - Call at start of every handler
- [x] **Task 5.3**: Update src/bot.mli
  - Remove functor parameters
  - Simplify API
- [x] **Task 5.4**: Create simple Bot.make function
  - No functors, just direct instantiation
  - Example: `Bot.make ~env ~client`
- [x] **Task 5.5**: Add handler instrumentation helpers
  - `Bot.with_handler_context : ctx -> (unit -> 'a) -> 'a`
  - Automatically binds user, chat, message context

### Phase 6: Basic Examples (8 examples)
- [ ] **Task 6.1**: examples/basic/hello_world.ml
  - Remove all functor composition (4 modules → 0)
  - Replace `Eio.traceln` with `[%log.info]` (PPX)
  - Use `Flo.with_span "handle_start"` for command
  - Bind user_id, chat_id at handler entry
  - Use `success` for successful message send
  - Use `info` for bot startup
  - Set `Flo.set_level Severity.Debug` for verbose mode
- [ ] **Task 6.2**: examples/basic/echo_bot.ml
  - Remove `Eio.traceln` calls
  - Use `[%log.info "Echo message" ~user_id ~text_length]`
  - Bind chat context at message handler
  - Use structured fields for message metadata
- [ ] **Task 6.3**: examples/basic/echo_enhanced.ml
  - Remove functor composition
  - Use `Flo.with_span "echo_enhanced"` for request flow
  - Add entity parsing logging
  - Use semantic conventions
- [ ] **Task 6.4**: examples/basic/command_bot.ml
  - Replace ALL `Printf.printf` with `Flo.info`
  - Replace ALL `Printf.eprintf` with `Flo.error`
  - Use `[%log.info "Command" ~command ~args]` with PPX
  - Add span for each command execution
  - Use `success` for successful command completion
- [ ] **Task 6.5**: examples/basic/command_tutorial.ml
  - Remove functor composition
  - Add comprehensive logging for tutorial flow
  - Use PPX for location capture
  - Demonstrate debug/info/success levels
- [ ] **Task 6.6**: examples/basic/keyboard_bot.ml
  - Add logging for button callbacks
  - Use structured fields: callback_data, button_text
  - Use `success` for callback handled
- [ ] **Task 6.7**: examples/basic/file_bot.ml
  - Add span for file upload/download
  - Log file_id, file_size, mime_type
  - Use `success` for successful transfer
  - Use `error` for file errors
- [ ] **Task 6.8**: examples/basic/core_concepts_demo.ml
  - Remove functor composition
  - Demonstrate ALL flo features:
    - Basic logging (all 7 levels)
    - Structured logging with fields
    - Context binding with `Flo.bind`
    - Spans with `Flo.with_span`
    - PPX extensions `[%log.info]`
    - Semantic conventions
    - Log level configuration

### Phase 7: Recipe Examples (12 examples)
- [ ] **Task 7.1-7.12**: Refactor all recipe examples
  - Remove functor composition
  - Use PPX for location capture
  - Add spans for multi-step operations
  - Use semantic conventions
  - Bind context at handler entry
  - Use appropriate severity levels
  - Add error logging with error_fields

### Phase 8: Advanced Examples (22 examples)
- [ ] **Task 8.1-8.22**: Refactor all advanced examples
  - Same pattern as recipes
  - Demonstrate advanced flo features:
    - Nested spans for complex flows
    - Type-safe structured events (STRUCTURED module)
    - Custom semantic conventions
    - Exception handling with `Flo.catch`
    - Performance instrumentation

### Phase 9: PPX Integration
- [ ] **Task 9.1**: Update examples/dune
  - Add `(preprocess (pps ppx_flo))` to all executables
- [ ] **Task 9.2**: Convert high-value logs to PPX
  - Use `[%log.info]` for handler entry/exit
  - Use `[%span]` for expensive operations
  - Keep manual API for dynamic fields

### Phase 10: Documentation Updates
- [ ] **Task 10.1**: Update CONTRIBUTING.md
  - Remove old functor logging section
  - Add flo logging guidelines
  - Document context binding pattern
  - Document semantic conventions usage
  - Add PPX examples
- [ ] **Task 10.2**: Update CLAUDE.md
  - Replace logging patterns with flo
  - Update error handling examples
  - Add context binding to handler template
- [ ] **Task 10.3**: Update .mld documentation files
  - docs/core_concepts.mld: Add logging section
  - docs/getting_started.mld: Show flo setup
  - docs/development_workflow.mld: Logging best practices
- [ ] **Task 10.4**: Update README.md
  - Mention flo in features
  - Show logging example in quick start
  - Link to CONTRIBUTING.md for details
- [ ] **Task 10.5**: Archive archive/LOGGING.md
  - Move to archive/OLD_LOGGING.md
  - Add deprecation notice

### Phase 11: Testing & Verification
- [ ] **Task 11.1**: Compile all library code
  - `dune build @all`
  - Zero warnings
- [ ] **Task 11.2**: Compile all examples
  - `dune build examples/`
  - Zero warnings
- [ ] **Task 11.3**: Run test suite
  - `dune test`
  - 100% passing
- [ ] **Task 11.4**: Manual smoke testing
  - Run hello_world.exe with TELEGRAM_BOT_TOKEN
  - Verify verbose logging output
  - Test all log levels
  - Verify context propagation
  - Verify span tracing
- [ ] **Task 11.5**: Search for remaining old patterns
  - `grep -r "Eio\.traceln" examples/` → should be 0 (or minimal)
  - `grep -r "Printf\.printf" examples/` → should be 0
  - `grep -r "Log\.Make" src/` → should be 0

### Phase 12: Final Cleanup
- [ ] **Task 12.1**: Remove unused functor code
  - Check for any remaining Log.Make patterns
  - Remove unused functor wrappers
- [ ] **Task 12.2**: Verify consistent log levels
  - trace: offset storage, deduplication
  - debug: session changes, parsing
  - info: updates, commands, messages
  - success: successful operations
  - warn: retries, rate limits
  - error: API errors, exceptions
  - fatal: startup failures
- [ ] **Task 12.3**: Create comprehensive logging example
  - examples/advanced/logging_guide.ml
  - Show all flo features
  - Demonstrate best practices
- [ ] **Task 12.4**: Git commit
  - "Migrate from functor logging to flo library"
  - Include comprehensive commit message
  - Reference FLO.md plan

---

## Migration Patterns

### Pattern 1: Simple Log Statement

**Before:**
```ocaml
module Log = Log.Make (Log.Console) (struct
  let src = "MyModule"
  let level = Info
end)

Log.info "Processing started"
```

**After:**
```ocaml
open Flo

info "Processing started"
(* or with PPX: *)
[%log.info "Processing started"]
```

### Pattern 2: Printf-Style Logging

**Before:**
```ocaml
Log.info "User %s sent message: %s" user_id text
Eio.traceln "Received update %Ld" update_id
```

**After:**
```ocaml
infof "User %s sent message: %s" user_id text
debugf "Received update %Ld" update_id
```

### Pattern 3: Structured Logging

**Before:**
```ocaml
Log.info_kv "API call" [
  ("method", "sendMessage");
  ("chat_id", chat_id);
]
```

**After:**
```ocaml
(* Manual API *)
info_fields "API call" ~fields:[
  ("method", Value.string "sendMessage");
  ("chat_id", Value.string chat_id);
]

(* PPX (if variables) *)
[%log.info "API call" ~method_:"sendMessage" ~chat_id]
```

### Pattern 4: Context Binding in Handlers

**Before:**
```ocaml
|> Bot.command "start" (fun ctx _args ->
    Eio.traceln "Received /start";
    (* ... *)
  )
```

**After:**
```ocaml
|> Bot.command "start" (fun ctx _args ->
    (* Bind context at entry *)
    let user_id = match Ctx.user ctx with
      | Some u -> Id.to_string u.id | None -> "unknown"
    in
    Flo.bind [
      ("command", Value.string "start");
      ("user_id", Value.string user_id);
      ("chat_id", Value.string (Id.to_string (Ctx.chat ctx)));
    ];

    [%log.info "Processing /start command"];

    (* All nested logs include context *)
    match Ctx.reply_ ctx "Hello!" with
    | Ok () ->
        [%log.success "Welcome message sent"];
        Ok ()
    | Error err ->
        error_fields "Reply failed" ~fields:[
          Flo_semconv.error_message (Format.asprintf "%a" Error.pp err);
        ];
        Error err
  )
```

### Pattern 5: Span for Multi-Step Operations

**Before:**
```ocaml
let process_order ctx order_id =
  Eio.traceln "Processing order %s" order_id;
  let items = fetch_items ctx order_id in
  Eio.traceln "Fetched %d items" (List.length items);
  let total = calculate_total items in
  Eio.traceln "Total: %.2f" total;
  total
```

**After:**
```ocaml
let process_order ctx order_id =
  Flo.with_span "process_order" (fun () ->
    Flo.bind [("order_id", Value.string order_id)];

    [%log.info "Processing order"];

    let items = Flo.with_span "fetch_items" (fun () ->
      fetch_items ctx order_id
    ) in

    debugf "Fetched %d items" (List.length items);

    let total = Flo.with_span "calculate_total" (fun () ->
      calculate_total items
    ) in

    [%log.success "Order processed" ~total];
    total
  )
```

---

## Best Practices

### 1. Use PPX for Location Capture

✅ **Good:**
```ocaml
[%log.info "Bot started"]
```

❌ **Avoid:**
```ocaml
Flo.info "Bot started"  (* No location info *)
```

### 2. Bind Context at Handler Entry

✅ **Good:**
```ocaml
|> Bot.command "start" (fun ctx _args ->
    Flo.bind [
      ("command", Value.string "start");
      ("user_id", Value.string user_id);
    ];
    (* ... *)
  )
```

❌ **Avoid:**
```ocaml
|> Bot.command "start" (fun ctx _args ->
    (* No context binding - logs lack correlation *)
    info "Processing command"
  )
```

### 3. Use Semantic Conventions

✅ **Good:**
```ocaml
info_fields "HTTP request" ~fields:[
  Flo_semconv.http_method "POST";
  Flo_semconv.http_status_code 200;
  Flo_semconv.duration_ms 42.5;
]
```

❌ **Avoid:**
```ocaml
info_fields "HTTP request" ~fields:[
  ("method", Value.string "POST");        (* Non-standard *)
  ("status", Value.int 200L);             (* Should be http.status_code *)
  ("time", Value.float 42.5);             (* Should be duration_ms *)
]
```

### 4. Use Appropriate Severity Levels

✅ **Good:**
```ocaml
trace "Deduplication check: update_id=%Ld" update_id  (* Internal detail *)
debug "Session state changed: key=%s" key              (* Development info *)
info "Update received from user %s" username           (* Normal operation *)
success "Command executed successfully"                (* Positive outcome *)
warn "Retry attempt %d of %d" attempt max_retries     (* Recoverable issue *)
error "API call failed: %s" error_msg                  (* Error needing attention *)
fatal "Bot startup failed: invalid token"              (* Critical failure *)
```

❌ **Avoid:**
```ocaml
info "Checking deduplication window"  (* Too verbose, use trace *)
error "Command executed"               (* Not an error, use success *)
debug "Bot startup failed"             (* Critical, use fatal *)
```

### 5. Use Spans for Multi-Step Operations

✅ **Good:**
```ocaml
Flo.with_span "handle_payment" (fun () ->
  let validated = Flo.with_span "validate_payment" (fun () -> ... ) in
  let charged = Flo.with_span "charge_card" (fun () -> ... ) in
  let receipt = Flo.with_span "send_receipt" (fun () -> ... ) in
  (validated, charged, receipt)
)
```

❌ **Avoid:**
```ocaml
(* No spans - can't trace operation hierarchy *)
let validated = validate_payment () in
let charged = charge_card () in
let receipt = send_receipt () in
```

### 6. Set Log Level Appropriately

**Development:**
```ocaml
Flo.set_level Severity.Debug  (* See debug logs *)
Flo.set_level Severity.Trace  (* See everything *)
```

**Production:**
```ocaml
Flo.set_level Severity.Info  (* Normal verbosity *)
Flo.set_level Severity.Warn  (* High-traffic services *)
```

### 7. Use Custom Semantic Conventions

✅ **Good:**
```ocaml
(* Define in src/flo_telegram.ml *)
info_fields "Telegram update" ~fields:[
  Flo_telegram.update_id update_id;
  Flo_telegram.update_type "message";
  Flo_telegram.user_id user_id;
  Flo_telegram.chat_id chat_id;
]
```

❌ **Avoid:**
```ocaml
(* Ad-hoc field names - inconsistent *)
info_fields "Update" ~fields:[
  ("upd_id", Value.int64 update_id);
  ("kind", Value.string "message");
  ("from", Value.string user_id);
]
```

---

## Success Criteria

✅ All tasks in master checklist completed
✅ Zero compilation warnings
✅ 100% test suite passing
✅ All examples compile and run
✅ All `Eio.traceln` replaced with flo
✅ All `Printf.printf/eprintf` in examples replaced
✅ All functors removed from Bot, Session, Polling
✅ Context binding in all handlers
✅ Spans for multi-step operations
✅ Semantic conventions used consistently
✅ PPX enabled in examples
✅ Documentation updated
✅ Logging guide example created

---

## References

- **Flo Repository**: https://github.com/nexo-tech/flo
- **Flo API Reference**: flo/API_REFERENCE.md
- **Flo Tutorial**: flo/TUTORIAL.md
- **Flo PPX Guide**: flo/PPX_GUIDE.md
- **OpenTelemetry Semantic Conventions**: https://opentelemetry.io/docs/specs/semconv/
- **W3C Trace Context**: https://www.w3.org/TR/trace-context/
