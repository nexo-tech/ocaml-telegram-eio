module Log = Telegram.Log.Make (Telegram.Log.Console) (struct
  let src = "Session"
  let level = Telegram.Log.Info
end)

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
  Log.debug "Session key access: operation=get, key_id=%d, found=%b" k (Option.is_some result);
  result

(* Set value for key *)
let set s k v =
  Log.debug "Session state modified: operation=set, key_id=%d" k;
  s.store <- B (k, v) :: List.filter (fun (B (k', _)) -> k <> k') s.store

(* Delete key from session *)
let delete s k =
  Log.debug "Session state modified: operation=delete, key_id=%d" k;
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
    try
      let session = Hashtbl.find store user_id in
      let keys_count = List.length session.store in
      Log.info "Session loaded: user_id=%Ld, keys_count=%d" user_id keys_count;
      session
    with Not_found ->
      Log.debug "Session load failed: user_id=%Ld, reason=not found, creating new" user_id;
      let session = { store = [] } in
      Hashtbl.add store user_id session;
      Log.info "Session loaded: user_id=%Ld, keys_count=0" user_id;
      session

  let set_session store ~user_id session =
    let keys_count = List.length session.store in
    Log.info "Session saved: user_id=%Ld, keys_count=%d" user_id keys_count;
    Hashtbl.replace store user_id session

  let delete_session store ~user_id =
    Hashtbl.remove store user_id

  let clear_all store =
    Hashtbl.clear store
end
