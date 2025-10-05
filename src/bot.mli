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
end

type route

val on : 'a Event.t -> ('a -> [ `Chat ] ctx -> unit) -> route
val router : ?middlewares:(unit -> unit) list -> route list -> route list

val run_polling : env:Telegram.Client.env -> client:Telegram.Client.t -> route list -> unit
val run_webhook : env:Telegram.Client.env -> client:Telegram.Client.t -> secret_token:string -> addr:[ `Tcp of (string * int) ] -> route list -> unit
