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

  val parse_command_args : string -> Telegram_generated.Gen_types.MessageEntity.t list option -> (string * string list) option
  (** Parse command name and arguments from message text and entities.
      Returns (command_name, args) option where command_name has no leading slash or @botname.
      This function parses entities only once to avoid infinite loops. *)
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

  (** {2 Stateful Handlers}

      These are ergonomic aliases for session operations, providing a cleaner API
      for stateful bot handlers. They maintain type-safety through [Session.key]
      phantom types and offer a more intuitive naming convention.

      Example - Counter Bot:
      {[
        let counter_key = Session.key "counter"

        let increment_handler ctx _args =
          (* Get current count, default to 0 *)
          let count = Option.value (Ctx.get_state ctx counter_key) ~default:0 in
          (* Increment and save *)
          Ctx.set_state ctx counter_key (count + 1);
          (* Reply with new count *)
          ignore (Ctx.reply ctx (Printf.sprintf "Count: %d" (count + 1)))

        let reset_handler ctx _args =
          (* Reset counter to 0 *)
          Ctx.set_state ctx counter_key 0;
          ignore (Ctx.reply ctx "Counter reset!")
      ]}

      Example - User Preferences:
      {[
        type prefs = { theme : string; lang : string }

        let prefs_key = Session.key "preferences"

        let set_theme_handler ctx args =
          let theme = Args.join_rest args 0 in
          (* Modify preferences, updating only the theme *)
          Ctx.modify_state ctx prefs_key
            ~default:{ theme = "light"; lang = "en" }
            (fun p -> { p with theme });
          ignore (Ctx.reply ctx "Theme updated!")
      ]}

      Example - State Machine:
      {[
        type state = Idle | AwaitingName | AwaitingAge

        let state_key = Session.key "state"
        let name_key = Session.key "name"

        let start_handler ctx _args =
          Ctx.set_state ctx state_key AwaitingName;
          ignore (Ctx.reply ctx "What's your name?")

        let text_handler ctx text =
          match Ctx.get_state ctx state_key with
          | Some AwaitingName ->
              Ctx.set_state ctx name_key text;
              Ctx.set_state ctx state_key AwaitingAge;
              ignore (Ctx.reply ctx "How old are you?")
          | Some AwaitingAge ->
              let name = Option.value (Ctx.get_state ctx name_key) ~default:"" in
              ignore (Ctx.reply ctx (Printf.sprintf "Hi %s, age %s!" name text));
              Ctx.set_state ctx state_key Idle
          | _ -> ()
      ]}
  *)

  val get_state : _ t -> 'a Session.key -> 'a option
  (** [get_state ctx key] retrieves a value from the session.

      Returns [Some value] if the key exists, [None] otherwise.
      This is an ergonomic alias for [session_get].

      Type-safe: The return type matches the key's phantom type.

      Example:
      {[
        let counter_key = Session.key "counter"

        let handler ctx =
          match Ctx.get_state ctx counter_key with
          | Some count -> Printf.printf "Count is %d\n" count
          | None -> Printf.printf "Counter not initialized\n"
      ]}
  *)

  val set_state : _ t -> 'a Session.key -> 'a -> unit
  (** [set_state ctx key value] stores a value in the session.

      This is an ergonomic alias for [session_set].

      Type-safe: The value type must match the key's phantom type.

      Example:
      {[
        let counter_key = Session.key "counter"

        let handler ctx =
          Ctx.set_state ctx counter_key 42;
          ignore (Ctx.reply ctx "Counter set to 42!")
      ]}
  *)

  val modify_state : _ t -> 'a Session.key -> default:'a -> ('a -> 'a) -> unit
  (** [modify_state ctx key ~default f] atomically updates a session value.

      If the key doesn't exist, uses [default] as the initial value.
      Applies function [f] to the current (or default) value and stores the result.

      This is an ergonomic alias for [session_modify].

      Type-safe: All types must match the key's phantom type.

      Example:
      {[
        let counter_key = Session.key "counter"

        let handler ctx =
          (* Increment counter, starting from 0 if not set *)
          Ctx.modify_state ctx counter_key ~default:0 (fun n -> n + 1);
          let count = Option.value (Ctx.get_state ctx counter_key) ~default:0 in
          ignore (Ctx.reply ctx (Printf.sprintf "New count: %d" count))
      ]}

      Example with complex state:
      {[
        type user_prefs = {
          notifications : bool;
          language : string;
          theme : string;
        }

        let prefs_key = Session.key "prefs"

        let toggle_notifications_handler ctx =
          Ctx.modify_state ctx prefs_key
            ~default:{ notifications = true; language = "en"; theme = "light" }
            (fun p -> { p with notifications = not p.notifications });
          ignore (Ctx.reply ctx "Notifications toggled!")
      ]}
  *)

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

