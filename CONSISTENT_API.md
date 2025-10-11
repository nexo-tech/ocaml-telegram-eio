# CONSISTENT_API.md

**Documentation Examples → Compiled Examples**

Goal: Implement every example from documentation in `examples/` directory with a clean, elegant, functional API that actually compiles.

## Master Checklist

### Phase 1.1.1: Core Concepts & Getting Started
- [x] Task 1.1.1.1: `docs/getting_started.mld` - Extract and implement all examples
  - Created `examples/hello_world.ml` - Basic /start command bot
  - Created `examples/echo_enhanced.ml` - Echo bot with command routing
  - Updated both examples to use functional builder API from BUILDER.md
  - `Verbose_bot.make ~env ~client |> Verbose_bot.command |> Verbose_bot.on_text |> Verbose_bot.run`
  - Examples compile without warnings and demonstrate elegant builder pattern
  - Clean, readable code that matches Haskell-style functional APIs
  - **Result-based handlers**: All handlers return `(unit, Error.t) result`
  - **Functor-based logging**: Custom Log/Session/Polling/Bot modules with Debug level
    - `Verbose_log = Log.Make (Log.Console) (struct let level = Log.Debug end)`
    - `Verbose_bot = Bot.Make (Verbose_log) (Verbose_session) (Verbose_polling)`
  - **VERBOSE LOGGING**: Added comprehensive Eio.traceln logging at every step
    - Bot initialization (token loading, client creation)
    - Route registration (command, on_text)
    - Update reception and routing
    - Handler execution (entry/exit with context details)
    - API calls (sendMessage with success/error)
    - Error handling (full context dump, error recovery)
  - Logs include prefixes: [Init], [Builder], [Handler], [Error]
  - Every example demonstrates troubleshooting best practices
  - Examples are fully debuggable with verbose output for Claude/humans
- [x] Task 1.1.1.2: `docs/quick_start.mld` - Extract and implement all examples
  - Updated `examples/command_tutorial.ml` - Bot DSL tutorial (Tutorial 3)
  - **Bot builder pattern**: Uses functional builder API with `|>` chaining
    - `Verbose_bot.make ~env ~client |> Verbose_bot.command ... |> Verbose_bot.run`
  - **Commands implemented**: /start, /help, /echo, /add, /upper + on_text fallback
  - **Args module**: Demonstrates Bot.Args helpers (expect_2, parse_int, join_rest)
  - **Result-based handlers**: All handlers return `(unit, Error.t) result`
  - **Functor-based logging**: Custom Verbose_bot with Debug level logging
  - **Comprehensive logging**: Every handler logs entry/exit, argument parsing, results
  - Example compiles without errors and demonstrates elegant Bot DSL from docs
- [x] Task 1.1.1.3: `docs/core_concepts.mld` - Extract and implement all examples
  - Created `examples/core_concepts_demo.ml` - Demonstrates fundamental patterns
  - **Bot lifecycle**: Shows 4 phases (Init → Start → Handle → Shutdown)
    - Phase 1: Eio runtime initialization, client creation
    - Phase 2: Bot builder DSL with route registration
    - Phase 3: Update handling with different event types
    - Phase 4: Automatic cleanup via Eio structured concurrency
  - **Separation of concerns**: Pure Logic module separate from Telegram handlers
  - **Result-based error handling**: Monadic let* composition throughout
  - **Type-safe IDs**: Demonstrates phantom types (Id.Chat.k, Id.User.k)
  - **Error recovery pattern**: on_error handler with user notification
  - **Functor-based logging**: Verbose logging at every lifecycle phase
  - Commands: /start, /echo (Args helpers), /error (error demo), /calc (monadic composition)
  - Comprehensive logging with phase markers (boxes) for clarity
  - Example compiles without errors and demonstrates core concepts elegantly

