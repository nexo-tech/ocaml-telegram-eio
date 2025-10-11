# BUILDER.md

**Elegant Builder Pattern API for Bot DSL**

Goal: Implement functional/monadic builder pattern to make writing bots super easy and elegant.

## Current State Analysis

### ✅ What's Implemented

**Event System:**
- `Event.t` type for routing
- `Event.message`, `Event.text`, `Event.command`, `Event.callback`, `Event.inline_query`
- Event combinators: `&`, `when_`

**Context System:**
- `ctx` type with phantom types for type safety
- `Ctx.reply`, `Ctx.send`, `Ctx.edit` - message helpers
- `Ctx.client`, `Ctx.env`, `Ctx.chat`, `Ctx.user`, `Ctx.message` - accessors
- Session helpers: `session_get`, `session_set`, `session_modify`, etc.

**Middleware System:**
- `Middleware.t` with phantom types
- `Middleware.make` - custom middleware
- Built-in: `logging`, `only_users`, `require_user`, `rate_limit`, `with_session`
- Combinators: `combine`, `>>`

**Route System (Current API):**
- `route` type
- `on : 'a Event.t -> ('a -> ctx -> unit) -> route`
- `with_middleware : Middleware.t list -> route -> route`
- `with_error_handler : (ctx -> exn -> unit) -> route -> route`
- `router : route list -> route list` (applies global middleware)
- `run_polling : client -> route list -> unit`
- `run_webhook : client -> route list -> unit`

**Helper Modules:**
- `Args` - parse_int, parse_float, expect_1/2/3, join_rest
- `Entity` - entity parsing, filter_by_type
- `ErrorHandler` - log, log_and_reply, silent, combine

### ❌ What's Missing (Documented but Not Implemented)

**Builder Pattern Core:**
```ocaml
(* Documented in bot.mli lines 9-24 but doesn't exist: *)
Bot.make client                           (* ❌ Missing *)
|> Bot.command "start" handler            (* ❌ Missing *)
|> Bot.command "echo" handler             (* ❌ Missing *)
|> Bot.on Event.text handler              (* ❌ Missing - wrong signature *)
|> Bot.run                                (* ❌ Missing *)
```

**Current Workaround (Verbose):**
```ocaml
(* What you have to write now: *)
let routes = [
  on (Event.command "start") (fun args ctx -> ...);
  on (Event.command "echo") (fun args ctx -> ...);
  on Event.text (fun text ctx -> ...);
] in
run_polling ~env ~client routes
```

## API Design Goals

### Functional/Monadic Principles

1. **Builder Pattern**: Chainable with `|>`
2. **Immutable**: Each operation returns new bot value
3. **Type Safe**: Phantom types prevent mistakes
4. **Composable**: Bots can be combined
5. **Monadic**: Result/Option friendly
6. **Point-free**: Functions as first-class values

### Elegant Syntax Examples

**Simple Bot:**
```ocaml
Bot.make client
|> command "start" ~desc:"Start bot" (reply "Welcome!")
|> command "help" ~desc:"Show help" (reply "Help text")
|> on Event.text (fun text -> reply ("Echo: " ^ text))
|> run
```

**With Middleware:**
```ocaml
Bot.make client
|> use (Middleware.logging ())
|> use (Middleware.rate_limit ~max_per_minute:10 ())
|> command "admin" (reply "Admin panel")
|> run
```

**Monadic Composition:**
```ocaml
let handler ctx =
  let* user = require_user ctx in
  let* state = get_session state_key ctx in
  let* () = send_message ctx "Processing..." in
  Ok ()
```

**Combinator Style:**
```ocaml
let echo_bot =
  Bot.make
  |> command "echo" (args >>= join_rest >> reply)
  |> on Event.text reply

let admin_bot =
  Bot.make
  |> require_admin
  |> command "stats" show_stats
  |> command "ban" ban_user

let combined = Bot.merge echo_bot admin_bot
```

## Master Implementation Checklist

### Phase 1: Core Builder Types & Infrastructure

- [x] Task 1.1: Define `bot` type (builder state)
  - Accumulates routes, middleware, error handlers
  - Immutable - operations return new bot
  - Contains client reference

