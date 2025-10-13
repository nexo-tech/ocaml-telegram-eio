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
- [x] Task 1.1.2.5: `docs/recipe_webhook_bot.mld` - Webhook setup
  - Created `examples/recipe_webhook_bot.ml` - Production-ready webhook bot
  - **Webhook server configuration**: Full-featured webhook server using Webhook module
    - Port configuration (8443 default, configurable via WEBHOOK_PORT)
    - Custom path configuration (configurable via WEBHOOK_PATH)
    - Secret token validation (WEBHOOK_SECRET environment variable)
    - Max connections: 100 concurrent connections
  - **Security features**: Production-grade security
    - Secret token validation (X-Telegram-Bot-Api-Secret-Token header)
    - IP allowlisting with Telegram's official IP ranges
    - Custom rate limiting validator (100 req/min per IP)
    - Request validation hooks
  - **Graceful shutdown**: Signal-based shutdown with connection draining
    - SIGINT and SIGTERM signal handlers
    - Eio switch-based graceful shutdown
    - In-flight request draining
    - Clean exit with final metrics
  - **Metrics tracking**: Comprehensive runtime metrics
    - Updates processed counter
    - Error counter
    - Uptime calculation with formatted display (hours/mins/secs)
    - Real-time metrics logging
  - **Rate limiting**: IP-based rate limiter with Hashtbl
    - 100 requests per minute per IP
    - Automatic counter reset every 60 seconds
    - Custom validator integration
  - **Webhook setup instructions**: Auto-generated curl commands
    - Prints setWebhook curl command on startup
    - Includes secret token and URL configuration
    - getWebhookInfo command for status checking
  - **Functor-based verbose logging**: Verbose_bot with Debug level
    - Comprehensive Eio.traceln logging at every step
    - Logs include: [Config], [Webhook], [RateLimit], [Metrics], [Update], [Error], [Shutdown]
    - Detailed request logging (IP, headers, path)
    - Update details logging (message ID, chat ID, text)
  - **Low-level Webhook API demonstration**: Uses Webhook module directly
    - `Webhook.make` with all configuration options
    - `Webhook.run_with_config_and_switch` for manual control
    - Demonstrates production patterns without high-level Bot.run_webhook
  - Example compiles without errors/warnings (zero compilation issues)
- [x] Task 1.1.2.6: `docs/recipe_chatbot_context.mld` - Contextual conversations
  - Created `examples/recipe_chatbot_context.ml` - Multi-turn contextual chatbot
  - **Multi-step conversation flow**: Profile setup wizard with state machine
    - States: Idle → AskName → AskEmail → AskTimezone → Confirm
    - Type-safe step transitions with phantom types
    - Data accumulation across steps (profile record)
    - Clear step progression with verbose logging
  - **Session-based state management**: Typed session keys with Verbose_session functor
    - `state_key = Verbose_session.make ~name:"profile_wizard"`
    - session_get, session_set, session_delete, session_exists operations
    - session_get_or with default for safe access
    - Per-user state isolation
  - **Context expiration with TTL**: Time-to-live based expiration
    - 15-minute TTL (900 seconds)
    - started_at timestamp tracking
    - Automatic expiration check before each step
    - Clear expiration message to user
  - **Confirmation keyboard**: Inline keyboard for final confirmation
    - ✅ Confirm button (saves and exits)
    - ✏️  Restart button (begins flow again)
    - ✖️  Cancel button (aborts and clears session)
    - Callback data: profile:confirm, profile:restart, profile:cancel
  - **Commands**: /start, /help, /start_profile, /status, /cancel
    - /start_profile initiates wizard
    - /status shows current step and TTL remaining
    - /cancel aborts active conversation
  - **Mixed input handling**: Text + buttons with graceful fallbacks
    - Text handler for name/email/timezone collection
    - Callback handler for confirmation actions
    - State-aware prompts at each step
    - Idle state ignores random text
  - **Conversation state tracking**: context_state type with profile data
    - profile type: name, email, timezone (all option)
    - step ADT with associated data
    - TTL tracking with Unix timestamps
    - Helper functions: now(), expired(), begin_flow()
  - **Result-based handlers**: All handlers return `(unit, Error.t) result`
  - **Functor-based verbose logging**: Verbose_bot with Debug level
    - Comprehensive Eio.traceln logging at every step
    - Logs include: [Flow], [Handler], [Builder], [Init], [Polling]
    - State transition logging (step changes)
    - TTL expiration logging (elapsed time)
    - Data collection logging (name, email, timezone)
  - Example compiles without errors/warnings (zero compilation issues)
