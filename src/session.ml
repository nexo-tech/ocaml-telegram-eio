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
  go s.store

(* Set value for key *)
let set s k v =
  s.store <- B (k, v) :: List.filter (fun (B (k', _)) -> k <> k') s.store

(* Delete key from session *)
let delete s k =
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
    try Hashtbl.find store user_id
    with Not_found ->
      let session = { store = [] } in
      Hashtbl.add store user_id session;
      session

  let set_session store ~user_id session =
    Hashtbl.replace store user_id session

  let delete_session store ~user_id =
    Hashtbl.remove store user_id

  let clear_all store =
    Hashtbl.clear store
end
