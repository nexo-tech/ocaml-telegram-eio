(* Public signatures referencing Telegram modules explicitly to avoid unused opens *)

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

val on : 'a Event.t -> ('a -> [ `Chat ] ctx -> unit) -> route
(** Create a route from an event matcher and handler *)

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
