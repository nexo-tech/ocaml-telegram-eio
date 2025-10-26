# Scoped Logging Migration Plan

This document outlines the migration from global `Flo` logging to hierarchical namespace-based scoped logging in the Telegram bot library.

## Overview

Flo now supports namespace-based logging with hierarchical level configuration. This allows:
- Library internals to use `Debug` level logging without forcing verbosity on applications
- Applications to control log levels per component (e.g., enable debug for `telegram.polling` but keep `telegram.http` at Info)
- Hierarchical namespace inheritance (e.g., `telegram.client.http` inherits from `telegram.client`)

## Namespace Hierarchy Design

```
telegram                           # Root namespace for all library logs
├── telegram.client                # Client initialization and management
│   ├── telegram.client.http       # HTTP requests/responses (detailed)
│   └── telegram.client.session    # Session management
├── telegram.polling               # Long polling loop
│   ├── telegram.polling.updates   # Update fetching
│   └── telegram.polling.dispatch  # Update dispatching
├── telegram.webhook               # Webhook server
├── telegram.bot                   # Bot routing and handlers
│   ├── telegram.bot.dispatch      # Event routing
│   ├── telegram.bot.middleware    # Middleware execution
│   └── telegram.bot.context       # Context operations
├── telegram.api                   # Generated API calls
├── telegram.upload                # File uploads
├── telegram.download              # File downloads
└── telegram.retry                 # Retry logic
```

## Master Checklist

### Phase 1: Infrastructure & Configuration

- [x] Task 1.1: Pin flo to latest commit with scoped logging support
  - Update `dune-project` to pin flo to commit `b45f6452061ef309767eb8e9985532c41abdfeaa`
  - Verify compilation works

- [x] Task 1.2: Create global scoped logger module `Flo_telegram`
  - Define root namespace `telegram` logger
  - Export as `module Log` for internal library use
  - Add convenience logger creation functions

- [x] Task 1.3: Add namespace configuration documentation
  - Document all namespaces in README.md
  - Add configuration examples showing how to enable debug logs
  - Update API_REFERENCE.md with namespace hierarchy

### Phase 2: Core Library Migration

- [x] Task 2.1: Migrate `src/client.ml` to scoped logging
  - Use namespace `telegram.client`
  - All internal operations → Debug level
  - Connection lifecycle → Info level
  - Keep current function signatures unchanged

- [x] Task 2.2: Migrate `src/http.ml` to scoped logging
  - Use namespace `telegram.client.http`
  - HTTP requests/responses → Debug level
  - Connection errors → Error level
  - Rate limiting → Warn level

- [x] Task 2.3: Migrate `src/api.ml` to scoped logging
  - Use namespace `telegram.api`
  - API calls → Debug level
  - API errors → Error level

- [x] Task 2.4: Migrate `src/request.ml` and `src/response.ml`
  - Use namespace `telegram.api.request` and `telegram.api.response`
  - Request/response parsing → Debug level
  - Validation errors → Warn level

### Phase 3: Polling & Webhook

- [x] Task 3.1: Migrate `src/polling.ml` to scoped logging
  - Use namespace `telegram.polling`
  - Poll loop lifecycle → Info level
  - Update fetching details → Debug level
  - Long polling errors → Warn/Error level

- [x] Task 3.2: Migrate `src/webhook.ml` to scoped logging
  - Use namespace `telegram.webhook`
  - Webhook server lifecycle → Info level
  - Request handling → Debug level
  - Webhook errors → Error level

### Phase 4: Bot Framework

- [x] Task 4.1: Migrate `src/bot.ml` - Event routing to scoped logging
  - Use namespace `telegram.bot.dispatch`
  - Route matching → Debug level
  - Handler execution → Debug level
  - Handler errors → Error level

- [x] Task 4.2: Migrate `src/bot.ml` - Middleware to scoped logging
  - Use namespace `telegram.bot.middleware`
  - Middleware execution → Debug level
  - Middleware errors → Error level

- [x] Task 4.3: Migrate `src/bot.ml` - Context operations to scoped logging
  - Use namespace `telegram.bot.context`
  - Context creation → Debug level
  - Reply/send operations → Debug level
  - Context errors → Error level

- [x] Task 4.4: Add context propagation helper
  - Create `Bot.Ctx.with_handler_context` for automatic span creation
  - Automatically binds user_id, chat_id, message_id to logs
  - Use in examples to show best practices

### Phase 5: File Operations

- [x] Task 5.1: Migrate `src/upload.ml` to scoped logging
  - Use namespace `telegram.upload`
  - Upload start/complete → Info level
  - Upload progress → Debug level
  - Upload errors → Error level

