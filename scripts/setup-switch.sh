#!/usr/bin/env bash
set -euo pipefail

OCAML_VERSION="5.2.1"

if ! command -v opam >/dev/null 2>&1; then
  echo "opam not found; please install opam first" >&2
  exit 1
fi

eval "$(opam env)"

if ! opam switch show | grep -q "$(pwd)"; then
  opam switch create . ocaml-base-compiler.$OCAML_VERSION -y || opam switch create . $OCAML_VERSION -y
fi

opam update
opam install . --deps-only -t -y

echo "Run: eval \"\$(opam env)\" to enter the switch"
