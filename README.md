# ocaml_telegram_eio

[![OCaml](https://img.shields.io/badge/OCaml-5.1%2B-orange.svg)](https://ocaml.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/oleg-nexo/ocaml_telegram_eio/ci.yml?branch=dev)](https://github.com/oleg-nexo/ocaml_telegram_eio/actions)

Type-safe Telegram Bot API client for OCaml using Eio.

## Features

- ✅ **Fully type-safe API** with phantom-typed identifiers
- ✅ **Complete Bot API coverage**: 449 types, 232 methods (auto-generated from spec)
- ✅ **Direct-style concurrency** using Eio effects (no monads, no callbacks)
- ✅ **Structured logging** with [flo](https://github.com/nexo-tech/flo) - OpenTelemetry-native, zero configuration
- ✅ **Forward-compatible**: preserves unknown fields for new Bot API features
- ✅ **Streaming file uploads/downloads** for efficient memory usage
- ✅ **Long polling and webhook** support
- ✅ **Comprehensive error handling** with Result types
- ✅ **Property-based and integration tested**

## Quick Start

### Installation

```bash
opam install ocaml_telegram_eio
```

### Hello World Bot

The simplest bot - responds to `/start` command with structured logging:

```ocaml
open Telegram

(* Configure logging *)
let () = Flo.set_level Severity.Info

let () =
  let open Flo in
  [%log.info "Bot starting..."];

  let token = Sys.getenv "TELEGRAM_BOT_TOKEN" in

  Eio_main.run @@ fun env ->
  let client = Client.create ~env ~token () in

  Bot.make ~env ~client
  |> Bot.command "start" (fun ctx _args ->
      Bot.Ctx.with_handler_context ctx (fun () ->
        [%log.info "Processing /start command"];
        let open Bot.Ctx in
        let* () = reply_ ctx "Hello! I'm your bot." in
        [%log.success "Command completed"];
        Ok ()
      )
    )
  |> Bot.run
```

**Key features shown:**
- Zero-configuration structured logging with [flo](https://github.com/nexo-tech/flo)
- PPX extensions for automatic location capture (`[%log.info]`)
- Context binding for user/chat fields (`Bot.Ctx.with_handler_context`)
- Result-based error handling (no exceptions)

Run it:

```bash
export TELEGRAM_BOT_TOKEN="your_token_here"
dune exec examples/hello_world.exe
```

## Documentation

- **[Getting Started Guide](docs/)** - Installation and first bot
- **[API Reference](docs/)** - Full API documentation (build with `dune build @doc`)
- **[Examples](examples/)** - 40+ working bot examples
- **[CHANGELOG](CHANGELOG.md)** - Version history and release notes
- **[CONTRIBUTING](CONTRIBUTING.md)** - Development workflow, logging best practices, and guidelines
- **[VERSIONING](VERSIONING.md)** - Semantic versioning policy
- **[COMPATIBILITY](COMPATIBILITY.md)** - Bot API compatibility and update policy

### Logging

The library uses [flo](https://github.com/nexo-tech/flo) for structured logging with OpenTelemetry support. See [CONTRIBUTING.md](CONTRIBUTING.md#flo-logging-guidelines) for comprehensive logging guidelines including:
- Severity levels and configuration
- Structured logging with fields
- Context binding for automatic user/chat fields
- Distributed tracing with spans
- Semantic conventions for errors
- PPX extensions for automatic location capture

### Debugging & Log Level Control

The library uses **namespace-based logging** to give you fine-grained control over log verbosity. By default, library internals log at `Debug` level (hidden), while user-facing events use `Info` level (visible).

**Enable debug logs for the entire telegram library:**
```ocaml
let () =
  Eio_main.run @@ fun env ->
    (* Enable debug for all telegram library components *)
    Flo.set_level_for "telegram" Severity.Debug;

    let client = Telegram.Client.create ~env ~token () in
    (* Now you'll see detailed internal logs *)
```

**Fine-grained control per component:**
```ocaml
let () =
  Eio_main.run @@ fun env ->
    (* Default: Info level (hides debug logs) *)
    Flo.set_level Severity.Info;

    (* Debug specific components *)
    Flo.set_level_for "telegram.polling" Severity.Debug;  (* See polling details *)
    Flo.set_level_for "telegram.bot.dispatch" Severity.Debug;  (* See event routing *)

    (* Quiet verbose components *)
    Flo.set_level_for "telegram.client.http" Severity.Warn;  (* Only warnings/errors *)

    let client = Telegram.Client.create ~env ~token () in
    (* ... *)
```

**Available namespaces:**
```
telegram                           # Root namespace
├── telegram.client                # Client operations
│   └── telegram.client.http       # HTTP requests/responses
├── telegram.api                   # API method calls
│   └── telegram.api.response      # Response parsing
├── telegram.polling               # Long polling
├── telegram.webhook               # Webhook server
├── telegram.bot                   # Bot framework
│   ├── telegram.bot.dispatch      # Event routing
│   ├── telegram.bot.middleware    # Middleware execution
│   └── telegram.bot.context       # Context operations
├── telegram.upload                # File uploads
├── telegram.download              # File downloads
├── telegram.retry                 # Retry logic
├── telegram.session               # Session management
└── telegram.error                 # Error analysis
```

**Common debugging scenarios:**

1. **Bot not responding to commands?**
   ```ocaml
   Flo.set_level_for "telegram.bot.dispatch" Severity.Debug;
   (* See which routes are matching *)
   ```

2. **Polling issues?**
   ```ocaml
   Flo.set_level_for "telegram.polling" Severity.Debug;
   (* See update fetching and processing *)
   ```

3. **API errors?**
   ```ocaml
   Flo.set_level_for "telegram.client.http" Severity.Debug;
   (* See full HTTP requests/responses *)
   ```

4. **State machine or session issues?**
   ```ocaml
   Flo.set_level_for "telegram.session" Severity.Debug;
   (* See session get/set operations *)
   ```

**For comprehensive logging documentation, see:**
- [LOGGING.md](LOGGING.md) - Complete logging guide with troubleshooting
- [examples/recipes/debug_logging.ml](examples/recipes/debug_logging.ml) - Interactive debugging tutorial

## Architecture

The library provides two API layers:

### Low-level: Generated Methods

```ocaml
(* Direct access to all 232 Telegram Bot API methods *)
open Telegram_generated

match Gen_methods.send_message client ~chat_id ~text:"Hello" () with
| Ok message -> (* handle success *)
| Error err -> (* handle error *)
```

### High-level: Ergonomic DSL

```ocaml
(* Helpers for common patterns *)
Tg.Polling.run client ~handler    (* Long polling *)
Tg.Keyboard.reply [["Button 1"]]  (* Reply keyboards *)
Tg.Keyboard.inline [[...]]         (* Inline keyboards *)
```

## Examples

See the [`examples/`](examples/) directory for 40+ complete, runnable examples:

### Basic Examples
- **[hello_world.ml](examples/hello_world.ml)** - Simplest bot with `/start` command
- **[echo_bot.ml](examples/echo_bot.ml)** - Simple echo bot with long polling
- **[command_bot.ml](examples/command_bot.ml)** - Command routing and argument parsing
- **[keyboard_bot.ml](examples/keyboard_bot.ml)** - Interactive keyboards and callbacks
- **[file_bot.ml](examples/file_bot.ml)** - File uploads and downloads

### Recipe Examples (Cookbook)
- **[recipe_echo_bot.ml](examples/recipe_echo_bot.ml)** - Feature-rich echo with transformations
- **[recipe_command_bot.ml](examples/recipe_command_bot.ml)** - Multi-command bot with help system
- **[recipe_keyboard_bot.ml](examples/recipe_keyboard_bot.ml)** - Advanced keyboard patterns
- **[recipe_file_bot.ml](examples/recipe_file_bot.ml)** - Complete file handling example
- **[recipe_webhook_bot.ml](examples/recipe_webhook_bot.ml)** - Webhook deployment example

### Advanced Tutorials
- **[task_1_1_3_*.ml](examples/)** - Comprehensive tutorials covering:
  - Keyboard API, Command DSL, Message Handling
  - Callback Queries, Media Files, Update Processing
  - Error Handling, Session Management, State Machines
  - Concurrency Patterns, Bot Composition, Middleware
  - Testing Patterns, Use Cases, Development Workflow

See [`examples/README.md`](examples/README.md) for the complete index.

## Requirements

- **OCaml 5.1+** (for Eio effects)
- **Eio 0.12+** (structured concurrency)
- See [ocaml_telegram_eio.opam](ocaml_telegram_eio.opam) for full dependency list

## Development

### Build

```bash
# Clone the repository
git clone https://github.com/oleg-nexo/ocaml_telegram_eio.git
cd ocaml_telegram_eio

# Install dependencies
opam install --deps-only .

# Build
dune build

# Run tests
dune runtest

# Build documentation
dune build @doc
```

### Regenerate Types from Bot API Spec

```bash
# Download latest specification from Telegram
./scripts/bootstrap.sh

# Regenerate types and methods
./scripts/regenerate.sh

# Run tests to verify
dune runtest
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for development workflow.

## Project Status

**Version 0.1.0** - Alpha

- ✅ Core functionality complete
- ✅ All Bot API types and methods implemented (449 types, 232 methods)
- ✅ High-level Bot DSL with functional builder pattern
- ✅ Comprehensive test coverage
- ✅ 40+ working examples with detailed documentation
- ⚠️ Some production features pending (advanced rate limiting)

**Development Roadmap**: 44/51 tasks (86%) - see [ROADMAP.md](ROADMAP.md)
- Phase 1 (Documentation): 37/37 (100%) ✓
- Phase 2 (Production Features): 7/14 (50%)

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

1. Report bugs or request features via [GitHub Issues](https://github.com/oleg-nexo/ocaml_telegram_eio/issues)
2. Submit pull requests with tests and documentation
3. Follow the existing code style and conventions

## Acknowledgments

- Built with [Eio](https://github.com/ocaml-multicore/eio) for structured concurrency
- Types auto-generated from [Telegram Bot API](https://core.telegram.org/bots/api) specification
- Inspired by ergonomic bot frameworks in other languages

## See Also

- [Telegram Bot API Documentation](https://core.telegram.org/bots/api)
- [Eio Documentation](https://github.com/ocaml-multicore/eio)
- [OCaml Effects](https://v2.ocaml.org/manual/effects.html)

