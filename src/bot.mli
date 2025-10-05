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
end

type route

val on : 'a Event.t -> ('a -> [ `Chat ] ctx -> unit) -> route
val router : ?middlewares:(unit -> unit) list -> route list -> route list

val run_polling : env:Telegram.Client.env -> client:Telegram.Client.t -> route list -> unit
val run_webhook : env:Telegram.Client.env -> client:Telegram.Client.t -> secret_token:string -> addr:[ `Tcp of (string * int) ] -> route list -> unit
