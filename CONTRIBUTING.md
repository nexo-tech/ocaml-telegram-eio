# Contributing

Thank you for contributing to ocaml_telegram_eio! This guide covers development workflow, coding standards, and best practices.

## Task Completion Policy

When working on tasks from [ROADMAP.md](ROADMAP.md) or implementing new features, follow this checklist:

1. **Understand the API**: Study library implementation & public API (generated methods + ergonomic wrappers)
2. **Code must compile**: Zero compiler warnings required
3. **Tests required**: Library code must pass 100% tests; write new tests for new API/implementation
4. **Documentation**: Public API changes require documentation updates
5. **Examples**: All code examples must compile and demonstrate best practices
6. **Verbose logging**: Examples should include comprehensive logging for troubleshooting
7. **Mark completion**: Update task as `[x]` in ROADMAP.md or relevant tracking file
8. **Commit**: Create descriptive commit when task successfully completed

### Code Quality Standards

- **Functional style**: Use monadic/functional/combinator patterns (Haskell-like)
- **Elegant and simple**: API should be powerful yet easy to use
- **Consistent interface**: Follow existing patterns in the codebase
- **Type-safe**: Leverage OCaml's type system for compile-time guarantees

## Result-Based Error Handling

**CRITICAL**: This library uses `Result.t` for ALL error handling. Exceptions are FORBIDDEN except at top-level boundaries.

### Core Principles

1. **All operations return Result**: Public API functions return `(ok_type, Error.t) result`
2. **No internal exceptions**: Never use `failwith`, `raise`, `invalid_arg` inside library code
3. **Exceptions only at boundaries**: Only catch exceptions at FFI/IO boundaries and convert to Result
4. **Monadic composition**: Use `let*` syntax and bind/map operators for chaining

### Why Result Over Exceptions?

**Result benefits:**
- Explicit in types - `('a, 'e) result` shows function can fail
- Composable - works with `let*`, `>>=`, `>>|`, `|>`
- Type-safe - compiler ensures errors are handled
- Traceable - errors propagate through call chain
- Testable - easy to test error cases

**Exception problems:**
- Hidden control flow - unclear when functions can fail
- Lost context - stack unwinding loses intermediate state
- Difficult composition - can't chain with `|>` or monadic operators
- Runtime surprises - compile-time safety lost
- Messy error handling - try/catch scattered everywhere

### Error Handling Patterns

#### Pattern 1: Monadic Composition (Recommended)

```ocaml
let handle_command ctx args =
  let open Bot.Ctx in
  let* user = require_user ctx in
  let* chat_id = chat ctx in
  let* () = reply_ ctx (Printf.sprintf "Hello %s!" user.username) in
  Ok ()
```

#### Pattern 2: Simple Match with Logging

```ocaml
match Bot.Ctx.reply ctx "Message" with
| Ok _ -> ()
| Error err ->
    let open Flo in
    error_fields "Failed to send message" ~fields:[
      Flo_semconv.error_message (Format.asprintf "%a" Telegram.Error.pp err);
    ]
```

#### Pattern 3: Converting to Result

```ocaml
(* CORRECT ✅ *)
let parse_int s =
  match int_of_string_opt s with
  | Some n -> Ok n
  | None -> Error (Telegram.Error.Invalid_argument "not a valid integer")

(* WRONG ❌ - letting exception escape *)
let parse_int s =
  int_of_string s  (* Can throw Failure exception! *)
```

### Common Mistakes

**❌ WRONG**: Using `ignore` on Result
```ocaml
ignore (Bot.Ctx.reply ctx "Hello!")  (* Operation never runs! *)
```

**✅ CORRECT**: Always handle Result
```ocaml
match Bot.Ctx.reply ctx "Hello!" with
| Ok _ -> ()
| Error err ->
    let open Flo in
    error_fields "Reply failed" ~fields:[
      Flo_semconv.error_message (Format.asprintf "%a" Telegram.Error.pp err);
    ]
```

### Migration Checklist

When refactoring to Result-based error handling:

- [ ] Replace all `failwith` with `Error (...)`
- [ ] Replace all `raise` with `Error (...)`
- [ ] Replace all `invalid_arg` with `Error (Invalid_argument ...)`
- [ ] Change function signatures from `'a` to `('a, Error.t) result`
- [ ] Add `let*` bindings for error propagation
- [ ] Update tests to expect Result types
- [ ] Update examples to use monadic composition

## Flo Logging Guidelines

