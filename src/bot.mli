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