- [x] Task 5.2: Migrate `src/download.ml` to scoped logging
  - Use namespace `telegram.download`
  - Download start/complete → Info level
  - Download progress → Debug level
  - Download errors → Error level

### Phase 6: Supporting Modules

- [ ] Task 6.1: Migrate `src/retry.ml` to scoped logging
  - Use namespace `telegram.retry`
  - Retry attempts → Debug level
  - Retry exhausted → Warn level

- [ ] Task 6.2: Migrate `src/session.ml` to scoped logging
  - Use namespace `telegram.session`
  - Session operations → Debug level
  - Session errors → Warn level

- [ ] Task 6.3: Update `src/error.ml` error formatting
  - Ensure errors log with structured fields
  - Use `Flo_semconv.error_*` fields

### Phase 7: Examples Migration

- [ ] Task 7.1: Update `examples/basic/echo.ml`
  - Add namespace configuration at startup
  - Show how to enable debug logs for specific components
  - Use `Bot.Ctx.with_handler_context` in handlers

- [ ] Task 7.2: Update `examples/basic/keyboard.ml`
  - Add namespace configuration
  - Show hierarchical namespace configuration

- [ ] Task 7.3: Update `examples/advanced/`
  - Add namespace configuration to all advanced examples
  - Show how to debug specific components

- [ ] Task 7.4: Create new example `examples/recipes/debug_logging.ml`
  - Show how to enable debug logs for different components
  - Demonstrate hierarchical namespace inheritance
  - Show dynamic log level adjustment

### Phase 8: Documentation

- [ ] Task 8.1: Update README.md
  - Add "Debugging & Logging" section
  - Document namespace hierarchy
  - Show configuration examples

- [ ] Task 8.2: Update API_REFERENCE.md
  - Document all namespaces
  - Add logging configuration section
  - Show effective level examples

- [ ] Task 8.3: Create LOGGING.md guide
  - Comprehensive guide to library logging
  - Troubleshooting guide
  - Performance considerations

- [ ] Task 8.4: Update CONTRIBUTING.md
  - Add guidelines for using scoped logging in contributions
  - Document namespace conventions
  - Show how to add new namespaces

### Phase 9: Testing & Verification

- [ ] Task 9.1: Test with default configuration (Info level)
  - Verify no debug logs appear by default
  - Run all examples
  - Run test suite

- [ ] Task 9.2: Test with debug enabled globally
  - Enable `telegram` namespace at Debug level
  - Verify all debug logs appear
  - Check for log spam issues

- [ ] Task 9.3: Test hierarchical configuration
  - Test parent/child namespace inheritance
  - Test selective component debugging
  - Verify namespace hierarchy works correctly

- [ ] Task 9.4: Performance testing
  - Benchmark with logging disabled
  - Benchmark with debug enabled
  - Ensure acceptable overhead (<10%)

### Phase 10: Cleanup

- [ ] Task 10.1: Remove any remaining global `Flo.*` calls
  - Search for remaining global logging calls
  - Convert to scoped logging
  - Verify all logs have appropriate namespaces

- [ ] Task 10.2: Final compilation check
  - Compile with zero warnings
  - All tests passing
  - All examples compile and run

## How Applications Enable Debug Logs

### Example 1: Enable Debug for All Telegram Library Logs

```ocaml
let () =
  Eio_main.run @@ fun env ->
    (* Enable debug for entire telegram library *)
    Flo.set_level_for "telegram" Severity.Debug;

    (* Your bot code *)
    let client = Telegram.Client.create ~env ~token () in
    (* ... *)
```

### Example 2: Enable Debug Only for Polling

```ocaml
let () =
  Eio_main.run @@ fun env ->
    (* Default to Info globally *)
    Flo.set_level Severity.Info;

    (* Debug only for polling subsystem *)
    Flo.set_level_for "telegram.polling" Severity.Debug;

    (* Your bot code *)
    let client = Telegram.Client.create ~env ~token () in
    (* ... *)
```

### Example 3: Fine-Grained Control

```ocaml
let () =
  Eio_main.run @@ fun env ->
    (* Configure all logging at startup *)
    Flo.set_level Severity.Info;  (* Default *)

    (* Quiet the HTTP logs (too verbose) *)
    Flo.set_level_for "telegram.client.http" Severity.Warn;

    (* Debug the polling and bot dispatch *)
    Flo.set_level_for "telegram.polling" Severity.Debug;
    Flo.set_level_for "telegram.bot.dispatch" Severity.Debug;

    (* Trace level for specific component *)
    Flo.set_level_for "telegram.api" Severity.Trace;

    (* Your bot code *)
    let client = Telegram.Client.create ~env ~token () in
    (* ... *)
```