### Phase 1.1.2: Recipe Examples (Cookbook)
- [ ] Task 1.1.2.1: `docs/recipe_echo_bot.mld` - Echo bot example
- [ ] Task 1.1.2.2: `docs/recipe_command_bot.mld` - Command routing bot
- [ ] Task 1.1.2.3: `docs/recipe_keyboard_bot.mld` - Keyboard interactions
- [ ] Task 1.1.2.4: `docs/recipe_file_bot.mld` - File upload/download
- [ ] Task 1.1.2.5: `docs/recipe_webhook_bot.mld` - Webhook setup
- [ ] Task 1.1.2.6: `docs/recipe_chatbot_context.mld` - Contextual conversations
- [ ] Task 1.1.2.7: `docs/recipe_notification_bot.mld` - Notifications
- [ ] Task 1.1.2.8: `docs/recipe_poll_quiz_bot.mld` - Polls and quizzes
- [ ] Task 1.1.2.9: `docs/recipe_inline_bot.mld` - Inline queries
- [ ] Task 1.1.2.10: `docs/recipe_group_management_bot.mld` - Group admin features
- [ ] Task 1.1.2.11: `docs/recipe_payment_bot.mld` - Payment integration
- [ ] Task 1.1.2.12: `docs/recipe_games_bot.mld` - Game bot

### Phase 1.1.3: API Components
- [ ] Task 1.1.3.1: `docs/keyboard_api.mld` - Keyboard creation examples
- [ ] Task 1.1.3.2: `docs/command_dsl.mld` - Command DSL examples
- [ ] Task 1.1.3.3: `docs/message_handling.mld` - Message handling patterns
- [ ] Task 1.1.3.4: `docs/callback_queries.mld` - Callback query handling
- [ ] Task 1.1.3.5: `docs/media_files.mld` - Media handling examples
- [ ] Task 1.1.3.6: `docs/update_processing.mld` - Update processing patterns
- [ ] Task 1.1.3.7: `docs/error_handling.mld` - Error handling examples
- [ ] Task 1.1.3.8: `docs/session_management.mld` - Session management examples
- [ ] Task 1.1.3.9: `docs/state_machines.mld` - State machine examples

### Phase 1.1.4: Advanced Patterns
- [ ] Task 1.1.4.1: `docs/concurrency_patterns.mld` - Concurrency examples
- [ ] Task 1.1.4.2: `docs/bot_composition.mld` - Bot composition patterns
- [ ] Task 1.1.4.3: `docs/middleware_architecture.mld` - Middleware examples
- [ ] Task 1.1.4.4: `docs/testing_patterns.mld` - Testing examples

### Phase 1.1.5: Use Cases
- [ ] Task 1.1.5.1: `docs/usecase_utility_bots.mld` - Utility bot examples
- [ ] Task 1.1.5.2: `docs/usecase_content_bots.mld` - Content bot examples
- [ ] Task 1.1.5.3: `docs/usecase_entertainment_bots.mld` - Entertainment bot examples
- [ ] Task 1.1.5.4: `docs/usecase_integration_bots.mld` - Integration bot examples

### Phase 1.1.6: Project Setup & Development
- [ ] Task 1.1.6.1: `docs/project_structure.mld` - Project structure examples
- [ ] Task 1.1.6.2: `docs/development_workflow.mld` - Development workflow examples
- [ ] Task 1.1.6.3: `docs/migration.mld` - Migration examples

### Phase 1.1.7: Reference & FAQ
- [ ] Task 1.1.7.1: `docs/faq.mld` - FAQ code examples
- [ ] Task 1.1.7.2: `docs/index.mld` - Index page examples

## API Design Principles

### 1. Elegant Public API
- **Simple things should be simple**: Common tasks in 1-3 lines
- **Type safety without ceremony**: Phantom types guide, don't obstruct
- **Functional first**: Immutable data, pure functions, composition
- **Pipeline friendly**: `|>` operator for chaining

### 2. Consistency Rules
- **Naming**: Clear, consistent module/function names
- **Parameters**: Same order across similar functions (client, chat_id, content, options)
- **Return types**: Always `Result.t` for operations that can fail
- **Error handling**: Explicit, actionable error messages

### 3. Example Standards
Every example must:
- [ ] Compile without errors
- [ ] Run successfully with valid token
- [ ] Include minimal imports
- [ ] Show one clear pattern
- [ ] Be self-documenting

## Progress Tracking

**Total Tasks**: 35
**Completed**: 5
**In Progress**: 0
**Remaining**: 30
**Progress**: 14% (5/35)

---

## Notes

- Each documentation file may contain multiple examples
- Some examples may combine into single comprehensive demo
- Focus on API ergonomics while implementing
- Identify and fix API inconsistencies during implementation
- Update this checklist as examples are validated and implemented

