open Telegram
open Telegram.Error

type +'s ctx = {
  client : Client.t;
  env : Client.env;
  chat : Id.Chat.k Id.t option;
  user : Telegram.Types.user option;
  msg : Telegram.Types.message option;
}

module Event = struct
  (* GADT for typed event matchers *)
  type 'a t =
    | Message : Telegram_generated.Gen_types.Message.t t
    | Text : string t
    | Command : string -> string list t
    | Callback : 'a -> 'a t
    | Inline_query : Telegram_generated.Gen_types.InlineQuery.t t
    | Any : Telegram_generated.Gen_types.Update.t t
    | Combine : 'a t * 'b t -> ('a * 'b) t
    | Filter : 'a t * ('a -> bool) -> 'a t

  let message = Message
  let text = Text
  let command cmd = Command cmd
  let callback codec = Callback codec
  let inline_query = Inline_query
  let any = Any
  let ( & ) a b = Combine (a, b)
  let when_ event predicate = Filter (event, predicate)

  (* Internal: match an update against an event matcher *)
  let rec match_event : type a. a t -> Telegram_generated.Gen_types.Update.t -> (a * [ `Chat ] ctx) option =
    fun event upd_param ->
      match event with
      | Any ->
          (* Create minimal context for 'any' event *)
          let ctx = {
            client = failwith "client not set"; (* Will be set by router *)
            env = failwith "env not set";
            chat = None;
            user = None;
            msg = None;
          } in
          Some (upd_param, ctx)

      | Message ->
          let open Telegram_generated.Gen_types in
          let Update.{ message = msg_opt; _ } = upd_param in
          (match msg_opt with
           | Some msg ->
               let open Telegram_generated.Gen_types in
               let Message.{ chat; from; _ } = msg in
               let Chat.{ id; _ } = chat in
               let chat_id = Telegram.Id.Chat.of_int id in
               let user = (match from with
                 | Some from_user ->
                     let User.{ id = user_id; username; _ } = from_user in
                     Some Telegram.Types.{
                       id = Telegram.Id.User.of_int user_id;
                       username = username;
                     }
                 | None -> None) in
               let Message.{ message_id; text; _ } = msg in
               let message = Telegram.Types.{
                 message_id = Int64.to_int message_id;
                 chat_id = chat_id;
                 text = text;
               } in
               let ctx = {
                 client = failwith "client not set";
                 env = failwith "env not set";
                 chat = Some chat_id;
                 user = user;
                 msg = Some message;
               } in
               Some (msg, ctx)
           | None -> None)

      | Text ->
          let open Telegram_generated.Gen_types in
          let Update.{ message = msg_opt; _ } = upd_param in
          (match msg_opt with
           | Some msg when msg.text <> None ->
               (match match_event Message upd_param with
                | Some (_, ctx) -> Some (Option.get msg.text, ctx)
                | None -> None)
           | _ -> None)

      | Command cmd ->
          let open Telegram_generated.Gen_types in
          let Update.{ message = msg_opt; _ } = upd_param in
          (match msg_opt with
           | Some msg ->
               (match msg.text with
                | Some text when String.length text > 0 && text.[0] = '/' ->
                    (* Parse command: /command[@botname] args *)
                    let parts = String.split_on_char ' ' text in
                    (match parts with
                     | cmd_part :: args when String.length cmd_part > 1 ->
                         let cmd_text = String.sub cmd_part 1 (String.length cmd_part - 1) in
                         (* Remove @botname if present *)
                         let cmd_name = (match String.index_opt cmd_text '@' with
                           | Some idx -> String.sub cmd_text 0 idx
                           | None -> cmd_text) in
                         if cmd_name = cmd then
                           (match match_event Message upd_param with
                            | Some (_, ctx) -> Some (args, ctx)
                            | None -> None)
                         else None
                     | _ -> None)
                | _ -> None)
           | None -> None)

      | Callback _ ->
          (* Callback matching requires the codec, which we'll implement later *)
          None

      | Inline_query ->
          let open Telegram_generated.Gen_types in
          let Update.{ inline_query = iq_opt; _ } = upd_param in
          (match iq_opt with
           | Some iq ->
               let ctx = {
                 client = failwith "client not set";
                 env = failwith "env not set";
                 chat = None;
                 user = None;
                 msg = None;
               } in
               Some (iq, ctx)
           | None -> None)

      | Combine (event_a, event_b) ->
          (match match_event event_a upd_param with
           | Some (a, ctx_a) ->
               (match match_event event_b upd_param with
                | Some (b, _ctx_b) -> Some ((a, b), ctx_a)
                | None -> None)
           | None -> None)

      | Filter (event, predicate) ->
          (match match_event event upd_param with
           | Some (value, ctx) when predicate value -> Some (value, ctx)
           | _ -> None)
end

module Ctx = struct
  type +'s t = 's ctx

  (* Basic accessors *)
  let client c = c.client
  let env c = c.env
  let chat (c : [ `Chat ] t) = match c.chat with Some id -> id | None -> failwith "no chat"
  let user c = c.user
  let message (c : [ `Chat ] t) = match c.msg with Some m -> m | None -> failwith "no message"

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

type handler = Handler : 'a Event.t * ('a -> [ `Chat ] ctx -> unit) -> handler
type route = handler

let on ev h = Handler (ev, h)

let router ?middlewares:_ routes = routes

(* Internal: try to match and execute routes against an update *)
let dispatch_update client env routes update =
  let rec try_routes = function
    | [] -> () (* No route matched, silently ignore *)
    | Handler (event, handler) :: rest ->
        (match Event.match_event event update with
         | Some (value, ctx) ->
             (* Fill in client and env in the context *)
             let ctx = { ctx with client = client; env = env } in
             (* Call the handler *)
             (try
                handler value ctx
              with exn ->
                (* Catch handler exceptions to prevent crashing *)
                Printf.eprintf "Handler exception: %s\n%!" (Printexc.to_string exn))
         | None ->
             (* This route didn't match, try next *)
             try_routes rest)
  in
  try_routes routes

let run_polling ~env ~client routes =
  (* Convert routes to update handler *)
  let handler update =
    dispatch_update client env routes update
  in

  (* Run the polling loop *)
  Polling.run client ~handler

let run_webhook ~env ~client ~secret_token ~addr routes =
  (* Extract path and port from addr *)
  let `Tcp (path, port) = addr in

  (* Convert routes to update handler *)
  let handler update =
    dispatch_update client env routes update
  in

  (* Run the webhook server *)
  Webhook.run client ~secret_token ~port ~path ~handler