- [x] Task 1.1.2.7: `docs/recipe_notification_bot.mld` - Notifications
  - Created `examples/recipe_notification_bot.ml` - Comprehensive notification system
  - **Subscription management**: In-memory subscriber storage with Hashtbl
    - Subscriptions module with create, add, remove, list, count, is_subscribed
    - Chat ID tracking (string keys for persistence compatibility)
    - Real-time subscription status tracking
    - Subscribe/unsubscribe commands
  - **Broadcast messaging**: Eio concurrency with rate limiting
    - Concurrent message sending with Eio.Semaphore (max_concurrency: 10)
    - Rate limiting with configurable delay between messages (0.05s default)
    - Background fibers with Eio.Fiber.fork
    - Success/failure tracking and reporting
    - Comprehensive broadcast logging (per-message status)
  - **Scheduled messages**: Background periodic messaging with Eio fibers
    - schedule_every function with clock-based timing
    - Daily digest demo (60s interval, configurable to 24h)
    - Background fiber integration with Eio.Switch
    - Admin chat configuration via ADMIN_CHAT_ID env var
  - **Notification preferences**: Session-based mute/unmute
    - notification_prefs type with mute flag
    - Session storage with prefs_key
    - /preferences command to toggle mute
    - Status display showing mute state
  - **Admin-only commands**: Permission-based access control
    - Admin module with ADMIN_USER_IDS environment variable
    - require_admin guard function
    - /broadcast restricted to admins
    - /stats restricted to admins
  - **Commands**: /start, /help, /subscribe, /unsubscribe, /status, /preferences, /broadcast (admin), /stats (admin)
  - **Eio concurrency patterns**: Demonstrates production patterns
    - Semaphore for concurrency limiting
    - Fiber.fork for background tasks
    - Switch for coordinated lifecycle
    - Clock-based scheduling
  - **Result-based handlers**: All handlers return `(unit, Error.t) result`
  - **Functor-based verbose logging**: Verbose_bot with Debug level
    - Comprehensive Eio.traceln logging at every step
    - Logs include: [Subscriptions], [Admin], [Broadcast], [Scheduler], [Handler], [Builder], [Init]
    - Broadcast progress logging (per-message success/failure)
    - Admin access logging (granted/denied)
    - Subscription changes logging (add/remove)
  - Example compiles without errors/warnings (zero compilation issues)
- [x] Task 1.1.2.8: `docs/recipe_poll_quiz_bot.mld` - Polls and quizzes
  - Created `examples/recipe_poll_quiz_bot.ml` - Comprehensive poll and quiz system
  - **Simple polls**: /poll command with multiple options
  - **Multiple answer polls**: /multipoll with allows_multiple_answers
  - **Timed polls**: /timedpoll with open_period (auto-close)
  - **Quiz mode**: /quiz command with correct answers and explanations
    - Non-anonymous mode for vote tracking
    - correct_option_id for marking right answer
    - HTML explanation with explanation_parse_mode
  - **Vote tracking**: VoteTracker module for non-anonymous polls
    - poll_id -> (user_id -> option_ids) mapping
    - Tracks PollAnswer updates
    - Aggregates vote counts per option
  - **Poll metadata storage**: PollMeta module
    - Stores chat_id, message_id, poll_type, correct_option
    - Required for stopping polls via stop_poll API
  - **Results display**: /results command stops poll and shows final counts
  - **Quiz leaderboard**: /leaderboard command ranks users by correct answers
    - Scores quiz based on correct_option_id
    - Formats with medal emojis (🥇🥈🥉)
    - Shows correct/incorrect status per user
  - **Poll management**: /list command shows all active polls
  - **Commands**: /start, /help, /poll, /multipoll, /timedpoll, /quiz, /results, /leaderboard, /list
  - **Result-based handlers**: All handlers return `(unit, Error.t) result`
  - **Functor-based verbose logging**: Verbose_bot with Debug level
    - Comprehensive Eio.traceln logging at every step
    - Logs include: [Handler], [PollOption], [PollMeta], [VoteTracker], [Leaderboard], [Builder], [Init], [Polling]
    - Poll creation logging (question, options count, poll_type)
    - Vote tracking logging (poll_id, user_id, option_ids)
    - Leaderboard scoring logging (correct answers, rankings)
  - Example compiles without errors/warnings (zero compilation issues)
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
**Completed**: 10
**In Progress**: 0
**Remaining**: 25
**Progress**: 29% (10/35)

---

## Notes

- Each documentation file may contain multiple examples
- Some examples may combine into single comprehensive demo
- Focus on API ergonomics while implementing
- Identify and fix API inconsistencies during implementation
- Update this checklist as examples are validated and implemented

