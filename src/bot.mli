(** High-level bot DSL with type-safe routing and session management.

    This module provides an elegant, functional API for building Telegram bots
    with minimal boilerplate. It includes event routing, command parsing,
    entity extraction, and type-safe session management.

    {2 Quick Example}

    {[
      open Bot

      let bot client =
        Bot.make client
        |> Bot.command "start" (fun ctx _args ->
            ctx#reply "Welcome! Use /help for commands"
          )
        |> Bot.command "echo" (fun ctx args ->
            let text = Args.join_rest args 0 in
            ctx#reply text
          )
        |> Bot.on Event.text (fun ctx text ->
            ctx#reply ("You said: " ^ text)
          )
    ]}

    {2 Event Routing}

    Route updates to handlers based on event patterns:

    {[
      bot
      |> on Event.message (fun ctx msg -> ...)
      |> on Event.text (fun ctx text -> ...)
      |> on (Event.command "help") (fun ctx args -> ...)
      |> on Event.callback (fun ctx data -> ...)
      |> on Event.inline_query (fun ctx query -> ...)
    ]}

    {2 Session Management}

    Type-safe sessions with phantom types:

    {[
      type state = { count : int }

      let counter_key = Session.key "counter"

      let handler ctx =
        let* state = ctx#get counter_key |> Result.value ~default:{ count = 0 } in
        let new_state = { count = state.count + 1 } in
        let* () = ctx#set counter_key new_state in
        ctx#reply (Printf.sprintf "Count: %d" new_state.count)
    ]}
*)

(** Bot context with session state of type ['s].
    Provides methods for sending messages, accessing the update, and managing sessions. *)
type +'s ctx

module Event : sig
  type 'a t
  val message : Telegram_generated.Gen_types.Message.t t
  val text : string t
  val command : string -> string list t
  val callback : 'a -> 'a t
  val inline_query : Telegram_generated.Gen_types.InlineQuery.t t
  val any : Telegram_generated.Gen_types.Update.t t
  val ( & ) : 'a t -> 'b t -> ('a * 'b) t
  val when_ : 'a t -> ('a -> bool) -> 'a t
end

module Args : sig
  (** Argument parsing helpers for command handlers *)

  val parse_int : string -> int option
  (** Parse an integer from a string argument *)

  val parse_float : string -> float option
  (** Parse a float from a string argument *)

  val parse_bool : string -> bool option
  (** Parse a boolean from a string argument (true/false, yes/no, 1/0) *)

  val nth : string list -> int -> string option
  (** Get the nth argument from the argument list *)

  val expect_1 : string list -> string option
  (** Match exactly 1 argument *)

  val expect_2 : string list -> (string * string) option
  (** Match exactly 2 arguments *)

  val expect_3 : string list -> (string * string * string) option
  (** Match exactly 3 arguments *)

  val rest : string list -> int -> string list
  (** Get remaining arguments after n *)

  val join_rest : string list -> int -> string
  (** Join remaining arguments after n into a single string *)
end

module Entity : sig
  (** Entity-aware text parsing for Telegram messages *)

  type entity_type =
    | Mention
    | Hashtag
    | Cashtag
    | BotCommand
    | Url
    | Email
    | PhoneNumber
    | Bold
    | Italic
    | Underline
    | Strikethrough
    | Spoiler
    | Code
    | Pre
    | TextLink of string
    | TextMention of Telegram_generated.Gen_types.User.t
    | CustomEmoji of string
    | Other of string

  type entity_info = {
    entity_type : entity_type;
    offset : int;
    length : int;
    text : string;
  }

  val parse_entities : string -> Telegram_generated.Gen_types.MessageEntity.t list option -> entity_info list
  (** Parse all entities from message text *)

  val filter_by_type : [ `BotCommand | `Url | `Mention | `Hashtag | `Code | `Pre ] -> entity_info list -> entity_info list
  (** Filter entities by type *)

  val parse_command_args : string -> Telegram_generated.Gen_types.MessageEntity.t list option -> string list option
  (** Extract command arguments using entity information *)
end

