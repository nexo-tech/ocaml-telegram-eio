# OCaml Telegram Eio Documentation

This directory contains 37 documentation files covering all aspects of the library.

## Prerequisites

Install odoc for building documentation:

```bash
opam install odoc
```

## Building Documentation

Build the HTML documentation with:

```bash
dune build @doc
```

The generated documentation will be in:
```
_build/default/_doc/_html/
```

To view locally:
```bash
# macOS
open _build/default/_doc/_html/index.html

# Linux
xdg-open _build/default/_doc/_html/index.html

# Windows (WSL)
explorer.exe _build/default/_doc/_html/index.html
```

## Documentation Structure

### Getting Started (6 files)
- `index.mld` - Main documentation index and overview
- `getting_started.mld` - Installation and first bot
- `core_concepts.mld` - Core concepts overview
- `quick_start.mld` - Quick start tutorial
- `migration.mld` - Migration guide
- `faq.mld` - Frequently asked questions

### API Components (9 files)
- `keyboard_api.mld` - Keyboard creation patterns
- `command_dsl.mld` - Command DSL deep dive
- `message_handling.mld` - Message processing patterns
- `callback_queries.mld` - Callback query handling
- `media_files.mld` - Media handling examples
- `update_processing.mld` - Update routing strategies
- `error_handling.mld` - Error handling patterns
- `session_management.mld` - Session storage patterns
- `state_machines.mld` - State machine patterns

### Advanced Patterns (4 files)
- `concurrency_patterns.mld` - Eio concurrency examples
- `bot_composition.mld` - Composing bots
- `middleware_architecture.mld` - Middleware patterns
- `testing_patterns.mld` - Testing strategies

### Recipe Examples (12 files)
- `recipe_echo_bot.mld` - Echo bot example
- `recipe_command_bot.mld` - Command routing bot
- `recipe_keyboard_bot.mld` - Keyboard interactions
- `recipe_file_bot.mld` - File upload/download
- `recipe_webhook_bot.mld` - Webhook setup
- `recipe_chatbot_context.mld` - Contextual conversations
- `recipe_notification_bot.mld` - Push notifications
- `recipe_poll_quiz_bot.mld` - Polls and quizzes
- `recipe_inline_bot.mld` - Inline query handling
- `recipe_group_management_bot.mld` - Group admin features
- `recipe_payment_bot.mld` - Payment integration
- `recipe_games_bot.mld` - Game bot

### Use Cases (4 files)
- `usecase_utility_bots.mld` - Utility bot examples
- `usecase_content_bots.mld` - Content delivery bots
- `usecase_entertainment_bots.mld` - Entertainment bots
- `usecase_integration_bots.mld` - Integration bots

### Project Setup (2 files)
- `project_structure.mld` - Project organization
- `development_workflow.mld` - Development workflow

---

## Adding Documentation

### Module Documentation

Add documentation comments to `.mli` files using OCamldoc syntax:

```ocaml
(** Module description.

    Longer description with examples.

    {2 Section Header}

    {[
      (* Code example *)
      let x = 42
    ]}
*)

(** [function arg] does something with [arg].

    @param arg The argument description
    @return The return value description
    @raise Failure when something goes wrong
*)
val function : string -> int
```

### Documentation Pages

Add new `.mld` files to this directory and reference them in `dune`:

```lisp
(documentation
 (package ocaml_telegram_eio)
 (mld_files index getting_started advanced your_new_page))
```

---

## Documentation Style Guide

1. **Module headers**: Start with a one-line summary, then detailed description
2. **Examples**: Use `{[ ]}` blocks for code examples
3. **Links**: Reference other modules with `{!Module.function}`
4. **Sections**: Use `{1 }`, `{2 }`, `{3 }` for hierarchical sections
5. **Parameters**: Document with `@param`, `@return`, `@raise`
6. **See also**: Use `@see <url>` for external references

---

## Publishing Documentation

### GitHub Pages

To prepare documentation for GitHub Pages:

```bash
# Build docs
dune build @doc

# Copy to docs-html/
cp -r _build/default/_doc/_html/ docs-html/

# Commit and push
git add docs-html/
git commit -m "Update documentation"
git push

# Configure GitHub Pages to serve from docs-html/ directory
```

### opam.ocaml.org

For released packages, documentation is automatically built and hosted on ocaml.org:

```bash
# Ensure your opam file has proper metadata
# Release and publish via opam-publish
opam publish
```

The docs will be available at: `https://ocaml.org/p/ocaml_telegram_eio/latest/doc/`

---

## API Reference

The API reference is automatically generated from `.mli` interface files in the `src/` directory.

**Main modules:**
- `Telegram` - Low-level types and API (generated types, Request, Api, Error, Id, Client)
- `Telegram.Bot` - High-level DSL for building bots
- `Telegram.Keyboard` - Keyboard builders
- `Telegram.Session` - Session management
- `Telegram.Polling` - Long polling runner
- `Telegram.Webhook` - Webhook runner

See the generated HTML documentation for complete API reference.
