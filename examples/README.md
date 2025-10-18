# Examples

This directory contains 40+ working examples demonstrating the ocaml_telegram_eio library.

## Prerequisites

All examples require a Telegram Bot Token:

```bash
export TELEGRAM_BOT_TOKEN="your_token_here"
```

Get your token from [@BotFather](https://t.me/BotFather) on Telegram.

## Running Examples

```bash
# From project root
dune exec examples/basic/hello_world.exe
dune exec examples/recipes/recipe_echo_bot.exe
dune exec examples/advanced/keyboard_api.exe
```

---

## Basic Examples (`basic/`)

Simple examples for getting started:

| Example | Description | Key Features |
|---------|-------------|--------------|
| **hello_world.ml** | Simplest bot - responds to /start | Bot.make, command handler |
| **echo_bot.ml** | Echo messages back to user | Long polling, message handling |
| **echo_enhanced.ml** | Echo with command routing | Multiple commands, text events |
| **command_bot.ml** | Command routing and args | Argument parsing, validation |
| **command_tutorial.ml** | Bot DSL tutorial | Bot.Args helpers, error handling |
| **keyboard_bot.ml** | Interactive keyboards | Reply & inline keyboards, callbacks |
| **file_bot.ml** | File uploads and downloads | Media handling, file operations |
| **core_concepts_demo.ml** | Fundamental patterns | Lifecycle, monadic composition |

**Start here**: `hello_world.ml` → `echo_bot.ml` → `command_bot.ml`

---

## Recipe Examples (`recipes/`)

Cookbook-style examples for common bot patterns:

| Example | Description | Features |
|---------|-------------|----------|
| **recipe_echo_bot.ml** | Feature-rich echo bot | Text transformations, sessions, styles |
| **recipe_command_bot.ml** | Multi-command bot | Command registry, help system, admin auth |
| **recipe_keyboard_bot.ml** | Advanced keyboard patterns | Dynamic keyboards, state management |
| **recipe_file_bot.ml** | Complete file handling | Upload, download, streaming, previews |
| **recipe_webhook_bot.ml** | Webhook deployment | Webhook setup, TLS, server integration |
| **recipe_chatbot_context.ml** | Contextual conversations | Multi-turn dialogs, context tracking |
| **recipe_notification_bot.ml** | Push notifications | Scheduled messages, broadcast |
| **recipe_poll_quiz_bot.ml** | Polls and quizzes ⚠️ | Interactive polls, quiz mode |
| **recipe_inline_bot.ml** | Inline query handling ⚠️ | Inline mode, article results |
| **recipe_group_management_bot.ml** | Group admin features ⚠️ | Member management, permissions |
| **recipe_payment_bot.ml** | Payment integration ⚠️ | Telegram Payments, invoices |
| **recipe_games_bot.ml** | Game bot ⚠️ | HTML5 games, scoring |

⚠️ = May have compilation errors (WIP)

---

## Advanced Examples (`advanced/`)

Comprehensive tutorials covering all library features:

### API Components

| Example | Description |
|---------|-------------|
| **keyboard_api.ml** | Keyboard creation patterns |
| **command_dsl.ml** | Command DSL deep dive |
| **message_handling.ml** | Message processing patterns |
| **callback_queries.ml** | Callback query handling |
| **media_files.ml** | Media handling examples |
| **update_processing.ml** | Update routing strategies |
| **error_handling.ml** | Error handling patterns |
| **session_management.ml** | Session storage patterns |
| **state_machines.ml** | State machine patterns |

### Advanced Patterns

| Example | Description |
|---------|-------------|
| **concurrency_patterns.ml** | Eio concurrency examples |
| **bot_composition.ml** | Composing bots |
| **middleware_architecture.ml** | Middleware patterns |
| **testing_patterns.ml** | Testing strategies |

### Use Cases

| Example | Description |
|---------|-------------|
| **usecase_utility_bots.ml** | Utility bot examples |
| **usecase_content_bots.ml** | Content delivery bots |
| **usecase_entertainment_bots.ml** | Entertainment bots |
| **usecase_integration_bots.ml** | Integration bots |

### Project Setup

| Example | Description |
|---------|-------------|
| **project_structure.ml** | Project organization |
| **development_workflow.ml** | Development workflow |
| **migration_guide.ml** | Migration examples |

### Reference

| Example | Description |
|---------|-------------|
| **faq.ml** | FAQ code examples |
| **index.ml** | Index/overview |

---

## Example Structure

Each example follows this pattern:

```ocaml
(* Purpose: What this example demonstrates *)
(* How to run: dune exec examples/basic/hello_world.exe *)
(* Expected behavior: Bot responds to /start with greeting *)

open Telegram

let () =
  let token = Sys.getenv "TELEGRAM_BOT_TOKEN" in
  Eio_main.run @@ fun env ->
  let client = Client.create ~env ~token () in

  Bot.make ~env ~client
  |> Bot.command "start" (fun ctx _args ->
      match Bot.Ctx.reply ctx "Hello!" with
      | Ok _ -> ()
      | Error err -> Eio.traceln "Error: %a" Error.pp err
    )
  |> Bot.run
```

---

## Common Patterns

### Error Handling

```ocaml
(* Pattern 1: Match on Result *)
match Bot.Ctx.reply ctx "Message" with
| Ok _ -> ()
| Error err -> Eio.traceln "Error: %a" Telegram.Error.pp err

(* Pattern 2: Monadic composition *)
let open Bot.Ctx in
let* user = require_user ctx in
let* () = reply_ ctx "Processing..." in
reply_ ctx "Done!"
```

### Verbose Logging

Examples use comprehensive logging for troubleshooting:

```ocaml
Eio.traceln "📨 Received /start command";
match Bot.Ctx.reply ctx "Hello!" with
| Ok _ -> Eio.traceln "✅ Reply sent"
| Error err -> Eio.traceln "❌ Error: %a" Telegram.Error.pp err
```

---

## Troubleshooting

**Bot is silent?**
- Check token: `echo $TELEGRAM_BOT_TOKEN`
- Enable verbose logging (see examples)
- Check for compilation warnings

**Can't find executable?**
- Build first: `dune build`
- Check path: `dune exec -- examples/basic/hello_world.exe`

**Import errors?**
- Examples use: `ocaml_telegram_eio.telegram`, `ocaml_telegram_eio.tg`
- Check `examples/dune` for library dependencies

---

## Contributing

When adding new examples:
1. Place in appropriate directory (`basic/`, `recipes/`, `advanced/`)
2. Add to `examples/dune`
3. Add to this README with description
4. Ensure code compiles with zero warnings
5. Include verbose logging for debugging
6. Test that example actually works

See [CONTRIBUTING.md](../CONTRIBUTING.md) for full guidelines.