- [x] Task 1.2: Implement `Bot.make : Client.t -> bot`
  - Create initial empty bot with client
  - Initialize empty route list
  - Set default error handler

- [x] Task 1.3: Implement `Bot.run : bot -> unit`
  - Extract routes from bot state
  - Call `run_polling` internally
  - Simple delegation to existing infrastructure

### Phase 2: Command Routing

- [x] Task 2.1: `Bot.command : string -> (ctx -> string list -> unit) -> bot -> bot`
  - Sugar over `on (Event.command name) handler`
  - Accumulate route into bot state
  - Return new bot value
  - Flips handler signature for better ergonomics (ctx first, args second)

- [x] Task 2.2: Command with description
  - `command : ?desc:string -> string -> handler -> bot -> bot`
  - Store descriptions for auto-generated help
  - Added `command_descriptions` field to bot type
  - Added `Bot.commands` accessor for help generation
  - Optional desc parameter (backward compatible)

- [x] Task 2.3: Command with argument parser
  - `command_with : string -> 'a parser -> (ctx -> 'a -> unit) -> bot -> bot`
  - Type-safe argument parsing
  - Automatic error messages on parse failure

### Phase 3: Event Routing Sugar

- [x] Task 3.1: Fix `Bot.on` signature
  - Current: `on : Event.t -> (data -> ctx -> unit) -> route`
  - Needed: `on : Event.t -> (ctx -> data -> unit) -> bot -> bot`
  - Better ergonomics: ctx first for partial application
  - Renamed route-based `on` to `route` for clarity
  - Added new builder-pattern `on` function

- [x] Task 3.2: Convenience methods for common events
  - `on_text : (ctx -> string -> unit) -> bot -> bot`
  - `on_message : (ctx -> Message.t -> unit) -> bot -> bot`
  - `on_callback : (ctx -> string -> unit) -> bot -> bot`
  - `on_photo : (ctx -> PhotoSize.t list -> unit) -> bot -> bot`
  - All implemented as thin wrappers over `Bot.on`
  - on_callback uses Event.when_ filter on callback_query
  - on_photo uses Event.when_ filter on messages with photos

### Phase 4: Middleware Integration

- [x] Task 4.1: `Bot.use : Middleware.t -> bot -> bot`
  - Apply middleware to all subsequent routes
  - Accumulate middleware in bot state
  - Middleware appended to bot.middleware list
  - Applied globally via router when Bot.run is called

- [x] Task 4.2: Scoped middleware
  - `Bot.scope : Middleware.t list -> bot -> bot`
  - Apply middleware only within scope
  - Pop middleware at end of scope
  - Added scoped_middleware field to bot type
  - Routes automatically get scoped middleware when added
  - Bot.end_scope clears scoped middleware

- [x] Task 4.3: Middleware combinators
  - `require_user >>` - monadic chaining (already existed)
  - `with_logging` - decorator style
  - Added `when_` combinator for conditional middleware
  - Added decorator-style helpers: `with_logging`, `require_admin`, `require_all`
  - All combinators support functional composition

### Phase 5: Error Handling

- [x] Task 5.1: `Bot.on_error : (ctx -> exn -> unit) -> bot -> bot`
  - Set global error handler
  - Override default
  - Simple implementation: `{ bot with on_error = Some handler }`
  - Applied via router when Bot.run is called
  - Route-specific handlers take precedence

- [x] Task 5.2: Per-command error handling
  - `command_safe : string -> (ctx -> args -> (unit, err) result) -> bot -> bot`
  - Automatic Result error handling
  - Handler returns Result type, errors automatically sent to user
  - Delegates to command function for route creation

- [x] Task 5.3: Error recovery
  - `catch : (ctx -> exn -> unit) -> bot -> bot`
  - Try/catch style error boundary
  - Added `scoped_error_handler` field to bot type
  - Implemented catch function to set scoped error handlers
  - Updated route creation (on, command, command_with) to apply scoped error handlers
  - Scoped error handlers take precedence over global but are overridden by route-specific

### Phase 6: Monadic Helpers

- [x] Task 6.1: Context monadic operations
  - `let* syntax in handlers`
  - `Ctx.bind`, `Ctx.map`, `Ctx.return`
  - Implemented monadic operations for Result type
  - Added `Ctx.return` to wrap values in Ok
  - Added `Ctx.bind` for chaining Result operations
  - Added `Ctx.map` for transforming Result values
  - Added `let*` operator for monadic syntax sugar
  - Added `let+` operator for applicative syntax sugar
  - Comprehensive documentation with examples

