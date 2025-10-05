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

  (* Basic accessors *)
  let client c = c.client
  let env c = c.env
  let chat (c : [ `Chat ] t) = match c.chat with Some id -> id | None -> failwith "no chat"
  let user c = c.user
  let message (c : [ `Chat ] t) = match c.message with Some m -> m | None -> failwith "no message"

  (* Convenience helpers for sending messages *)
  let reply (c : [ `Chat ] t) text =
    let chat_id = chat c in
    let msg = message c in
    let params = [
      ("chat_id", Param.string (Id.to_string chat_id));
      ("text", Param.string text);
      ("reply_parameters", Param.json (`Assoc [
        ("message_id", `Int msg.message_id)
      ]));
    ] in
    match Api.call_method (client c) ~method_name:"sendMessage" params with
    | Ok json ->
        (match Telegram_generated.Gen_types.Message.of_yojson json with
         | Ok m -> Ok m
         | Error err -> Error (Decode_error ("Failed to decode sent message: " ^ err)))
    | Error err -> Error err

  (* Alias for reply *)
  let answer = reply

  (* Send a message to the chat without replying *)
  let send (c : [ `Chat ] t) text =
    let chat_id = chat c in
    let params = [
      ("chat_id", Param.string (Id.to_string chat_id));
      ("text", Param.string text);
    ] in
    match Api.call_method (client c) ~method_name:"sendMessage" params with
    | Ok json ->
        (match Telegram_generated.Gen_types.Message.of_yojson json with
         | Ok m -> Ok m
         | Error err -> Error (Decode_error ("Failed to decode sent message: " ^ err)))
    | Error err -> Error err

  (* Edit the current message (for callback queries) *)
  let edit (c : [ `Chat ] t) text =
    let chat_id = chat c in
    let msg = message c in
    let params = [
      ("chat_id", Param.string (Id.to_string chat_id));
      ("message_id", Param.int msg.message_id);
      ("text", Param.string text);
    ] in
    match Api.call_method (client c) ~method_name:"editMessageText" params with
    | Ok json ->
        (match json with
         | `Bool true -> Ok ()
         | _ ->
             (match Telegram_generated.Gen_types.Message.of_yojson json with
              | Ok _ -> Ok ()
              | Error err -> Error (Decode_error ("Failed to decode edited message: " ^ err))))
    | Error err -> Error err
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

let run_webhook ~env:_ ~client ~secret_token ~addr t =
  (* Extract path and port from addr *)
  let `Tcp (path, port) = addr in

  (* Convert routes to a simple handler that processes updates *)
  let handler _update =
    (* Route matching will be implemented once Event system is complete.
       The webhook infrastructure is fully functional; route handlers
       are pending Event type implementation. *)
    List.iter (fun (Handler (_event, _h)) ->
      (* Event matching deferred until Event.t is a proper GADT *)
      ()
    ) t
  in

  (* Run the webhook server *)
  Webhook.run client ~secret_token ~port ~path ~handler
