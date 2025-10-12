open Telegram
open Telegram.Error

type +'s ctx = {
  client : Client.t option;
  env : Client.env option;
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

(* Module type S - defines the signature of the bot module *)
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
  val on_photo : ([ `Chat ] ctx -> Telegram_generated.Gen_types.PhotoSize.t list -> (unit, Telegram.Error.t) result) -> bot -> bot

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

(* Functor-based implementation *)
module Make
  (Log : Telegram.Log.S)
  (Session_impl : Session.S)
  (Polling_impl : Polling.S)
: S = struct

  (* Compose dependent modules with same logging *)
  module Session_ops = Session_impl
  module Polling_ops = Polling_impl

  (* Exception wrapper for Error.t to convert to exn *)
  exception Bot_error of Error.t

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
  (** Parse command name and arguments from message text and entities.
      Returns (command_name, args) option where command_name has no leading slash or @botname.
      This function parses entities only once to avoid infinite loops. *)
  let parse_command_args text entities =
    Log.debug' (fun () ->
      let ent_count = match entities with Some e -> List.length e | None -> 0 in
      Format.asprintf "Command parsing: raw_text=%s, entities=%d" text ent_count
    );

    (* Find the bot_command entity *)
    let parsed = parse_entities text entities in
    let cmd_entities = filter_by_type `BotCommand parsed in
    match cmd_entities with
    | [] -> None  (* No command found *)
    | cmd :: _ ->
        (* Extract command name and strip leading / and @botname *)
        let cmd_text = cmd.text in
        let cmd_text_no_slash = if String.length cmd_text > 0 && cmd_text.[0] = '/' then
          String.sub cmd_text 1 (String.length cmd_text - 1)
        else cmd_text in

        (* Command name normalization (strip @botname) *)
        let cmd_name = (match String.index_opt cmd_text_no_slash '@' with
          | Some idx ->
              let botname = String.sub cmd_text_no_slash (idx + 1) (String.length cmd_text_no_slash - idx - 1) in
              Log.debug "Command name normalization: @botname stripped (%s)" botname;
              String.sub cmd_text_no_slash 0 idx
          | None -> cmd_text_no_slash) in

        (* Get text after the command *)
        let args_start = cmd.offset + cmd.length in
        let args = if args_start >= String.length text then
          []  (* Command with no args *)
        else
          let args_text = String.sub text args_start (String.length text - args_start) in
          let trimmed = String.trim args_text in
          if trimmed = "" then []
          else String.split_on_char ' ' trimmed |> List.filter (fun s -> s <> "")
        in

        Log.debug "Arguments extracted: args=[%s]" (String.concat ", " args);

        Some (cmd_name, args)
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
      (* Extract update type for logging *)
      let update_type =
        let open Telegram_generated.Gen_types.Update in
        let { message; edited_message; channel_post; edited_channel_post;
              inline_query; callback_query; _ } = upd_param in
        if message <> None then "message"
        else if edited_message <> None then "edited_message"
        else if channel_post <> None then "channel_post"
        else if edited_channel_post <> None then "edited_channel_post"
        else if inline_query <> None then "inline_query"
        else if callback_query <> None then "callback_query"
        else "other"
      in

      let event_type_str = match event with
        | Any -> "Any"
        | Message -> "Message"
        | Text -> "Text"
        | Command cmd -> "Command(" ^ cmd ^ ")"
        | Callback _ -> "Callback"
        | Inline_query -> "Inline_query"
        | Combine _ -> "Combine"
        | Filter _ -> "Filter"
      in

      Log.debug "Event.match_event called: event_type=%s, update_type=%s"
        event_type_str update_type;

      match event with
      | Any ->
          (* Create minimal context for 'any' event *)
          let ctx = {
            client = None; (* Will be set by dispatch_update *)
            env = None;
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
                 client = None; (* Will be filled by dispatch_update *)
                 env = None; (* Will be filled by dispatch_update *)
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
                    (* Try entity-aware parsing first - now returns (cmd_name, args) *)
                    (match Entity.parse_command_args text msg.entities with
                     | Some (cmd_name, args) ->
                         (* Check if this is the command we're looking for *)
                         if cmd_name = cmd then (
                           let user_id = match msg.from with
                             | Some user -> Int64.to_string user.id
                             | None -> "unknown"
                           in
                           Log.info "Command received: command_name=%s, user_id=%s, args_count=%d"
                             cmd_name user_id (List.length args);
                           match match_event Message upd_param with
                           | Some (_, ctx) -> Some (args, ctx)
                           | None -> None
                         ) else None
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
                 client = None;
                 env = None;
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
           | Some (value, ctx) ->
               let pred_result = predicate value in
               Log.debug "Filter predicate evaluated: result=%b" pred_result;
               if pred_result then Some (value, ctx) else None
           | None -> None)
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
    ~on_error:(fun _ctx err ->
      Format.eprintf "%s Handler error: %s@." prefix (Printexc.to_string err))
    "logging"

  (* Authorization middleware - only allow specific user IDs *)
  let only_users allowed_ids =
    make ~before:(fun ctx ->
      match ctx.user with
      | Some u ->
          let user_id = u.Telegram.Types.id in
          let user_id_str = Telegram.Id.to_string user_id in
          let is_allowed = List.mem user_id allowed_ids in
          Log.debug "User whitelist check: user_id=%s, is_allowed=%b" user_id_str is_allowed;
          if is_allowed then
            Ok ctx
          else (
            Log.warn "Unauthorized access attempt: user_id=%s, required_role=whitelisted_user"
              user_id_str;
            Error "Unauthorized user"
          )
      | None ->
          Log.warn "Unauthorized access attempt: user_id=none, required_role=whitelisted_user";
          Error "No user in update")
    "only_users"

  (* Authorization middleware - require user to be present *)
  let require_user () =
    make ~before:(fun ctx ->
      match ctx.user with
      | Some u ->
          let user_id_str = Telegram.Id.to_string u.Telegram.Types.id in
          Log.debug "Authorization check: user_id=%s, has_permission=true" user_id_str;
          Ok ctx
      | None ->
          Log.warn "Authorization check failed: user_id=none, required_role=any_user";
          Error "User required")
    "require_user"

  (* Authorization middleware - require chat to be present *)
  let require_chat () =
    make ~before:(fun ctx ->
      match ctx.chat with
      | Some chat_id ->
          let chat_id_str = Telegram.Id.to_string chat_id in
          Log.debug "Authorization check: chat_id=%s, has_permission=true" chat_id_str;
          Ok ctx
      | None ->
          Log.warn "Authorization check failed: chat_id=none, required_role=any_chat";
          Error "Chat required")
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
          let user_id_str = Telegram.Id.to_string user_id in
          let count = try H.find requests user_id with Not_found -> (ref 0, ref now) in
          let (counter, first_req) = count in

          (* Reset if window expired *)
          if now -. !first_req > 60.0 then (
            Log.debug "Rate limit window expired: user_id=%s, resetting counter" user_id_str;
            counter := 1;
            first_req := now;
            H.replace requests user_id (counter, first_req);
            Log.debug "Rate counter incremented: user_id=%s, new_count=%d" user_id_str !counter;
            Ok ctx
          ) else if !counter >= max_per_minute then (
            Log.warn "Rate limit exceeded: user_id=%s, current=%d, limit=%d"
              user_id_str !counter max_per_minute;
            Error "Rate limit exceeded"
          ) else (
            Log.debug "Rate check: user_id=%s, count=%d, limit=%d, window=60s"
              user_id_str !counter max_per_minute;
            incr counter;
            H.replace requests user_id (counter, first_req);
            Log.debug "Rate counter incremented: user_id=%s, new_count=%d" user_id_str !counter;
            Ok ctx
          )
      | None -> Ok ctx (* No user, no rate limit *))
    "rate_limit"

  (* Context enricher - add custom data *)
  let enrich f =
    make ~before:(fun ctx -> Ok (f ctx)) "enrich"

  (* Session middleware - adds session to context *)
  let with_session (type s) (module Store : Session_ops.STORE with type store = s) store =
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
  let client c = Option.get c.client  (* guaranteed to be Some in valid contexts *)
  let env c = Option.get c.env  (* guaranteed to be Some in valid contexts *)
  let chat (c : [ `Chat ] t) = Option.get c.chat  (* guaranteed to be Some in Chat context *)
  let user c = c.user
  let message (c : [ `Chat ] t) = Option.get c.msg  (* guaranteed to be Some in Chat context *)

  (* Helper to serialize inline keyboard markup to JSON string *)
  let serialize_keyboard (kb : Telegram.Types.inline_keyboard_markup) : string =
    let open Telegram_generated.Gen_types in
    let uf = Telegram.Json_compat.Unknown_fields.create () in
    let inline_keyboard = List.map (fun row ->
      List.map (fun btn ->
        match btn with
        | Telegram.Types.Url_button { text; url } ->
            {
              InlineKeyboardButton.text;
              url = Some url;
              callback_data = None;
              web_app = None;
              login_url = None;
              switch_inline_query = None;
              switch_inline_query_current_chat = None;
              switch_inline_query_chosen_chat = None;
              copy_text = None;
              callback_game = None;
              pay = None;
              unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf [];
            }
        | Telegram.Types.Callback_button { text; data } ->
            {
              InlineKeyboardButton.text;
              callback_data = Some data;
              url = None;
              web_app = None;
              login_url = None;
              switch_inline_query = None;
              switch_inline_query_current_chat = None;
              switch_inline_query_chosen_chat = None;
              copy_text = None;
              callback_game = None;
              pay = None;
              unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf [];
            }
      ) row
    ) kb in
    let markup = {
      InlineKeyboardMarkup.inline_keyboard;
      unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf [];
    } in
    InlineKeyboardMarkup.to_yojson markup |> Yojson.Safe.to_string

  (* Convenience helpers for sending messages *)
  let reply ?keyboard (c : [ `Chat ] t) text =
    let open Result_syntax in
    let cli = client c in
    let chat_id = chat c in
    let msg = message c in
    let base_params = [
      ("chat_id", Param.string (Id.to_string chat_id));
      ("text", Param.string text);
      ("reply_parameters", Param.json (`Assoc [
        ("message_id", `Int msg.message_id)
      ]));
    ] in
    let params = match keyboard with
      | Some kb -> base_params @ [("reply_markup", Param.string (serialize_keyboard kb))]
      | None -> base_params
    in
    let* json = Api.call_method cli ~method_name:"sendMessage" params in
    match Telegram_generated.Gen_types.Message.of_yojson json with
    | Ok m -> Ok m
    | Error err -> Error (Decode_error ("Failed to decode sent message: " ^ err))

  (* Alias for reply *)
  let answer = reply

  (* Send a message to the chat without replying *)
  let send ?keyboard (c : [ `Chat ] t) text =
    let open Result_syntax in
    let cli = client c in
    let chat_id = chat c in
    let base_params = [
      ("chat_id", Param.string (Id.to_string chat_id));
      ("text", Param.string text);
    ] in
    let params = match keyboard with
      | Some kb -> base_params @ [("reply_markup", Param.string (serialize_keyboard kb))]
      | None -> base_params
    in
    let* json = Api.call_method cli ~method_name:"sendMessage" params in
    match Telegram_generated.Gen_types.Message.of_yojson json with
    | Ok m -> Ok m
    | Error err -> Error (Decode_error ("Failed to decode sent message: " ^ err))

  (* Edit the current message (for callback queries) *)
  let edit ?keyboard (c : [ `Chat ] t) text =
    let open Result_syntax in
    let cli = client c in
    let chat_id = chat c in
    let msg = message c in
    let base_params = [
      ("chat_id", Param.string (Id.to_string chat_id));
      ("message_id", Param.int msg.message_id);
      ("text", Param.string text);
    ] in
    let params = match keyboard with
      | Some kb -> base_params @ [("reply_markup", Param.string (serialize_keyboard kb))]
      | None -> base_params
    in
    let* json = Api.call_method cli ~method_name:"editMessageText" params in
    match json with
    | `Bool true -> Ok ()
    | _ ->
        (match Telegram_generated.Gen_types.Message.of_yojson json with
         | Ok _ -> Ok ()
         | Error err -> Error (Decode_error ("Failed to decode edited message: " ^ err)))

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
    Session_ops.get (session c) key

  let session_set (c : _ t) key value =
    Session_ops.set (session c) key value

  let session_get_or (c : _ t) key ~default =
    Session_ops.get_or (session c) key ~default

  let session_delete (c : _ t) key =
    Session_ops.delete (session c) key

  let session_exists (c : _ t) key =
    Session_ops.exists (session c) key

  let session_clear (c : _ t) =
    Session_ops.clear (session c)

  let session_modify (c : _ t) key ~default f =
    Session_ops.modify (session c) key ~default f

  (* Stateful handlers - ergonomic aliases for session operations *)

  let get_state (c : _ t) key =
    session_get c key
  (** [get_state ctx key] retrieves a value from the session.
      Returns [Some value] if the key exists, [None] otherwise.
      This is an ergonomic alias for [session_get]. *)

  let set_state (c : _ t) key value =
    session_set c key value
  (** [set_state ctx key value] stores a value in the session.
      This is an ergonomic alias for [session_set]. *)

  let modify_state (c : _ t) key ~default f =
    session_modify c key ~default f
  (** [modify_state ctx key ~default f] atomically updates a session value.
      If the key doesn't exist, uses [default] as the initial value.
      This is an ergonomic alias for [session_modify]. *)

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

  let reply_ ?keyboard ctx text =
    match reply ?keyboard ctx text with
    | Ok _ -> Ok ()
    | Error e -> Error e
  (** [reply_ ?keyboard ctx text] sends a reply and returns [Ok ()] on success.
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

type handler = Handler : 'a Event.t * ('a -> [ `Chat ] ctx -> (unit, Error.t) result) -> handler

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

(* Internal: try to match and execute routes against an update *)
let dispatch_update client env routes update =
  (* Extract update_id and type for logging *)
  let open Telegram_generated.Gen_types.Update in
  let { update_id; message; edited_message; channel_post; edited_channel_post;
        inline_query; callback_query; _ } = update in
  let update_type =
    if message <> None then "message"
    else if edited_message <> None then "edited_message"
    else if channel_post <> None then "channel_post"
    else if edited_channel_post <> None then "edited_channel_post"
    else if inline_query <> None then "inline_query"
    else if callback_query <> None then "callback_query"
    else "other"
  in

  Log.info "Dispatching update: update_id=%Ld, type=%s" update_id update_type;

  let route_index = ref 0 in
  let matched_route = ref None in

  let rec try_routes = function
    | [] ->
        if !matched_route = None then
          Log.warn "No route matched for update: update_id=%Ld, type=%s" update_id update_type;
        () (* No route matched *)
    | route :: rest ->
        let current_index = !route_index in
        route_index := !route_index + 1;

        let { handler = Handler (event, handler); middleware; on_error } = route in

        let event_type_str = match event with
          | Event.Any -> "Any"
          | Event.Message -> "Message"
          | Event.Text -> "Text"
          | Event.Command cmd -> "Command(" ^ cmd ^ ")"
          | Event.Callback _ -> "Callback"
          | Event.Inline_query -> "Inline_query"
          | Event.Combine _ -> "Combine"
          | Event.Filter _ -> "Filter"
        in

        Log.debug "Trying route: route_index=%d, event_type=%s" current_index event_type_str;

        (match Event.match_event event update with
         | Some (value, ctx) ->
             matched_route := Some current_index;
             Log.info "Route matched: route_index=%d" current_index;

             let start_time = Unix.gettimeofday () in

             (* Fill in client and env in the context *)
             let ctx = { ctx with client = Some client; env = Some env } in

             Log.debug' (fun () ->
               let has_user = ctx.user <> None in
               let has_chat = ctx.chat <> None in
               let has_message = ctx.msg <> None in
               Format.asprintf "Context preparation: has_user=%b, has_chat=%b, has_message=%b"
                 has_user has_chat has_message
             );

             (* Run middleware before hooks *)
             let middleware_count = List.length middleware in
             if middleware_count > 0 then
               Log.info "Middleware chain started: middleware_count=%d" middleware_count;

             let ctx_result = List.fold_left (fun acc mw ->
               match acc with
               | Error _ as e -> e
               | Ok ctx ->
                   Log.debug "Middleware.before: middleware_name=%s" mw.Middleware.name;
                   match mw.Middleware.before ctx with
                   | Ok enriched_ctx -> Ok enriched_ctx
                   | Error reason ->
                       Log.debug "Middleware rejected request: middleware_name=%s, reason=%s"
                         mw.Middleware.name reason;
                       Error reason
             ) (Ok ctx) middleware in

             (match ctx_result with
              | Error err ->
                  (* Middleware rejected the request *)
                  Log.warn "Middleware rejected: %s" err;
                  Printf.eprintf "Middleware rejected: %s\n%!" err
              | Ok enriched_ctx ->
                  Log.info "Handler executing: handler_type=%s" event_type_str;

                  (* Call the handler - it returns Result *)
                  let handler_result = handler value enriched_ctx in
                  let duration = (Unix.gettimeofday () -. start_time) *. 1000.0 in

                  (match handler_result with
                   | Ok () ->
                       Log.info "Handler returned Ok";
                       Log.info "Handler execution completed: duration=%.1fms" duration;
                       Log.debug "Handler result: Ok";
                       (* Handler succeeded, run middleware after hooks *)
                       List.iter (fun mw ->
                         Log.debug "Middleware.after: middleware_name=%s" mw.Middleware.name;
                         mw.Middleware.after enriched_ctx
                       ) (List.rev middleware);
                       if middleware_count > 0 then
                         Log.info "Middleware chain completed"
                   | Error err ->
                       Log.error "Handler returned Error: %a" Error.pp err;
                       Log.debug "Handler result: Error";
                       (* Handler returned error, run error handlers *)
                       (* Run middleware error hooks - middleware expects exn *)
                       let exn_err = Bot_error err in
                       List.iter (fun mw ->
                         Log.debug "Middleware.on_error: middleware_name=%s, error=%a"
                           mw.Middleware.name Error.pp err;
                         mw.Middleware.on_error enriched_ctx exn_err
                       ) (List.rev middleware);
                       (* Call route-specific error handler if present *)
                       (match on_error with
                        | Some err_h -> err_h enriched_ctx exn_err
                        | None -> Format.eprintf "Handler error: %a@." Error.pp err)))
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
  Polling_ops.run client ~handler

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
        Ok ()
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
let on : type a. a Event.t -> ([ `Chat ] ctx -> a -> (unit, Error.t) result) -> bot -> bot =
  fun event handler bot ->
    (* Flip handler signature: builder takes (ctx -> data -> (unit, Error.t) result)
       but route expects (data -> ctx -> (unit, Error.t) result) *)
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
    | None -> Ok ()
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
    | None -> Ok ()
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
    | Ok () -> Ok ()
    | Error err_msg ->
        (* Send error message to user *)
        let _ = Ctx.reply ctx ("❌ " ^ err_msg) in
        Ok ()
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
        Ok () (* Predicate failed, do nothing *)
    in
    { route with handler = Handler (event, conditional_handler) }
  in

  {
    bot with
    routes = List.map wrap_route bot.routes;
  }

(** Session integration *)

let with_sessions (type s) (module Store : Session_ops.STORE with type store = s) store bot =
  (* Auto-enable session middleware for the bot.
     This is sugar over manually using Bot.use with Middleware.with_session. *)
  let session_middleware = Middleware.with_session (module Store) store in
  use session_middleware bot

(** Session-based routing for state machines *)

let when_state : type a. a Session.key -> (a option -> bool) -> bot -> bot =
  fun key predicate bot ->
    (* Filter routes based on session state.
       Only execute handlers when the session state matches the predicate. *)
    let state_predicate ctx =
      match ctx.session with
      | None -> false  (* No session, predicate fails *)
      | Some session ->
          let state = Session_ops.get session key in
          predicate state
    in
    when_ state_predicate bot

let when_state_eq : type a. a Session.key -> a -> bot -> bot =
  fun key expected_state bot ->
    (* Convenience function to check if session state equals expected value. *)
    when_state key (fun state_opt ->
      match state_opt with
      | Some state -> state = expected_state
      | None -> false
    ) bot

let on_state : type a b. a Session.key -> a -> b Event.t -> ([ `Chat ] ctx -> b -> (unit, Error.t) result) -> bot -> bot =
  fun key state event handler bot ->
    (* Add a route that only executes when session is in the specified state.
       This is sugar for: bot |> on event handler |> when_state_eq key state *)
    bot
    |> on event handler
    |> when_state_eq key state

end

(* Default logging configuration *)
module Log_default = Telegram.Log.Make (Telegram.Log.Console) (struct
  let src = "Bot"
  let level = Telegram.Log.Info
end)

(* Instantiate dependencies with default logging *)
module Session_default = Session.Make (Log_default)
module Polling_default = Polling.Make (Log_default)

(* Default instantiation for backward compatibility *)
include Make (Log_default) (Session_default) (Polling_default)

(* Error handler utilities - outside Make since they're in top-level .mli *)
module ErrorHandler = struct
  let log _ctx exn =
    Format.eprintf "[Bot Error] %s\n%!" (Printexc.to_string exn)

  let log_and_reply ?(message = "Sorry, an error occurred while processing your request.") () ctx exn =
    log ctx exn;
    (* Try to send error message to user *)
    (match Ctx.reply ctx message with
     | Ok _ -> ()
     | Error e ->
         Format.eprintf "[Bot Error] Failed to send error message to user: %a\n%!"
           Error.pp e)

  let silent _ctx _exn = ()

  let combine handlers ctx exn =
    List.iter (fun h -> h ctx exn) handlers
end
