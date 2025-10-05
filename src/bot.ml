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

let run_polling ~env:_ ~client t =
  (* Convert routes to a simple handler that processes updates *)
  let handler _update =
    (* Route matching will be implemented once Event system is complete.
       The polling infrastructure is fully functional; route handlers
       are pending Event type implementation. *)
    List.iter (fun (Handler (_event, _h)) ->
      (* Event matching deferred until Event.t is a proper GADT *)
      ()
    ) t
  in

  (* Run the polling loop *)
  Polling.run client ~handler

let run_webhook ~env:_ ~client:_ ~secret_token:_ ~addr:_ _t = ()