module Middleware : sig
  (** Middleware system for before/after hooks, authorization, and error handling *)

  type 's t
  (** Middleware type with phantom type for context scope *)

  val make :
    ?before:('s ctx -> ('s ctx, string) result) ->
    ?after:('s ctx -> unit) ->
    ?on_error:('s ctx -> exn -> unit) ->
    string -> 's t
  (** Create custom middleware with optional before/after/error hooks.
      - [before]: Run before handler, can transform context or reject request
      - [after]: Run after successful handler execution
      - [on_error]: Run when handler raises an exception
      - name: Middleware identifier for debugging *)

  (** {2 Common Middleware} *)

  val logging : ?prefix:string -> unit -> 's t
  (** Log updates and handler execution. Default prefix is "[Bot]" *)

  val only_users : Telegram.Id.User.k Telegram.Id.t list -> 's t
  (** Only allow updates from specific user IDs *)

  val require_user : unit -> 's t
  (** Require user to be present in update *)

  val require_chat : unit -> 's t
  (** Require chat to be present in update *)

  val rate_limit : max_per_minute:int -> unit -> 's t
  (** Simple in-memory rate limiting per user (max requests per minute) *)

  val enrich : ('s ctx -> 's ctx) -> 's t
  (** Transform/enrich context before handler *)

  val with_session : (module Session.STORE with type store = 's) -> 's -> [ `Chat ] t
  (** Enable sessions using a session store. Automatically loads/saves per-user sessions. *)

  (** {2 Combinators} *)

  val combine : 's t list -> 's t
  (** Combine multiple middleware into one *)

  val ( >> ) : 's t -> 's t -> 's t
  (** Chain operator: [m1 >> m2] runs m1 then m2 *)

  val when_ : ('s ctx -> bool) -> 's t -> 's t
  (** [when_ predicate middleware] conditionally applies middleware based on a predicate.

      The middleware only runs if the predicate returns true for the current context.
      This is useful for applying middleware only in specific situations.

      Example:
      {[
        (* Only log private chats *)
        let is_private ctx = match ctx.chat with
          | Some chat_id -> (* check if private *)
          | None -> false

        Middleware.when_ is_private (Middleware.logging ())
      ]}
  *)

  val with_logging : ?prefix:string -> unit -> 's t
  (** Decorator-style alias for [logging]. Makes code more readable in pipelines.

      Example:
      {[
        Bot.make ~env ~client
        |> Bot.use (Middleware.with_logging ~prefix:"[MyBot]" ())
        |> Bot.command "start" handler
      ]}
  *)

  val require_admin : Telegram.Id.User.k Telegram.Id.t list -> 's t
  (** Decorator-style alias for [only_users]. More descriptive for admin-only routes.

      Example:
      {[
        let admin_ids = [Telegram.Id.User.of_int 123456] in

        Bot.make ~env ~client
        |> Bot.scope [Middleware.require_admin admin_ids]
        |> Bot.command "admin" admin_handler
        |> Bot.end_scope
      ]}
  *)

  val require_all : 's t list -> 's t
  (** Combine multiple middleware that must all pass.

      This is an alias for [combine] with a more descriptive name for authorization checks.

      Example:
      {[
        Middleware.require_all [
          Middleware.require_user ();
          Middleware.rate_limit ~max_per_minute:10 ();
        ]
      ]}
  *)
end

module Ctx : sig
  type +'s t = 's ctx

  (** Basic accessors *)
  val client : _ t -> Telegram.Client.t
  val env : _ t -> Telegram.Client.env
  val chat : [ `Chat ] t -> Telegram.Id.Chat.k Telegram.Id.t
  val user : _ t -> Telegram.Types.user option
  val message : [ `Chat ] t -> Telegram.Types.message

  (** Convenience helpers for sending messages *)

  val reply : [ `Chat ] t -> string -> (Telegram_generated.Gen_types.Message.t, Telegram.Error.t) result
  (** Reply to the current message.
      Sends a message in the same chat and sets reply_parameters to reference
      the current message. *)

  val answer : [ `Chat ] t -> string -> (Telegram_generated.Gen_types.Message.t, Telegram.Error.t) result
  (** Alias for [reply]. *)

  val send : [ `Chat ] t -> string -> (Telegram_generated.Gen_types.Message.t, Telegram.Error.t) result
  (** Send a message to the chat without replying to the current message. *)

  val edit : [ `Chat ] t -> string -> (unit, Telegram.Error.t) result
  (** Edit the current message text.
      Useful for responding to callback queries by editing the message
      that contained the inline keyboard. *)

  val entities : [ `Chat ] t -> Entity.entity_info list
  (** Get all entities from the current message *)

  val get_entities : [ `Chat ] t -> [ `BotCommand | `Url | `Mention | `Hashtag | `Code | `Pre ] -> Entity.entity_info list
  (** Get entities of a specific type from the current message *)

  (** {2 Session Helpers} *)

  val session : _ t -> Session.t
  (** Get the session (fails if session middleware not enabled) *)

  val session_opt : _ t -> Session.t option
  (** Get the session as an option *)

  val session_get : _ t -> 'a Session.key -> 'a option
  (** Get a value from the session *)

  val session_set : _ t -> 'a Session.key -> 'a -> unit
  (** Set a value in the session *)

  val session_get_or : _ t -> 'a Session.key -> default:'a -> 'a
  (** Get a value from session or return default *)

  val session_delete : _ t -> 'a Session.key -> unit
  (** Delete a key from the session *)

  val session_exists : _ t -> 'a Session.key -> bool
  (** Check if a key exists in the session *)

  val session_clear : _ t -> unit
  (** Clear all session data *)

  val session_modify : _ t -> 'a Session.key -> default:'a -> ('a -> 'a) -> unit
  (** Modify a session value, using default if missing *)

  (** {2 Monadic Operations}

      These operations enable elegant error handling using OCaml's monadic syntax.
      All context operations that can fail (like [reply], [send], [edit]) return
      [Result.t] values, which can be chained using [bind] or the [let*] syntax.
  *)

  val return : 'a -> ('a, Telegram.Error.t) result
  (** [return x] wraps a value in [Ok x].

      This is the monadic return operation for Result.

      Example:
      {[
        let handler ctx =
          Ctx.return ()  (* Returns Ok () *)
      ]}
  *)

  val bind : ('a, Telegram.Error.t) result -> ('a -> ('b, Telegram.Error.t) result) -> ('b, Telegram.Error.t) result
  (** [bind result f] is the monadic bind operation for Result.

      If [result] is [Ok x], applies [f] to [x] and returns the result.
      If [result] is [Error e], propagates the error without calling [f].

      This enables chaining operations that can fail.

      Example:
      {[
        let handler ctx =
          bind (Ctx.reply ctx "First message") (fun _msg1 ->
            bind (Ctx.send ctx "Second message") (fun _msg2 ->
              Ctx.return ()
            )
          )
      ]}

      However, it's more idiomatic to use the [let*] syntax (see below).
  *)

  val map : ('a, Telegram.Error.t) result -> ('a -> 'b) -> ('b, Telegram.Error.t) result
  (** [map result f] applies function [f] to the value inside [Ok], or propagates [Error].

      If [result] is [Ok x], returns [Ok (f x)].
      If [result] is [Error e], returns [Error e].

      Example:
      {[
        let handler ctx =
          map (Ctx.reply ctx "Hello") (fun msg ->
            Printf.printf "Sent message with ID: %Ld\n" msg.message_id
          )
      ]}

      However, it's more idiomatic to use the [let+] syntax (see below).
  *)

  val ( let* ) : ('a, Telegram.Error.t) result -> ('a -> ('b, Telegram.Error.t) result) -> ('b, Telegram.Error.t) result
  (** [let* x = expr in body] is syntactic sugar for [bind expr (fun x -> body)].

      This enables elegant monadic syntax for chaining operations that return Result.

      Example:
      {[
        let handler ctx =
          let open Ctx in
          let* msg1 = reply ctx "First message" in
          let* msg2 = send ctx "Second message" in
          let* () = edit ctx "Updated message" in
          return ()
      ]}

      The above is equivalent to:
      {[
        let handler ctx =
          Ctx.bind (Ctx.reply ctx "First message") (fun msg1 ->
            Ctx.bind (Ctx.send ctx "Second message") (fun msg2 ->
              Ctx.bind (Ctx.edit ctx "Updated message") (fun () ->
                Ctx.return ()
              )
            )
          )
      ]}

      Benefits:
      - Errors are automatically propagated (short-circuiting on first error)
      - No need for nested match statements
      - Clean, readable code that focuses on the happy path
      - Type-safe error handling
  *)

  val ( let+ ) : ('a, Telegram.Error.t) result -> ('a -> 'b) -> ('b, Telegram.Error.t) result
  (** [let+ x = expr in body] is syntactic sugar for [map expr (fun x -> body)].

      This enables applicative syntax for Result operations.

      Example:
      {[
        let handler ctx =
          let open Ctx in
          let+ msg = reply ctx "Hello!" in
          Printf.printf "Message ID: %Ld\n" msg.message_id
      ]}

      Use [let+] when you want to transform a successful result without chaining
      another Result-returning operation. Use [let*] when you need to chain operations.
  *)

  (** {2 Handler Combinators}

      These are helper functions designed to work seamlessly with monadic syntax.
      They return Result types and can be chained using [let*] for elegant error handling.
  *)

  val reply_ : [ `Chat ] t -> string -> (unit, Telegram.Error.t) result
  (** [reply_ ctx text] sends a reply and returns [Ok ()] on success.

      This is a simpler version of {!reply} that discards the returned message.
      Useful when you don't need to inspect the sent message and want cleaner code.

      Example:
      {[
        let handler ctx =
          let open Ctx in
          let* () = reply_ ctx "Processing..." in
          (* Do some work *)
          let* () = reply_ ctx "Done!" in
          return ()
      ]}

      Compare with using [reply]:
      {[
        let handler ctx =
          let open Ctx in
          let* _msg1 = reply ctx "Processing..." in
          (* Do some work *)
          let* _msg2 = reply ctx "Done!" in
          return ()
      ]}

      The [reply_] version is cleaner when you don't care about the message object.
  *)

  val require_user : _ t -> (Telegram.Types.user, Telegram.Error.t) result
  (** [require_user ctx] extracts the user from context or returns an error.

      This enables monadic checking of user presence with automatic error handling.

      Example:
      {[
        let handler ctx =
          let open Ctx in
          let* user = require_user ctx in
          let username = Option.value user.username ~default:"Anonymous" in
          reply_ ctx (Printf.sprintf "Hello, %s!" username)
      ]}

      Without this combinator, you'd need explicit pattern matching:
      {[
        let handler ctx =
          match Ctx.user ctx with
          | None -> Error (Api_error "User required")
          | Some user ->
              let username = Option.value user.username ~default:"Anonymous" in
              Ctx.reply_ ctx (Printf.sprintf "Hello, %s!" username)
      ]}

      Returns:
      - [Ok user] if user is present in the update
      - [Error (Api_error "User required...")] if user is missing
  *)

  val require_admin : Telegram.Id.User.k Telegram.Id.t list -> _ t -> (unit, Telegram.Error.t) result
  (** [require_admin admin_ids ctx] checks if the user is in the admin list.

      This is a monadic authorization check that integrates with [let*] syntax.

      Example:
      {[
        let admin_ids = [
          Telegram.Id.User.of_int 123456;
          Telegram.Id.User.of_int 789012;
        ]

        let handler ctx =
          let open Ctx in
          let* () = require_admin admin_ids ctx in
          let* () = reply_ ctx "Admin command executed!" in
          return ()
      ]}

      If the user is not an admin, the function returns an error and the rest
      of the handler is not executed (monadic short-circuiting).

      Returns:
      - [Ok ()] if user is in admin list
      - [Error (Api_error "User required...")] if user is missing
      - [Error (Api_error "Admin privileges required")] if user is not an admin
  *)

  (** {2 Function Composition}

      These operators enable point-free style composition of handler functions.
      They compose functions that work with Result types, enabling elegant
      pipelines without explicit argument passing.
  *)

  val ( >>= ) : ('a -> ('b, Telegram.Error.t) result) -> ('b -> ('c, Telegram.Error.t) result) -> ('a -> ('c, Telegram.Error.t) result)
  (** [f >>= g] composes two monadic functions (both return Result).

      The composed function passes the result of [f] to [g] if successful,
      otherwise propagates the error. This is the Kleisli composition operator
      for Result.

      Example (point-free style):
      {[
        let open Ctx in

        (* Define reusable monadic functions *)
        let get_username ctx =
          let* user = require_user ctx in
          return (Option.value user.username ~default:"Anonymous")

        let greet name ctx =
          reply_ ctx (Printf.sprintf "Hello, %s!" name)

        (* Compose them point-free *)
        let greet_user = get_username >>= greet

        (* Use in handler *)
        let handler ctx =
          greet_user ctx
      ]}

      Compare with explicit style:
      {[
        let handler ctx =
          let open Ctx in
          let* user = require_user ctx in
          let name = Option.value user.username ~default:"Anonymous" in
          reply_ ctx (Printf.sprintf "Hello, %s!" name)
      ]}

      The [>>=] operator enables building reusable, composable handler functions.

      Type signature breakdown:
      - [f : 'a -> ('b, error) result] - First monadic function
      - [g : 'b -> ('c, error) result] - Second monadic function
      - Result: ['a -> ('c, error) result] - Composed function

      Properties:
      - Left identity: [return >>= f] is equivalent to [f]
      - Right identity: [f >>= return] is equivalent to [f]
      - Associativity: [(f >>= g) >>= h] is equivalent to [f >>= (g >>= h)]
  *)

  val ( >>| ) : ('a -> ('b, Telegram.Error.t) result) -> ('b -> 'c) -> ('a -> ('c, Telegram.Error.t) result)
  (** [f >>| g] composes a monadic function with a regular (pure) function.

      The composed function applies [g] to transform the successful result of [f].
      If [f] returns an error, it's propagated without calling [g].

      Example (point-free style):
      {[
        let open Ctx in

        (* Define transformation pipeline *)
        let extract_username user =
          Option.value user.username ~default:"Anonymous"

        let format_greeting name =
          Printf.sprintf "Hello, %s! Welcome to the bot."

        (* Compose: require_user >>| extract_username >>| format_greeting *)
        let get_greeting =
          require_user >>| extract_username >>| format_greeting

        (* Use in handler *)
        let handler ctx =
          let* greeting = get_greeting ctx in
          reply_ ctx greeting
      ]}

      Compare with explicit style:
      {[
        let handler ctx =
          let open Ctx in
          let* user = require_user ctx in
          let name = Option.value user.username ~default:"Anonymous" in
          let greeting = Printf.sprintf "Hello, %s! Welcome to the bot." name in
          reply_ ctx greeting
      ]}

      The [>>|] operator enables clean transformation pipelines.

      Type signature breakdown:
      - [f : 'a -> ('b, error) result] - Monadic function
      - [g : 'b -> 'c] - Pure transformation
      - Result: ['a -> ('c, error) result] - Composed function

      Use [>>|] when transforming values, [>>=] when chaining operations that can fail.
  *)
