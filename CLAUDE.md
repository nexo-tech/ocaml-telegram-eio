# Claude Code Automation Instructions

This file contains instructions for Claude Code AI assistant when working on this project.

**For human contributors**: See [CONTRIBUTING.md](CONTRIBUTING.md) for development workflow, coding standards, and best practices.

---

## Task Completion Protocol

When completing tasks from ROADMAP.md or CLEANUP.md, follow this protocol:

1. **Understand library implementation & public API** (generated methods + ergonomic wrappers)
2. **Documentation code snippets must compile**
3. **Examples use high-level public API** with consistent interface
4. **If docs use non-existent API** that's nicer than generated API, implement it
5. **API must be powerful monadic/functional/combinator style** (like Haskell) - elegant and simple
6. **Code compiles with zero warnings**
7. **Library code passes 100% tests**, write new tests if new api/implementation is introduced
8. **Public API changes require documentation updates**
9. **Mark the task checked** in the .md file - `[x]`
10. **Commit when task successfully completed**
11. **All code examples must have the most verbose logging configured** (to effectively troubleshoot all the issues)

---

## Result-Based Error Handling (NO EXCEPTIONS)

**CRITICAL RULE**: This library uses `Result.t` for ALL error handling. Exceptions are FORBIDDEN except at the top-level boundary.

