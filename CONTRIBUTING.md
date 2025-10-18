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
| Error err -> Eio.traceln "Error: %a" Telegram.Error.pp err
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
| Error err -> Eio.traceln "Error: %a" Telegram.Error.pp err
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
