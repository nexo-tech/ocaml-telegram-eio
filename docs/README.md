# OCaml Telegram Eio Documentation

This directory contains the API documentation source files for `ocaml_telegram_eio`.

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
open _build/default/_doc/_html/index.html  # macOS
xdg-open _build/default/_doc/_html/index.html  # Linux
```

## Documentation Structure

- `index.mld` - Main documentation index and overview
- `dune` - Dune configuration for documentation

The API reference is automatically generated from `.mli` interface files in the `src/` directory.

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
 (mld_files index getting_started advanced))
```

## Documentation Style Guide

1. **Module headers**: Start with a one-line summary, then detailed description
2. **Examples**: Use `{[ ]}` blocks for code examples
3. **Links**: Reference other modules with `{!Module.function}`
4. **Sections**: Use `{1 }`, `{2 }`, `{3 }` for hierarchical sections
5. **Parameters**: Document with `@param`, `@return`, `@raise`
6. **See also**: Use `@see <url>` for external references

## Hosting Documentation

The documentation can be hosted on GitHub Pages or any static hosting service.

To prepare for GitHub Pages:

```bash
dune build @doc
cp -r _build/default/_doc/_html/ docs-html/
# Commit docs-html/ and configure GitHub Pages to serve from it
```

Alternatively, publish to ocaml.org via opam-publish (recommended for released packages).
