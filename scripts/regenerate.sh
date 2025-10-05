#!/usr/bin/env bash
set -euo pipefail

ref=${1:-reference/api.html}
out_dir=${2:-generated}

echo "Building generators..." >&2
dune build bin/spec_codegen_types.exe bin/spec_codegen_methods.exe bin/telegram_gen.exe

echo "Checking if generated files are up to date..." >&2
if _build/default/bin/telegram_gen.exe --in "$ref" --out-dir "$out_dir" --check; then
  echo "Already up to date." >&2
else
  echo "Regenerating..." >&2
  _build/default/bin/telegram_gen.exe --in "$ref" --out-dir "$out_dir"
fi

echo "Done." >&2
