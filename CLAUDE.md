# Task Completion Policy

## Requirements

1. Understand library implementation & public API (generated methods + ergonomic wrappers)
2. Documentation code snippets must compile
3. Examples use high-level public API with consistent interface
4. If docs use non-existent API that's nicer than generated API, implement it
5. API must be powerful monadic/functional/combinator style (like Haskell) - elegant and simple
6. Code compiles with zero warnings
7. Library code passes 100% tests, write new tests if new api/implementation is
   introduced
8. Public API changes require documentation updates
9. Mark the task checked in the .md file - [x]
10. Commit when task successfully completed
11. all code examples must have the most verbose logging configured (to
    effectively troubleshoot all the issues)

## Result-Based Error Handling (NO EXCEPTIONS)

**CRITICAL RULE**: This library uses `Result.t` for ALL error handling. Exceptions are FORBIDDEN except at the top-level boundary.

### Core Principles

1. **All operations return Result**: Public API functions return `(ok_type, Error.t) result`
2. **No internal exceptions**: Never use `failwith`, `raise`, `invalid_arg`, etc. inside library code
3. **Exceptions only at boundaries**: Only catch exceptions at FFI/IO boundaries and convert to Result
4. **Monadic composition**: Use `let*` syntax and bind/map operators for chaining

### Why No Exceptions?

❌ **Exceptions are bad because:**
- Hidden control flow - unclear when functions can fail
- Lost context - stack unwinding loses intermediate state
- Difficult composition - can't chain with `|>` or monadic operators
- Runtime surprises - compile-time safety lost
- Messy error handling - try/catch scattered everywhere

✅ **Result is good because:**
- Explicit in types - `('a, 'e) result` shows function can fail
- Composable - works with `let*`, `>>=`, `>>|`, `|>`
- Type-safe - compiler ensures errors are handled
- Traceable - errors propagate through call chain
- Testable - easy to test error cases

### Handler Signature

Handlers MUST return `(unit, Error.t) result`:

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

### Context Accessors Return Result

All Ctx functions that can fail MUST return Result:

```ocaml
(* CORRECT ✅ *)
val client : 'a t -> (Client.t, Error.t) result
val env : 'a t -> (Client.env, Error.t) result
val chat : [ `Chat ] t -> (Id.Chat.k Id.t, Error.t) result
val message : [ `Chat ] t -> (message, Error.t) result
val require_user : 'a t -> (user, Error.t) result

(* WRONG ❌ - using exceptions internally *)
let client c = match c.client with
  | Some cl -> cl
  | None -> failwith "client not set"  (* BAD! Should return Error *)
```

### Error Propagation Pattern

Use monadic binding to propagate errors:

```ocaml
(* Pattern: Early return on error *)
let handle_command ctx args =
  let open Ctx in
  let* user = require_user ctx in
  let* chat_id = chat ctx in
  let* message = message ctx in
  let* () = reply_ ctx (Printf.sprintf "Hello %s!" user.username) in
  Ok ()

(* Errors automatically propagate up - no try/catch needed! *)
```

### Converting to Result (Internal Library Code)

When calling functions that might fail:

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

### Exception Boundary (Top-Level Only)

Only at the very top level (dispatch_update) should we catch exceptions:

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

### Don't Use reply_or_fail Pattern

The old `reply_or_fail` pattern converts Result to exception - this is WRONG:

```ocaml
(* WRONG ❌ - defeats the purpose of Result *)
let reply_or_fail ctx text =
  match Ctx.reply ctx text with
  | Ok msg -> msg
  | Error err -> raise (Failure ...)  (* BAD! Converting Result to exception *)

(* Use this instead: *)
let _ = reply_or_fail ctx "Hello!" in  (* Error hidden! *)

(* CORRECT ✅ - keep Result and propagate *)
let handle ctx =
  let* () = Ctx.reply_ ctx "Hello!" in  (* Errors propagate naturally *)
  Ok ()
```

### Migration Checklist

When refactoring to Result-based:

- [ ] Replace all `failwith` with `Error (...)`
- [ ] Replace all `raise` with `Error (...)`
- [ ] Replace all `invalid_arg` with `Error (Invalid_argument ...)`
- [ ] Change function signatures from `'a` to `('a, Error.t) result`
- [ ] Add `let*` bindings for error propagation
- [ ] Update tests to expect Result types
- [ ] Update examples to use monadic composition

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

`Result.t` in OCaml is not automatically executed. Using `ignore` on a Result
means the computation never runs - the message is never sent!

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