end

type route

(** {1 Builder Pattern}

    The [bot] type accumulates routes, middleware, and configuration for
    building bots using a functional, composable style with the [|>] operator.

    This is an immutable builder pattern - operations return new [bot] values
    rather than mutating in place.

    Example:
    {[
      Bot.make ~env ~client
      |> Bot.command "start" (fun ctx _args -> Ctx.reply ctx "Welcome!")
      |> Bot.on Event.text (fun ctx text -> Ctx.reply ctx text)
      |> Bot.run
    ]}
*)
type bot

val make : env:Telegram.Client.env -> client:Telegram.Client.t -> bot
(** Create a new bot with empty routes, ready for building with [|>] *)

val run : bot -> unit
(** Run the bot using long polling. Extracts accumulated routes and delegates to [run_polling]. *)

val command : ?desc:string -> string -> ([ `Chat ] ctx -> string list -> unit) -> bot -> bot
(** [command ?desc name handler bot] adds a command handler to the bot.

    The handler receives the context first, then the command arguments.
    This provides better ergonomics for partial application and piping.

    Optional [desc] parameter stores command description for auto-generated help.
    When provided, the description is associated with the command name and can
    be used to generate help messages programmatically.

    Example:
    {[
      Bot.make ~env ~client
      |> Bot.command ~desc:"Start the bot" "start" (fun ctx _args ->
          let _ = Ctx.reply ctx "Welcome!" in ()
        )
      |> Bot.command ~desc:"Echo back your message" "echo" (fun ctx args ->
          let text = String.concat " " args in
          let _ = Ctx.reply ctx text in ()
        )
    ]}

    The descriptions are stored in the bot state as [(command_name, description)]
    pairs and can be used to implement help commands.
*)

val commands : bot -> (string * string) list
(** [commands bot] returns list of registered commands with their descriptions.

    Returns a list of [(command_name, description)] pairs for all commands
    that were registered with descriptions. Useful for implementing help commands.

    Example:
    {[
      let help_text bot =
        Bot.commands bot
        |> List.map (fun (name, desc) -> Printf.sprintf "/%s - %s" name desc)
        |> String.concat "\n"
    ]}
*)

type 'a parser = string list -> ('a, string) result
(** Type-safe argument parser for commands.

    A parser takes a list of string arguments and returns either:
    - [Ok value] on successful parse
    - [Error message] on parse failure with user-friendly error message

    Example parsers:
    {[
      (* Parser that expects exactly 2 integers *)
      let two_ints : (int * int) parser = fun args ->
        match args with
        | [a; b] ->
            (match int_of_string_opt a, int_of_string_opt b with
             | Some x, Some y -> Ok (x, y)
             | _ -> Error "Both arguments must be integers")
        | _ -> Error "Expected exactly 2 arguments"

      (* Parser that expects at least 1 argument *)
      let non_empty : string parser = fun args ->
        match Args.join_rest args 0 with
        | "" -> Error "Please provide some text"
        | text -> Ok text
    ]}
*)

val command_with : ?desc:string -> string -> 'a parser -> ([ `Chat ] ctx -> 'a -> unit) -> bot -> bot
(** [command_with ?desc name parser handler bot] adds a command handler with type-safe argument parsing.

    The parser is run on command arguments. On success, the handler is called with the parsed value.
    On parse failure, an error message is automatically sent to the user.

    This provides stronger type safety than [command] and automatic error handling,
    eliminating boilerplate argument validation code.

    Example:
    {[
      (* Define a parser for two integers *)
      let two_ints args =
        match args with
        | [a; b] ->
            (match int_of_string_opt a, int_of_string_opt b with
             | Some x, Some y -> Ok (x, y)
             | _ -> Error "Both arguments must be integers")
        | _ -> Error "Usage: /add <number1> <number2>"

      Bot.make ~env ~client
      |> Bot.command_with ~desc:"Add two numbers" "add" two_ints
          (fun ctx (a, b) ->
            let result = a + b in
            let _ = Ctx.reply ctx (Printf.sprintf "%d + %d = %d" a b result) in
            ()
          )
    ]}

    The handler receives the parsed value directly, with type ['a] determined by the parser.
    Parse errors are automatically sent to the user with a ❌ prefix.
*)

(** {1 Builder Pattern - Event Routing} *)

val on : 'a Event.t -> ([ `Chat ] ctx -> 'a -> unit) -> bot -> bot
(** [on event handler bot] adds an event handler to the bot.

    The handler receives the context first, then the event data.
    This provides better ergonomics for partial application and piping.

    Example:
    {[
      Bot.make ~env ~client
      |> Bot.on Event.text (fun ctx text ->
          let _ = Ctx.reply ctx ("Echo: " ^ text) in ()
        )
      |> Bot.on Event.message (fun ctx msg ->
          (* Handle any message *)
          let _ = Ctx.send ctx "Got a message!" in ()
        )
      |> Bot.run
    ]}

    Common events:
    - [Event.text] - matches text messages, handler receives string
    - [Event.message] - matches any message, handler receives Message.t
    - [Event.callback] - matches callback queries
    - [Event.inline_query] - matches inline queries
*)

val on_text : ([ `Chat ] ctx -> string -> unit) -> bot -> bot
(** [on_text handler bot] adds a text message handler to the bot.

    This is a convenience method equivalent to [on Event.text handler bot].

    Example:
    {[
      Bot.make ~env ~client
      |> Bot.on_text (fun ctx text ->
          let _ = Ctx.reply ctx ("You said: " ^ text) in ()
        )
      |> Bot.run
    ]}
*)

val on_message : ([ `Chat ] ctx -> Telegram_generated.Gen_types.Message.t -> unit) -> bot -> bot
(** [on_message handler bot] adds a message handler that matches any message.

    This is a convenience method equivalent to [on Event.message handler bot].
    The handler receives the full Telegram Message.t object.

    Example:
    {[
      Bot.make ~env ~client
      |> Bot.on_message (fun ctx msg ->
          let open Telegram_generated.Gen_types in
          let text = Option.value msg.Message.text ~default:"(no text)" in
          let _ = Ctx.send ctx ("Received: " ^ text) in ()
        )
      |> Bot.run
    ]}
*)

val on_callback : ([ `Chat ] ctx -> string -> unit) -> bot -> bot
(** [on_callback handler bot] adds a callback query handler to the bot.

    The handler receives the callback data as a string.
    This matches updates with callback_query field and extracts the data.

    Example:
    {[
      Bot.make ~env ~client
      |> Bot.on_callback (fun ctx data ->
          (* data is the callback_data from inline keyboard button *)
          let _ = Ctx.send ctx ("Callback: " ^ data) in ()
        )
      |> Bot.run
    ]}
*)

val on_photo : ([ `Chat ] ctx -> Telegram_generated.Gen_types.PhotoSize.t list -> unit) -> bot -> bot
(** [on_photo handler bot] adds a photo message handler to the bot.

    The handler receives a list of PhotoSize objects (different resolutions of the same photo).
    This matches messages that contain photos.

    Example:
    {[
      Bot.make ~env ~client
      |> Bot.on_photo (fun ctx photos ->
          let count = List.length photos in
          let _ = Ctx.reply ctx (Printf.sprintf "Got %d photo sizes" count) in ()
        )
      |> Bot.run
    ]}
*)

(** {1 Middleware Integration} *)

val use : [ `Chat ] Middleware.t -> bot -> bot
(** [use middleware bot] adds middleware that applies to all routes in the bot.

    Middleware is accumulated in the bot state and applied globally when [run] is called.
    Middleware runs in the order it was added (first added runs first).

    Example:
    {[
      Bot.make ~env ~client
      |> Bot.use (Middleware.logging ())
      |> Bot.use (Middleware.rate_limit ~max_per_minute:10 ())
      |> Bot.command "start" (fun ctx _args ->
          (* Both logging and rate_limit middleware will run before this handler *)
          let _ = Ctx.reply ctx "Welcome!" in ()
        )
      |> Bot.run
    ]}

    Common middleware:
    - [Middleware.logging ()] - Log all updates and handler execution
    - [Middleware.rate_limit ~max_per_minute:n ()] - Rate limiting per user
    - [Middleware.only_users ids] - Restrict bot to specific user IDs
    - [Middleware.require_user ()] - Require user to be present in update
    - [Middleware.with_session store] - Enable session management

    Middleware can:
    - Run code before handler ([before] hook)
    - Transform or enrich the context
    - Reject requests (return [Error] from [before])
    - Run code after handler ([after] hook)
    - Handle errors ([on_error] hook)
*)

val scope : [ `Chat ] Middleware.t list -> bot -> bot
(** [scope middlewares bot] adds scoped middleware that applies only to routes added after this call.

    Scoped middleware is temporary - it only affects routes added to the returned bot value.
    Use [end_scope] to clear scoped middleware and return to the previous state.

    This is useful for applying middleware to a subset of routes without affecting others.

    Example:
    {[
      let admin_ids = [Telegram.Id.User.of_int 123456] in

      Bot.make ~env ~client
      |> Bot.command "start" (fun ctx _args ->
          (* No special middleware *)
          let _ = Ctx.reply ctx "Welcome!" in ()
        )
      |> Bot.scope [Middleware.only_users admin_ids]
      |> Bot.command "admin" (fun ctx _args ->
          (* only_users middleware applies here *)
          let _ = Ctx.reply ctx "Admin panel" in ()
        )
      |> Bot.command "ban" (fun ctx _args ->
          (* only_users middleware applies here too *)
          let _ = Ctx.reply ctx "User banned" in ()
        )
      |> Bot.end_scope
      |> Bot.command "help" (fun ctx _args ->
          (* Back to no special middleware *)
          let _ = Ctx.reply ctx "Help text" in ()
        )
      |> Bot.run
    ]}

    Note: Scoped middleware is additive with global middleware from [use].
    Routes get both global and scoped middleware.
*)

val end_scope : bot -> bot
(** [end_scope bot] clears all scoped middleware, returning to the previous middleware state.

    This allows you to stop applying scoped middleware to subsequent routes.
    See [scope] for examples.
*)

(** {1 Error Handling} *)

val on_error : ([ `Chat ] ctx -> exn -> unit) -> bot -> bot
(** [on_error handler bot] sets a global error handler for all routes in the bot.

    The error handler is called when any route handler raises an exception.
    This overrides the default error handling behavior.

    The handler receives the context and the exception that was raised.

    Example:
    {[
      Bot.make ~env ~client
      |> Bot.on_error (fun ctx exn ->
          (* Log error *)
          Printf.eprintf "Error in handler: %s\n" (Printexc.to_string exn);
          (* Try to notify user *)
          let _ = Ctx.reply ctx "Sorry, an error occurred!" in
          ()
        )
      |> Bot.command "start" (fun ctx _args ->
          (* If this raises, on_error handler is called *)
          let _ = Ctx.reply ctx "Welcome!" in ()
        )
      |> Bot.run
    ]}

    Note: Route-specific error handlers (via [with_error_handler]) take precedence
    over the global error handler.

    Common use cases:
    - Logging errors to a file or service
    - Sending error notifications to users
    - Recovering gracefully from errors
    - Implementing custom retry logic

    See also [ErrorHandler] module for pre-built error handlers:
    - [ErrorHandler.log] - Log to stderr
    - [ErrorHandler.log_and_reply] - Log and send message to user
    - [ErrorHandler.silent] - Ignore errors silently
*)

val command_safe : ?desc:string -> string -> ([ `Chat ] ctx -> string list -> (unit, string) result) -> bot -> bot
(** [command_safe ?desc name handler bot] adds a command handler with automatic Result error handling.

    The handler returns a Result type. On [Ok ()], execution continues normally.
    On [Error message], the error message is automatically sent to the user with a ❌ prefix.

    This eliminates the need for manual error handling boilerplate in command handlers.

    Example:
    {[
      Bot.make ~env ~client
      |> Bot.command_safe ~desc:"Divide two numbers" "div" (fun ctx args ->
          match args with
          | [a; b] ->
              (match int_of_string_opt a, int_of_string_opt b with
               | Some x, Some 0 ->
                   Error "Cannot divide by zero!"
               | Some x, Some y ->
                   let result = x / y in
                   let _ = Ctx.reply ctx (string_of_int result) in
                   Ok ()
               | _ ->
                   Error "Both arguments must be integers")
          | _ ->
              Error "Usage: /div <number1> <number2>"
        )
      |> Bot.run
    ]}

    The handler signature is [(ctx -> args -> (unit, string) result)], making it easy
    to chain operations that can fail without explicit error handling at each step.

    Benefits over regular [command]:
    - Explicit error handling in type signature
    - Automatic error message sending
    - No need to manually call [Ctx.reply] for errors
    - Encourages functional error handling patterns

    Note: Like [command], this supports optional [desc] parameter for help generation.
*)

val catch : ([ `Chat ] ctx -> exn -> unit) -> bot -> bot
(** [catch handler bot] sets a scoped error handler that applies to routes added after this call.

    This provides try/catch style error boundaries for specific groups of routes.
    Unlike [on_error] which sets a global error handler, [catch] only affects
    routes added to the returned bot value.

    The scoped error handler takes precedence over the global error handler set by [on_error],
    but is overridden by route-specific handlers set via [with_error_handler].

    Example:
    {[
      Bot.make ~env ~client
      |> Bot.command "safe" (fun ctx _args ->
          (* No special error handling *)
          let _ = Ctx.reply ctx "This is safe" in ()
        )
      |> Bot.catch (fun ctx exn ->
          (* This error handler applies to the next routes *)
          Printf.eprintf "Caught error: %s\n" (Printexc.to_string exn);
          let _ = Ctx.reply ctx "An error occurred in this section" in ()
        )
      |> Bot.command "risky" (fun ctx _args ->
          (* This route has the catch error handler *)
          failwith "Something went wrong!"
        )
      |> Bot.command "also_risky" (fun ctx _args ->
          (* This route also has the catch error handler *)
          raise (Failure "Another error")
        )
      |> Bot.run
    ]}

    Use cases:
    - Apply specialized error handling to a group of related routes
    - Create error boundaries around experimental or high-risk features
    - Provide different error handling for admin vs user commands
    - Implement fallback behavior for specific route sections

    Note: Like scoped middleware from [scope], scoped error handlers persist
    until explicitly cleared or until a new [catch] call replaces them.
    Currently there is no [end_catch] function - error boundaries persist
    for all subsequent routes.

    Priority order (highest to lowest):
    1. Route-specific error handler (via [with_error_handler])
    2. Scoped error handler (via [catch])
    3. Global error handler (via [on_error])
    4. Default error handler (prints to stderr)
*)

(** {1 Route-based API} *)

val route : 'a Event.t -> ('a -> [ `Chat ] ctx -> unit) -> route
(** Create a route from an event matcher and handler.

    This is the low-level route-based API. For the builder pattern, use {!on} instead.

    Note: The handler signature is ('a -> ctx -> unit) - data first, then context.
    This is different from the builder pattern {!on} which uses (ctx -> 'a -> unit).
*)

val with_middleware : [ `Chat ] Middleware.t list -> route -> route
(** Add middleware to a specific route *)

val with_error_handler : ([ `Chat ] ctx -> exn -> unit) -> route -> route
(** Add a custom error handler to a specific route *)

val router :
  ?middlewares:[ `Chat ] Middleware.t list ->
  ?on_error:([ `Chat ] ctx -> exn -> unit) ->
  route list -> route list
(** Create a router with optional global middleware and error handler applied to all routes.
    - [middlewares]: Global middleware applied to all routes
    - [on_error]: Global error handler (overridden by route-specific handlers) *)

(** {1 Error Handlers} *)

module ErrorHandler : sig
  val log : [ `Chat ] ctx -> exn -> unit
  (** Log error to stderr with exception details *)

  val log_and_reply : ?message:string -> unit -> [ `Chat ] ctx -> exn -> unit
  (** Log error and send a reply to the user.
      Default message: "Sorry, an error occurred while processing your request." *)

  val silent : [ `Chat ] ctx -> exn -> unit
  (** Silently ignore errors (no logging, no user feedback) *)

  val combine : ([ `Chat ] ctx -> exn -> unit) list -> [ `Chat ] ctx -> exn -> unit
  (** Combine multiple error handlers (all are called in sequence) *)
end

val run_polling : env:Telegram.Client.env -> client:Telegram.Client.t -> route list -> unit
val run_webhook : env:Telegram.Client.env -> client:Telegram.Client.t -> secret_token:string -> addr:[ `Tcp of (string * int) ] -> route list -> unit