This library uses the [flo](https://github.com/nexo-tech/flo) logging library for zero-configuration, structured logging with OpenTelemetry support.

### Why Flo?

**Flo benefits:**
- Zero configuration - singleton design, no functor composition required
- Structured logging - key-value fields with type-safe `Value.t`
- OpenTelemetry native - distributed tracing, semantic conventions
- Eio integration - works seamlessly with OCaml 5 effects
- PPX support - automatic location capture with `[%log.info]`
- Multiple backends - console, file, HTTP exporters

**Previous functor approach problems:**
- Boilerplate - every module needed `Log.Make` functor instantiation
- Verbose - functor composition for Session, Polling, Bot modules
- Configuration complexity - passing log instances through module chain
- Testing difficulty - hard to mock or intercept logs

### Logging Severity Levels

Flo provides 7 severity levels (matching OpenTelemetry):

```ocaml
Flo.trace "Low-level details"       (* Trace - extremely detailed *)
Flo.debug "Debug information"       (* Debug - diagnostic info *)
Flo.info "Normal operation"         (* Info - general information *)
Flo.success "Operation completed"   (* Success - positive outcome *)
Flo.warn "Warning condition"        (* Warn - potentially harmful *)
Flo.error "Error occurred"          (* Error - failure event *)
Flo.fatal "Fatal error"             (* Fatal - critical failure *)
```

**Configure severity threshold:**
```ocaml
(* Enable debug logging *)
let () = Flo.set_level Severity.Debug

(* Show only warnings and above *)
let () = Flo.set_level Severity.Warn
```

### Structured Logging with Fields

Use `*_fields` variants for structured logging:

```ocaml
let open Flo in

(* Log with structured fields *)
info_fields "User authenticated" ~fields:[
  ("user_id", Value.string "12345");
  ("username", Value.string "alice");
  ("auth_method", Value.string "oauth");
]

debug_fields "API request" ~fields:[
  ("method", Value.string "getUpdates");
  ("offset", Value.int offset);
  ("timeout", Value.int timeout);
]

error_fields "Request failed" ~fields:[
  ("http_status", Value.int 429);
  ("retry_after", Value.int 30);
  Flo_semconv.error_message "Rate limit exceeded";
]
```

**Field value types:**
- `Value.string` - string values
- `Value.int` - integer values
- `Value.float` - float values
- `Value.bool` - boolean values

### Context Binding Pattern

Use context binding to automatically include context fields in all logs within a scope:

```ocaml
(* Bind handler context for automatic fields *)
Bot.Ctx.with_handler_context ctx (fun () ->
  let open Flo in
  info "Processing command";        (* Includes user_id, chat_id from ctx *)
  debug "Validating input";         (* Includes user_id, chat_id from ctx *)
  success "Command completed";      (* Includes user_id, chat_id from ctx *)
)
```

**Handler context automatically includes:**
- `user_id` - Telegram user ID
- `chat_id` - Chat ID
- `username` - Username (if available)
- `message_id` - Message ID
- `update_id` - Update ID

### Distributed Tracing with Spans

Use `Flo.with_span` to trace request flow across operations:

```ocaml
(* Create span for expensive operation *)
Flo.with_span "handle_command" (fun () ->
  let open Flo in
  info "Handler started";

  (* Nested span for sub-operation *)
  Flo.with_span "database_query" (fun () ->
    debug "Querying user data";
    (* ... database operations ... *)
  );

  success "Handler completed";
)
```

**Spans provide:**
- Operation timing - automatic duration tracking
- Nested operations - parent/child span relationships
- Trace IDs - correlate logs across distributed systems
- Span attributes - attach metadata to spans

### Semantic Conventions

Use `Flo_semconv` module for OpenTelemetry standard attributes:

```ocaml
let open Flo in

(* Error attributes *)
error_fields "Operation failed" ~fields:[
  Flo_semconv.error_type "NetworkError";
  Flo_semconv.error_message "Connection timeout";
  Flo_semconv.error_stack_trace (Printexc.get_backtrace ());
]

(* HTTP attributes *)
info_fields "HTTP request" ~fields:[
  Flo_semconv.http_request_method "POST";
  Flo_semconv.http_response_status_code 200;
  Flo_semconv.http_request_body_size 1024;
]

(* Custom attributes *)
debug_fields "Bot update" ~fields:[
  ("bot.update.type", Value.string "message");
  ("bot.command", Value.string "/start");
]
```

**Common semantic conventions:**
- `error_*` - error attributes (type, message, stack trace)
- `http_*` - HTTP attributes (method, status, headers)
- `server_*` - server attributes (address, port)
- `db_*` - database attributes (system, query, table)

### PPX Extensions

Use `ppx_flo` for automatic location capture:

**Enable in dune file:**
```sexp
(executable
  (name my_bot)
  (libraries ocaml_telegram_eio.telegram eio_main)
  (preprocess (pps ppx_flo)))
```

**Use PPX extensions for simple logs:**
```ocaml
let () =
  let open Flo in

  (* PPX extension - automatic location capture *)
  [%log.info "Bot starting"];
  [%log.debug "Loading configuration"];
  [%log.success "Bot started successfully"];
  [%log.error "Failed to connect"];
```

**When to use PPX vs manual API:**

✅ **Use PPX extensions** for:
- Simple log messages without dynamic fields
- Static strings known at compile time
- Benefit: Automatic file, line, function location

✅ **Use manual API** for:
- Logs with structured fields (`*_fields` variants)
- Dynamic content evaluated at runtime
- Benefit: Rich structured data, semantic conventions

**Example combining both:**
```ocaml
let handle_command ctx args =
  let open Flo in

  (* PPX for simple messages *)
  [%log.info "Command received"];

  (* Manual API for structured data *)
  Bot.Ctx.with_handler_context ctx (fun () ->
    debug_fields "Command details" ~fields:[
      ("command", Value.string "start");
      ("arg_count", Value.int (List.length args));
    ];

    (* PPX within context *)
    [%log.debug "Executing handler"];

    (* Manual API for result *)
    success_fields "Command completed" ~fields:[
      ("duration_ms", Value.int 42);
    ];
  )
```

### Best Practices

**1. Configure severity level globally:**
```ocaml
(* In main executable entry point *)
let () = Flo.set_level Severity.Debug  (* Development *)
let () = Flo.set_level Severity.Info   (* Production *)
```

**2. Use context binding in handlers:**
```ocaml
|> Bot.command "start" (fun ctx args ->
    Bot.Ctx.with_handler_context ctx (fun () ->
      let open Flo in
      [%log.info "Processing /start command"];
      (* All logs here include user_id, chat_id *)
      Ok ()
    )
  )
```

**3. Use spans for expensive operations:**
```ocaml
Flo.with_span "image_processing" (fun () ->
  let open Flo in
  info "Processing image";
  (* ... expensive work ... *)
  success "Image processed";
)
```

**4. Use semantic conventions for errors:**
```ocaml
error_fields "API call failed" ~fields:[
  Flo_semconv.error_type "TelegramApiError";
  Flo_semconv.error_message "Rate limit exceeded";
  ("retry_after", Value.int 30);
]
```

**5. Choose appropriate severity:**
- `trace` - Low-level library internals
- `debug` - Development troubleshooting
- `info` - Production informational messages
- `success` - Positive outcomes (handler completed)
- `warn` - Recoverable issues (deprecated API used)
- `error` - Failures requiring attention
- `fatal` - Critical failures (configuration missing)

## Regenerating code from Telegram Bot API reference

This project includes offline copies of the spec in `reference/`. We generate OCaml types and method wrappers from `reference/api.html`.

- Build the generator and check if generated files are up-to-date:

```
./scripts/regenerate.sh
```

- Force regeneration (writes into `generated/`):

```
./scripts/regenerate.sh reference/api.html generated
```

Artifacts:
- `generated/gen_types.ml` and `generated/gen_types.mli`: record types with `[@@deriving yojson]`
- `generated/gen_methods.ml`: method wrapper stubs (sendMessage implemented; others documented)

## Testing

- Run all tests: `dune runtest`
- Run specific test suite: `dune exec test/golden.exe` (golden tests), `dune exec test/smoke.exe`, etc.

### Golden Tests

Golden tests ensure generated code stability. Baselines are stored in `test/golden/`.

- **Update golden baselines** after intentional generator changes:
  ```bash
  dune exec test/update_golden.exe
  ```

- **CI automatically checks** that generated code matches golden baselines via `dune runtest`

If golden tests fail, you'll see:
```
FAIL: Generated file differs from golden baseline for gen_types.ml
To see differences: diff -u test/golden/gen_types.ml generated/gen_types.ml | head -50
To update golden (if change is intentional): dune exec test/update_golden.exe
```

## Development

- Build: `dune build`
- Test: `dune runtest`
- Run codegen helpers directly:
  - `dune exec -- bin/spec_types.exe reference/api.html`
  - `dune exec -- bin/spec_methods.exe reference/api.html`
  - `dune exec -- bin/spec_codegen_types.exe reference/api.html --out-dir generated`
  - `dune exec -- bin/spec_codegen_methods.exe reference/api.html > generated/gen_methods.ml`
  - `dune exec -- bin/telegram_gen.exe --in reference/api.html --out-dir generated --check`

## Notes

- Generated code is not compiled by default to keep the main build green while the generator evolves. Once stable, we can wire a `dune` stanza for the generated library.
- The high-level DSL and low-level API are documented in `API_DESIGN.md`.