- [x] Task 6.2: Handler combinators
  - `reply : string -> ctx -> (unit, Error.t) result`
  - `require_user : ctx -> (User.t, Error.t) result`
  - `require_admin : ctx -> (unit, Error.t) result`
  - Implemented `Ctx.reply_` that returns unit instead of Message.t
  - Implemented `Ctx.require_user` to extract user or return error
  - Implemented `Ctx.require_admin` to check admin privileges
  - All combinators work seamlessly with let* syntax
  - Comprehensive documentation with examples

- [ ] Task 6.3: Chaining helpers
  - `(>>=) : ('a -> 'b result) -> ('b -> 'c result) -> ('a -> 'c result)`
  - `(>>|) : ('a -> 'b result) -> ('b -> 'c) -> ('a -> 'c result)`

### Phase 7: Advanced Composition

- [ ] Task 7.1: Bot composition
  - `Bot.merge : bot -> bot -> bot`
  - Combine multiple bots
  - Route priority/ordering

- [ ] Task 7.2: Sub-routers
  - `Bot.scope_prefix : string -> bot -> bot`
  - Namespace commands (e.g., `/admin/stats`)

- [ ] Task 7.3: Conditional routing
  - `Bot.when_ : (ctx -> bool) -> bot -> bot`
  - Enable/disable routes conditionally

### Phase 8: Session Integration

- [ ] Task 8.1: Session sugar
  - `Bot.with_sessions : Session.store -> bot -> bot`
  - Auto-enable session middleware

- [ ] Task 8.2: Stateful handlers
  - Type-safe session key access
  - `get_state`, `set_state`, `modify_state`

- [ ] Task 8.3: Session-based routing
  - Route based on session state
  - State machines

### Phase 9: Testing & Examples

- [ ] Task 9.1: Update all documentation examples
  - Replace route-based with builder pattern
  - Consistent style across docs

- [ ] Task 9.2: Create builder pattern examples
  - `examples/builder_echo.ml`
  - `examples/builder_command.ml`
  - `examples/builder_stateful.ml`

- [ ] Task 9.3: Write tests
  - Builder state accumulation
  - Route generation
  - Error handling

### Phase 10: Migration Guide

- [ ] Task 10.1: Migration documentation
  - Route-based → Builder pattern
  - Side-by-side comparison

- [ ] Task 10.2: Backward compatibility
  - Keep route-based API working
  - Deprecation warnings (not errors)

- [ ] Task 10.3: Best practices guide
  - When to use builder vs routes
  - Performance implications

## API Consistency Rules

1. **Parameter Order**: `bot` always last (enables `|>`)
2. **Naming**: `command`, `on_text`, `use`, `catch` (short, clear)
3. **Return Types**: Always return `bot` (chainable)
4. **Context**: `ctx` parameter always first in handlers
5. **Results**: Handlers return `(unit, Error.t) result` or `unit`

## Priority Implementation Order

### High Priority (Core Functionality)
1. Phase 1: Core builder types (Tasks 1.1, 1.2, 1.3)
2. Phase 2: Command routing (Tasks 2.1)
3. Phase 3: Event routing (Task 3.1, 3.2)
4. Phase 9: Examples (Task 9.2)

### Medium Priority (Ergonomics)
5. Phase 4: Middleware (Task 4.1)
6. Phase 5: Error handling (Task 5.1)
7. Phase 6: Monadic helpers (Task 6.1, 6.2)

### Low Priority (Advanced)
8. Phase 7: Composition (Task 7.1)
9. Phase 8: Sessions (Task 8.1)
10. Phase 10: Migration (Task 10.1, 10.2)

## Progress Tracking

**Total Tasks**: 33
**Completed**: 16
**In Progress**: 0
**Remaining**: 17
**Progress**: 48% (16/33)

---

## Implementation Notes

- Keep existing route-based API intact (no breaking changes)
- Builder pattern is sugar over routes
- All type safety from existing phantom types preserved
- Middleware system reused as-is
- Session system reused as-is
