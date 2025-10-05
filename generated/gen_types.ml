(* Generated from reference/api.html *)
module rec GetUpdates : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SetWebhook : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and DeleteWebhook : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and GetWebhookInfo : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    url : string;
    has_custom_certificate : bool;
    pending_update_count : int64;
    ip_address : string option;
    last_error_date : int64 option;
    last_error_message : string option;
    last_synchronization_error_date : int64 option;
    max_connections : int64 option;
    allowed_updates : string list option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("url", `String v.url);
      ("has_custom_certificate", `Bool v.has_custom_certificate);
      ("pending_update_count", `Intlit (Int64.to_string v.pending_update_count));
      (match v.ip_address with None -> ("ip_address", `Null) | Some x -> ("ip_address", `String x));
      (match v.last_error_date with None -> ("last_error_date", `Null) | Some x -> ("last_error_date", `Intlit (Int64.to_string x)));
      (match v.last_error_message with None -> ("last_error_message", `Null) | Some x -> ("last_error_message", `String x));
      (match v.last_synchronization_error_date with None -> ("last_synchronization_error_date", `Null) | Some x -> ("last_synchronization_error_date", `Intlit (Int64.to_string x)));
      (match v.max_connections with None -> ("max_connections", `Null) | Some x -> ("max_connections", `Intlit (Int64.to_string x)));
      (match v.allowed_updates with None -> ("allowed_updates", `Null) | Some x -> ("allowed_updates", `List (List.map (fun x -> `String x) x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "url";
          let url = (to_string (List.assoc "url" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "has_custom_certificate";
          let has_custom_certificate = (to_bool (List.assoc "has_custom_certificate" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "pending_update_count";
          let pending_update_count = (match (List.assoc "pending_update_count" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "pending_update_count" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "ip_address";
          let ip_address = match List.assoc_opt "ip_address" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "last_error_date";
          let last_error_date = match List.assoc_opt "last_error_date" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "last_error_message";
          let last_error_message = match List.assoc_opt "last_error_message" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "last_synchronization_error_date";
          let last_synchronization_error_date = match List.assoc_opt "last_synchronization_error_date" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "max_connections";
          let max_connections = match List.assoc_opt "max_connections" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "allowed_updates";
          let allowed_updates = match List.assoc_opt "allowed_updates" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (to_string x)) (to_list x))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { url = url; has_custom_certificate = has_custom_certificate; pending_update_count = pending_update_count; ip_address = ip_address; last_error_date = last_error_date; last_error_message = last_error_message; last_synchronization_error_date = last_synchronization_error_date; max_connections = max_connections; allowed_updates = allowed_updates; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and WebhookInfo : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    url : string;
    has_custom_certificate : bool;
    pending_update_count : int64;
    ip_address : string option;
    last_error_date : int64 option;
    last_error_message : string option;
    last_synchronization_error_date : int64 option;
    max_connections : int64 option;
    allowed_updates : string list option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("url", `String v.url);
      ("has_custom_certificate", `Bool v.has_custom_certificate);
      ("pending_update_count", `Intlit (Int64.to_string v.pending_update_count));
      (match v.ip_address with None -> ("ip_address", `Null) | Some x -> ("ip_address", `String x));
      (match v.last_error_date with None -> ("last_error_date", `Null) | Some x -> ("last_error_date", `Intlit (Int64.to_string x)));
      (match v.last_error_message with None -> ("last_error_message", `Null) | Some x -> ("last_error_message", `String x));
      (match v.last_synchronization_error_date with None -> ("last_synchronization_error_date", `Null) | Some x -> ("last_synchronization_error_date", `Intlit (Int64.to_string x)));
      (match v.max_connections with None -> ("max_connections", `Null) | Some x -> ("max_connections", `Intlit (Int64.to_string x)));
      (match v.allowed_updates with None -> ("allowed_updates", `Null) | Some x -> ("allowed_updates", `List (List.map (fun x -> `String x) x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "url";
          let url = (to_string (List.assoc "url" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "has_custom_certificate";
          let has_custom_certificate = (to_bool (List.assoc "has_custom_certificate" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "pending_update_count";
          let pending_update_count = (match (List.assoc "pending_update_count" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "pending_update_count" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "ip_address";
          let ip_address = match List.assoc_opt "ip_address" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "last_error_date";
          let last_error_date = match List.assoc_opt "last_error_date" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "last_error_message";
          let last_error_message = match List.assoc_opt "last_error_message" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "last_synchronization_error_date";
          let last_synchronization_error_date = match List.assoc_opt "last_synchronization_error_date" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "max_connections";
          let max_connections = match List.assoc_opt "max_connections" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "allowed_updates";
          let allowed_updates = match List.assoc_opt "allowed_updates" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (to_string x)) (to_list x))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { url = url; has_custom_certificate = has_custom_certificate; pending_update_count = pending_update_count; ip_address = ip_address; last_error_date = last_error_date; last_error_message = last_error_message; last_synchronization_error_date = last_synchronization_error_date; max_connections = max_connections; allowed_updates = allowed_updates; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and User : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    id : int64;
    is_bot : bool;
    first_name : string;
    last_name : string option;
    username : string option;
    language_code : string option;
    is_premium : bool option;
    added_to_attachment_menu : bool option;
    can_join_groups : bool option;
    can_read_all_group_messages : bool option;
    supports_inline_queries : bool option;
    can_connect_to_business : bool option;
    has_main_web_app : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("id", `Intlit (Int64.to_string v.id));
      ("is_bot", `Bool v.is_bot);
      ("first_name", `String v.first_name);
      (match v.last_name with None -> ("last_name", `Null) | Some x -> ("last_name", `String x));
      (match v.username with None -> ("username", `Null) | Some x -> ("username", `String x));
      (match v.language_code with None -> ("language_code", `Null) | Some x -> ("language_code", `String x));
      (match v.is_premium with None -> ("is_premium", `Null) | Some x -> ("is_premium", `Bool x));
      (match v.added_to_attachment_menu with None -> ("added_to_attachment_menu", `Null) | Some x -> ("added_to_attachment_menu", `Bool x));
      (match v.can_join_groups with None -> ("can_join_groups", `Null) | Some x -> ("can_join_groups", `Bool x));
      (match v.can_read_all_group_messages with None -> ("can_read_all_group_messages", `Null) | Some x -> ("can_read_all_group_messages", `Bool x));
      (match v.supports_inline_queries with None -> ("supports_inline_queries", `Null) | Some x -> ("supports_inline_queries", `Bool x));
      (match v.can_connect_to_business with None -> ("can_connect_to_business", `Null) | Some x -> ("can_connect_to_business", `Bool x));
      (match v.has_main_web_app with None -> ("has_main_web_app", `Null) | Some x -> ("has_main_web_app", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (match (List.assoc "id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_bot";
          let is_bot = (to_bool (List.assoc "is_bot" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "first_name";
          let first_name = (to_string (List.assoc "first_name" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "last_name";
          let last_name = match List.assoc_opt "last_name" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "username";
          let username = match List.assoc_opt "username" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "language_code";
          let language_code = match List.assoc_opt "language_code" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_premium";
          let is_premium = match List.assoc_opt "is_premium" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "added_to_attachment_menu";
          let added_to_attachment_menu = match List.assoc_opt "added_to_attachment_menu" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_join_groups";
          let can_join_groups = match List.assoc_opt "can_join_groups" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_read_all_group_messages";
          let can_read_all_group_messages = match List.assoc_opt "can_read_all_group_messages" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "supports_inline_queries";
          let supports_inline_queries = match List.assoc_opt "supports_inline_queries" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_connect_to_business";
          let can_connect_to_business = match List.assoc_opt "can_connect_to_business" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "has_main_web_app";
          let has_main_web_app = match List.assoc_opt "has_main_web_app" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { id = id; is_bot = is_bot; first_name = first_name; last_name = last_name; username = username; language_code = language_code; is_premium = is_premium; added_to_attachment_menu = added_to_attachment_menu; can_join_groups = can_join_groups; can_read_all_group_messages = can_read_all_group_messages; supports_inline_queries = supports_inline_queries; can_connect_to_business = can_connect_to_business; has_main_web_app = has_main_web_app; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and Chat : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    id : int64;
    type_ : string;
    title : string option;
    username : string option;
    first_name : string option;
    last_name : string option;
    is_forum : bool option;
    is_direct_messages : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("id", `Intlit (Int64.to_string v.id));
      ("type", `String v.type_);
      (match v.title with None -> ("title", `Null) | Some x -> ("title", `String x));
      (match v.username with None -> ("username", `Null) | Some x -> ("username", `String x));
      (match v.first_name with None -> ("first_name", `Null) | Some x -> ("first_name", `String x));
      (match v.last_name with None -> ("last_name", `Null) | Some x -> ("last_name", `String x));
      (match v.is_forum with None -> ("is_forum", `Null) | Some x -> ("is_forum", `Bool x));
      (match v.is_direct_messages with None -> ("is_direct_messages", `Null) | Some x -> ("is_direct_messages", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (match (List.assoc "id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = match List.assoc_opt "title" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "username";
          let username = match List.assoc_opt "username" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "first_name";
          let first_name = match List.assoc_opt "first_name" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "last_name";
          let last_name = match List.assoc_opt "last_name" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_forum";
          let is_forum = match List.assoc_opt "is_forum" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_direct_messages";
          let is_direct_messages = match List.assoc_opt "is_direct_messages" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { id = id; type_ = type_; title = title; username = username; first_name = first_name; last_name = last_name; is_forum = is_forum; is_direct_messages = is_direct_messages; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and MessageId : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    message_id : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("message_id", `Intlit (Int64.to_string v.message_id));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "message_id";
          let message_id = (match (List.assoc "message_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "message_id" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { message_id = message_id; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and MessageOriginHiddenUser : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    date : int64;
    sender_user_name : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("date", `Intlit (Int64.to_string v.date));
      ("sender_user_name", `String v.sender_user_name);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "date";
          let date = (match (List.assoc "date" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "date" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "sender_user_name";
          let sender_user_name = (to_string (List.assoc "sender_user_name" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; date = date; sender_user_name = sender_user_name; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and PhotoSize : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    file_id : string;
    file_unique_id : string;
    width : int64;
    height : int64;
    file_size : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("file_id", `String v.file_id);
      ("file_unique_id", `String v.file_unique_id);
      ("width", `Intlit (Int64.to_string v.width));
      ("height", `Intlit (Int64.to_string v.height));
      (match v.file_size with None -> ("file_size", `Null) | Some x -> ("file_size", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_id";
          let file_id = (to_string (List.assoc "file_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_unique_id";
          let file_unique_id = (to_string (List.assoc "file_unique_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "width";
          let width = (match (List.assoc "width" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "width" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "height";
          let height = (match (List.assoc "height" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "height" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_size";
          let file_size = match List.assoc_opt "file_size" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { file_id = file_id; file_unique_id = file_unique_id; width = width; height = height; file_size = file_size; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and Voice : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    file_id : string;
    file_unique_id : string;
    duration : int64;
    mime_type : string option;
    file_size : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("file_id", `String v.file_id);
      ("file_unique_id", `String v.file_unique_id);
      ("duration", `Intlit (Int64.to_string v.duration));
      (match v.mime_type with None -> ("mime_type", `Null) | Some x -> ("mime_type", `String x));
      (match v.file_size with None -> ("file_size", `Null) | Some x -> ("file_size", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_id";
          let file_id = (to_string (List.assoc "file_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_unique_id";
          let file_unique_id = (to_string (List.assoc "file_unique_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "duration";
          let duration = (match (List.assoc "duration" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "duration" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "mime_type";
          let mime_type = match List.assoc_opt "mime_type" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_size";
          let file_size = match List.assoc_opt "file_size" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { file_id = file_id; file_unique_id = file_unique_id; duration = duration; mime_type = mime_type; file_size = file_size; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and PaidMedia : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    width : int64 option;
    height : int64 option;
    duration : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      (match v.width with None -> ("width", `Null) | Some x -> ("width", `Intlit (Int64.to_string x)));
      (match v.height with None -> ("height", `Null) | Some x -> ("height", `Intlit (Int64.to_string x)));
      (match v.duration with None -> ("duration", `Null) | Some x -> ("duration", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "width";
          let width = match List.assoc_opt "width" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "height";
          let height = match List.assoc_opt "height" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "duration";
          let duration = match List.assoc_opt "duration" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; width = width; height = height; duration = duration; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and PaidMediaPreview : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    width : int64 option;
    height : int64 option;
    duration : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      (match v.width with None -> ("width", `Null) | Some x -> ("width", `Intlit (Int64.to_string x)));
      (match v.height with None -> ("height", `Null) | Some x -> ("height", `Intlit (Int64.to_string x)));
      (match v.duration with None -> ("duration", `Null) | Some x -> ("duration", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "width";
          let width = match List.assoc_opt "width" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "height";
          let height = match List.assoc_opt "height" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "duration";
          let duration = match List.assoc_opt "duration" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; width = width; height = height; duration = duration; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and Contact : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    phone_number : string;
    first_name : string;
    last_name : string option;
    user_id : int64 option;
    vcard : string option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("phone_number", `String v.phone_number);
      ("first_name", `String v.first_name);
      (match v.last_name with None -> ("last_name", `Null) | Some x -> ("last_name", `String x));
      (match v.user_id with None -> ("user_id", `Null) | Some x -> ("user_id", `Intlit (Int64.to_string x)));
      (match v.vcard with None -> ("vcard", `Null) | Some x -> ("vcard", `String x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "phone_number";
          let phone_number = (to_string (List.assoc "phone_number" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "first_name";
          let first_name = (to_string (List.assoc "first_name" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "last_name";
          let last_name = match List.assoc_opt "last_name" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "user_id";
          let user_id = match List.assoc_opt "user_id" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "vcard";
          let vcard = match List.assoc_opt "vcard" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { phone_number = phone_number; first_name = first_name; last_name = last_name; user_id = user_id; vcard = vcard; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and Dice : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    emoji : string;
    value : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("emoji", `String v.emoji);
      ("value", `Intlit (Int64.to_string v.value));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "emoji";
          let emoji = (to_string (List.assoc "emoji" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "value";
          let value = (match (List.assoc "value" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "value" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { emoji = emoji; value = value; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and Location : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    latitude : float;
    longitude : float;
    horizontal_accuracy : float option;
    live_period : int64 option;
    heading : int64 option;
    proximity_alert_radius : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("latitude", `Float v.latitude);
      ("longitude", `Float v.longitude);
      (match v.horizontal_accuracy with None -> ("horizontal_accuracy", `Null) | Some x -> ("horizontal_accuracy", `Float x));
      (match v.live_period with None -> ("live_period", `Null) | Some x -> ("live_period", `Intlit (Int64.to_string x)));
      (match v.heading with None -> ("heading", `Null) | Some x -> ("heading", `Intlit (Int64.to_string x)));
      (match v.proximity_alert_radius with None -> ("proximity_alert_radius", `Null) | Some x -> ("proximity_alert_radius", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "latitude";
          let latitude = (to_float (List.assoc "latitude" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "longitude";
          let longitude = (to_float (List.assoc "longitude" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "horizontal_accuracy";
          let horizontal_accuracy = match List.assoc_opt "horizontal_accuracy" fields with None | Some `Null -> None | Some x -> Some ((to_float x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "live_period";
          let live_period = match List.assoc_opt "live_period" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "heading";
          let heading = match List.assoc_opt "heading" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "proximity_alert_radius";
          let proximity_alert_radius = match List.assoc_opt "proximity_alert_radius" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { latitude = latitude; longitude = longitude; horizontal_accuracy = horizontal_accuracy; live_period = live_period; heading = heading; proximity_alert_radius = proximity_alert_radius; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and WebAppData : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    data : string;
    button_text : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("data", `String v.data);
      ("button_text", `String v.button_text);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "data";
          let data = (to_string (List.assoc "data" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "button_text";
          let button_text = (to_string (List.assoc "button_text" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { data = data; button_text = button_text; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and MessageAutoDeleteTimerChanged : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    message_auto_delete_time : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("message_auto_delete_time", `Intlit (Int64.to_string v.message_auto_delete_time));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "message_auto_delete_time";
          let message_auto_delete_time = (match (List.assoc "message_auto_delete_time" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "message_auto_delete_time" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { message_auto_delete_time = message_auto_delete_time; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ChatBoostAdded : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    boost_count : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("boost_count", `Intlit (Int64.to_string v.boost_count));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "boost_count";
          let boost_count = (match (List.assoc "boost_count" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "boost_count" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { boost_count = boost_count; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and BackgroundFill : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    color : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("color", `Intlit (Int64.to_string v.color));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "color";
          let color = (match (List.assoc "color" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "color" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; color = color; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and BackgroundFillSolid : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    color : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("color", `Intlit (Int64.to_string v.color));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "color";
          let color = (match (List.assoc "color" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "color" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; color = color; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and BackgroundFillGradient : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    top_color : int64;
    bottom_color : int64;
    rotation_angle : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("top_color", `Intlit (Int64.to_string v.top_color));
      ("bottom_color", `Intlit (Int64.to_string v.bottom_color));
      ("rotation_angle", `Intlit (Int64.to_string v.rotation_angle));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "top_color";
          let top_color = (match (List.assoc "top_color" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "top_color" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "bottom_color";
          let bottom_color = (match (List.assoc "bottom_color" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "bottom_color" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "rotation_angle";
          let rotation_angle = (match (List.assoc "rotation_angle" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "rotation_angle" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; top_color = top_color; bottom_color = bottom_color; rotation_angle = rotation_angle; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and BackgroundFillFreeformGradient : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    colors : int64 list;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("colors", `List (List.map (fun x -> `Intlit (Int64.to_string x)) v.colors));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "colors";
          let colors = (List.map (fun x -> (match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) (to_list (List.assoc "colors" fields))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; colors = colors; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and BackgroundTypeChatTheme : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    theme_name : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("theme_name", `String v.theme_name);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "theme_name";
          let theme_name = (to_string (List.assoc "theme_name" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; theme_name = theme_name; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ForumTopicCreated : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    name : string;
    icon_color : int64;
    icon_custom_emoji_id : string option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("name", `String v.name);
      ("icon_color", `Intlit (Int64.to_string v.icon_color));
      (match v.icon_custom_emoji_id with None -> ("icon_custom_emoji_id", `Null) | Some x -> ("icon_custom_emoji_id", `String x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "name";
          let name = (to_string (List.assoc "name" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "icon_color";
          let icon_color = (match (List.assoc "icon_color" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "icon_color" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "icon_custom_emoji_id";
          let icon_custom_emoji_id = match List.assoc_opt "icon_custom_emoji_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { name = name; icon_color = icon_color; icon_custom_emoji_id = icon_custom_emoji_id; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ForumTopicClosed : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    name : string option;
    icon_custom_emoji_id : string option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      (match v.name with None -> ("name", `Null) | Some x -> ("name", `String x));
      (match v.icon_custom_emoji_id with None -> ("icon_custom_emoji_id", `Null) | Some x -> ("icon_custom_emoji_id", `String x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "name";
          let name = match List.assoc_opt "name" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "icon_custom_emoji_id";
          let icon_custom_emoji_id = match List.assoc_opt "icon_custom_emoji_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { name = name; icon_custom_emoji_id = icon_custom_emoji_id; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ForumTopicEdited : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    name : string option;
    icon_custom_emoji_id : string option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      (match v.name with None -> ("name", `Null) | Some x -> ("name", `String x));
      (match v.icon_custom_emoji_id with None -> ("icon_custom_emoji_id", `Null) | Some x -> ("icon_custom_emoji_id", `String x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "name";
          let name = match List.assoc_opt "name" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "icon_custom_emoji_id";
          let icon_custom_emoji_id = match List.assoc_opt "icon_custom_emoji_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { name = name; icon_custom_emoji_id = icon_custom_emoji_id; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and WriteAccessAllowed : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    from_request : bool option;
    web_app_name : string option;
    from_attachment_menu : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      (match v.from_request with None -> ("from_request", `Null) | Some x -> ("from_request", `Bool x));
      (match v.web_app_name with None -> ("web_app_name", `Null) | Some x -> ("web_app_name", `String x));
      (match v.from_attachment_menu with None -> ("from_attachment_menu", `Null) | Some x -> ("from_attachment_menu", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "from_request";
          let from_request = match List.assoc_opt "from_request" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "web_app_name";
          let web_app_name = match List.assoc_opt "web_app_name" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "from_attachment_menu";
          let from_attachment_menu = match List.assoc_opt "from_attachment_menu" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { from_request = from_request; web_app_name = web_app_name; from_attachment_menu = from_attachment_menu; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and VideoChatScheduled : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    start_date : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("start_date", `Intlit (Int64.to_string v.start_date));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "start_date";
          let start_date = (match (List.assoc "start_date" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "start_date" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { start_date = start_date; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and VideoChatStarted : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    duration : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("duration", `Intlit (Int64.to_string v.duration));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "duration";
          let duration = (match (List.assoc "duration" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "duration" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { duration = duration; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and VideoChatEnded : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    duration : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("duration", `Intlit (Int64.to_string v.duration));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "duration";
          let duration = (match (List.assoc "duration" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "duration" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { duration = duration; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and PaidMessagePriceChanged : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    paid_message_star_count : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("paid_message_star_count", `Intlit (Int64.to_string v.paid_message_star_count));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "paid_message_star_count";
          let paid_message_star_count = (match (List.assoc "paid_message_star_count" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "paid_message_star_count" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { paid_message_star_count = paid_message_star_count; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and DirectMessagePriceChanged : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    are_direct_messages_enabled : bool;
    direct_message_star_count : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("are_direct_messages_enabled", `Bool v.are_direct_messages_enabled);
      (match v.direct_message_star_count with None -> ("direct_message_star_count", `Null) | Some x -> ("direct_message_star_count", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "are_direct_messages_enabled";
          let are_direct_messages_enabled = (to_bool (List.assoc "are_direct_messages_enabled" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "direct_message_star_count";
          let direct_message_star_count = match List.assoc_opt "direct_message_star_count" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { are_direct_messages_enabled = are_direct_messages_enabled; direct_message_star_count = direct_message_star_count; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and GiveawayCreated : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    prize_star_count : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      (match v.prize_star_count with None -> ("prize_star_count", `Null) | Some x -> ("prize_star_count", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "prize_star_count";
          let prize_star_count = match List.assoc_opt "prize_star_count" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { prize_star_count = prize_star_count; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and LinkPreviewOptions : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    is_disabled : bool option;
    url : string option;
    prefer_small_media : bool option;
    prefer_large_media : bool option;
    show_above_text : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      (match v.is_disabled with None -> ("is_disabled", `Null) | Some x -> ("is_disabled", `Bool x));
      (match v.url with None -> ("url", `Null) | Some x -> ("url", `String x));
      (match v.prefer_small_media with None -> ("prefer_small_media", `Null) | Some x -> ("prefer_small_media", `Bool x));
      (match v.prefer_large_media with None -> ("prefer_large_media", `Null) | Some x -> ("prefer_large_media", `Bool x));
      (match v.show_above_text with None -> ("show_above_text", `Null) | Some x -> ("show_above_text", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_disabled";
          let is_disabled = match List.assoc_opt "is_disabled" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "url";
          let url = match List.assoc_opt "url" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "prefer_small_media";
          let prefer_small_media = match List.assoc_opt "prefer_small_media" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "prefer_large_media";
          let prefer_large_media = match List.assoc_opt "prefer_large_media" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "show_above_text";
          let show_above_text = match List.assoc_opt "show_above_text" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { is_disabled = is_disabled; url = url; prefer_small_media = prefer_small_media; prefer_large_media = prefer_large_media; show_above_text = show_above_text; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and SuggestedPostPrice : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    currency : string;
    amount : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("currency", `String v.currency);
      ("amount", `Intlit (Int64.to_string v.amount));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "currency";
          let currency = (to_string (List.assoc "currency" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "amount";
          let amount = (match (List.assoc "amount" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "amount" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { currency = currency; amount = amount; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and File : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    file_id : string;
    file_unique_id : string;
    file_size : int64 option;
    file_path : string option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("file_id", `String v.file_id);
      ("file_unique_id", `String v.file_unique_id);
      (match v.file_size with None -> ("file_size", `Null) | Some x -> ("file_size", `Intlit (Int64.to_string x)));
      (match v.file_path with None -> ("file_path", `Null) | Some x -> ("file_path", `String x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_id";
          let file_id = (to_string (List.assoc "file_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_unique_id";
          let file_unique_id = (to_string (List.assoc "file_unique_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_size";
          let file_size = match List.assoc_opt "file_size" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_path";
          let file_path = match List.assoc_opt "file_path" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { file_id = file_id; file_unique_id = file_unique_id; file_size = file_size; file_path = file_path; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and WebAppInfo : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    url : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("url", `String v.url);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "url";
          let url = (to_string (List.assoc "url" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { url = url; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and KeyboardButtonRequestUsers : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    request_id : int64;
    user_is_bot : bool option;
    user_is_premium : bool option;
    max_quantity : int64 option;
    request_name : bool option;
    request_username : bool option;
    request_photo : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("request_id", `Intlit (Int64.to_string v.request_id));
      (match v.user_is_bot with None -> ("user_is_bot", `Null) | Some x -> ("user_is_bot", `Bool x));
      (match v.user_is_premium with None -> ("user_is_premium", `Null) | Some x -> ("user_is_premium", `Bool x));
      (match v.max_quantity with None -> ("max_quantity", `Null) | Some x -> ("max_quantity", `Intlit (Int64.to_string x)));
      (match v.request_name with None -> ("request_name", `Null) | Some x -> ("request_name", `Bool x));
      (match v.request_username with None -> ("request_username", `Null) | Some x -> ("request_username", `Bool x));
      (match v.request_photo with None -> ("request_photo", `Null) | Some x -> ("request_photo", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "request_id";
          let request_id = (match (List.assoc "request_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "request_id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "user_is_bot";
          let user_is_bot = match List.assoc_opt "user_is_bot" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "user_is_premium";
          let user_is_premium = match List.assoc_opt "user_is_premium" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "max_quantity";
          let max_quantity = match List.assoc_opt "max_quantity" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "request_name";
          let request_name = match List.assoc_opt "request_name" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "request_username";
          let request_username = match List.assoc_opt "request_username" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "request_photo";
          let request_photo = match List.assoc_opt "request_photo" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { request_id = request_id; user_is_bot = user_is_bot; user_is_premium = user_is_premium; max_quantity = max_quantity; request_name = request_name; request_username = request_username; request_photo = request_photo; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and KeyboardButtonPollType : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      (match v.type_ with None -> ("type", `Null) | Some x -> ("type", `String x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = match List.assoc_opt "type" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ReplyKeyboardRemove : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    remove_keyboard : bool;
    selective : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("remove_keyboard", `Bool v.remove_keyboard);
      (match v.selective with None -> ("selective", `Null) | Some x -> ("selective", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "remove_keyboard";
          let remove_keyboard = (to_bool (List.assoc "remove_keyboard" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "selective";
          let selective = match List.assoc_opt "selective" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { remove_keyboard = remove_keyboard; selective = selective; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and LoginUrl : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    url : string;
    forward_text : string option;
    bot_username : string option;
    request_write_access : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("url", `String v.url);
      (match v.forward_text with None -> ("forward_text", `Null) | Some x -> ("forward_text", `String x));
      (match v.bot_username with None -> ("bot_username", `Null) | Some x -> ("bot_username", `String x));
      (match v.request_write_access with None -> ("request_write_access", `Null) | Some x -> ("request_write_access", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "url";
          let url = (to_string (List.assoc "url" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "forward_text";
          let forward_text = match List.assoc_opt "forward_text" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "bot_username";
          let bot_username = match List.assoc_opt "bot_username" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "request_write_access";
          let request_write_access = match List.assoc_opt "request_write_access" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { url = url; forward_text = forward_text; bot_username = bot_username; request_write_access = request_write_access; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and SwitchInlineQueryChosenChat : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    query : string option;
    allow_user_chats : bool option;
    allow_bot_chats : bool option;
    allow_group_chats : bool option;
    allow_channel_chats : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      (match v.query with None -> ("query", `Null) | Some x -> ("query", `String x));
      (match v.allow_user_chats with None -> ("allow_user_chats", `Null) | Some x -> ("allow_user_chats", `Bool x));
      (match v.allow_bot_chats with None -> ("allow_bot_chats", `Null) | Some x -> ("allow_bot_chats", `Bool x));
      (match v.allow_group_chats with None -> ("allow_group_chats", `Null) | Some x -> ("allow_group_chats", `Bool x));
      (match v.allow_channel_chats with None -> ("allow_channel_chats", `Null) | Some x -> ("allow_channel_chats", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "query";
          let query = match List.assoc_opt "query" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "allow_user_chats";
          let allow_user_chats = match List.assoc_opt "allow_user_chats" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "allow_bot_chats";
          let allow_bot_chats = match List.assoc_opt "allow_bot_chats" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "allow_group_chats";
          let allow_group_chats = match List.assoc_opt "allow_group_chats" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "allow_channel_chats";
          let allow_channel_chats = match List.assoc_opt "allow_channel_chats" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { query = query; allow_user_chats = allow_user_chats; allow_bot_chats = allow_bot_chats; allow_group_chats = allow_group_chats; allow_channel_chats = allow_channel_chats; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and CopyTextButton : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    text : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("text", `String v.text);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "text";
          let text = (to_string (List.assoc "text" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { text = text; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ForceReply : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    force_reply : bool;
    input_field_placeholder : string option;
    selective : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("force_reply", `Bool v.force_reply);
      (match v.input_field_placeholder with None -> ("input_field_placeholder", `Null) | Some x -> ("input_field_placeholder", `String x));
      (match v.selective with None -> ("selective", `Null) | Some x -> ("selective", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "force_reply";
          let force_reply = (to_bool (List.assoc "force_reply" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "input_field_placeholder";
          let input_field_placeholder = match List.assoc_opt "input_field_placeholder" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "selective";
          let selective = match List.assoc_opt "selective" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { force_reply = force_reply; input_field_placeholder = input_field_placeholder; selective = selective; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ChatPhoto : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    small_file_id : string;
    small_file_unique_id : string;
    big_file_id : string;
    big_file_unique_id : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("small_file_id", `String v.small_file_id);
      ("small_file_unique_id", `String v.small_file_unique_id);
      ("big_file_id", `String v.big_file_id);
      ("big_file_unique_id", `String v.big_file_unique_id);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "small_file_id";
          let small_file_id = (to_string (List.assoc "small_file_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "small_file_unique_id";
          let small_file_unique_id = (to_string (List.assoc "small_file_unique_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "big_file_id";
          let big_file_id = (to_string (List.assoc "big_file_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "big_file_unique_id";
          let big_file_unique_id = (to_string (List.assoc "big_file_unique_id" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { small_file_id = small_file_id; small_file_unique_id = small_file_unique_id; big_file_id = big_file_id; big_file_unique_id = big_file_unique_id; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ChatAdministratorRights : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    is_anonymous : bool;
    can_manage_chat : bool;
    can_delete_messages : bool;
    can_manage_video_chats : bool;
    can_restrict_members : bool;
    can_promote_members : bool;
    can_change_info : bool;
    can_invite_users : bool;
    can_post_stories : bool;
    can_edit_stories : bool;
    can_delete_stories : bool;
    can_post_messages : bool option;
    can_edit_messages : bool option;
    can_pin_messages : bool option;
    can_manage_topics : bool option;
    can_manage_direct_messages : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("is_anonymous", `Bool v.is_anonymous);
      ("can_manage_chat", `Bool v.can_manage_chat);
      ("can_delete_messages", `Bool v.can_delete_messages);
      ("can_manage_video_chats", `Bool v.can_manage_video_chats);
      ("can_restrict_members", `Bool v.can_restrict_members);
      ("can_promote_members", `Bool v.can_promote_members);
      ("can_change_info", `Bool v.can_change_info);
      ("can_invite_users", `Bool v.can_invite_users);
      ("can_post_stories", `Bool v.can_post_stories);
      ("can_edit_stories", `Bool v.can_edit_stories);
      ("can_delete_stories", `Bool v.can_delete_stories);
      (match v.can_post_messages with None -> ("can_post_messages", `Null) | Some x -> ("can_post_messages", `Bool x));
      (match v.can_edit_messages with None -> ("can_edit_messages", `Null) | Some x -> ("can_edit_messages", `Bool x));
      (match v.can_pin_messages with None -> ("can_pin_messages", `Null) | Some x -> ("can_pin_messages", `Bool x));
      (match v.can_manage_topics with None -> ("can_manage_topics", `Null) | Some x -> ("can_manage_topics", `Bool x));
      (match v.can_manage_direct_messages with None -> ("can_manage_direct_messages", `Null) | Some x -> ("can_manage_direct_messages", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_anonymous";
          let is_anonymous = (to_bool (List.assoc "is_anonymous" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_manage_chat";
          let can_manage_chat = (to_bool (List.assoc "can_manage_chat" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_delete_messages";
          let can_delete_messages = (to_bool (List.assoc "can_delete_messages" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_manage_video_chats";
          let can_manage_video_chats = (to_bool (List.assoc "can_manage_video_chats" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_restrict_members";
          let can_restrict_members = (to_bool (List.assoc "can_restrict_members" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_promote_members";
          let can_promote_members = (to_bool (List.assoc "can_promote_members" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_change_info";
          let can_change_info = (to_bool (List.assoc "can_change_info" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_invite_users";
          let can_invite_users = (to_bool (List.assoc "can_invite_users" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_post_stories";
          let can_post_stories = (to_bool (List.assoc "can_post_stories" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_edit_stories";
          let can_edit_stories = (to_bool (List.assoc "can_edit_stories" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_delete_stories";
          let can_delete_stories = (to_bool (List.assoc "can_delete_stories" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_post_messages";
          let can_post_messages = match List.assoc_opt "can_post_messages" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_edit_messages";
          let can_edit_messages = match List.assoc_opt "can_edit_messages" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_pin_messages";
          let can_pin_messages = match List.assoc_opt "can_pin_messages" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_manage_topics";
          let can_manage_topics = match List.assoc_opt "can_manage_topics" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_manage_direct_messages";
          let can_manage_direct_messages = match List.assoc_opt "can_manage_direct_messages" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { is_anonymous = is_anonymous; can_manage_chat = can_manage_chat; can_delete_messages = can_delete_messages; can_manage_video_chats = can_manage_video_chats; can_restrict_members = can_restrict_members; can_promote_members = can_promote_members; can_change_info = can_change_info; can_invite_users = can_invite_users; can_post_stories = can_post_stories; can_edit_stories = can_edit_stories; can_delete_stories = can_delete_stories; can_post_messages = can_post_messages; can_edit_messages = can_edit_messages; can_pin_messages = can_pin_messages; can_manage_topics = can_manage_topics; can_manage_direct_messages = can_manage_direct_messages; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ChatPermissions : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    can_send_messages : bool option;
    can_send_audios : bool option;
    can_send_documents : bool option;
    can_send_photos : bool option;
    can_send_videos : bool option;
    can_send_video_notes : bool option;
    can_send_voice_notes : bool option;
    can_send_polls : bool option;
    can_send_other_messages : bool option;
    can_add_web_page_previews : bool option;
    can_change_info : bool option;
    can_invite_users : bool option;
    can_pin_messages : bool option;
    can_manage_topics : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      (match v.can_send_messages with None -> ("can_send_messages", `Null) | Some x -> ("can_send_messages", `Bool x));
      (match v.can_send_audios with None -> ("can_send_audios", `Null) | Some x -> ("can_send_audios", `Bool x));
      (match v.can_send_documents with None -> ("can_send_documents", `Null) | Some x -> ("can_send_documents", `Bool x));
      (match v.can_send_photos with None -> ("can_send_photos", `Null) | Some x -> ("can_send_photos", `Bool x));
      (match v.can_send_videos with None -> ("can_send_videos", `Null) | Some x -> ("can_send_videos", `Bool x));
      (match v.can_send_video_notes with None -> ("can_send_video_notes", `Null) | Some x -> ("can_send_video_notes", `Bool x));
      (match v.can_send_voice_notes with None -> ("can_send_voice_notes", `Null) | Some x -> ("can_send_voice_notes", `Bool x));
      (match v.can_send_polls with None -> ("can_send_polls", `Null) | Some x -> ("can_send_polls", `Bool x));
      (match v.can_send_other_messages with None -> ("can_send_other_messages", `Null) | Some x -> ("can_send_other_messages", `Bool x));
      (match v.can_add_web_page_previews with None -> ("can_add_web_page_previews", `Null) | Some x -> ("can_add_web_page_previews", `Bool x));
      (match v.can_change_info with None -> ("can_change_info", `Null) | Some x -> ("can_change_info", `Bool x));
      (match v.can_invite_users with None -> ("can_invite_users", `Null) | Some x -> ("can_invite_users", `Bool x));
      (match v.can_pin_messages with None -> ("can_pin_messages", `Null) | Some x -> ("can_pin_messages", `Bool x));
      (match v.can_manage_topics with None -> ("can_manage_topics", `Null) | Some x -> ("can_manage_topics", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_send_messages";
          let can_send_messages = match List.assoc_opt "can_send_messages" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_send_audios";
          let can_send_audios = match List.assoc_opt "can_send_audios" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_send_documents";
          let can_send_documents = match List.assoc_opt "can_send_documents" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_send_photos";
          let can_send_photos = match List.assoc_opt "can_send_photos" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_send_videos";
          let can_send_videos = match List.assoc_opt "can_send_videos" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_send_video_notes";
          let can_send_video_notes = match List.assoc_opt "can_send_video_notes" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_send_voice_notes";
          let can_send_voice_notes = match List.assoc_opt "can_send_voice_notes" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_send_polls";
          let can_send_polls = match List.assoc_opt "can_send_polls" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_send_other_messages";
          let can_send_other_messages = match List.assoc_opt "can_send_other_messages" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_add_web_page_previews";
          let can_add_web_page_previews = match List.assoc_opt "can_add_web_page_previews" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_change_info";
          let can_change_info = match List.assoc_opt "can_change_info" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_invite_users";
          let can_invite_users = match List.assoc_opt "can_invite_users" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_pin_messages";
          let can_pin_messages = match List.assoc_opt "can_pin_messages" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_manage_topics";
          let can_manage_topics = match List.assoc_opt "can_manage_topics" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { can_send_messages = can_send_messages; can_send_audios = can_send_audios; can_send_documents = can_send_documents; can_send_photos = can_send_photos; can_send_videos = can_send_videos; can_send_video_notes = can_send_video_notes; can_send_voice_notes = can_send_voice_notes; can_send_polls = can_send_polls; can_send_other_messages = can_send_other_messages; can_add_web_page_previews = can_add_web_page_previews; can_change_info = can_change_info; can_invite_users = can_invite_users; can_pin_messages = can_pin_messages; can_manage_topics = can_manage_topics; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and Birthdate : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    day : int64;
    month : int64;
    year : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("day", `Intlit (Int64.to_string v.day));
      ("month", `Intlit (Int64.to_string v.month));
      (match v.year with None -> ("year", `Null) | Some x -> ("year", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "day";
          let day = (match (List.assoc "day" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "day" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "month";
          let month = (match (List.assoc "month" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "month" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "year";
          let year = match List.assoc_opt "year" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { day = day; month = month; year = year; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and BusinessOpeningHoursInterval : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    opening_minute : int64;
    closing_minute : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("opening_minute", `Intlit (Int64.to_string v.opening_minute));
      ("closing_minute", `Intlit (Int64.to_string v.closing_minute));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "opening_minute";
          let opening_minute = (match (List.assoc "opening_minute" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "opening_minute" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "closing_minute";
          let closing_minute = (match (List.assoc "closing_minute" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "closing_minute" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { opening_minute = opening_minute; closing_minute = closing_minute; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and StoryAreaPosition : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    x_percentage : float;
    y_percentage : float;
    width_percentage : float;
    height_percentage : float;
    rotation_angle : float;
    corner_radius_percentage : float;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("x_percentage", `Float v.x_percentage);
      ("y_percentage", `Float v.y_percentage);
      ("width_percentage", `Float v.width_percentage);
      ("height_percentage", `Float v.height_percentage);
      ("rotation_angle", `Float v.rotation_angle);
      ("corner_radius_percentage", `Float v.corner_radius_percentage);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "x_percentage";
          let x_percentage = (to_float (List.assoc "x_percentage" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "y_percentage";
          let y_percentage = (to_float (List.assoc "y_percentage" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "width_percentage";
          let width_percentage = (to_float (List.assoc "width_percentage" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "height_percentage";
          let height_percentage = (to_float (List.assoc "height_percentage" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "rotation_angle";
          let rotation_angle = (to_float (List.assoc "rotation_angle" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "corner_radius_percentage";
          let corner_radius_percentage = (to_float (List.assoc "corner_radius_percentage" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { x_percentage = x_percentage; y_percentage = y_percentage; width_percentage = width_percentage; height_percentage = height_percentage; rotation_angle = rotation_angle; corner_radius_percentage = corner_radius_percentage; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and LocationAddress : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    country_code : string;
    state : string option;
    city : string option;
    street : string option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("country_code", `String v.country_code);
      (match v.state with None -> ("state", `Null) | Some x -> ("state", `String x));
      (match v.city with None -> ("city", `Null) | Some x -> ("city", `String x));
      (match v.street with None -> ("street", `Null) | Some x -> ("street", `String x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "country_code";
          let country_code = (to_string (List.assoc "country_code" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "state";
          let state = match List.assoc_opt "state" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "city";
          let city = match List.assoc_opt "city" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "street";
          let street = match List.assoc_opt "street" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { country_code = country_code; state = state; city = city; street = street; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and StoryAreaTypeLink : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    url : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("url", `String v.url);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "url";
          let url = (to_string (List.assoc "url" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; url = url; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and StoryAreaTypeWeather : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    temperature : float;
    emoji : string;
    background_color : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("temperature", `Float v.temperature);
      ("emoji", `String v.emoji);
      ("background_color", `Intlit (Int64.to_string v.background_color));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "temperature";
          let temperature = (to_float (List.assoc "temperature" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "emoji";
          let emoji = (to_string (List.assoc "emoji" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "background_color";
          let background_color = (match (List.assoc "background_color" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "background_color" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; temperature = temperature; emoji = emoji; background_color = background_color; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and StoryAreaTypeUniqueGift : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    name : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("name", `String v.name);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "name";
          let name = (to_string (List.assoc "name" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; name = name; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ReactionType : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    emoji : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("emoji", `String v.emoji);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "emoji";
          let emoji = (to_string (List.assoc "emoji" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; emoji = emoji; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ReactionTypeEmoji : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    emoji : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("emoji", `String v.emoji);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "emoji";
          let emoji = (to_string (List.assoc "emoji" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; emoji = emoji; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ReactionTypeCustomEmoji : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    custom_emoji_id : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("custom_emoji_id", `String v.custom_emoji_id);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "custom_emoji_id";
          let custom_emoji_id = (to_string (List.assoc "custom_emoji_id" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; custom_emoji_id = custom_emoji_id; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ReactionTypePaid : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ForumTopic : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    message_thread_id : int64;
    name : string;
    icon_color : int64;
    icon_custom_emoji_id : string option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("message_thread_id", `Intlit (Int64.to_string v.message_thread_id));
      ("name", `String v.name);
      ("icon_color", `Intlit (Int64.to_string v.icon_color));
      (match v.icon_custom_emoji_id with None -> ("icon_custom_emoji_id", `Null) | Some x -> ("icon_custom_emoji_id", `String x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "message_thread_id";
          let message_thread_id = (match (List.assoc "message_thread_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "message_thread_id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "name";
          let name = (to_string (List.assoc "name" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "icon_color";
          let icon_color = (match (List.assoc "icon_color" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "icon_color" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "icon_custom_emoji_id";
          let icon_custom_emoji_id = match List.assoc_opt "icon_custom_emoji_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { message_thread_id = message_thread_id; name = name; icon_color = icon_color; icon_custom_emoji_id = icon_custom_emoji_id; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and UniqueGiftBackdropColors : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    center_color : int64;
    edge_color : int64;
    symbol_color : int64;
    text_color : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("center_color", `Intlit (Int64.to_string v.center_color));
      ("edge_color", `Intlit (Int64.to_string v.edge_color));
      ("symbol_color", `Intlit (Int64.to_string v.symbol_color));
      ("text_color", `Intlit (Int64.to_string v.text_color));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "center_color";
          let center_color = (match (List.assoc "center_color" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "center_color" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "edge_color";
          let edge_color = (match (List.assoc "edge_color" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "edge_color" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "symbol_color";
          let symbol_color = (match (List.assoc "symbol_color" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "symbol_color" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "text_color";
          let text_color = (match (List.assoc "text_color" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "text_color" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { center_color = center_color; edge_color = edge_color; symbol_color = symbol_color; text_color = text_color; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and AcceptedGiftTypes : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    unlimited_gifts : bool;
    limited_gifts : bool;
    unique_gifts : bool;
    premium_subscription : bool;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("unlimited_gifts", `Bool v.unlimited_gifts);
      ("limited_gifts", `Bool v.limited_gifts);
      ("unique_gifts", `Bool v.unique_gifts);
      ("premium_subscription", `Bool v.premium_subscription);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "unlimited_gifts";
          let unlimited_gifts = (to_bool (List.assoc "unlimited_gifts" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "limited_gifts";
          let limited_gifts = (to_bool (List.assoc "limited_gifts" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "unique_gifts";
          let unique_gifts = (to_bool (List.assoc "unique_gifts" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "premium_subscription";
          let premium_subscription = (to_bool (List.assoc "premium_subscription" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { unlimited_gifts = unlimited_gifts; limited_gifts = limited_gifts; unique_gifts = unique_gifts; premium_subscription = premium_subscription; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and StarAmount : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    amount : int64;
    nanostar_amount : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("amount", `Intlit (Int64.to_string v.amount));
      (match v.nanostar_amount with None -> ("nanostar_amount", `Null) | Some x -> ("nanostar_amount", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "amount";
          let amount = (match (List.assoc "amount" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "amount" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "nanostar_amount";
          let nanostar_amount = match List.assoc_opt "nanostar_amount" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { amount = amount; nanostar_amount = nanostar_amount; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and BotCommand : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    command : string;
    description : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("command", `String v.command);
      ("description", `String v.description);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "command";
          let command = (to_string (List.assoc "command" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "description";
          let description = (to_string (List.assoc "description" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { command = command; description = description; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and BotCommandScope : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and DeterminingListOfCommands : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and BotCommandScopeDefault : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and BotCommandScopeAllPrivateChats : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and BotCommandScopeAllGroupChats : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and BotCommandScopeAllChatAdministrators : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and BotCommandScopeChat : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    chat_id : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("chat_id", `String v.chat_id);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_id";
          let chat_id = (to_string (List.assoc "chat_id" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; chat_id = chat_id; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and BotCommandScopeChatAdministrators : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    chat_id : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("chat_id", `String v.chat_id);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_id";
          let chat_id = (to_string (List.assoc "chat_id" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; chat_id = chat_id; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and BotCommandScopeChatMember : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    chat_id : string;
    user_id : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("chat_id", `String v.chat_id);
      ("user_id", `Intlit (Int64.to_string v.user_id));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_id";
          let chat_id = (to_string (List.assoc "chat_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "user_id";
          let user_id = (match (List.assoc "user_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "user_id" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; chat_id = chat_id; user_id = user_id; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and BotName : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    name : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("name", `String v.name);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "name";
          let name = (to_string (List.assoc "name" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { name = name; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and BotDescription : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    description : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("description", `String v.description);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "description";
          let description = (to_string (List.assoc "description" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { description = description; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and BotShortDescription : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    short_description : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("short_description", `String v.short_description);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "short_description";
          let short_description = (to_string (List.assoc "short_description" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { short_description = short_description; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and MenuButton : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and MenuButtonCommands : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and MenuButtonDefault : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and BusinessBotRights : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    can_reply : bool option;
    can_read_messages : bool option;
    can_delete_sent_messages : bool option;
    can_delete_all_messages : bool option;
    can_edit_name : bool option;
    can_edit_bio : bool option;
    can_edit_profile_photo : bool option;
    can_edit_username : bool option;
    can_change_gift_settings : bool option;
    can_view_gifts_and_stars : bool option;
    can_convert_gifts_to_stars : bool option;
    can_transfer_and_upgrade_gifts : bool option;
    can_transfer_stars : bool option;
    can_manage_stories : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      (match v.can_reply with None -> ("can_reply", `Null) | Some x -> ("can_reply", `Bool x));
      (match v.can_read_messages with None -> ("can_read_messages", `Null) | Some x -> ("can_read_messages", `Bool x));
      (match v.can_delete_sent_messages with None -> ("can_delete_sent_messages", `Null) | Some x -> ("can_delete_sent_messages", `Bool x));
      (match v.can_delete_all_messages with None -> ("can_delete_all_messages", `Null) | Some x -> ("can_delete_all_messages", `Bool x));
      (match v.can_edit_name with None -> ("can_edit_name", `Null) | Some x -> ("can_edit_name", `Bool x));
      (match v.can_edit_bio with None -> ("can_edit_bio", `Null) | Some x -> ("can_edit_bio", `Bool x));
      (match v.can_edit_profile_photo with None -> ("can_edit_profile_photo", `Null) | Some x -> ("can_edit_profile_photo", `Bool x));
      (match v.can_edit_username with None -> ("can_edit_username", `Null) | Some x -> ("can_edit_username", `Bool x));
      (match v.can_change_gift_settings with None -> ("can_change_gift_settings", `Null) | Some x -> ("can_change_gift_settings", `Bool x));
      (match v.can_view_gifts_and_stars with None -> ("can_view_gifts_and_stars", `Null) | Some x -> ("can_view_gifts_and_stars", `Bool x));
      (match v.can_convert_gifts_to_stars with None -> ("can_convert_gifts_to_stars", `Null) | Some x -> ("can_convert_gifts_to_stars", `Bool x));
      (match v.can_transfer_and_upgrade_gifts with None -> ("can_transfer_and_upgrade_gifts", `Null) | Some x -> ("can_transfer_and_upgrade_gifts", `Bool x));
      (match v.can_transfer_stars with None -> ("can_transfer_stars", `Null) | Some x -> ("can_transfer_stars", `Bool x));
      (match v.can_manage_stories with None -> ("can_manage_stories", `Null) | Some x -> ("can_manage_stories", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_reply";
          let can_reply = match List.assoc_opt "can_reply" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_read_messages";
          let can_read_messages = match List.assoc_opt "can_read_messages" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_delete_sent_messages";
          let can_delete_sent_messages = match List.assoc_opt "can_delete_sent_messages" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_delete_all_messages";
          let can_delete_all_messages = match List.assoc_opt "can_delete_all_messages" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_edit_name";
          let can_edit_name = match List.assoc_opt "can_edit_name" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_edit_bio";
          let can_edit_bio = match List.assoc_opt "can_edit_bio" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_edit_profile_photo";
          let can_edit_profile_photo = match List.assoc_opt "can_edit_profile_photo" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_edit_username";
          let can_edit_username = match List.assoc_opt "can_edit_username" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_change_gift_settings";
          let can_change_gift_settings = match List.assoc_opt "can_change_gift_settings" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_view_gifts_and_stars";
          let can_view_gifts_and_stars = match List.assoc_opt "can_view_gifts_and_stars" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_convert_gifts_to_stars";
          let can_convert_gifts_to_stars = match List.assoc_opt "can_convert_gifts_to_stars" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_transfer_and_upgrade_gifts";
          let can_transfer_and_upgrade_gifts = match List.assoc_opt "can_transfer_and_upgrade_gifts" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_transfer_stars";
          let can_transfer_stars = match List.assoc_opt "can_transfer_stars" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_manage_stories";
          let can_manage_stories = match List.assoc_opt "can_manage_stories" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { can_reply = can_reply; can_read_messages = can_read_messages; can_delete_sent_messages = can_delete_sent_messages; can_delete_all_messages = can_delete_all_messages; can_edit_name = can_edit_name; can_edit_bio = can_edit_bio; can_edit_profile_photo = can_edit_profile_photo; can_edit_username = can_edit_username; can_change_gift_settings = can_change_gift_settings; can_view_gifts_and_stars = can_view_gifts_and_stars; can_convert_gifts_to_stars = can_convert_gifts_to_stars; can_transfer_and_upgrade_gifts = can_transfer_and_upgrade_gifts; can_transfer_stars = can_transfer_stars; can_manage_stories = can_manage_stories; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ResponseParameters : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    migrate_to_chat_id : int64 option;
    retry_after : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      (match v.migrate_to_chat_id with None -> ("migrate_to_chat_id", `Null) | Some x -> ("migrate_to_chat_id", `Intlit (Int64.to_string x)));
      (match v.retry_after with None -> ("retry_after", `Null) | Some x -> ("retry_after", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "migrate_to_chat_id";
          let migrate_to_chat_id = match List.assoc_opt "migrate_to_chat_id" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "retry_after";
          let retry_after = match List.assoc_opt "retry_after" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { migrate_to_chat_id = migrate_to_chat_id; retry_after = retry_after; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InputFile : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    media : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("media", `String v.media);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "media";
          let media = (to_string (List.assoc "media" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; media = media; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InputPaidMedia : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    media : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("media", `String v.media);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "media";
          let media = (to_string (List.assoc "media" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; media = media; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InputPaidMediaPhoto : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    media : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("media", `String v.media);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "media";
          let media = (to_string (List.assoc "media" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; media = media; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InputPaidMediaVideo : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    media : string;
    thumbnail : string option;
    cover : string option;
    start_timestamp : int64 option;
    width : int64 option;
    height : int64 option;
    duration : int64 option;
    supports_streaming : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("media", `String v.media);
      (match v.thumbnail with None -> ("thumbnail", `Null) | Some x -> ("thumbnail", `String x));
      (match v.cover with None -> ("cover", `Null) | Some x -> ("cover", `String x));
      (match v.start_timestamp with None -> ("start_timestamp", `Null) | Some x -> ("start_timestamp", `Intlit (Int64.to_string x)));
      (match v.width with None -> ("width", `Null) | Some x -> ("width", `Intlit (Int64.to_string x)));
      (match v.height with None -> ("height", `Null) | Some x -> ("height", `Intlit (Int64.to_string x)));
      (match v.duration with None -> ("duration", `Null) | Some x -> ("duration", `Intlit (Int64.to_string x)));
      (match v.supports_streaming with None -> ("supports_streaming", `Null) | Some x -> ("supports_streaming", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "media";
          let media = (to_string (List.assoc "media" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail";
          let thumbnail = match List.assoc_opt "thumbnail" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "cover";
          let cover = match List.assoc_opt "cover" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "start_timestamp";
          let start_timestamp = match List.assoc_opt "start_timestamp" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "width";
          let width = match List.assoc_opt "width" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "height";
          let height = match List.assoc_opt "height" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "duration";
          let duration = match List.assoc_opt "duration" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "supports_streaming";
          let supports_streaming = match List.assoc_opt "supports_streaming" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; media = media; thumbnail = thumbnail; cover = cover; start_timestamp = start_timestamp; width = width; height = height; duration = duration; supports_streaming = supports_streaming; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InputProfilePhoto : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    photo : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("photo", `String v.photo);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "photo";
          let photo = (to_string (List.assoc "photo" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; photo = photo; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InputProfilePhotoStatic : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    photo : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("photo", `String v.photo);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "photo";
          let photo = (to_string (List.assoc "photo" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; photo = photo; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InputProfilePhotoAnimated : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    animation : string;
    main_frame_timestamp : float option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("animation", `String v.animation);
      (match v.main_frame_timestamp with None -> ("main_frame_timestamp", `Null) | Some x -> ("main_frame_timestamp", `Float x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "animation";
          let animation = (to_string (List.assoc "animation" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "main_frame_timestamp";
          let main_frame_timestamp = match List.assoc_opt "main_frame_timestamp" fields with None | Some `Null -> None | Some x -> Some ((to_float x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; animation = animation; main_frame_timestamp = main_frame_timestamp; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InputStoryContent : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    photo : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("photo", `String v.photo);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "photo";
          let photo = (to_string (List.assoc "photo" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; photo = photo; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InputStoryContentPhoto : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    photo : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("photo", `String v.photo);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "photo";
          let photo = (to_string (List.assoc "photo" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; photo = photo; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InputStoryContentVideo : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    video : string;
    duration : float option;
    cover_frame_timestamp : float option;
    is_animation : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("video", `String v.video);
      (match v.duration with None -> ("duration", `Null) | Some x -> ("duration", `Float x));
      (match v.cover_frame_timestamp with None -> ("cover_frame_timestamp", `Null) | Some x -> ("cover_frame_timestamp", `Float x));
      (match v.is_animation with None -> ("is_animation", `Null) | Some x -> ("is_animation", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "video";
          let video = (to_string (List.assoc "video" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "duration";
          let duration = match List.assoc_opt "duration" fields with None | Some `Null -> None | Some x -> Some ((to_float x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "cover_frame_timestamp";
          let cover_frame_timestamp = match List.assoc_opt "cover_frame_timestamp" fields with None | Some `Null -> None | Some x -> Some ((to_float x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_animation";
          let is_animation = match List.assoc_opt "is_animation" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; video = video; duration = duration; cover_frame_timestamp = cover_frame_timestamp; is_animation = is_animation; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and SendingFiles : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and AccentColors : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and ProfileAccentColors : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and InlineModeObjects : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and GetMe : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and LogOut : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and Close : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SendMessage : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and FormattingOptions : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and PaidBroadcasts : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and ForwardMessage : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and ForwardMessages : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and CopyMessage : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and CopyMessages : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SendPhoto : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SendAudio : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SendDocument : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SendVideo : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SendAnimation : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SendVoice : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SendVideoNote : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SendPaidMedia : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SendMediaGroup : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SendLocation : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SendVenue : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SendContact : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SendPoll : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SendChecklist : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SendDice : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SendChatAction : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SetMessageReaction : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and GetUserProfilePhotos : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SetUserEmojiStatus : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and GetFile : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and BanChatMember : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and UnbanChatMember : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and RestrictChatMember : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and PromoteChatMember : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SetChatAdministratorCustomTitle : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and BanChatSenderChat : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and UnbanChatSenderChat : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SetChatPermissions : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and ExportChatInviteLink : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and CreateChatInviteLink : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and EditChatInviteLink : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and CreateChatSubscriptionInviteLink : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and EditChatSubscriptionInviteLink : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and RevokeChatInviteLink : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and ApproveChatJoinRequest : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and DeclineChatJoinRequest : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SetChatPhoto : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and DeleteChatPhoto : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SetChatTitle : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SetChatDescription : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and PinChatMessage : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and UnpinChatMessage : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and UnpinAllChatMessages : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and LeaveChat : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and GetChat : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and GetChatAdministrators : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and GetChatMemberCount : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and GetChatMember : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SetChatStickerSet : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and DeleteChatStickerSet : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and GetForumTopicIconStickers : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and CreateForumTopic : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and EditForumTopic : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and CloseForumTopic : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and ReopenForumTopic : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and DeleteForumTopic : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and UnpinAllForumTopicMessages : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and EditGeneralForumTopic : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and CloseGeneralForumTopic : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and ReopenGeneralForumTopic : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and HideGeneralForumTopic : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and UnhideGeneralForumTopic : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and UnpinAllGeneralForumTopicMessages : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and AnswerCallbackQuery : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and GetUserChatBoosts : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and GetBusinessConnection : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SetMyCommands : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and DeleteMyCommands : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and GetMyCommands : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SetMyName : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and GetMyName : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SetMyDescription : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and GetMyDescription : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SetMyShortDescription : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and GetMyShortDescription : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SetChatMenuButton : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and GetChatMenuButton : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SetMyDefaultAdministratorRights : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and GetMyDefaultAdministratorRights : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and GetAvailableGifts : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SendGift : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and GiftPremiumSubscription : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and VerifyUser : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and VerifyChat : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and RemoveUserVerification : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and RemoveChatVerification : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and ReadBusinessMessage : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and DeleteBusinessMessages : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SetBusinessAccountName : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SetBusinessAccountUsername : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SetBusinessAccountBio : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SetBusinessAccountProfilePhoto : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and RemoveBusinessAccountProfilePhoto : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SetBusinessAccountGiftSettings : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and GetBusinessAccountStarBalance : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and TransferBusinessAccountStars : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and GetBusinessAccountGifts : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and ConvertGiftToStars : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and UpgradeGift : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and TransferGift : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and PostStory : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and EditStory : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and DeleteStory : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and InlineModeMethods : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and EditMessageText : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and EditMessageCaption : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and EditMessageMedia : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and EditMessageLiveLocation : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and StopMessageLiveLocation : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and EditMessageChecklist : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and EditMessageReplyMarkup : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and StopPoll : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and ApproveSuggestedPost : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and DeclineSuggestedPost : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and DeleteMessage : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and DeleteMessages : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and MaskPosition : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    point : string;
    x_shift : float;
    y_shift : float;
    scale : float;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("point", `String v.point);
      ("x_shift", `Float v.x_shift);
      ("y_shift", `Float v.y_shift);
      ("scale", `Float v.scale);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "point";
          let point = (to_string (List.assoc "point" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "x_shift";
          let x_shift = (to_float (List.assoc "x_shift" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "y_shift";
          let y_shift = (to_float (List.assoc "y_shift" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "scale";
          let scale = (to_float (List.assoc "scale" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { point = point; x_shift = x_shift; y_shift = y_shift; scale = scale; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and SendSticker : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and GetStickerSet : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and GetCustomEmojiStickers : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and UploadStickerFile : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and CreateNewStickerSet : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and AddStickerToSet : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SetStickerPositionInSet : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and DeleteStickerFromSet : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and ReplaceStickerInSet : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SetStickerEmojiList : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SetStickerKeywords : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SetStickerMaskPosition : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SetStickerSetTitle : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SetStickerSetThumbnail : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SetCustomEmojiStickerSetThumbnail : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and DeleteStickerSet : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and AnswerInlineQuery : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and InputLocationMessageContent : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    latitude : float;
    longitude : float;
    horizontal_accuracy : float option;
    live_period : int64 option;
    heading : int64 option;
    proximity_alert_radius : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("latitude", `Float v.latitude);
      ("longitude", `Float v.longitude);
      (match v.horizontal_accuracy with None -> ("horizontal_accuracy", `Null) | Some x -> ("horizontal_accuracy", `Float x));
      (match v.live_period with None -> ("live_period", `Null) | Some x -> ("live_period", `Intlit (Int64.to_string x)));
      (match v.heading with None -> ("heading", `Null) | Some x -> ("heading", `Intlit (Int64.to_string x)));
      (match v.proximity_alert_radius with None -> ("proximity_alert_radius", `Null) | Some x -> ("proximity_alert_radius", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "latitude";
          let latitude = (to_float (List.assoc "latitude" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "longitude";
          let longitude = (to_float (List.assoc "longitude" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "horizontal_accuracy";
          let horizontal_accuracy = match List.assoc_opt "horizontal_accuracy" fields with None | Some `Null -> None | Some x -> Some ((to_float x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "live_period";
          let live_period = match List.assoc_opt "live_period" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "heading";
          let heading = match List.assoc_opt "heading" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "proximity_alert_radius";
          let proximity_alert_radius = match List.assoc_opt "proximity_alert_radius" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { latitude = latitude; longitude = longitude; horizontal_accuracy = horizontal_accuracy; live_period = live_period; heading = heading; proximity_alert_radius = proximity_alert_radius; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InputVenueMessageContent : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    latitude : float;
    longitude : float;
    title : string;
    address : string;
    foursquare_id : string option;
    foursquare_type : string option;
    google_place_id : string option;
    google_place_type : string option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("latitude", `Float v.latitude);
      ("longitude", `Float v.longitude);
      ("title", `String v.title);
      ("address", `String v.address);
      (match v.foursquare_id with None -> ("foursquare_id", `Null) | Some x -> ("foursquare_id", `String x));
      (match v.foursquare_type with None -> ("foursquare_type", `Null) | Some x -> ("foursquare_type", `String x));
      (match v.google_place_id with None -> ("google_place_id", `Null) | Some x -> ("google_place_id", `String x));
      (match v.google_place_type with None -> ("google_place_type", `Null) | Some x -> ("google_place_type", `String x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "latitude";
          let latitude = (to_float (List.assoc "latitude" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "longitude";
          let longitude = (to_float (List.assoc "longitude" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = (to_string (List.assoc "title" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "address";
          let address = (to_string (List.assoc "address" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "foursquare_id";
          let foursquare_id = match List.assoc_opt "foursquare_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "foursquare_type";
          let foursquare_type = match List.assoc_opt "foursquare_type" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "google_place_id";
          let google_place_id = match List.assoc_opt "google_place_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "google_place_type";
          let google_place_type = match List.assoc_opt "google_place_type" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { latitude = latitude; longitude = longitude; title = title; address = address; foursquare_id = foursquare_id; foursquare_type = foursquare_type; google_place_id = google_place_id; google_place_type = google_place_type; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InputContactMessageContent : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    phone_number : string;
    first_name : string;
    last_name : string option;
    vcard : string option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("phone_number", `String v.phone_number);
      ("first_name", `String v.first_name);
      (match v.last_name with None -> ("last_name", `Null) | Some x -> ("last_name", `String x));
      (match v.vcard with None -> ("vcard", `Null) | Some x -> ("vcard", `String x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "phone_number";
          let phone_number = (to_string (List.assoc "phone_number" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "first_name";
          let first_name = (to_string (List.assoc "first_name" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "last_name";
          let last_name = match List.assoc_opt "last_name" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "vcard";
          let vcard = match List.assoc_opt "vcard" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { phone_number = phone_number; first_name = first_name; last_name = last_name; vcard = vcard; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and AnswerWebAppQuery : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SentWebAppMessage : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    inline_message_id : string option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      (match v.inline_message_id with None -> ("inline_message_id", `Null) | Some x -> ("inline_message_id", `String x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "inline_message_id";
          let inline_message_id = match List.assoc_opt "inline_message_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { inline_message_id = inline_message_id; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and SavePreparedInlineMessage : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and PreparedInlineMessage : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    id : string;
    expiration_date : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("id", `String v.id);
      ("expiration_date", `Intlit (Int64.to_string v.expiration_date));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "expiration_date";
          let expiration_date = (match (List.assoc "expiration_date" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "expiration_date" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { id = id; expiration_date = expiration_date; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and SendInvoice : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and CreateInvoiceLink : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and AnswerShippingQuery : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and AnswerPreCheckoutQuery : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and GetMyStarBalance : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and GetStarTransactions : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and RefundStarPayment : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and EditUserStarSubscription : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and LabeledPrice : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    label : string;
    amount : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("label", `String v.label);
      ("amount", `Intlit (Int64.to_string v.amount));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "label";
          let label = (to_string (List.assoc "label" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "amount";
          let amount = (match (List.assoc "amount" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "amount" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { label = label; amount = amount; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and Invoice : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    title : string;
    description : string;
    start_parameter : string;
    currency : string;
    total_amount : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("title", `String v.title);
      ("description", `String v.description);
      ("start_parameter", `String v.start_parameter);
      ("currency", `String v.currency);
      ("total_amount", `Intlit (Int64.to_string v.total_amount));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = (to_string (List.assoc "title" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "description";
          let description = (to_string (List.assoc "description" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "start_parameter";
          let start_parameter = (to_string (List.assoc "start_parameter" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "currency";
          let currency = (to_string (List.assoc "currency" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "total_amount";
          let total_amount = (match (List.assoc "total_amount" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "total_amount" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { title = title; description = description; start_parameter = start_parameter; currency = currency; total_amount = total_amount; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ShippingAddress : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    country_code : string;
    state : string;
    city : string;
    street_line1 : string;
    street_line2 : string;
    post_code : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("country_code", `String v.country_code);
      ("state", `String v.state);
      ("city", `String v.city);
      ("street_line1", `String v.street_line1);
      ("street_line2", `String v.street_line2);
      ("post_code", `String v.post_code);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "country_code";
          let country_code = (to_string (List.assoc "country_code" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "state";
          let state = (to_string (List.assoc "state" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "city";
          let city = (to_string (List.assoc "city" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "street_line1";
          let street_line1 = (to_string (List.assoc "street_line1" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "street_line2";
          let street_line2 = (to_string (List.assoc "street_line2" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "post_code";
          let post_code = (to_string (List.assoc "post_code" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { country_code = country_code; state = state; city = city; street_line1 = street_line1; street_line2 = street_line2; post_code = post_code; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and RefundedPayment : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    currency : string;
    total_amount : int64;
    invoice_payload : string;
    telegram_payment_charge_id : string;
    provider_payment_charge_id : string option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("currency", `String v.currency);
      ("total_amount", `Intlit (Int64.to_string v.total_amount));
      ("invoice_payload", `String v.invoice_payload);
      ("telegram_payment_charge_id", `String v.telegram_payment_charge_id);
      (match v.provider_payment_charge_id with None -> ("provider_payment_charge_id", `Null) | Some x -> ("provider_payment_charge_id", `String x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "currency";
          let currency = (to_string (List.assoc "currency" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "total_amount";
          let total_amount = (match (List.assoc "total_amount" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "total_amount" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "invoice_payload";
          let invoice_payload = (to_string (List.assoc "invoice_payload" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "telegram_payment_charge_id";
          let telegram_payment_charge_id = (to_string (List.assoc "telegram_payment_charge_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "provider_payment_charge_id";
          let provider_payment_charge_id = match List.assoc_opt "provider_payment_charge_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { currency = currency; total_amount = total_amount; invoice_payload = invoice_payload; telegram_payment_charge_id = telegram_payment_charge_id; provider_payment_charge_id = provider_payment_charge_id; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and RevenueWithdrawalState : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and RevenueWithdrawalStatePending : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and RevenueWithdrawalStateSucceeded : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    date : int64;
    url : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("date", `Intlit (Int64.to_string v.date));
      ("url", `String v.url);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "date";
          let date = (match (List.assoc "date" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "date" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "url";
          let url = (to_string (List.assoc "url" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; date = date; url = url; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and RevenueWithdrawalStateFailed : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and TransactionPartnerTelegramAds : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and TransactionPartnerTelegramApi : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    request_count : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("request_count", `Intlit (Int64.to_string v.request_count));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "request_count";
          let request_count = (match (List.assoc "request_count" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "request_count" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; request_count = request_count; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and TransactionPartnerOther : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and PassportFile : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    file_id : string;
    file_unique_id : string;
    file_size : int64;
    file_date : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("file_id", `String v.file_id);
      ("file_unique_id", `String v.file_unique_id);
      ("file_size", `Intlit (Int64.to_string v.file_size));
      ("file_date", `Intlit (Int64.to_string v.file_date));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_id";
          let file_id = (to_string (List.assoc "file_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_unique_id";
          let file_unique_id = (to_string (List.assoc "file_unique_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_size";
          let file_size = (match (List.assoc "file_size" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "file_size" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_date";
          let file_date = (match (List.assoc "file_date" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "file_date" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { file_id = file_id; file_unique_id = file_unique_id; file_size = file_size; file_date = file_date; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and EncryptedCredentials : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    data : string;
    hash : string;
    secret : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("data", `String v.data);
      ("hash", `String v.hash);
      ("secret", `String v.secret);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "data";
          let data = (to_string (List.assoc "data" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "hash";
          let hash = (to_string (List.assoc "hash" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "secret";
          let secret = (to_string (List.assoc "secret" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { data = data; hash = hash; secret = secret; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and SetPassportDataErrors : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and PassportElementError : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    source : string;
    type_ : string;
    field_name : string;
    data_hash : string;
    message : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("source", `String v.source);
      ("type", `String v.type_);
      ("field_name", `String v.field_name);
      ("data_hash", `String v.data_hash);
      ("message", `String v.message);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "source";
          let source = (to_string (List.assoc "source" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "field_name";
          let field_name = (to_string (List.assoc "field_name" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "data_hash";
          let data_hash = (to_string (List.assoc "data_hash" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message";
          let message = (to_string (List.assoc "message" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { source = source; type_ = type_; field_name = field_name; data_hash = data_hash; message = message; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and PassportElementErrorDataField : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    source : string;
    type_ : string;
    field_name : string;
    data_hash : string;
    message : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("source", `String v.source);
      ("type", `String v.type_);
      ("field_name", `String v.field_name);
      ("data_hash", `String v.data_hash);
      ("message", `String v.message);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "source";
          let source = (to_string (List.assoc "source" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "field_name";
          let field_name = (to_string (List.assoc "field_name" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "data_hash";
          let data_hash = (to_string (List.assoc "data_hash" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message";
          let message = (to_string (List.assoc "message" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { source = source; type_ = type_; field_name = field_name; data_hash = data_hash; message = message; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and PassportElementErrorFrontSide : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    source : string;
    type_ : string;
    file_hash : string;
    message : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("source", `String v.source);
      ("type", `String v.type_);
      ("file_hash", `String v.file_hash);
      ("message", `String v.message);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "source";
          let source = (to_string (List.assoc "source" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_hash";
          let file_hash = (to_string (List.assoc "file_hash" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message";
          let message = (to_string (List.assoc "message" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { source = source; type_ = type_; file_hash = file_hash; message = message; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and PassportElementErrorReverseSide : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    source : string;
    type_ : string;
    file_hash : string;
    message : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("source", `String v.source);
      ("type", `String v.type_);
      ("file_hash", `String v.file_hash);
      ("message", `String v.message);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "source";
          let source = (to_string (List.assoc "source" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_hash";
          let file_hash = (to_string (List.assoc "file_hash" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message";
          let message = (to_string (List.assoc "message" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { source = source; type_ = type_; file_hash = file_hash; message = message; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and PassportElementErrorSelfie : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    source : string;
    type_ : string;
    file_hash : string;
    message : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("source", `String v.source);
      ("type", `String v.type_);
      ("file_hash", `String v.file_hash);
      ("message", `String v.message);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "source";
          let source = (to_string (List.assoc "source" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_hash";
          let file_hash = (to_string (List.assoc "file_hash" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message";
          let message = (to_string (List.assoc "message" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { source = source; type_ = type_; file_hash = file_hash; message = message; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and PassportElementErrorFile : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    source : string;
    type_ : string;
    file_hash : string;
    message : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("source", `String v.source);
      ("type", `String v.type_);
      ("file_hash", `String v.file_hash);
      ("message", `String v.message);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "source";
          let source = (to_string (List.assoc "source" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_hash";
          let file_hash = (to_string (List.assoc "file_hash" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message";
          let message = (to_string (List.assoc "message" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { source = source; type_ = type_; file_hash = file_hash; message = message; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and PassportElementErrorFiles : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    source : string;
    type_ : string;
    file_hashes : string list;
    message : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("source", `String v.source);
      ("type", `String v.type_);
      ("file_hashes", `List (List.map (fun x -> `String x) v.file_hashes));
      ("message", `String v.message);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "source";
          let source = (to_string (List.assoc "source" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_hashes";
          let file_hashes = (List.map (fun x -> (to_string x)) (to_list (List.assoc "file_hashes" fields))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message";
          let message = (to_string (List.assoc "message" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { source = source; type_ = type_; file_hashes = file_hashes; message = message; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and PassportElementErrorTranslationFile : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    source : string;
    type_ : string;
    file_hash : string;
    message : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("source", `String v.source);
      ("type", `String v.type_);
      ("file_hash", `String v.file_hash);
      ("message", `String v.message);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "source";
          let source = (to_string (List.assoc "source" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_hash";
          let file_hash = (to_string (List.assoc "file_hash" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message";
          let message = (to_string (List.assoc "message" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { source = source; type_ = type_; file_hash = file_hash; message = message; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and PassportElementErrorTranslationFiles : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    source : string;
    type_ : string;
    file_hashes : string list;
    message : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("source", `String v.source);
      ("type", `String v.type_);
      ("file_hashes", `List (List.map (fun x -> `String x) v.file_hashes));
      ("message", `String v.message);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "source";
          let source = (to_string (List.assoc "source" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_hashes";
          let file_hashes = (List.map (fun x -> (to_string x)) (to_list (List.assoc "file_hashes" fields))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message";
          let message = (to_string (List.assoc "message" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { source = source; type_ = type_; file_hashes = file_hashes; message = message; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and PassportElementErrorUnspecified : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    source : string;
    type_ : string;
    element_hash : string;
    message : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("source", `String v.source);
      ("type", `String v.type_);
      ("element_hash", `String v.element_hash);
      ("message", `String v.message);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "source";
          let source = (to_string (List.assoc "source" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "element_hash";
          let element_hash = (to_string (List.assoc "element_hash" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message";
          let message = (to_string (List.assoc "message" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { source = source; type_ = type_; element_hash = element_hash; message = message; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and SendGame : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and CallbackGame : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and SetGameScore : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and GetGameHighScores : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = unit
  let to_yojson (_ : t) : Yojson.Safe.t = `Null
  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)
end
and InaccessibleMessage : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    chat : Chat.t;
    message_id : int64;
    date : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("chat", Chat.to_yojson v.chat);
      ("message_id", `Intlit (Int64.to_string v.message_id));
      ("date", `Intlit (Int64.to_string v.date));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat";
          let chat = (match Chat.of_yojson (List.assoc "chat" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "chat" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message_id";
          let message_id = (match (List.assoc "message_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "message_id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "date";
          let date = (match (List.assoc "date" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "date" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { chat = chat; message_id = message_id; date = date; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and MaybeInaccessibleMessage : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    offset : int64;
    length : int64;
    url : string option;
    user : User.t option;
    language : string option;
    custom_emoji_id : string option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("offset", `Intlit (Int64.to_string v.offset));
      ("length", `Intlit (Int64.to_string v.length));
      (match v.url with None -> ("url", `Null) | Some x -> ("url", `String x));
      (match v.user with None -> ("user", `Null) | Some x -> ("user", User.to_yojson x));
      (match v.language with None -> ("language", `Null) | Some x -> ("language", `String x));
      (match v.custom_emoji_id with None -> ("custom_emoji_id", `Null) | Some x -> ("custom_emoji_id", `String x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "offset";
          let offset = (match (List.assoc "offset" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "offset" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "length";
          let length = (match (List.assoc "length" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "length" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "url";
          let url = match List.assoc_opt "url" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "user";
          let user = match List.assoc_opt "user" fields with None | Some `Null -> None | Some x -> Some ((match User.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "language";
          let language = match List.assoc_opt "language" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "custom_emoji_id";
          let custom_emoji_id = match List.assoc_opt "custom_emoji_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; offset = offset; length = length; url = url; user = user; language = language; custom_emoji_id = custom_emoji_id; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and MessageEntity : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    offset : int64;
    length : int64;
    url : string option;
    user : User.t option;
    language : string option;
    custom_emoji_id : string option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("offset", `Intlit (Int64.to_string v.offset));
      ("length", `Intlit (Int64.to_string v.length));
      (match v.url with None -> ("url", `Null) | Some x -> ("url", `String x));
      (match v.user with None -> ("user", `Null) | Some x -> ("user", User.to_yojson x));
      (match v.language with None -> ("language", `Null) | Some x -> ("language", `String x));
      (match v.custom_emoji_id with None -> ("custom_emoji_id", `Null) | Some x -> ("custom_emoji_id", `String x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "offset";
          let offset = (match (List.assoc "offset" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "offset" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "length";
          let length = (match (List.assoc "length" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "length" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "url";
          let url = match List.assoc_opt "url" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "user";
          let user = match List.assoc_opt "user" fields with None | Some `Null -> None | Some x -> Some ((match User.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "language";
          let language = match List.assoc_opt "language" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "custom_emoji_id";
          let custom_emoji_id = match List.assoc_opt "custom_emoji_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; offset = offset; length = length; url = url; user = user; language = language; custom_emoji_id = custom_emoji_id; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and MessageOrigin : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    date : int64;
    sender_user : User.t;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("date", `Intlit (Int64.to_string v.date));
      ("sender_user", User.to_yojson v.sender_user);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "date";
          let date = (match (List.assoc "date" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "date" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "sender_user";
          let sender_user = (match User.of_yojson (List.assoc "sender_user" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "sender_user" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; date = date; sender_user = sender_user; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and MessageOriginUser : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    date : int64;
    sender_user : User.t;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("date", `Intlit (Int64.to_string v.date));
      ("sender_user", User.to_yojson v.sender_user);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "date";
          let date = (match (List.assoc "date" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "date" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "sender_user";
          let sender_user = (match User.of_yojson (List.assoc "sender_user" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "sender_user" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; date = date; sender_user = sender_user; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and MessageOriginChat : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    date : int64;
    sender_chat : Chat.t;
    author_signature : string option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("date", `Intlit (Int64.to_string v.date));
      ("sender_chat", Chat.to_yojson v.sender_chat);
      (match v.author_signature with None -> ("author_signature", `Null) | Some x -> ("author_signature", `String x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "date";
          let date = (match (List.assoc "date" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "date" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "sender_chat";
          let sender_chat = (match Chat.of_yojson (List.assoc "sender_chat" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "sender_chat" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "author_signature";
          let author_signature = match List.assoc_opt "author_signature" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; date = date; sender_chat = sender_chat; author_signature = author_signature; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and MessageOriginChannel : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    date : int64;
    chat : Chat.t;
    message_id : int64;
    author_signature : string option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("date", `Intlit (Int64.to_string v.date));
      ("chat", Chat.to_yojson v.chat);
      ("message_id", `Intlit (Int64.to_string v.message_id));
      (match v.author_signature with None -> ("author_signature", `Null) | Some x -> ("author_signature", `String x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "date";
          let date = (match (List.assoc "date" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "date" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat";
          let chat = (match Chat.of_yojson (List.assoc "chat" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "chat" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message_id";
          let message_id = (match (List.assoc "message_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "message_id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "author_signature";
          let author_signature = match List.assoc_opt "author_signature" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; date = date; chat = chat; message_id = message_id; author_signature = author_signature; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and Animation : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    file_id : string;
    file_unique_id : string;
    width : int64;
    height : int64;
    duration : int64;
    thumbnail : PhotoSize.t option;
    file_name : string option;
    mime_type : string option;
    file_size : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("file_id", `String v.file_id);
      ("file_unique_id", `String v.file_unique_id);
      ("width", `Intlit (Int64.to_string v.width));
      ("height", `Intlit (Int64.to_string v.height));
      ("duration", `Intlit (Int64.to_string v.duration));
      (match v.thumbnail with None -> ("thumbnail", `Null) | Some x -> ("thumbnail", PhotoSize.to_yojson x));
      (match v.file_name with None -> ("file_name", `Null) | Some x -> ("file_name", `String x));
      (match v.mime_type with None -> ("mime_type", `Null) | Some x -> ("mime_type", `String x));
      (match v.file_size with None -> ("file_size", `Null) | Some x -> ("file_size", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_id";
          let file_id = (to_string (List.assoc "file_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_unique_id";
          let file_unique_id = (to_string (List.assoc "file_unique_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "width";
          let width = (match (List.assoc "width" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "width" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "height";
          let height = (match (List.assoc "height" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "height" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "duration";
          let duration = (match (List.assoc "duration" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "duration" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail";
          let thumbnail = match List.assoc_opt "thumbnail" fields with None | Some `Null -> None | Some x -> Some ((match PhotoSize.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_name";
          let file_name = match List.assoc_opt "file_name" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "mime_type";
          let mime_type = match List.assoc_opt "mime_type" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_size";
          let file_size = match List.assoc_opt "file_size" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { file_id = file_id; file_unique_id = file_unique_id; width = width; height = height; duration = duration; thumbnail = thumbnail; file_name = file_name; mime_type = mime_type; file_size = file_size; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and Audio : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    file_id : string;
    file_unique_id : string;
    duration : int64;
    performer : string option;
    title : string option;
    file_name : string option;
    mime_type : string option;
    file_size : int64 option;
    thumbnail : PhotoSize.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("file_id", `String v.file_id);
      ("file_unique_id", `String v.file_unique_id);
      ("duration", `Intlit (Int64.to_string v.duration));
      (match v.performer with None -> ("performer", `Null) | Some x -> ("performer", `String x));
      (match v.title with None -> ("title", `Null) | Some x -> ("title", `String x));
      (match v.file_name with None -> ("file_name", `Null) | Some x -> ("file_name", `String x));
      (match v.mime_type with None -> ("mime_type", `Null) | Some x -> ("mime_type", `String x));
      (match v.file_size with None -> ("file_size", `Null) | Some x -> ("file_size", `Intlit (Int64.to_string x)));
      (match v.thumbnail with None -> ("thumbnail", `Null) | Some x -> ("thumbnail", PhotoSize.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_id";
          let file_id = (to_string (List.assoc "file_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_unique_id";
          let file_unique_id = (to_string (List.assoc "file_unique_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "duration";
          let duration = (match (List.assoc "duration" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "duration" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "performer";
          let performer = match List.assoc_opt "performer" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = match List.assoc_opt "title" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_name";
          let file_name = match List.assoc_opt "file_name" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "mime_type";
          let mime_type = match List.assoc_opt "mime_type" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_size";
          let file_size = match List.assoc_opt "file_size" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail";
          let thumbnail = match List.assoc_opt "thumbnail" fields with None | Some `Null -> None | Some x -> Some ((match PhotoSize.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { file_id = file_id; file_unique_id = file_unique_id; duration = duration; performer = performer; title = title; file_name = file_name; mime_type = mime_type; file_size = file_size; thumbnail = thumbnail; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and Document : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    file_id : string;
    file_unique_id : string;
    thumbnail : PhotoSize.t option;
    file_name : string option;
    mime_type : string option;
    file_size : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("file_id", `String v.file_id);
      ("file_unique_id", `String v.file_unique_id);
      (match v.thumbnail with None -> ("thumbnail", `Null) | Some x -> ("thumbnail", PhotoSize.to_yojson x));
      (match v.file_name with None -> ("file_name", `Null) | Some x -> ("file_name", `String x));
      (match v.mime_type with None -> ("mime_type", `Null) | Some x -> ("mime_type", `String x));
      (match v.file_size with None -> ("file_size", `Null) | Some x -> ("file_size", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_id";
          let file_id = (to_string (List.assoc "file_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_unique_id";
          let file_unique_id = (to_string (List.assoc "file_unique_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail";
          let thumbnail = match List.assoc_opt "thumbnail" fields with None | Some `Null -> None | Some x -> Some ((match PhotoSize.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_name";
          let file_name = match List.assoc_opt "file_name" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "mime_type";
          let mime_type = match List.assoc_opt "mime_type" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_size";
          let file_size = match List.assoc_opt "file_size" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { file_id = file_id; file_unique_id = file_unique_id; thumbnail = thumbnail; file_name = file_name; mime_type = mime_type; file_size = file_size; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and Story : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    chat : Chat.t;
    id : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("chat", Chat.to_yojson v.chat);
      ("id", `Intlit (Int64.to_string v.id));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat";
          let chat = (match Chat.of_yojson (List.assoc "chat" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "chat" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (match (List.assoc "id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "id" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { chat = chat; id = id; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and Video : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    file_id : string;
    file_unique_id : string;
    width : int64;
    height : int64;
    duration : int64;
    thumbnail : PhotoSize.t option;
    cover : PhotoSize.t list option;
    start_timestamp : int64 option;
    file_name : string option;
    mime_type : string option;
    file_size : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("file_id", `String v.file_id);
      ("file_unique_id", `String v.file_unique_id);
      ("width", `Intlit (Int64.to_string v.width));
      ("height", `Intlit (Int64.to_string v.height));
      ("duration", `Intlit (Int64.to_string v.duration));
      (match v.thumbnail with None -> ("thumbnail", `Null) | Some x -> ("thumbnail", PhotoSize.to_yojson x));
      (match v.cover with None -> ("cover", `Null) | Some x -> ("cover", `List (List.map (fun x -> PhotoSize.to_yojson x) x)));
      (match v.start_timestamp with None -> ("start_timestamp", `Null) | Some x -> ("start_timestamp", `Intlit (Int64.to_string x)));
      (match v.file_name with None -> ("file_name", `Null) | Some x -> ("file_name", `String x));
      (match v.mime_type with None -> ("mime_type", `Null) | Some x -> ("mime_type", `String x));
      (match v.file_size with None -> ("file_size", `Null) | Some x -> ("file_size", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_id";
          let file_id = (to_string (List.assoc "file_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_unique_id";
          let file_unique_id = (to_string (List.assoc "file_unique_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "width";
          let width = (match (List.assoc "width" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "width" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "height";
          let height = (match (List.assoc "height" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "height" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "duration";
          let duration = (match (List.assoc "duration" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "duration" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail";
          let thumbnail = match List.assoc_opt "thumbnail" fields with None | Some `Null -> None | Some x -> Some ((match PhotoSize.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "cover";
          let cover = match List.assoc_opt "cover" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match PhotoSize.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "start_timestamp";
          let start_timestamp = match List.assoc_opt "start_timestamp" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_name";
          let file_name = match List.assoc_opt "file_name" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "mime_type";
          let mime_type = match List.assoc_opt "mime_type" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_size";
          let file_size = match List.assoc_opt "file_size" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { file_id = file_id; file_unique_id = file_unique_id; width = width; height = height; duration = duration; thumbnail = thumbnail; cover = cover; start_timestamp = start_timestamp; file_name = file_name; mime_type = mime_type; file_size = file_size; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and VideoNote : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    file_id : string;
    file_unique_id : string;
    length : int64;
    duration : int64;
    thumbnail : PhotoSize.t option;
    file_size : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("file_id", `String v.file_id);
      ("file_unique_id", `String v.file_unique_id);
      ("length", `Intlit (Int64.to_string v.length));
      ("duration", `Intlit (Int64.to_string v.duration));
      (match v.thumbnail with None -> ("thumbnail", `Null) | Some x -> ("thumbnail", PhotoSize.to_yojson x));
      (match v.file_size with None -> ("file_size", `Null) | Some x -> ("file_size", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_id";
          let file_id = (to_string (List.assoc "file_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_unique_id";
          let file_unique_id = (to_string (List.assoc "file_unique_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "length";
          let length = (match (List.assoc "length" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "length" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "duration";
          let duration = (match (List.assoc "duration" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "duration" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail";
          let thumbnail = match List.assoc_opt "thumbnail" fields with None | Some `Null -> None | Some x -> Some ((match PhotoSize.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_size";
          let file_size = match List.assoc_opt "file_size" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { file_id = file_id; file_unique_id = file_unique_id; length = length; duration = duration; thumbnail = thumbnail; file_size = file_size; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and PaidMediaInfo : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    star_count : int64;
    paid_media : PaidMedia.t list;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("star_count", `Intlit (Int64.to_string v.star_count));
      ("paid_media", `List (List.map (fun x -> PaidMedia.to_yojson x) v.paid_media));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "star_count";
          let star_count = (match (List.assoc "star_count" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "star_count" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "paid_media";
          let paid_media = (List.map (fun x -> (match PaidMedia.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list (List.assoc "paid_media" fields))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { star_count = star_count; paid_media = paid_media; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and PaidMediaPhoto : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    photo : PhotoSize.t list;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("photo", `List (List.map (fun x -> PhotoSize.to_yojson x) v.photo));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "photo";
          let photo = (List.map (fun x -> (match PhotoSize.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list (List.assoc "photo" fields))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; photo = photo; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and PollAnswer : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    poll_id : string;
    voter_chat : Chat.t option;
    user : User.t option;
    option_ids : int64 list;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("poll_id", `String v.poll_id);
      (match v.voter_chat with None -> ("voter_chat", `Null) | Some x -> ("voter_chat", Chat.to_yojson x));
      (match v.user with None -> ("user", `Null) | Some x -> ("user", User.to_yojson x));
      ("option_ids", `List (List.map (fun x -> `Intlit (Int64.to_string x)) v.option_ids));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "poll_id";
          let poll_id = (to_string (List.assoc "poll_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "voter_chat";
          let voter_chat = match List.assoc_opt "voter_chat" fields with None | Some `Null -> None | Some x -> Some ((match Chat.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "user";
          let user = match List.assoc_opt "user" fields with None | Some `Null -> None | Some x -> Some ((match User.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "option_ids";
          let option_ids = (List.map (fun x -> (match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) (to_list (List.assoc "option_ids" fields))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { poll_id = poll_id; voter_chat = voter_chat; user = user; option_ids = option_ids; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and Venue : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    location : Location.t;
    title : string;
    address : string;
    foursquare_id : string option;
    foursquare_type : string option;
    google_place_id : string option;
    google_place_type : string option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("location", Location.to_yojson v.location);
      ("title", `String v.title);
      ("address", `String v.address);
      (match v.foursquare_id with None -> ("foursquare_id", `Null) | Some x -> ("foursquare_id", `String x));
      (match v.foursquare_type with None -> ("foursquare_type", `Null) | Some x -> ("foursquare_type", `String x));
      (match v.google_place_id with None -> ("google_place_id", `Null) | Some x -> ("google_place_id", `String x));
      (match v.google_place_type with None -> ("google_place_type", `Null) | Some x -> ("google_place_type", `String x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "location";
          let location = (match Location.of_yojson (List.assoc "location" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "location" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = (to_string (List.assoc "title" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "address";
          let address = (to_string (List.assoc "address" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "foursquare_id";
          let foursquare_id = match List.assoc_opt "foursquare_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "foursquare_type";
          let foursquare_type = match List.assoc_opt "foursquare_type" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "google_place_id";
          let google_place_id = match List.assoc_opt "google_place_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "google_place_type";
          let google_place_type = match List.assoc_opt "google_place_type" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { location = location; title = title; address = address; foursquare_id = foursquare_id; foursquare_type = foursquare_type; google_place_id = google_place_id; google_place_type = google_place_type; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ProximityAlertTriggered : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    traveler : User.t;
    watcher : User.t;
    distance : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("traveler", User.to_yojson v.traveler);
      ("watcher", User.to_yojson v.watcher);
      ("distance", `Intlit (Int64.to_string v.distance));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "traveler";
          let traveler = (match User.of_yojson (List.assoc "traveler" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "traveler" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "watcher";
          let watcher = (match User.of_yojson (List.assoc "watcher" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "watcher" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "distance";
          let distance = (match (List.assoc "distance" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "distance" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { traveler = traveler; watcher = watcher; distance = distance; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and BackgroundType : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    fill : BackgroundFill.t;
    dark_theme_dimming : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("fill", BackgroundFill.to_yojson v.fill);
      ("dark_theme_dimming", `Intlit (Int64.to_string v.dark_theme_dimming));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "fill";
          let fill = (match BackgroundFill.of_yojson (List.assoc "fill" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "fill" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "dark_theme_dimming";
          let dark_theme_dimming = (match (List.assoc "dark_theme_dimming" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "dark_theme_dimming" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; fill = fill; dark_theme_dimming = dark_theme_dimming; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and BackgroundTypeFill : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    fill : BackgroundFill.t;
    dark_theme_dimming : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("fill", BackgroundFill.to_yojson v.fill);
      ("dark_theme_dimming", `Intlit (Int64.to_string v.dark_theme_dimming));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "fill";
          let fill = (match BackgroundFill.of_yojson (List.assoc "fill" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "fill" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "dark_theme_dimming";
          let dark_theme_dimming = (match (List.assoc "dark_theme_dimming" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "dark_theme_dimming" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; fill = fill; dark_theme_dimming = dark_theme_dimming; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ForumTopicReopened : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    user_id : int64;
    first_name : string option;
    last_name : string option;
    username : string option;
    photo : PhotoSize.t list option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("user_id", `Intlit (Int64.to_string v.user_id));
      (match v.first_name with None -> ("first_name", `Null) | Some x -> ("first_name", `String x));
      (match v.last_name with None -> ("last_name", `Null) | Some x -> ("last_name", `String x));
      (match v.username with None -> ("username", `Null) | Some x -> ("username", `String x));
      (match v.photo with None -> ("photo", `Null) | Some x -> ("photo", `List (List.map (fun x -> PhotoSize.to_yojson x) x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "user_id";
          let user_id = (match (List.assoc "user_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "user_id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "first_name";
          let first_name = match List.assoc_opt "first_name" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "last_name";
          let last_name = match List.assoc_opt "last_name" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "username";
          let username = match List.assoc_opt "username" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "photo";
          let photo = match List.assoc_opt "photo" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match PhotoSize.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { user_id = user_id; first_name = first_name; last_name = last_name; username = username; photo = photo; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and GeneralForumTopicHidden : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    user_id : int64;
    first_name : string option;
    last_name : string option;
    username : string option;
    photo : PhotoSize.t list option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("user_id", `Intlit (Int64.to_string v.user_id));
      (match v.first_name with None -> ("first_name", `Null) | Some x -> ("first_name", `String x));
      (match v.last_name with None -> ("last_name", `Null) | Some x -> ("last_name", `String x));
      (match v.username with None -> ("username", `Null) | Some x -> ("username", `String x));
      (match v.photo with None -> ("photo", `Null) | Some x -> ("photo", `List (List.map (fun x -> PhotoSize.to_yojson x) x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "user_id";
          let user_id = (match (List.assoc "user_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "user_id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "first_name";
          let first_name = match List.assoc_opt "first_name" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "last_name";
          let last_name = match List.assoc_opt "last_name" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "username";
          let username = match List.assoc_opt "username" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "photo";
          let photo = match List.assoc_opt "photo" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match PhotoSize.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { user_id = user_id; first_name = first_name; last_name = last_name; username = username; photo = photo; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and GeneralForumTopicUnhidden : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    user_id : int64;
    first_name : string option;
    last_name : string option;
    username : string option;
    photo : PhotoSize.t list option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("user_id", `Intlit (Int64.to_string v.user_id));
      (match v.first_name with None -> ("first_name", `Null) | Some x -> ("first_name", `String x));
      (match v.last_name with None -> ("last_name", `Null) | Some x -> ("last_name", `String x));
      (match v.username with None -> ("username", `Null) | Some x -> ("username", `String x));
      (match v.photo with None -> ("photo", `Null) | Some x -> ("photo", `List (List.map (fun x -> PhotoSize.to_yojson x) x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "user_id";
          let user_id = (match (List.assoc "user_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "user_id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "first_name";
          let first_name = match List.assoc_opt "first_name" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "last_name";
          let last_name = match List.assoc_opt "last_name" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "username";
          let username = match List.assoc_opt "username" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "photo";
          let photo = match List.assoc_opt "photo" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match PhotoSize.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { user_id = user_id; first_name = first_name; last_name = last_name; username = username; photo = photo; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and SharedUser : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    user_id : int64;
    first_name : string option;
    last_name : string option;
    username : string option;
    photo : PhotoSize.t list option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("user_id", `Intlit (Int64.to_string v.user_id));
      (match v.first_name with None -> ("first_name", `Null) | Some x -> ("first_name", `String x));
      (match v.last_name with None -> ("last_name", `Null) | Some x -> ("last_name", `String x));
      (match v.username with None -> ("username", `Null) | Some x -> ("username", `String x));
      (match v.photo with None -> ("photo", `Null) | Some x -> ("photo", `List (List.map (fun x -> PhotoSize.to_yojson x) x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "user_id";
          let user_id = (match (List.assoc "user_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "user_id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "first_name";
          let first_name = match List.assoc_opt "first_name" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "last_name";
          let last_name = match List.assoc_opt "last_name" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "username";
          let username = match List.assoc_opt "username" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "photo";
          let photo = match List.assoc_opt "photo" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match PhotoSize.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { user_id = user_id; first_name = first_name; last_name = last_name; username = username; photo = photo; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ChatShared : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    request_id : int64;
    chat_id : int64;
    title : string option;
    username : string option;
    photo : PhotoSize.t list option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("request_id", `Intlit (Int64.to_string v.request_id));
      ("chat_id", `Intlit (Int64.to_string v.chat_id));
      (match v.title with None -> ("title", `Null) | Some x -> ("title", `String x));
      (match v.username with None -> ("username", `Null) | Some x -> ("username", `String x));
      (match v.photo with None -> ("photo", `Null) | Some x -> ("photo", `List (List.map (fun x -> PhotoSize.to_yojson x) x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "request_id";
          let request_id = (match (List.assoc "request_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "request_id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_id";
          let chat_id = (match (List.assoc "chat_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "chat_id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = match List.assoc_opt "title" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "username";
          let username = match List.assoc_opt "username" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "photo";
          let photo = match List.assoc_opt "photo" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match PhotoSize.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { request_id = request_id; chat_id = chat_id; title = title; username = username; photo = photo; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and VideoChatParticipantsInvited : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    users : User.t list;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("users", `List (List.map (fun x -> User.to_yojson x) v.users));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "users";
          let users = (List.map (fun x -> (match User.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list (List.assoc "users" fields))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { users = users; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and Giveaway : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    chats : Chat.t list;
    winners_selection_date : int64;
    winner_count : int64;
    only_new_members : bool option;
    has_public_winners : bool option;
    prize_description : string option;
    country_codes : string list option;
    prize_star_count : int64 option;
    premium_subscription_month_count : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("chats", `List (List.map (fun x -> Chat.to_yojson x) v.chats));
      ("winners_selection_date", `Intlit (Int64.to_string v.winners_selection_date));
      ("winner_count", `Intlit (Int64.to_string v.winner_count));
      (match v.only_new_members with None -> ("only_new_members", `Null) | Some x -> ("only_new_members", `Bool x));
      (match v.has_public_winners with None -> ("has_public_winners", `Null) | Some x -> ("has_public_winners", `Bool x));
      (match v.prize_description with None -> ("prize_description", `Null) | Some x -> ("prize_description", `String x));
      (match v.country_codes with None -> ("country_codes", `Null) | Some x -> ("country_codes", `List (List.map (fun x -> `String x) x)));
      (match v.prize_star_count with None -> ("prize_star_count", `Null) | Some x -> ("prize_star_count", `Intlit (Int64.to_string x)));
      (match v.premium_subscription_month_count with None -> ("premium_subscription_month_count", `Null) | Some x -> ("premium_subscription_month_count", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "chats";
          let chats = (List.map (fun x -> (match Chat.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list (List.assoc "chats" fields))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "winners_selection_date";
          let winners_selection_date = (match (List.assoc "winners_selection_date" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "winners_selection_date" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "winner_count";
          let winner_count = (match (List.assoc "winner_count" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "winner_count" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "only_new_members";
          let only_new_members = match List.assoc_opt "only_new_members" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "has_public_winners";
          let has_public_winners = match List.assoc_opt "has_public_winners" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "prize_description";
          let prize_description = match List.assoc_opt "prize_description" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "country_codes";
          let country_codes = match List.assoc_opt "country_codes" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (to_string x)) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "prize_star_count";
          let prize_star_count = match List.assoc_opt "prize_star_count" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "premium_subscription_month_count";
          let premium_subscription_month_count = match List.assoc_opt "premium_subscription_month_count" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { chats = chats; winners_selection_date = winners_selection_date; winner_count = winner_count; only_new_members = only_new_members; has_public_winners = has_public_winners; prize_description = prize_description; country_codes = country_codes; prize_star_count = prize_star_count; premium_subscription_month_count = premium_subscription_month_count; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and GiveawayWinners : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    chat : Chat.t;
    giveaway_message_id : int64;
    winners_selection_date : int64;
    winner_count : int64;
    winners : User.t list;
    additional_chat_count : int64 option;
    prize_star_count : int64 option;
    premium_subscription_month_count : int64 option;
    unclaimed_prize_count : int64 option;
    only_new_members : bool option;
    was_refunded : bool option;
    prize_description : string option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("chat", Chat.to_yojson v.chat);
      ("giveaway_message_id", `Intlit (Int64.to_string v.giveaway_message_id));
      ("winners_selection_date", `Intlit (Int64.to_string v.winners_selection_date));
      ("winner_count", `Intlit (Int64.to_string v.winner_count));
      ("winners", `List (List.map (fun x -> User.to_yojson x) v.winners));
      (match v.additional_chat_count with None -> ("additional_chat_count", `Null) | Some x -> ("additional_chat_count", `Intlit (Int64.to_string x)));
      (match v.prize_star_count with None -> ("prize_star_count", `Null) | Some x -> ("prize_star_count", `Intlit (Int64.to_string x)));
      (match v.premium_subscription_month_count with None -> ("premium_subscription_month_count", `Null) | Some x -> ("premium_subscription_month_count", `Intlit (Int64.to_string x)));
      (match v.unclaimed_prize_count with None -> ("unclaimed_prize_count", `Null) | Some x -> ("unclaimed_prize_count", `Intlit (Int64.to_string x)));
      (match v.only_new_members with None -> ("only_new_members", `Null) | Some x -> ("only_new_members", `Bool x));
      (match v.was_refunded with None -> ("was_refunded", `Null) | Some x -> ("was_refunded", `Bool x));
      (match v.prize_description with None -> ("prize_description", `Null) | Some x -> ("prize_description", `String x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat";
          let chat = (match Chat.of_yojson (List.assoc "chat" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "chat" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "giveaway_message_id";
          let giveaway_message_id = (match (List.assoc "giveaway_message_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "giveaway_message_id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "winners_selection_date";
          let winners_selection_date = (match (List.assoc "winners_selection_date" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "winners_selection_date" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "winner_count";
          let winner_count = (match (List.assoc "winner_count" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "winner_count" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "winners";
          let winners = (List.map (fun x -> (match User.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list (List.assoc "winners" fields))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "additional_chat_count";
          let additional_chat_count = match List.assoc_opt "additional_chat_count" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "prize_star_count";
          let prize_star_count = match List.assoc_opt "prize_star_count" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "premium_subscription_month_count";
          let premium_subscription_month_count = match List.assoc_opt "premium_subscription_month_count" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "unclaimed_prize_count";
          let unclaimed_prize_count = match List.assoc_opt "unclaimed_prize_count" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "only_new_members";
          let only_new_members = match List.assoc_opt "only_new_members" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "was_refunded";
          let was_refunded = match List.assoc_opt "was_refunded" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "prize_description";
          let prize_description = match List.assoc_opt "prize_description" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { chat = chat; giveaway_message_id = giveaway_message_id; winners_selection_date = winners_selection_date; winner_count = winner_count; winners = winners; additional_chat_count = additional_chat_count; prize_star_count = prize_star_count; premium_subscription_month_count = premium_subscription_month_count; unclaimed_prize_count = unclaimed_prize_count; only_new_members = only_new_members; was_refunded = was_refunded; prize_description = prize_description; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and SuggestedPostInfo : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    state : string;
    price : SuggestedPostPrice.t option;
    send_date : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("state", `String v.state);
      (match v.price with None -> ("price", `Null) | Some x -> ("price", SuggestedPostPrice.to_yojson x));
      (match v.send_date with None -> ("send_date", `Null) | Some x -> ("send_date", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "state";
          let state = (to_string (List.assoc "state" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "price";
          let price = match List.assoc_opt "price" fields with None | Some `Null -> None | Some x -> Some ((match SuggestedPostPrice.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "send_date";
          let send_date = match List.assoc_opt "send_date" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { state = state; price = price; send_date = send_date; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and SuggestedPostParameters : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    price : SuggestedPostPrice.t option;
    send_date : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      (match v.price with None -> ("price", `Null) | Some x -> ("price", SuggestedPostPrice.to_yojson x));
      (match v.send_date with None -> ("send_date", `Null) | Some x -> ("send_date", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "price";
          let price = match List.assoc_opt "price" fields with None | Some `Null -> None | Some x -> Some ((match SuggestedPostPrice.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "send_date";
          let send_date = match List.assoc_opt "send_date" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { price = price; send_date = send_date; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and DirectMessagesTopic : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    topic_id : int64;
    user : User.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("topic_id", `Intlit (Int64.to_string v.topic_id));
      (match v.user with None -> ("user", `Null) | Some x -> ("user", User.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "topic_id";
          let topic_id = (match (List.assoc "topic_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "topic_id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "user";
          let user = match List.assoc_opt "user" fields with None | Some `Null -> None | Some x -> Some ((match User.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { topic_id = topic_id; user = user; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and UserProfilePhotos : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    total_count : int64;
    photos : PhotoSize.t list list;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("total_count", `Intlit (Int64.to_string v.total_count));
      ("photos", `List (List.map (fun x -> `List (List.map (fun x -> PhotoSize.to_yojson x) x)) v.photos));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "total_count";
          let total_count = (match (List.assoc "total_count" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "total_count" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "photos";
          let photos = (List.map (fun x -> (List.map (fun x -> (match PhotoSize.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) (to_list (List.assoc "photos" fields))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { total_count = total_count; photos = photos; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and KeyboardButtonRequestChat : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    request_id : int64;
    chat_is_channel : bool;
    chat_is_forum : bool option;
    chat_has_username : bool option;
    chat_is_created : bool option;
    user_administrator_rights : ChatAdministratorRights.t option;
    bot_administrator_rights : ChatAdministratorRights.t option;
    bot_is_member : bool option;
    request_title : bool option;
    request_username : bool option;
    request_photo : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("request_id", `Intlit (Int64.to_string v.request_id));
      ("chat_is_channel", `Bool v.chat_is_channel);
      (match v.chat_is_forum with None -> ("chat_is_forum", `Null) | Some x -> ("chat_is_forum", `Bool x));
      (match v.chat_has_username with None -> ("chat_has_username", `Null) | Some x -> ("chat_has_username", `Bool x));
      (match v.chat_is_created with None -> ("chat_is_created", `Null) | Some x -> ("chat_is_created", `Bool x));
      (match v.user_administrator_rights with None -> ("user_administrator_rights", `Null) | Some x -> ("user_administrator_rights", ChatAdministratorRights.to_yojson x));
      (match v.bot_administrator_rights with None -> ("bot_administrator_rights", `Null) | Some x -> ("bot_administrator_rights", ChatAdministratorRights.to_yojson x));
      (match v.bot_is_member with None -> ("bot_is_member", `Null) | Some x -> ("bot_is_member", `Bool x));
      (match v.request_title with None -> ("request_title", `Null) | Some x -> ("request_title", `Bool x));
      (match v.request_username with None -> ("request_username", `Null) | Some x -> ("request_username", `Bool x));
      (match v.request_photo with None -> ("request_photo", `Null) | Some x -> ("request_photo", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "request_id";
          let request_id = (match (List.assoc "request_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "request_id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_is_channel";
          let chat_is_channel = (to_bool (List.assoc "chat_is_channel" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_is_forum";
          let chat_is_forum = match List.assoc_opt "chat_is_forum" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_has_username";
          let chat_has_username = match List.assoc_opt "chat_has_username" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_is_created";
          let chat_is_created = match List.assoc_opt "chat_is_created" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "user_administrator_rights";
          let user_administrator_rights = match List.assoc_opt "user_administrator_rights" fields with None | Some `Null -> None | Some x -> Some ((match ChatAdministratorRights.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "bot_administrator_rights";
          let bot_administrator_rights = match List.assoc_opt "bot_administrator_rights" fields with None | Some `Null -> None | Some x -> Some ((match ChatAdministratorRights.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "bot_is_member";
          let bot_is_member = match List.assoc_opt "bot_is_member" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "request_title";
          let request_title = match List.assoc_opt "request_title" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "request_username";
          let request_username = match List.assoc_opt "request_username" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "request_photo";
          let request_photo = match List.assoc_opt "request_photo" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { request_id = request_id; chat_is_channel = chat_is_channel; chat_is_forum = chat_is_forum; chat_has_username = chat_has_username; chat_is_created = chat_is_created; user_administrator_rights = user_administrator_rights; bot_administrator_rights = bot_administrator_rights; bot_is_member = bot_is_member; request_title = request_title; request_username = request_username; request_photo = request_photo; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InlineKeyboardButton : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    text : string;
    url : string option;
    callback_data : string option;
    web_app : WebAppInfo.t option;
    login_url : LoginUrl.t option;
    switch_inline_query : string option;
    switch_inline_query_current_chat : string option;
    switch_inline_query_chosen_chat : SwitchInlineQueryChosenChat.t option;
    copy_text : CopyTextButton.t option;
    callback_game : CallbackGame.t option;
    pay : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("text", `String v.text);
      (match v.url with None -> ("url", `Null) | Some x -> ("url", `String x));
      (match v.callback_data with None -> ("callback_data", `Null) | Some x -> ("callback_data", `String x));
      (match v.web_app with None -> ("web_app", `Null) | Some x -> ("web_app", WebAppInfo.to_yojson x));
      (match v.login_url with None -> ("login_url", `Null) | Some x -> ("login_url", LoginUrl.to_yojson x));
      (match v.switch_inline_query with None -> ("switch_inline_query", `Null) | Some x -> ("switch_inline_query", `String x));
      (match v.switch_inline_query_current_chat with None -> ("switch_inline_query_current_chat", `Null) | Some x -> ("switch_inline_query_current_chat", `String x));
      (match v.switch_inline_query_chosen_chat with None -> ("switch_inline_query_chosen_chat", `Null) | Some x -> ("switch_inline_query_chosen_chat", SwitchInlineQueryChosenChat.to_yojson x));
      (match v.copy_text with None -> ("copy_text", `Null) | Some x -> ("copy_text", CopyTextButton.to_yojson x));
      (match v.callback_game with None -> ("callback_game", `Null) | Some x -> ("callback_game", CallbackGame.to_yojson x));
      (match v.pay with None -> ("pay", `Null) | Some x -> ("pay", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "text";
          let text = (to_string (List.assoc "text" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "url";
          let url = match List.assoc_opt "url" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "callback_data";
          let callback_data = match List.assoc_opt "callback_data" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "web_app";
          let web_app = match List.assoc_opt "web_app" fields with None | Some `Null -> None | Some x -> Some ((match WebAppInfo.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "login_url";
          let login_url = match List.assoc_opt "login_url" fields with None | Some `Null -> None | Some x -> Some ((match LoginUrl.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "switch_inline_query";
          let switch_inline_query = match List.assoc_opt "switch_inline_query" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "switch_inline_query_current_chat";
          let switch_inline_query_current_chat = match List.assoc_opt "switch_inline_query_current_chat" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "switch_inline_query_chosen_chat";
          let switch_inline_query_chosen_chat = match List.assoc_opt "switch_inline_query_chosen_chat" fields with None | Some `Null -> None | Some x -> Some ((match SwitchInlineQueryChosenChat.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "copy_text";
          let copy_text = match List.assoc_opt "copy_text" fields with None | Some `Null -> None | Some x -> Some ((match CopyTextButton.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "callback_game";
          let callback_game = match List.assoc_opt "callback_game" fields with None | Some `Null -> None | Some x -> Some ((match CallbackGame.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "pay";
          let pay = match List.assoc_opt "pay" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { text = text; url = url; callback_data = callback_data; web_app = web_app; login_url = login_url; switch_inline_query = switch_inline_query; switch_inline_query_current_chat = switch_inline_query_current_chat; switch_inline_query_chosen_chat = switch_inline_query_chosen_chat; copy_text = copy_text; callback_game = callback_game; pay = pay; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ChatInviteLink : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    invite_link : string;
    creator : User.t;
    creates_join_request : bool;
    is_primary : bool;
    is_revoked : bool;
    name : string option;
    expire_date : int64 option;
    member_limit : int64 option;
    pending_join_request_count : int64 option;
    subscription_period : int64 option;
    subscription_price : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("invite_link", `String v.invite_link);
      ("creator", User.to_yojson v.creator);
      ("creates_join_request", `Bool v.creates_join_request);
      ("is_primary", `Bool v.is_primary);
      ("is_revoked", `Bool v.is_revoked);
      (match v.name with None -> ("name", `Null) | Some x -> ("name", `String x));
      (match v.expire_date with None -> ("expire_date", `Null) | Some x -> ("expire_date", `Intlit (Int64.to_string x)));
      (match v.member_limit with None -> ("member_limit", `Null) | Some x -> ("member_limit", `Intlit (Int64.to_string x)));
      (match v.pending_join_request_count with None -> ("pending_join_request_count", `Null) | Some x -> ("pending_join_request_count", `Intlit (Int64.to_string x)));
      (match v.subscription_period with None -> ("subscription_period", `Null) | Some x -> ("subscription_period", `Intlit (Int64.to_string x)));
      (match v.subscription_price with None -> ("subscription_price", `Null) | Some x -> ("subscription_price", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "invite_link";
          let invite_link = (to_string (List.assoc "invite_link" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "creator";
          let creator = (match User.of_yojson (List.assoc "creator" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "creator" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "creates_join_request";
          let creates_join_request = (to_bool (List.assoc "creates_join_request" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_primary";
          let is_primary = (to_bool (List.assoc "is_primary" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_revoked";
          let is_revoked = (to_bool (List.assoc "is_revoked" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "name";
          let name = match List.assoc_opt "name" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "expire_date";
          let expire_date = match List.assoc_opt "expire_date" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "member_limit";
          let member_limit = match List.assoc_opt "member_limit" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "pending_join_request_count";
          let pending_join_request_count = match List.assoc_opt "pending_join_request_count" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "subscription_period";
          let subscription_period = match List.assoc_opt "subscription_period" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "subscription_price";
          let subscription_price = match List.assoc_opt "subscription_price" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { invite_link = invite_link; creator = creator; creates_join_request = creates_join_request; is_primary = is_primary; is_revoked = is_revoked; name = name; expire_date = expire_date; member_limit = member_limit; pending_join_request_count = pending_join_request_count; subscription_period = subscription_period; subscription_price = subscription_price; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ChatMember : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    status : string;
    user : User.t;
    is_anonymous : bool;
    custom_title : string option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("status", `String v.status);
      ("user", User.to_yojson v.user);
      ("is_anonymous", `Bool v.is_anonymous);
      (match v.custom_title with None -> ("custom_title", `Null) | Some x -> ("custom_title", `String x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "status";
          let status = (to_string (List.assoc "status" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "user";
          let user = (match User.of_yojson (List.assoc "user" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "user" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_anonymous";
          let is_anonymous = (to_bool (List.assoc "is_anonymous" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "custom_title";
          let custom_title = match List.assoc_opt "custom_title" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { status = status; user = user; is_anonymous = is_anonymous; custom_title = custom_title; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ChatMemberOwner : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    status : string;
    user : User.t;
    is_anonymous : bool;
    custom_title : string option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("status", `String v.status);
      ("user", User.to_yojson v.user);
      ("is_anonymous", `Bool v.is_anonymous);
      (match v.custom_title with None -> ("custom_title", `Null) | Some x -> ("custom_title", `String x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "status";
          let status = (to_string (List.assoc "status" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "user";
          let user = (match User.of_yojson (List.assoc "user" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "user" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_anonymous";
          let is_anonymous = (to_bool (List.assoc "is_anonymous" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "custom_title";
          let custom_title = match List.assoc_opt "custom_title" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { status = status; user = user; is_anonymous = is_anonymous; custom_title = custom_title; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ChatMemberAdministrator : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    status : string;
    user : User.t;
    can_be_edited : bool;
    is_anonymous : bool;
    can_manage_chat : bool;
    can_delete_messages : bool;
    can_manage_video_chats : bool;
    can_restrict_members : bool;
    can_promote_members : bool;
    can_change_info : bool;
    can_invite_users : bool;
    can_post_stories : bool;
    can_edit_stories : bool;
    can_delete_stories : bool;
    can_post_messages : bool option;
    can_edit_messages : bool option;
    can_pin_messages : bool option;
    can_manage_topics : bool option;
    can_manage_direct_messages : bool option;
    custom_title : string option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("status", `String v.status);
      ("user", User.to_yojson v.user);
      ("can_be_edited", `Bool v.can_be_edited);
      ("is_anonymous", `Bool v.is_anonymous);
      ("can_manage_chat", `Bool v.can_manage_chat);
      ("can_delete_messages", `Bool v.can_delete_messages);
      ("can_manage_video_chats", `Bool v.can_manage_video_chats);
      ("can_restrict_members", `Bool v.can_restrict_members);
      ("can_promote_members", `Bool v.can_promote_members);
      ("can_change_info", `Bool v.can_change_info);
      ("can_invite_users", `Bool v.can_invite_users);
      ("can_post_stories", `Bool v.can_post_stories);
      ("can_edit_stories", `Bool v.can_edit_stories);
      ("can_delete_stories", `Bool v.can_delete_stories);
      (match v.can_post_messages with None -> ("can_post_messages", `Null) | Some x -> ("can_post_messages", `Bool x));
      (match v.can_edit_messages with None -> ("can_edit_messages", `Null) | Some x -> ("can_edit_messages", `Bool x));
      (match v.can_pin_messages with None -> ("can_pin_messages", `Null) | Some x -> ("can_pin_messages", `Bool x));
      (match v.can_manage_topics with None -> ("can_manage_topics", `Null) | Some x -> ("can_manage_topics", `Bool x));
      (match v.can_manage_direct_messages with None -> ("can_manage_direct_messages", `Null) | Some x -> ("can_manage_direct_messages", `Bool x));
      (match v.custom_title with None -> ("custom_title", `Null) | Some x -> ("custom_title", `String x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "status";
          let status = (to_string (List.assoc "status" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "user";
          let user = (match User.of_yojson (List.assoc "user" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "user" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_be_edited";
          let can_be_edited = (to_bool (List.assoc "can_be_edited" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_anonymous";
          let is_anonymous = (to_bool (List.assoc "is_anonymous" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_manage_chat";
          let can_manage_chat = (to_bool (List.assoc "can_manage_chat" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_delete_messages";
          let can_delete_messages = (to_bool (List.assoc "can_delete_messages" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_manage_video_chats";
          let can_manage_video_chats = (to_bool (List.assoc "can_manage_video_chats" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_restrict_members";
          let can_restrict_members = (to_bool (List.assoc "can_restrict_members" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_promote_members";
          let can_promote_members = (to_bool (List.assoc "can_promote_members" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_change_info";
          let can_change_info = (to_bool (List.assoc "can_change_info" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_invite_users";
          let can_invite_users = (to_bool (List.assoc "can_invite_users" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_post_stories";
          let can_post_stories = (to_bool (List.assoc "can_post_stories" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_edit_stories";
          let can_edit_stories = (to_bool (List.assoc "can_edit_stories" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_delete_stories";
          let can_delete_stories = (to_bool (List.assoc "can_delete_stories" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_post_messages";
          let can_post_messages = match List.assoc_opt "can_post_messages" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_edit_messages";
          let can_edit_messages = match List.assoc_opt "can_edit_messages" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_pin_messages";
          let can_pin_messages = match List.assoc_opt "can_pin_messages" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_manage_topics";
          let can_manage_topics = match List.assoc_opt "can_manage_topics" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_manage_direct_messages";
          let can_manage_direct_messages = match List.assoc_opt "can_manage_direct_messages" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "custom_title";
          let custom_title = match List.assoc_opt "custom_title" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { status = status; user = user; can_be_edited = can_be_edited; is_anonymous = is_anonymous; can_manage_chat = can_manage_chat; can_delete_messages = can_delete_messages; can_manage_video_chats = can_manage_video_chats; can_restrict_members = can_restrict_members; can_promote_members = can_promote_members; can_change_info = can_change_info; can_invite_users = can_invite_users; can_post_stories = can_post_stories; can_edit_stories = can_edit_stories; can_delete_stories = can_delete_stories; can_post_messages = can_post_messages; can_edit_messages = can_edit_messages; can_pin_messages = can_pin_messages; can_manage_topics = can_manage_topics; can_manage_direct_messages = can_manage_direct_messages; custom_title = custom_title; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ChatMemberMember : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    status : string;
    user : User.t;
    until_date : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("status", `String v.status);
      ("user", User.to_yojson v.user);
      (match v.until_date with None -> ("until_date", `Null) | Some x -> ("until_date", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "status";
          let status = (to_string (List.assoc "status" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "user";
          let user = (match User.of_yojson (List.assoc "user" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "user" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "until_date";
          let until_date = match List.assoc_opt "until_date" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { status = status; user = user; until_date = until_date; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ChatMemberRestricted : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    status : string;
    user : User.t;
    is_member : bool;
    can_send_messages : bool;
    can_send_audios : bool;
    can_send_documents : bool;
    can_send_photos : bool;
    can_send_videos : bool;
    can_send_video_notes : bool;
    can_send_voice_notes : bool;
    can_send_polls : bool;
    can_send_other_messages : bool;
    can_add_web_page_previews : bool;
    can_change_info : bool;
    can_invite_users : bool;
    can_pin_messages : bool;
    can_manage_topics : bool;
    until_date : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("status", `String v.status);
      ("user", User.to_yojson v.user);
      ("is_member", `Bool v.is_member);
      ("can_send_messages", `Bool v.can_send_messages);
      ("can_send_audios", `Bool v.can_send_audios);
      ("can_send_documents", `Bool v.can_send_documents);
      ("can_send_photos", `Bool v.can_send_photos);
      ("can_send_videos", `Bool v.can_send_videos);
      ("can_send_video_notes", `Bool v.can_send_video_notes);
      ("can_send_voice_notes", `Bool v.can_send_voice_notes);
      ("can_send_polls", `Bool v.can_send_polls);
      ("can_send_other_messages", `Bool v.can_send_other_messages);
      ("can_add_web_page_previews", `Bool v.can_add_web_page_previews);
      ("can_change_info", `Bool v.can_change_info);
      ("can_invite_users", `Bool v.can_invite_users);
      ("can_pin_messages", `Bool v.can_pin_messages);
      ("can_manage_topics", `Bool v.can_manage_topics);
      ("until_date", `Intlit (Int64.to_string v.until_date));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "status";
          let status = (to_string (List.assoc "status" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "user";
          let user = (match User.of_yojson (List.assoc "user" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "user" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_member";
          let is_member = (to_bool (List.assoc "is_member" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_send_messages";
          let can_send_messages = (to_bool (List.assoc "can_send_messages" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_send_audios";
          let can_send_audios = (to_bool (List.assoc "can_send_audios" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_send_documents";
          let can_send_documents = (to_bool (List.assoc "can_send_documents" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_send_photos";
          let can_send_photos = (to_bool (List.assoc "can_send_photos" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_send_videos";
          let can_send_videos = (to_bool (List.assoc "can_send_videos" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_send_video_notes";
          let can_send_video_notes = (to_bool (List.assoc "can_send_video_notes" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_send_voice_notes";
          let can_send_voice_notes = (to_bool (List.assoc "can_send_voice_notes" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_send_polls";
          let can_send_polls = (to_bool (List.assoc "can_send_polls" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_send_other_messages";
          let can_send_other_messages = (to_bool (List.assoc "can_send_other_messages" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_add_web_page_previews";
          let can_add_web_page_previews = (to_bool (List.assoc "can_add_web_page_previews" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_change_info";
          let can_change_info = (to_bool (List.assoc "can_change_info" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_invite_users";
          let can_invite_users = (to_bool (List.assoc "can_invite_users" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_pin_messages";
          let can_pin_messages = (to_bool (List.assoc "can_pin_messages" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_manage_topics";
          let can_manage_topics = (to_bool (List.assoc "can_manage_topics" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "until_date";
          let until_date = (match (List.assoc "until_date" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "until_date" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { status = status; user = user; is_member = is_member; can_send_messages = can_send_messages; can_send_audios = can_send_audios; can_send_documents = can_send_documents; can_send_photos = can_send_photos; can_send_videos = can_send_videos; can_send_video_notes = can_send_video_notes; can_send_voice_notes = can_send_voice_notes; can_send_polls = can_send_polls; can_send_other_messages = can_send_other_messages; can_add_web_page_previews = can_add_web_page_previews; can_change_info = can_change_info; can_invite_users = can_invite_users; can_pin_messages = can_pin_messages; can_manage_topics = can_manage_topics; until_date = until_date; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ChatMemberLeft : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    status : string;
    user : User.t;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("status", `String v.status);
      ("user", User.to_yojson v.user);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "status";
          let status = (to_string (List.assoc "status" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "user";
          let user = (match User.of_yojson (List.assoc "user" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "user" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { status = status; user = user; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ChatMemberBanned : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    status : string;
    user : User.t;
    until_date : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("status", `String v.status);
      ("user", User.to_yojson v.user);
      ("until_date", `Intlit (Int64.to_string v.until_date));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "status";
          let status = (to_string (List.assoc "status" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "user";
          let user = (match User.of_yojson (List.assoc "user" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "user" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "until_date";
          let until_date = (match (List.assoc "until_date" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "until_date" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { status = status; user = user; until_date = until_date; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and BusinessLocation : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    address : string;
    location : Location.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("address", `String v.address);
      (match v.location with None -> ("location", `Null) | Some x -> ("location", Location.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "address";
          let address = (to_string (List.assoc "address" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "location";
          let location = match List.assoc_opt "location" fields with None | Some `Null -> None | Some x -> Some ((match Location.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { address = address; location = location; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and BusinessOpeningHours : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    time_zone_name : string;
    opening_hours : BusinessOpeningHoursInterval.t list;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("time_zone_name", `String v.time_zone_name);
      ("opening_hours", `List (List.map (fun x -> BusinessOpeningHoursInterval.to_yojson x) v.opening_hours));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "time_zone_name";
          let time_zone_name = (to_string (List.assoc "time_zone_name" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "opening_hours";
          let opening_hours = (List.map (fun x -> (match BusinessOpeningHoursInterval.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list (List.assoc "opening_hours" fields))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { time_zone_name = time_zone_name; opening_hours = opening_hours; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and StoryAreaType : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    latitude : float;
    longitude : float;
    address : LocationAddress.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("latitude", `Float v.latitude);
      ("longitude", `Float v.longitude);
      (match v.address with None -> ("address", `Null) | Some x -> ("address", LocationAddress.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "latitude";
          let latitude = (to_float (List.assoc "latitude" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "longitude";
          let longitude = (to_float (List.assoc "longitude" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "address";
          let address = match List.assoc_opt "address" fields with None | Some `Null -> None | Some x -> Some ((match LocationAddress.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; latitude = latitude; longitude = longitude; address = address; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and StoryAreaTypeLocation : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    latitude : float;
    longitude : float;
    address : LocationAddress.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("latitude", `Float v.latitude);
      ("longitude", `Float v.longitude);
      (match v.address with None -> ("address", `Null) | Some x -> ("address", LocationAddress.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "latitude";
          let latitude = (to_float (List.assoc "latitude" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "longitude";
          let longitude = (to_float (List.assoc "longitude" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "address";
          let address = match List.assoc_opt "address" fields with None | Some `Null -> None | Some x -> Some ((match LocationAddress.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; latitude = latitude; longitude = longitude; address = address; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and StoryAreaTypeSuggestedReaction : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    reaction_type : ReactionType.t;
    is_dark : bool option;
    is_flipped : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("reaction_type", ReactionType.to_yojson v.reaction_type);
      (match v.is_dark with None -> ("is_dark", `Null) | Some x -> ("is_dark", `Bool x));
      (match v.is_flipped with None -> ("is_flipped", `Null) | Some x -> ("is_flipped", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "reaction_type";
          let reaction_type = (match ReactionType.of_yojson (List.assoc "reaction_type" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "reaction_type" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_dark";
          let is_dark = match List.assoc_opt "is_dark" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_flipped";
          let is_flipped = match List.assoc_opt "is_flipped" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; reaction_type = reaction_type; is_dark = is_dark; is_flipped = is_flipped; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ChatLocation : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    location : Location.t;
    address : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("location", Location.to_yojson v.location);
      ("address", `String v.address);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "location";
          let location = (match Location.of_yojson (List.assoc "location" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "location" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "address";
          let address = (to_string (List.assoc "address" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { location = location; address = address; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ReactionCount : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : ReactionType.t;
    total_count : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", ReactionType.to_yojson v.type_);
      ("total_count", `Intlit (Int64.to_string v.total_count));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (match ReactionType.of_yojson (List.assoc "type" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "type" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "total_count";
          let total_count = (match (List.assoc "total_count" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "total_count" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; total_count = total_count; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and MessageReactionUpdated : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    chat : Chat.t;
    message_id : int64;
    user : User.t option;
    actor_chat : Chat.t option;
    date : int64;
    old_reaction : ReactionType.t list;
    new_reaction : ReactionType.t list;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("chat", Chat.to_yojson v.chat);
      ("message_id", `Intlit (Int64.to_string v.message_id));
      (match v.user with None -> ("user", `Null) | Some x -> ("user", User.to_yojson x));
      (match v.actor_chat with None -> ("actor_chat", `Null) | Some x -> ("actor_chat", Chat.to_yojson x));
      ("date", `Intlit (Int64.to_string v.date));
      ("old_reaction", `List (List.map (fun x -> ReactionType.to_yojson x) v.old_reaction));
      ("new_reaction", `List (List.map (fun x -> ReactionType.to_yojson x) v.new_reaction));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat";
          let chat = (match Chat.of_yojson (List.assoc "chat" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "chat" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message_id";
          let message_id = (match (List.assoc "message_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "message_id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "user";
          let user = match List.assoc_opt "user" fields with None | Some `Null -> None | Some x -> Some ((match User.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "actor_chat";
          let actor_chat = match List.assoc_opt "actor_chat" fields with None | Some `Null -> None | Some x -> Some ((match Chat.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "date";
          let date = (match (List.assoc "date" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "date" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "old_reaction";
          let old_reaction = (List.map (fun x -> (match ReactionType.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list (List.assoc "old_reaction" fields))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "new_reaction";
          let new_reaction = (List.map (fun x -> (match ReactionType.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list (List.assoc "new_reaction" fields))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { chat = chat; message_id = message_id; user = user; actor_chat = actor_chat; date = date; old_reaction = old_reaction; new_reaction = new_reaction; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and UniqueGiftBackdrop : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    name : string;
    colors : UniqueGiftBackdropColors.t;
    rarity_per_mille : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("name", `String v.name);
      ("colors", UniqueGiftBackdropColors.to_yojson v.colors);
      ("rarity_per_mille", `Intlit (Int64.to_string v.rarity_per_mille));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "name";
          let name = (to_string (List.assoc "name" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "colors";
          let colors = (match UniqueGiftBackdropColors.of_yojson (List.assoc "colors" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "colors" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "rarity_per_mille";
          let rarity_per_mille = (match (List.assoc "rarity_per_mille" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "rarity_per_mille" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { name = name; colors = colors; rarity_per_mille = rarity_per_mille; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and MenuButtonWebApp : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    text : string;
    web_app : WebAppInfo.t;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("text", `String v.text);
      ("web_app", WebAppInfo.to_yojson v.web_app);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "text";
          let text = (to_string (List.assoc "text" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "web_app";
          let web_app = (match WebAppInfo.of_yojson (List.assoc "web_app" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "web_app" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; text = text; web_app = web_app; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ChatBoostSource : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    source : string;
    user : User.t;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("source", `String v.source);
      ("user", User.to_yojson v.user);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "source";
          let source = (to_string (List.assoc "source" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "user";
          let user = (match User.of_yojson (List.assoc "user" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "user" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { source = source; user = user; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ChatBoostSourcePremium : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    source : string;
    user : User.t;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("source", `String v.source);
      ("user", User.to_yojson v.user);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "source";
          let source = (to_string (List.assoc "source" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "user";
          let user = (match User.of_yojson (List.assoc "user" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "user" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { source = source; user = user; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ChatBoostSourceGiftCode : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    source : string;
    user : User.t;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("source", `String v.source);
      ("user", User.to_yojson v.user);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "source";
          let source = (to_string (List.assoc "source" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "user";
          let user = (match User.of_yojson (List.assoc "user" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "user" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { source = source; user = user; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ChatBoostSourceGiveaway : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    source : string;
    giveaway_message_id : int64;
    user : User.t option;
    prize_star_count : int64 option;
    is_unclaimed : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("source", `String v.source);
      ("giveaway_message_id", `Intlit (Int64.to_string v.giveaway_message_id));
      (match v.user with None -> ("user", `Null) | Some x -> ("user", User.to_yojson x));
      (match v.prize_star_count with None -> ("prize_star_count", `Null) | Some x -> ("prize_star_count", `Intlit (Int64.to_string x)));
      (match v.is_unclaimed with None -> ("is_unclaimed", `Null) | Some x -> ("is_unclaimed", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "source";
          let source = (to_string (List.assoc "source" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "giveaway_message_id";
          let giveaway_message_id = (match (List.assoc "giveaway_message_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "giveaway_message_id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "user";
          let user = match List.assoc_opt "user" fields with None | Some `Null -> None | Some x -> Some ((match User.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "prize_star_count";
          let prize_star_count = match List.assoc_opt "prize_star_count" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_unclaimed";
          let is_unclaimed = match List.assoc_opt "is_unclaimed" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { source = source; giveaway_message_id = giveaway_message_id; user = user; prize_star_count = prize_star_count; is_unclaimed = is_unclaimed; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and BusinessConnection : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    id : string;
    user : User.t;
    user_chat_id : int64;
    date : int64;
    rights : BusinessBotRights.t option;
    is_enabled : bool;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("id", `String v.id);
      ("user", User.to_yojson v.user);
      ("user_chat_id", `Intlit (Int64.to_string v.user_chat_id));
      ("date", `Intlit (Int64.to_string v.date));
      (match v.rights with None -> ("rights", `Null) | Some x -> ("rights", BusinessBotRights.to_yojson x));
      ("is_enabled", `Bool v.is_enabled);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "user";
          let user = (match User.of_yojson (List.assoc "user" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "user" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "user_chat_id";
          let user_chat_id = (match (List.assoc "user_chat_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "user_chat_id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "date";
          let date = (match (List.assoc "date" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "date" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "rights";
          let rights = match List.assoc_opt "rights" fields with None | Some `Null -> None | Some x -> Some ((match BusinessBotRights.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_enabled";
          let is_enabled = (to_bool (List.assoc "is_enabled" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { id = id; user = user; user_chat_id = user_chat_id; date = date; rights = rights; is_enabled = is_enabled; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and BusinessMessagesDeleted : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    business_connection_id : string;
    chat : Chat.t;
    message_ids : int64 list;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("business_connection_id", `String v.business_connection_id);
      ("chat", Chat.to_yojson v.chat);
      ("message_ids", `List (List.map (fun x -> `Intlit (Int64.to_string x)) v.message_ids));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "business_connection_id";
          let business_connection_id = (to_string (List.assoc "business_connection_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat";
          let chat = (match Chat.of_yojson (List.assoc "chat" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "chat" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message_ids";
          let message_ids = (List.map (fun x -> (match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) (to_list (List.assoc "message_ids" fields))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { business_connection_id = business_connection_id; chat = chat; message_ids = message_ids; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and Sticker : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    file_id : string;
    file_unique_id : string;
    type_ : string;
    width : int64;
    height : int64;
    is_animated : bool;
    is_video : bool;
    thumbnail : PhotoSize.t option;
    emoji : string option;
    set_name : string option;
    premium_animation : File.t option;
    mask_position : MaskPosition.t option;
    custom_emoji_id : string option;
    needs_repainting : bool option;
    file_size : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("file_id", `String v.file_id);
      ("file_unique_id", `String v.file_unique_id);
      ("type", `String v.type_);
      ("width", `Intlit (Int64.to_string v.width));
      ("height", `Intlit (Int64.to_string v.height));
      ("is_animated", `Bool v.is_animated);
      ("is_video", `Bool v.is_video);
      (match v.thumbnail with None -> ("thumbnail", `Null) | Some x -> ("thumbnail", PhotoSize.to_yojson x));
      (match v.emoji with None -> ("emoji", `Null) | Some x -> ("emoji", `String x));
      (match v.set_name with None -> ("set_name", `Null) | Some x -> ("set_name", `String x));
      (match v.premium_animation with None -> ("premium_animation", `Null) | Some x -> ("premium_animation", File.to_yojson x));
      (match v.mask_position with None -> ("mask_position", `Null) | Some x -> ("mask_position", MaskPosition.to_yojson x));
      (match v.custom_emoji_id with None -> ("custom_emoji_id", `Null) | Some x -> ("custom_emoji_id", `String x));
      (match v.needs_repainting with None -> ("needs_repainting", `Null) | Some x -> ("needs_repainting", `Bool x));
      (match v.file_size with None -> ("file_size", `Null) | Some x -> ("file_size", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_id";
          let file_id = (to_string (List.assoc "file_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_unique_id";
          let file_unique_id = (to_string (List.assoc "file_unique_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "width";
          let width = (match (List.assoc "width" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "width" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "height";
          let height = (match (List.assoc "height" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "height" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_animated";
          let is_animated = (to_bool (List.assoc "is_animated" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_video";
          let is_video = (to_bool (List.assoc "is_video" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail";
          let thumbnail = match List.assoc_opt "thumbnail" fields with None | Some `Null -> None | Some x -> Some ((match PhotoSize.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "emoji";
          let emoji = match List.assoc_opt "emoji" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "set_name";
          let set_name = match List.assoc_opt "set_name" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "premium_animation";
          let premium_animation = match List.assoc_opt "premium_animation" fields with None | Some `Null -> None | Some x -> Some ((match File.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "mask_position";
          let mask_position = match List.assoc_opt "mask_position" fields with None | Some `Null -> None | Some x -> Some ((match MaskPosition.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "custom_emoji_id";
          let custom_emoji_id = match List.assoc_opt "custom_emoji_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "needs_repainting";
          let needs_repainting = match List.assoc_opt "needs_repainting" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "file_size";
          let file_size = match List.assoc_opt "file_size" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { file_id = file_id; file_unique_id = file_unique_id; type_ = type_; width = width; height = height; is_animated = is_animated; is_video = is_video; thumbnail = thumbnail; emoji = emoji; set_name = set_name; premium_animation = premium_animation; mask_position = mask_position; custom_emoji_id = custom_emoji_id; needs_repainting = needs_repainting; file_size = file_size; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InputSticker : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    sticker : string;
    format : string;
    emoji_list : string list;
    mask_position : MaskPosition.t option;
    keywords : string list option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("sticker", `String v.sticker);
      ("format", `String v.format);
      ("emoji_list", `List (List.map (fun x -> `String x) v.emoji_list));
      (match v.mask_position with None -> ("mask_position", `Null) | Some x -> ("mask_position", MaskPosition.to_yojson x));
      (match v.keywords with None -> ("keywords", `Null) | Some x -> ("keywords", `List (List.map (fun x -> `String x) x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "sticker";
          let sticker = (to_string (List.assoc "sticker" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "format";
          let format = (to_string (List.assoc "format" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "emoji_list";
          let emoji_list = (List.map (fun x -> (to_string x)) (to_list (List.assoc "emoji_list" fields))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "mask_position";
          let mask_position = match List.assoc_opt "mask_position" fields with None | Some `Null -> None | Some x -> Some ((match MaskPosition.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "keywords";
          let keywords = match List.assoc_opt "keywords" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (to_string x)) (to_list x))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { sticker = sticker; format = format; emoji_list = emoji_list; mask_position = mask_position; keywords = keywords; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InlineQuery : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    id : string;
    from : User.t;
    query : string;
    offset : string;
    chat_type : string option;
    location : Location.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("id", `String v.id);
      ("from", User.to_yojson v.from);
      ("query", `String v.query);
      ("offset", `String v.offset);
      (match v.chat_type with None -> ("chat_type", `Null) | Some x -> ("chat_type", `String x));
      (match v.location with None -> ("location", `Null) | Some x -> ("location", Location.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "from";
          let from = (match User.of_yojson (List.assoc "from" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "from" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "query";
          let query = (to_string (List.assoc "query" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "offset";
          let offset = (to_string (List.assoc "offset" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_type";
          let chat_type = match List.assoc_opt "chat_type" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "location";
          let location = match List.assoc_opt "location" fields with None | Some `Null -> None | Some x -> Some ((match Location.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { id = id; from = from; query = query; offset = offset; chat_type = chat_type; location = location; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InlineQueryResultsButton : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    text : string;
    web_app : WebAppInfo.t option;
    start_parameter : string option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("text", `String v.text);
      (match v.web_app with None -> ("web_app", `Null) | Some x -> ("web_app", WebAppInfo.to_yojson x));
      (match v.start_parameter with None -> ("start_parameter", `Null) | Some x -> ("start_parameter", `String x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "text";
          let text = (to_string (List.assoc "text" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "web_app";
          let web_app = match List.assoc_opt "web_app" fields with None | Some `Null -> None | Some x -> Some ((match WebAppInfo.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "start_parameter";
          let start_parameter = match List.assoc_opt "start_parameter" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { text = text; web_app = web_app; start_parameter = start_parameter; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InputInvoiceMessageContent : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    title : string;
    description : string;
    payload : string;
    provider_token : string option;
    currency : string;
    prices : LabeledPrice.t list;
    max_tip_amount : int64 option;
    suggested_tip_amounts : int64 list option;
    provider_data : string option;
    photo_url : string option;
    photo_size : int64 option;
    photo_width : int64 option;
    photo_height : int64 option;
    need_name : bool option;
    need_phone_number : bool option;
    need_email : bool option;
    need_shipping_address : bool option;
    send_phone_number_to_provider : bool option;
    send_email_to_provider : bool option;
    is_flexible : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("title", `String v.title);
      ("description", `String v.description);
      ("payload", `String v.payload);
      (match v.provider_token with None -> ("provider_token", `Null) | Some x -> ("provider_token", `String x));
      ("currency", `String v.currency);
      ("prices", `List (List.map (fun x -> LabeledPrice.to_yojson x) v.prices));
      (match v.max_tip_amount with None -> ("max_tip_amount", `Null) | Some x -> ("max_tip_amount", `Intlit (Int64.to_string x)));
      (match v.suggested_tip_amounts with None -> ("suggested_tip_amounts", `Null) | Some x -> ("suggested_tip_amounts", `List (List.map (fun x -> `Intlit (Int64.to_string x)) x)));
      (match v.provider_data with None -> ("provider_data", `Null) | Some x -> ("provider_data", `String x));
      (match v.photo_url with None -> ("photo_url", `Null) | Some x -> ("photo_url", `String x));
      (match v.photo_size with None -> ("photo_size", `Null) | Some x -> ("photo_size", `Intlit (Int64.to_string x)));
      (match v.photo_width with None -> ("photo_width", `Null) | Some x -> ("photo_width", `Intlit (Int64.to_string x)));
      (match v.photo_height with None -> ("photo_height", `Null) | Some x -> ("photo_height", `Intlit (Int64.to_string x)));
      (match v.need_name with None -> ("need_name", `Null) | Some x -> ("need_name", `Bool x));
      (match v.need_phone_number with None -> ("need_phone_number", `Null) | Some x -> ("need_phone_number", `Bool x));
      (match v.need_email with None -> ("need_email", `Null) | Some x -> ("need_email", `Bool x));
      (match v.need_shipping_address with None -> ("need_shipping_address", `Null) | Some x -> ("need_shipping_address", `Bool x));
      (match v.send_phone_number_to_provider with None -> ("send_phone_number_to_provider", `Null) | Some x -> ("send_phone_number_to_provider", `Bool x));
      (match v.send_email_to_provider with None -> ("send_email_to_provider", `Null) | Some x -> ("send_email_to_provider", `Bool x));
      (match v.is_flexible with None -> ("is_flexible", `Null) | Some x -> ("is_flexible", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = (to_string (List.assoc "title" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "description";
          let description = (to_string (List.assoc "description" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "payload";
          let payload = (to_string (List.assoc "payload" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "provider_token";
          let provider_token = match List.assoc_opt "provider_token" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "currency";
          let currency = (to_string (List.assoc "currency" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "prices";
          let prices = (List.map (fun x -> (match LabeledPrice.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list (List.assoc "prices" fields))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "max_tip_amount";
          let max_tip_amount = match List.assoc_opt "max_tip_amount" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "suggested_tip_amounts";
          let suggested_tip_amounts = match List.assoc_opt "suggested_tip_amounts" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "provider_data";
          let provider_data = match List.assoc_opt "provider_data" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "photo_url";
          let photo_url = match List.assoc_opt "photo_url" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "photo_size";
          let photo_size = match List.assoc_opt "photo_size" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "photo_width";
          let photo_width = match List.assoc_opt "photo_width" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "photo_height";
          let photo_height = match List.assoc_opt "photo_height" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "need_name";
          let need_name = match List.assoc_opt "need_name" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "need_phone_number";
          let need_phone_number = match List.assoc_opt "need_phone_number" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "need_email";
          let need_email = match List.assoc_opt "need_email" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "need_shipping_address";
          let need_shipping_address = match List.assoc_opt "need_shipping_address" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "send_phone_number_to_provider";
          let send_phone_number_to_provider = match List.assoc_opt "send_phone_number_to_provider" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "send_email_to_provider";
          let send_email_to_provider = match List.assoc_opt "send_email_to_provider" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_flexible";
          let is_flexible = match List.assoc_opt "is_flexible" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { title = title; description = description; payload = payload; provider_token = provider_token; currency = currency; prices = prices; max_tip_amount = max_tip_amount; suggested_tip_amounts = suggested_tip_amounts; provider_data = provider_data; photo_url = photo_url; photo_size = photo_size; photo_width = photo_width; photo_height = photo_height; need_name = need_name; need_phone_number = need_phone_number; need_email = need_email; need_shipping_address = need_shipping_address; send_phone_number_to_provider = send_phone_number_to_provider; send_email_to_provider = send_email_to_provider; is_flexible = is_flexible; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ChosenInlineResult : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    result_id : string;
    from : User.t;
    location : Location.t option;
    inline_message_id : string option;
    query : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("result_id", `String v.result_id);
      ("from", User.to_yojson v.from);
      (match v.location with None -> ("location", `Null) | Some x -> ("location", Location.to_yojson x));
      (match v.inline_message_id with None -> ("inline_message_id", `Null) | Some x -> ("inline_message_id", `String x));
      ("query", `String v.query);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "result_id";
          let result_id = (to_string (List.assoc "result_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "from";
          let from = (match User.of_yojson (List.assoc "from" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "from" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "location";
          let location = match List.assoc_opt "location" fields with None | Some `Null -> None | Some x -> Some ((match Location.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "inline_message_id";
          let inline_message_id = match List.assoc_opt "inline_message_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "query";
          let query = (to_string (List.assoc "query" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { result_id = result_id; from = from; location = location; inline_message_id = inline_message_id; query = query; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and OrderInfo : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    name : string option;
    phone_number : string option;
    email : string option;
    shipping_address : ShippingAddress.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      (match v.name with None -> ("name", `Null) | Some x -> ("name", `String x));
      (match v.phone_number with None -> ("phone_number", `Null) | Some x -> ("phone_number", `String x));
      (match v.email with None -> ("email", `Null) | Some x -> ("email", `String x));
      (match v.shipping_address with None -> ("shipping_address", `Null) | Some x -> ("shipping_address", ShippingAddress.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "name";
          let name = match List.assoc_opt "name" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "phone_number";
          let phone_number = match List.assoc_opt "phone_number" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "email";
          let email = match List.assoc_opt "email" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "shipping_address";
          let shipping_address = match List.assoc_opt "shipping_address" fields with None | Some `Null -> None | Some x -> Some ((match ShippingAddress.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { name = name; phone_number = phone_number; email = email; shipping_address = shipping_address; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ShippingOption : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    id : string;
    title : string;
    prices : LabeledPrice.t list;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("id", `String v.id);
      ("title", `String v.title);
      ("prices", `List (List.map (fun x -> LabeledPrice.to_yojson x) v.prices));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = (to_string (List.assoc "title" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "prices";
          let prices = (List.map (fun x -> (match LabeledPrice.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list (List.assoc "prices" fields))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { id = id; title = title; prices = prices; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ShippingQuery : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    id : string;
    from : User.t;
    invoice_payload : string;
    shipping_address : ShippingAddress.t;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("id", `String v.id);
      ("from", User.to_yojson v.from);
      ("invoice_payload", `String v.invoice_payload);
      ("shipping_address", ShippingAddress.to_yojson v.shipping_address);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "from";
          let from = (match User.of_yojson (List.assoc "from" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "from" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "invoice_payload";
          let invoice_payload = (to_string (List.assoc "invoice_payload" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "shipping_address";
          let shipping_address = (match ShippingAddress.of_yojson (List.assoc "shipping_address" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "shipping_address" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { id = id; from = from; invoice_payload = invoice_payload; shipping_address = shipping_address; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and PaidMediaPurchased : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    from : User.t;
    paid_media_payload : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("from", User.to_yojson v.from);
      ("paid_media_payload", `String v.paid_media_payload);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "from";
          let from = (match User.of_yojson (List.assoc "from" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "from" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "paid_media_payload";
          let paid_media_payload = (to_string (List.assoc "paid_media_payload" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { from = from; paid_media_payload = paid_media_payload; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and AffiliateInfo : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    affiliate_user : User.t option;
    affiliate_chat : Chat.t option;
    commission_per_mille : int64;
    amount : int64;
    nanostar_amount : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      (match v.affiliate_user with None -> ("affiliate_user", `Null) | Some x -> ("affiliate_user", User.to_yojson x));
      (match v.affiliate_chat with None -> ("affiliate_chat", `Null) | Some x -> ("affiliate_chat", Chat.to_yojson x));
      ("commission_per_mille", `Intlit (Int64.to_string v.commission_per_mille));
      ("amount", `Intlit (Int64.to_string v.amount));
      (match v.nanostar_amount with None -> ("nanostar_amount", `Null) | Some x -> ("nanostar_amount", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "affiliate_user";
          let affiliate_user = match List.assoc_opt "affiliate_user" fields with None | Some `Null -> None | Some x -> Some ((match User.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "affiliate_chat";
          let affiliate_chat = match List.assoc_opt "affiliate_chat" fields with None | Some `Null -> None | Some x -> Some ((match Chat.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "commission_per_mille";
          let commission_per_mille = (match (List.assoc "commission_per_mille" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "commission_per_mille" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "amount";
          let amount = (match (List.assoc "amount" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "amount" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "nanostar_amount";
          let nanostar_amount = match List.assoc_opt "nanostar_amount" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { affiliate_user = affiliate_user; affiliate_chat = affiliate_chat; commission_per_mille = commission_per_mille; amount = amount; nanostar_amount = nanostar_amount; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and TransactionPartnerAffiliateProgram : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    sponsor_user : User.t option;
    commission_per_mille : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      (match v.sponsor_user with None -> ("sponsor_user", `Null) | Some x -> ("sponsor_user", User.to_yojson x));
      ("commission_per_mille", `Intlit (Int64.to_string v.commission_per_mille));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "sponsor_user";
          let sponsor_user = match List.assoc_opt "sponsor_user" fields with None | Some `Null -> None | Some x -> Some ((match User.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "commission_per_mille";
          let commission_per_mille = (match (List.assoc "commission_per_mille" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "commission_per_mille" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; sponsor_user = sponsor_user; commission_per_mille = commission_per_mille; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and TransactionPartnerFragment : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    withdrawal_state : RevenueWithdrawalState.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      (match v.withdrawal_state with None -> ("withdrawal_state", `Null) | Some x -> ("withdrawal_state", RevenueWithdrawalState.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "withdrawal_state";
          let withdrawal_state = match List.assoc_opt "withdrawal_state" fields with None | Some `Null -> None | Some x -> Some ((match RevenueWithdrawalState.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; withdrawal_state = withdrawal_state; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and EncryptedPassportElement : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    data : string option;
    phone_number : string option;
    email : string option;
    files : PassportFile.t list option;
    front_side : PassportFile.t option;
    reverse_side : PassportFile.t option;
    selfie : PassportFile.t option;
    translation : PassportFile.t list option;
    hash : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      (match v.data with None -> ("data", `Null) | Some x -> ("data", `String x));
      (match v.phone_number with None -> ("phone_number", `Null) | Some x -> ("phone_number", `String x));
      (match v.email with None -> ("email", `Null) | Some x -> ("email", `String x));
      (match v.files with None -> ("files", `Null) | Some x -> ("files", `List (List.map (fun x -> PassportFile.to_yojson x) x)));
      (match v.front_side with None -> ("front_side", `Null) | Some x -> ("front_side", PassportFile.to_yojson x));
      (match v.reverse_side with None -> ("reverse_side", `Null) | Some x -> ("reverse_side", PassportFile.to_yojson x));
      (match v.selfie with None -> ("selfie", `Null) | Some x -> ("selfie", PassportFile.to_yojson x));
      (match v.translation with None -> ("translation", `Null) | Some x -> ("translation", `List (List.map (fun x -> PassportFile.to_yojson x) x)));
      ("hash", `String v.hash);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "data";
          let data = match List.assoc_opt "data" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "phone_number";
          let phone_number = match List.assoc_opt "phone_number" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "email";
          let email = match List.assoc_opt "email" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "files";
          let files = match List.assoc_opt "files" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match PassportFile.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "front_side";
          let front_side = match List.assoc_opt "front_side" fields with None | Some `Null -> None | Some x -> Some ((match PassportFile.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "reverse_side";
          let reverse_side = match List.assoc_opt "reverse_side" fields with None | Some `Null -> None | Some x -> Some ((match PassportFile.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "selfie";
          let selfie = match List.assoc_opt "selfie" fields with None | Some `Null -> None | Some x -> Some ((match PassportFile.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "translation";
          let translation = match List.assoc_opt "translation" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match PassportFile.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "hash";
          let hash = (to_string (List.assoc "hash" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; data = data; phone_number = phone_number; email = email; files = files; front_side = front_side; reverse_side = reverse_side; selfie = selfie; translation = translation; hash = hash; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and GameHighScore : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    position : int64;
    user : User.t;
    score : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("position", `Intlit (Int64.to_string v.position));
      ("user", User.to_yojson v.user);
      ("score", `Intlit (Int64.to_string v.score));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "position";
          let position = (match (List.assoc "position" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "position" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "user";
          let user = (match User.of_yojson (List.assoc "user" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "user" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "score";
          let score = (match (List.assoc "score" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "score" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { position = position; user = user; score = score; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and TextQuote : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    text : string;
    entities : MessageEntity.t list option;
    position : int64;
    is_manual : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("text", `String v.text);
      (match v.entities with None -> ("entities", `Null) | Some x -> ("entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      ("position", `Intlit (Int64.to_string v.position));
      (match v.is_manual with None -> ("is_manual", `Null) | Some x -> ("is_manual", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "text";
          let text = (to_string (List.assoc "text" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "entities";
          let entities = match List.assoc_opt "entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "position";
          let position = (match (List.assoc "position" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "position" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_manual";
          let is_manual = match List.assoc_opt "is_manual" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { text = text; entities = entities; position = position; is_manual = is_manual; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ReplyParameters : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    message_id : int64;
    chat_id : string option;
    allow_sending_without_reply : bool option;
    quote : string option;
    quote_parse_mode : string option;
    quote_entities : MessageEntity.t list option;
    quote_position : int64 option;
    checklist_task_id : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("message_id", `Intlit (Int64.to_string v.message_id));
      (match v.chat_id with None -> ("chat_id", `Null) | Some x -> ("chat_id", `String x));
      (match v.allow_sending_without_reply with None -> ("allow_sending_without_reply", `Null) | Some x -> ("allow_sending_without_reply", `Bool x));
      (match v.quote with None -> ("quote", `Null) | Some x -> ("quote", `String x));
      (match v.quote_parse_mode with None -> ("quote_parse_mode", `Null) | Some x -> ("quote_parse_mode", `String x));
      (match v.quote_entities with None -> ("quote_entities", `Null) | Some x -> ("quote_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.quote_position with None -> ("quote_position", `Null) | Some x -> ("quote_position", `Intlit (Int64.to_string x)));
      (match v.checklist_task_id with None -> ("checklist_task_id", `Null) | Some x -> ("checklist_task_id", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "message_id";
          let message_id = (match (List.assoc "message_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "message_id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_id";
          let chat_id = match List.assoc_opt "chat_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "allow_sending_without_reply";
          let allow_sending_without_reply = match List.assoc_opt "allow_sending_without_reply" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "quote";
          let quote = match List.assoc_opt "quote" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "quote_parse_mode";
          let quote_parse_mode = match List.assoc_opt "quote_parse_mode" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "quote_entities";
          let quote_entities = match List.assoc_opt "quote_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "quote_position";
          let quote_position = match List.assoc_opt "quote_position" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "checklist_task_id";
          let checklist_task_id = match List.assoc_opt "checklist_task_id" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { message_id = message_id; chat_id = chat_id; allow_sending_without_reply = allow_sending_without_reply; quote = quote; quote_parse_mode = quote_parse_mode; quote_entities = quote_entities; quote_position = quote_position; checklist_task_id = checklist_task_id; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and PaidMediaVideo : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    video : Video.t;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("video", Video.to_yojson v.video);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "video";
          let video = (match Video.of_yojson (List.assoc "video" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "video" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; video = video; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and PollOption : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    text : string;
    text_entities : MessageEntity.t list option;
    voter_count : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("text", `String v.text);
      (match v.text_entities with None -> ("text_entities", `Null) | Some x -> ("text_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      ("voter_count", `Intlit (Int64.to_string v.voter_count));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "text";
          let text = (to_string (List.assoc "text" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "text_entities";
          let text_entities = match List.assoc_opt "text_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "voter_count";
          let voter_count = (match (List.assoc "voter_count" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "voter_count" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { text = text; text_entities = text_entities; voter_count = voter_count; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InputPollOption : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    text : string;
    text_parse_mode : string option;
    text_entities : MessageEntity.t list option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("text", `String v.text);
      (match v.text_parse_mode with None -> ("text_parse_mode", `Null) | Some x -> ("text_parse_mode", `String x));
      (match v.text_entities with None -> ("text_entities", `Null) | Some x -> ("text_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "text";
          let text = (to_string (List.assoc "text" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "text_parse_mode";
          let text_parse_mode = match List.assoc_opt "text_parse_mode" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "text_entities";
          let text_entities = match List.assoc_opt "text_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { text = text; text_parse_mode = text_parse_mode; text_entities = text_entities; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ChecklistTask : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    id : int64;
    text : string;
    text_entities : MessageEntity.t list option;
    completed_by_user : User.t option;
    completion_date : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("id", `Intlit (Int64.to_string v.id));
      ("text", `String v.text);
      (match v.text_entities with None -> ("text_entities", `Null) | Some x -> ("text_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.completed_by_user with None -> ("completed_by_user", `Null) | Some x -> ("completed_by_user", User.to_yojson x));
      (match v.completion_date with None -> ("completion_date", `Null) | Some x -> ("completion_date", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (match (List.assoc "id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "text";
          let text = (to_string (List.assoc "text" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "text_entities";
          let text_entities = match List.assoc_opt "text_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "completed_by_user";
          let completed_by_user = match List.assoc_opt "completed_by_user" fields with None | Some `Null -> None | Some x -> Some ((match User.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "completion_date";
          let completion_date = match List.assoc_opt "completion_date" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { id = id; text = text; text_entities = text_entities; completed_by_user = completed_by_user; completion_date = completion_date; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InputChecklistTask : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    id : int64;
    text : string;
    parse_mode : string option;
    text_entities : MessageEntity.t list option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("id", `Intlit (Int64.to_string v.id));
      ("text", `String v.text);
      (match v.parse_mode with None -> ("parse_mode", `Null) | Some x -> ("parse_mode", `String x));
      (match v.text_entities with None -> ("text_entities", `Null) | Some x -> ("text_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (match (List.assoc "id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "text";
          let text = (to_string (List.assoc "text" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "parse_mode";
          let parse_mode = match List.assoc_opt "parse_mode" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "text_entities";
          let text_entities = match List.assoc_opt "text_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { id = id; text = text; parse_mode = parse_mode; text_entities = text_entities; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and BackgroundTypeWallpaper : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    document : Document.t;
    dark_theme_dimming : int64;
    is_blurred : bool option;
    is_moving : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("document", Document.to_yojson v.document);
      ("dark_theme_dimming", `Intlit (Int64.to_string v.dark_theme_dimming));
      (match v.is_blurred with None -> ("is_blurred", `Null) | Some x -> ("is_blurred", `Bool x));
      (match v.is_moving with None -> ("is_moving", `Null) | Some x -> ("is_moving", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "document";
          let document = (match Document.of_yojson (List.assoc "document" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "document" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "dark_theme_dimming";
          let dark_theme_dimming = (match (List.assoc "dark_theme_dimming" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "dark_theme_dimming" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_blurred";
          let is_blurred = match List.assoc_opt "is_blurred" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_moving";
          let is_moving = match List.assoc_opt "is_moving" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; document = document; dark_theme_dimming = dark_theme_dimming; is_blurred = is_blurred; is_moving = is_moving; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and BackgroundTypePattern : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    document : Document.t;
    fill : BackgroundFill.t;
    intensity : int64;
    is_inverted : bool option;
    is_moving : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("document", Document.to_yojson v.document);
      ("fill", BackgroundFill.to_yojson v.fill);
      ("intensity", `Intlit (Int64.to_string v.intensity));
      (match v.is_inverted with None -> ("is_inverted", `Null) | Some x -> ("is_inverted", `Bool x));
      (match v.is_moving with None -> ("is_moving", `Null) | Some x -> ("is_moving", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "document";
          let document = (match Document.of_yojson (List.assoc "document" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "document" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "fill";
          let fill = (match BackgroundFill.of_yojson (List.assoc "fill" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "fill" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "intensity";
          let intensity = (match (List.assoc "intensity" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "intensity" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_inverted";
          let is_inverted = match List.assoc_opt "is_inverted" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_moving";
          let is_moving = match List.assoc_opt "is_moving" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; document = document; fill = fill; intensity = intensity; is_inverted = is_inverted; is_moving = is_moving; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ChatBackground : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : BackgroundType.t;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", BackgroundType.to_yojson v.type_);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (match BackgroundType.of_yojson (List.assoc "type" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "type" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and UsersShared : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    request_id : int64;
    users : SharedUser.t list;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("request_id", `Intlit (Int64.to_string v.request_id));
      ("users", `List (List.map (fun x -> SharedUser.to_yojson x) v.users));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "request_id";
          let request_id = (match (List.assoc "request_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "request_id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "users";
          let users = (List.map (fun x -> (match SharedUser.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list (List.assoc "users" fields))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { request_id = request_id; users = users; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and KeyboardButton : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    text : string;
    request_users : KeyboardButtonRequestUsers.t option;
    request_chat : KeyboardButtonRequestChat.t option;
    request_contact : bool option;
    request_location : bool option;
    request_poll : KeyboardButtonPollType.t option;
    web_app : WebAppInfo.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("text", `String v.text);
      (match v.request_users with None -> ("request_users", `Null) | Some x -> ("request_users", KeyboardButtonRequestUsers.to_yojson x));
      (match v.request_chat with None -> ("request_chat", `Null) | Some x -> ("request_chat", KeyboardButtonRequestChat.to_yojson x));
      (match v.request_contact with None -> ("request_contact", `Null) | Some x -> ("request_contact", `Bool x));
      (match v.request_location with None -> ("request_location", `Null) | Some x -> ("request_location", `Bool x));
      (match v.request_poll with None -> ("request_poll", `Null) | Some x -> ("request_poll", KeyboardButtonPollType.to_yojson x));
      (match v.web_app with None -> ("web_app", `Null) | Some x -> ("web_app", WebAppInfo.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "text";
          let text = (to_string (List.assoc "text" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "request_users";
          let request_users = match List.assoc_opt "request_users" fields with None | Some `Null -> None | Some x -> Some ((match KeyboardButtonRequestUsers.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "request_chat";
          let request_chat = match List.assoc_opt "request_chat" fields with None | Some `Null -> None | Some x -> Some ((match KeyboardButtonRequestChat.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "request_contact";
          let request_contact = match List.assoc_opt "request_contact" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "request_location";
          let request_location = match List.assoc_opt "request_location" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "request_poll";
          let request_poll = match List.assoc_opt "request_poll" fields with None | Some `Null -> None | Some x -> Some ((match KeyboardButtonPollType.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "web_app";
          let web_app = match List.assoc_opt "web_app" fields with None | Some `Null -> None | Some x -> Some ((match WebAppInfo.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { text = text; request_users = request_users; request_chat = request_chat; request_contact = request_contact; request_location = request_location; request_poll = request_poll; web_app = web_app; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InlineKeyboardMarkup : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    inline_keyboard : InlineKeyboardButton.t list list;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("inline_keyboard", `List (List.map (fun x -> `List (List.map (fun x -> InlineKeyboardButton.to_yojson x) x)) v.inline_keyboard));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "inline_keyboard";
          let inline_keyboard = (List.map (fun x -> (List.map (fun x -> (match InlineKeyboardButton.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) (to_list (List.assoc "inline_keyboard" fields))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { inline_keyboard = inline_keyboard; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and CallbackQuery : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    id : string;
    from : User.t;
    message : MaybeInaccessibleMessage.t option;
    inline_message_id : string option;
    chat_instance : string;
    data : string option;
    game_short_name : string option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("id", `String v.id);
      ("from", User.to_yojson v.from);
      (match v.message with None -> ("message", `Null) | Some x -> ("message", MaybeInaccessibleMessage.to_yojson x));
      (match v.inline_message_id with None -> ("inline_message_id", `Null) | Some x -> ("inline_message_id", `String x));
      ("chat_instance", `String v.chat_instance);
      (match v.data with None -> ("data", `Null) | Some x -> ("data", `String x));
      (match v.game_short_name with None -> ("game_short_name", `Null) | Some x -> ("game_short_name", `String x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "from";
          let from = (match User.of_yojson (List.assoc "from" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "from" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message";
          let message = match List.assoc_opt "message" fields with None | Some `Null -> None | Some x -> Some ((match MaybeInaccessibleMessage.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "inline_message_id";
          let inline_message_id = match List.assoc_opt "inline_message_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_instance";
          let chat_instance = (to_string (List.assoc "chat_instance" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "data";
          let data = match List.assoc_opt "data" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "game_short_name";
          let game_short_name = match List.assoc_opt "game_short_name" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { id = id; from = from; message = message; inline_message_id = inline_message_id; chat_instance = chat_instance; data = data; game_short_name = game_short_name; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ChatMemberUpdated : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    chat : Chat.t;
    from : User.t;
    date : int64;
    old_chat_member : ChatMember.t;
    new_chat_member : ChatMember.t;
    invite_link : ChatInviteLink.t option;
    via_join_request : bool option;
    via_chat_folder_invite_link : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("chat", Chat.to_yojson v.chat);
      ("from", User.to_yojson v.from);
      ("date", `Intlit (Int64.to_string v.date));
      ("old_chat_member", ChatMember.to_yojson v.old_chat_member);
      ("new_chat_member", ChatMember.to_yojson v.new_chat_member);
      (match v.invite_link with None -> ("invite_link", `Null) | Some x -> ("invite_link", ChatInviteLink.to_yojson x));
      (match v.via_join_request with None -> ("via_join_request", `Null) | Some x -> ("via_join_request", `Bool x));
      (match v.via_chat_folder_invite_link with None -> ("via_chat_folder_invite_link", `Null) | Some x -> ("via_chat_folder_invite_link", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat";
          let chat = (match Chat.of_yojson (List.assoc "chat" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "chat" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "from";
          let from = (match User.of_yojson (List.assoc "from" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "from" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "date";
          let date = (match (List.assoc "date" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "date" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "old_chat_member";
          let old_chat_member = (match ChatMember.of_yojson (List.assoc "old_chat_member" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "old_chat_member" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "new_chat_member";
          let new_chat_member = (match ChatMember.of_yojson (List.assoc "new_chat_member" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "new_chat_member" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "invite_link";
          let invite_link = match List.assoc_opt "invite_link" fields with None | Some `Null -> None | Some x -> Some ((match ChatInviteLink.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "via_join_request";
          let via_join_request = match List.assoc_opt "via_join_request" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "via_chat_folder_invite_link";
          let via_chat_folder_invite_link = match List.assoc_opt "via_chat_folder_invite_link" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { chat = chat; from = from; date = date; old_chat_member = old_chat_member; new_chat_member = new_chat_member; invite_link = invite_link; via_join_request = via_join_request; via_chat_folder_invite_link = via_chat_folder_invite_link; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ChatJoinRequest : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    chat : Chat.t;
    from : User.t;
    user_chat_id : int64;
    date : int64;
    bio : string option;
    invite_link : ChatInviteLink.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("chat", Chat.to_yojson v.chat);
      ("from", User.to_yojson v.from);
      ("user_chat_id", `Intlit (Int64.to_string v.user_chat_id));
      ("date", `Intlit (Int64.to_string v.date));
      (match v.bio with None -> ("bio", `Null) | Some x -> ("bio", `String x));
      (match v.invite_link with None -> ("invite_link", `Null) | Some x -> ("invite_link", ChatInviteLink.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat";
          let chat = (match Chat.of_yojson (List.assoc "chat" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "chat" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "from";
          let from = (match User.of_yojson (List.assoc "from" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "from" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "user_chat_id";
          let user_chat_id = (match (List.assoc "user_chat_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "user_chat_id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "date";
          let date = (match (List.assoc "date" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "date" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "bio";
          let bio = match List.assoc_opt "bio" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "invite_link";
          let invite_link = match List.assoc_opt "invite_link" fields with None | Some `Null -> None | Some x -> Some ((match ChatInviteLink.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { chat = chat; from = from; user_chat_id = user_chat_id; date = date; bio = bio; invite_link = invite_link; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and BusinessIntro : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    title : string option;
    message : string option;
    sticker : Sticker.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      (match v.title with None -> ("title", `Null) | Some x -> ("title", `String x));
      (match v.message with None -> ("message", `Null) | Some x -> ("message", `String x));
      (match v.sticker with None -> ("sticker", `Null) | Some x -> ("sticker", Sticker.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = match List.assoc_opt "title" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message";
          let message = match List.assoc_opt "message" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "sticker";
          let sticker = match List.assoc_opt "sticker" fields with None | Some `Null -> None | Some x -> Some ((match Sticker.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { title = title; message = message; sticker = sticker; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and StoryArea : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    position : StoryAreaPosition.t;
    type_ : StoryAreaType.t;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("position", StoryAreaPosition.to_yojson v.position);
      ("type", StoryAreaType.to_yojson v.type_);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "position";
          let position = (match StoryAreaPosition.of_yojson (List.assoc "position" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "position" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (match StoryAreaType.of_yojson (List.assoc "type" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "type" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { position = position; type_ = type_; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and MessageReactionCountUpdated : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    chat : Chat.t;
    message_id : int64;
    date : int64;
    reactions : ReactionCount.t list;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("chat", Chat.to_yojson v.chat);
      ("message_id", `Intlit (Int64.to_string v.message_id));
      ("date", `Intlit (Int64.to_string v.date));
      ("reactions", `List (List.map (fun x -> ReactionCount.to_yojson x) v.reactions));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat";
          let chat = (match Chat.of_yojson (List.assoc "chat" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "chat" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message_id";
          let message_id = (match (List.assoc "message_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "message_id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "date";
          let date = (match (List.assoc "date" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "date" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "reactions";
          let reactions = (List.map (fun x -> (match ReactionCount.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list (List.assoc "reactions" fields))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { chat = chat; message_id = message_id; date = date; reactions = reactions; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and Gift : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    id : string;
    sticker : Sticker.t;
    star_count : int64;
    upgrade_star_count : int64 option;
    total_count : int64 option;
    remaining_count : int64 option;
    publisher_chat : Chat.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("id", `String v.id);
      ("sticker", Sticker.to_yojson v.sticker);
      ("star_count", `Intlit (Int64.to_string v.star_count));
      (match v.upgrade_star_count with None -> ("upgrade_star_count", `Null) | Some x -> ("upgrade_star_count", `Intlit (Int64.to_string x)));
      (match v.total_count with None -> ("total_count", `Null) | Some x -> ("total_count", `Intlit (Int64.to_string x)));
      (match v.remaining_count with None -> ("remaining_count", `Null) | Some x -> ("remaining_count", `Intlit (Int64.to_string x)));
      (match v.publisher_chat with None -> ("publisher_chat", `Null) | Some x -> ("publisher_chat", Chat.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "sticker";
          let sticker = (match Sticker.of_yojson (List.assoc "sticker" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "sticker" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "star_count";
          let star_count = (match (List.assoc "star_count" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "star_count" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "upgrade_star_count";
          let upgrade_star_count = match List.assoc_opt "upgrade_star_count" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "total_count";
          let total_count = match List.assoc_opt "total_count" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "remaining_count";
          let remaining_count = match List.assoc_opt "remaining_count" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "publisher_chat";
          let publisher_chat = match List.assoc_opt "publisher_chat" fields with None | Some `Null -> None | Some x -> Some ((match Chat.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { id = id; sticker = sticker; star_count = star_count; upgrade_star_count = upgrade_star_count; total_count = total_count; remaining_count = remaining_count; publisher_chat = publisher_chat; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and UniqueGiftModel : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    name : string;
    sticker : Sticker.t;
    rarity_per_mille : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("name", `String v.name);
      ("sticker", Sticker.to_yojson v.sticker);
      ("rarity_per_mille", `Intlit (Int64.to_string v.rarity_per_mille));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "name";
          let name = (to_string (List.assoc "name" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "sticker";
          let sticker = (match Sticker.of_yojson (List.assoc "sticker" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "sticker" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "rarity_per_mille";
          let rarity_per_mille = (match (List.assoc "rarity_per_mille" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "rarity_per_mille" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { name = name; sticker = sticker; rarity_per_mille = rarity_per_mille; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and UniqueGiftSymbol : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    name : string;
    sticker : Sticker.t;
    rarity_per_mille : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("name", `String v.name);
      ("sticker", Sticker.to_yojson v.sticker);
      ("rarity_per_mille", `Intlit (Int64.to_string v.rarity_per_mille));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "name";
          let name = (to_string (List.assoc "name" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "sticker";
          let sticker = (match Sticker.of_yojson (List.assoc "sticker" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "sticker" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "rarity_per_mille";
          let rarity_per_mille = (match (List.assoc "rarity_per_mille" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "rarity_per_mille" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { name = name; sticker = sticker; rarity_per_mille = rarity_per_mille; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ChatBoost : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    boost_id : string;
    add_date : int64;
    expiration_date : int64;
    source : ChatBoostSource.t;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("boost_id", `String v.boost_id);
      ("add_date", `Intlit (Int64.to_string v.add_date));
      ("expiration_date", `Intlit (Int64.to_string v.expiration_date));
      ("source", ChatBoostSource.to_yojson v.source);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "boost_id";
          let boost_id = (to_string (List.assoc "boost_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "add_date";
          let add_date = (match (List.assoc "add_date" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "add_date" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "expiration_date";
          let expiration_date = (match (List.assoc "expiration_date" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "expiration_date" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "source";
          let source = (match ChatBoostSource.of_yojson (List.assoc "source" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "source" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { boost_id = boost_id; add_date = add_date; expiration_date = expiration_date; source = source; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ChatBoostRemoved : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    chat : Chat.t;
    boost_id : string;
    remove_date : int64;
    source : ChatBoostSource.t;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("chat", Chat.to_yojson v.chat);
      ("boost_id", `String v.boost_id);
      ("remove_date", `Intlit (Int64.to_string v.remove_date));
      ("source", ChatBoostSource.to_yojson v.source);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat";
          let chat = (match Chat.of_yojson (List.assoc "chat" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "chat" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "boost_id";
          let boost_id = (to_string (List.assoc "boost_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "remove_date";
          let remove_date = (match (List.assoc "remove_date" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "remove_date" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "source";
          let source = (match ChatBoostSource.of_yojson (List.assoc "source" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "source" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { chat = chat; boost_id = boost_id; remove_date = remove_date; source = source; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InputMedia : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    media : string;
    caption : string option;
    parse_mode : string option;
    caption_entities : MessageEntity.t list option;
    show_caption_above_media : bool option;
    has_spoiler : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("media", `String v.media);
      (match v.caption with None -> ("caption", `Null) | Some x -> ("caption", `String x));
      (match v.parse_mode with None -> ("parse_mode", `Null) | Some x -> ("parse_mode", `String x));
      (match v.caption_entities with None -> ("caption_entities", `Null) | Some x -> ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.show_caption_above_media with None -> ("show_caption_above_media", `Null) | Some x -> ("show_caption_above_media", `Bool x));
      (match v.has_spoiler with None -> ("has_spoiler", `Null) | Some x -> ("has_spoiler", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "media";
          let media = (to_string (List.assoc "media" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption";
          let caption = match List.assoc_opt "caption" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "parse_mode";
          let parse_mode = match List.assoc_opt "parse_mode" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption_entities";
          let caption_entities = match List.assoc_opt "caption_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "show_caption_above_media";
          let show_caption_above_media = match List.assoc_opt "show_caption_above_media" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "has_spoiler";
          let has_spoiler = match List.assoc_opt "has_spoiler" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; media = media; caption = caption; parse_mode = parse_mode; caption_entities = caption_entities; show_caption_above_media = show_caption_above_media; has_spoiler = has_spoiler; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InputMediaPhoto : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    media : string;
    caption : string option;
    parse_mode : string option;
    caption_entities : MessageEntity.t list option;
    show_caption_above_media : bool option;
    has_spoiler : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("media", `String v.media);
      (match v.caption with None -> ("caption", `Null) | Some x -> ("caption", `String x));
      (match v.parse_mode with None -> ("parse_mode", `Null) | Some x -> ("parse_mode", `String x));
      (match v.caption_entities with None -> ("caption_entities", `Null) | Some x -> ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.show_caption_above_media with None -> ("show_caption_above_media", `Null) | Some x -> ("show_caption_above_media", `Bool x));
      (match v.has_spoiler with None -> ("has_spoiler", `Null) | Some x -> ("has_spoiler", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "media";
          let media = (to_string (List.assoc "media" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption";
          let caption = match List.assoc_opt "caption" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "parse_mode";
          let parse_mode = match List.assoc_opt "parse_mode" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption_entities";
          let caption_entities = match List.assoc_opt "caption_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "show_caption_above_media";
          let show_caption_above_media = match List.assoc_opt "show_caption_above_media" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "has_spoiler";
          let has_spoiler = match List.assoc_opt "has_spoiler" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; media = media; caption = caption; parse_mode = parse_mode; caption_entities = caption_entities; show_caption_above_media = show_caption_above_media; has_spoiler = has_spoiler; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InputMediaVideo : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    media : string;
    thumbnail : string option;
    cover : string option;
    start_timestamp : int64 option;
    caption : string option;
    parse_mode : string option;
    caption_entities : MessageEntity.t list option;
    show_caption_above_media : bool option;
    width : int64 option;
    height : int64 option;
    duration : int64 option;
    supports_streaming : bool option;
    has_spoiler : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("media", `String v.media);
      (match v.thumbnail with None -> ("thumbnail", `Null) | Some x -> ("thumbnail", `String x));
      (match v.cover with None -> ("cover", `Null) | Some x -> ("cover", `String x));
      (match v.start_timestamp with None -> ("start_timestamp", `Null) | Some x -> ("start_timestamp", `Intlit (Int64.to_string x)));
      (match v.caption with None -> ("caption", `Null) | Some x -> ("caption", `String x));
      (match v.parse_mode with None -> ("parse_mode", `Null) | Some x -> ("parse_mode", `String x));
      (match v.caption_entities with None -> ("caption_entities", `Null) | Some x -> ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.show_caption_above_media with None -> ("show_caption_above_media", `Null) | Some x -> ("show_caption_above_media", `Bool x));
      (match v.width with None -> ("width", `Null) | Some x -> ("width", `Intlit (Int64.to_string x)));
      (match v.height with None -> ("height", `Null) | Some x -> ("height", `Intlit (Int64.to_string x)));
      (match v.duration with None -> ("duration", `Null) | Some x -> ("duration", `Intlit (Int64.to_string x)));
      (match v.supports_streaming with None -> ("supports_streaming", `Null) | Some x -> ("supports_streaming", `Bool x));
      (match v.has_spoiler with None -> ("has_spoiler", `Null) | Some x -> ("has_spoiler", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "media";
          let media = (to_string (List.assoc "media" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail";
          let thumbnail = match List.assoc_opt "thumbnail" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "cover";
          let cover = match List.assoc_opt "cover" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "start_timestamp";
          let start_timestamp = match List.assoc_opt "start_timestamp" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption";
          let caption = match List.assoc_opt "caption" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "parse_mode";
          let parse_mode = match List.assoc_opt "parse_mode" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption_entities";
          let caption_entities = match List.assoc_opt "caption_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "show_caption_above_media";
          let show_caption_above_media = match List.assoc_opt "show_caption_above_media" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "width";
          let width = match List.assoc_opt "width" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "height";
          let height = match List.assoc_opt "height" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "duration";
          let duration = match List.assoc_opt "duration" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "supports_streaming";
          let supports_streaming = match List.assoc_opt "supports_streaming" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "has_spoiler";
          let has_spoiler = match List.assoc_opt "has_spoiler" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; media = media; thumbnail = thumbnail; cover = cover; start_timestamp = start_timestamp; caption = caption; parse_mode = parse_mode; caption_entities = caption_entities; show_caption_above_media = show_caption_above_media; width = width; height = height; duration = duration; supports_streaming = supports_streaming; has_spoiler = has_spoiler; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InputMediaAnimation : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    media : string;
    thumbnail : string option;
    caption : string option;
    parse_mode : string option;
    caption_entities : MessageEntity.t list option;
    show_caption_above_media : bool option;
    width : int64 option;
    height : int64 option;
    duration : int64 option;
    has_spoiler : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("media", `String v.media);
      (match v.thumbnail with None -> ("thumbnail", `Null) | Some x -> ("thumbnail", `String x));
      (match v.caption with None -> ("caption", `Null) | Some x -> ("caption", `String x));
      (match v.parse_mode with None -> ("parse_mode", `Null) | Some x -> ("parse_mode", `String x));
      (match v.caption_entities with None -> ("caption_entities", `Null) | Some x -> ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.show_caption_above_media with None -> ("show_caption_above_media", `Null) | Some x -> ("show_caption_above_media", `Bool x));
      (match v.width with None -> ("width", `Null) | Some x -> ("width", `Intlit (Int64.to_string x)));
      (match v.height with None -> ("height", `Null) | Some x -> ("height", `Intlit (Int64.to_string x)));
      (match v.duration with None -> ("duration", `Null) | Some x -> ("duration", `Intlit (Int64.to_string x)));
      (match v.has_spoiler with None -> ("has_spoiler", `Null) | Some x -> ("has_spoiler", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "media";
          let media = (to_string (List.assoc "media" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail";
          let thumbnail = match List.assoc_opt "thumbnail" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption";
          let caption = match List.assoc_opt "caption" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "parse_mode";
          let parse_mode = match List.assoc_opt "parse_mode" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption_entities";
          let caption_entities = match List.assoc_opt "caption_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "show_caption_above_media";
          let show_caption_above_media = match List.assoc_opt "show_caption_above_media" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "width";
          let width = match List.assoc_opt "width" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "height";
          let height = match List.assoc_opt "height" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "duration";
          let duration = match List.assoc_opt "duration" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "has_spoiler";
          let has_spoiler = match List.assoc_opt "has_spoiler" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; media = media; thumbnail = thumbnail; caption = caption; parse_mode = parse_mode; caption_entities = caption_entities; show_caption_above_media = show_caption_above_media; width = width; height = height; duration = duration; has_spoiler = has_spoiler; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InputMediaAudio : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    media : string;
    thumbnail : string option;
    caption : string option;
    parse_mode : string option;
    caption_entities : MessageEntity.t list option;
    duration : int64 option;
    performer : string option;
    title : string option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("media", `String v.media);
      (match v.thumbnail with None -> ("thumbnail", `Null) | Some x -> ("thumbnail", `String x));
      (match v.caption with None -> ("caption", `Null) | Some x -> ("caption", `String x));
      (match v.parse_mode with None -> ("parse_mode", `Null) | Some x -> ("parse_mode", `String x));
      (match v.caption_entities with None -> ("caption_entities", `Null) | Some x -> ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.duration with None -> ("duration", `Null) | Some x -> ("duration", `Intlit (Int64.to_string x)));
      (match v.performer with None -> ("performer", `Null) | Some x -> ("performer", `String x));
      (match v.title with None -> ("title", `Null) | Some x -> ("title", `String x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "media";
          let media = (to_string (List.assoc "media" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail";
          let thumbnail = match List.assoc_opt "thumbnail" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption";
          let caption = match List.assoc_opt "caption" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "parse_mode";
          let parse_mode = match List.assoc_opt "parse_mode" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption_entities";
          let caption_entities = match List.assoc_opt "caption_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "duration";
          let duration = match List.assoc_opt "duration" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "performer";
          let performer = match List.assoc_opt "performer" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = match List.assoc_opt "title" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; media = media; thumbnail = thumbnail; caption = caption; parse_mode = parse_mode; caption_entities = caption_entities; duration = duration; performer = performer; title = title; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InputMediaDocument : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    media : string;
    thumbnail : string option;
    caption : string option;
    parse_mode : string option;
    caption_entities : MessageEntity.t list option;
    disable_content_type_detection : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("media", `String v.media);
      (match v.thumbnail with None -> ("thumbnail", `Null) | Some x -> ("thumbnail", `String x));
      (match v.caption with None -> ("caption", `Null) | Some x -> ("caption", `String x));
      (match v.parse_mode with None -> ("parse_mode", `Null) | Some x -> ("parse_mode", `String x));
      (match v.caption_entities with None -> ("caption_entities", `Null) | Some x -> ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.disable_content_type_detection with None -> ("disable_content_type_detection", `Null) | Some x -> ("disable_content_type_detection", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "media";
          let media = (to_string (List.assoc "media" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail";
          let thumbnail = match List.assoc_opt "thumbnail" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption";
          let caption = match List.assoc_opt "caption" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "parse_mode";
          let parse_mode = match List.assoc_opt "parse_mode" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption_entities";
          let caption_entities = match List.assoc_opt "caption_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "disable_content_type_detection";
          let disable_content_type_detection = match List.assoc_opt "disable_content_type_detection" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; media = media; thumbnail = thumbnail; caption = caption; parse_mode = parse_mode; caption_entities = caption_entities; disable_content_type_detection = disable_content_type_detection; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and StickerSet : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    name : string;
    title : string;
    sticker_type : string;
    stickers : Sticker.t list;
    thumbnail : PhotoSize.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("name", `String v.name);
      ("title", `String v.title);
      ("sticker_type", `String v.sticker_type);
      ("stickers", `List (List.map (fun x -> Sticker.to_yojson x) v.stickers));
      (match v.thumbnail with None -> ("thumbnail", `Null) | Some x -> ("thumbnail", PhotoSize.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "name";
          let name = (to_string (List.assoc "name" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = (to_string (List.assoc "title" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "sticker_type";
          let sticker_type = (to_string (List.assoc "sticker_type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "stickers";
          let stickers = (List.map (fun x -> (match Sticker.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list (List.assoc "stickers" fields))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail";
          let thumbnail = match List.assoc_opt "thumbnail" fields with None | Some `Null -> None | Some x -> Some ((match PhotoSize.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { name = name; title = title; sticker_type = sticker_type; stickers = stickers; thumbnail = thumbnail; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InputMessageContent : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    message_text : string;
    parse_mode : string option;
    entities : MessageEntity.t list option;
    link_preview_options : LinkPreviewOptions.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("message_text", `String v.message_text);
      (match v.parse_mode with None -> ("parse_mode", `Null) | Some x -> ("parse_mode", `String x));
      (match v.entities with None -> ("entities", `Null) | Some x -> ("entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.link_preview_options with None -> ("link_preview_options", `Null) | Some x -> ("link_preview_options", LinkPreviewOptions.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "message_text";
          let message_text = (to_string (List.assoc "message_text" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "parse_mode";
          let parse_mode = match List.assoc_opt "parse_mode" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "entities";
          let entities = match List.assoc_opt "entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "link_preview_options";
          let link_preview_options = match List.assoc_opt "link_preview_options" fields with None | Some `Null -> None | Some x -> Some ((match LinkPreviewOptions.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { message_text = message_text; parse_mode = parse_mode; entities = entities; link_preview_options = link_preview_options; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InputTextMessageContent : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    message_text : string;
    parse_mode : string option;
    entities : MessageEntity.t list option;
    link_preview_options : LinkPreviewOptions.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("message_text", `String v.message_text);
      (match v.parse_mode with None -> ("parse_mode", `Null) | Some x -> ("parse_mode", `String x));
      (match v.entities with None -> ("entities", `Null) | Some x -> ("entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.link_preview_options with None -> ("link_preview_options", `Null) | Some x -> ("link_preview_options", LinkPreviewOptions.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "message_text";
          let message_text = (to_string (List.assoc "message_text" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "parse_mode";
          let parse_mode = match List.assoc_opt "parse_mode" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "entities";
          let entities = match List.assoc_opt "entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "link_preview_options";
          let link_preview_options = match List.assoc_opt "link_preview_options" fields with None | Some `Null -> None | Some x -> Some ((match LinkPreviewOptions.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { message_text = message_text; parse_mode = parse_mode; entities = entities; link_preview_options = link_preview_options; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and SuccessfulPayment : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    currency : string;
    total_amount : int64;
    invoice_payload : string;
    subscription_expiration_date : int64 option;
    is_recurring : bool option;
    is_first_recurring : bool option;
    shipping_option_id : string option;
    order_info : OrderInfo.t option;
    telegram_payment_charge_id : string;
    provider_payment_charge_id : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("currency", `String v.currency);
      ("total_amount", `Intlit (Int64.to_string v.total_amount));
      ("invoice_payload", `String v.invoice_payload);
      (match v.subscription_expiration_date with None -> ("subscription_expiration_date", `Null) | Some x -> ("subscription_expiration_date", `Intlit (Int64.to_string x)));
      (match v.is_recurring with None -> ("is_recurring", `Null) | Some x -> ("is_recurring", `Bool x));
      (match v.is_first_recurring with None -> ("is_first_recurring", `Null) | Some x -> ("is_first_recurring", `Bool x));
      (match v.shipping_option_id with None -> ("shipping_option_id", `Null) | Some x -> ("shipping_option_id", `String x));
      (match v.order_info with None -> ("order_info", `Null) | Some x -> ("order_info", OrderInfo.to_yojson x));
      ("telegram_payment_charge_id", `String v.telegram_payment_charge_id);
      ("provider_payment_charge_id", `String v.provider_payment_charge_id);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "currency";
          let currency = (to_string (List.assoc "currency" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "total_amount";
          let total_amount = (match (List.assoc "total_amount" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "total_amount" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "invoice_payload";
          let invoice_payload = (to_string (List.assoc "invoice_payload" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "subscription_expiration_date";
          let subscription_expiration_date = match List.assoc_opt "subscription_expiration_date" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_recurring";
          let is_recurring = match List.assoc_opt "is_recurring" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_first_recurring";
          let is_first_recurring = match List.assoc_opt "is_first_recurring" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "shipping_option_id";
          let shipping_option_id = match List.assoc_opt "shipping_option_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "order_info";
          let order_info = match List.assoc_opt "order_info" fields with None | Some `Null -> None | Some x -> Some ((match OrderInfo.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "telegram_payment_charge_id";
          let telegram_payment_charge_id = (to_string (List.assoc "telegram_payment_charge_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "provider_payment_charge_id";
          let provider_payment_charge_id = (to_string (List.assoc "provider_payment_charge_id" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { currency = currency; total_amount = total_amount; invoice_payload = invoice_payload; subscription_expiration_date = subscription_expiration_date; is_recurring = is_recurring; is_first_recurring = is_first_recurring; shipping_option_id = shipping_option_id; order_info = order_info; telegram_payment_charge_id = telegram_payment_charge_id; provider_payment_charge_id = provider_payment_charge_id; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and PreCheckoutQuery : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    id : string;
    from : User.t;
    currency : string;
    total_amount : int64;
    invoice_payload : string;
    shipping_option_id : string option;
    order_info : OrderInfo.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("id", `String v.id);
      ("from", User.to_yojson v.from);
      ("currency", `String v.currency);
      ("total_amount", `Intlit (Int64.to_string v.total_amount));
      ("invoice_payload", `String v.invoice_payload);
      (match v.shipping_option_id with None -> ("shipping_option_id", `Null) | Some x -> ("shipping_option_id", `String x));
      (match v.order_info with None -> ("order_info", `Null) | Some x -> ("order_info", OrderInfo.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "from";
          let from = (match User.of_yojson (List.assoc "from" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "from" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "currency";
          let currency = (to_string (List.assoc "currency" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "total_amount";
          let total_amount = (match (List.assoc "total_amount" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "total_amount" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "invoice_payload";
          let invoice_payload = (to_string (List.assoc "invoice_payload" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "shipping_option_id";
          let shipping_option_id = match List.assoc_opt "shipping_option_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "order_info";
          let order_info = match List.assoc_opt "order_info" fields with None | Some `Null -> None | Some x -> Some ((match OrderInfo.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { id = id; from = from; currency = currency; total_amount = total_amount; invoice_payload = invoice_payload; shipping_option_id = shipping_option_id; order_info = order_info; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and PassportData : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    data : EncryptedPassportElement.t list;
    credentials : EncryptedCredentials.t;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("data", `List (List.map (fun x -> EncryptedPassportElement.to_yojson x) v.data));
      ("credentials", EncryptedCredentials.to_yojson v.credentials);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "data";
          let data = (List.map (fun x -> (match EncryptedPassportElement.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list (List.assoc "data" fields))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "credentials";
          let credentials = (match EncryptedCredentials.of_yojson (List.assoc "credentials" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "credentials" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { data = data; credentials = credentials; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and Game : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    title : string;
    description : string;
    photo : PhotoSize.t list;
    text : string option;
    text_entities : MessageEntity.t list option;
    animation : Animation.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("title", `String v.title);
      ("description", `String v.description);
      ("photo", `List (List.map (fun x -> PhotoSize.to_yojson x) v.photo));
      (match v.text with None -> ("text", `Null) | Some x -> ("text", `String x));
      (match v.text_entities with None -> ("text_entities", `Null) | Some x -> ("text_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.animation with None -> ("animation", `Null) | Some x -> ("animation", Animation.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = (to_string (List.assoc "title" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "description";
          let description = (to_string (List.assoc "description" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "photo";
          let photo = (List.map (fun x -> (match PhotoSize.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list (List.assoc "photo" fields))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "text";
          let text = match List.assoc_opt "text" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "text_entities";
          let text_entities = match List.assoc_opt "text_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "animation";
          let animation = match List.assoc_opt "animation" fields with None | Some `Null -> None | Some x -> Some ((match Animation.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { title = title; description = description; photo = photo; text = text; text_entities = text_entities; animation = animation; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and Poll : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    id : string;
    question : string;
    question_entities : MessageEntity.t list option;
    options : PollOption.t list;
    total_voter_count : int64;
    is_closed : bool;
    is_anonymous : bool;
    type_ : string;
    allows_multiple_answers : bool;
    correct_option_id : int64 option;
    explanation : string option;
    explanation_entities : MessageEntity.t list option;
    open_period : int64 option;
    close_date : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("id", `String v.id);
      ("question", `String v.question);
      (match v.question_entities with None -> ("question_entities", `Null) | Some x -> ("question_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      ("options", `List (List.map (fun x -> PollOption.to_yojson x) v.options));
      ("total_voter_count", `Intlit (Int64.to_string v.total_voter_count));
      ("is_closed", `Bool v.is_closed);
      ("is_anonymous", `Bool v.is_anonymous);
      ("type", `String v.type_);
      ("allows_multiple_answers", `Bool v.allows_multiple_answers);
      (match v.correct_option_id with None -> ("correct_option_id", `Null) | Some x -> ("correct_option_id", `Intlit (Int64.to_string x)));
      (match v.explanation with None -> ("explanation", `Null) | Some x -> ("explanation", `String x));
      (match v.explanation_entities with None -> ("explanation_entities", `Null) | Some x -> ("explanation_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.open_period with None -> ("open_period", `Null) | Some x -> ("open_period", `Intlit (Int64.to_string x)));
      (match v.close_date with None -> ("close_date", `Null) | Some x -> ("close_date", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "question";
          let question = (to_string (List.assoc "question" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "question_entities";
          let question_entities = match List.assoc_opt "question_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "options";
          let options = (List.map (fun x -> (match PollOption.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list (List.assoc "options" fields))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "total_voter_count";
          let total_voter_count = (match (List.assoc "total_voter_count" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "total_voter_count" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_closed";
          let is_closed = (to_bool (List.assoc "is_closed" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_anonymous";
          let is_anonymous = (to_bool (List.assoc "is_anonymous" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "allows_multiple_answers";
          let allows_multiple_answers = (to_bool (List.assoc "allows_multiple_answers" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "correct_option_id";
          let correct_option_id = match List.assoc_opt "correct_option_id" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "explanation";
          let explanation = match List.assoc_opt "explanation" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "explanation_entities";
          let explanation_entities = match List.assoc_opt "explanation_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "open_period";
          let open_period = match List.assoc_opt "open_period" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "close_date";
          let close_date = match List.assoc_opt "close_date" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { id = id; question = question; question_entities = question_entities; options = options; total_voter_count = total_voter_count; is_closed = is_closed; is_anonymous = is_anonymous; type_ = type_; allows_multiple_answers = allows_multiple_answers; correct_option_id = correct_option_id; explanation = explanation; explanation_entities = explanation_entities; open_period = open_period; close_date = close_date; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and Checklist : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    title : string;
    title_entities : MessageEntity.t list option;
    tasks : ChecklistTask.t list;
    others_can_add_tasks : bool option;
    others_can_mark_tasks_as_done : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("title", `String v.title);
      (match v.title_entities with None -> ("title_entities", `Null) | Some x -> ("title_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      ("tasks", `List (List.map (fun x -> ChecklistTask.to_yojson x) v.tasks));
      (match v.others_can_add_tasks with None -> ("others_can_add_tasks", `Null) | Some x -> ("others_can_add_tasks", `Bool x));
      (match v.others_can_mark_tasks_as_done with None -> ("others_can_mark_tasks_as_done", `Null) | Some x -> ("others_can_mark_tasks_as_done", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = (to_string (List.assoc "title" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "title_entities";
          let title_entities = match List.assoc_opt "title_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "tasks";
          let tasks = (List.map (fun x -> (match ChecklistTask.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list (List.assoc "tasks" fields))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "others_can_add_tasks";
          let others_can_add_tasks = match List.assoc_opt "others_can_add_tasks" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "others_can_mark_tasks_as_done";
          let others_can_mark_tasks_as_done = match List.assoc_opt "others_can_mark_tasks_as_done" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { title = title; title_entities = title_entities; tasks = tasks; others_can_add_tasks = others_can_add_tasks; others_can_mark_tasks_as_done = others_can_mark_tasks_as_done; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InputChecklist : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    title : string;
    parse_mode : string option;
    title_entities : MessageEntity.t list option;
    tasks : InputChecklistTask.t list;
    others_can_add_tasks : bool option;
    others_can_mark_tasks_as_done : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("title", `String v.title);
      (match v.parse_mode with None -> ("parse_mode", `Null) | Some x -> ("parse_mode", `String x));
      (match v.title_entities with None -> ("title_entities", `Null) | Some x -> ("title_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      ("tasks", `List (List.map (fun x -> InputChecklistTask.to_yojson x) v.tasks));
      (match v.others_can_add_tasks with None -> ("others_can_add_tasks", `Null) | Some x -> ("others_can_add_tasks", `Bool x));
      (match v.others_can_mark_tasks_as_done with None -> ("others_can_mark_tasks_as_done", `Null) | Some x -> ("others_can_mark_tasks_as_done", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = (to_string (List.assoc "title" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "parse_mode";
          let parse_mode = match List.assoc_opt "parse_mode" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "title_entities";
          let title_entities = match List.assoc_opt "title_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "tasks";
          let tasks = (List.map (fun x -> (match InputChecklistTask.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list (List.assoc "tasks" fields))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "others_can_add_tasks";
          let others_can_add_tasks = match List.assoc_opt "others_can_add_tasks" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "others_can_mark_tasks_as_done";
          let others_can_mark_tasks_as_done = match List.assoc_opt "others_can_mark_tasks_as_done" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { title = title; parse_mode = parse_mode; title_entities = title_entities; tasks = tasks; others_can_add_tasks = others_can_add_tasks; others_can_mark_tasks_as_done = others_can_mark_tasks_as_done; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ReplyKeyboardMarkup : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    keyboard : KeyboardButton.t list list;
    is_persistent : bool option;
    resize_keyboard : bool option;
    one_time_keyboard : bool option;
    input_field_placeholder : string option;
    selective : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("keyboard", `List (List.map (fun x -> `List (List.map (fun x -> KeyboardButton.to_yojson x) x)) v.keyboard));
      (match v.is_persistent with None -> ("is_persistent", `Null) | Some x -> ("is_persistent", `Bool x));
      (match v.resize_keyboard with None -> ("resize_keyboard", `Null) | Some x -> ("resize_keyboard", `Bool x));
      (match v.one_time_keyboard with None -> ("one_time_keyboard", `Null) | Some x -> ("one_time_keyboard", `Bool x));
      (match v.input_field_placeholder with None -> ("input_field_placeholder", `Null) | Some x -> ("input_field_placeholder", `String x));
      (match v.selective with None -> ("selective", `Null) | Some x -> ("selective", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "keyboard";
          let keyboard = (List.map (fun x -> (List.map (fun x -> (match KeyboardButton.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) (to_list (List.assoc "keyboard" fields))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_persistent";
          let is_persistent = match List.assoc_opt "is_persistent" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "resize_keyboard";
          let resize_keyboard = match List.assoc_opt "resize_keyboard" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "one_time_keyboard";
          let one_time_keyboard = match List.assoc_opt "one_time_keyboard" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "input_field_placeholder";
          let input_field_placeholder = match List.assoc_opt "input_field_placeholder" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "selective";
          let selective = match List.assoc_opt "selective" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { keyboard = keyboard; is_persistent = is_persistent; resize_keyboard = resize_keyboard; one_time_keyboard = one_time_keyboard; input_field_placeholder = input_field_placeholder; selective = selective; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and Gifts : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    gifts : Gift.t list;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("gifts", `List (List.map (fun x -> Gift.to_yojson x) v.gifts));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "gifts";
          let gifts = (List.map (fun x -> (match Gift.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list (List.assoc "gifts" fields))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { gifts = gifts; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and UniqueGift : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    base_name : string;
    name : string;
    number : int64;
    model : UniqueGiftModel.t;
    symbol : UniqueGiftSymbol.t;
    backdrop : UniqueGiftBackdrop.t;
    publisher_chat : Chat.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("base_name", `String v.base_name);
      ("name", `String v.name);
      ("number", `Intlit (Int64.to_string v.number));
      ("model", UniqueGiftModel.to_yojson v.model);
      ("symbol", UniqueGiftSymbol.to_yojson v.symbol);
      ("backdrop", UniqueGiftBackdrop.to_yojson v.backdrop);
      (match v.publisher_chat with None -> ("publisher_chat", `Null) | Some x -> ("publisher_chat", Chat.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "base_name";
          let base_name = (to_string (List.assoc "base_name" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "name";
          let name = (to_string (List.assoc "name" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "number";
          let number = (match (List.assoc "number" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "number" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "model";
          let model = (match UniqueGiftModel.of_yojson (List.assoc "model" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "model" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "symbol";
          let symbol = (match UniqueGiftSymbol.of_yojson (List.assoc "symbol" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "symbol" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "backdrop";
          let backdrop = (match UniqueGiftBackdrop.of_yojson (List.assoc "backdrop" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "backdrop" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "publisher_chat";
          let publisher_chat = match List.assoc_opt "publisher_chat" fields with None | Some `Null -> None | Some x -> Some ((match Chat.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { base_name = base_name; name = name; number = number; model = model; symbol = symbol; backdrop = backdrop; publisher_chat = publisher_chat; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and GiftInfo : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    gift : Gift.t;
    owned_gift_id : string option;
    convert_star_count : int64 option;
    prepaid_upgrade_star_count : int64 option;
    can_be_upgraded : bool option;
    text : string option;
    entities : MessageEntity.t list option;
    is_private : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("gift", Gift.to_yojson v.gift);
      (match v.owned_gift_id with None -> ("owned_gift_id", `Null) | Some x -> ("owned_gift_id", `String x));
      (match v.convert_star_count with None -> ("convert_star_count", `Null) | Some x -> ("convert_star_count", `Intlit (Int64.to_string x)));
      (match v.prepaid_upgrade_star_count with None -> ("prepaid_upgrade_star_count", `Null) | Some x -> ("prepaid_upgrade_star_count", `Intlit (Int64.to_string x)));
      (match v.can_be_upgraded with None -> ("can_be_upgraded", `Null) | Some x -> ("can_be_upgraded", `Bool x));
      (match v.text with None -> ("text", `Null) | Some x -> ("text", `String x));
      (match v.entities with None -> ("entities", `Null) | Some x -> ("entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.is_private with None -> ("is_private", `Null) | Some x -> ("is_private", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "gift";
          let gift = (match Gift.of_yojson (List.assoc "gift" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "gift" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "owned_gift_id";
          let owned_gift_id = match List.assoc_opt "owned_gift_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "convert_star_count";
          let convert_star_count = match List.assoc_opt "convert_star_count" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "prepaid_upgrade_star_count";
          let prepaid_upgrade_star_count = match List.assoc_opt "prepaid_upgrade_star_count" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_be_upgraded";
          let can_be_upgraded = match List.assoc_opt "can_be_upgraded" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "text";
          let text = match List.assoc_opt "text" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "entities";
          let entities = match List.assoc_opt "entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_private";
          let is_private = match List.assoc_opt "is_private" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { gift = gift; owned_gift_id = owned_gift_id; convert_star_count = convert_star_count; prepaid_upgrade_star_count = prepaid_upgrade_star_count; can_be_upgraded = can_be_upgraded; text = text; entities = entities; is_private = is_private; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and OwnedGift : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    gift : Gift.t;
    owned_gift_id : string option;
    sender_user : User.t option;
    send_date : int64;
    text : string option;
    entities : MessageEntity.t list option;
    is_private : bool option;
    is_saved : bool option;
    can_be_upgraded : bool option;
    was_refunded : bool option;
    convert_star_count : int64 option;
    prepaid_upgrade_star_count : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("gift", Gift.to_yojson v.gift);
      (match v.owned_gift_id with None -> ("owned_gift_id", `Null) | Some x -> ("owned_gift_id", `String x));
      (match v.sender_user with None -> ("sender_user", `Null) | Some x -> ("sender_user", User.to_yojson x));
      ("send_date", `Intlit (Int64.to_string v.send_date));
      (match v.text with None -> ("text", `Null) | Some x -> ("text", `String x));
      (match v.entities with None -> ("entities", `Null) | Some x -> ("entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.is_private with None -> ("is_private", `Null) | Some x -> ("is_private", `Bool x));
      (match v.is_saved with None -> ("is_saved", `Null) | Some x -> ("is_saved", `Bool x));
      (match v.can_be_upgraded with None -> ("can_be_upgraded", `Null) | Some x -> ("can_be_upgraded", `Bool x));
      (match v.was_refunded with None -> ("was_refunded", `Null) | Some x -> ("was_refunded", `Bool x));
      (match v.convert_star_count with None -> ("convert_star_count", `Null) | Some x -> ("convert_star_count", `Intlit (Int64.to_string x)));
      (match v.prepaid_upgrade_star_count with None -> ("prepaid_upgrade_star_count", `Null) | Some x -> ("prepaid_upgrade_star_count", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "gift";
          let gift = (match Gift.of_yojson (List.assoc "gift" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "gift" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "owned_gift_id";
          let owned_gift_id = match List.assoc_opt "owned_gift_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "sender_user";
          let sender_user = match List.assoc_opt "sender_user" fields with None | Some `Null -> None | Some x -> Some ((match User.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "send_date";
          let send_date = (match (List.assoc "send_date" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "send_date" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "text";
          let text = match List.assoc_opt "text" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "entities";
          let entities = match List.assoc_opt "entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_private";
          let is_private = match List.assoc_opt "is_private" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_saved";
          let is_saved = match List.assoc_opt "is_saved" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_be_upgraded";
          let can_be_upgraded = match List.assoc_opt "can_be_upgraded" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "was_refunded";
          let was_refunded = match List.assoc_opt "was_refunded" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "convert_star_count";
          let convert_star_count = match List.assoc_opt "convert_star_count" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "prepaid_upgrade_star_count";
          let prepaid_upgrade_star_count = match List.assoc_opt "prepaid_upgrade_star_count" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; gift = gift; owned_gift_id = owned_gift_id; sender_user = sender_user; send_date = send_date; text = text; entities = entities; is_private = is_private; is_saved = is_saved; can_be_upgraded = can_be_upgraded; was_refunded = was_refunded; convert_star_count = convert_star_count; prepaid_upgrade_star_count = prepaid_upgrade_star_count; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and OwnedGiftRegular : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    gift : Gift.t;
    owned_gift_id : string option;
    sender_user : User.t option;
    send_date : int64;
    text : string option;
    entities : MessageEntity.t list option;
    is_private : bool option;
    is_saved : bool option;
    can_be_upgraded : bool option;
    was_refunded : bool option;
    convert_star_count : int64 option;
    prepaid_upgrade_star_count : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("gift", Gift.to_yojson v.gift);
      (match v.owned_gift_id with None -> ("owned_gift_id", `Null) | Some x -> ("owned_gift_id", `String x));
      (match v.sender_user with None -> ("sender_user", `Null) | Some x -> ("sender_user", User.to_yojson x));
      ("send_date", `Intlit (Int64.to_string v.send_date));
      (match v.text with None -> ("text", `Null) | Some x -> ("text", `String x));
      (match v.entities with None -> ("entities", `Null) | Some x -> ("entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.is_private with None -> ("is_private", `Null) | Some x -> ("is_private", `Bool x));
      (match v.is_saved with None -> ("is_saved", `Null) | Some x -> ("is_saved", `Bool x));
      (match v.can_be_upgraded with None -> ("can_be_upgraded", `Null) | Some x -> ("can_be_upgraded", `Bool x));
      (match v.was_refunded with None -> ("was_refunded", `Null) | Some x -> ("was_refunded", `Bool x));
      (match v.convert_star_count with None -> ("convert_star_count", `Null) | Some x -> ("convert_star_count", `Intlit (Int64.to_string x)));
      (match v.prepaid_upgrade_star_count with None -> ("prepaid_upgrade_star_count", `Null) | Some x -> ("prepaid_upgrade_star_count", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "gift";
          let gift = (match Gift.of_yojson (List.assoc "gift" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "gift" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "owned_gift_id";
          let owned_gift_id = match List.assoc_opt "owned_gift_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "sender_user";
          let sender_user = match List.assoc_opt "sender_user" fields with None | Some `Null -> None | Some x -> Some ((match User.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "send_date";
          let send_date = (match (List.assoc "send_date" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "send_date" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "text";
          let text = match List.assoc_opt "text" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "entities";
          let entities = match List.assoc_opt "entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_private";
          let is_private = match List.assoc_opt "is_private" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_saved";
          let is_saved = match List.assoc_opt "is_saved" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_be_upgraded";
          let can_be_upgraded = match List.assoc_opt "can_be_upgraded" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "was_refunded";
          let was_refunded = match List.assoc_opt "was_refunded" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "convert_star_count";
          let convert_star_count = match List.assoc_opt "convert_star_count" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "prepaid_upgrade_star_count";
          let prepaid_upgrade_star_count = match List.assoc_opt "prepaid_upgrade_star_count" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; gift = gift; owned_gift_id = owned_gift_id; sender_user = sender_user; send_date = send_date; text = text; entities = entities; is_private = is_private; is_saved = is_saved; can_be_upgraded = can_be_upgraded; was_refunded = was_refunded; convert_star_count = convert_star_count; prepaid_upgrade_star_count = prepaid_upgrade_star_count; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ChatBoostUpdated : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    chat : Chat.t;
    boost : ChatBoost.t;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("chat", Chat.to_yojson v.chat);
      ("boost", ChatBoost.to_yojson v.boost);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat";
          let chat = (match Chat.of_yojson (List.assoc "chat" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "chat" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "boost";
          let boost = (match ChatBoost.of_yojson (List.assoc "boost" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "boost" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { chat = chat; boost = boost; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and UserChatBoosts : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    boosts : ChatBoost.t list;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("boosts", `List (List.map (fun x -> ChatBoost.to_yojson x) v.boosts));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "boosts";
          let boosts = (List.map (fun x -> (match ChatBoost.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list (List.assoc "boosts" fields))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { boosts = boosts; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InlineQueryResult : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    id : string;
    title : string;
    input_message_content : InputMessageContent.t;
    reply_markup : InlineKeyboardMarkup.t option;
    url : string option;
    description : string option;
    thumbnail_url : string option;
    thumbnail_width : int64 option;
    thumbnail_height : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("id", `String v.id);
      ("title", `String v.title);
      ("input_message_content", InputMessageContent.to_yojson v.input_message_content);
      (match v.reply_markup with None -> ("reply_markup", `Null) | Some x -> ("reply_markup", InlineKeyboardMarkup.to_yojson x));
      (match v.url with None -> ("url", `Null) | Some x -> ("url", `String x));
      (match v.description with None -> ("description", `Null) | Some x -> ("description", `String x));
      (match v.thumbnail_url with None -> ("thumbnail_url", `Null) | Some x -> ("thumbnail_url", `String x));
      (match v.thumbnail_width with None -> ("thumbnail_width", `Null) | Some x -> ("thumbnail_width", `Intlit (Int64.to_string x)));
      (match v.thumbnail_height with None -> ("thumbnail_height", `Null) | Some x -> ("thumbnail_height", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = (to_string (List.assoc "title" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "input_message_content";
          let input_message_content = (match InputMessageContent.of_yojson (List.assoc "input_message_content" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "input_message_content" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "reply_markup";
          let reply_markup = match List.assoc_opt "reply_markup" fields with None | Some `Null -> None | Some x -> Some ((match InlineKeyboardMarkup.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "url";
          let url = match List.assoc_opt "url" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "description";
          let description = match List.assoc_opt "description" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail_url";
          let thumbnail_url = match List.assoc_opt "thumbnail_url" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail_width";
          let thumbnail_width = match List.assoc_opt "thumbnail_width" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail_height";
          let thumbnail_height = match List.assoc_opt "thumbnail_height" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; id = id; title = title; input_message_content = input_message_content; reply_markup = reply_markup; url = url; description = description; thumbnail_url = thumbnail_url; thumbnail_width = thumbnail_width; thumbnail_height = thumbnail_height; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InlineQueryResultArticle : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    id : string;
    title : string;
    input_message_content : InputMessageContent.t;
    reply_markup : InlineKeyboardMarkup.t option;
    url : string option;
    description : string option;
    thumbnail_url : string option;
    thumbnail_width : int64 option;
    thumbnail_height : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("id", `String v.id);
      ("title", `String v.title);
      ("input_message_content", InputMessageContent.to_yojson v.input_message_content);
      (match v.reply_markup with None -> ("reply_markup", `Null) | Some x -> ("reply_markup", InlineKeyboardMarkup.to_yojson x));
      (match v.url with None -> ("url", `Null) | Some x -> ("url", `String x));
      (match v.description with None -> ("description", `Null) | Some x -> ("description", `String x));
      (match v.thumbnail_url with None -> ("thumbnail_url", `Null) | Some x -> ("thumbnail_url", `String x));
      (match v.thumbnail_width with None -> ("thumbnail_width", `Null) | Some x -> ("thumbnail_width", `Intlit (Int64.to_string x)));
      (match v.thumbnail_height with None -> ("thumbnail_height", `Null) | Some x -> ("thumbnail_height", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = (to_string (List.assoc "title" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "input_message_content";
          let input_message_content = (match InputMessageContent.of_yojson (List.assoc "input_message_content" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "input_message_content" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "reply_markup";
          let reply_markup = match List.assoc_opt "reply_markup" fields with None | Some `Null -> None | Some x -> Some ((match InlineKeyboardMarkup.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "url";
          let url = match List.assoc_opt "url" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "description";
          let description = match List.assoc_opt "description" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail_url";
          let thumbnail_url = match List.assoc_opt "thumbnail_url" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail_width";
          let thumbnail_width = match List.assoc_opt "thumbnail_width" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail_height";
          let thumbnail_height = match List.assoc_opt "thumbnail_height" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; id = id; title = title; input_message_content = input_message_content; reply_markup = reply_markup; url = url; description = description; thumbnail_url = thumbnail_url; thumbnail_width = thumbnail_width; thumbnail_height = thumbnail_height; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InlineQueryResultPhoto : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    id : string;
    photo_url : string;
    thumbnail_url : string;
    photo_width : int64 option;
    photo_height : int64 option;
    title : string option;
    description : string option;
    caption : string option;
    parse_mode : string option;
    caption_entities : MessageEntity.t list option;
    show_caption_above_media : bool option;
    reply_markup : InlineKeyboardMarkup.t option;
    input_message_content : InputMessageContent.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("id", `String v.id);
      ("photo_url", `String v.photo_url);
      ("thumbnail_url", `String v.thumbnail_url);
      (match v.photo_width with None -> ("photo_width", `Null) | Some x -> ("photo_width", `Intlit (Int64.to_string x)));
      (match v.photo_height with None -> ("photo_height", `Null) | Some x -> ("photo_height", `Intlit (Int64.to_string x)));
      (match v.title with None -> ("title", `Null) | Some x -> ("title", `String x));
      (match v.description with None -> ("description", `Null) | Some x -> ("description", `String x));
      (match v.caption with None -> ("caption", `Null) | Some x -> ("caption", `String x));
      (match v.parse_mode with None -> ("parse_mode", `Null) | Some x -> ("parse_mode", `String x));
      (match v.caption_entities with None -> ("caption_entities", `Null) | Some x -> ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.show_caption_above_media with None -> ("show_caption_above_media", `Null) | Some x -> ("show_caption_above_media", `Bool x));
      (match v.reply_markup with None -> ("reply_markup", `Null) | Some x -> ("reply_markup", InlineKeyboardMarkup.to_yojson x));
      (match v.input_message_content with None -> ("input_message_content", `Null) | Some x -> ("input_message_content", InputMessageContent.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "photo_url";
          let photo_url = (to_string (List.assoc "photo_url" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail_url";
          let thumbnail_url = (to_string (List.assoc "thumbnail_url" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "photo_width";
          let photo_width = match List.assoc_opt "photo_width" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "photo_height";
          let photo_height = match List.assoc_opt "photo_height" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = match List.assoc_opt "title" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "description";
          let description = match List.assoc_opt "description" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption";
          let caption = match List.assoc_opt "caption" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "parse_mode";
          let parse_mode = match List.assoc_opt "parse_mode" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption_entities";
          let caption_entities = match List.assoc_opt "caption_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "show_caption_above_media";
          let show_caption_above_media = match List.assoc_opt "show_caption_above_media" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "reply_markup";
          let reply_markup = match List.assoc_opt "reply_markup" fields with None | Some `Null -> None | Some x -> Some ((match InlineKeyboardMarkup.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "input_message_content";
          let input_message_content = match List.assoc_opt "input_message_content" fields with None | Some `Null -> None | Some x -> Some ((match InputMessageContent.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; id = id; photo_url = photo_url; thumbnail_url = thumbnail_url; photo_width = photo_width; photo_height = photo_height; title = title; description = description; caption = caption; parse_mode = parse_mode; caption_entities = caption_entities; show_caption_above_media = show_caption_above_media; reply_markup = reply_markup; input_message_content = input_message_content; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InlineQueryResultGif : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    id : string;
    gif_url : string;
    gif_width : int64 option;
    gif_height : int64 option;
    gif_duration : int64 option;
    thumbnail_url : string;
    thumbnail_mime_type : string option;
    title : string option;
    caption : string option;
    parse_mode : string option;
    caption_entities : MessageEntity.t list option;
    show_caption_above_media : bool option;
    reply_markup : InlineKeyboardMarkup.t option;
    input_message_content : InputMessageContent.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("id", `String v.id);
      ("gif_url", `String v.gif_url);
      (match v.gif_width with None -> ("gif_width", `Null) | Some x -> ("gif_width", `Intlit (Int64.to_string x)));
      (match v.gif_height with None -> ("gif_height", `Null) | Some x -> ("gif_height", `Intlit (Int64.to_string x)));
      (match v.gif_duration with None -> ("gif_duration", `Null) | Some x -> ("gif_duration", `Intlit (Int64.to_string x)));
      ("thumbnail_url", `String v.thumbnail_url);
      (match v.thumbnail_mime_type with None -> ("thumbnail_mime_type", `Null) | Some x -> ("thumbnail_mime_type", `String x));
      (match v.title with None -> ("title", `Null) | Some x -> ("title", `String x));
      (match v.caption with None -> ("caption", `Null) | Some x -> ("caption", `String x));
      (match v.parse_mode with None -> ("parse_mode", `Null) | Some x -> ("parse_mode", `String x));
      (match v.caption_entities with None -> ("caption_entities", `Null) | Some x -> ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.show_caption_above_media with None -> ("show_caption_above_media", `Null) | Some x -> ("show_caption_above_media", `Bool x));
      (match v.reply_markup with None -> ("reply_markup", `Null) | Some x -> ("reply_markup", InlineKeyboardMarkup.to_yojson x));
      (match v.input_message_content with None -> ("input_message_content", `Null) | Some x -> ("input_message_content", InputMessageContent.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "gif_url";
          let gif_url = (to_string (List.assoc "gif_url" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "gif_width";
          let gif_width = match List.assoc_opt "gif_width" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "gif_height";
          let gif_height = match List.assoc_opt "gif_height" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "gif_duration";
          let gif_duration = match List.assoc_opt "gif_duration" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail_url";
          let thumbnail_url = (to_string (List.assoc "thumbnail_url" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail_mime_type";
          let thumbnail_mime_type = match List.assoc_opt "thumbnail_mime_type" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = match List.assoc_opt "title" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption";
          let caption = match List.assoc_opt "caption" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "parse_mode";
          let parse_mode = match List.assoc_opt "parse_mode" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption_entities";
          let caption_entities = match List.assoc_opt "caption_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "show_caption_above_media";
          let show_caption_above_media = match List.assoc_opt "show_caption_above_media" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "reply_markup";
          let reply_markup = match List.assoc_opt "reply_markup" fields with None | Some `Null -> None | Some x -> Some ((match InlineKeyboardMarkup.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "input_message_content";
          let input_message_content = match List.assoc_opt "input_message_content" fields with None | Some `Null -> None | Some x -> Some ((match InputMessageContent.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; id = id; gif_url = gif_url; gif_width = gif_width; gif_height = gif_height; gif_duration = gif_duration; thumbnail_url = thumbnail_url; thumbnail_mime_type = thumbnail_mime_type; title = title; caption = caption; parse_mode = parse_mode; caption_entities = caption_entities; show_caption_above_media = show_caption_above_media; reply_markup = reply_markup; input_message_content = input_message_content; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InlineQueryResultMpeg4Gif : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    id : string;
    mpeg4_url : string;
    mpeg4_width : int64 option;
    mpeg4_height : int64 option;
    mpeg4_duration : int64 option;
    thumbnail_url : string;
    thumbnail_mime_type : string option;
    title : string option;
    caption : string option;
    parse_mode : string option;
    caption_entities : MessageEntity.t list option;
    show_caption_above_media : bool option;
    reply_markup : InlineKeyboardMarkup.t option;
    input_message_content : InputMessageContent.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("id", `String v.id);
      ("mpeg4_url", `String v.mpeg4_url);
      (match v.mpeg4_width with None -> ("mpeg4_width", `Null) | Some x -> ("mpeg4_width", `Intlit (Int64.to_string x)));
      (match v.mpeg4_height with None -> ("mpeg4_height", `Null) | Some x -> ("mpeg4_height", `Intlit (Int64.to_string x)));
      (match v.mpeg4_duration with None -> ("mpeg4_duration", `Null) | Some x -> ("mpeg4_duration", `Intlit (Int64.to_string x)));
      ("thumbnail_url", `String v.thumbnail_url);
      (match v.thumbnail_mime_type with None -> ("thumbnail_mime_type", `Null) | Some x -> ("thumbnail_mime_type", `String x));
      (match v.title with None -> ("title", `Null) | Some x -> ("title", `String x));
      (match v.caption with None -> ("caption", `Null) | Some x -> ("caption", `String x));
      (match v.parse_mode with None -> ("parse_mode", `Null) | Some x -> ("parse_mode", `String x));
      (match v.caption_entities with None -> ("caption_entities", `Null) | Some x -> ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.show_caption_above_media with None -> ("show_caption_above_media", `Null) | Some x -> ("show_caption_above_media", `Bool x));
      (match v.reply_markup with None -> ("reply_markup", `Null) | Some x -> ("reply_markup", InlineKeyboardMarkup.to_yojson x));
      (match v.input_message_content with None -> ("input_message_content", `Null) | Some x -> ("input_message_content", InputMessageContent.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "mpeg4_url";
          let mpeg4_url = (to_string (List.assoc "mpeg4_url" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "mpeg4_width";
          let mpeg4_width = match List.assoc_opt "mpeg4_width" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "mpeg4_height";
          let mpeg4_height = match List.assoc_opt "mpeg4_height" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "mpeg4_duration";
          let mpeg4_duration = match List.assoc_opt "mpeg4_duration" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail_url";
          let thumbnail_url = (to_string (List.assoc "thumbnail_url" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail_mime_type";
          let thumbnail_mime_type = match List.assoc_opt "thumbnail_mime_type" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = match List.assoc_opt "title" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption";
          let caption = match List.assoc_opt "caption" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "parse_mode";
          let parse_mode = match List.assoc_opt "parse_mode" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption_entities";
          let caption_entities = match List.assoc_opt "caption_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "show_caption_above_media";
          let show_caption_above_media = match List.assoc_opt "show_caption_above_media" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "reply_markup";
          let reply_markup = match List.assoc_opt "reply_markup" fields with None | Some `Null -> None | Some x -> Some ((match InlineKeyboardMarkup.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "input_message_content";
          let input_message_content = match List.assoc_opt "input_message_content" fields with None | Some `Null -> None | Some x -> Some ((match InputMessageContent.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; id = id; mpeg4_url = mpeg4_url; mpeg4_width = mpeg4_width; mpeg4_height = mpeg4_height; mpeg4_duration = mpeg4_duration; thumbnail_url = thumbnail_url; thumbnail_mime_type = thumbnail_mime_type; title = title; caption = caption; parse_mode = parse_mode; caption_entities = caption_entities; show_caption_above_media = show_caption_above_media; reply_markup = reply_markup; input_message_content = input_message_content; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InlineQueryResultVideo : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    id : string;
    video_url : string;
    mime_type : string;
    thumbnail_url : string;
    title : string;
    caption : string option;
    parse_mode : string option;
    caption_entities : MessageEntity.t list option;
    show_caption_above_media : bool option;
    video_width : int64 option;
    video_height : int64 option;
    video_duration : int64 option;
    description : string option;
    reply_markup : InlineKeyboardMarkup.t option;
    input_message_content : InputMessageContent.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("id", `String v.id);
      ("video_url", `String v.video_url);
      ("mime_type", `String v.mime_type);
      ("thumbnail_url", `String v.thumbnail_url);
      ("title", `String v.title);
      (match v.caption with None -> ("caption", `Null) | Some x -> ("caption", `String x));
      (match v.parse_mode with None -> ("parse_mode", `Null) | Some x -> ("parse_mode", `String x));
      (match v.caption_entities with None -> ("caption_entities", `Null) | Some x -> ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.show_caption_above_media with None -> ("show_caption_above_media", `Null) | Some x -> ("show_caption_above_media", `Bool x));
      (match v.video_width with None -> ("video_width", `Null) | Some x -> ("video_width", `Intlit (Int64.to_string x)));
      (match v.video_height with None -> ("video_height", `Null) | Some x -> ("video_height", `Intlit (Int64.to_string x)));
      (match v.video_duration with None -> ("video_duration", `Null) | Some x -> ("video_duration", `Intlit (Int64.to_string x)));
      (match v.description with None -> ("description", `Null) | Some x -> ("description", `String x));
      (match v.reply_markup with None -> ("reply_markup", `Null) | Some x -> ("reply_markup", InlineKeyboardMarkup.to_yojson x));
      (match v.input_message_content with None -> ("input_message_content", `Null) | Some x -> ("input_message_content", InputMessageContent.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "video_url";
          let video_url = (to_string (List.assoc "video_url" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "mime_type";
          let mime_type = (to_string (List.assoc "mime_type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail_url";
          let thumbnail_url = (to_string (List.assoc "thumbnail_url" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = (to_string (List.assoc "title" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption";
          let caption = match List.assoc_opt "caption" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "parse_mode";
          let parse_mode = match List.assoc_opt "parse_mode" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption_entities";
          let caption_entities = match List.assoc_opt "caption_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "show_caption_above_media";
          let show_caption_above_media = match List.assoc_opt "show_caption_above_media" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "video_width";
          let video_width = match List.assoc_opt "video_width" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "video_height";
          let video_height = match List.assoc_opt "video_height" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "video_duration";
          let video_duration = match List.assoc_opt "video_duration" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "description";
          let description = match List.assoc_opt "description" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "reply_markup";
          let reply_markup = match List.assoc_opt "reply_markup" fields with None | Some `Null -> None | Some x -> Some ((match InlineKeyboardMarkup.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "input_message_content";
          let input_message_content = match List.assoc_opt "input_message_content" fields with None | Some `Null -> None | Some x -> Some ((match InputMessageContent.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; id = id; video_url = video_url; mime_type = mime_type; thumbnail_url = thumbnail_url; title = title; caption = caption; parse_mode = parse_mode; caption_entities = caption_entities; show_caption_above_media = show_caption_above_media; video_width = video_width; video_height = video_height; video_duration = video_duration; description = description; reply_markup = reply_markup; input_message_content = input_message_content; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InlineQueryResultAudio : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    id : string;
    audio_url : string;
    title : string;
    caption : string option;
    parse_mode : string option;
    caption_entities : MessageEntity.t list option;
    performer : string option;
    audio_duration : int64 option;
    reply_markup : InlineKeyboardMarkup.t option;
    input_message_content : InputMessageContent.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("id", `String v.id);
      ("audio_url", `String v.audio_url);
      ("title", `String v.title);
      (match v.caption with None -> ("caption", `Null) | Some x -> ("caption", `String x));
      (match v.parse_mode with None -> ("parse_mode", `Null) | Some x -> ("parse_mode", `String x));
      (match v.caption_entities with None -> ("caption_entities", `Null) | Some x -> ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.performer with None -> ("performer", `Null) | Some x -> ("performer", `String x));
      (match v.audio_duration with None -> ("audio_duration", `Null) | Some x -> ("audio_duration", `Intlit (Int64.to_string x)));
      (match v.reply_markup with None -> ("reply_markup", `Null) | Some x -> ("reply_markup", InlineKeyboardMarkup.to_yojson x));
      (match v.input_message_content with None -> ("input_message_content", `Null) | Some x -> ("input_message_content", InputMessageContent.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "audio_url";
          let audio_url = (to_string (List.assoc "audio_url" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = (to_string (List.assoc "title" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption";
          let caption = match List.assoc_opt "caption" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "parse_mode";
          let parse_mode = match List.assoc_opt "parse_mode" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption_entities";
          let caption_entities = match List.assoc_opt "caption_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "performer";
          let performer = match List.assoc_opt "performer" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "audio_duration";
          let audio_duration = match List.assoc_opt "audio_duration" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "reply_markup";
          let reply_markup = match List.assoc_opt "reply_markup" fields with None | Some `Null -> None | Some x -> Some ((match InlineKeyboardMarkup.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "input_message_content";
          let input_message_content = match List.assoc_opt "input_message_content" fields with None | Some `Null -> None | Some x -> Some ((match InputMessageContent.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; id = id; audio_url = audio_url; title = title; caption = caption; parse_mode = parse_mode; caption_entities = caption_entities; performer = performer; audio_duration = audio_duration; reply_markup = reply_markup; input_message_content = input_message_content; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InlineQueryResultVoice : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    id : string;
    voice_url : string;
    title : string;
    caption : string option;
    parse_mode : string option;
    caption_entities : MessageEntity.t list option;
    voice_duration : int64 option;
    reply_markup : InlineKeyboardMarkup.t option;
    input_message_content : InputMessageContent.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("id", `String v.id);
      ("voice_url", `String v.voice_url);
      ("title", `String v.title);
      (match v.caption with None -> ("caption", `Null) | Some x -> ("caption", `String x));
      (match v.parse_mode with None -> ("parse_mode", `Null) | Some x -> ("parse_mode", `String x));
      (match v.caption_entities with None -> ("caption_entities", `Null) | Some x -> ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.voice_duration with None -> ("voice_duration", `Null) | Some x -> ("voice_duration", `Intlit (Int64.to_string x)));
      (match v.reply_markup with None -> ("reply_markup", `Null) | Some x -> ("reply_markup", InlineKeyboardMarkup.to_yojson x));
      (match v.input_message_content with None -> ("input_message_content", `Null) | Some x -> ("input_message_content", InputMessageContent.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "voice_url";
          let voice_url = (to_string (List.assoc "voice_url" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = (to_string (List.assoc "title" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption";
          let caption = match List.assoc_opt "caption" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "parse_mode";
          let parse_mode = match List.assoc_opt "parse_mode" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption_entities";
          let caption_entities = match List.assoc_opt "caption_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "voice_duration";
          let voice_duration = match List.assoc_opt "voice_duration" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "reply_markup";
          let reply_markup = match List.assoc_opt "reply_markup" fields with None | Some `Null -> None | Some x -> Some ((match InlineKeyboardMarkup.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "input_message_content";
          let input_message_content = match List.assoc_opt "input_message_content" fields with None | Some `Null -> None | Some x -> Some ((match InputMessageContent.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; id = id; voice_url = voice_url; title = title; caption = caption; parse_mode = parse_mode; caption_entities = caption_entities; voice_duration = voice_duration; reply_markup = reply_markup; input_message_content = input_message_content; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InlineQueryResultDocument : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    id : string;
    title : string;
    caption : string option;
    parse_mode : string option;
    caption_entities : MessageEntity.t list option;
    document_url : string;
    mime_type : string;
    description : string option;
    reply_markup : InlineKeyboardMarkup.t option;
    input_message_content : InputMessageContent.t option;
    thumbnail_url : string option;
    thumbnail_width : int64 option;
    thumbnail_height : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("id", `String v.id);
      ("title", `String v.title);
      (match v.caption with None -> ("caption", `Null) | Some x -> ("caption", `String x));
      (match v.parse_mode with None -> ("parse_mode", `Null) | Some x -> ("parse_mode", `String x));
      (match v.caption_entities with None -> ("caption_entities", `Null) | Some x -> ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      ("document_url", `String v.document_url);
      ("mime_type", `String v.mime_type);
      (match v.description with None -> ("description", `Null) | Some x -> ("description", `String x));
      (match v.reply_markup with None -> ("reply_markup", `Null) | Some x -> ("reply_markup", InlineKeyboardMarkup.to_yojson x));
      (match v.input_message_content with None -> ("input_message_content", `Null) | Some x -> ("input_message_content", InputMessageContent.to_yojson x));
      (match v.thumbnail_url with None -> ("thumbnail_url", `Null) | Some x -> ("thumbnail_url", `String x));
      (match v.thumbnail_width with None -> ("thumbnail_width", `Null) | Some x -> ("thumbnail_width", `Intlit (Int64.to_string x)));
      (match v.thumbnail_height with None -> ("thumbnail_height", `Null) | Some x -> ("thumbnail_height", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = (to_string (List.assoc "title" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption";
          let caption = match List.assoc_opt "caption" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "parse_mode";
          let parse_mode = match List.assoc_opt "parse_mode" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption_entities";
          let caption_entities = match List.assoc_opt "caption_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "document_url";
          let document_url = (to_string (List.assoc "document_url" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "mime_type";
          let mime_type = (to_string (List.assoc "mime_type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "description";
          let description = match List.assoc_opt "description" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "reply_markup";
          let reply_markup = match List.assoc_opt "reply_markup" fields with None | Some `Null -> None | Some x -> Some ((match InlineKeyboardMarkup.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "input_message_content";
          let input_message_content = match List.assoc_opt "input_message_content" fields with None | Some `Null -> None | Some x -> Some ((match InputMessageContent.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail_url";
          let thumbnail_url = match List.assoc_opt "thumbnail_url" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail_width";
          let thumbnail_width = match List.assoc_opt "thumbnail_width" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail_height";
          let thumbnail_height = match List.assoc_opt "thumbnail_height" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; id = id; title = title; caption = caption; parse_mode = parse_mode; caption_entities = caption_entities; document_url = document_url; mime_type = mime_type; description = description; reply_markup = reply_markup; input_message_content = input_message_content; thumbnail_url = thumbnail_url; thumbnail_width = thumbnail_width; thumbnail_height = thumbnail_height; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InlineQueryResultLocation : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    id : string;
    latitude : float;
    longitude : float;
    title : string;
    horizontal_accuracy : float option;
    live_period : int64 option;
    heading : int64 option;
    proximity_alert_radius : int64 option;
    reply_markup : InlineKeyboardMarkup.t option;
    input_message_content : InputMessageContent.t option;
    thumbnail_url : string option;
    thumbnail_width : int64 option;
    thumbnail_height : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("id", `String v.id);
      ("latitude", `Float v.latitude);
      ("longitude", `Float v.longitude);
      ("title", `String v.title);
      (match v.horizontal_accuracy with None -> ("horizontal_accuracy", `Null) | Some x -> ("horizontal_accuracy", `Float x));
      (match v.live_period with None -> ("live_period", `Null) | Some x -> ("live_period", `Intlit (Int64.to_string x)));
      (match v.heading with None -> ("heading", `Null) | Some x -> ("heading", `Intlit (Int64.to_string x)));
      (match v.proximity_alert_radius with None -> ("proximity_alert_radius", `Null) | Some x -> ("proximity_alert_radius", `Intlit (Int64.to_string x)));
      (match v.reply_markup with None -> ("reply_markup", `Null) | Some x -> ("reply_markup", InlineKeyboardMarkup.to_yojson x));
      (match v.input_message_content with None -> ("input_message_content", `Null) | Some x -> ("input_message_content", InputMessageContent.to_yojson x));
      (match v.thumbnail_url with None -> ("thumbnail_url", `Null) | Some x -> ("thumbnail_url", `String x));
      (match v.thumbnail_width with None -> ("thumbnail_width", `Null) | Some x -> ("thumbnail_width", `Intlit (Int64.to_string x)));
      (match v.thumbnail_height with None -> ("thumbnail_height", `Null) | Some x -> ("thumbnail_height", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "latitude";
          let latitude = (to_float (List.assoc "latitude" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "longitude";
          let longitude = (to_float (List.assoc "longitude" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = (to_string (List.assoc "title" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "horizontal_accuracy";
          let horizontal_accuracy = match List.assoc_opt "horizontal_accuracy" fields with None | Some `Null -> None | Some x -> Some ((to_float x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "live_period";
          let live_period = match List.assoc_opt "live_period" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "heading";
          let heading = match List.assoc_opt "heading" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "proximity_alert_radius";
          let proximity_alert_radius = match List.assoc_opt "proximity_alert_radius" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "reply_markup";
          let reply_markup = match List.assoc_opt "reply_markup" fields with None | Some `Null -> None | Some x -> Some ((match InlineKeyboardMarkup.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "input_message_content";
          let input_message_content = match List.assoc_opt "input_message_content" fields with None | Some `Null -> None | Some x -> Some ((match InputMessageContent.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail_url";
          let thumbnail_url = match List.assoc_opt "thumbnail_url" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail_width";
          let thumbnail_width = match List.assoc_opt "thumbnail_width" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail_height";
          let thumbnail_height = match List.assoc_opt "thumbnail_height" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; id = id; latitude = latitude; longitude = longitude; title = title; horizontal_accuracy = horizontal_accuracy; live_period = live_period; heading = heading; proximity_alert_radius = proximity_alert_radius; reply_markup = reply_markup; input_message_content = input_message_content; thumbnail_url = thumbnail_url; thumbnail_width = thumbnail_width; thumbnail_height = thumbnail_height; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InlineQueryResultVenue : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    id : string;
    latitude : float;
    longitude : float;
    title : string;
    address : string;
    foursquare_id : string option;
    foursquare_type : string option;
    google_place_id : string option;
    google_place_type : string option;
    reply_markup : InlineKeyboardMarkup.t option;
    input_message_content : InputMessageContent.t option;
    thumbnail_url : string option;
    thumbnail_width : int64 option;
    thumbnail_height : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("id", `String v.id);
      ("latitude", `Float v.latitude);
      ("longitude", `Float v.longitude);
      ("title", `String v.title);
      ("address", `String v.address);
      (match v.foursquare_id with None -> ("foursquare_id", `Null) | Some x -> ("foursquare_id", `String x));
      (match v.foursquare_type with None -> ("foursquare_type", `Null) | Some x -> ("foursquare_type", `String x));
      (match v.google_place_id with None -> ("google_place_id", `Null) | Some x -> ("google_place_id", `String x));
      (match v.google_place_type with None -> ("google_place_type", `Null) | Some x -> ("google_place_type", `String x));
      (match v.reply_markup with None -> ("reply_markup", `Null) | Some x -> ("reply_markup", InlineKeyboardMarkup.to_yojson x));
      (match v.input_message_content with None -> ("input_message_content", `Null) | Some x -> ("input_message_content", InputMessageContent.to_yojson x));
      (match v.thumbnail_url with None -> ("thumbnail_url", `Null) | Some x -> ("thumbnail_url", `String x));
      (match v.thumbnail_width with None -> ("thumbnail_width", `Null) | Some x -> ("thumbnail_width", `Intlit (Int64.to_string x)));
      (match v.thumbnail_height with None -> ("thumbnail_height", `Null) | Some x -> ("thumbnail_height", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "latitude";
          let latitude = (to_float (List.assoc "latitude" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "longitude";
          let longitude = (to_float (List.assoc "longitude" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = (to_string (List.assoc "title" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "address";
          let address = (to_string (List.assoc "address" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "foursquare_id";
          let foursquare_id = match List.assoc_opt "foursquare_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "foursquare_type";
          let foursquare_type = match List.assoc_opt "foursquare_type" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "google_place_id";
          let google_place_id = match List.assoc_opt "google_place_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "google_place_type";
          let google_place_type = match List.assoc_opt "google_place_type" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "reply_markup";
          let reply_markup = match List.assoc_opt "reply_markup" fields with None | Some `Null -> None | Some x -> Some ((match InlineKeyboardMarkup.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "input_message_content";
          let input_message_content = match List.assoc_opt "input_message_content" fields with None | Some `Null -> None | Some x -> Some ((match InputMessageContent.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail_url";
          let thumbnail_url = match List.assoc_opt "thumbnail_url" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail_width";
          let thumbnail_width = match List.assoc_opt "thumbnail_width" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail_height";
          let thumbnail_height = match List.assoc_opt "thumbnail_height" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; id = id; latitude = latitude; longitude = longitude; title = title; address = address; foursquare_id = foursquare_id; foursquare_type = foursquare_type; google_place_id = google_place_id; google_place_type = google_place_type; reply_markup = reply_markup; input_message_content = input_message_content; thumbnail_url = thumbnail_url; thumbnail_width = thumbnail_width; thumbnail_height = thumbnail_height; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InlineQueryResultContact : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    id : string;
    phone_number : string;
    first_name : string;
    last_name : string option;
    vcard : string option;
    reply_markup : InlineKeyboardMarkup.t option;
    input_message_content : InputMessageContent.t option;
    thumbnail_url : string option;
    thumbnail_width : int64 option;
    thumbnail_height : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("id", `String v.id);
      ("phone_number", `String v.phone_number);
      ("first_name", `String v.first_name);
      (match v.last_name with None -> ("last_name", `Null) | Some x -> ("last_name", `String x));
      (match v.vcard with None -> ("vcard", `Null) | Some x -> ("vcard", `String x));
      (match v.reply_markup with None -> ("reply_markup", `Null) | Some x -> ("reply_markup", InlineKeyboardMarkup.to_yojson x));
      (match v.input_message_content with None -> ("input_message_content", `Null) | Some x -> ("input_message_content", InputMessageContent.to_yojson x));
      (match v.thumbnail_url with None -> ("thumbnail_url", `Null) | Some x -> ("thumbnail_url", `String x));
      (match v.thumbnail_width with None -> ("thumbnail_width", `Null) | Some x -> ("thumbnail_width", `Intlit (Int64.to_string x)));
      (match v.thumbnail_height with None -> ("thumbnail_height", `Null) | Some x -> ("thumbnail_height", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "phone_number";
          let phone_number = (to_string (List.assoc "phone_number" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "first_name";
          let first_name = (to_string (List.assoc "first_name" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "last_name";
          let last_name = match List.assoc_opt "last_name" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "vcard";
          let vcard = match List.assoc_opt "vcard" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "reply_markup";
          let reply_markup = match List.assoc_opt "reply_markup" fields with None | Some `Null -> None | Some x -> Some ((match InlineKeyboardMarkup.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "input_message_content";
          let input_message_content = match List.assoc_opt "input_message_content" fields with None | Some `Null -> None | Some x -> Some ((match InputMessageContent.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail_url";
          let thumbnail_url = match List.assoc_opt "thumbnail_url" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail_width";
          let thumbnail_width = match List.assoc_opt "thumbnail_width" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "thumbnail_height";
          let thumbnail_height = match List.assoc_opt "thumbnail_height" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; id = id; phone_number = phone_number; first_name = first_name; last_name = last_name; vcard = vcard; reply_markup = reply_markup; input_message_content = input_message_content; thumbnail_url = thumbnail_url; thumbnail_width = thumbnail_width; thumbnail_height = thumbnail_height; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InlineQueryResultGame : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    id : string;
    game_short_name : string;
    reply_markup : InlineKeyboardMarkup.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("id", `String v.id);
      ("game_short_name", `String v.game_short_name);
      (match v.reply_markup with None -> ("reply_markup", `Null) | Some x -> ("reply_markup", InlineKeyboardMarkup.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "game_short_name";
          let game_short_name = (to_string (List.assoc "game_short_name" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "reply_markup";
          let reply_markup = match List.assoc_opt "reply_markup" fields with None | Some `Null -> None | Some x -> Some ((match InlineKeyboardMarkup.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; id = id; game_short_name = game_short_name; reply_markup = reply_markup; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InlineQueryResultCachedPhoto : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    id : string;
    photo_file_id : string;
    title : string option;
    description : string option;
    caption : string option;
    parse_mode : string option;
    caption_entities : MessageEntity.t list option;
    show_caption_above_media : bool option;
    reply_markup : InlineKeyboardMarkup.t option;
    input_message_content : InputMessageContent.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("id", `String v.id);
      ("photo_file_id", `String v.photo_file_id);
      (match v.title with None -> ("title", `Null) | Some x -> ("title", `String x));
      (match v.description with None -> ("description", `Null) | Some x -> ("description", `String x));
      (match v.caption with None -> ("caption", `Null) | Some x -> ("caption", `String x));
      (match v.parse_mode with None -> ("parse_mode", `Null) | Some x -> ("parse_mode", `String x));
      (match v.caption_entities with None -> ("caption_entities", `Null) | Some x -> ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.show_caption_above_media with None -> ("show_caption_above_media", `Null) | Some x -> ("show_caption_above_media", `Bool x));
      (match v.reply_markup with None -> ("reply_markup", `Null) | Some x -> ("reply_markup", InlineKeyboardMarkup.to_yojson x));
      (match v.input_message_content with None -> ("input_message_content", `Null) | Some x -> ("input_message_content", InputMessageContent.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "photo_file_id";
          let photo_file_id = (to_string (List.assoc "photo_file_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = match List.assoc_opt "title" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "description";
          let description = match List.assoc_opt "description" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption";
          let caption = match List.assoc_opt "caption" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "parse_mode";
          let parse_mode = match List.assoc_opt "parse_mode" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption_entities";
          let caption_entities = match List.assoc_opt "caption_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "show_caption_above_media";
          let show_caption_above_media = match List.assoc_opt "show_caption_above_media" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "reply_markup";
          let reply_markup = match List.assoc_opt "reply_markup" fields with None | Some `Null -> None | Some x -> Some ((match InlineKeyboardMarkup.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "input_message_content";
          let input_message_content = match List.assoc_opt "input_message_content" fields with None | Some `Null -> None | Some x -> Some ((match InputMessageContent.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; id = id; photo_file_id = photo_file_id; title = title; description = description; caption = caption; parse_mode = parse_mode; caption_entities = caption_entities; show_caption_above_media = show_caption_above_media; reply_markup = reply_markup; input_message_content = input_message_content; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InlineQueryResultCachedGif : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    id : string;
    gif_file_id : string;
    title : string option;
    caption : string option;
    parse_mode : string option;
    caption_entities : MessageEntity.t list option;
    show_caption_above_media : bool option;
    reply_markup : InlineKeyboardMarkup.t option;
    input_message_content : InputMessageContent.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("id", `String v.id);
      ("gif_file_id", `String v.gif_file_id);
      (match v.title with None -> ("title", `Null) | Some x -> ("title", `String x));
      (match v.caption with None -> ("caption", `Null) | Some x -> ("caption", `String x));
      (match v.parse_mode with None -> ("parse_mode", `Null) | Some x -> ("parse_mode", `String x));
      (match v.caption_entities with None -> ("caption_entities", `Null) | Some x -> ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.show_caption_above_media with None -> ("show_caption_above_media", `Null) | Some x -> ("show_caption_above_media", `Bool x));
      (match v.reply_markup with None -> ("reply_markup", `Null) | Some x -> ("reply_markup", InlineKeyboardMarkup.to_yojson x));
      (match v.input_message_content with None -> ("input_message_content", `Null) | Some x -> ("input_message_content", InputMessageContent.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "gif_file_id";
          let gif_file_id = (to_string (List.assoc "gif_file_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = match List.assoc_opt "title" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption";
          let caption = match List.assoc_opt "caption" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "parse_mode";
          let parse_mode = match List.assoc_opt "parse_mode" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption_entities";
          let caption_entities = match List.assoc_opt "caption_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "show_caption_above_media";
          let show_caption_above_media = match List.assoc_opt "show_caption_above_media" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "reply_markup";
          let reply_markup = match List.assoc_opt "reply_markup" fields with None | Some `Null -> None | Some x -> Some ((match InlineKeyboardMarkup.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "input_message_content";
          let input_message_content = match List.assoc_opt "input_message_content" fields with None | Some `Null -> None | Some x -> Some ((match InputMessageContent.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; id = id; gif_file_id = gif_file_id; title = title; caption = caption; parse_mode = parse_mode; caption_entities = caption_entities; show_caption_above_media = show_caption_above_media; reply_markup = reply_markup; input_message_content = input_message_content; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InlineQueryResultCachedMpeg4Gif : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    id : string;
    mpeg4_file_id : string;
    title : string option;
    caption : string option;
    parse_mode : string option;
    caption_entities : MessageEntity.t list option;
    show_caption_above_media : bool option;
    reply_markup : InlineKeyboardMarkup.t option;
    input_message_content : InputMessageContent.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("id", `String v.id);
      ("mpeg4_file_id", `String v.mpeg4_file_id);
      (match v.title with None -> ("title", `Null) | Some x -> ("title", `String x));
      (match v.caption with None -> ("caption", `Null) | Some x -> ("caption", `String x));
      (match v.parse_mode with None -> ("parse_mode", `Null) | Some x -> ("parse_mode", `String x));
      (match v.caption_entities with None -> ("caption_entities", `Null) | Some x -> ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.show_caption_above_media with None -> ("show_caption_above_media", `Null) | Some x -> ("show_caption_above_media", `Bool x));
      (match v.reply_markup with None -> ("reply_markup", `Null) | Some x -> ("reply_markup", InlineKeyboardMarkup.to_yojson x));
      (match v.input_message_content with None -> ("input_message_content", `Null) | Some x -> ("input_message_content", InputMessageContent.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "mpeg4_file_id";
          let mpeg4_file_id = (to_string (List.assoc "mpeg4_file_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = match List.assoc_opt "title" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption";
          let caption = match List.assoc_opt "caption" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "parse_mode";
          let parse_mode = match List.assoc_opt "parse_mode" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption_entities";
          let caption_entities = match List.assoc_opt "caption_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "show_caption_above_media";
          let show_caption_above_media = match List.assoc_opt "show_caption_above_media" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "reply_markup";
          let reply_markup = match List.assoc_opt "reply_markup" fields with None | Some `Null -> None | Some x -> Some ((match InlineKeyboardMarkup.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "input_message_content";
          let input_message_content = match List.assoc_opt "input_message_content" fields with None | Some `Null -> None | Some x -> Some ((match InputMessageContent.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; id = id; mpeg4_file_id = mpeg4_file_id; title = title; caption = caption; parse_mode = parse_mode; caption_entities = caption_entities; show_caption_above_media = show_caption_above_media; reply_markup = reply_markup; input_message_content = input_message_content; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InlineQueryResultCachedSticker : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    id : string;
    sticker_file_id : string;
    reply_markup : InlineKeyboardMarkup.t option;
    input_message_content : InputMessageContent.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("id", `String v.id);
      ("sticker_file_id", `String v.sticker_file_id);
      (match v.reply_markup with None -> ("reply_markup", `Null) | Some x -> ("reply_markup", InlineKeyboardMarkup.to_yojson x));
      (match v.input_message_content with None -> ("input_message_content", `Null) | Some x -> ("input_message_content", InputMessageContent.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "sticker_file_id";
          let sticker_file_id = (to_string (List.assoc "sticker_file_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "reply_markup";
          let reply_markup = match List.assoc_opt "reply_markup" fields with None | Some `Null -> None | Some x -> Some ((match InlineKeyboardMarkup.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "input_message_content";
          let input_message_content = match List.assoc_opt "input_message_content" fields with None | Some `Null -> None | Some x -> Some ((match InputMessageContent.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; id = id; sticker_file_id = sticker_file_id; reply_markup = reply_markup; input_message_content = input_message_content; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InlineQueryResultCachedDocument : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    id : string;
    title : string;
    document_file_id : string;
    description : string option;
    caption : string option;
    parse_mode : string option;
    caption_entities : MessageEntity.t list option;
    reply_markup : InlineKeyboardMarkup.t option;
    input_message_content : InputMessageContent.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("id", `String v.id);
      ("title", `String v.title);
      ("document_file_id", `String v.document_file_id);
      (match v.description with None -> ("description", `Null) | Some x -> ("description", `String x));
      (match v.caption with None -> ("caption", `Null) | Some x -> ("caption", `String x));
      (match v.parse_mode with None -> ("parse_mode", `Null) | Some x -> ("parse_mode", `String x));
      (match v.caption_entities with None -> ("caption_entities", `Null) | Some x -> ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.reply_markup with None -> ("reply_markup", `Null) | Some x -> ("reply_markup", InlineKeyboardMarkup.to_yojson x));
      (match v.input_message_content with None -> ("input_message_content", `Null) | Some x -> ("input_message_content", InputMessageContent.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = (to_string (List.assoc "title" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "document_file_id";
          let document_file_id = (to_string (List.assoc "document_file_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "description";
          let description = match List.assoc_opt "description" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption";
          let caption = match List.assoc_opt "caption" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "parse_mode";
          let parse_mode = match List.assoc_opt "parse_mode" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption_entities";
          let caption_entities = match List.assoc_opt "caption_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "reply_markup";
          let reply_markup = match List.assoc_opt "reply_markup" fields with None | Some `Null -> None | Some x -> Some ((match InlineKeyboardMarkup.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "input_message_content";
          let input_message_content = match List.assoc_opt "input_message_content" fields with None | Some `Null -> None | Some x -> Some ((match InputMessageContent.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; id = id; title = title; document_file_id = document_file_id; description = description; caption = caption; parse_mode = parse_mode; caption_entities = caption_entities; reply_markup = reply_markup; input_message_content = input_message_content; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InlineQueryResultCachedVideo : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    id : string;
    video_file_id : string;
    title : string;
    description : string option;
    caption : string option;
    parse_mode : string option;
    caption_entities : MessageEntity.t list option;
    show_caption_above_media : bool option;
    reply_markup : InlineKeyboardMarkup.t option;
    input_message_content : InputMessageContent.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("id", `String v.id);
      ("video_file_id", `String v.video_file_id);
      ("title", `String v.title);
      (match v.description with None -> ("description", `Null) | Some x -> ("description", `String x));
      (match v.caption with None -> ("caption", `Null) | Some x -> ("caption", `String x));
      (match v.parse_mode with None -> ("parse_mode", `Null) | Some x -> ("parse_mode", `String x));
      (match v.caption_entities with None -> ("caption_entities", `Null) | Some x -> ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.show_caption_above_media with None -> ("show_caption_above_media", `Null) | Some x -> ("show_caption_above_media", `Bool x));
      (match v.reply_markup with None -> ("reply_markup", `Null) | Some x -> ("reply_markup", InlineKeyboardMarkup.to_yojson x));
      (match v.input_message_content with None -> ("input_message_content", `Null) | Some x -> ("input_message_content", InputMessageContent.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "video_file_id";
          let video_file_id = (to_string (List.assoc "video_file_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = (to_string (List.assoc "title" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "description";
          let description = match List.assoc_opt "description" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption";
          let caption = match List.assoc_opt "caption" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "parse_mode";
          let parse_mode = match List.assoc_opt "parse_mode" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption_entities";
          let caption_entities = match List.assoc_opt "caption_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "show_caption_above_media";
          let show_caption_above_media = match List.assoc_opt "show_caption_above_media" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "reply_markup";
          let reply_markup = match List.assoc_opt "reply_markup" fields with None | Some `Null -> None | Some x -> Some ((match InlineKeyboardMarkup.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "input_message_content";
          let input_message_content = match List.assoc_opt "input_message_content" fields with None | Some `Null -> None | Some x -> Some ((match InputMessageContent.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; id = id; video_file_id = video_file_id; title = title; description = description; caption = caption; parse_mode = parse_mode; caption_entities = caption_entities; show_caption_above_media = show_caption_above_media; reply_markup = reply_markup; input_message_content = input_message_content; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InlineQueryResultCachedVoice : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    id : string;
    voice_file_id : string;
    title : string;
    caption : string option;
    parse_mode : string option;
    caption_entities : MessageEntity.t list option;
    reply_markup : InlineKeyboardMarkup.t option;
    input_message_content : InputMessageContent.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("id", `String v.id);
      ("voice_file_id", `String v.voice_file_id);
      ("title", `String v.title);
      (match v.caption with None -> ("caption", `Null) | Some x -> ("caption", `String x));
      (match v.parse_mode with None -> ("parse_mode", `Null) | Some x -> ("parse_mode", `String x));
      (match v.caption_entities with None -> ("caption_entities", `Null) | Some x -> ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.reply_markup with None -> ("reply_markup", `Null) | Some x -> ("reply_markup", InlineKeyboardMarkup.to_yojson x));
      (match v.input_message_content with None -> ("input_message_content", `Null) | Some x -> ("input_message_content", InputMessageContent.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "voice_file_id";
          let voice_file_id = (to_string (List.assoc "voice_file_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = (to_string (List.assoc "title" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption";
          let caption = match List.assoc_opt "caption" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "parse_mode";
          let parse_mode = match List.assoc_opt "parse_mode" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption_entities";
          let caption_entities = match List.assoc_opt "caption_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "reply_markup";
          let reply_markup = match List.assoc_opt "reply_markup" fields with None | Some `Null -> None | Some x -> Some ((match InlineKeyboardMarkup.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "input_message_content";
          let input_message_content = match List.assoc_opt "input_message_content" fields with None | Some `Null -> None | Some x -> Some ((match InputMessageContent.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; id = id; voice_file_id = voice_file_id; title = title; caption = caption; parse_mode = parse_mode; caption_entities = caption_entities; reply_markup = reply_markup; input_message_content = input_message_content; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and InlineQueryResultCachedAudio : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    id : string;
    audio_file_id : string;
    caption : string option;
    parse_mode : string option;
    caption_entities : MessageEntity.t list option;
    reply_markup : InlineKeyboardMarkup.t option;
    input_message_content : InputMessageContent.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("id", `String v.id);
      ("audio_file_id", `String v.audio_file_id);
      (match v.caption with None -> ("caption", `Null) | Some x -> ("caption", `String x));
      (match v.parse_mode with None -> ("parse_mode", `Null) | Some x -> ("parse_mode", `String x));
      (match v.caption_entities with None -> ("caption_entities", `Null) | Some x -> ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.reply_markup with None -> ("reply_markup", `Null) | Some x -> ("reply_markup", InlineKeyboardMarkup.to_yojson x));
      (match v.input_message_content with None -> ("input_message_content", `Null) | Some x -> ("input_message_content", InputMessageContent.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "audio_file_id";
          let audio_file_id = (to_string (List.assoc "audio_file_id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption";
          let caption = match List.assoc_opt "caption" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "parse_mode";
          let parse_mode = match List.assoc_opt "parse_mode" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption_entities";
          let caption_entities = match List.assoc_opt "caption_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "reply_markup";
          let reply_markup = match List.assoc_opt "reply_markup" fields with None | Some `Null -> None | Some x -> Some ((match InlineKeyboardMarkup.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "input_message_content";
          let input_message_content = match List.assoc_opt "input_message_content" fields with None | Some `Null -> None | Some x -> Some ((match InputMessageContent.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; id = id; audio_file_id = audio_file_id; caption = caption; parse_mode = parse_mode; caption_entities = caption_entities; reply_markup = reply_markup; input_message_content = input_message_content; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and TransactionPartner : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    transaction_type : string;
    user : User.t;
    affiliate : AffiliateInfo.t option;
    invoice_payload : string option;
    subscription_period : int64 option;
    paid_media : PaidMedia.t list option;
    paid_media_payload : string option;
    gift : Gift.t option;
    premium_subscription_duration : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("transaction_type", `String v.transaction_type);
      ("user", User.to_yojson v.user);
      (match v.affiliate with None -> ("affiliate", `Null) | Some x -> ("affiliate", AffiliateInfo.to_yojson x));
      (match v.invoice_payload with None -> ("invoice_payload", `Null) | Some x -> ("invoice_payload", `String x));
      (match v.subscription_period with None -> ("subscription_period", `Null) | Some x -> ("subscription_period", `Intlit (Int64.to_string x)));
      (match v.paid_media with None -> ("paid_media", `Null) | Some x -> ("paid_media", `List (List.map (fun x -> PaidMedia.to_yojson x) x)));
      (match v.paid_media_payload with None -> ("paid_media_payload", `Null) | Some x -> ("paid_media_payload", `String x));
      (match v.gift with None -> ("gift", `Null) | Some x -> ("gift", Gift.to_yojson x));
      (match v.premium_subscription_duration with None -> ("premium_subscription_duration", `Null) | Some x -> ("premium_subscription_duration", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "transaction_type";
          let transaction_type = (to_string (List.assoc "transaction_type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "user";
          let user = (match User.of_yojson (List.assoc "user" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "user" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "affiliate";
          let affiliate = match List.assoc_opt "affiliate" fields with None | Some `Null -> None | Some x -> Some ((match AffiliateInfo.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "invoice_payload";
          let invoice_payload = match List.assoc_opt "invoice_payload" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "subscription_period";
          let subscription_period = match List.assoc_opt "subscription_period" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "paid_media";
          let paid_media = match List.assoc_opt "paid_media" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match PaidMedia.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "paid_media_payload";
          let paid_media_payload = match List.assoc_opt "paid_media_payload" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "gift";
          let gift = match List.assoc_opt "gift" fields with None | Some `Null -> None | Some x -> Some ((match Gift.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "premium_subscription_duration";
          let premium_subscription_duration = match List.assoc_opt "premium_subscription_duration" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; transaction_type = transaction_type; user = user; affiliate = affiliate; invoice_payload = invoice_payload; subscription_period = subscription_period; paid_media = paid_media; paid_media_payload = paid_media_payload; gift = gift; premium_subscription_duration = premium_subscription_duration; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and TransactionPartnerUser : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    transaction_type : string;
    user : User.t;
    affiliate : AffiliateInfo.t option;
    invoice_payload : string option;
    subscription_period : int64 option;
    paid_media : PaidMedia.t list option;
    paid_media_payload : string option;
    gift : Gift.t option;
    premium_subscription_duration : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("transaction_type", `String v.transaction_type);
      ("user", User.to_yojson v.user);
      (match v.affiliate with None -> ("affiliate", `Null) | Some x -> ("affiliate", AffiliateInfo.to_yojson x));
      (match v.invoice_payload with None -> ("invoice_payload", `Null) | Some x -> ("invoice_payload", `String x));
      (match v.subscription_period with None -> ("subscription_period", `Null) | Some x -> ("subscription_period", `Intlit (Int64.to_string x)));
      (match v.paid_media with None -> ("paid_media", `Null) | Some x -> ("paid_media", `List (List.map (fun x -> PaidMedia.to_yojson x) x)));
      (match v.paid_media_payload with None -> ("paid_media_payload", `Null) | Some x -> ("paid_media_payload", `String x));
      (match v.gift with None -> ("gift", `Null) | Some x -> ("gift", Gift.to_yojson x));
      (match v.premium_subscription_duration with None -> ("premium_subscription_duration", `Null) | Some x -> ("premium_subscription_duration", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "transaction_type";
          let transaction_type = (to_string (List.assoc "transaction_type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "user";
          let user = (match User.of_yojson (List.assoc "user" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "user" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "affiliate";
          let affiliate = match List.assoc_opt "affiliate" fields with None | Some `Null -> None | Some x -> Some ((match AffiliateInfo.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "invoice_payload";
          let invoice_payload = match List.assoc_opt "invoice_payload" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "subscription_period";
          let subscription_period = match List.assoc_opt "subscription_period" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "paid_media";
          let paid_media = match List.assoc_opt "paid_media" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match PaidMedia.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "paid_media_payload";
          let paid_media_payload = match List.assoc_opt "paid_media_payload" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "gift";
          let gift = match List.assoc_opt "gift" fields with None | Some `Null -> None | Some x -> Some ((match Gift.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "premium_subscription_duration";
          let premium_subscription_duration = match List.assoc_opt "premium_subscription_duration" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; transaction_type = transaction_type; user = user; affiliate = affiliate; invoice_payload = invoice_payload; subscription_period = subscription_period; paid_media = paid_media; paid_media_payload = paid_media_payload; gift = gift; premium_subscription_duration = premium_subscription_duration; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and TransactionPartnerChat : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    chat : Chat.t;
    gift : Gift.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("chat", Chat.to_yojson v.chat);
      (match v.gift with None -> ("gift", `Null) | Some x -> ("gift", Gift.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat";
          let chat = (match Chat.of_yojson (List.assoc "chat" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "chat" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "gift";
          let gift = match List.assoc_opt "gift" fields with None | Some `Null -> None | Some x -> Some ((match Gift.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; chat = chat; gift = gift; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ExternalReplyInfo : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    origin : MessageOrigin.t;
    chat : Chat.t option;
    message_id : int64 option;
    link_preview_options : LinkPreviewOptions.t option;
    animation : Animation.t option;
    audio : Audio.t option;
    document : Document.t option;
    paid_media : PaidMediaInfo.t option;
    photo : PhotoSize.t list option;
    sticker : Sticker.t option;
    story : Story.t option;
    video : Video.t option;
    video_note : VideoNote.t option;
    voice : Voice.t option;
    has_media_spoiler : bool option;
    checklist : Checklist.t option;
    contact : Contact.t option;
    dice : Dice.t option;
    game : Game.t option;
    giveaway : Giveaway.t option;
    giveaway_winners : GiveawayWinners.t option;
    invoice : Invoice.t option;
    location : Location.t option;
    poll : Poll.t option;
    venue : Venue.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("origin", MessageOrigin.to_yojson v.origin);
      (match v.chat with None -> ("chat", `Null) | Some x -> ("chat", Chat.to_yojson x));
      (match v.message_id with None -> ("message_id", `Null) | Some x -> ("message_id", `Intlit (Int64.to_string x)));
      (match v.link_preview_options with None -> ("link_preview_options", `Null) | Some x -> ("link_preview_options", LinkPreviewOptions.to_yojson x));
      (match v.animation with None -> ("animation", `Null) | Some x -> ("animation", Animation.to_yojson x));
      (match v.audio with None -> ("audio", `Null) | Some x -> ("audio", Audio.to_yojson x));
      (match v.document with None -> ("document", `Null) | Some x -> ("document", Document.to_yojson x));
      (match v.paid_media with None -> ("paid_media", `Null) | Some x -> ("paid_media", PaidMediaInfo.to_yojson x));
      (match v.photo with None -> ("photo", `Null) | Some x -> ("photo", `List (List.map (fun x -> PhotoSize.to_yojson x) x)));
      (match v.sticker with None -> ("sticker", `Null) | Some x -> ("sticker", Sticker.to_yojson x));
      (match v.story with None -> ("story", `Null) | Some x -> ("story", Story.to_yojson x));
      (match v.video with None -> ("video", `Null) | Some x -> ("video", Video.to_yojson x));
      (match v.video_note with None -> ("video_note", `Null) | Some x -> ("video_note", VideoNote.to_yojson x));
      (match v.voice with None -> ("voice", `Null) | Some x -> ("voice", Voice.to_yojson x));
      (match v.has_media_spoiler with None -> ("has_media_spoiler", `Null) | Some x -> ("has_media_spoiler", `Bool x));
      (match v.checklist with None -> ("checklist", `Null) | Some x -> ("checklist", Checklist.to_yojson x));
      (match v.contact with None -> ("contact", `Null) | Some x -> ("contact", Contact.to_yojson x));
      (match v.dice with None -> ("dice", `Null) | Some x -> ("dice", Dice.to_yojson x));
      (match v.game with None -> ("game", `Null) | Some x -> ("game", Game.to_yojson x));
      (match v.giveaway with None -> ("giveaway", `Null) | Some x -> ("giveaway", Giveaway.to_yojson x));
      (match v.giveaway_winners with None -> ("giveaway_winners", `Null) | Some x -> ("giveaway_winners", GiveawayWinners.to_yojson x));
      (match v.invoice with None -> ("invoice", `Null) | Some x -> ("invoice", Invoice.to_yojson x));
      (match v.location with None -> ("location", `Null) | Some x -> ("location", Location.to_yojson x));
      (match v.poll with None -> ("poll", `Null) | Some x -> ("poll", Poll.to_yojson x));
      (match v.venue with None -> ("venue", `Null) | Some x -> ("venue", Venue.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "origin";
          let origin = (match MessageOrigin.of_yojson (List.assoc "origin" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "origin" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat";
          let chat = match List.assoc_opt "chat" fields with None | Some `Null -> None | Some x -> Some ((match Chat.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message_id";
          let message_id = match List.assoc_opt "message_id" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "link_preview_options";
          let link_preview_options = match List.assoc_opt "link_preview_options" fields with None | Some `Null -> None | Some x -> Some ((match LinkPreviewOptions.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "animation";
          let animation = match List.assoc_opt "animation" fields with None | Some `Null -> None | Some x -> Some ((match Animation.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "audio";
          let audio = match List.assoc_opt "audio" fields with None | Some `Null -> None | Some x -> Some ((match Audio.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "document";
          let document = match List.assoc_opt "document" fields with None | Some `Null -> None | Some x -> Some ((match Document.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "paid_media";
          let paid_media = match List.assoc_opt "paid_media" fields with None | Some `Null -> None | Some x -> Some ((match PaidMediaInfo.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "photo";
          let photo = match List.assoc_opt "photo" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match PhotoSize.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "sticker";
          let sticker = match List.assoc_opt "sticker" fields with None | Some `Null -> None | Some x -> Some ((match Sticker.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "story";
          let story = match List.assoc_opt "story" fields with None | Some `Null -> None | Some x -> Some ((match Story.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "video";
          let video = match List.assoc_opt "video" fields with None | Some `Null -> None | Some x -> Some ((match Video.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "video_note";
          let video_note = match List.assoc_opt "video_note" fields with None | Some `Null -> None | Some x -> Some ((match VideoNote.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "voice";
          let voice = match List.assoc_opt "voice" fields with None | Some `Null -> None | Some x -> Some ((match Voice.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "has_media_spoiler";
          let has_media_spoiler = match List.assoc_opt "has_media_spoiler" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "checklist";
          let checklist = match List.assoc_opt "checklist" fields with None | Some `Null -> None | Some x -> Some ((match Checklist.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "contact";
          let contact = match List.assoc_opt "contact" fields with None | Some `Null -> None | Some x -> Some ((match Contact.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "dice";
          let dice = match List.assoc_opt "dice" fields with None | Some `Null -> None | Some x -> Some ((match Dice.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "game";
          let game = match List.assoc_opt "game" fields with None | Some `Null -> None | Some x -> Some ((match Game.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "giveaway";
          let giveaway = match List.assoc_opt "giveaway" fields with None | Some `Null -> None | Some x -> Some ((match Giveaway.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "giveaway_winners";
          let giveaway_winners = match List.assoc_opt "giveaway_winners" fields with None | Some `Null -> None | Some x -> Some ((match GiveawayWinners.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "invoice";
          let invoice = match List.assoc_opt "invoice" fields with None | Some `Null -> None | Some x -> Some ((match Invoice.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "location";
          let location = match List.assoc_opt "location" fields with None | Some `Null -> None | Some x -> Some ((match Location.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "poll";
          let poll = match List.assoc_opt "poll" fields with None | Some `Null -> None | Some x -> Some ((match Poll.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "venue";
          let venue = match List.assoc_opt "venue" fields with None | Some `Null -> None | Some x -> Some ((match Venue.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { origin = origin; chat = chat; message_id = message_id; link_preview_options = link_preview_options; animation = animation; audio = audio; document = document; paid_media = paid_media; photo = photo; sticker = sticker; story = story; video = video; video_note = video_note; voice = voice; has_media_spoiler = has_media_spoiler; checklist = checklist; contact = contact; dice = dice; game = game; giveaway = giveaway; giveaway_winners = giveaway_winners; invoice = invoice; location = location; poll = poll; venue = venue; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and UniqueGiftInfo : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    gift : UniqueGift.t;
    origin : string;
    last_resale_star_count : int64 option;
    owned_gift_id : string option;
    transfer_star_count : int64 option;
    next_transfer_date : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("gift", UniqueGift.to_yojson v.gift);
      ("origin", `String v.origin);
      (match v.last_resale_star_count with None -> ("last_resale_star_count", `Null) | Some x -> ("last_resale_star_count", `Intlit (Int64.to_string x)));
      (match v.owned_gift_id with None -> ("owned_gift_id", `Null) | Some x -> ("owned_gift_id", `String x));
      (match v.transfer_star_count with None -> ("transfer_star_count", `Null) | Some x -> ("transfer_star_count", `Intlit (Int64.to_string x)));
      (match v.next_transfer_date with None -> ("next_transfer_date", `Null) | Some x -> ("next_transfer_date", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "gift";
          let gift = (match UniqueGift.of_yojson (List.assoc "gift" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "gift" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "origin";
          let origin = (to_string (List.assoc "origin" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "last_resale_star_count";
          let last_resale_star_count = match List.assoc_opt "last_resale_star_count" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "owned_gift_id";
          let owned_gift_id = match List.assoc_opt "owned_gift_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "transfer_star_count";
          let transfer_star_count = match List.assoc_opt "transfer_star_count" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "next_transfer_date";
          let next_transfer_date = match List.assoc_opt "next_transfer_date" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { gift = gift; origin = origin; last_resale_star_count = last_resale_star_count; owned_gift_id = owned_gift_id; transfer_star_count = transfer_star_count; next_transfer_date = next_transfer_date; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and OwnedGiftUnique : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    type_ : string;
    gift : UniqueGift.t;
    owned_gift_id : string option;
    sender_user : User.t option;
    send_date : int64;
    is_saved : bool option;
    can_be_transferred : bool option;
    transfer_star_count : int64 option;
    next_transfer_date : int64 option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("type", `String v.type_);
      ("gift", UniqueGift.to_yojson v.gift);
      (match v.owned_gift_id with None -> ("owned_gift_id", `Null) | Some x -> ("owned_gift_id", `String x));
      (match v.sender_user with None -> ("sender_user", `Null) | Some x -> ("sender_user", User.to_yojson x));
      ("send_date", `Intlit (Int64.to_string v.send_date));
      (match v.is_saved with None -> ("is_saved", `Null) | Some x -> ("is_saved", `Bool x));
      (match v.can_be_transferred with None -> ("can_be_transferred", `Null) | Some x -> ("can_be_transferred", `Bool x));
      (match v.transfer_star_count with None -> ("transfer_star_count", `Null) | Some x -> ("transfer_star_count", `Intlit (Int64.to_string x)));
      (match v.next_transfer_date with None -> ("next_transfer_date", `Null) | Some x -> ("next_transfer_date", `Intlit (Int64.to_string x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "gift";
          let gift = (match UniqueGift.of_yojson (List.assoc "gift" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "gift" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "owned_gift_id";
          let owned_gift_id = match List.assoc_opt "owned_gift_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "sender_user";
          let sender_user = match List.assoc_opt "sender_user" fields with None | Some `Null -> None | Some x -> Some ((match User.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "send_date";
          let send_date = (match (List.assoc "send_date" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "send_date" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_saved";
          let is_saved = match List.assoc_opt "is_saved" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_be_transferred";
          let can_be_transferred = match List.assoc_opt "can_be_transferred" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "transfer_star_count";
          let transfer_star_count = match List.assoc_opt "transfer_star_count" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "next_transfer_date";
          let next_transfer_date = match List.assoc_opt "next_transfer_date" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { type_ = type_; gift = gift; owned_gift_id = owned_gift_id; sender_user = sender_user; send_date = send_date; is_saved = is_saved; can_be_transferred = can_be_transferred; transfer_star_count = transfer_star_count; next_transfer_date = next_transfer_date; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and OwnedGifts : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    total_count : int64;
    gifts : OwnedGift.t list;
    next_offset : string option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("total_count", `Intlit (Int64.to_string v.total_count));
      ("gifts", `List (List.map (fun x -> OwnedGift.to_yojson x) v.gifts));
      (match v.next_offset with None -> ("next_offset", `Null) | Some x -> ("next_offset", `String x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "total_count";
          let total_count = (match (List.assoc "total_count" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "total_count" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "gifts";
          let gifts = (List.map (fun x -> (match OwnedGift.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list (List.assoc "gifts" fields))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "next_offset";
          let next_offset = match List.assoc_opt "next_offset" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { total_count = total_count; gifts = gifts; next_offset = next_offset; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and StarTransaction : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    id : string;
    amount : int64;
    nanostar_amount : int64 option;
    date : int64;
    source : TransactionPartner.t option;
    receiver : TransactionPartner.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("id", `String v.id);
      ("amount", `Intlit (Int64.to_string v.amount));
      (match v.nanostar_amount with None -> ("nanostar_amount", `Null) | Some x -> ("nanostar_amount", `Intlit (Int64.to_string x)));
      ("date", `Intlit (Int64.to_string v.date));
      (match v.source with None -> ("source", `Null) | Some x -> ("source", TransactionPartner.to_yojson x));
      (match v.receiver with None -> ("receiver", `Null) | Some x -> ("receiver", TransactionPartner.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (to_string (List.assoc "id" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "amount";
          let amount = (match (List.assoc "amount" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "amount" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "nanostar_amount";
          let nanostar_amount = match List.assoc_opt "nanostar_amount" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "date";
          let date = (match (List.assoc "date" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "date" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "source";
          let source = match List.assoc_opt "source" fields with None | Some `Null -> None | Some x -> Some ((match TransactionPartner.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "receiver";
          let receiver = match List.assoc_opt "receiver" fields with None | Some `Null -> None | Some x -> Some ((match TransactionPartner.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { id = id; amount = amount; nanostar_amount = nanostar_amount; date = date; source = source; receiver = receiver; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and StarTransactions : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    transactions : StarTransaction.t list;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("transactions", `List (List.map (fun x -> StarTransaction.to_yojson x) v.transactions));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "transactions";
          let transactions = (List.map (fun x -> (match StarTransaction.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list (List.assoc "transactions" fields))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { transactions = transactions; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and August152025 : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    update_id : int64;
    message : Message.t option;
    edited_message : Message.t option;
    channel_post : Message.t option;
    edited_channel_post : Message.t option;
    business_connection : BusinessConnection.t option;
    business_message : Message.t option;
    edited_business_message : Message.t option;
    deleted_business_messages : BusinessMessagesDeleted.t option;
    message_reaction : MessageReactionUpdated.t option;
    message_reaction_count : MessageReactionCountUpdated.t option;
    inline_query : InlineQuery.t option;
    chosen_inline_result : ChosenInlineResult.t option;
    callback_query : CallbackQuery.t option;
    shipping_query : ShippingQuery.t option;
    pre_checkout_query : PreCheckoutQuery.t option;
    purchased_paid_media : PaidMediaPurchased.t option;
    poll : Poll.t option;
    poll_answer : PollAnswer.t option;
    my_chat_member : ChatMemberUpdated.t option;
    chat_member : ChatMemberUpdated.t option;
    chat_join_request : ChatJoinRequest.t option;
    chat_boost : ChatBoostUpdated.t option;
    removed_chat_boost : ChatBoostRemoved.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("update_id", `Intlit (Int64.to_string v.update_id));
      (match v.message with None -> ("message", `Null) | Some x -> ("message", Message.to_yojson x));
      (match v.edited_message with None -> ("edited_message", `Null) | Some x -> ("edited_message", Message.to_yojson x));
      (match v.channel_post with None -> ("channel_post", `Null) | Some x -> ("channel_post", Message.to_yojson x));
      (match v.edited_channel_post with None -> ("edited_channel_post", `Null) | Some x -> ("edited_channel_post", Message.to_yojson x));
      (match v.business_connection with None -> ("business_connection", `Null) | Some x -> ("business_connection", BusinessConnection.to_yojson x));
      (match v.business_message with None -> ("business_message", `Null) | Some x -> ("business_message", Message.to_yojson x));
      (match v.edited_business_message with None -> ("edited_business_message", `Null) | Some x -> ("edited_business_message", Message.to_yojson x));
      (match v.deleted_business_messages with None -> ("deleted_business_messages", `Null) | Some x -> ("deleted_business_messages", BusinessMessagesDeleted.to_yojson x));
      (match v.message_reaction with None -> ("message_reaction", `Null) | Some x -> ("message_reaction", MessageReactionUpdated.to_yojson x));
      (match v.message_reaction_count with None -> ("message_reaction_count", `Null) | Some x -> ("message_reaction_count", MessageReactionCountUpdated.to_yojson x));
      (match v.inline_query with None -> ("inline_query", `Null) | Some x -> ("inline_query", InlineQuery.to_yojson x));
      (match v.chosen_inline_result with None -> ("chosen_inline_result", `Null) | Some x -> ("chosen_inline_result", ChosenInlineResult.to_yojson x));
      (match v.callback_query with None -> ("callback_query", `Null) | Some x -> ("callback_query", CallbackQuery.to_yojson x));
      (match v.shipping_query with None -> ("shipping_query", `Null) | Some x -> ("shipping_query", ShippingQuery.to_yojson x));
      (match v.pre_checkout_query with None -> ("pre_checkout_query", `Null) | Some x -> ("pre_checkout_query", PreCheckoutQuery.to_yojson x));
      (match v.purchased_paid_media with None -> ("purchased_paid_media", `Null) | Some x -> ("purchased_paid_media", PaidMediaPurchased.to_yojson x));
      (match v.poll with None -> ("poll", `Null) | Some x -> ("poll", Poll.to_yojson x));
      (match v.poll_answer with None -> ("poll_answer", `Null) | Some x -> ("poll_answer", PollAnswer.to_yojson x));
      (match v.my_chat_member with None -> ("my_chat_member", `Null) | Some x -> ("my_chat_member", ChatMemberUpdated.to_yojson x));
      (match v.chat_member with None -> ("chat_member", `Null) | Some x -> ("chat_member", ChatMemberUpdated.to_yojson x));
      (match v.chat_join_request with None -> ("chat_join_request", `Null) | Some x -> ("chat_join_request", ChatJoinRequest.to_yojson x));
      (match v.chat_boost with None -> ("chat_boost", `Null) | Some x -> ("chat_boost", ChatBoostUpdated.to_yojson x));
      (match v.removed_chat_boost with None -> ("removed_chat_boost", `Null) | Some x -> ("removed_chat_boost", ChatBoostRemoved.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "update_id";
          let update_id = (match (List.assoc "update_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "update_id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message";
          let message = match List.assoc_opt "message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "edited_message";
          let edited_message = match List.assoc_opt "edited_message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "channel_post";
          let channel_post = match List.assoc_opt "channel_post" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "edited_channel_post";
          let edited_channel_post = match List.assoc_opt "edited_channel_post" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "business_connection";
          let business_connection = match List.assoc_opt "business_connection" fields with None | Some `Null -> None | Some x -> Some ((match BusinessConnection.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "business_message";
          let business_message = match List.assoc_opt "business_message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "edited_business_message";
          let edited_business_message = match List.assoc_opt "edited_business_message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "deleted_business_messages";
          let deleted_business_messages = match List.assoc_opt "deleted_business_messages" fields with None | Some `Null -> None | Some x -> Some ((match BusinessMessagesDeleted.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message_reaction";
          let message_reaction = match List.assoc_opt "message_reaction" fields with None | Some `Null -> None | Some x -> Some ((match MessageReactionUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message_reaction_count";
          let message_reaction_count = match List.assoc_opt "message_reaction_count" fields with None | Some `Null -> None | Some x -> Some ((match MessageReactionCountUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "inline_query";
          let inline_query = match List.assoc_opt "inline_query" fields with None | Some `Null -> None | Some x -> Some ((match InlineQuery.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chosen_inline_result";
          let chosen_inline_result = match List.assoc_opt "chosen_inline_result" fields with None | Some `Null -> None | Some x -> Some ((match ChosenInlineResult.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "callback_query";
          let callback_query = match List.assoc_opt "callback_query" fields with None | Some `Null -> None | Some x -> Some ((match CallbackQuery.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "shipping_query";
          let shipping_query = match List.assoc_opt "shipping_query" fields with None | Some `Null -> None | Some x -> Some ((match ShippingQuery.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "pre_checkout_query";
          let pre_checkout_query = match List.assoc_opt "pre_checkout_query" fields with None | Some `Null -> None | Some x -> Some ((match PreCheckoutQuery.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "purchased_paid_media";
          let purchased_paid_media = match List.assoc_opt "purchased_paid_media" fields with None | Some `Null -> None | Some x -> Some ((match PaidMediaPurchased.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "poll";
          let poll = match List.assoc_opt "poll" fields with None | Some `Null -> None | Some x -> Some ((match Poll.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "poll_answer";
          let poll_answer = match List.assoc_opt "poll_answer" fields with None | Some `Null -> None | Some x -> Some ((match PollAnswer.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "my_chat_member";
          let my_chat_member = match List.assoc_opt "my_chat_member" fields with None | Some `Null -> None | Some x -> Some ((match ChatMemberUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_member";
          let chat_member = match List.assoc_opt "chat_member" fields with None | Some `Null -> None | Some x -> Some ((match ChatMemberUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_join_request";
          let chat_join_request = match List.assoc_opt "chat_join_request" fields with None | Some `Null -> None | Some x -> Some ((match ChatJoinRequest.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_boost";
          let chat_boost = match List.assoc_opt "chat_boost" fields with None | Some `Null -> None | Some x -> Some ((match ChatBoostUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "removed_chat_boost";
          let removed_chat_boost = match List.assoc_opt "removed_chat_boost" fields with None | Some `Null -> None | Some x -> Some ((match ChatBoostRemoved.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { update_id = update_id; message = message; edited_message = edited_message; channel_post = channel_post; edited_channel_post = edited_channel_post; business_connection = business_connection; business_message = business_message; edited_business_message = edited_business_message; deleted_business_messages = deleted_business_messages; message_reaction = message_reaction; message_reaction_count = message_reaction_count; inline_query = inline_query; chosen_inline_result = chosen_inline_result; callback_query = callback_query; shipping_query = shipping_query; pre_checkout_query = pre_checkout_query; purchased_paid_media = purchased_paid_media; poll = poll; poll_answer = poll_answer; my_chat_member = my_chat_member; chat_member = chat_member; chat_join_request = chat_join_request; chat_boost = chat_boost; removed_chat_boost = removed_chat_boost; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and July32025 : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    update_id : int64;
    message : Message.t option;
    edited_message : Message.t option;
    channel_post : Message.t option;
    edited_channel_post : Message.t option;
    business_connection : BusinessConnection.t option;
    business_message : Message.t option;
    edited_business_message : Message.t option;
    deleted_business_messages : BusinessMessagesDeleted.t option;
    message_reaction : MessageReactionUpdated.t option;
    message_reaction_count : MessageReactionCountUpdated.t option;
    inline_query : InlineQuery.t option;
    chosen_inline_result : ChosenInlineResult.t option;
    callback_query : CallbackQuery.t option;
    shipping_query : ShippingQuery.t option;
    pre_checkout_query : PreCheckoutQuery.t option;
    purchased_paid_media : PaidMediaPurchased.t option;
    poll : Poll.t option;
    poll_answer : PollAnswer.t option;
    my_chat_member : ChatMemberUpdated.t option;
    chat_member : ChatMemberUpdated.t option;
    chat_join_request : ChatJoinRequest.t option;
    chat_boost : ChatBoostUpdated.t option;
    removed_chat_boost : ChatBoostRemoved.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("update_id", `Intlit (Int64.to_string v.update_id));
      (match v.message with None -> ("message", `Null) | Some x -> ("message", Message.to_yojson x));
      (match v.edited_message with None -> ("edited_message", `Null) | Some x -> ("edited_message", Message.to_yojson x));
      (match v.channel_post with None -> ("channel_post", `Null) | Some x -> ("channel_post", Message.to_yojson x));
      (match v.edited_channel_post with None -> ("edited_channel_post", `Null) | Some x -> ("edited_channel_post", Message.to_yojson x));
      (match v.business_connection with None -> ("business_connection", `Null) | Some x -> ("business_connection", BusinessConnection.to_yojson x));
      (match v.business_message with None -> ("business_message", `Null) | Some x -> ("business_message", Message.to_yojson x));
      (match v.edited_business_message with None -> ("edited_business_message", `Null) | Some x -> ("edited_business_message", Message.to_yojson x));
      (match v.deleted_business_messages with None -> ("deleted_business_messages", `Null) | Some x -> ("deleted_business_messages", BusinessMessagesDeleted.to_yojson x));
      (match v.message_reaction with None -> ("message_reaction", `Null) | Some x -> ("message_reaction", MessageReactionUpdated.to_yojson x));
      (match v.message_reaction_count with None -> ("message_reaction_count", `Null) | Some x -> ("message_reaction_count", MessageReactionCountUpdated.to_yojson x));
      (match v.inline_query with None -> ("inline_query", `Null) | Some x -> ("inline_query", InlineQuery.to_yojson x));
      (match v.chosen_inline_result with None -> ("chosen_inline_result", `Null) | Some x -> ("chosen_inline_result", ChosenInlineResult.to_yojson x));
      (match v.callback_query with None -> ("callback_query", `Null) | Some x -> ("callback_query", CallbackQuery.to_yojson x));
      (match v.shipping_query with None -> ("shipping_query", `Null) | Some x -> ("shipping_query", ShippingQuery.to_yojson x));
      (match v.pre_checkout_query with None -> ("pre_checkout_query", `Null) | Some x -> ("pre_checkout_query", PreCheckoutQuery.to_yojson x));
      (match v.purchased_paid_media with None -> ("purchased_paid_media", `Null) | Some x -> ("purchased_paid_media", PaidMediaPurchased.to_yojson x));
      (match v.poll with None -> ("poll", `Null) | Some x -> ("poll", Poll.to_yojson x));
      (match v.poll_answer with None -> ("poll_answer", `Null) | Some x -> ("poll_answer", PollAnswer.to_yojson x));
      (match v.my_chat_member with None -> ("my_chat_member", `Null) | Some x -> ("my_chat_member", ChatMemberUpdated.to_yojson x));
      (match v.chat_member with None -> ("chat_member", `Null) | Some x -> ("chat_member", ChatMemberUpdated.to_yojson x));
      (match v.chat_join_request with None -> ("chat_join_request", `Null) | Some x -> ("chat_join_request", ChatJoinRequest.to_yojson x));
      (match v.chat_boost with None -> ("chat_boost", `Null) | Some x -> ("chat_boost", ChatBoostUpdated.to_yojson x));
      (match v.removed_chat_boost with None -> ("removed_chat_boost", `Null) | Some x -> ("removed_chat_boost", ChatBoostRemoved.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "update_id";
          let update_id = (match (List.assoc "update_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "update_id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message";
          let message = match List.assoc_opt "message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "edited_message";
          let edited_message = match List.assoc_opt "edited_message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "channel_post";
          let channel_post = match List.assoc_opt "channel_post" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "edited_channel_post";
          let edited_channel_post = match List.assoc_opt "edited_channel_post" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "business_connection";
          let business_connection = match List.assoc_opt "business_connection" fields with None | Some `Null -> None | Some x -> Some ((match BusinessConnection.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "business_message";
          let business_message = match List.assoc_opt "business_message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "edited_business_message";
          let edited_business_message = match List.assoc_opt "edited_business_message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "deleted_business_messages";
          let deleted_business_messages = match List.assoc_opt "deleted_business_messages" fields with None | Some `Null -> None | Some x -> Some ((match BusinessMessagesDeleted.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message_reaction";
          let message_reaction = match List.assoc_opt "message_reaction" fields with None | Some `Null -> None | Some x -> Some ((match MessageReactionUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message_reaction_count";
          let message_reaction_count = match List.assoc_opt "message_reaction_count" fields with None | Some `Null -> None | Some x -> Some ((match MessageReactionCountUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "inline_query";
          let inline_query = match List.assoc_opt "inline_query" fields with None | Some `Null -> None | Some x -> Some ((match InlineQuery.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chosen_inline_result";
          let chosen_inline_result = match List.assoc_opt "chosen_inline_result" fields with None | Some `Null -> None | Some x -> Some ((match ChosenInlineResult.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "callback_query";
          let callback_query = match List.assoc_opt "callback_query" fields with None | Some `Null -> None | Some x -> Some ((match CallbackQuery.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "shipping_query";
          let shipping_query = match List.assoc_opt "shipping_query" fields with None | Some `Null -> None | Some x -> Some ((match ShippingQuery.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "pre_checkout_query";
          let pre_checkout_query = match List.assoc_opt "pre_checkout_query" fields with None | Some `Null -> None | Some x -> Some ((match PreCheckoutQuery.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "purchased_paid_media";
          let purchased_paid_media = match List.assoc_opt "purchased_paid_media" fields with None | Some `Null -> None | Some x -> Some ((match PaidMediaPurchased.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "poll";
          let poll = match List.assoc_opt "poll" fields with None | Some `Null -> None | Some x -> Some ((match Poll.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "poll_answer";
          let poll_answer = match List.assoc_opt "poll_answer" fields with None | Some `Null -> None | Some x -> Some ((match PollAnswer.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "my_chat_member";
          let my_chat_member = match List.assoc_opt "my_chat_member" fields with None | Some `Null -> None | Some x -> Some ((match ChatMemberUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_member";
          let chat_member = match List.assoc_opt "chat_member" fields with None | Some `Null -> None | Some x -> Some ((match ChatMemberUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_join_request";
          let chat_join_request = match List.assoc_opt "chat_join_request" fields with None | Some `Null -> None | Some x -> Some ((match ChatJoinRequest.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_boost";
          let chat_boost = match List.assoc_opt "chat_boost" fields with None | Some `Null -> None | Some x -> Some ((match ChatBoostUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "removed_chat_boost";
          let removed_chat_boost = match List.assoc_opt "removed_chat_boost" fields with None | Some `Null -> None | Some x -> Some ((match ChatBoostRemoved.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { update_id = update_id; message = message; edited_message = edited_message; channel_post = channel_post; edited_channel_post = edited_channel_post; business_connection = business_connection; business_message = business_message; edited_business_message = edited_business_message; deleted_business_messages = deleted_business_messages; message_reaction = message_reaction; message_reaction_count = message_reaction_count; inline_query = inline_query; chosen_inline_result = chosen_inline_result; callback_query = callback_query; shipping_query = shipping_query; pre_checkout_query = pre_checkout_query; purchased_paid_media = purchased_paid_media; poll = poll; poll_answer = poll_answer; my_chat_member = my_chat_member; chat_member = chat_member; chat_join_request = chat_join_request; chat_boost = chat_boost; removed_chat_boost = removed_chat_boost; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and April112025 : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    update_id : int64;
    message : Message.t option;
    edited_message : Message.t option;
    channel_post : Message.t option;
    edited_channel_post : Message.t option;
    business_connection : BusinessConnection.t option;
    business_message : Message.t option;
    edited_business_message : Message.t option;
    deleted_business_messages : BusinessMessagesDeleted.t option;
    message_reaction : MessageReactionUpdated.t option;
    message_reaction_count : MessageReactionCountUpdated.t option;
    inline_query : InlineQuery.t option;
    chosen_inline_result : ChosenInlineResult.t option;
    callback_query : CallbackQuery.t option;
    shipping_query : ShippingQuery.t option;
    pre_checkout_query : PreCheckoutQuery.t option;
    purchased_paid_media : PaidMediaPurchased.t option;
    poll : Poll.t option;
    poll_answer : PollAnswer.t option;
    my_chat_member : ChatMemberUpdated.t option;
    chat_member : ChatMemberUpdated.t option;
    chat_join_request : ChatJoinRequest.t option;
    chat_boost : ChatBoostUpdated.t option;
    removed_chat_boost : ChatBoostRemoved.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("update_id", `Intlit (Int64.to_string v.update_id));
      (match v.message with None -> ("message", `Null) | Some x -> ("message", Message.to_yojson x));
      (match v.edited_message with None -> ("edited_message", `Null) | Some x -> ("edited_message", Message.to_yojson x));
      (match v.channel_post with None -> ("channel_post", `Null) | Some x -> ("channel_post", Message.to_yojson x));
      (match v.edited_channel_post with None -> ("edited_channel_post", `Null) | Some x -> ("edited_channel_post", Message.to_yojson x));
      (match v.business_connection with None -> ("business_connection", `Null) | Some x -> ("business_connection", BusinessConnection.to_yojson x));
      (match v.business_message with None -> ("business_message", `Null) | Some x -> ("business_message", Message.to_yojson x));
      (match v.edited_business_message with None -> ("edited_business_message", `Null) | Some x -> ("edited_business_message", Message.to_yojson x));
      (match v.deleted_business_messages with None -> ("deleted_business_messages", `Null) | Some x -> ("deleted_business_messages", BusinessMessagesDeleted.to_yojson x));
      (match v.message_reaction with None -> ("message_reaction", `Null) | Some x -> ("message_reaction", MessageReactionUpdated.to_yojson x));
      (match v.message_reaction_count with None -> ("message_reaction_count", `Null) | Some x -> ("message_reaction_count", MessageReactionCountUpdated.to_yojson x));
      (match v.inline_query with None -> ("inline_query", `Null) | Some x -> ("inline_query", InlineQuery.to_yojson x));
      (match v.chosen_inline_result with None -> ("chosen_inline_result", `Null) | Some x -> ("chosen_inline_result", ChosenInlineResult.to_yojson x));
      (match v.callback_query with None -> ("callback_query", `Null) | Some x -> ("callback_query", CallbackQuery.to_yojson x));
      (match v.shipping_query with None -> ("shipping_query", `Null) | Some x -> ("shipping_query", ShippingQuery.to_yojson x));
      (match v.pre_checkout_query with None -> ("pre_checkout_query", `Null) | Some x -> ("pre_checkout_query", PreCheckoutQuery.to_yojson x));
      (match v.purchased_paid_media with None -> ("purchased_paid_media", `Null) | Some x -> ("purchased_paid_media", PaidMediaPurchased.to_yojson x));
      (match v.poll with None -> ("poll", `Null) | Some x -> ("poll", Poll.to_yojson x));
      (match v.poll_answer with None -> ("poll_answer", `Null) | Some x -> ("poll_answer", PollAnswer.to_yojson x));
      (match v.my_chat_member with None -> ("my_chat_member", `Null) | Some x -> ("my_chat_member", ChatMemberUpdated.to_yojson x));
      (match v.chat_member with None -> ("chat_member", `Null) | Some x -> ("chat_member", ChatMemberUpdated.to_yojson x));
      (match v.chat_join_request with None -> ("chat_join_request", `Null) | Some x -> ("chat_join_request", ChatJoinRequest.to_yojson x));
      (match v.chat_boost with None -> ("chat_boost", `Null) | Some x -> ("chat_boost", ChatBoostUpdated.to_yojson x));
      (match v.removed_chat_boost with None -> ("removed_chat_boost", `Null) | Some x -> ("removed_chat_boost", ChatBoostRemoved.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "update_id";
          let update_id = (match (List.assoc "update_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "update_id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message";
          let message = match List.assoc_opt "message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "edited_message";
          let edited_message = match List.assoc_opt "edited_message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "channel_post";
          let channel_post = match List.assoc_opt "channel_post" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "edited_channel_post";
          let edited_channel_post = match List.assoc_opt "edited_channel_post" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "business_connection";
          let business_connection = match List.assoc_opt "business_connection" fields with None | Some `Null -> None | Some x -> Some ((match BusinessConnection.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "business_message";
          let business_message = match List.assoc_opt "business_message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "edited_business_message";
          let edited_business_message = match List.assoc_opt "edited_business_message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "deleted_business_messages";
          let deleted_business_messages = match List.assoc_opt "deleted_business_messages" fields with None | Some `Null -> None | Some x -> Some ((match BusinessMessagesDeleted.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message_reaction";
          let message_reaction = match List.assoc_opt "message_reaction" fields with None | Some `Null -> None | Some x -> Some ((match MessageReactionUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message_reaction_count";
          let message_reaction_count = match List.assoc_opt "message_reaction_count" fields with None | Some `Null -> None | Some x -> Some ((match MessageReactionCountUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "inline_query";
          let inline_query = match List.assoc_opt "inline_query" fields with None | Some `Null -> None | Some x -> Some ((match InlineQuery.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chosen_inline_result";
          let chosen_inline_result = match List.assoc_opt "chosen_inline_result" fields with None | Some `Null -> None | Some x -> Some ((match ChosenInlineResult.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "callback_query";
          let callback_query = match List.assoc_opt "callback_query" fields with None | Some `Null -> None | Some x -> Some ((match CallbackQuery.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "shipping_query";
          let shipping_query = match List.assoc_opt "shipping_query" fields with None | Some `Null -> None | Some x -> Some ((match ShippingQuery.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "pre_checkout_query";
          let pre_checkout_query = match List.assoc_opt "pre_checkout_query" fields with None | Some `Null -> None | Some x -> Some ((match PreCheckoutQuery.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "purchased_paid_media";
          let purchased_paid_media = match List.assoc_opt "purchased_paid_media" fields with None | Some `Null -> None | Some x -> Some ((match PaidMediaPurchased.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "poll";
          let poll = match List.assoc_opt "poll" fields with None | Some `Null -> None | Some x -> Some ((match Poll.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "poll_answer";
          let poll_answer = match List.assoc_opt "poll_answer" fields with None | Some `Null -> None | Some x -> Some ((match PollAnswer.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "my_chat_member";
          let my_chat_member = match List.assoc_opt "my_chat_member" fields with None | Some `Null -> None | Some x -> Some ((match ChatMemberUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_member";
          let chat_member = match List.assoc_opt "chat_member" fields with None | Some `Null -> None | Some x -> Some ((match ChatMemberUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_join_request";
          let chat_join_request = match List.assoc_opt "chat_join_request" fields with None | Some `Null -> None | Some x -> Some ((match ChatJoinRequest.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_boost";
          let chat_boost = match List.assoc_opt "chat_boost" fields with None | Some `Null -> None | Some x -> Some ((match ChatBoostUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "removed_chat_boost";
          let removed_chat_boost = match List.assoc_opt "removed_chat_boost" fields with None | Some `Null -> None | Some x -> Some ((match ChatBoostRemoved.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { update_id = update_id; message = message; edited_message = edited_message; channel_post = channel_post; edited_channel_post = edited_channel_post; business_connection = business_connection; business_message = business_message; edited_business_message = edited_business_message; deleted_business_messages = deleted_business_messages; message_reaction = message_reaction; message_reaction_count = message_reaction_count; inline_query = inline_query; chosen_inline_result = chosen_inline_result; callback_query = callback_query; shipping_query = shipping_query; pre_checkout_query = pre_checkout_query; purchased_paid_media = purchased_paid_media; poll = poll; poll_answer = poll_answer; my_chat_member = my_chat_member; chat_member = chat_member; chat_join_request = chat_join_request; chat_boost = chat_boost; removed_chat_boost = removed_chat_boost; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and MakingRequestsWhenGettingUpdates : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    update_id : int64;
    message : Message.t option;
    edited_message : Message.t option;
    channel_post : Message.t option;
    edited_channel_post : Message.t option;
    business_connection : BusinessConnection.t option;
    business_message : Message.t option;
    edited_business_message : Message.t option;
    deleted_business_messages : BusinessMessagesDeleted.t option;
    message_reaction : MessageReactionUpdated.t option;
    message_reaction_count : MessageReactionCountUpdated.t option;
    inline_query : InlineQuery.t option;
    chosen_inline_result : ChosenInlineResult.t option;
    callback_query : CallbackQuery.t option;
    shipping_query : ShippingQuery.t option;
    pre_checkout_query : PreCheckoutQuery.t option;
    purchased_paid_media : PaidMediaPurchased.t option;
    poll : Poll.t option;
    poll_answer : PollAnswer.t option;
    my_chat_member : ChatMemberUpdated.t option;
    chat_member : ChatMemberUpdated.t option;
    chat_join_request : ChatJoinRequest.t option;
    chat_boost : ChatBoostUpdated.t option;
    removed_chat_boost : ChatBoostRemoved.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("update_id", `Intlit (Int64.to_string v.update_id));
      (match v.message with None -> ("message", `Null) | Some x -> ("message", Message.to_yojson x));
      (match v.edited_message with None -> ("edited_message", `Null) | Some x -> ("edited_message", Message.to_yojson x));
      (match v.channel_post with None -> ("channel_post", `Null) | Some x -> ("channel_post", Message.to_yojson x));
      (match v.edited_channel_post with None -> ("edited_channel_post", `Null) | Some x -> ("edited_channel_post", Message.to_yojson x));
      (match v.business_connection with None -> ("business_connection", `Null) | Some x -> ("business_connection", BusinessConnection.to_yojson x));
      (match v.business_message with None -> ("business_message", `Null) | Some x -> ("business_message", Message.to_yojson x));
      (match v.edited_business_message with None -> ("edited_business_message", `Null) | Some x -> ("edited_business_message", Message.to_yojson x));
      (match v.deleted_business_messages with None -> ("deleted_business_messages", `Null) | Some x -> ("deleted_business_messages", BusinessMessagesDeleted.to_yojson x));
      (match v.message_reaction with None -> ("message_reaction", `Null) | Some x -> ("message_reaction", MessageReactionUpdated.to_yojson x));
      (match v.message_reaction_count with None -> ("message_reaction_count", `Null) | Some x -> ("message_reaction_count", MessageReactionCountUpdated.to_yojson x));
      (match v.inline_query with None -> ("inline_query", `Null) | Some x -> ("inline_query", InlineQuery.to_yojson x));
      (match v.chosen_inline_result with None -> ("chosen_inline_result", `Null) | Some x -> ("chosen_inline_result", ChosenInlineResult.to_yojson x));
      (match v.callback_query with None -> ("callback_query", `Null) | Some x -> ("callback_query", CallbackQuery.to_yojson x));
      (match v.shipping_query with None -> ("shipping_query", `Null) | Some x -> ("shipping_query", ShippingQuery.to_yojson x));
      (match v.pre_checkout_query with None -> ("pre_checkout_query", `Null) | Some x -> ("pre_checkout_query", PreCheckoutQuery.to_yojson x));
      (match v.purchased_paid_media with None -> ("purchased_paid_media", `Null) | Some x -> ("purchased_paid_media", PaidMediaPurchased.to_yojson x));
      (match v.poll with None -> ("poll", `Null) | Some x -> ("poll", Poll.to_yojson x));
      (match v.poll_answer with None -> ("poll_answer", `Null) | Some x -> ("poll_answer", PollAnswer.to_yojson x));
      (match v.my_chat_member with None -> ("my_chat_member", `Null) | Some x -> ("my_chat_member", ChatMemberUpdated.to_yojson x));
      (match v.chat_member with None -> ("chat_member", `Null) | Some x -> ("chat_member", ChatMemberUpdated.to_yojson x));
      (match v.chat_join_request with None -> ("chat_join_request", `Null) | Some x -> ("chat_join_request", ChatJoinRequest.to_yojson x));
      (match v.chat_boost with None -> ("chat_boost", `Null) | Some x -> ("chat_boost", ChatBoostUpdated.to_yojson x));
      (match v.removed_chat_boost with None -> ("removed_chat_boost", `Null) | Some x -> ("removed_chat_boost", ChatBoostRemoved.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "update_id";
          let update_id = (match (List.assoc "update_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "update_id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message";
          let message = match List.assoc_opt "message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "edited_message";
          let edited_message = match List.assoc_opt "edited_message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "channel_post";
          let channel_post = match List.assoc_opt "channel_post" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "edited_channel_post";
          let edited_channel_post = match List.assoc_opt "edited_channel_post" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "business_connection";
          let business_connection = match List.assoc_opt "business_connection" fields with None | Some `Null -> None | Some x -> Some ((match BusinessConnection.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "business_message";
          let business_message = match List.assoc_opt "business_message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "edited_business_message";
          let edited_business_message = match List.assoc_opt "edited_business_message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "deleted_business_messages";
          let deleted_business_messages = match List.assoc_opt "deleted_business_messages" fields with None | Some `Null -> None | Some x -> Some ((match BusinessMessagesDeleted.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message_reaction";
          let message_reaction = match List.assoc_opt "message_reaction" fields with None | Some `Null -> None | Some x -> Some ((match MessageReactionUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message_reaction_count";
          let message_reaction_count = match List.assoc_opt "message_reaction_count" fields with None | Some `Null -> None | Some x -> Some ((match MessageReactionCountUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "inline_query";
          let inline_query = match List.assoc_opt "inline_query" fields with None | Some `Null -> None | Some x -> Some ((match InlineQuery.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chosen_inline_result";
          let chosen_inline_result = match List.assoc_opt "chosen_inline_result" fields with None | Some `Null -> None | Some x -> Some ((match ChosenInlineResult.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "callback_query";
          let callback_query = match List.assoc_opt "callback_query" fields with None | Some `Null -> None | Some x -> Some ((match CallbackQuery.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "shipping_query";
          let shipping_query = match List.assoc_opt "shipping_query" fields with None | Some `Null -> None | Some x -> Some ((match ShippingQuery.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "pre_checkout_query";
          let pre_checkout_query = match List.assoc_opt "pre_checkout_query" fields with None | Some `Null -> None | Some x -> Some ((match PreCheckoutQuery.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "purchased_paid_media";
          let purchased_paid_media = match List.assoc_opt "purchased_paid_media" fields with None | Some `Null -> None | Some x -> Some ((match PaidMediaPurchased.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "poll";
          let poll = match List.assoc_opt "poll" fields with None | Some `Null -> None | Some x -> Some ((match Poll.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "poll_answer";
          let poll_answer = match List.assoc_opt "poll_answer" fields with None | Some `Null -> None | Some x -> Some ((match PollAnswer.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "my_chat_member";
          let my_chat_member = match List.assoc_opt "my_chat_member" fields with None | Some `Null -> None | Some x -> Some ((match ChatMemberUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_member";
          let chat_member = match List.assoc_opt "chat_member" fields with None | Some `Null -> None | Some x -> Some ((match ChatMemberUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_join_request";
          let chat_join_request = match List.assoc_opt "chat_join_request" fields with None | Some `Null -> None | Some x -> Some ((match ChatJoinRequest.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_boost";
          let chat_boost = match List.assoc_opt "chat_boost" fields with None | Some `Null -> None | Some x -> Some ((match ChatBoostUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "removed_chat_boost";
          let removed_chat_boost = match List.assoc_opt "removed_chat_boost" fields with None | Some `Null -> None | Some x -> Some ((match ChatBoostRemoved.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { update_id = update_id; message = message; edited_message = edited_message; channel_post = channel_post; edited_channel_post = edited_channel_post; business_connection = business_connection; business_message = business_message; edited_business_message = edited_business_message; deleted_business_messages = deleted_business_messages; message_reaction = message_reaction; message_reaction_count = message_reaction_count; inline_query = inline_query; chosen_inline_result = chosen_inline_result; callback_query = callback_query; shipping_query = shipping_query; pre_checkout_query = pre_checkout_query; purchased_paid_media = purchased_paid_media; poll = poll; poll_answer = poll_answer; my_chat_member = my_chat_member; chat_member = chat_member; chat_join_request = chat_join_request; chat_boost = chat_boost; removed_chat_boost = removed_chat_boost; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and DoINeedALocalBotAPIServer : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    update_id : int64;
    message : Message.t option;
    edited_message : Message.t option;
    channel_post : Message.t option;
    edited_channel_post : Message.t option;
    business_connection : BusinessConnection.t option;
    business_message : Message.t option;
    edited_business_message : Message.t option;
    deleted_business_messages : BusinessMessagesDeleted.t option;
    message_reaction : MessageReactionUpdated.t option;
    message_reaction_count : MessageReactionCountUpdated.t option;
    inline_query : InlineQuery.t option;
    chosen_inline_result : ChosenInlineResult.t option;
    callback_query : CallbackQuery.t option;
    shipping_query : ShippingQuery.t option;
    pre_checkout_query : PreCheckoutQuery.t option;
    purchased_paid_media : PaidMediaPurchased.t option;
    poll : Poll.t option;
    poll_answer : PollAnswer.t option;
    my_chat_member : ChatMemberUpdated.t option;
    chat_member : ChatMemberUpdated.t option;
    chat_join_request : ChatJoinRequest.t option;
    chat_boost : ChatBoostUpdated.t option;
    removed_chat_boost : ChatBoostRemoved.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("update_id", `Intlit (Int64.to_string v.update_id));
      (match v.message with None -> ("message", `Null) | Some x -> ("message", Message.to_yojson x));
      (match v.edited_message with None -> ("edited_message", `Null) | Some x -> ("edited_message", Message.to_yojson x));
      (match v.channel_post with None -> ("channel_post", `Null) | Some x -> ("channel_post", Message.to_yojson x));
      (match v.edited_channel_post with None -> ("edited_channel_post", `Null) | Some x -> ("edited_channel_post", Message.to_yojson x));
      (match v.business_connection with None -> ("business_connection", `Null) | Some x -> ("business_connection", BusinessConnection.to_yojson x));
      (match v.business_message with None -> ("business_message", `Null) | Some x -> ("business_message", Message.to_yojson x));
      (match v.edited_business_message with None -> ("edited_business_message", `Null) | Some x -> ("edited_business_message", Message.to_yojson x));
      (match v.deleted_business_messages with None -> ("deleted_business_messages", `Null) | Some x -> ("deleted_business_messages", BusinessMessagesDeleted.to_yojson x));
      (match v.message_reaction with None -> ("message_reaction", `Null) | Some x -> ("message_reaction", MessageReactionUpdated.to_yojson x));
      (match v.message_reaction_count with None -> ("message_reaction_count", `Null) | Some x -> ("message_reaction_count", MessageReactionCountUpdated.to_yojson x));
      (match v.inline_query with None -> ("inline_query", `Null) | Some x -> ("inline_query", InlineQuery.to_yojson x));
      (match v.chosen_inline_result with None -> ("chosen_inline_result", `Null) | Some x -> ("chosen_inline_result", ChosenInlineResult.to_yojson x));
      (match v.callback_query with None -> ("callback_query", `Null) | Some x -> ("callback_query", CallbackQuery.to_yojson x));
      (match v.shipping_query with None -> ("shipping_query", `Null) | Some x -> ("shipping_query", ShippingQuery.to_yojson x));
      (match v.pre_checkout_query with None -> ("pre_checkout_query", `Null) | Some x -> ("pre_checkout_query", PreCheckoutQuery.to_yojson x));
      (match v.purchased_paid_media with None -> ("purchased_paid_media", `Null) | Some x -> ("purchased_paid_media", PaidMediaPurchased.to_yojson x));
      (match v.poll with None -> ("poll", `Null) | Some x -> ("poll", Poll.to_yojson x));
      (match v.poll_answer with None -> ("poll_answer", `Null) | Some x -> ("poll_answer", PollAnswer.to_yojson x));
      (match v.my_chat_member with None -> ("my_chat_member", `Null) | Some x -> ("my_chat_member", ChatMemberUpdated.to_yojson x));
      (match v.chat_member with None -> ("chat_member", `Null) | Some x -> ("chat_member", ChatMemberUpdated.to_yojson x));
      (match v.chat_join_request with None -> ("chat_join_request", `Null) | Some x -> ("chat_join_request", ChatJoinRequest.to_yojson x));
      (match v.chat_boost with None -> ("chat_boost", `Null) | Some x -> ("chat_boost", ChatBoostUpdated.to_yojson x));
      (match v.removed_chat_boost with None -> ("removed_chat_boost", `Null) | Some x -> ("removed_chat_boost", ChatBoostRemoved.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "update_id";
          let update_id = (match (List.assoc "update_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "update_id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message";
          let message = match List.assoc_opt "message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "edited_message";
          let edited_message = match List.assoc_opt "edited_message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "channel_post";
          let channel_post = match List.assoc_opt "channel_post" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "edited_channel_post";
          let edited_channel_post = match List.assoc_opt "edited_channel_post" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "business_connection";
          let business_connection = match List.assoc_opt "business_connection" fields with None | Some `Null -> None | Some x -> Some ((match BusinessConnection.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "business_message";
          let business_message = match List.assoc_opt "business_message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "edited_business_message";
          let edited_business_message = match List.assoc_opt "edited_business_message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "deleted_business_messages";
          let deleted_business_messages = match List.assoc_opt "deleted_business_messages" fields with None | Some `Null -> None | Some x -> Some ((match BusinessMessagesDeleted.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message_reaction";
          let message_reaction = match List.assoc_opt "message_reaction" fields with None | Some `Null -> None | Some x -> Some ((match MessageReactionUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message_reaction_count";
          let message_reaction_count = match List.assoc_opt "message_reaction_count" fields with None | Some `Null -> None | Some x -> Some ((match MessageReactionCountUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "inline_query";
          let inline_query = match List.assoc_opt "inline_query" fields with None | Some `Null -> None | Some x -> Some ((match InlineQuery.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chosen_inline_result";
          let chosen_inline_result = match List.assoc_opt "chosen_inline_result" fields with None | Some `Null -> None | Some x -> Some ((match ChosenInlineResult.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "callback_query";
          let callback_query = match List.assoc_opt "callback_query" fields with None | Some `Null -> None | Some x -> Some ((match CallbackQuery.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "shipping_query";
          let shipping_query = match List.assoc_opt "shipping_query" fields with None | Some `Null -> None | Some x -> Some ((match ShippingQuery.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "pre_checkout_query";
          let pre_checkout_query = match List.assoc_opt "pre_checkout_query" fields with None | Some `Null -> None | Some x -> Some ((match PreCheckoutQuery.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "purchased_paid_media";
          let purchased_paid_media = match List.assoc_opt "purchased_paid_media" fields with None | Some `Null -> None | Some x -> Some ((match PaidMediaPurchased.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "poll";
          let poll = match List.assoc_opt "poll" fields with None | Some `Null -> None | Some x -> Some ((match Poll.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "poll_answer";
          let poll_answer = match List.assoc_opt "poll_answer" fields with None | Some `Null -> None | Some x -> Some ((match PollAnswer.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "my_chat_member";
          let my_chat_member = match List.assoc_opt "my_chat_member" fields with None | Some `Null -> None | Some x -> Some ((match ChatMemberUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_member";
          let chat_member = match List.assoc_opt "chat_member" fields with None | Some `Null -> None | Some x -> Some ((match ChatMemberUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_join_request";
          let chat_join_request = match List.assoc_opt "chat_join_request" fields with None | Some `Null -> None | Some x -> Some ((match ChatJoinRequest.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_boost";
          let chat_boost = match List.assoc_opt "chat_boost" fields with None | Some `Null -> None | Some x -> Some ((match ChatBoostUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "removed_chat_boost";
          let removed_chat_boost = match List.assoc_opt "removed_chat_boost" fields with None | Some `Null -> None | Some x -> Some ((match ChatBoostRemoved.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { update_id = update_id; message = message; edited_message = edited_message; channel_post = channel_post; edited_channel_post = edited_channel_post; business_connection = business_connection; business_message = business_message; edited_business_message = edited_business_message; deleted_business_messages = deleted_business_messages; message_reaction = message_reaction; message_reaction_count = message_reaction_count; inline_query = inline_query; chosen_inline_result = chosen_inline_result; callback_query = callback_query; shipping_query = shipping_query; pre_checkout_query = pre_checkout_query; purchased_paid_media = purchased_paid_media; poll = poll; poll_answer = poll_answer; my_chat_member = my_chat_member; chat_member = chat_member; chat_join_request = chat_join_request; chat_boost = chat_boost; removed_chat_boost = removed_chat_boost; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and Update : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    update_id : int64;
    message : Message.t option;
    edited_message : Message.t option;
    channel_post : Message.t option;
    edited_channel_post : Message.t option;
    business_connection : BusinessConnection.t option;
    business_message : Message.t option;
    edited_business_message : Message.t option;
    deleted_business_messages : BusinessMessagesDeleted.t option;
    message_reaction : MessageReactionUpdated.t option;
    message_reaction_count : MessageReactionCountUpdated.t option;
    inline_query : InlineQuery.t option;
    chosen_inline_result : ChosenInlineResult.t option;
    callback_query : CallbackQuery.t option;
    shipping_query : ShippingQuery.t option;
    pre_checkout_query : PreCheckoutQuery.t option;
    purchased_paid_media : PaidMediaPurchased.t option;
    poll : Poll.t option;
    poll_answer : PollAnswer.t option;
    my_chat_member : ChatMemberUpdated.t option;
    chat_member : ChatMemberUpdated.t option;
    chat_join_request : ChatJoinRequest.t option;
    chat_boost : ChatBoostUpdated.t option;
    removed_chat_boost : ChatBoostRemoved.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("update_id", `Intlit (Int64.to_string v.update_id));
      (match v.message with None -> ("message", `Null) | Some x -> ("message", Message.to_yojson x));
      (match v.edited_message with None -> ("edited_message", `Null) | Some x -> ("edited_message", Message.to_yojson x));
      (match v.channel_post with None -> ("channel_post", `Null) | Some x -> ("channel_post", Message.to_yojson x));
      (match v.edited_channel_post with None -> ("edited_channel_post", `Null) | Some x -> ("edited_channel_post", Message.to_yojson x));
      (match v.business_connection with None -> ("business_connection", `Null) | Some x -> ("business_connection", BusinessConnection.to_yojson x));
      (match v.business_message with None -> ("business_message", `Null) | Some x -> ("business_message", Message.to_yojson x));
      (match v.edited_business_message with None -> ("edited_business_message", `Null) | Some x -> ("edited_business_message", Message.to_yojson x));
      (match v.deleted_business_messages with None -> ("deleted_business_messages", `Null) | Some x -> ("deleted_business_messages", BusinessMessagesDeleted.to_yojson x));
      (match v.message_reaction with None -> ("message_reaction", `Null) | Some x -> ("message_reaction", MessageReactionUpdated.to_yojson x));
      (match v.message_reaction_count with None -> ("message_reaction_count", `Null) | Some x -> ("message_reaction_count", MessageReactionCountUpdated.to_yojson x));
      (match v.inline_query with None -> ("inline_query", `Null) | Some x -> ("inline_query", InlineQuery.to_yojson x));
      (match v.chosen_inline_result with None -> ("chosen_inline_result", `Null) | Some x -> ("chosen_inline_result", ChosenInlineResult.to_yojson x));
      (match v.callback_query with None -> ("callback_query", `Null) | Some x -> ("callback_query", CallbackQuery.to_yojson x));
      (match v.shipping_query with None -> ("shipping_query", `Null) | Some x -> ("shipping_query", ShippingQuery.to_yojson x));
      (match v.pre_checkout_query with None -> ("pre_checkout_query", `Null) | Some x -> ("pre_checkout_query", PreCheckoutQuery.to_yojson x));
      (match v.purchased_paid_media with None -> ("purchased_paid_media", `Null) | Some x -> ("purchased_paid_media", PaidMediaPurchased.to_yojson x));
      (match v.poll with None -> ("poll", `Null) | Some x -> ("poll", Poll.to_yojson x));
      (match v.poll_answer with None -> ("poll_answer", `Null) | Some x -> ("poll_answer", PollAnswer.to_yojson x));
      (match v.my_chat_member with None -> ("my_chat_member", `Null) | Some x -> ("my_chat_member", ChatMemberUpdated.to_yojson x));
      (match v.chat_member with None -> ("chat_member", `Null) | Some x -> ("chat_member", ChatMemberUpdated.to_yojson x));
      (match v.chat_join_request with None -> ("chat_join_request", `Null) | Some x -> ("chat_join_request", ChatJoinRequest.to_yojson x));
      (match v.chat_boost with None -> ("chat_boost", `Null) | Some x -> ("chat_boost", ChatBoostUpdated.to_yojson x));
      (match v.removed_chat_boost with None -> ("removed_chat_boost", `Null) | Some x -> ("removed_chat_boost", ChatBoostRemoved.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "update_id";
          let update_id = (match (List.assoc "update_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "update_id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message";
          let message = match List.assoc_opt "message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "edited_message";
          let edited_message = match List.assoc_opt "edited_message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "channel_post";
          let channel_post = match List.assoc_opt "channel_post" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "edited_channel_post";
          let edited_channel_post = match List.assoc_opt "edited_channel_post" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "business_connection";
          let business_connection = match List.assoc_opt "business_connection" fields with None | Some `Null -> None | Some x -> Some ((match BusinessConnection.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "business_message";
          let business_message = match List.assoc_opt "business_message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "edited_business_message";
          let edited_business_message = match List.assoc_opt "edited_business_message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "deleted_business_messages";
          let deleted_business_messages = match List.assoc_opt "deleted_business_messages" fields with None | Some `Null -> None | Some x -> Some ((match BusinessMessagesDeleted.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message_reaction";
          let message_reaction = match List.assoc_opt "message_reaction" fields with None | Some `Null -> None | Some x -> Some ((match MessageReactionUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message_reaction_count";
          let message_reaction_count = match List.assoc_opt "message_reaction_count" fields with None | Some `Null -> None | Some x -> Some ((match MessageReactionCountUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "inline_query";
          let inline_query = match List.assoc_opt "inline_query" fields with None | Some `Null -> None | Some x -> Some ((match InlineQuery.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chosen_inline_result";
          let chosen_inline_result = match List.assoc_opt "chosen_inline_result" fields with None | Some `Null -> None | Some x -> Some ((match ChosenInlineResult.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "callback_query";
          let callback_query = match List.assoc_opt "callback_query" fields with None | Some `Null -> None | Some x -> Some ((match CallbackQuery.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "shipping_query";
          let shipping_query = match List.assoc_opt "shipping_query" fields with None | Some `Null -> None | Some x -> Some ((match ShippingQuery.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "pre_checkout_query";
          let pre_checkout_query = match List.assoc_opt "pre_checkout_query" fields with None | Some `Null -> None | Some x -> Some ((match PreCheckoutQuery.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "purchased_paid_media";
          let purchased_paid_media = match List.assoc_opt "purchased_paid_media" fields with None | Some `Null -> None | Some x -> Some ((match PaidMediaPurchased.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "poll";
          let poll = match List.assoc_opt "poll" fields with None | Some `Null -> None | Some x -> Some ((match Poll.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "poll_answer";
          let poll_answer = match List.assoc_opt "poll_answer" fields with None | Some `Null -> None | Some x -> Some ((match PollAnswer.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "my_chat_member";
          let my_chat_member = match List.assoc_opt "my_chat_member" fields with None | Some `Null -> None | Some x -> Some ((match ChatMemberUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_member";
          let chat_member = match List.assoc_opt "chat_member" fields with None | Some `Null -> None | Some x -> Some ((match ChatMemberUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_join_request";
          let chat_join_request = match List.assoc_opt "chat_join_request" fields with None | Some `Null -> None | Some x -> Some ((match ChatJoinRequest.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_boost";
          let chat_boost = match List.assoc_opt "chat_boost" fields with None | Some `Null -> None | Some x -> Some ((match ChatBoostUpdated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "removed_chat_boost";
          let removed_chat_boost = match List.assoc_opt "removed_chat_boost" fields with None | Some `Null -> None | Some x -> Some ((match ChatBoostRemoved.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { update_id = update_id; message = message; edited_message = edited_message; channel_post = channel_post; edited_channel_post = edited_channel_post; business_connection = business_connection; business_message = business_message; edited_business_message = edited_business_message; deleted_business_messages = deleted_business_messages; message_reaction = message_reaction; message_reaction_count = message_reaction_count; inline_query = inline_query; chosen_inline_result = chosen_inline_result; callback_query = callback_query; shipping_query = shipping_query; pre_checkout_query = pre_checkout_query; purchased_paid_media = purchased_paid_media; poll = poll; poll_answer = poll_answer; my_chat_member = my_chat_member; chat_member = chat_member; chat_join_request = chat_join_request; chat_boost = chat_boost; removed_chat_boost = removed_chat_boost; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ChatFullInfo : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    id : int64;
    type_ : string;
    title : string option;
    username : string option;
    first_name : string option;
    last_name : string option;
    is_forum : bool option;
    is_direct_messages : bool option;
    accent_color_id : int64;
    max_reaction_count : int64;
    photo : ChatPhoto.t option;
    active_usernames : string list option;
    birthdate : Birthdate.t option;
    business_intro : BusinessIntro.t option;
    business_location : BusinessLocation.t option;
    business_opening_hours : BusinessOpeningHours.t option;
    personal_chat : Chat.t option;
    parent_chat : Chat.t option;
    available_reactions : ReactionType.t list option;
    background_custom_emoji_id : string option;
    profile_accent_color_id : int64 option;
    profile_background_custom_emoji_id : string option;
    emoji_status_custom_emoji_id : string option;
    emoji_status_expiration_date : int64 option;
    bio : string option;
    has_private_forwards : bool option;
    has_restricted_voice_and_video_messages : bool option;
    join_to_send_messages : bool option;
    join_by_request : bool option;
    description : string option;
    invite_link : string option;
    pinned_message : Message.t option;
    permissions : ChatPermissions.t option;
    accepted_gift_types : AcceptedGiftTypes.t;
    can_send_paid_media : bool option;
    slow_mode_delay : int64 option;
    unrestrict_boost_count : int64 option;
    message_auto_delete_time : int64 option;
    has_aggressive_anti_spam_enabled : bool option;
    has_hidden_members : bool option;
    has_protected_content : bool option;
    has_visible_history : bool option;
    sticker_set_name : string option;
    can_set_sticker_set : bool option;
    custom_emoji_sticker_set_name : string option;
    linked_chat_id : int64 option;
    location : ChatLocation.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("id", `Intlit (Int64.to_string v.id));
      ("type", `String v.type_);
      (match v.title with None -> ("title", `Null) | Some x -> ("title", `String x));
      (match v.username with None -> ("username", `Null) | Some x -> ("username", `String x));
      (match v.first_name with None -> ("first_name", `Null) | Some x -> ("first_name", `String x));
      (match v.last_name with None -> ("last_name", `Null) | Some x -> ("last_name", `String x));
      (match v.is_forum with None -> ("is_forum", `Null) | Some x -> ("is_forum", `Bool x));
      (match v.is_direct_messages with None -> ("is_direct_messages", `Null) | Some x -> ("is_direct_messages", `Bool x));
      ("accent_color_id", `Intlit (Int64.to_string v.accent_color_id));
      ("max_reaction_count", `Intlit (Int64.to_string v.max_reaction_count));
      (match v.photo with None -> ("photo", `Null) | Some x -> ("photo", ChatPhoto.to_yojson x));
      (match v.active_usernames with None -> ("active_usernames", `Null) | Some x -> ("active_usernames", `List (List.map (fun x -> `String x) x)));
      (match v.birthdate with None -> ("birthdate", `Null) | Some x -> ("birthdate", Birthdate.to_yojson x));
      (match v.business_intro with None -> ("business_intro", `Null) | Some x -> ("business_intro", BusinessIntro.to_yojson x));
      (match v.business_location with None -> ("business_location", `Null) | Some x -> ("business_location", BusinessLocation.to_yojson x));
      (match v.business_opening_hours with None -> ("business_opening_hours", `Null) | Some x -> ("business_opening_hours", BusinessOpeningHours.to_yojson x));
      (match v.personal_chat with None -> ("personal_chat", `Null) | Some x -> ("personal_chat", Chat.to_yojson x));
      (match v.parent_chat with None -> ("parent_chat", `Null) | Some x -> ("parent_chat", Chat.to_yojson x));
      (match v.available_reactions with None -> ("available_reactions", `Null) | Some x -> ("available_reactions", `List (List.map (fun x -> ReactionType.to_yojson x) x)));
      (match v.background_custom_emoji_id with None -> ("background_custom_emoji_id", `Null) | Some x -> ("background_custom_emoji_id", `String x));
      (match v.profile_accent_color_id with None -> ("profile_accent_color_id", `Null) | Some x -> ("profile_accent_color_id", `Intlit (Int64.to_string x)));
      (match v.profile_background_custom_emoji_id with None -> ("profile_background_custom_emoji_id", `Null) | Some x -> ("profile_background_custom_emoji_id", `String x));
      (match v.emoji_status_custom_emoji_id with None -> ("emoji_status_custom_emoji_id", `Null) | Some x -> ("emoji_status_custom_emoji_id", `String x));
      (match v.emoji_status_expiration_date with None -> ("emoji_status_expiration_date", `Null) | Some x -> ("emoji_status_expiration_date", `Intlit (Int64.to_string x)));
      (match v.bio with None -> ("bio", `Null) | Some x -> ("bio", `String x));
      (match v.has_private_forwards with None -> ("has_private_forwards", `Null) | Some x -> ("has_private_forwards", `Bool x));
      (match v.has_restricted_voice_and_video_messages with None -> ("has_restricted_voice_and_video_messages", `Null) | Some x -> ("has_restricted_voice_and_video_messages", `Bool x));
      (match v.join_to_send_messages with None -> ("join_to_send_messages", `Null) | Some x -> ("join_to_send_messages", `Bool x));
      (match v.join_by_request with None -> ("join_by_request", `Null) | Some x -> ("join_by_request", `Bool x));
      (match v.description with None -> ("description", `Null) | Some x -> ("description", `String x));
      (match v.invite_link with None -> ("invite_link", `Null) | Some x -> ("invite_link", `String x));
      (match v.pinned_message with None -> ("pinned_message", `Null) | Some x -> ("pinned_message", Message.to_yojson x));
      (match v.permissions with None -> ("permissions", `Null) | Some x -> ("permissions", ChatPermissions.to_yojson x));
      ("accepted_gift_types", AcceptedGiftTypes.to_yojson v.accepted_gift_types);
      (match v.can_send_paid_media with None -> ("can_send_paid_media", `Null) | Some x -> ("can_send_paid_media", `Bool x));
      (match v.slow_mode_delay with None -> ("slow_mode_delay", `Null) | Some x -> ("slow_mode_delay", `Intlit (Int64.to_string x)));
      (match v.unrestrict_boost_count with None -> ("unrestrict_boost_count", `Null) | Some x -> ("unrestrict_boost_count", `Intlit (Int64.to_string x)));
      (match v.message_auto_delete_time with None -> ("message_auto_delete_time", `Null) | Some x -> ("message_auto_delete_time", `Intlit (Int64.to_string x)));
      (match v.has_aggressive_anti_spam_enabled with None -> ("has_aggressive_anti_spam_enabled", `Null) | Some x -> ("has_aggressive_anti_spam_enabled", `Bool x));
      (match v.has_hidden_members with None -> ("has_hidden_members", `Null) | Some x -> ("has_hidden_members", `Bool x));
      (match v.has_protected_content with None -> ("has_protected_content", `Null) | Some x -> ("has_protected_content", `Bool x));
      (match v.has_visible_history with None -> ("has_visible_history", `Null) | Some x -> ("has_visible_history", `Bool x));
      (match v.sticker_set_name with None -> ("sticker_set_name", `Null) | Some x -> ("sticker_set_name", `String x));
      (match v.can_set_sticker_set with None -> ("can_set_sticker_set", `Null) | Some x -> ("can_set_sticker_set", `Bool x));
      (match v.custom_emoji_sticker_set_name with None -> ("custom_emoji_sticker_set_name", `Null) | Some x -> ("custom_emoji_sticker_set_name", `String x));
      (match v.linked_chat_id with None -> ("linked_chat_id", `Null) | Some x -> ("linked_chat_id", `Intlit (Int64.to_string x)));
      (match v.location with None -> ("location", `Null) | Some x -> ("location", ChatLocation.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "id";
          let id = (match (List.assoc "id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "type";
          let type_ = (to_string (List.assoc "type" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "title";
          let title = match List.assoc_opt "title" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "username";
          let username = match List.assoc_opt "username" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "first_name";
          let first_name = match List.assoc_opt "first_name" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "last_name";
          let last_name = match List.assoc_opt "last_name" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_forum";
          let is_forum = match List.assoc_opt "is_forum" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_direct_messages";
          let is_direct_messages = match List.assoc_opt "is_direct_messages" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "accent_color_id";
          let accent_color_id = (match (List.assoc "accent_color_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "accent_color_id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "max_reaction_count";
          let max_reaction_count = (match (List.assoc "max_reaction_count" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "max_reaction_count" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "photo";
          let photo = match List.assoc_opt "photo" fields with None | Some `Null -> None | Some x -> Some ((match ChatPhoto.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "active_usernames";
          let active_usernames = match List.assoc_opt "active_usernames" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (to_string x)) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "birthdate";
          let birthdate = match List.assoc_opt "birthdate" fields with None | Some `Null -> None | Some x -> Some ((match Birthdate.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "business_intro";
          let business_intro = match List.assoc_opt "business_intro" fields with None | Some `Null -> None | Some x -> Some ((match BusinessIntro.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "business_location";
          let business_location = match List.assoc_opt "business_location" fields with None | Some `Null -> None | Some x -> Some ((match BusinessLocation.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "business_opening_hours";
          let business_opening_hours = match List.assoc_opt "business_opening_hours" fields with None | Some `Null -> None | Some x -> Some ((match BusinessOpeningHours.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "personal_chat";
          let personal_chat = match List.assoc_opt "personal_chat" fields with None | Some `Null -> None | Some x -> Some ((match Chat.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "parent_chat";
          let parent_chat = match List.assoc_opt "parent_chat" fields with None | Some `Null -> None | Some x -> Some ((match Chat.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "available_reactions";
          let available_reactions = match List.assoc_opt "available_reactions" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match ReactionType.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "background_custom_emoji_id";
          let background_custom_emoji_id = match List.assoc_opt "background_custom_emoji_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "profile_accent_color_id";
          let profile_accent_color_id = match List.assoc_opt "profile_accent_color_id" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "profile_background_custom_emoji_id";
          let profile_background_custom_emoji_id = match List.assoc_opt "profile_background_custom_emoji_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "emoji_status_custom_emoji_id";
          let emoji_status_custom_emoji_id = match List.assoc_opt "emoji_status_custom_emoji_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "emoji_status_expiration_date";
          let emoji_status_expiration_date = match List.assoc_opt "emoji_status_expiration_date" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "bio";
          let bio = match List.assoc_opt "bio" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "has_private_forwards";
          let has_private_forwards = match List.assoc_opt "has_private_forwards" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "has_restricted_voice_and_video_messages";
          let has_restricted_voice_and_video_messages = match List.assoc_opt "has_restricted_voice_and_video_messages" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "join_to_send_messages";
          let join_to_send_messages = match List.assoc_opt "join_to_send_messages" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "join_by_request";
          let join_by_request = match List.assoc_opt "join_by_request" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "description";
          let description = match List.assoc_opt "description" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "invite_link";
          let invite_link = match List.assoc_opt "invite_link" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "pinned_message";
          let pinned_message = match List.assoc_opt "pinned_message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "permissions";
          let permissions = match List.assoc_opt "permissions" fields with None | Some `Null -> None | Some x -> Some ((match ChatPermissions.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "accepted_gift_types";
          let accepted_gift_types = (match AcceptedGiftTypes.of_yojson (List.assoc "accepted_gift_types" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "accepted_gift_types" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_send_paid_media";
          let can_send_paid_media = match List.assoc_opt "can_send_paid_media" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "slow_mode_delay";
          let slow_mode_delay = match List.assoc_opt "slow_mode_delay" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "unrestrict_boost_count";
          let unrestrict_boost_count = match List.assoc_opt "unrestrict_boost_count" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message_auto_delete_time";
          let message_auto_delete_time = match List.assoc_opt "message_auto_delete_time" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "has_aggressive_anti_spam_enabled";
          let has_aggressive_anti_spam_enabled = match List.assoc_opt "has_aggressive_anti_spam_enabled" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "has_hidden_members";
          let has_hidden_members = match List.assoc_opt "has_hidden_members" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "has_protected_content";
          let has_protected_content = match List.assoc_opt "has_protected_content" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "has_visible_history";
          let has_visible_history = match List.assoc_opt "has_visible_history" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "sticker_set_name";
          let sticker_set_name = match List.assoc_opt "sticker_set_name" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "can_set_sticker_set";
          let can_set_sticker_set = match List.assoc_opt "can_set_sticker_set" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "custom_emoji_sticker_set_name";
          let custom_emoji_sticker_set_name = match List.assoc_opt "custom_emoji_sticker_set_name" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "linked_chat_id";
          let linked_chat_id = match List.assoc_opt "linked_chat_id" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "location";
          let location = match List.assoc_opt "location" fields with None | Some `Null -> None | Some x -> Some ((match ChatLocation.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { id = id; type_ = type_; title = title; username = username; first_name = first_name; last_name = last_name; is_forum = is_forum; is_direct_messages = is_direct_messages; accent_color_id = accent_color_id; max_reaction_count = max_reaction_count; photo = photo; active_usernames = active_usernames; birthdate = birthdate; business_intro = business_intro; business_location = business_location; business_opening_hours = business_opening_hours; personal_chat = personal_chat; parent_chat = parent_chat; available_reactions = available_reactions; background_custom_emoji_id = background_custom_emoji_id; profile_accent_color_id = profile_accent_color_id; profile_background_custom_emoji_id = profile_background_custom_emoji_id; emoji_status_custom_emoji_id = emoji_status_custom_emoji_id; emoji_status_expiration_date = emoji_status_expiration_date; bio = bio; has_private_forwards = has_private_forwards; has_restricted_voice_and_video_messages = has_restricted_voice_and_video_messages; join_to_send_messages = join_to_send_messages; join_by_request = join_by_request; description = description; invite_link = invite_link; pinned_message = pinned_message; permissions = permissions; accepted_gift_types = accepted_gift_types; can_send_paid_media = can_send_paid_media; slow_mode_delay = slow_mode_delay; unrestrict_boost_count = unrestrict_boost_count; message_auto_delete_time = message_auto_delete_time; has_aggressive_anti_spam_enabled = has_aggressive_anti_spam_enabled; has_hidden_members = has_hidden_members; has_protected_content = has_protected_content; has_visible_history = has_visible_history; sticker_set_name = sticker_set_name; can_set_sticker_set = can_set_sticker_set; custom_emoji_sticker_set_name = custom_emoji_sticker_set_name; linked_chat_id = linked_chat_id; location = location; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and Message : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    message_id : int64;
    message_thread_id : int64 option;
    direct_messages_topic : DirectMessagesTopic.t option;
    from : User.t option;
    sender_chat : Chat.t option;
    sender_boost_count : int64 option;
    sender_business_bot : User.t option;
    date : int64;
    business_connection_id : string option;
    chat : Chat.t;
    forward_origin : MessageOrigin.t option;
    is_topic_message : bool option;
    is_automatic_forward : bool option;
    reply_to_message : t option;
    external_reply : ExternalReplyInfo.t option;
    quote : TextQuote.t option;
    reply_to_story : Story.t option;
    reply_to_checklist_task_id : int64 option;
    via_bot : User.t option;
    edit_date : int64 option;
    has_protected_content : bool option;
    is_from_offline : bool option;
    is_paid_post : bool option;
    media_group_id : string option;
    author_signature : string option;
    paid_star_count : int64 option;
    text : string option;
    entities : MessageEntity.t list option;
    link_preview_options : LinkPreviewOptions.t option;
    suggested_post_info : SuggestedPostInfo.t option;
    effect_id : string option;
    animation : Animation.t option;
    audio : Audio.t option;
    document : Document.t option;
    paid_media : PaidMediaInfo.t option;
    photo : PhotoSize.t list option;
    sticker : Sticker.t option;
    story : Story.t option;
    video : Video.t option;
    video_note : VideoNote.t option;
    voice : Voice.t option;
    caption : string option;
    caption_entities : MessageEntity.t list option;
    show_caption_above_media : bool option;
    has_media_spoiler : bool option;
    checklist : Checklist.t option;
    contact : Contact.t option;
    dice : Dice.t option;
    game : Game.t option;
    poll : Poll.t option;
    venue : Venue.t option;
    location : Location.t option;
    new_chat_members : User.t list option;
    left_chat_member : User.t option;
    new_chat_title : string option;
    new_chat_photo : PhotoSize.t list option;
    delete_chat_photo : bool option;
    group_chat_created : bool option;
    supergroup_chat_created : bool option;
    channel_chat_created : bool option;
    message_auto_delete_timer_changed : MessageAutoDeleteTimerChanged.t option;
    migrate_to_chat_id : int64 option;
    migrate_from_chat_id : int64 option;
    pinned_message : MaybeInaccessibleMessage.t option;
    invoice : Invoice.t option;
    successful_payment : SuccessfulPayment.t option;
    refunded_payment : RefundedPayment.t option;
    users_shared : UsersShared.t option;
    chat_shared : ChatShared.t option;
    gift : GiftInfo.t option;
    unique_gift : UniqueGiftInfo.t option;
    connected_website : string option;
    write_access_allowed : WriteAccessAllowed.t option;
    passport_data : PassportData.t option;
    proximity_alert_triggered : ProximityAlertTriggered.t option;
    boost_added : ChatBoostAdded.t option;
    chat_background_set : ChatBackground.t option;
    checklist_tasks_done : ChecklistTasksDone.t option;
    checklist_tasks_added : ChecklistTasksAdded.t option;
    direct_message_price_changed : DirectMessagePriceChanged.t option;
    forum_topic_created : ForumTopicCreated.t option;
    forum_topic_edited : ForumTopicEdited.t option;
    forum_topic_closed : ForumTopicClosed.t option;
    forum_topic_reopened : ForumTopicReopened.t option;
    general_forum_topic_hidden : GeneralForumTopicHidden.t option;
    general_forum_topic_unhidden : GeneralForumTopicUnhidden.t option;
    giveaway_created : GiveawayCreated.t option;
    giveaway : Giveaway.t option;
    giveaway_winners : GiveawayWinners.t option;
    giveaway_completed : GiveawayCompleted.t option;
    paid_message_price_changed : PaidMessagePriceChanged.t option;
    suggested_post_approved : SuggestedPostApproved.t option;
    suggested_post_approval_failed : SuggestedPostApprovalFailed.t option;
    suggested_post_declined : SuggestedPostDeclined.t option;
    suggested_post_paid : SuggestedPostPaid.t option;
    suggested_post_refunded : SuggestedPostRefunded.t option;
    video_chat_scheduled : VideoChatScheduled.t option;
    video_chat_started : VideoChatStarted.t option;
    video_chat_ended : VideoChatEnded.t option;
    video_chat_participants_invited : VideoChatParticipantsInvited.t option;
    web_app_data : WebAppData.t option;
    reply_markup : InlineKeyboardMarkup.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("message_id", `Intlit (Int64.to_string v.message_id));
      (match v.message_thread_id with None -> ("message_thread_id", `Null) | Some x -> ("message_thread_id", `Intlit (Int64.to_string x)));
      (match v.direct_messages_topic with None -> ("direct_messages_topic", `Null) | Some x -> ("direct_messages_topic", DirectMessagesTopic.to_yojson x));
      (match v.from with None -> ("from", `Null) | Some x -> ("from", User.to_yojson x));
      (match v.sender_chat with None -> ("sender_chat", `Null) | Some x -> ("sender_chat", Chat.to_yojson x));
      (match v.sender_boost_count with None -> ("sender_boost_count", `Null) | Some x -> ("sender_boost_count", `Intlit (Int64.to_string x)));
      (match v.sender_business_bot with None -> ("sender_business_bot", `Null) | Some x -> ("sender_business_bot", User.to_yojson x));
      ("date", `Intlit (Int64.to_string v.date));
      (match v.business_connection_id with None -> ("business_connection_id", `Null) | Some x -> ("business_connection_id", `String x));
      ("chat", Chat.to_yojson v.chat);
      (match v.forward_origin with None -> ("forward_origin", `Null) | Some x -> ("forward_origin", MessageOrigin.to_yojson x));
      (match v.is_topic_message with None -> ("is_topic_message", `Null) | Some x -> ("is_topic_message", `Bool x));
      (match v.is_automatic_forward with None -> ("is_automatic_forward", `Null) | Some x -> ("is_automatic_forward", `Bool x));
      (match v.reply_to_message with None -> ("reply_to_message", `Null) | Some x -> ("reply_to_message", Message.to_yojson x));
      (match v.external_reply with None -> ("external_reply", `Null) | Some x -> ("external_reply", ExternalReplyInfo.to_yojson x));
      (match v.quote with None -> ("quote", `Null) | Some x -> ("quote", TextQuote.to_yojson x));
      (match v.reply_to_story with None -> ("reply_to_story", `Null) | Some x -> ("reply_to_story", Story.to_yojson x));
      (match v.reply_to_checklist_task_id with None -> ("reply_to_checklist_task_id", `Null) | Some x -> ("reply_to_checklist_task_id", `Intlit (Int64.to_string x)));
      (match v.via_bot with None -> ("via_bot", `Null) | Some x -> ("via_bot", User.to_yojson x));
      (match v.edit_date with None -> ("edit_date", `Null) | Some x -> ("edit_date", `Intlit (Int64.to_string x)));
      (match v.has_protected_content with None -> ("has_protected_content", `Null) | Some x -> ("has_protected_content", `Bool x));
      (match v.is_from_offline with None -> ("is_from_offline", `Null) | Some x -> ("is_from_offline", `Bool x));
      (match v.is_paid_post with None -> ("is_paid_post", `Null) | Some x -> ("is_paid_post", `Bool x));
      (match v.media_group_id with None -> ("media_group_id", `Null) | Some x -> ("media_group_id", `String x));
      (match v.author_signature with None -> ("author_signature", `Null) | Some x -> ("author_signature", `String x));
      (match v.paid_star_count with None -> ("paid_star_count", `Null) | Some x -> ("paid_star_count", `Intlit (Int64.to_string x)));
      (match v.text with None -> ("text", `Null) | Some x -> ("text", `String x));
      (match v.entities with None -> ("entities", `Null) | Some x -> ("entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.link_preview_options with None -> ("link_preview_options", `Null) | Some x -> ("link_preview_options", LinkPreviewOptions.to_yojson x));
      (match v.suggested_post_info with None -> ("suggested_post_info", `Null) | Some x -> ("suggested_post_info", SuggestedPostInfo.to_yojson x));
      (match v.effect_id with None -> ("effect_id", `Null) | Some x -> ("effect_id", `String x));
      (match v.animation with None -> ("animation", `Null) | Some x -> ("animation", Animation.to_yojson x));
      (match v.audio with None -> ("audio", `Null) | Some x -> ("audio", Audio.to_yojson x));
      (match v.document with None -> ("document", `Null) | Some x -> ("document", Document.to_yojson x));
      (match v.paid_media with None -> ("paid_media", `Null) | Some x -> ("paid_media", PaidMediaInfo.to_yojson x));
      (match v.photo with None -> ("photo", `Null) | Some x -> ("photo", `List (List.map (fun x -> PhotoSize.to_yojson x) x)));
      (match v.sticker with None -> ("sticker", `Null) | Some x -> ("sticker", Sticker.to_yojson x));
      (match v.story with None -> ("story", `Null) | Some x -> ("story", Story.to_yojson x));
      (match v.video with None -> ("video", `Null) | Some x -> ("video", Video.to_yojson x));
      (match v.video_note with None -> ("video_note", `Null) | Some x -> ("video_note", VideoNote.to_yojson x));
      (match v.voice with None -> ("voice", `Null) | Some x -> ("voice", Voice.to_yojson x));
      (match v.caption with None -> ("caption", `Null) | Some x -> ("caption", `String x));
      (match v.caption_entities with None -> ("caption_entities", `Null) | Some x -> ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) x)));
      (match v.show_caption_above_media with None -> ("show_caption_above_media", `Null) | Some x -> ("show_caption_above_media", `Bool x));
      (match v.has_media_spoiler with None -> ("has_media_spoiler", `Null) | Some x -> ("has_media_spoiler", `Bool x));
      (match v.checklist with None -> ("checklist", `Null) | Some x -> ("checklist", Checklist.to_yojson x));
      (match v.contact with None -> ("contact", `Null) | Some x -> ("contact", Contact.to_yojson x));
      (match v.dice with None -> ("dice", `Null) | Some x -> ("dice", Dice.to_yojson x));
      (match v.game with None -> ("game", `Null) | Some x -> ("game", Game.to_yojson x));
      (match v.poll with None -> ("poll", `Null) | Some x -> ("poll", Poll.to_yojson x));
      (match v.venue with None -> ("venue", `Null) | Some x -> ("venue", Venue.to_yojson x));
      (match v.location with None -> ("location", `Null) | Some x -> ("location", Location.to_yojson x));
      (match v.new_chat_members with None -> ("new_chat_members", `Null) | Some x -> ("new_chat_members", `List (List.map (fun x -> User.to_yojson x) x)));
      (match v.left_chat_member with None -> ("left_chat_member", `Null) | Some x -> ("left_chat_member", User.to_yojson x));
      (match v.new_chat_title with None -> ("new_chat_title", `Null) | Some x -> ("new_chat_title", `String x));
      (match v.new_chat_photo with None -> ("new_chat_photo", `Null) | Some x -> ("new_chat_photo", `List (List.map (fun x -> PhotoSize.to_yojson x) x)));
      (match v.delete_chat_photo with None -> ("delete_chat_photo", `Null) | Some x -> ("delete_chat_photo", `Bool x));
      (match v.group_chat_created with None -> ("group_chat_created", `Null) | Some x -> ("group_chat_created", `Bool x));
      (match v.supergroup_chat_created with None -> ("supergroup_chat_created", `Null) | Some x -> ("supergroup_chat_created", `Bool x));
      (match v.channel_chat_created with None -> ("channel_chat_created", `Null) | Some x -> ("channel_chat_created", `Bool x));
      (match v.message_auto_delete_timer_changed with None -> ("message_auto_delete_timer_changed", `Null) | Some x -> ("message_auto_delete_timer_changed", MessageAutoDeleteTimerChanged.to_yojson x));
      (match v.migrate_to_chat_id with None -> ("migrate_to_chat_id", `Null) | Some x -> ("migrate_to_chat_id", `Intlit (Int64.to_string x)));
      (match v.migrate_from_chat_id with None -> ("migrate_from_chat_id", `Null) | Some x -> ("migrate_from_chat_id", `Intlit (Int64.to_string x)));
      (match v.pinned_message with None -> ("pinned_message", `Null) | Some x -> ("pinned_message", MaybeInaccessibleMessage.to_yojson x));
      (match v.invoice with None -> ("invoice", `Null) | Some x -> ("invoice", Invoice.to_yojson x));
      (match v.successful_payment with None -> ("successful_payment", `Null) | Some x -> ("successful_payment", SuccessfulPayment.to_yojson x));
      (match v.refunded_payment with None -> ("refunded_payment", `Null) | Some x -> ("refunded_payment", RefundedPayment.to_yojson x));
      (match v.users_shared with None -> ("users_shared", `Null) | Some x -> ("users_shared", UsersShared.to_yojson x));
      (match v.chat_shared with None -> ("chat_shared", `Null) | Some x -> ("chat_shared", ChatShared.to_yojson x));
      (match v.gift with None -> ("gift", `Null) | Some x -> ("gift", GiftInfo.to_yojson x));
      (match v.unique_gift with None -> ("unique_gift", `Null) | Some x -> ("unique_gift", UniqueGiftInfo.to_yojson x));
      (match v.connected_website with None -> ("connected_website", `Null) | Some x -> ("connected_website", `String x));
      (match v.write_access_allowed with None -> ("write_access_allowed", `Null) | Some x -> ("write_access_allowed", WriteAccessAllowed.to_yojson x));
      (match v.passport_data with None -> ("passport_data", `Null) | Some x -> ("passport_data", PassportData.to_yojson x));
      (match v.proximity_alert_triggered with None -> ("proximity_alert_triggered", `Null) | Some x -> ("proximity_alert_triggered", ProximityAlertTriggered.to_yojson x));
      (match v.boost_added with None -> ("boost_added", `Null) | Some x -> ("boost_added", ChatBoostAdded.to_yojson x));
      (match v.chat_background_set with None -> ("chat_background_set", `Null) | Some x -> ("chat_background_set", ChatBackground.to_yojson x));
      (match v.checklist_tasks_done with None -> ("checklist_tasks_done", `Null) | Some x -> ("checklist_tasks_done", ChecklistTasksDone.to_yojson x));
      (match v.checklist_tasks_added with None -> ("checklist_tasks_added", `Null) | Some x -> ("checklist_tasks_added", ChecklistTasksAdded.to_yojson x));
      (match v.direct_message_price_changed with None -> ("direct_message_price_changed", `Null) | Some x -> ("direct_message_price_changed", DirectMessagePriceChanged.to_yojson x));
      (match v.forum_topic_created with None -> ("forum_topic_created", `Null) | Some x -> ("forum_topic_created", ForumTopicCreated.to_yojson x));
      (match v.forum_topic_edited with None -> ("forum_topic_edited", `Null) | Some x -> ("forum_topic_edited", ForumTopicEdited.to_yojson x));
      (match v.forum_topic_closed with None -> ("forum_topic_closed", `Null) | Some x -> ("forum_topic_closed", ForumTopicClosed.to_yojson x));
      (match v.forum_topic_reopened with None -> ("forum_topic_reopened", `Null) | Some x -> ("forum_topic_reopened", ForumTopicReopened.to_yojson x));
      (match v.general_forum_topic_hidden with None -> ("general_forum_topic_hidden", `Null) | Some x -> ("general_forum_topic_hidden", GeneralForumTopicHidden.to_yojson x));
      (match v.general_forum_topic_unhidden with None -> ("general_forum_topic_unhidden", `Null) | Some x -> ("general_forum_topic_unhidden", GeneralForumTopicUnhidden.to_yojson x));
      (match v.giveaway_created with None -> ("giveaway_created", `Null) | Some x -> ("giveaway_created", GiveawayCreated.to_yojson x));
      (match v.giveaway with None -> ("giveaway", `Null) | Some x -> ("giveaway", Giveaway.to_yojson x));
      (match v.giveaway_winners with None -> ("giveaway_winners", `Null) | Some x -> ("giveaway_winners", GiveawayWinners.to_yojson x));
      (match v.giveaway_completed with None -> ("giveaway_completed", `Null) | Some x -> ("giveaway_completed", GiveawayCompleted.to_yojson x));
      (match v.paid_message_price_changed with None -> ("paid_message_price_changed", `Null) | Some x -> ("paid_message_price_changed", PaidMessagePriceChanged.to_yojson x));
      (match v.suggested_post_approved with None -> ("suggested_post_approved", `Null) | Some x -> ("suggested_post_approved", SuggestedPostApproved.to_yojson x));
      (match v.suggested_post_approval_failed with None -> ("suggested_post_approval_failed", `Null) | Some x -> ("suggested_post_approval_failed", SuggestedPostApprovalFailed.to_yojson x));
      (match v.suggested_post_declined with None -> ("suggested_post_declined", `Null) | Some x -> ("suggested_post_declined", SuggestedPostDeclined.to_yojson x));
      (match v.suggested_post_paid with None -> ("suggested_post_paid", `Null) | Some x -> ("suggested_post_paid", SuggestedPostPaid.to_yojson x));
      (match v.suggested_post_refunded with None -> ("suggested_post_refunded", `Null) | Some x -> ("suggested_post_refunded", SuggestedPostRefunded.to_yojson x));
      (match v.video_chat_scheduled with None -> ("video_chat_scheduled", `Null) | Some x -> ("video_chat_scheduled", VideoChatScheduled.to_yojson x));
      (match v.video_chat_started with None -> ("video_chat_started", `Null) | Some x -> ("video_chat_started", VideoChatStarted.to_yojson x));
      (match v.video_chat_ended with None -> ("video_chat_ended", `Null) | Some x -> ("video_chat_ended", VideoChatEnded.to_yojson x));
      (match v.video_chat_participants_invited with None -> ("video_chat_participants_invited", `Null) | Some x -> ("video_chat_participants_invited", VideoChatParticipantsInvited.to_yojson x));
      (match v.web_app_data with None -> ("web_app_data", `Null) | Some x -> ("web_app_data", WebAppData.to_yojson x));
      (match v.reply_markup with None -> ("reply_markup", `Null) | Some x -> ("reply_markup", InlineKeyboardMarkup.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "message_id";
          let message_id = (match (List.assoc "message_id" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "message_id" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message_thread_id";
          let message_thread_id = match List.assoc_opt "message_thread_id" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "direct_messages_topic";
          let direct_messages_topic = match List.assoc_opt "direct_messages_topic" fields with None | Some `Null -> None | Some x -> Some ((match DirectMessagesTopic.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "from";
          let from = match List.assoc_opt "from" fields with None | Some `Null -> None | Some x -> Some ((match User.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "sender_chat";
          let sender_chat = match List.assoc_opt "sender_chat" fields with None | Some `Null -> None | Some x -> Some ((match Chat.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "sender_boost_count";
          let sender_boost_count = match List.assoc_opt "sender_boost_count" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "sender_business_bot";
          let sender_business_bot = match List.assoc_opt "sender_business_bot" fields with None | Some `Null -> None | Some x -> Some ((match User.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "date";
          let date = (match (List.assoc "date" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "date" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "business_connection_id";
          let business_connection_id = match List.assoc_opt "business_connection_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat";
          let chat = (match Chat.of_yojson (List.assoc "chat" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "chat" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "forward_origin";
          let forward_origin = match List.assoc_opt "forward_origin" fields with None | Some `Null -> None | Some x -> Some ((match MessageOrigin.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_topic_message";
          let is_topic_message = match List.assoc_opt "is_topic_message" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_automatic_forward";
          let is_automatic_forward = match List.assoc_opt "is_automatic_forward" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "reply_to_message";
          let reply_to_message = match List.assoc_opt "reply_to_message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "external_reply";
          let external_reply = match List.assoc_opt "external_reply" fields with None | Some `Null -> None | Some x -> Some ((match ExternalReplyInfo.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "quote";
          let quote = match List.assoc_opt "quote" fields with None | Some `Null -> None | Some x -> Some ((match TextQuote.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "reply_to_story";
          let reply_to_story = match List.assoc_opt "reply_to_story" fields with None | Some `Null -> None | Some x -> Some ((match Story.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "reply_to_checklist_task_id";
          let reply_to_checklist_task_id = match List.assoc_opt "reply_to_checklist_task_id" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "via_bot";
          let via_bot = match List.assoc_opt "via_bot" fields with None | Some `Null -> None | Some x -> Some ((match User.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "edit_date";
          let edit_date = match List.assoc_opt "edit_date" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "has_protected_content";
          let has_protected_content = match List.assoc_opt "has_protected_content" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_from_offline";
          let is_from_offline = match List.assoc_opt "is_from_offline" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_paid_post";
          let is_paid_post = match List.assoc_opt "is_paid_post" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "media_group_id";
          let media_group_id = match List.assoc_opt "media_group_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "author_signature";
          let author_signature = match List.assoc_opt "author_signature" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "paid_star_count";
          let paid_star_count = match List.assoc_opt "paid_star_count" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "text";
          let text = match List.assoc_opt "text" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "entities";
          let entities = match List.assoc_opt "entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "link_preview_options";
          let link_preview_options = match List.assoc_opt "link_preview_options" fields with None | Some `Null -> None | Some x -> Some ((match LinkPreviewOptions.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "suggested_post_info";
          let suggested_post_info = match List.assoc_opt "suggested_post_info" fields with None | Some `Null -> None | Some x -> Some ((match SuggestedPostInfo.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "effect_id";
          let effect_id = match List.assoc_opt "effect_id" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "animation";
          let animation = match List.assoc_opt "animation" fields with None | Some `Null -> None | Some x -> Some ((match Animation.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "audio";
          let audio = match List.assoc_opt "audio" fields with None | Some `Null -> None | Some x -> Some ((match Audio.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "document";
          let document = match List.assoc_opt "document" fields with None | Some `Null -> None | Some x -> Some ((match Document.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "paid_media";
          let paid_media = match List.assoc_opt "paid_media" fields with None | Some `Null -> None | Some x -> Some ((match PaidMediaInfo.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "photo";
          let photo = match List.assoc_opt "photo" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match PhotoSize.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "sticker";
          let sticker = match List.assoc_opt "sticker" fields with None | Some `Null -> None | Some x -> Some ((match Sticker.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "story";
          let story = match List.assoc_opt "story" fields with None | Some `Null -> None | Some x -> Some ((match Story.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "video";
          let video = match List.assoc_opt "video" fields with None | Some `Null -> None | Some x -> Some ((match Video.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "video_note";
          let video_note = match List.assoc_opt "video_note" fields with None | Some `Null -> None | Some x -> Some ((match VideoNote.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "voice";
          let voice = match List.assoc_opt "voice" fields with None | Some `Null -> None | Some x -> Some ((match Voice.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption";
          let caption = match List.assoc_opt "caption" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "caption_entities";
          let caption_entities = match List.assoc_opt "caption_entities" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match MessageEntity.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "show_caption_above_media";
          let show_caption_above_media = match List.assoc_opt "show_caption_above_media" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "has_media_spoiler";
          let has_media_spoiler = match List.assoc_opt "has_media_spoiler" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "checklist";
          let checklist = match List.assoc_opt "checklist" fields with None | Some `Null -> None | Some x -> Some ((match Checklist.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "contact";
          let contact = match List.assoc_opt "contact" fields with None | Some `Null -> None | Some x -> Some ((match Contact.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "dice";
          let dice = match List.assoc_opt "dice" fields with None | Some `Null -> None | Some x -> Some ((match Dice.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "game";
          let game = match List.assoc_opt "game" fields with None | Some `Null -> None | Some x -> Some ((match Game.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "poll";
          let poll = match List.assoc_opt "poll" fields with None | Some `Null -> None | Some x -> Some ((match Poll.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "venue";
          let venue = match List.assoc_opt "venue" fields with None | Some `Null -> None | Some x -> Some ((match Venue.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "location";
          let location = match List.assoc_opt "location" fields with None | Some `Null -> None | Some x -> Some ((match Location.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "new_chat_members";
          let new_chat_members = match List.assoc_opt "new_chat_members" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match User.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "left_chat_member";
          let left_chat_member = match List.assoc_opt "left_chat_member" fields with None | Some `Null -> None | Some x -> Some ((match User.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "new_chat_title";
          let new_chat_title = match List.assoc_opt "new_chat_title" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "new_chat_photo";
          let new_chat_photo = match List.assoc_opt "new_chat_photo" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match PhotoSize.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "delete_chat_photo";
          let delete_chat_photo = match List.assoc_opt "delete_chat_photo" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "group_chat_created";
          let group_chat_created = match List.assoc_opt "group_chat_created" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "supergroup_chat_created";
          let supergroup_chat_created = match List.assoc_opt "supergroup_chat_created" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "channel_chat_created";
          let channel_chat_created = match List.assoc_opt "channel_chat_created" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "message_auto_delete_timer_changed";
          let message_auto_delete_timer_changed = match List.assoc_opt "message_auto_delete_timer_changed" fields with None | Some `Null -> None | Some x -> Some ((match MessageAutoDeleteTimerChanged.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "migrate_to_chat_id";
          let migrate_to_chat_id = match List.assoc_opt "migrate_to_chat_id" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "migrate_from_chat_id";
          let migrate_from_chat_id = match List.assoc_opt "migrate_from_chat_id" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "pinned_message";
          let pinned_message = match List.assoc_opt "pinned_message" fields with None | Some `Null -> None | Some x -> Some ((match MaybeInaccessibleMessage.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "invoice";
          let invoice = match List.assoc_opt "invoice" fields with None | Some `Null -> None | Some x -> Some ((match Invoice.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "successful_payment";
          let successful_payment = match List.assoc_opt "successful_payment" fields with None | Some `Null -> None | Some x -> Some ((match SuccessfulPayment.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "refunded_payment";
          let refunded_payment = match List.assoc_opt "refunded_payment" fields with None | Some `Null -> None | Some x -> Some ((match RefundedPayment.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "users_shared";
          let users_shared = match List.assoc_opt "users_shared" fields with None | Some `Null -> None | Some x -> Some ((match UsersShared.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_shared";
          let chat_shared = match List.assoc_opt "chat_shared" fields with None | Some `Null -> None | Some x -> Some ((match ChatShared.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "gift";
          let gift = match List.assoc_opt "gift" fields with None | Some `Null -> None | Some x -> Some ((match GiftInfo.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "unique_gift";
          let unique_gift = match List.assoc_opt "unique_gift" fields with None | Some `Null -> None | Some x -> Some ((match UniqueGiftInfo.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "connected_website";
          let connected_website = match List.assoc_opt "connected_website" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "write_access_allowed";
          let write_access_allowed = match List.assoc_opt "write_access_allowed" fields with None | Some `Null -> None | Some x -> Some ((match WriteAccessAllowed.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "passport_data";
          let passport_data = match List.assoc_opt "passport_data" fields with None | Some `Null -> None | Some x -> Some ((match PassportData.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "proximity_alert_triggered";
          let proximity_alert_triggered = match List.assoc_opt "proximity_alert_triggered" fields with None | Some `Null -> None | Some x -> Some ((match ProximityAlertTriggered.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "boost_added";
          let boost_added = match List.assoc_opt "boost_added" fields with None | Some `Null -> None | Some x -> Some ((match ChatBoostAdded.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "chat_background_set";
          let chat_background_set = match List.assoc_opt "chat_background_set" fields with None | Some `Null -> None | Some x -> Some ((match ChatBackground.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "checklist_tasks_done";
          let checklist_tasks_done = match List.assoc_opt "checklist_tasks_done" fields with None | Some `Null -> None | Some x -> Some ((match ChecklistTasksDone.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "checklist_tasks_added";
          let checklist_tasks_added = match List.assoc_opt "checklist_tasks_added" fields with None | Some `Null -> None | Some x -> Some ((match ChecklistTasksAdded.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "direct_message_price_changed";
          let direct_message_price_changed = match List.assoc_opt "direct_message_price_changed" fields with None | Some `Null -> None | Some x -> Some ((match DirectMessagePriceChanged.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "forum_topic_created";
          let forum_topic_created = match List.assoc_opt "forum_topic_created" fields with None | Some `Null -> None | Some x -> Some ((match ForumTopicCreated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "forum_topic_edited";
          let forum_topic_edited = match List.assoc_opt "forum_topic_edited" fields with None | Some `Null -> None | Some x -> Some ((match ForumTopicEdited.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "forum_topic_closed";
          let forum_topic_closed = match List.assoc_opt "forum_topic_closed" fields with None | Some `Null -> None | Some x -> Some ((match ForumTopicClosed.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "forum_topic_reopened";
          let forum_topic_reopened = match List.assoc_opt "forum_topic_reopened" fields with None | Some `Null -> None | Some x -> Some ((match ForumTopicReopened.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "general_forum_topic_hidden";
          let general_forum_topic_hidden = match List.assoc_opt "general_forum_topic_hidden" fields with None | Some `Null -> None | Some x -> Some ((match GeneralForumTopicHidden.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "general_forum_topic_unhidden";
          let general_forum_topic_unhidden = match List.assoc_opt "general_forum_topic_unhidden" fields with None | Some `Null -> None | Some x -> Some ((match GeneralForumTopicUnhidden.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "giveaway_created";
          let giveaway_created = match List.assoc_opt "giveaway_created" fields with None | Some `Null -> None | Some x -> Some ((match GiveawayCreated.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "giveaway";
          let giveaway = match List.assoc_opt "giveaway" fields with None | Some `Null -> None | Some x -> Some ((match Giveaway.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "giveaway_winners";
          let giveaway_winners = match List.assoc_opt "giveaway_winners" fields with None | Some `Null -> None | Some x -> Some ((match GiveawayWinners.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "giveaway_completed";
          let giveaway_completed = match List.assoc_opt "giveaway_completed" fields with None | Some `Null -> None | Some x -> Some ((match GiveawayCompleted.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "paid_message_price_changed";
          let paid_message_price_changed = match List.assoc_opt "paid_message_price_changed" fields with None | Some `Null -> None | Some x -> Some ((match PaidMessagePriceChanged.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "suggested_post_approved";
          let suggested_post_approved = match List.assoc_opt "suggested_post_approved" fields with None | Some `Null -> None | Some x -> Some ((match SuggestedPostApproved.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "suggested_post_approval_failed";
          let suggested_post_approval_failed = match List.assoc_opt "suggested_post_approval_failed" fields with None | Some `Null -> None | Some x -> Some ((match SuggestedPostApprovalFailed.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "suggested_post_declined";
          let suggested_post_declined = match List.assoc_opt "suggested_post_declined" fields with None | Some `Null -> None | Some x -> Some ((match SuggestedPostDeclined.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "suggested_post_paid";
          let suggested_post_paid = match List.assoc_opt "suggested_post_paid" fields with None | Some `Null -> None | Some x -> Some ((match SuggestedPostPaid.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "suggested_post_refunded";
          let suggested_post_refunded = match List.assoc_opt "suggested_post_refunded" fields with None | Some `Null -> None | Some x -> Some ((match SuggestedPostRefunded.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "video_chat_scheduled";
          let video_chat_scheduled = match List.assoc_opt "video_chat_scheduled" fields with None | Some `Null -> None | Some x -> Some ((match VideoChatScheduled.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "video_chat_started";
          let video_chat_started = match List.assoc_opt "video_chat_started" fields with None | Some `Null -> None | Some x -> Some ((match VideoChatStarted.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "video_chat_ended";
          let video_chat_ended = match List.assoc_opt "video_chat_ended" fields with None | Some `Null -> None | Some x -> Some ((match VideoChatEnded.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "video_chat_participants_invited";
          let video_chat_participants_invited = match List.assoc_opt "video_chat_participants_invited" fields with None | Some `Null -> None | Some x -> Some ((match VideoChatParticipantsInvited.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "web_app_data";
          let web_app_data = match List.assoc_opt "web_app_data" fields with None | Some `Null -> None | Some x -> Some ((match WebAppData.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "reply_markup";
          let reply_markup = match List.assoc_opt "reply_markup" fields with None | Some `Null -> None | Some x -> Some ((match InlineKeyboardMarkup.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { message_id = message_id; message_thread_id = message_thread_id; direct_messages_topic = direct_messages_topic; from = from; sender_chat = sender_chat; sender_boost_count = sender_boost_count; sender_business_bot = sender_business_bot; date = date; business_connection_id = business_connection_id; chat = chat; forward_origin = forward_origin; is_topic_message = is_topic_message; is_automatic_forward = is_automatic_forward; reply_to_message = reply_to_message; external_reply = external_reply; quote = quote; reply_to_story = reply_to_story; reply_to_checklist_task_id = reply_to_checklist_task_id; via_bot = via_bot; edit_date = edit_date; has_protected_content = has_protected_content; is_from_offline = is_from_offline; is_paid_post = is_paid_post; media_group_id = media_group_id; author_signature = author_signature; paid_star_count = paid_star_count; text = text; entities = entities; link_preview_options = link_preview_options; suggested_post_info = suggested_post_info; effect_id = effect_id; animation = animation; audio = audio; document = document; paid_media = paid_media; photo = photo; sticker = sticker; story = story; video = video; video_note = video_note; voice = voice; caption = caption; caption_entities = caption_entities; show_caption_above_media = show_caption_above_media; has_media_spoiler = has_media_spoiler; checklist = checklist; contact = contact; dice = dice; game = game; poll = poll; venue = venue; location = location; new_chat_members = new_chat_members; left_chat_member = left_chat_member; new_chat_title = new_chat_title; new_chat_photo = new_chat_photo; delete_chat_photo = delete_chat_photo; group_chat_created = group_chat_created; supergroup_chat_created = supergroup_chat_created; channel_chat_created = channel_chat_created; message_auto_delete_timer_changed = message_auto_delete_timer_changed; migrate_to_chat_id = migrate_to_chat_id; migrate_from_chat_id = migrate_from_chat_id; pinned_message = pinned_message; invoice = invoice; successful_payment = successful_payment; refunded_payment = refunded_payment; users_shared = users_shared; chat_shared = chat_shared; gift = gift; unique_gift = unique_gift; connected_website = connected_website; write_access_allowed = write_access_allowed; passport_data = passport_data; proximity_alert_triggered = proximity_alert_triggered; boost_added = boost_added; chat_background_set = chat_background_set; checklist_tasks_done = checklist_tasks_done; checklist_tasks_added = checklist_tasks_added; direct_message_price_changed = direct_message_price_changed; forum_topic_created = forum_topic_created; forum_topic_edited = forum_topic_edited; forum_topic_closed = forum_topic_closed; forum_topic_reopened = forum_topic_reopened; general_forum_topic_hidden = general_forum_topic_hidden; general_forum_topic_unhidden = general_forum_topic_unhidden; giveaway_created = giveaway_created; giveaway = giveaway; giveaway_winners = giveaway_winners; giveaway_completed = giveaway_completed; paid_message_price_changed = paid_message_price_changed; suggested_post_approved = suggested_post_approved; suggested_post_approval_failed = suggested_post_approval_failed; suggested_post_declined = suggested_post_declined; suggested_post_paid = suggested_post_paid; suggested_post_refunded = suggested_post_refunded; video_chat_scheduled = video_chat_scheduled; video_chat_started = video_chat_started; video_chat_ended = video_chat_ended; video_chat_participants_invited = video_chat_participants_invited; web_app_data = web_app_data; reply_markup = reply_markup; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ChecklistTasksDone : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    checklist_message : Message.t option;
    marked_as_done_task_ids : int64 list option;
    marked_as_not_done_task_ids : int64 list option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      (match v.checklist_message with None -> ("checklist_message", `Null) | Some x -> ("checklist_message", Message.to_yojson x));
      (match v.marked_as_done_task_ids with None -> ("marked_as_done_task_ids", `Null) | Some x -> ("marked_as_done_task_ids", `List (List.map (fun x -> `Intlit (Int64.to_string x)) x)));
      (match v.marked_as_not_done_task_ids with None -> ("marked_as_not_done_task_ids", `Null) | Some x -> ("marked_as_not_done_task_ids", `List (List.map (fun x -> `Intlit (Int64.to_string x)) x)));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "checklist_message";
          let checklist_message = match List.assoc_opt "checklist_message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "marked_as_done_task_ids";
          let marked_as_done_task_ids = match List.assoc_opt "marked_as_done_task_ids" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) (to_list x))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "marked_as_not_done_task_ids";
          let marked_as_not_done_task_ids = match List.assoc_opt "marked_as_not_done_task_ids" fields with None | Some `Null -> None | Some x -> Some ((List.map (fun x -> (match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) (to_list x))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { checklist_message = checklist_message; marked_as_done_task_ids = marked_as_done_task_ids; marked_as_not_done_task_ids = marked_as_not_done_task_ids; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and ChecklistTasksAdded : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    checklist_message : Message.t option;
    tasks : ChecklistTask.t list;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      (match v.checklist_message with None -> ("checklist_message", `Null) | Some x -> ("checklist_message", Message.to_yojson x));
      ("tasks", `List (List.map (fun x -> ChecklistTask.to_yojson x) v.tasks));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "checklist_message";
          let checklist_message = match List.assoc_opt "checklist_message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "tasks";
          let tasks = (List.map (fun x -> (match ChecklistTask.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) (to_list (List.assoc "tasks" fields))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { checklist_message = checklist_message; tasks = tasks; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and SuggestedPostApproved : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    suggested_post_message : Message.t option;
    price : SuggestedPostPrice.t option;
    send_date : int64;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      (match v.suggested_post_message with None -> ("suggested_post_message", `Null) | Some x -> ("suggested_post_message", Message.to_yojson x));
      (match v.price with None -> ("price", `Null) | Some x -> ("price", SuggestedPostPrice.to_yojson x));
      ("send_date", `Intlit (Int64.to_string v.send_date));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "suggested_post_message";
          let suggested_post_message = match List.assoc_opt "suggested_post_message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "price";
          let price = match List.assoc_opt "price" fields with None | Some `Null -> None | Some x -> Some ((match SuggestedPostPrice.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "send_date";
          let send_date = (match (List.assoc "send_date" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "send_date" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { suggested_post_message = suggested_post_message; price = price; send_date = send_date; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and SuggestedPostApprovalFailed : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    suggested_post_message : Message.t option;
    price : SuggestedPostPrice.t;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      (match v.suggested_post_message with None -> ("suggested_post_message", `Null) | Some x -> ("suggested_post_message", Message.to_yojson x));
      ("price", SuggestedPostPrice.to_yojson v.price);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "suggested_post_message";
          let suggested_post_message = match List.assoc_opt "suggested_post_message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "price";
          let price = (match SuggestedPostPrice.of_yojson (List.assoc "price" fields) with Ok v -> v | Error e -> raise (Type_error (e, (List.assoc "price" fields)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { suggested_post_message = suggested_post_message; price = price; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and SuggestedPostDeclined : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    suggested_post_message : Message.t option;
    comment : string option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      (match v.suggested_post_message with None -> ("suggested_post_message", `Null) | Some x -> ("suggested_post_message", Message.to_yojson x));
      (match v.comment with None -> ("comment", `Null) | Some x -> ("comment", `String x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "suggested_post_message";
          let suggested_post_message = match List.assoc_opt "suggested_post_message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "comment";
          let comment = match List.assoc_opt "comment" fields with None | Some `Null -> None | Some x -> Some ((to_string x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { suggested_post_message = suggested_post_message; comment = comment; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and SuggestedPostPaid : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    suggested_post_message : Message.t option;
    currency : string;
    amount : int64 option;
    star_amount : StarAmount.t option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      (match v.suggested_post_message with None -> ("suggested_post_message", `Null) | Some x -> ("suggested_post_message", Message.to_yojson x));
      ("currency", `String v.currency);
      (match v.amount with None -> ("amount", `Null) | Some x -> ("amount", `Intlit (Int64.to_string x)));
      (match v.star_amount with None -> ("star_amount", `Null) | Some x -> ("star_amount", StarAmount.to_yojson x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "suggested_post_message";
          let suggested_post_message = match List.assoc_opt "suggested_post_message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "currency";
          let currency = (to_string (List.assoc "currency" fields)) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "amount";
          let amount = match List.assoc_opt "amount" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "star_amount";
          let star_amount = match List.assoc_opt "star_amount" fields with None | Some `Null -> None | Some x -> Some ((match StarAmount.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { suggested_post_message = suggested_post_message; currency = currency; amount = amount; star_amount = star_amount; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and SuggestedPostRefunded : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    suggested_post_message : Message.t option;
    reason : string;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      (match v.suggested_post_message with None -> ("suggested_post_message", `Null) | Some x -> ("suggested_post_message", Message.to_yojson x));
      ("reason", `String v.reason);
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "suggested_post_message";
          let suggested_post_message = match List.assoc_opt "suggested_post_message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "reason";
          let reason = (to_string (List.assoc "reason" fields)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { suggested_post_message = suggested_post_message; reason = reason; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
and GiveawayCompleted : sig
  type t
  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> (t, string) result
end = struct
  type t = {
    winner_count : int64;
    unclaimed_prize_count : int64 option;
    giveaway_message : Message.t option;
    is_star_giveaway : bool option;
    unknown_fields : Telegram.Json_compat.Unknown_fields.t;
  }
  let to_yojson (v : t) : Yojson.Safe.t =
    `Assoc ([
      ("winner_count", `Intlit (Int64.to_string v.winner_count));
      (match v.unclaimed_prize_count with None -> ("unclaimed_prize_count", `Null) | Some x -> ("unclaimed_prize_count", `Intlit (Int64.to_string x)));
      (match v.giveaway_message with None -> ("giveaway_message", `Null) | Some x -> ("giveaway_message", Message.to_yojson x));
      (match v.is_star_giveaway with None -> ("is_star_giveaway", `Null) | Some x -> ("is_star_giveaway", `Bool x));
    ] @ Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)
  let of_yojson (j : Yojson.Safe.t) : (t, string) result =
    match j with
    | `Assoc fields ->
        let open Yojson.Safe.Util in
        let uf = Telegram.Json_compat.Unknown_fields.create () in
        (try
          Telegram.Json_compat.Unknown_fields.mark_known uf "winner_count";
          let winner_count = (match (List.assoc "winner_count" fields) with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", (List.assoc "winner_count" fields)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "unclaimed_prize_count";
          let unclaimed_prize_count = match List.assoc_opt "unclaimed_prize_count" fields with None | Some `Null -> None | Some x -> Some ((match x with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error ("Expected int", x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "giveaway_message";
          let giveaway_message = match List.assoc_opt "giveaway_message" fields with None | Some `Null -> None | Some x -> Some ((match Message.of_yojson x with Ok v -> v | Error e -> raise (Type_error (e, x)))) in
          Telegram.Json_compat.Unknown_fields.mark_known uf "is_star_giveaway";
          let is_star_giveaway = match List.assoc_opt "is_star_giveaway" fields with None | Some `Null -> None | Some x -> Some ((to_bool x)) in
          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in
          Ok { winner_count = winner_count; unclaimed_prize_count = unclaimed_prize_count; giveaway_message = giveaway_message; is_star_giveaway = is_star_giveaway; unknown_fields }
        with
        | Not_found -> Error "Missing required field"
        | Type_error (msg, _) -> Error msg
        | Yojson.Safe.Util.Type_error (msg, _) -> Error msg)
    | _ -> Error "Expected JSON object"
end
