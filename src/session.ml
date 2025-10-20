(** Session management with flo logging *)

open Flo

(* Typed session keys using phantom types *)
module K = struct
  type 'a t = int
end

type 'a key = 'a K.t

(* Existential box for storing heterogeneous values *)
type boxed = B : 'a key * 'a -> boxed

(* In-memory session storage *)
type t = {
  mutable store : boxed list;
}

(* Create a unique typed key *)
let counter = ref 0
let make ~name:_ =
  incr counter;
  !counter

(* Empty session *)
let empty = { store = [] }

(* Get value by key *)
let get s k =
  let rec go = function
    | [] -> None
    | B (k', v) :: tl -> if k = k' then Some (Obj.magic v) else go tl
  in
  let result = go s.store in
  debugf "Session key access: operation=get, key_id=%d, found=%b" k (Option.is_some result);
  result

(* Set value for key *)
let set s k v =
  debugf "Session state modified: operation=set, key_id=%d" k;
  s.store <- B (k, v) :: List.filter (fun (B (k', _)) -> k <> k') s.store

(* Delete key from session *)
let delete s k =
  debugf "Session state modified: operation=delete, key_id=%d" k;
  s.store <- List.filter (fun (B (k', _)) -> k <> k') s.store

(* Check if key exists *)
let exists s k =
  List.exists (fun (B (k', _)) -> k = k') s.store

(* Clear all session data *)
let clear s =
  s.store <- []

(* Get or default *)
let get_or s k ~default =
  match get s k with
  | Some v -> v
  | None -> default

(* Update if exists, otherwise set *)
let update s k f =
  match get s k with
  | Some v -> set s k (f v)
  | None -> ()

(* Modify - like update but sets default if missing *)
let modify s k ~default f =
  let has_value = exists s k in
  debugf "Session.modify: key_id=%d, has_value=%b" k has_value;
  let v = get_or s k ~default in
  set s k (f v)

(* Session store interface for pluggable backends *)
module type STORE = sig
  type store

  val create : unit -> store
  val get_session : store -> user_id:int64 -> t
  val set_session : store -> user_id:int64 -> t -> unit
  val delete_session : store -> user_id:int64 -> unit
  val clear_all : store -> unit
end

(* In-memory session store implementation *)
module Memory_store : STORE = struct
  type store = (int64, t) Hashtbl.t

  let create () = Hashtbl.create 100

  let get_session store ~user_id =
    debugf "Store access: user_id=%Ld, operation=get_session" user_id;
    try
      let session = Hashtbl.find store user_id in
      let keys_count = List.length session.store in
      info_fields "Session loaded" ~fields:[
        ("user_id", Value.int64 user_id);
        ("keys_count", Value.int keys_count);
      ];
      debug_fields "Store size" ~fields:[
        ("session_count", Value.int (Hashtbl.length store));
        ("total_keys", Value.int (Hashtbl.fold (fun _ sess acc ->
          acc + List.length sess.store
        ) store 0));
      ];
      session
    with Not_found ->
      debugf "Session load failed: user_id=%Ld, reason=not found, creating new" user_id;
      let session = { store = [] } in
      Hashtbl.add store user_id session;
      info_fields "Session loaded" ~fields:[
        ("user_id", Value.int64 user_id);
        ("keys_count", Value.int 0);
      ];
      debug_fields "Store size" ~fields:[
        ("session_count", Value.int (Hashtbl.length store));
        ("total_keys", Value.int 0);
      ];
      session

  let set_session store ~user_id session =
    debugf "Store access: user_id=%Ld, operation=set_session" user_id;
    let keys_count = List.length session.store in
    info_fields "Session saved" ~fields:[
      ("user_id", Value.int64 user_id);
      ("keys_count", Value.int keys_count);
    ];
    Hashtbl.replace store user_id session

  let delete_session store ~user_id =
    debugf "Store access: user_id=%Ld, operation=delete_session" user_id;
    info_fields "Session deleted" ~fields:[
      ("user_id", Value.int64 user_id);
    ];
    Hashtbl.remove store user_id

  let clear_all store =
    let session_count = Hashtbl.length store in
    info_fields "Store cleared" ~fields:[
      ("session_count", Value.int session_count);
    ];
    Hashtbl.clear store
end
