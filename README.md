# ocaml_telegram_eio

[![OCaml](https://img.shields.io/badge/OCaml-5.1%2B-orange.svg)](https://ocaml.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Type-safe Telegram Bot API client for OCaml using Eio.

## Features

- ✅ **Fully type-safe API** with phantom-typed identifiers
- ✅ **Complete Bot API coverage**: 449 types, 232 methods (auto-generated from spec)
- ✅ **Direct-style concurrency** using Eio effects (no monads, no callbacks)
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

### Simple Echo Bot

```ocaml
let () =
  let token = Sys.getenv "<TELEGRAM_BOT_TOKEN>" in

  Eio_main.run @@ fun env ->
  let client = Telegram.Client.create ~env ~token () in

  let handler update =
    let open Telegram_generated.Gen_types in
    match update.Update.message with
    | Some msg ->
        let chat_id = Telegram.Id.Chat.of_int msg.Message.chat.Chat.id in
        let text = Option.value msg.Message.text ~default:"" in
        if text <> "" then
          ignore (Gen_methods.send_message client ~chat_id
                   ~text:("Echo: " ^ text) ())
    | None -> ()
  in

  Tg.Polling.run client ~handler
```

Run it:

```bash
export TELEGRAM_BOT_TOKEN="your_token_here"
dune exec examples/echo_bot.exe
```

## Documentation

- **[Getting Started Guide](docs/)** - Installation and first bot
- **[API Reference](https://yourusername.github.io/ocaml-telegram-eio/)** - Full API documentation
- **[Migration Guide](docs/MIGRATION.md)** - Migrating from Lwt/Async or other libraries
- **[FAQ](docs/FAQ.md)** - Frequently asked questions
- **[Examples](examples/)** - Working bot examples
- **[CHANGELOG](CHANGELOG.md)** - Version history and release notes
- **[VERSIONING](VERSIONING.md)** - Semantic versioning policy
- **[COMPATIBILITY](COMPATIBILITY.md)** - Bot API compatibility and update policy

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

See the [`examples/`](examples/) directory for complete, runnable examples:

- **[echo_bot.ml](examples/echo_bot.ml)** - Simple echo bot with long polling
- **[command_bot.ml](examples/command_bot.ml)** - Command routing and argument parsing
- **[keyboard_bot.ml](examples/keyboard_bot.ml)** - Interactive keyboards and callbacks
- **[file_bot.ml](examples/file_bot.ml)** - File uploads and downloads

## Requirements

- **OCaml 5.1+** (for Eio effects)
- **Eio 0.12+** (structured concurrency)
- See [ocaml_telegram_eio.opam](ocaml_telegram_eio.opam) for full dependency list

## Development

### Build

```bash
# Clone the repository
git clone https://github.com/yourusername/ocaml-telegram-eio.git
cd ocaml-telegram-eio

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
- ✅ All Bot API types and methods implemented
- ✅ Comprehensive test coverage
- ⚠️ High-level Bot DSL partially implemented
- ⚠️ Some production features pending (rate limiting, retry policies)

See [PLAN.md](PLAN.md) for detailed roadmap (45/92 tasks complete, 49%).

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

1. Report bugs or request features via [GitHub Issues](https://github.com/yourusername/ocaml-telegram-eio/issues)
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