See [CONTRIBUTING.md](CONTRIBUTING.md#result-based-error-handling) for full error handling guidelines.

### Quick Reference

**Handler Signature**: Handlers MUST return `(unit, Error.t) result`:

```ocaml
(* CORRECT ✅ *)
|> command "start" (fun ctx _args ->
    let open Ctx in
    let* user = require_user ctx in
    let* () = reply_ ctx "Hello!" in
    Ok ()
  )

(* WRONG ❌ - returns unit instead of result *)
|> command "start" (fun ctx _args ->
    match Ctx.reply ctx "Hello!" with
    | Ok _ -> ()  (* Should be Ok () *)
    | Error err -> Eio.traceln "%a" Error.pp err  (* Should be Error err *)
  )
```

**Context Accessors Return Result**: All Ctx functions that can fail MUST return Result:

```ocaml
(* CORRECT ✅ *)
val client : 'a t -> (Client.t, Error.t) result
val env : 'a t -> (Client.env, Error.t) result
val chat : [ `Chat ] t -> (Id.Chat.k Id.t, Error.t) result
val message : [ `Chat ] t -> (message, Error.t) result
val require_user : 'a t -> (user, Error.t) result
```

**Error Propagation**: Use monadic binding to propagate errors:

```ocaml
let handle_command ctx args =
  let open Ctx in
  let* user = require_user ctx in
  let* chat_id = chat ctx in
  let* message = message ctx in
  let* () = reply_ ctx (Printf.sprintf "Hello %s!" user.username) in
  Ok ()
```

**Converting to Result**: When calling functions that might fail:

```ocaml
(* CORRECT ✅ *)
let parse_int s =
  match int_of_string_opt s with
  | Some n -> Ok n
  | None -> Error (Decode_error "not a valid integer")

(* WRONG ❌ - letting exception escape *)
let parse_int s =
  int_of_string s  (* Can throw Failure exception! *)
```

**Exception Boundary**: Only at the very top level (dispatch_update) should we catch exceptions:

```ocaml
(* dispatch_update - top-level boundary *)
let dispatch_update client env routes update =
  let rec try_routes = function
    | [] -> Ok ()  (* No route matched - not an error *)
    | route :: rest ->
        match Event.match_event event update with
        | Ok (Some (value, ctx)) ->
            (* Call handler and catch any unexpected exceptions *)
            (try
               handler value ctx  (* This returns (unit, Error.t) result *)
             with exn ->
               (* Convert uncaught exceptions to Error *)
               Error (Internal_error (Printexc.to_string exn)))
        | Ok None -> try_routes rest
        | Error err -> Error err
  in
  try_routes routes
```

---

## Error Handling in Documentation Examples

**CRITICAL**: All documentation examples must handle `Result.t` return values properly.

### Rule: Never use `ignore` on Result values

**WRONG** ❌:
```ocaml
|> command "start" (fun ctx _args ->
    ignore (Ctx.reply ctx "Hello!")  (* This doesn't send the message! *)
  )
```

**RIGHT** ✅:
```ocaml
|> command "start" (fun ctx _args ->
    match Ctx.reply ctx "Hello!" with
    | Ok _ -> ()
    | Error err -> Eio.traceln "Error: %a" Telegram.Error.pp err
  )
```

### Standard Error Handling Patterns

#### Pattern 1: Simple match with logging (recommended for examples)
```ocaml
match Ctx.reply ctx "Message" with
| Ok _ -> ()
| Error err -> Eio.traceln "Error: %a" Telegram.Error.pp err
```

#### Pattern 2: Monadic chaining with let* (for complex flows)
```ocaml
let handler ctx args =
  let open Ctx in
  let* user = require_user ctx in
  let* () = reply_ ctx "Processing..." in
  let* result = some_operation ctx in
  reply_ ctx (Printf.sprintf "Done: %s" result)
```

#### Pattern 3: Ignore only for non-critical operations
```ocaml
(* Only if you genuinely don't care about errors *)
let _ = Ctx.reply ctx "Optional notification" in
do_critical_work ()
```

### Why This Matters

`Result.t` in OCaml is not automatically executed. Using `ignore` on a Result means the computation never runs - the message is never sent!

Always match on Result values to:
1. Actually execute the operation
2. Handle errors gracefully
3. Provide debugging information

### Examples Must Be Correct

All examples in documentation and in `examples/` directory must:
- Compile without warnings
- Actually work when run
- Handle errors explicitly
- Show best practices

---

## Global Error Handler Pattern

Use `Bot.on_error` to catch all exceptions in handlers and route errors globally.

### Pattern: Convert Result errors to exceptions

Create a helper that converts Result errors to exceptions so they go through the global error handler:

```ocaml
(* Helper: Convert Result to exception for global error handler *)
let reply_or_fail ctx text =
  match Ctx.reply ctx text with
  | Ok msg -> msg
  | Error err -> raise (Failure (Format.asprintf "Reply failed: %a" Telegram.Error.pp err))
```

### Pattern: Global error handler with user notification

```ocaml
Bot.make ~env ~client
|> Bot.on_error (fun ctx exn ->
    Eio.traceln "❌ Error in handler: %s" (Printexc.to_string exn);
    Eio.traceln "Backtrace: %s" (Printexc.get_backtrace ());
    (* Try to notify user about the error *)
    match Ctx.reply ctx "❌ Sorry, an error occurred. Please try again." with
    | Ok _ -> ()
    | Error err -> Eio.traceln "Failed to send error message: %a" Telegram.Error.pp err
  )
|> Bot.command "start" (fun ctx _args ->
    Eio.traceln "📨 Received /start command";
    let _ = reply_or_fail ctx "Hello!" in  (* Errors go to on_error handler *)
    ()
  )
|> Bot.run
```

### Benefits of Global Error Handler

1. **Centralized error handling**: All errors logged in one place
2. **User-friendly**: Users get error messages instead of silence
3. **Debug-friendly**: Errors printed to console with backtraces
4. **Less boilerplate**: No need to match on Result in every handler

### Debugging Silent Bots

If your bot is silent, add tracing to see what's happening:

```ocaml
|> Bot.command "start" (fun ctx _args ->
    Eio.traceln "📨 Received /start command";  (* Did command trigger? *)
    let _ = reply_or_fail ctx "Hello!" in
    Eio.traceln "✅ Reply sent successfully";   (* Did reply succeed? *)
  )
```

Common issues:
- Using `ignore` on Result.t (operation never runs)
- Not handling Result.t at all (operation never runs)
- Error thrown but no error handler (error lost)
- Token invalid (check API errors)
