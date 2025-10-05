open Telegram
open Telegram.Error

type +'s ctx = {
  client : Client.t;
  env : Client.env;
  chat : Id.Chat.k Id.t option;
  user : Telegram.Types.user option;
  msg : Telegram.Types.message option;
  full_message : Telegram_generated.Gen_types.Message.t option;
}

(* Argument parsing helpers *)
module Args = struct
  (* Parse integer from string *)
  let parse_int s =
    try Some (int_of_string s)
    with Failure _ -> None

  (* Parse float from string *)
  let parse_float s =
    try Some (float_of_string s)
    with Failure _ -> None

  (* Parse boolean from string (true/false, yes/no, 1/0) *)
  let parse_bool s =
    match String.lowercase_ascii s with
    | "true" | "yes" | "1" -> Some true
    | "false" | "no" | "0" -> Some false
    | _ -> None

  (* Get nth argument *)
  let nth args n = List.nth_opt args n

  (* Pattern matching helpers *)
  let expect_1 args = match args with [a] -> Some a | _ -> None
  let expect_2 args = match args with [a; b] -> Some (a, b) | _ -> None
  let expect_3 args = match args with [a; b; c] -> Some (a, b, c) | _ -> None

  (* Get remaining args after n *)
  let rest args n =
    let rec drop n lst =
      if n <= 0 then lst
      else match lst with
        | [] -> []
        | _ :: tl -> drop (n - 1) tl
    in
    drop n args

  (* Join remaining args into single string *)
  let join_rest args n = String.concat " " (rest args n)
end