### Example 4: Dynamic Debug (Runtime)

```ocaml
(* Enable debug dynamically at runtime *)
let enable_debug component =
  Flo.set_level_for ("telegram." ^ component) Severity.Debug;
  Flo.infof "Debug enabled for telegram.%s" component

let disable_debug component =
  Flo.clear_level_for ("telegram." ^ component);
  Flo.infof "Debug disabled for telegram.%s" component

(* Usage in bot command *)
|> Bot.command "debug" (fun ctx args ->
    Bot.Ctx.with_handler_context ctx (fun () ->
      match args with
      | ["enable"; component] ->
          enable_debug component;
          Ok ()
      | ["disable"; component] ->
          disable_debug component;
          Ok ()
      | _ ->
          let* () = Bot.Ctx.reply_ ctx "Usage: /debug enable|disable <component>" in
          Ok ()
    )
  )
```

### Example 5: Handler Context with Automatic Logging

```ocaml
(* All handlers should use with_handler_context for automatic span and context binding *)
|> Bot.command "start" (fun ctx _args ->
    Bot.Ctx.with_handler_context ctx (fun () ->
      let open Flo in
      (* Automatically logs with user_id, chat_id in context *)
      [%log.info "Processing /start command"];

      let* user = Bot.Ctx.require_user ctx in
      let* () = Bot.Ctx.reply_ ctx (Printf.sprintf "Hello %s!" user.first_name) in

      [%log.success "Command completed"];
      Ok ()
    )
  )
```

## Migration Principles

1. **Hierarchical Namespacing**: Follow `telegram.component.subcomponent` pattern
2. **Debug for Internals**: Library internals use Debug/Trace level by default
3. **Info for User Actions**: User-facing actions (polls, connections) use Info level
4. **Structured Logging**: Use `_fields` variants with semantic conventions
5. **Context Propagation**: Use `with_span` and `bind` for distributed tracing
6. **No Breaking Changes**: All migrations maintain function signatures
7. **Zero Warnings**: Code must compile with zero warnings
8. **100% Tests Passing**: All tests must pass after each phase

## Implementation Pattern

### Pattern 1: Create Scoped Logger (Preferred)

```ocaml
(* In src/client.ml *)
module Log = Flo_scoped.Make(struct
  let namespace = "telegram.client"
end)

let create ~env ~token () =
  Log.info "Creating Telegram client";
  Log.debug_fields "Client configuration" ~fields:[
    ("token_length", Flo.Value.int (String.length token));
  ];
  { env; token }
```

### Pattern 2: Use Explicit Scoped Functions

```ocaml
(* For one-off logs or dynamic namespaces *)
let handle_update update =
  Flo.scoped_debug "telegram.polling" "Received update";
  (* ... *)
```

### Pattern 3: Context-Based Scoping

```ocaml
(* For wrapping entire functions *)
let process_updates () =
  Flo.with_namespace "telegram.polling.dispatch" (fun () ->
    Flo.info "Starting update dispatcher";
    (* All logs here automatically use telegram.polling.dispatch *)
  )
```

## Best Practices

### DO ✅

- Use `Flo_scoped.Make` for compile-time namespaces (most efficient)
- Use Debug level for internal library operations
- Use Info level for user-facing lifecycle events
- Use structured logging with semantic conventions
- Add context binding in handlers (`bind`, `with_span`)
- Document namespaces in public API documentation

### DON'T ❌

- Don't use dynamic namespaces in hot paths (e.g., per-message namespace)
- Don't log at Info level for every internal operation
- Don't use global `Flo.*` functions in library code
- Don't forget to update examples with namespace configuration
- Don't mix global and scoped logging in the same module

## Verification Checklist

After completing all phases, verify:

- [ ] All library code uses scoped logging with appropriate namespaces
- [ ] No global `Flo.*` calls in library code (only in examples/docs)
- [ ] All examples show namespace configuration
- [ ] Documentation explains namespace hierarchy
- [ ] Debug logs are hidden by default (Info level)
- [ ] Applications can enable debug per component
- [ ] Zero compilation warnings
- [ ] All tests passing
- [ ] Performance overhead acceptable (<10%)

## References

- [Flo NAMESPACE_MIGRATION.md](./flo/NAMESPACE_MIGRATION.md) - Flo's official migration guide
- [Flo scoped_logging.ml](./flo/examples/scoped_logging.ml) - Complete scoped logging example
- [Flo API_REFERENCE.md](./flo/API_REFERENCE.md) - Flo API documentation
- [Flo DESIGN.md](./flo/DESIGN.md) - Flo architecture and design decisions

---

**Status**: Migration in progress
**Last Updated**: 2025-10-22
