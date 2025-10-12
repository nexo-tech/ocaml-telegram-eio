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
- [x] Task 1.1.2.1: `docs/recipe_echo_bot.mld` - Echo bot example
  - Created `examples/recipe_echo_bot.ml` - Feature-rich echo bot with transformations
  - **Text transformations**: 7 types (upper, lower, reverse, l33t, novowels, count, freq)
    - Pure Transform module with clean separation of concerns
    - Each transformation is a pure function on strings
  - **Formatting styles**: 5 types (plain, bold, italic, code, quote)
    - HTML escaping for safe formatting
    - Style module with type-safe style application
  - **Session management**: User preferences persist across messages
    - Session keys created via functor: `Verbose_session.make ~name:"transform"`
    - session_get_or for defaults, session_set for updates
    - session_modify for atomic increments (message counting)
    - session_clear for reset functionality
  - **Smart context awareness**: Emoji prefixes based on message content
    - Questions (?) → 🤔, Greetings → 👋, Thanks → 😊, Excitement (!) → 🎉
  - **Statistics tracking**: Message count per user
  - **Commands**: /start, /help, /transform <type>, /style <type>, /stats, /reset
  - **Result-based handlers**: All handlers return `(unit, Error.t) result`
  - **Functor-based logging**: Verbose_bot with Debug level
  - Example compiles without errors and demonstrates cookbook patterns elegantly
- [x] Task 1.1.2.2: `docs/recipe_command_bot.mld` - Command routing bot
  - Created `examples/recipe_command_bot.ml` - Multi-command bot with help system
  - **Command registry**: Auto-generated help from command metadata
    - `Command_registry` module stores command_info (name, aliases, description, usage, category, admin_only)
    - `format_help_text ~is_admin ()` generates context-aware help
    - `find_command` for looking up commands by name or alias
  - **Command aliases**: Multiple names for same command
    - /h → /help, /e → /echo, /info → /about
    - Logged in verbose output for troubleshooting
  - **Admin commands**: Permission-based access control
    - `Admin` module with require_admin wrapper
    - Admin IDs loaded from ADMIN_USER_IDS environment variable
    - /stats and /broadcast restricted to admins
    - Permission checks logged with user ID
  - **Structured argument parsing**: Calculator with type-safe operation parsing
    - `Calculator` module with `parse_args` returning Result
    - Operation type (Add | Subtract | Multiply | Divide) with float tuples
    - Division by zero protection
    - Detailed error messages for invalid input
  - **Statistics tracking**: Bot state with command counting
    - `Bot_state` module tracks total commands and unique users
    - Hashtbl for unique user tracking
    - Uptime calculation and formatting
  - **8 commands**: /start, /help (/h), /echo (/e), /time, /calc, /about (/info), /stats (admin), /broadcast (admin)
  - **Verbose logging**: Every command tracked, admin checks logged, argument parsing traced
  - **Result-based handlers**: All handlers return `(unit, Error.t) result`
  - Example compiles without errors and demonstrates command bot patterns elegantly
- [x] Task 1.1.2.3: `docs/recipe_keyboard_bot.mld` - Keyboard interactions
  - Created `examples/recipe_keyboard_bot.ml` - Interactive keyboard bot with menu navigation
  - **Refined keyboard API**: Uses library's `Keyboard` module with optional keyboard params
    - `Keyboard.inline [[Keyboard.callback ~text ~data]]` creates inline keyboard markup
    - `Ctx.send ~keyboard ctx "text"` sends messages with keyboards
    - `Ctx.edit ~keyboard ctx "text"` edits messages with keyboards
    - `Ctx.reply ~keyboard ctx "text"` replies with keyboards
    - Optional `?keyboard` parameter added to all Ctx message functions
  - **Keyboard serialization**: Added `serialize_keyboard` helper in Bot.Ctx module
    - Converts `Types.inline_keyboard_markup` to JSON string for API calls
    - Handles both `Url_button` and `Callback_button` types
    - Integrates with `Gen_types.InlineKeyboardButton` and `InlineKeyboardMarkup`
  - **Multi-level menu navigation**: Main menu → Settings/Profile/Help with back buttons
  - **Session-based state**: Settings persist across interactions
    - `Verbose_session.make ~name:"settings"` creates typed session key
    - `session_get_or` retrieves with default
    - `session_set` updates session state
  - **Toggle buttons**: Notification toggle updates keyboard in real-time
  - **Callback routing**: Multiple on_callback handlers with data matching
    - menu:main, menu:settings, menu:profile, menu:help
    - toggle_notif for notification toggle
  - **Result-based handlers**: All handlers return `(unit, Error.t) result`
  - **Functor-based logging**: Verbose_bot with Debug level
  - Commands: /start (main menu), /settings (settings with state)
  - **Ergonomic API**: Uses library's Keyboard module, no custom wrappers needed
  - Example compiles without errors/warnings and demonstrates keyboard interaction patterns
  - All tests pass (100% test coverage maintained)
- [x] Task 1.1.2.4: `docs/recipe_file_bot.mld` - File upload/download
  - Created `examples/recipe_file_bot.ml` - Comprehensive file management bot
  - **File storage with quota tracking**: User-specific file storage with 100MB quota
    - `file_entry` type tracks file_id, file_name, file_size, mime_type, uploaded_at, user_id
    - `user_storage` type with files list and quota field
    - `total_size`, `has_space`, `add_file`, `remove_file` storage operations
  - **Session-based file tracking**: Files persisted in user sessions
    - `storage_key = Verbose_session.make ~name:"user_storage"` for per-user storage
    - `album_key = Verbose_session.make ~name:"album_builder"` for album state
  - **File cache**: Hashtbl for quick file access by ID
  - **Callback-based file operations**: Inline keyboard for file management
    - download:file_id, delete:file_id, view:file_id callbacks
    - Dynamic keyboard generation from user's file list
  - **Album builder**: Multi-photo album with session state
    - Collect up to 10 photos with /album command
    - Session stores album_state (items list, max_items)
    - Send all photos as album or cancel collection
  - **Commands**: /start, /files (list files), /stats (storage stats), /album (build album)
  - **Callback handlers**: File download/delete/view, album actions (add/send/cancel)
  - **Note**: Uses on_text fallback for file handling (Event.document/Event.photo to be implemented)
  - **Result-based handlers**: All handlers return `(unit, Error.t) result`
  - **Functor-based verbose logging**: Verbose_bot with Debug level for troubleshooting
    - Comprehensive Eio.traceln logging at every step
    - Logs include: [Init], [Handler], [Storage], [Album], [Callback] prefixes
  - Example compiles without errors/warnings (zero compilation issues)
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
**Completed**: 9
**In Progress**: 0
**Remaining**: 26
**Progress**: 26% (9/35)

---

## Notes

- Each documentation file may contain multiple examples
- Some examples may combine into single comprehensive demo
- Focus on API ergonomics while implementing
- Identify and fix API inconsistencies during implementation
- Update this checklist as examples are validated and implemented