(* Entity-aware text parsing *)
module Entity = struct
  open Telegram_generated.Gen_types

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
    | TextMention of User.t
    | CustomEmoji of string
    | Other of string

  let entity_type_of_string s =
    match s with
    | "mention" -> Mention
    | "hashtag" -> Hashtag
    | "cashtag" -> Cashtag
    | "bot_command" -> BotCommand
    | "url" -> Url
    | "email" -> Email
    | "phone_number" -> PhoneNumber
    | "bold" -> Bold
    | "italic" -> Italic
    | "underline" -> Underline
    | "strikethrough" -> Strikethrough
    | "spoiler" -> Spoiler
    | "code" -> Code
    | "pre" -> Pre
    | "text_link" -> TextLink ""
    | "text_mention" -> TextMention (Obj.magic ()) (* placeholder *)
    | "custom_emoji" -> CustomEmoji ""
    | other -> Other other

  type entity_info = {
    entity_type : entity_type;
    offset : int;
    length : int;
    text : string;
  }

  (* Extract text substring respecting UTF-8 encoding *)
  let utf8_substring text offset length =
    let rec skip_chars text pos count =
      if count = 0 || pos >= String.length text then pos
      else
        let char_len =
          let c = Char.code text.[pos] in
          if c < 0x80 then 1
          else if c < 0xE0 then 2
          else if c < 0xF0 then 3
          else 4
        in
        skip_chars text (pos + char_len) (count - 1)
    in
    let start_pos = skip_chars text 0 offset in
    let end_pos = skip_chars text start_pos length in
    String.sub text start_pos (end_pos - start_pos)

  (* Parse entities from a message *)
  let parse_entities text entities =
    match entities with
    | None -> []
    | Some ents ->
        List.map (fun (ent : MessageEntity.t) ->
          let MessageEntity.{ type_; offset; length; url; user; custom_emoji_id; _ } = ent in
          let offset_int = Int64.to_int offset in
          let length_int = Int64.to_int length in
          let extracted_text = utf8_substring text offset_int length_int in
          let entity_type =
            match type_ with
            | "text_link" -> TextLink (Option.value url ~default:"")
            | "text_mention" -> (match user with Some u -> TextMention u | None -> Other type_)
            | "custom_emoji" -> CustomEmoji (Option.value custom_emoji_id ~default:"")
            | _ -> entity_type_of_string type_
          in
          { entity_type; offset = offset_int; length = length_int; text = extracted_text }
        ) ents

  (* Get all entities of a specific type *)
  let filter_by_type typ entities =
    List.filter (fun e ->
      match typ, e.entity_type with
      | `BotCommand, BotCommand -> true
      | `Url, Url -> true
      | `Mention, Mention -> true
      | `Hashtag, Hashtag -> true
      | `Code, Code -> true
      | `Pre, Pre -> true
      | _ -> false
    ) entities

  (* Extract command arguments from text, respecting entities *)
  let parse_command_args text entities =
    (* Find the bot_command entity *)
    let cmd_entities = filter_by_type `BotCommand (parse_entities text entities) in
    match cmd_entities with
    | [] -> None  (* No command found *)
    | cmd :: _ ->
        (* Get text after the command *)
        let args_start = cmd.offset + cmd.length in
        if args_start >= String.length text then
          Some []  (* Command with no args *)
        else
          let args_text = String.sub text args_start (String.length text - args_start) in
          let trimmed = String.trim args_text in
          if trimmed = "" then Some []
          else Some (String.split_on_char ' ' trimmed |> List.filter (fun s -> s <> ""))
end

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
            full_message = None;
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
                 full_message = Some msg;
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
                    (* Try entity-aware parsing first *)
                    (match Entity.parse_command_args text msg.entities with
                     | Some args ->
                         (* Extract command name from first bot_command entity *)
                         let cmd_entities = Entity.filter_by_type `BotCommand (Entity.parse_entities text msg.entities) in
                         (match cmd_entities with
                          | cmd_entity :: _ ->
                              (* Extract command text and strip @botname if present *)
                              let cmd_text = cmd_entity.Entity.text in
                              let cmd_text_no_slash = if String.length cmd_text > 0 && cmd_text.[0] = '/' then
                                String.sub cmd_text 1 (String.length cmd_text - 1)
                              else cmd_text in
                              let cmd_name = (match String.index_opt cmd_text_no_slash '@' with
                                | Some idx -> String.sub cmd_text_no_slash 0 idx
                                | None -> cmd_text_no_slash) in
                              if cmd_name = cmd then
                                (match match_event Message upd_param with
                                 | Some (_, ctx) -> Some (args, ctx)
                                 | None -> None)
                              else None
                          | [] ->
                              (* Fallback to simple parsing if no entities *)
                              let parts = String.split_on_char ' ' text in
                              (match parts with
                               | cmd_part :: args when String.length cmd_part > 1 ->
                                   let cmd_text = String.sub cmd_part 1 (String.length cmd_part - 1) in
                                   let cmd_name = (match String.index_opt cmd_text '@' with
                                     | Some idx -> String.sub cmd_text 0 idx
                                     | None -> cmd_text) in
                                   if cmd_name = cmd then
                                     (match match_event Message upd_param with
                                      | Some (_, ctx) -> Some (args, ctx)
                                      | None -> None)
                                   else None
                               | _ -> None))
                     | None ->
                         (* Fallback to simple parsing *)
                         let parts = String.split_on_char ' ' text in
                         (match parts with
                          | cmd_part :: args when String.length cmd_part > 1 ->
                              let cmd_text = String.sub cmd_part 1 (String.length cmd_part - 1) in
                              let cmd_name = (match String.index_opt cmd_text '@' with
                                | Some idx -> String.sub cmd_text 0 idx
                                | None -> cmd_text) in
                              if cmd_name = cmd then
                                (match match_event Message upd_param with
                                 | Some (_, ctx) -> Some (args, ctx)
                                 | None -> None)
                              else None
                          | _ -> None))
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
                 full_message = None;
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

  (* Entity access helpers *)
  let entities (c : [ `Chat ] t) =
    match c.full_message with
    | Some full_msg ->
        let open Telegram_generated.Gen_types in
        let Message.{ text; entities; _ } = full_msg in
        (match text with
         | Some txt -> Entity.parse_entities txt entities
         | None -> [])
    | None -> []

  (* Get entities of a specific type *)
  let get_entities (c : [ `Chat ] t) typ =
    Entity.filter_by_type typ (entities c)
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
