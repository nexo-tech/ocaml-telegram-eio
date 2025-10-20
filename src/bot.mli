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

(** {1 Functor Interface} *)

(** Bot module signature - output of Make functor.
    This contains all modules that depend on Log (Event, Entity, Middleware, Ctx)
    as well as the builder functions. *)
module type S = sig
  type route
  type bot

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

  module Entity : sig
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
    val filter_by_type : [ `BotCommand | `Url | `Mention | `Hashtag | `Code | `Pre ] -> entity_info list -> entity_info list
    val parse_command_args : string -> Telegram_generated.Gen_types.MessageEntity.t list option -> (string * string list) option
  end

  module Middleware : sig
    type 's t

    val make :
      ?before:('s ctx -> ('s ctx, string) result) ->
      ?after:('s ctx -> unit) ->
      ?on_error:('s ctx -> exn -> unit) ->
      string -> 's t

    val logging : ?prefix:string -> unit -> 's t
    val only_users : Telegram.Id.User.k Telegram.Id.t list -> 's t
    val require_user : unit -> 's t
    val require_chat : unit -> 's t
    val rate_limit : max_per_minute:int -> unit -> 's t
    val enrich : ('s ctx -> 's ctx) -> 's t
    val with_session : (module Session.STORE with type store = 's) -> 's -> [ `Chat ] t

    val combine : 's t list -> 's t
    val ( >> ) : 's t -> 's t -> 's t
    val when_ : ('s ctx -> bool) -> 's t -> 's t
    val with_logging : ?prefix:string -> unit -> 's t
    val require_admin : Telegram.Id.User.k Telegram.Id.t list -> 's t
    val require_all : 's t list -> 's t
  end

  module Ctx : sig
    type +'s t = 's ctx

    val client : _ t -> Telegram.Client.t
    val env : _ t -> Telegram.Client.env
    val chat : [ `Chat ] t -> Telegram.Id.Chat.k Telegram.Id.t
    val user : _ t -> Telegram.Types.user option
    val message : [ `Chat ] t -> Telegram.Types.message

    val reply : ?keyboard:Telegram.Types.inline_keyboard_markup -> [ `Chat ] t -> string -> (Telegram_generated.Gen_types.Message.t, Telegram.Error.t) result
    val answer : ?keyboard:Telegram.Types.inline_keyboard_markup -> [ `Chat ] t -> string -> (Telegram_generated.Gen_types.Message.t, Telegram.Error.t) result
    val send : ?keyboard:Telegram.Types.inline_keyboard_markup -> [ `Chat ] t -> string -> (Telegram_generated.Gen_types.Message.t, Telegram.Error.t) result
    val edit : ?keyboard:Telegram.Types.inline_keyboard_markup -> [ `Chat ] t -> string -> (unit, Telegram.Error.t) result

    val entities : [ `Chat ] t -> Entity.entity_info list
    val get_entities : [ `Chat ] t -> [ `BotCommand | `Url | `Mention | `Hashtag | `Code | `Pre ] -> Entity.entity_info list

    val session : _ t -> Session.t
    val session_opt : _ t -> Session.t option
    val session_get : _ t -> 'a Session.key -> 'a option
    val session_set : _ t -> 'a Session.key -> 'a -> unit
    val session_get_or : _ t -> 'a Session.key -> default:'a -> 'a
    val session_delete : _ t -> 'a Session.key -> unit
    val session_exists : _ t -> 'a Session.key -> bool
    val session_clear : _ t -> unit
    val session_modify : _ t -> 'a Session.key -> default:'a -> ('a -> 'a) -> unit

    val get_state : _ t -> 'a Session.key -> 'a option
    val set_state : _ t -> 'a Session.key -> 'a -> unit
    val modify_state : _ t -> 'a Session.key -> default:'a -> ('a -> 'a) -> unit

    val return : 'a -> ('a, Telegram.Error.t) result
    val bind : ('a, Telegram.Error.t) result -> ('a -> ('b, Telegram.Error.t) result) -> ('b, Telegram.Error.t) result
    val map : ('a, Telegram.Error.t) result -> ('a -> 'b) -> ('b, Telegram.Error.t) result
    val ( let* ) : ('a, Telegram.Error.t) result -> ('a -> ('b, Telegram.Error.t) result) -> ('b, Telegram.Error.t) result
    val ( let+ ) : ('a, Telegram.Error.t) result -> ('a -> 'b) -> ('b, Telegram.Error.t) result

    val reply_ : ?keyboard:Telegram.Types.inline_keyboard_markup -> [ `Chat ] t -> string -> (unit, Telegram.Error.t) result
    val require_user : _ t -> (Telegram.Types.user, Telegram.Error.t) result
    val require_admin : Telegram.Id.User.k Telegram.Id.t list -> _ t -> (unit, Telegram.Error.t) result

    val ( >>= ) : ('a -> ('b, Telegram.Error.t) result) -> ('b -> ('c, Telegram.Error.t) result) -> ('a -> ('c, Telegram.Error.t) result)
    val ( >>| ) : ('a -> ('b, Telegram.Error.t) result) -> ('b -> 'c) -> ('a -> ('c, Telegram.Error.t) result)

    (** Bind handler context (user, chat, message) to fiber-local storage for structured logging.

        This helper automatically extracts user_id, chat_id, and message_id from the context
        and binds them to Flo's fiber-local storage, so all logs within the handler will
        include these fields.

        Example:
        {[
          |> command "start" (fun ctx _args ->
              Ctx.with_handler_context ctx (fun () ->
                (* All logs here will include user_id, chat_id, message_id *)
                let* () = Ctx.reply_ ctx "Hello!" in
                Ok ()
              )
            )
        ]}
    *)
    val with_handler_context : 's t -> (unit -> 'a) -> 'a
  end

  (** {1 Builder API} *)

  val make : env:Telegram.Client.env -> client:Telegram.Client.t -> bot
  val run : bot -> unit
  val command : ?desc:string -> string -> ([ `Chat ] ctx -> string list -> (unit, Telegram.Error.t) result) -> bot -> bot
  val commands : bot -> (string * string) list

  type 'a parser = string list -> ('a, string) result
  val command_with : ?desc:string -> string -> 'a parser -> ([ `Chat ] ctx -> 'a -> (unit, Telegram.Error.t) result) -> bot -> bot

  val on : 'a Event.t -> ([ `Chat ] ctx -> 'a -> (unit, Telegram.Error.t) result) -> bot -> bot
  val on_text : ([ `Chat ] ctx -> string -> (unit, Telegram.Error.t) result) -> bot -> bot
  val on_message : ([ `Chat ] ctx -> Telegram_generated.Gen_types.Message.t -> (unit, Telegram.Error.t) result) -> bot -> bot
  val on_callback : ([ `Chat ] ctx -> string -> (unit, Telegram.Error.t) result) -> bot -> bot
  val on_callback_data : string -> ([ `Chat ] ctx -> (unit, Telegram.Error.t) result) -> bot -> bot
  val on_photo : ([ `Chat ] ctx -> Telegram_generated.Gen_types.PhotoSize.t list -> (unit, Telegram.Error.t) result) -> bot -> bot
  val on_document : ([ `Chat ] ctx -> Telegram_generated.Gen_types.Document.t -> (unit, Telegram.Error.t) result) -> bot -> bot

  val use : [ `Chat ] Middleware.t -> bot -> bot
  val scope : [ `Chat ] Middleware.t list -> bot -> bot
  val end_scope : bot -> bot

  val on_error : ([ `Chat ] ctx -> exn -> unit) -> bot -> bot
  val command_safe : ?desc:string -> string -> ([ `Chat ] ctx -> string list -> (unit, string) result) -> bot -> bot
  val catch : ([ `Chat ] ctx -> exn -> unit) -> bot -> bot

  val merge : bot -> bot -> bot
  val scope_prefix : string -> bot -> bot
  val when_ : ([ `Chat ] ctx -> bool) -> bot -> bot

  val with_sessions : (module Session.STORE with type store = 's) -> 's -> bot -> bot
  val when_state : 'a Session.key -> ('a option -> bool) -> bot -> bot
  val when_state_eq : 'a Session.key -> 'a -> bot -> bot
  val on_state : 'a Session.key -> 'a -> 'b Event.t -> ([ `Chat ] ctx -> 'b -> (unit, Telegram.Error.t) result) -> bot -> bot

  val route : 'a Event.t -> ('a -> [ `Chat ] ctx -> (unit, Telegram.Error.t) result) -> route
  val with_middleware : [ `Chat ] Middleware.t list -> route -> route
  val with_error_handler : ([ `Chat ] ctx -> exn -> unit) -> route -> route
  val router :
    ?middlewares:[ `Chat ] Middleware.t list ->
    ?on_error:([ `Chat ] ctx -> exn -> unit) ->
    route list -> route list

  val run_polling : env:Telegram.Client.env -> client:Telegram.Client.t -> route list -> unit
  val run_webhook : env:Telegram.Client.env -> client:Telegram.Client.t -> secret_token:string -> addr:[ `Tcp of (string * int) ] -> route list -> unit
end

(** {1 Core Bot Framework}

    All bot functionality uses flo for logging. Configure logging globally:

    {[
      (* Set log level before running bot *)
      Flo.set_level Severity.Info   (* Production *)
      Flo.set_level Severity.Debug  (* Development *)

      (* Create and run bot *)
      Bot.make ~env ~client
      |> Bot.command "start" (fun ctx _args -> Bot.Ctx.reply ctx "Welcome!")
      |> Bot.run
    ]}
*)

(* All functions are available at the top level *)
include S

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
