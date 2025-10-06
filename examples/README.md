# Examples

This directory contains complete, runnable examples demonstrating the `ocaml-telegram-eio` library.

## Prerequisites

1. Create a Telegram bot via [@BotFather](https://t.me/botfather)
2. Get your bot token
3. Export it as an environment variable:
   ```bash
   export TELEGRAM_BOT_TOKEN="1234567890:ABCdefGHIjklMNOpqrsTUVwxyz"
   ```

## Available Examples

### 1. Echo Bot (`echo_bot.ml`)

A simple bot that echoes back any message you send.

**Features:**
- Long polling for updates
- Basic message handling
- Clean error handling

**Run:**
```bash
export TELEGRAM_BOT_TOKEN="your_token"
dune exec examples/echo_bot.exe
```

### 2. Command Bot (`command_bot.ml`)

A bot with multiple commands and argument parsing.

**Features:**
- Command routing (`/start`, `/help`, `/echo`, `/add`, `/upper`)
- Argument parsing
- Help text generation
- Error handling for invalid inputs

**Commands:**
- `/start` - Welcome message
- `/help` - List all commands
- `/echo <text>` - Echo back the text
- `/add <num1> <num2>` - Add two numbers
- `/upper <text>` - Convert text to uppercase

**Run:**
```bash
export TELEGRAM_BOT_TOKEN="your_token"
dune exec examples/command_bot.exe
```

**Example usage:**
```
You: /add 5 3
Bot: 5 + 3 = 8

You: /upper hello world
Bot: HELLO WORLD
```

### 3. Keyboard Bot (`keyboard_bot.ml`)

Interactive bot with reply and inline keyboards.

**Features:**
- Reply keyboards (persistent buttons below the chat)
- Inline keyboards (buttons attached to messages)
- Callback query handling
- Keyboard removal

**Commands:**
- `/start` - Show reply keyboard
- `/inline` - Show inline keyboard with callbacks
- `/remove` - Remove keyboard

**Run:**
```bash
export TELEGRAM_BOT_TOKEN="your_token"
dune exec examples/keyboard_bot.exe
```

### 4. File Bot (`file_bot.ml`)

Upload and download files (photos and documents).

**Features:**
- Sending photos from local files
- Sending documents with captions
- Receiving and acknowledging uploaded files
- Temporary file handling

**Commands:**
- `/start` - Show help
- `/photo` - Send a test photo
- `/document` - Send a test document
- Send any photo/document - Bot acknowledges receipt

**Run:**
```bash
export TELEGRAM_BOT_TOKEN="your_token"
dune exec examples/file_bot.exe
```

## Building All Examples

Build all examples at once:

```bash
dune build examples/
```

## Code Structure

All examples follow a similar pattern:

1. **Token validation** - Check for `TELEGRAM_BOT_TOKEN` environment variable
2. **Eio setup** - Create Eio environment with `Eio_main.run`
3. **Client creation** - Initialize Telegram client
4. **Bot info** - Fetch and display bot username
5. **Handler definition** - Process updates
6. **Polling** - Start long polling loop

## Common Patterns

### Error Handling

```ocaml
match Telegram.Api.call client request with
| Ok result -> (* handle success *)
| Error err ->
    Printf.eprintf "Error: %s\n" (Telegram.Error.to_string err)
```

### Sending Messages

```ocaml
let send_message client chat_id text =
  let req = Telegram.Api.send_message ~chat_id ~text () in
  match Telegram.Api.call client req with
  | Ok _ -> ()
  | Error err -> (* handle error *)
```

### Command Parsing

```ocaml
if String.length text > 0 && text.[0] = '/' then
  let parts = String.split_on_char ' ' text in
  let cmd = List.hd parts in
  let args = List.tl parts in
  match cmd with
  | "/command" -> (* handle command *)
  | _ -> (* unknown command *)
```

## Debugging

Enable verbose output by adding print statements:

```ocaml
let handle_update update =
  Printf.printf "Update: %s\n" (Yojson.Safe.to_string (Update.to_yojson update));
  (* ... *)
```

## Next Steps

After trying these examples, check out:

- [API Documentation](../docs/index.mld) - Complete API reference
- [Source Code](../src/) - Library implementation
- [Tests](../test/) - Test suite with more usage examples

## Troubleshooting

**Bot doesn't respond:**
- Check that the token is correct
- Verify network connectivity
- Look for error messages in the console

**Build errors:**
- Run `dune clean && dune build`
- Check that all dependencies are installed

**File upload errors:**
- Ensure file paths are correct
- Check file permissions
- Verify file sizes are within Telegram limits
