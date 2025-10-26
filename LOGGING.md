# Logging Guide

This guide provides comprehensive documentation on logging in ocaml-telegram-eio.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Namespace Hierarchy](#namespace-hierarchy)
- [Configuration](#configuration)
- [Troubleshooting Guide](#troubleshooting-guide)
- [Performance Considerations](#performance-considerations)
- [Best Practices](#best-practices)
- [Advanced Usage](#advanced-usage)

## Overview

ocaml-telegram-eio uses **namespace-based scoped logging** powered by [Flo](https://github.com/c-cube/ocaml-flo). This approach provides:

- **Fine-grained control**: Enable/disable logs per component
- **Hierarchical namespaces**: Child namespaces inherit from parents
- **Zero overhead when disabled**: Debug logs compiled out when not enabled
- **Structured logging**: All logs use semantic fields (OpenTelemetry compatible)
- **Context propagation**: User/chat/message context automatically bound to logs

### Design Philosophy

By default:
- **Library internals** log at `Debug` level (hidden unless explicitly enabled)
- **User-facing events** log at `Info` level (visible by default)
- **Errors** log at `Warn` or `Error` level (always visible)

This means applications see important events without being flooded with internal details.

## Quick Start

### Basic Setup

```ocaml
(* examples/basic/echo_bot.ml *)

(* Set global log level to Info - hides debug logs *)
let () = Flo.set_level Severity.Info

let () =
  Eio_main.run @@ fun env ->
    let client = Telegram.Client.create ~env ~token () in
    (* You'll see Info/Warn/Error logs, but not Debug logs *)
    Bot.make ~env ~client
    |> Bot.command "start" (fun ctx _args ->
        (* ... *)
      )
    |> Bot.run
```

### Enabling Debug Logs

```ocaml
(* Enable debug for ALL telegram library logs *)
let () =
  Flo.set_level Severity.Info;
  Flo.set_level_for "telegram" Severity.Debug

(* Enable debug for SPECIFIC components only *)
let () =
  Flo.set_level Severity.Info;
  Flo.set_level_for "telegram.polling" Severity.Debug;  (* See polling details *)
  Flo.set_level_for "telegram.bot.dispatch" Severity.Debug;  (* See routing *)
```

### Interactive Debugging

Try the interactive debugging tutorial:

```bash
export TELEGRAM_BOT_TOKEN="your_token"
dune exec examples/debug_logging_recipe.exe
```

Use commands like `/debug_polling`, `/debug_sessions`, `/debug_http` to dynamically enable debug logs.

## Namespace Hierarchy

### Complete Namespace Tree

```
telegram                           # Root namespace (all library logs)
│
├── telegram.client                # Client initialization
│   └── telegram.client.http       # HTTP requests/responses
│
├── telegram.api                   # Telegram API calls
│   └── telegram.api.response      # Response parsing
│
├── telegram.polling               # Long polling
│
├── telegram.webhook               # Webhook server
│
├── telegram.bot                   # Bot framework
│   ├── telegram.bot.dispatch      # Event routing
│   ├── telegram.bot.middleware    # Middleware chain
│   └── telegram.bot.context       # Context operations
│
├── telegram.upload                # File uploads
│
├── telegram.download              # File downloads
│
├── telegram.retry                 # Retry logic
│
├── telegram.session               # Session management
│
└── telegram.error                 # Error analysis
```

### Inheritance Rules

Child namespaces inherit log levels from their parents:

```ocaml
(* This enables Debug for ALL bot-related logs *)
Flo.set_level_for "telegram.bot" Severity.Debug;
(*
  Effective levels:
  - telegram.bot → Debug (explicit)
  - telegram.bot.dispatch → Debug (inherited)
  - telegram.bot.middleware → Debug (inherited)
  - telegram.bot.context → Debug (inherited)
*)

(* You can override children to reduce noise *)
Flo.set_level_for "telegram.bot" Severity.Debug;
Flo.set_level_for "telegram.bot.context" Severity.Warn;
(*
  Effective levels:
  - telegram.bot → Debug
  - telegram.bot.dispatch → Debug (inherited)
  - telegram.bot.middleware → Debug (inherited)
  - telegram.bot.context → Warn (explicit override)
*)
```

## Configuration

### Configuration API

```ocaml
(* Set global log level *)
Flo.set_level Severity.Info

(* Set namespace-specific level *)
Flo.set_level_for "telegram.polling" Severity.Debug

(* Clear namespace override - revert to parent/global *)
Flo.clear_level_for "telegram.polling"

(* Available severity levels (lowest to highest) *)
Severity.Trace    (* Very detailed internal state *)
Severity.Debug    (* Internal operations *)
Severity.Info     (* User-visible events *)
Severity.Warn     (* Recoverable errors *)
Severity.Error    (* Critical errors *)
```

### Common Configurations

#### Development Mode (Verbose)

```ocaml
let () =
  (* See everything *)
  Flo.set_level_for "telegram" Severity.Debug
```

#### Production Mode (Quiet)

```ocaml
let () =
  (* Only important events and errors *)
  Flo.set_level Severity.Info;
  (* Optionally reduce HTTP noise *)
  Flo.set_level_for "telegram.client.http" Severity.Warn
```

#### Debugging Specific Issue

```ocaml
let () =
  Flo.set_level Severity.Info;  (* Default *)

  (* Enable debug only for the problematic component *)
  Flo.set_level_for "telegram.polling" Severity.Debug
```

## Troubleshooting Guide

### Bot Not Responding to Commands

**Symptoms:**
- Sending commands to bot, but nothing happens
- No errors in logs

**Diagnosis:**
Enable debug for bot dispatch:

```ocaml
Flo.set_level_for "telegram.bot.dispatch" Severity.Debug
```

**Look for:**
- "Trying route" - Is the command route being tried?
- "Route matched" - Is the route matching the update?
- "Handler executing" - Is the handler being called?
- "Handler returned Error" - Is the handler failing?

**Common causes:**
1. Route pattern doesn't match (check command name)
2. Handler throwing exception (check error logs)
3. Update not arriving (enable `telegram.polling` debug)

### Polling Not Receiving Updates

**Symptoms:**
- Bot doesn't receive any messages
- Polling appears to be running

**Diagnosis:**
Enable debug for polling:

```ocaml
Flo.set_level_for "telegram.polling" Severity.Debug
```

**Look for:**
- "Received updates" - Are updates arriving? (count, update_ids)
- "getUpdates error" - Are API calls failing?
- "Offset calculation" (Trace level) - Is offset advancing?

**Common causes:**
1. Another bot instance consuming updates (check offset)
2. Network issues (enable `telegram.client.http` debug)
3. Invalid token (check connection errors)

### API Calls Failing

**Symptoms:**
- sendMessage, getMe, or other API calls returning errors
- Random failures or timeouts

**Diagnosis:**
Enable debug for HTTP and API:

```ocaml
Flo.set_level_for "telegram.client.http" Severity.Debug;
Flo.set_level_for "telegram.api" Severity.Debug
```

**Look for:**
- "HTTP request started" - What's the URL? Headers?
- "Telegram API returned error" - What's the error code? Description?
- "HTTP request timeout" - Network issues?

**Common causes:**
1. Rate limiting (429 error) - Look for retry_after
2. Invalid parameters (400 error) - Check request payload
3. Network issues - Check timeouts and connection errors
4. Invalid token (401 error) - Verify TELEGRAM_BOT_TOKEN

### State Machine Not Persisting

**Symptoms:**
- State resets between messages
- Session data disappearing

**Diagnosis:**
Enable debug for sessions:

```ocaml
Flo.set_level_for "telegram.session" Severity.Debug
```

**Look for:**
- "Session key access: operation=get" - Is state being retrieved?
- "Session state modified: operation=set" - Is state being saved?
- "Session loaded" - Are sessions being loaded for the user?

**Common causes:**
1. Not using same session store instance
2. User ID mismatch (check user_id in logs)
3. Key name mismatch (check key_id)

### File Upload/Download Failures

**Symptoms:**
- Files not uploading or downloading
- Size limit errors

**Diagnosis:**
Enable debug for uploads/downloads:

```ocaml
Flo.set_level_for "telegram.upload" Severity.Debug;
Flo.set_level_for "telegram.download" Severity.Debug
```

**Look for:**
- "Upload started" - What's the size? Part count?
- "Upload exceeds size limit" - Is file too large?
- "Download URL constructed" - Is URL correct?
- "Download size limit exceeded" - Is response too large?

### Middleware Rejection

**Symptoms:**
- Handlers not executing
- Logs show middleware rejection

**Diagnosis:**
Enable debug for middleware:

```ocaml
Flo.set_level_for "telegram.bot.middleware" Severity.Debug
```

**Look for:**
- "Middleware.before" - Which middleware is running?
- "Middleware rejected request" - Which middleware rejected? Why?
- "Authorization check failed" - Missing user? Missing permissions?

## Performance Considerations

### Runtime Overhead

**When logs are DISABLED (default):**
- Near-zero overhead
- Debug log calls are cheaply skipped
- No string formatting or field allocation

**When logs are ENABLED:**
- Small overhead from log formatting
- Structured field allocation
- I/O operations (writing to stdout/stderr)

### Production Recommendations

#### 1. Keep Default Level at Info

```ocaml
(* Production config *)
let () = Flo.set_level Severity.Info
```

This hides internal debug logs while showing important events.

#### 2. Reduce HTTP Noise

HTTP logging can be extremely verbose during high traffic:

```ocaml
let () =
  Flo.set_level Severity.Info;
  (* Only log HTTP warnings and errors *)
  Flo.set_level_for "telegram.client.http" Severity.Warn
```

#### 3. Avoid Trace Level in Production

Trace logs are extremely detailed and can impact performance:

```ocaml
(* DON'T do this in production *)
Flo.set_level_for "telegram" Severity.Trace
```

#### 4. Enable Debug Temporarily

If you need to debug production issues, enable debug for specific components only:

```ocaml
(* Debugging polling issues in production *)
Flo.set_level Severity.Info;  (* Keep default *)
Flo.set_level_for "telegram.polling" Severity.Debug;  (* Enable only polling *)
```

### Dynamic Log Level Adjustment

You can change log levels at runtime without restarting:

```ocaml
|> Bot.command "debug_on" (fun ctx _args ->
    (* Admin-only command to enable debug *)
    Flo.set_level_for "telegram" Severity.Debug;
    reply_ ctx "Debug enabled"
  )

|> Bot.command "debug_off" (fun ctx _args ->
    Flo.set_level Severity.Info;
    Flo.clear_level_for "telegram";
    reply_ ctx "Debug disabled"
  )
```

See [examples/recipes/debug_logging.ml](examples/recipes/debug_logging.ml) for a complete interactive debugging example.

## Best Practices

### 1. Use Structured Logging in Handlers

Always use `Bot.Ctx.with_handler_context` to bind user/chat/message context:

```ocaml
|> Bot.command "start" (fun ctx _args ->
    Bot.Ctx.with_handler_context ctx (fun () ->
      let open Flo in
      [%log.info "Processing /start command"];
      (* All logs here include user_id, chat_id, message_id *)
      let* () = reply_ ctx "Hello!" in
      [%log.success "Reply sent"];
      Ok ()
    )
  )
```

### 2. Start with Global Info, Enable Debug Selectively

```ocaml
(* Good: Start conservative, enable as needed *)
let () =
  Flo.set_level Severity.Info;  (* Default *)
  (* Enable debug for specific components when debugging *)
  (* Flo.set_level_for "telegram.polling" Severity.Debug; *)
```

```ocaml
(* Bad: Enable everything by default *)
let () =
  Flo.set_level_for "telegram" Severity.Debug  (* Too verbose! *)
```

### 3. Use Hierarchical Configuration

Take advantage of namespace inheritance:

```ocaml
(* Good: Enable entire subsystem *)
Flo.set_level_for "telegram.bot" Severity.Debug;
(* ↑ Enables dispatch, middleware, AND context *)

(* Then override specific children to reduce noise *)
Flo.set_level_for "telegram.bot.context" Severity.Warn;
```

### 4. Match Logs to Development Workflow

**During development:**
```ocaml
(* See everything you're working on *)
Flo.set_level_for "telegram.bot" Severity.Debug;
Flo.set_level_for "telegram.session" Severity.Debug;
```

**During testing:**
```ocaml
(* Quiet, but show errors *)
Flo.set_level Severity.Warn;
```

**In production:**
```ocaml
(* Important events only *)
Flo.set_level Severity.Info;
```

### 5. Document Your Logging Configuration

Add comments explaining why specific namespaces are enabled:

```ocaml
let () =
  Flo.set_level Severity.Info;

  (* Enable session debug - debugging state machine issue #123 *)
  Flo.set_level_for "telegram.session" Severity.Debug;

  (* Reduce HTTP noise - too verbose in production *)
  Flo.set_level_for "telegram.client.http" Severity.Warn;
```

## Advanced Usage

### Conditional Debug Logging

Enable debug only in development:

```ocaml
let () =
  let is_dev = Sys.getenv_opt "ENV" = Some "development" in
  Flo.set_level Severity.Info;
  if is_dev then
    Flo.set_level_for "telegram" Severity.Debug
```

### Per-User Debug Mode

Enable debug for specific users:

```ocaml
let debug_users = [123456789L; 987654321L]  (* Admin user IDs *)

|> Bot.middleware (Middleware.make
    ~before:(fun ctx ->
      match ctx.user with
      | Some u when List.mem u.id debug_users ->
          (* Enable debug for admin users *)
          Flo.set_level_for "telegram.bot.dispatch" Severity.Debug;
          Ok ctx
      | _ -> Ok ctx
    )
    "admin_debug"
  )
```

### Structured Logging with Custom Fields

Use Flo's structured logging in your handlers:

```ocaml
|> Bot.command "process" (fun ctx args ->
    Bot.Ctx.with_handler_context ctx (fun () ->
      let open Flo in

      [%log.info "Processing data" ~fields:[
        ("args_count", Value.int (List.length args));
        ("timestamp", Value.float (Unix.gettimeofday ()));
      ]];

      (* ... processing ... *)

      [%log.success "Processing complete" ~fields:[
        ("duration_ms", Value.float duration);
      ]];

      Ok ()
    )
  )
```

### Log Filtering by Severity

Flo supports filtering logs by severity. Use this to create different outputs:

```ocaml
(* Log errors to a file, everything else to console *)
let () =
  (* This would require custom Flo configuration *)
  (* See Flo documentation for advanced filtering *)
```

## See Also

- [API_REFERENCE.md](API_REFERENCE.md) - Complete namespace reference
- [examples/recipes/debug_logging.ml](examples/recipes/debug_logging.ml) - Interactive debugging tutorial
- [LOG_SCOPED.md](LOG_SCOPED.md) - Migration plan and implementation details
- [Flo Documentation](https://c-cube.github.io/ocaml-flo/) - Underlying logging library

## FAQ

**Q: Why don't I see any debug logs?**

A: Debug logs are hidden by default. Enable them with:
```ocaml
Flo.set_level_for "telegram" Severity.Debug
```

**Q: How do I see HTTP request/response payloads?**

A: Enable debug for HTTP:
```ocaml
Flo.set_level_for "telegram.client.http" Severity.Debug
```

**Q: Can I change log levels at runtime?**

A: Yes! Call `Flo.set_level_for` anytime, even from a bot command.

**Q: Do debug logs impact performance when disabled?**

A: No, they have near-zero overhead when disabled.

**Q: How do I log in my own handlers?**

A: Use Flo's ppx syntax:
```ocaml
let open Flo in
[%log.info "My log message"];
[%log.debug "Debug info" ~fields:[("key", Value.string "value")]];
```

**Q: What's the difference between Debug and Trace?**

A: Debug is for internal operations you might need during development. Trace is for extremely detailed internal state (offset calculations, store sizes, etc.).

**Q: Can I send logs to a file instead of stdout?**

A: Yes, but this requires Flo configuration. See Flo documentation for output configuration.
