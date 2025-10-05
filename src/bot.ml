open Telegram
open Telegram.Error
open Telegram.Types

type +'s ctx = {
  client : Client.t;
  env : Client.env;
  chat : Id.Chat.k Id.t option;
  user : user option;
  message : message option;
}

module Event = struct
  type 'a t = unit
  let message = ()
  let text = ()
  let command _ = ()
  let callback _codec = ()
  let inline_query = ()
  let any = ()
  let ( & ) _ _ = ()
  let when_ _ _ = ()
end

module Ctx = struct
  type +'s t = 's ctx
  let client c = c.client
  let env c = c.env
  let chat (c : [ `Chat ] t) = match c.chat with Some id -> id | None -> failwith "no chat"
  let user c = c.user
  let message (c : [ `Chat ] t) = match c.message with Some m -> m | None -> failwith "no message"
  let reply (_c : [ `Chat ] t) (_text : string) = Error (Not_implemented "reply")
end

type handler = Handler : 'a Event.t * ('a -> unit) -> handler
type route = handler
type t = route list

let on ev h = Handler (ev, h)

let router ?middlewares:_ routes = routes

let run_polling ~env:_ ~client:_ _t = ()

let run_webhook ~env:_ ~client:_ ~secret_token:_ ~addr:_ _t = ()
