#!/bin/bash
# Script to convert Eio.traceln to Flo logging

set -e

# Function to convert a single file
convert_file() {
    local file="$1"
    echo "Converting $file..."

    # Create backup
    cp "$file" "$file.bak"

    # Convert patterns:
    # 1. Simple string messages -> Flo.debug or Flo.info based on context
    # 2. Printf-style messages -> Flo.debugf
    # 3. Messages with %a (Error.pp) -> use Format.asprintf

    sed -i \
        -e 's/Eio\.traceln "\[Init\]/Flo.info "[Init]/g' \
        -e 's/Eio\.traceln "\[Start\]/Flo.info "[Start]/g' \
        -e 's/Eio\.traceln "╔/Flo.info "╔/g' \
        -e 's/Eio\.traceln "║/Flo.info "║/g' \
        -e 's/Eio\.traceln "╚/Flo.info "╚/g' \
        -e 's/Eio\.traceln "===/Flo.info "===/g' \
        -e 's/Eio\.traceln "🤖/Flo.info "🤖/g' \
        -e 's/Eio\.traceln "\[Polling\]/Flo.info "[Polling]/g' \
        -e 's/Eio\.traceln "Features:/Flo.info "Features:/g' \
        -e 's/Eio\.traceln "  -/Flo.info "  -/g' \
        -e 's/Eio\.traceln "";/Flo.debug "";/g' \
        -e 's/Eio\.traceln ""/Flo.debug ""/g' \
        -e 's/Eio\.traceln "\[Handler\] ✅/Flo.success "[Handler] ✅/g' \
        -e 's/Eio\.traceln "\[Handler\] ❌/Flo.error "[Handler] ❌/g' \
        -e 's/Eio\.traceln "\[.*\] ✅/Flo.success "&/g' | \
    sed -i \
        -e 's/Eio\.traceln "\[.*\] ❌/Flo.error "&/g' \
        "$file"

    # Convert remaining Eio.traceln to Flo.debug
    sed -i 's/Eio\.traceln/Flo.debugf/g' "$file"

    # Fix double quotes for simple strings (no formatting)
    sed -i 's/Flo\.debugf "\([^%]*\)";/Flo.debug "\1";/g' "$file"

    # Convert %a Error.pp pattern to Format.asprintf
    # This is complex and might need manual adjustment

    echo "Converted $file"
}

# List of files to convert
files=(
    "examples/recipes/recipe_chatbot_context.ml"
    "examples/recipes/recipe_command_bot.ml"
    "examples/recipes/recipe_file_bot.ml"
    "examples/recipes/recipe_games_bot.ml"
    "examples/recipes/recipe_group_management_bot.ml"
    "examples/recipes/recipe_inline_bot.ml"
    "examples/recipes/recipe_payment_bot.ml"
    "examples/recipes/recipe_poll_quiz_bot.ml"
    "examples/recipes/recipe_webhook_bot.ml"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        convert_file "$file"
    else
        echo "File not found: $file"
    fi
done

echo "All files converted!"
echo "Running dune build to check compilation..."
dune build examples/recipes/

echo "Done!"