(** {1 Bot Composition} *)

val merge : bot -> bot -> bot
(** [merge bot1 bot2] combines two bots into a single bot.

    This enables modular bot construction by composing smaller, focused bots
    into a larger application. Routes from [bot1] are processed before routes
    from [bot2], giving [bot1] higher priority in pattern matching.

    Merging behavior:
    - Routes: [bot1.routes @ bot2.routes] (bot1 routes have priority)
    - Middleware: [bot1.middleware @ bot2.middleware] (both apply in order)
    - Command descriptions: Combined from both bots
    - Client/env: Uses [bot2]'s (current state)
    - Global error handler: Uses [bot2]'s if set, otherwise [bot1]'s
    - Scoped state: Uses [bot2]'s (current middleware/error handler scope)

    Example - Modular bot construction:
    {[
      (* Define focused sub-bots *)
      let public_bot client =
        Bot.make ~env ~client
        |> Bot.command ~desc:"Start the bot" "start" (fun ctx _args ->
            let _ = Ctx.reply ctx "Welcome!" in ()
          )
        |> Bot.command ~desc:"Show help" "help" (fun ctx _args ->
            let _ = Ctx.reply ctx "Available commands: /start, /help" in ()
          )

      let admin_bot admin_ids client =
        Bot.make ~env ~client
        |> Bot.use (Middleware.only_users admin_ids)
        |> Bot.command ~desc:"Show stats" "stats" (fun ctx _args ->
            let _ = Ctx.reply ctx "Stats: ..." in ()
          )
        |> Bot.command ~desc:"Ban user" "ban" (fun ctx _args ->
            let _ = Ctx.reply ctx "User banned" in ()
          )

      (* Combine into full bot *)
      let full_bot =
        Bot.merge (public_bot client) (admin_bot admin_ids client)
        |> Bot.run
    ]}

    Example - Feature composition:
    {[
      let echo_bot =
        Bot.make ~env ~client
        |> Bot.on_text (fun ctx text ->
            let _ = Ctx.reply ctx ("Echo: " ^ text) in ()
          )

      let command_bot =
        Bot.make ~env ~client
        |> Bot.command "ping" (fun ctx _args ->
            let _ = Ctx.reply ctx "Pong!" in ()
          )

      (* Combine features *)
      let combined =
        Bot.merge command_bot echo_bot
        |> Bot.run
    ]}

    Route priority example:
    {[
      let specific =
        Bot.make ~env ~client
        |> Bot.command "greet" (fun ctx _args ->
            let _ = Ctx.reply ctx "Hello from specific!" in ()
          )

      let general =
        Bot.make ~env ~client
        |> Bot.command "greet" (fun ctx _args ->
            let _ = Ctx.reply ctx "Hello from general!" in ()
          )

      (* specific's /greet handler runs (higher priority) *)
      let bot = Bot.merge specific general
    ]}

    Note: Both bots should share the same client and env for proper operation.
    The merged bot uses [bot2]'s client/env, but typically they should be identical.

    Use cases:
    - Modular bot architecture (separate public/admin/feature bots)
    - Plugin system (dynamically compose bots)
    - Namespace separation (different bot modules)
    - Incremental bot construction
    - Testing (compose small testable units)
*)

val scope_prefix : string -> bot -> bot
(** [scope_prefix prefix bot] adds a prefix to all command names in the bot.

    This enables command namespacing for modular organization. All commands
    in the bot will have the prefix prepended to their name. Non-command
    routes (text handlers, callbacks, etc.) are left unchanged.

    The prefix is added as-is, so include any separators you want
    (e.g., "admin_", "user_", "mod-").

    Note: Telegram command names can only contain letters, digits, and underscores.
    Using other characters (like "/") may not work properly in Telegram clients.

    Example - Basic namespacing:
    {[
      let admin_commands =
        Bot.make ~env ~client
        |> Bot.command ~desc:"Show statistics" "stats" (fun ctx _args ->
            let _ = Ctx.reply ctx "Statistics: ..." in ()
          )
        |> Bot.command ~desc:"Ban a user" "ban" (fun ctx _args ->
            let _ = Ctx.reply ctx "User banned" in ()
          )
        |> Bot.scope_prefix "admin_"
        (* Commands are now: /admin_stats, /admin_ban *)

      let user_commands =
        Bot.make ~env ~client
        |> Bot.command ~desc:"View profile" "profile" (fun ctx _args ->
            let _ = Ctx.reply ctx "Your profile" in ()
          )
        |> Bot.scope_prefix "user_"
        (* Command is now: /user_profile *)

      let full_bot = Bot.merge admin_commands user_commands |> Bot.run
    ]}

    Example - Modular architecture:
    {[
      (* Define a bot module *)
      let make_crud_bot ~prefix ~entity =
        Bot.make ~env ~client
        |> Bot.command "list" (fun ctx _args ->
            let _ = Ctx.reply ctx (Printf.sprintf "List of %s" entity) in ()
          )
        |> Bot.command "create" (fun ctx _args ->
            let _ = Ctx.reply ctx (Printf.sprintf "Create %s" entity) in ()
          )
        |> Bot.command "delete" (fun ctx _args ->
            let _ = Ctx.reply ctx (Printf.sprintf "Delete %s" entity) in ()
          )
        |> Bot.scope_prefix prefix

      (* Create multiple instances *)
      let users_bot = make_crud_bot ~prefix:"users_" ~entity:"users"
      (* Commands: /users_list, /users_create, /users_delete *)

      let posts_bot = make_crud_bot ~prefix:"posts_" ~entity:"posts"
      (* Commands: /posts_list, /posts_create, /posts_delete *)

      let full_bot =
        Bot.merge users_bot posts_bot
        |> Bot.run
    ]}

    Example - Combined with middleware:
    {[
      let admin_ids = [Telegram.Id.User.of_int 123456]

      let admin_bot =
        Bot.make ~env ~client
        |> Bot.use (Middleware.only_users admin_ids)
        |> Bot.command "restart" (fun ctx _args -> ...)
        |> Bot.command "config" (fun ctx _args -> ...)
        |> Bot.scope_prefix "admin_"
        (* Commands: /admin_restart, /admin_config *)
        (* Both require admin privileges *)
    ]}

    Behavior:
    - Command routes: Command name is prefixed
    - Text handlers: Unchanged (still match all text)
    - Callback handlers: Unchanged
    - Other event handlers: Unchanged
    - Command descriptions: Updated with prefix for help generation

    Note: Apply scope_prefix after defining commands but before merging,
    as it transforms the existing routes in the bot.

    Use cases:
    - Organize commands by feature/module (user_, admin_, mod_)
    - Prevent command name collisions when merging bots
    - Create reusable bot templates with custom prefixes
    - Implement plugin systems with namespaced commands
*)

val when_ : ([ `Chat ] ctx -> bool) -> bot -> bot
(** [when_ predicate bot] conditionally enables/disables all routes in the bot.

    The predicate is checked for every update before executing any route handler.
    If the predicate returns [false], the route handlers do nothing (routes are
    effectively disabled). If it returns [true], routes execute normally.

    This enables dynamic route activation based on runtime conditions like:
    - Time of day (e.g., only during business hours)
    - Feature flags (e.g., enable beta features for specific users)
    - Bot state (e.g., only when maintenance mode is off)
    - User properties (e.g., only for premium users)

    Example - Time-based routing:
    {[
      let is_business_hours _ctx =
        let open Unix in
        let tm = localtime (time ()) in
        tm.tm_hour >= 9 && tm.tm_hour < 17

      let business_bot =
        Bot.make ~env ~client
        |> Bot.command "support" (fun ctx _args ->
            let _ = Ctx.reply ctx "Support team will assist you" in ()
          )
        |> Bot.when_ is_business_hours
        (* Only responds to /support during 9-17 hours *)

      let after_hours_bot =
        Bot.make ~env ~client
        |> Bot.command "support" (fun ctx _args ->
            let _ = Ctx.reply ctx "Support is offline. Please try 9-17" in ()
          )
        |> Bot.when_ (fun ctx -> not (is_business_hours ctx))

      let full_bot = Bot.merge business_bot after_hours_bot |> Bot.run
    ]}

    Example - Feature flags:
    {[
      let beta_features_enabled = ref false

      let beta_bot =
        Bot.make ~env ~client
        |> Bot.command "experimental" (fun ctx _args ->
            let _ = Ctx.reply ctx "Experimental feature!" in ()
          )
        |> Bot.command "beta" (fun ctx _args ->
            let _ = Ctx.reply ctx "Beta command" in ()
          )
        |> Bot.when_ (fun _ctx -> !beta_features_enabled)
        (* Only enabled when flag is true *)

      (* Toggle feature flag *)
      let () = beta_features_enabled := true
    ]}

    Example - User-based conditions:
    {[
      let premium_users = [
        Telegram.Id.User.of_int 123456;
        Telegram.Id.User.of_int 789012;
      ]

      let is_premium ctx =
        match Ctx.user ctx with
        | None -> false
        | Some user -> List.mem user.Telegram.Types.id premium_users

      let premium_bot =
        Bot.make ~env ~client
        |> Bot.command "premium_feature" (fun ctx _args ->
            let _ = Ctx.reply ctx "Premium feature active!" in ()
          )
        |> Bot.when_ is_premium
        (* Only premium users can use these commands *)
    ]}

    Example - Maintenance mode:
    {[
      let maintenance_mode = ref false

      let main_bot =
        Bot.make ~env ~client
        |> Bot.command "start" (fun ctx _args -> ...)
        |> Bot.command "help" (fun ctx _args -> ...)
        |> Bot.when_ (fun _ctx -> not !maintenance_mode)
        (* Disabled during maintenance *)

      let maintenance_bot =
        Bot.make ~env ~client
        |> Bot.on_text (fun ctx _text ->
            let _ = Ctx.reply ctx "Bot is under maintenance. Try later." in ()
          )
        |> Bot.when_ (fun _ctx -> !maintenance_mode)
        (* Only active during maintenance *)

      let full_bot = Bot.merge main_bot maintenance_bot |> Bot.run
    ]}

    Behavior:
    - Predicate is evaluated on every update
    - All routes in the bot are affected
    - If predicate returns false, handlers do nothing
    - Middleware still runs (only handlers are conditional)
    - Can be combined with other transformations (scope_prefix, merge, etc.)

    Note: The predicate should be fast as it's evaluated for every update.
    Avoid expensive operations in the predicate.

    Use cases:
    - Time-based routing (business hours, weekends)
    - Feature flags (A/B testing, gradual rollouts)
    - User segmentation (premium/free, beta testers)
    - Maintenance mode (disable main bot, show maintenance message)
    - Dynamic bot behavior based on external state
*)

(** {1 Session Integration} *)

val with_sessions : (module Session.STORE with type store = 's) -> 's -> bot -> bot
(** [with_sessions (module Store) store bot] auto-enables session middleware for the bot.

    This is a convenience function that automatically applies session middleware,
    eliminating the need to manually use [Bot.use] with [Middleware.with_session].

    Sessions allow you to store per-user state across multiple updates. The session
    is automatically loaded for each user and made available in the context via
    [Ctx.session] and related helpers.

    Example - Basic session usage:
    {[
      (* Create a session store *)
      let store = Session.Memory_store.create ()

      (* Define a session key *)
      let count_key = Session.key "message_count"

      let bot =
        Bot.make ~env ~client
        |> Bot.with_sessions (module Session.Memory_store) store
        |> Bot.command "count" (fun ctx _args ->
            (* Get current count from session *)
            let count = Ctx.session_get_or ctx count_key ~default:0 in
            let new_count = count + 1 in
            (* Save new count to session *)
            Ctx.session_set ctx count_key new_count;
            let _ = Ctx.reply ctx (Printf.sprintf "Message count: %d" new_count) in
            ()
          )
        |> Bot.run
    ]}

    Example - Counter bot with sessions:
    {[
      let store = Session.Memory_store.create ()
      let counter_key = Session.key "counter"

      let bot =
        Bot.make ~env ~client
        |> Bot.with_sessions (module Session.Memory_store) store
        |> Bot.command "increment" (fun ctx _args ->
            Ctx.session_modify ctx counter_key ~default:0 (fun n -> n + 1);
            let count = Ctx.session_get_or ctx counter_key ~default:0 in
            let _ = Ctx.reply ctx (Printf.sprintf "Counter: %d" count) in
            ()
          )
        |> Bot.command "reset" (fun ctx _args ->
            Ctx.session_set ctx counter_key 0;
            let _ = Ctx.reply ctx "Counter reset" in ()
          )
        |> Bot.run
    ]}

    Example - User preferences:
    {[
      type language = EN | FR | ES

      let store = Session.Memory_store.create ()
      let lang_key = Session.key "language"

      let bot =
        Bot.make ~env ~client
        |> Bot.with_sessions (module Session.Memory_store) store
        |> Bot.command "setlang" (fun ctx args ->
            let lang = match args with
              | ["en"] -> Some EN
              | ["fr"] -> Some FR
              | ["es"] -> Some ES
              | _ -> None
            in
            match lang with
            | Some l ->
                Ctx.session_set ctx lang_key l;
                let _ = Ctx.reply ctx "Language updated" in ()
            | None ->
                let _ = Ctx.reply ctx "Usage: /setlang [en|fr|es]" in ()
          )
        |> Bot.command "greet" (fun ctx _args ->
            let lang = Ctx.session_get_or ctx lang_key ~default:EN in
            let greeting = match lang with
              | EN -> "Hello!"
              | FR -> "Bonjour!"
              | ES -> "¡Hola!"
            in
            let _ = Ctx.reply ctx greeting in ()
          )
        |> Bot.run
    ]}

    How it works:
    - Creates a session middleware using the provided store
    - Applies it globally to the bot using [Bot.use]
    - For each update with a user, loads the user's session
    - Session is added to the context and accessible via [Ctx.session_*] functions
    - Changes to session are persisted in the store

    Session helpers in Ctx module:
    - [Ctx.session] - Get the session (fails if not enabled)
    - [Ctx.session_opt] - Get the session as an option
    - [Ctx.session_get] - Get a value from the session
    - [Ctx.session_set] - Set a value in the session
    - [Ctx.session_get_or] - Get a value or return default
    - [Ctx.session_delete] - Delete a key from the session
    - [Ctx.session_clear] - Clear all session data
    - [Ctx.session_modify] - Modify a session value

    Note: The built-in [Session.Memory_store] is suitable for development and
    small bots. For production use with multiple bot instances or persistence,
    consider implementing a custom store backed by Redis, PostgreSQL, etc.

    See also:
    - [Session] module for session operations and store interface
    - [Ctx.session_*] functions for session access
    - [Middleware.with_session] for manual middleware setup
*)

(** {1 Session-based Routing}

    Route handlers based on session state for implementing conversational state machines.
    These functions enable multi-step conversations where different handlers are activated
    based on the current session state.

    Common use cases:
    - Multi-step forms (collect name, age, email, etc.)
    - Conversational flows (ask question, await response, provide follow-up)
    - Game states (menu, playing, game over)
    - Wizard-style interactions (step 1, step 2, step 3, etc.)
*)

val when_state : 'a Session.key -> ('a option -> bool) -> bot -> bot
(** [when_state key predicate bot] wraps all routes in the bot to only execute when
    the session state matches the predicate.

    The predicate receives [Some value] if the key exists in the session, or [None] if not.
    If the predicate returns [false], the route handlers do nothing (effectively skip).

    This is useful for scoping multiple handlers to a specific state.

    Example - Name collection state:
    {[
      type state = Idle | AwaitingName | AwaitingAge

      let state_key = Session.key "state"

      (* Only handle text when awaiting name *)
      let name_bot =
        Bot.make ~env ~client
        |> Bot.when_state state_key (fun s -> s = Some AwaitingName)
        |> Bot.on Event.text (fun ctx text ->
            Ctx.set_state ctx name_key text;
            Ctx.set_state ctx state_key AwaitingAge;
            ignore (Ctx.reply ctx "How old are you?")
          )
        |> Bot.on (Event.command "cancel") cancel_handler
    ]}

    Example - Complex state filtering:
    {[
      (* Only active during business hours *)
      let business_hours_bot =
        Bot.make ~env ~client
        |> Bot.when_state status_key (fun s ->
            match s with
            | Some "active" | Some "busy" -> true
            | _ -> false
          )
        |> Bot.on Event.text handle_business_messages
    ]}

    See also:
    - [when_state_eq] for simple equality checks
    - [on_state] for adding single routes with state guards
*)

val when_state_eq : 'a Session.key -> 'a -> bot -> bot
(** [when_state_eq key expected_state bot] is a convenience function that wraps all routes
    to only execute when the session state exactly equals [expected_state].

    This is equivalent to [when_state key (fun s -> s = Some expected_state)].

    Example - State-based routing:
    {[
      type state = Menu | Playing | GameOver

      let state_key = Session.key "game_state"

      (* Handle menu commands *)
      let menu_bot =
        Bot.make ~env ~client
        |> Bot.when_state_eq state_key Menu
        |> Bot.command "new_game" start_game_handler
        |> Bot.command "high_scores" show_scores_handler

      (* Handle game commands *)
      let game_bot =
        Bot.make ~env ~client
        |> Bot.when_state_eq state_key Playing
        |> Bot.on Event.text process_move_handler
        |> Bot.command "quit" quit_game_handler

      (* Combine all states *)
      let bot =
        Bot.make ~env ~client
        |> Bot.with_sessions (module Session.Memory_store) store
        |> Bot.merge menu_bot
        |> Bot.merge game_bot
        |> Bot.run
    ]}

    This pattern enables clean separation of concerns: each state has its own
    isolated bot with its own handlers, and they're combined at the end.
*)

val on_state : 'a Session.key -> 'a -> 'b Event.t -> ([ `Chat ] ctx -> 'b -> unit) -> bot -> bot
(** [on_state key state event handler bot] adds a route that only executes when the
    session is in the specified [state].

    This combines [Bot.on] and [Bot.when_state_eq] for convenience when adding
    individual state-specific handlers.

    Example - Multi-step form:
    {[
      type form_state = Idle | AwaitingName | AwaitingEmail | AwaitingAge

      let state_key = Session.key "form_state"
      let name_key = Session.key "name"
      let email_key = Session.key "email"

      let bot =
        Bot.make ~env ~client
        |> Bot.with_sessions (module Session.Memory_store) store

        (* Start command *)
        |> Bot.command "register" (fun ctx _args ->
            Ctx.set_state ctx state_key AwaitingName;
            ignore (Ctx.reply ctx "What's your name?")
          )

        (* Handle name input *)
        |> Bot.on_state state_key AwaitingName Event.text (fun ctx text ->
            Ctx.set_state ctx name_key text;
            Ctx.set_state ctx state_key AwaitingEmail;
            ignore (Ctx.reply ctx "What's your email?")
          )

        (* Handle email input *)
        |> Bot.on_state state_key AwaitingEmail Event.text (fun ctx text ->
            Ctx.set_state ctx email_key text;
            Ctx.set_state ctx state_key AwaitingAge;
            ignore (Ctx.reply ctx "What's your age?")
          )

        (* Handle age input *)
        |> Bot.on_state state_key AwaitingAge Event.text (fun ctx text ->
            let name = Option.get (Ctx.get_state ctx name_key) in
            let email = Option.get (Ctx.get_state ctx email_key) in
            ignore (Ctx.reply ctx
              (Printf.sprintf "Registered: %s (%s), age %s" name email text));
            Ctx.set_state ctx state_key Idle
          )

        (* Cancel at any step *)
        |> Bot.command "cancel" (fun ctx _args ->
            Ctx.set_state ctx state_key Idle;
            ignore (Ctx.reply ctx "Registration cancelled")
          )

        |> Bot.run
    ]}

    Example - Conversational Q&A bot:
    {[
      type qa_state = Idle | AwaitingQuestion | AwaitingConfirmation

      let state_key = Session.key "qa_state"
      let question_key = Session.key "question"

      let bot =
        Bot.make ~env ~client
        |> Bot.with_sessions (module Session.Memory_store) store

        |> Bot.command "ask" (fun ctx _args ->
            Ctx.set_state ctx state_key AwaitingQuestion;
            ignore (Ctx.reply ctx "What's your question?")
          )

        |> Bot.on_state state_key AwaitingQuestion Event.text (fun ctx text ->
            Ctx.set_state ctx question_key text;
            Ctx.set_state ctx state_key AwaitingConfirmation;
            ignore (Ctx.reply ctx
              (Printf.sprintf "You asked: %s\n\nSubmit? (yes/no)" text))
          )

        |> Bot.on_state state_key AwaitingConfirmation Event.text (fun ctx text ->
            match String.lowercase_ascii text with
            | "yes" | "y" ->
                let q = Option.get (Ctx.get_state ctx question_key) in
                (* Process question... *)
                ignore (Ctx.reply ctx (Printf.sprintf "Processing: %s" q));
                Ctx.set_state ctx state_key Idle
            | "no" | "n" ->
                Ctx.set_state ctx state_key Idle;
                ignore (Ctx.reply ctx "Cancelled")
            | _ ->
                ignore (Ctx.reply ctx "Please answer yes or no")
          )

        |> Bot.run
    ]}

    Benefits of state-based routing:
    - Clear separation between different conversation stages
    - Same events (e.g., text messages) can have different meanings in different states
    - Easy to add cancel/back handlers that work across multiple states
    - Natural way to implement wizards, forms, and conversational flows

    See also:
    - [when_state] for wrapping multiple handlers with state guard
    - [when_state_eq] for applying state filter to entire bot
    - [Ctx.get_state], [Ctx.set_state] for state management
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
