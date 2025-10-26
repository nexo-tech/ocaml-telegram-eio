#!/usr/bin/env python3
"""
Convert Eio.traceln to Flo logging in recipe files
"""

import re
import sys
from pathlib import Path

def convert_line(line):
    """Convert a single line from Eio.traceln to Flo logging"""

    # Skip if already converted
    if 'Flo.debug' in line or 'Flo.info' in line or 'Flo.success' in line or 'Flo.error' in line:
        return line

    # Skip if not an Eio.traceln line
    if 'Eio.traceln' not in line:
        return line

    # Extract the log message
    match = re.search(r'Eio\.traceln\s+"([^"]*)"', line)
    if not match:
        # Handle multiline or complex cases - keep original for now
        return line

    msg = match.group(1)

    # Determine log level based on message content
    if any(x in msg for x in ['[Init]', '[Start]', 'Phase', '╔', '║', '╚', '===', '🤖', '[Polling]', 'Features:', 'Bot is Ready', 'Starting']):
        level = 'info'
    elif '✅' in msg or '[Success]' in msg or 'success' in msg.lower():
        level = 'success'
    elif '❌' in msg or '[Error]' in msg or 'ERROR' in msg or '✗' in msg:
        level = 'error'
    else:
        level = 'debug'

    # Check if it has format specifiers
    has_format = '%' in msg and any(x in msg for x in ['%s', '%d', '%f', '%b', '%Ld', '%a'])

    if has_format:
        # Check for %a with Error.pp pattern
        if '%a' in line and 'Error.pp' in line:
            # Need to use Format.asprintf for %a
            # Pattern: Eio.traceln "msg: %a" Error.pp err
            # Convert to: Flo.debugf "msg: %s" (Format.asprintf "%a" Error.pp err)
            parts = line.split('Eio.traceln')
            if len(parts) == 2:
                rest = parts[1].strip()
                # This is complex, mark for manual review
                return line.replace('Eio.traceln', f'Flo.{level}f  (* TODO: Convert %a *)')
        else:
            # Regular printf-style formatting
            return line.replace('Eio.traceln', f'Flo.{level}f')
    else:
        # Simple string, no formatting
        return line.replace('Eio.traceln', f'Flo.{level}')

def convert_file(filepath):
    """Convert a single file"""
    print(f"Converting {filepath}...")

    path = Path(filepath)
    if not path.exists():
        print(f"  File not found: {filepath}")
        return False

    # Read file
    with open(path, 'r') as f:
        lines = f.readlines()

    # Convert lines
    converted_lines = [convert_line(line) for line in lines]

    # Count conversions
    original_count = sum(1 for line in lines if 'Eio.traceln' in line)
    remaining_count = sum(1 for line in converted_lines if 'Eio.traceln' in line)

    print(f"  Original Eio.traceln: {original_count}")
    print(f"  Remaining Eio.traceln: {remaining_count}")
    print(f"  Converted: {original_count - remaining_count}")

    # Write file
    with open(path, 'w') as f:
        f.writelines(converted_lines)

    return True

def main():
    """Main function"""
    files = [
        'examples/recipes/recipe_chatbot_context.ml',
        'examples/recipes/recipe_command_bot.ml',
        'examples/recipes/recipe_file_bot.ml',
        'examples/recipes/recipe_games_bot.ml',
        'examples/recipes/recipe_group_management_bot.ml',
        'examples/recipes/recipe_inline_bot.ml',
        'examples/recipes/recipe_payment_bot.ml',
        'examples/recipes/recipe_poll_quiz_bot.ml',
        'examples/recipes/recipe_webhook_bot.ml',
    ]

    total_converted = 0
    for filepath in files:
        if convert_file(filepath):
            total_converted += 1

    print(f"\nTotal files converted: {total_converted}/{len(files)}")
    print("\nNow run: dune build examples/recipes/")

if __name__ == '__main__':
    main()
