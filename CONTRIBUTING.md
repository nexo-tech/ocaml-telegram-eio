# Contributing

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
