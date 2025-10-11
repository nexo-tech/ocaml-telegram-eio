open Telegram
open Telegram.Error

type +'s ctx = {
  client : Client.t;
  env : Client.env;
  chat : Id.Chat.k Id.t option;
  user : Telegram.Types.user option;
  msg : Telegram.Types.message option;
  full_message : Telegram_generated.Gen_types.Message.t option;
  session : Session.t option;
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
            session = None;
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
                 session = None;
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
                 session = None;
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

(* Middleware system *)
module Middleware = struct
  type 's t = {
    name : string; [@warning "-69"]
    before : 's ctx -> ('s ctx, string) result;
    after : 's ctx -> unit;
    on_error : 's ctx -> exn -> unit;
  }

  (* Create middleware with all hooks *)
  let make ?(before = fun ctx -> Ok ctx) ?(after = fun _ -> ()) ?(on_error = fun _ _ -> ()) name =
    { name; before; after; on_error }

  (* Common middleware constructors *)

  (* Logging middleware *)
  let logging ?(prefix = "[Bot]") () =
    make ~before:(fun ctx ->
      (match ctx.user with
       | Some u ->
           let username = match u.Telegram.Types.username with Some un -> "@" ^ un | None -> "?" in
           Printf.eprintf "%s Update from %s\n%!" prefix username
       | None -> Printf.eprintf "%s Update (no user)\n%!" prefix);
      Ok ctx)
    ~after:(fun _ctx ->
      Printf.eprintf "%s Handler completed\n%!" prefix)
    ~on_error:(fun _ctx exn ->
      Printf.eprintf "%s Handler error: %s\n%!" prefix (Printexc.to_string exn))
    "logging"

  (* Authorization middleware - only allow specific user IDs *)
  let only_users allowed_ids =
    make ~before:(fun ctx ->
      match ctx.user with
      | Some u ->
          if List.mem u.Telegram.Types.id allowed_ids then
            Ok ctx
          else
            Error "Unauthorized user"
      | None -> Error "No user in update")
    "only_users"

  (* Authorization middleware - require user to be present *)
  let require_user () =
    make ~before:(fun ctx ->
      match ctx.user with
      | Some _ -> Ok ctx
      | None -> Error "User required")
    "require_user"

  (* Authorization middleware - require chat to be present *)
  let require_chat () =
    make ~before:(fun ctx ->
      match ctx.chat with
      | Some _ -> Ok ctx
      | None -> Error "Chat required")
    "require_chat"

  (* Rate limiting middleware (simple in-memory) *)
  let rate_limit ~max_per_minute () =
    let module H = Hashtbl in
    let requests = H.create 100 in
    let cleanup_interval = 60.0 in
    let last_cleanup = ref (Unix.gettimeofday ()) in

    make ~before:(fun ctx ->
      let now = Unix.gettimeofday () in

      (* Periodic cleanup *)
      if now -. !last_cleanup > cleanup_interval then (
        H.clear requests;
        last_cleanup := now
      );

      match ctx.user with
      | Some u ->
          let user_id = u.Telegram.Types.id in
          let count = try H.find requests user_id with Not_found -> (ref 0, ref now) in
          let (counter, first_req) = count in

          (* Reset if window expired *)
          if now -. !first_req > 60.0 then (
            counter := 1;
            first_req := now;
            H.replace requests user_id (counter, first_req);
            Ok ctx
          ) else if !counter >= max_per_minute then
            Error "Rate limit exceeded"
          else (
            incr counter;
            H.replace requests user_id (counter, first_req);
            Ok ctx
          )
      | None -> Ok ctx (* No user, no rate limit *))
    "rate_limit"

  (* Context enricher - add custom data *)
  let enrich f =
    make ~before:(fun ctx -> Ok (f ctx)) "enrich"

  (* Session middleware - adds session to context *)
  let with_session (type s) (module Store : Session.STORE with type store = s) store =
    make ~before:(fun ctx ->
      match ctx.user with
      | Some u ->
          let user_id = Int64.of_string (Telegram.Id.to_string u.Telegram.Types.id) in
          let session = Store.get_session store ~user_id in
          Ok { ctx with session = Some session }
      | None -> Ok ctx (* No user, no session *)
    ) "with_session"

  (* Combine multiple middleware *)
  let combine middlewares =
    make
      ~before:(fun ctx ->
        List.fold_left (fun acc mw ->
          match acc with
          | Error _ as e -> e
          | Ok ctx -> mw.before ctx
        ) (Ok ctx) middlewares)
      ~after:(fun ctx ->
        List.iter (fun mw -> mw.after ctx) (List.rev middlewares))
      ~on_error:(fun ctx exn ->
        List.iter (fun mw -> mw.on_error ctx exn) (List.rev middlewares))
      "combined"

  (* Chain operator for combining middleware *)
  let ( >> ) m1 m2 = combine [m1; m2]

  (* Conditional middleware - only apply if predicate is true *)
  let when_ predicate mw =
    make ~before:(fun ctx ->
      if predicate ctx then
        mw.before ctx
      else
        Ok ctx)
    ~after:(fun ctx ->
      if predicate ctx then
        mw.after ctx)
    ~on_error:(fun ctx exn ->
      if predicate ctx then
        mw.on_error ctx exn)
    ("when_" ^ mw.name)

  (* Decorator-style helpers for common patterns *)

  (* Apply logging middleware with custom prefix *)
  let with_logging ?(prefix = "[Bot]") () =
    logging ~prefix ()

  (* Require admin user (example decorator) *)
  let require_admin admin_ids =
    only_users admin_ids

  (* Combine authorization checks *)
  let require_all checks =
    combine checks
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

  (* Session access helpers *)
  let session (c : _ t) =
    match c.session with
    | Some s -> s
    | None -> failwith "Session not available. Did you forget to add session middleware?"

  let session_opt (c : _ t) = c.session

  (* Session operations (convenient wrappers) *)
  let session_get (c : _ t) key =
    Session.get (session c) key

  let session_set (c : _ t) key value =
    Session.set (session c) key value

  let session_get_or (c : _ t) key ~default =
    Session.get_or (session c) key ~default

  let session_delete (c : _ t) key =
    Session.delete (session c) key

  let session_exists (c : _ t) key =
    Session.exists (session c) key

  let session_clear (c : _ t) =
    Session.clear (session c)

  let session_modify (c : _ t) key ~default f =
    Session.modify (session c) key ~default f

  (* Monadic operations for Result type *)

  let return x = Ok x
  (** [return x] wraps a value in Ok, for use in monadic context *)

  let bind result f =
    match result with
    | Ok x -> f x
    | Error e -> Error e
  (** [bind result f] monadic bind operation. Chains operations that return Result.
      If [result] is [Ok x], applies [f] to [x]. If [Error e], propagates the error. *)

  let map result f =
    match result with
    | Ok x -> Ok (f x)
    | Error e -> Error e
  (** [map result f] applies function [f] to the value inside [Ok], or propagates [Error] *)

  (* Let operators for monadic syntax *)

  let ( let* ) = bind
  (** [let* x = expr in body] desugars to [bind expr (fun x -> body)].
      Enables monadic syntax for chaining Result operations. *)

  let ( let+ ) result f = map result f
  (** [let+ x = expr in body] desugars to [map expr (fun x -> body)].
      Enables applicative syntax for Result operations. *)

  (* Handler combinators for common patterns *)

  let reply_ ctx text =
    match reply ctx text with
    | Ok _ -> Ok ()
    | Error e -> Error e
  (** [reply_ ctx text] sends a reply and returns [Ok ()] on success.
      This is a simpler version of [reply] that discards the returned message,
      useful when you don't need to inspect the sent message. *)

  let require_user ctx =
    match ctx.user with
    | Some u -> Ok u
    | None -> Error (Telegram.Error.Api_error {
        code = 400;
        description = "User required but not present in update";
        parameters = None
      })
  (** [require_user ctx] extracts the user from context or returns an error.
      This enables monadic checking of user presence. *)

  let require_admin admin_ids ctx =
    match ctx.user with
    | None -> Error (Telegram.Error.Api_error {
        code = 401;
        description = "User required for admin check";
        parameters = None
      })
    | Some u ->
        if List.mem u.Telegram.Types.id admin_ids then
          Ok ()
        else
          Error (Telegram.Error.Api_error {
            code = 403;
            description = "Admin privileges required";
            parameters = None
          })
  (** [require_admin admin_ids ctx] checks if the user is in the admin list.
      Returns [Ok ()] if user is admin, [Error] otherwise. *)

  (* Function composition operators for point-free style *)

  let ( >>= ) f g = fun x ->
    match f x with
    | Ok y -> g y
    | Error e -> Error e
  (** [f >>= g] composes two monadic functions.
      The result of [f] is passed to [g] if successful, otherwise the error is propagated.
      This enables point-free composition of handlers. *)

  let ( >>| ) f g = fun x ->
    match f x with
    | Ok y -> Ok (g y)
    | Error e -> Error e
  (** [f >>| g] composes a monadic function with a regular function.
      The result of [f] is transformed by [g] if successful.
      This enables point-free composition of handlers with transformations. *)
end

type handler = Handler : 'a Event.t * ('a -> [ `Chat ] ctx -> unit) -> handler

(* Route with optional middleware and error handler *)
type route = {
  handler : handler;
  middleware : [ `Chat ] Middleware.t list;
  on_error : ([ `Chat ] ctx -> exn -> unit) option;
}

(* Builder pattern bot type - accumulates routes, middleware, and config *)
type bot = {
  client : Client.t;
  env : Client.env;
  routes : route list;
  middleware : [ `Chat ] Middleware.t list;  (* global middleware *)
  scoped_middleware : [ `Chat ] Middleware.t list;  (* scoped middleware for next routes *)
  on_error : ([ `Chat ] ctx -> exn -> unit) option;
  scoped_error_handler : ([ `Chat ] ctx -> exn -> unit) option;  (* scoped error handler for next routes *)
  command_descriptions : (string * string) list; (* (command_name, description) pairs *)
}

(* Parser type for type-safe argument parsing *)
type 'a parser = string list -> ('a, string) result

(* Create a route from an event and handler - route-based API *)
let route ev h = {
  handler = Handler (ev, h);
  middleware = [];
  on_error = None;
}

(* Add middleware to a route *)
let with_middleware mws (route : route) : route = { route with middleware = mws }

(* Add error handler to a route *)
let with_error_handler err_h (route : route) : route = { route with on_error = Some err_h }

(* Create router with optional global middleware and error handler *)
let router ?(middlewares = []) ?on_error (routes : route list) : route list =
  (* Apply global middleware and error handler to all routes *)
  List.map (fun (route : route) : route ->
    { route with
      middleware = middlewares @ route.middleware;
      on_error = (match route.on_error with
        | Some _ as route_handler -> route_handler  (* Route-specific handler takes precedence *)
        | None -> on_error)  (* Use global handler if no route-specific one *)
    }
  ) routes

(* Error handler utilities *)
module ErrorHandler = struct
  (* Log error to stderr *)
  let log _ctx exn =
    Printf.eprintf "[Bot Error] %s\n%s\n%!"
      (Printexc.to_string exn)
      (Printexc.get_backtrace ())

  (* Log error and send reply to user *)
  let log_and_reply ?(message = "Sorry, an error occurred while processing your request.") () ctx exn =
    log ctx exn;
    (* Try to send error message to user *)
    (match Ctx.reply ctx message with
     | Ok _ -> ()
     | Error e ->
         Format.eprintf "[Bot Error] Failed to send error message to user: %a\n%!"
           Telegram.Error.pp e)

  (* Silent error handler - do nothing *)
  let silent _ctx _exn = ()

  (* Combine multiple error handlers *)
  let combine handlers ctx exn =
    List.iter (fun h -> h ctx exn) handlers
end

(* Internal: try to match and execute routes against an update *)
let dispatch_update client env routes update =
  let rec try_routes = function
    | [] -> () (* No route matched, silently ignore *)
    | route :: rest ->
        let { handler = Handler (event, handler); middleware; on_error } = route in
        (match Event.match_event event update with
         | Some (value, ctx) ->
             (* Fill in client and env in the context *)
             let ctx = { ctx with client = client; env = env } in

             (* Run middleware before hooks *)
             let ctx_result = List.fold_left (fun acc mw ->
               match acc with
               | Error _ as e -> e
               | Ok ctx -> mw.Middleware.before ctx
             ) (Ok ctx) middleware in

             (match ctx_result with
              | Error err ->
                  (* Middleware rejected the request *)
                  Printf.eprintf "Middleware rejected: %s\n%!" err
              | Ok enriched_ctx ->
                  (* Call the handler with error boundary *)
                  (try
                     handler value enriched_ctx;
                     (* Run middleware after hooks *)
                     List.iter (fun mw -> mw.Middleware.after enriched_ctx) (List.rev middleware)
                   with exn ->
                     (* Run middleware error hooks *)
                     List.iter (fun mw -> mw.Middleware.on_error enriched_ctx exn) (List.rev middleware);
                     (* Call route-specific error handler if present *)
                     (match on_error with
                      | Some err_h -> err_h enriched_ctx exn
                      | None -> Printf.eprintf "Handler exception: %s\n%!" (Printexc.to_string exn))))
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

(* Builder pattern functions *)

(** Create a new bot with empty route list *)
let make ~env ~client = {
  client;
  env;
  routes = [];
  middleware = [];
  scoped_middleware = [];
  on_error = None;
  scoped_error_handler = None;
  command_descriptions = [];
}

(** Run the bot using long polling *)
let run bot =
  (* Apply global middleware/error handler to all routes *)
  let routes = router
    ~middlewares:bot.middleware
    ?on_error:bot.on_error
    bot.routes
  in
  (* Delegate to existing run_polling *)
  run_polling ~env:bot.env ~client:bot.client routes

(** Add a command handler to the bot *)
let command ?(desc = "") cmd_name handler bot =
  (* Create route with flipped handler signature for better ergonomics
     Handler takes (ctx -> string list -> unit) but Event expects (string list -> ctx -> unit) *)
  let flipped_handler args ctx = handler ctx args in
  let route_obj = route (Event.Command cmd_name) flipped_handler in
  (* Apply scoped middleware to this route *)
  let route_obj = { route_obj with middleware = bot.scoped_middleware @ route_obj.middleware } in
  (* Apply scoped error handler to this route *)
  let route_obj = { route_obj with on_error = bot.scoped_error_handler } in
  (* Store description if provided *)
  let command_descriptions =
    if desc <> "" then
      bot.command_descriptions @ [(cmd_name, desc)]
    else
      bot.command_descriptions
  in
  (* Return new bot with route and description added *)
  { bot with
    routes = bot.routes @ [route_obj];
    command_descriptions;
  }

(** Get list of registered commands with their descriptions *)
let commands bot = bot.command_descriptions

(** Add a command handler with type-safe argument parser *)
let command_with ?(desc = "") cmd_name parser handler bot =
  (* Handler that runs parser and calls user handler on success *)
  let parsing_handler ctx args =
    match parser args with
    | Ok parsed_value ->
        handler ctx parsed_value
    | Error err_msg ->
        (* Send error message to user *)
        let _ = Ctx.reply ctx ("❌ " ^ err_msg) in
        ()
  in
  (* Create route with the parsing handler *)
  let flipped_handler args ctx = parsing_handler ctx args in
  let route_obj = route (Event.Command cmd_name) flipped_handler in
  (* Apply scoped middleware to this route *)
  let route_obj = { route_obj with middleware = bot.scoped_middleware @ route_obj.middleware } in
  (* Apply scoped error handler to this route *)
  let route_obj = { route_obj with on_error = bot.scoped_error_handler } in
  (* Store description if provided *)
  let command_descriptions =
    if desc <> "" then
      bot.command_descriptions @ [(cmd_name, desc)]
    else
      bot.command_descriptions
  in
  (* Return new bot with route and description added *)
  { bot with
    routes = bot.routes @ [route_obj];
    command_descriptions;
  }

(** Add an event handler to the bot - builder pattern *)
let on : type a. a Event.t -> ([ `Chat ] ctx -> a -> unit) -> bot -> bot =
  fun event handler bot ->
    (* Flip handler signature: builder takes (ctx -> data -> unit)
       but route expects (data -> ctx -> unit) *)
    let flipped_handler data ctx = handler ctx data in
    let route_obj = route event flipped_handler in
    (* Apply scoped middleware to this route *)
    let route_obj = { route_obj with middleware = bot.scoped_middleware @ route_obj.middleware } in
    (* Apply scoped error handler to this route *)
    let route_obj = { route_obj with on_error = bot.scoped_error_handler } in
    (* Return new bot with route added *)
    { bot with routes = bot.routes @ [route_obj] }

(** Convenience methods for common event types *)

(** Add a text message handler to the bot *)
let on_text handler bot =
  on Event.text handler bot

(** Add a message handler to the bot *)
let on_message handler bot =
  on Event.message handler bot

(** Add a callback query handler to the bot *)
let on_callback handler bot =
  (* Create a filter on callback_query updates that extracts the data *)
  let callback_event = Event.when_ Event.any (fun upd ->
    match upd.Telegram_generated.Gen_types.Update.callback_query with
    | Some _ -> true
    | None -> false
  ) in
  let wrapped_handler ctx upd =
    match upd.Telegram_generated.Gen_types.Update.callback_query with
    | Some cbq ->
        let data = Option.value cbq.Telegram_generated.Gen_types.CallbackQuery.data ~default:"" in
        handler ctx data
    | None -> ()
  in
  on callback_event wrapped_handler bot

(** Add a photo message handler to the bot *)
let on_photo handler bot =
  (* Filter messages that have photos *)
  let photo_event = Event.when_ Event.message (fun msg ->
    match msg.Telegram_generated.Gen_types.Message.photo with
    | Some (_ :: _) -> true
    | _ -> false
  ) in
  let wrapped_handler ctx msg =
    match msg.Telegram_generated.Gen_types.Message.photo with
    | Some photos -> handler ctx photos
    | None -> ()
  in
  on photo_event wrapped_handler bot

(** Middleware integration *)

(** Add middleware that applies to all routes *)
let use mw bot =
  { bot with middleware = bot.middleware @ [mw] }

(** Add scoped middleware that applies only to routes added after this point *)
let scope mws bot =
  { bot with scoped_middleware = bot.scoped_middleware @ mws }

(** Clear all scoped middleware *)
let end_scope bot =
  { bot with scoped_middleware = [] }

(** Error handling *)

(** Set global error handler for the bot *)
let on_error handler bot =
  { bot with on_error = Some handler }

(** Set scoped error handler for subsequently added routes *)
let catch handler bot =
  { bot with scoped_error_handler = Some handler }

(** Add a command handler with automatic Result error handling *)
let command_safe ?(desc = "") cmd_name handler bot =
  (* Wrapper that handles Result type *)
  let safe_handler ctx args =
    match handler ctx args with
    | Ok () -> ()
    | Error err_msg ->
        (* Send error message to user *)
        let _ = Ctx.reply ctx ("❌ " ^ err_msg) in
        ()
  in
  (* Delegate to regular command function *)
  command ~desc cmd_name safe_handler bot

(** Bot composition *)

let merge bot1 bot2 =
  (* Merge two bots, combining their routes and configuration.
     Routes from bot1 come first (higher priority).
     Uses bot2's client, env, and scoped state (current state).
     Global middleware and error handlers are combined. *)
  {
    client = bot2.client;
    env = bot2.env;
    routes = bot1.routes @ bot2.routes;
    middleware = bot1.middleware @ bot2.middleware;
    scoped_middleware = bot2.scoped_middleware;
    on_error = (match bot2.on_error with
      | Some _ as handler -> handler
      | None -> bot1.on_error);
    scoped_error_handler = bot2.scoped_error_handler;
    command_descriptions = bot1.command_descriptions @ bot2.command_descriptions;
  }

(** Sub-routers with command prefixes *)

let scope_prefix prefix bot =
  (* Transform all command routes to add a prefix to the command name.
     This enables namespacing commands for modular organization.
     Non-command routes are left unchanged. *)

  (* Helper to transform a route's handler if it's a command *)
  let transform_route route =
    let Handler (event, handler) = route.handler in
    match event with
    | Event.Command cmd_name ->
        (* Create new command with prefixed name *)
        let prefixed_cmd = prefix ^ cmd_name in
        let new_handler = Handler (Event.Command prefixed_cmd, handler) in
        { route with handler = new_handler }
    | _ ->
        (* Non-command routes are unchanged *)
        route
  in

  (* Transform command descriptions to include prefix *)
  let transform_descriptions =
    List.map (fun (cmd, desc) -> (prefix ^ cmd, desc)) bot.command_descriptions
  in

  {
    bot with
    routes = List.map transform_route bot.routes;
    command_descriptions = transform_descriptions;
  }

(** Conditional routing *)

let when_ predicate bot =
  (* Wrap all route handlers to check the predicate before executing.
     If predicate returns false, the handler does nothing (route effectively doesn't match). *)

  let wrap_route route =
    let Handler (event, handler) = route.handler in
    let conditional_handler data ctx =
      if predicate ctx then
        handler data ctx
      else
        () (* Predicate failed, do nothing *)
    in
    { route with handler = Handler (event, conditional_handler) }
  in

  {
    bot with
    routes = List.map wrap_route bot.routes;
  }
