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

