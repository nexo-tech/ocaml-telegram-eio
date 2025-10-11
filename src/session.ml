(** Session management with composable logging via functors *)

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

(** Session module signature - output of Make functor *)
module type S = sig
  val make : name:string -> 'a key
  val empty : t
  val get : t -> 'a key -> 'a option
  val set : t -> 'a key -> 'a -> unit
  val delete : t -> 'a key -> unit
  val exists : t -> 'a key -> bool
  val clear : t -> unit
  val get_or : t -> 'a key -> default:'a -> 'a
  val update : t -> 'a key -> ('a -> 'a) -> unit
  val modify : t -> 'a key -> default:'a -> ('a -> 'a) -> unit

  module type STORE = sig
    type store
    val create : unit -> store
    val get_session : store -> user_id:int64 -> t
    val set_session : store -> user_id:int64 -> t -> unit
    val delete_session : store -> user_id:int64 -> unit
    val clear_all : store -> unit
  end

  module Memory_store : STORE
end

(** Session module parameterized by logging backend *)
module Make (Log : Telegram.Log.S) : S = struct

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
    let has_value = exists s k in
    Log.debug "Session.modify: key_id=%d, has_value=%b" k has_value;
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
      Log.debug "Store access: user_id=%Ld, operation=get_session" user_id;
      try
        let session = Hashtbl.find store user_id in
        let keys_count = List.length session.store in
        Log.info "Session loaded: user_id=%Ld, keys_count=%d" user_id keys_count;
        Log.debug' (fun () ->
          let session_count = Hashtbl.length store in
          let total_keys = Hashtbl.fold (fun _ sess acc ->
            acc + List.length sess.store
          ) store 0 in
          Format.asprintf "Store size: session_count=%d, total_keys=%d" session_count total_keys
        );
        session
      with Not_found ->
        Log.debug "Session load failed: user_id=%Ld, reason=not found, creating new" user_id;
        let session = { store = [] } in
        Hashtbl.add store user_id session;
        Log.info "Session loaded: user_id=%Ld, keys_count=0" user_id;
        Log.debug' (fun () ->
          let session_count = Hashtbl.length store in
          Format.asprintf "Store size: session_count=%d, total_keys=0" session_count
        );
        session

    let set_session store ~user_id session =
      Log.debug "Store access: user_id=%Ld, operation=set_session" user_id;
      let keys_count = List.length session.store in
      Log.info "Session saved: user_id=%Ld, keys_count=%d" user_id keys_count;
      Hashtbl.replace store user_id session

    let delete_session store ~user_id =
      Log.debug "Store access: user_id=%Ld, operation=delete_session" user_id;
      Log.info "Session deleted: user_id=%Ld" user_id;
      Hashtbl.remove store user_id

    let clear_all store =
      let session_count = Hashtbl.length store in
      Log.info "Store cleared: session_count=%d" session_count;
      Hashtbl.clear store
  end
end

(* Default logging configuration for backward compatibility *)
module Log_default = Telegram.Log.Make (Telegram.Log.Console) (struct
  let src = "Session"
  let level = Telegram.Log.Info
end)

(* Default instantiation - this is what most users will use *)
include Make (Log_default)
