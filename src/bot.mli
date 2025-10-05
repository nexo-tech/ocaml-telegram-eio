(* Public signatures referencing Telegram modules explicitly to avoid unused opens *)

type +'s ctx

module Event : sig
  type 'a t
  val message : Telegram.Types.message t
  val text : string t
  val command : string -> string list t
  val callback : 'a -> 'a t
  val inline_query : Telegram.Types.inline_query t
  val any : unit t
  val ( & ) : 'a t -> 'b t -> ('a * 'b) t
  val when_ : 'a t -> ('a -> bool) -> 'a t
end

module Ctx : sig
  type +'s t = 's ctx
  val client : _ t -> Telegram.Client.t
  val env : _ t -> Telegram.Client.env
  val chat : [ `Chat ] t -> Telegram.Id.Chat.k Telegram.Id.t
  val user : _ t -> Telegram.Types.user option
  val message : [ `Chat ] t -> Telegram.Types.message
  val reply : [ `Chat ] t -> string -> (Telegram.Types.message, Telegram.Error.t) result
end

type route
type t

val on : 'a Event.t -> ('a -> unit) -> route
val router : ?middlewares:(unit -> unit) list -> route list -> t

val run_polling : env:Telegram.Client.env -> client:Telegram.Client.t -> t -> unit
val run_webhook : env:Telegram.Client.env -> client:Telegram.Client.t -> secret_token:string -> addr:[ `Tcp of (string * int) ] -> t -> unit
