(** Typed session storage with phantom types and composable logging *)

type 'a key
(** A typed key for session storage. The type parameter ensures type safety. *)

type t
(** Session storage type *)

(** {1 Functor Interface} *)

(** Session module signature - output of Make functor *)
module type S = sig
  val make : name:string -> 'a key
  (** Create a new unique typed key for session storage. The name is for debugging. *)

  val empty : t
  (** Create an empty session *)

  val get : t -> 'a key -> 'a option
  (** Get a value from the session by key *)

  val set : t -> 'a key -> 'a -> unit
  (** Set a value in the session *)

  val delete : t -> 'a key -> unit
  (** Delete a key from the session *)

  val exists : t -> 'a key -> bool
  (** Check if a key exists in the session *)

  val clear : t -> unit
  (** Clear all session data *)

  val get_or : t -> 'a key -> default:'a -> 'a
  (** Get a value or return default if not present *)

  val update : t -> 'a key -> ('a -> 'a) -> unit
  (** Update a value if it exists (no-op if missing) *)

  val modify : t -> 'a key -> default:'a -> ('a -> 'a) -> unit
  (** Modify a value, using default if missing *)

  (** {2 Session Store Interface} *)

  module type STORE = sig
    type store
    (** The store type *)

    val create : unit -> store
    (** Create a new store *)

    val get_session : store -> user_id:int64 -> t
    (** Get session for a user (creates if missing) *)

    val set_session : store -> user_id:int64 -> t -> unit
    (** Save session for a user *)

    val delete_session : store -> user_id:int64 -> unit
    (** Delete a user's session *)

    val clear_all : store -> unit
    (** Clear all sessions *)
  end

  (** {2 Built-in Stores} *)

  module Memory_store : STORE
  (** In-memory session store (hashtable-based) *)
end

(** Functor to create session module with custom logging backend.

    Example:
    {[
      (* Custom logging configuration *)
      module My_log = Telegram.Log.Make (Telegram.Log.Console) (struct
        let src = "Session"
        let level = Telegram.Log.Debug  (* More verbose *)
      end)

      (* Create session module with custom logging *)
      module My_session = Telegram.Session.Make (My_log)

      (* Use it *)
      let session = My_session.empty
      let counter_key = My_session.make ~name:"counter"
      My_session.set session counter_key 42
    ]}
*)
module Make (Log : Telegram.Log.S) : S [@@warning "-67"]

(** {1 Default Implementation}

    The following functions use the default logging configuration
    (Console backend at Info level). This is provided for convenience
    and backward compatibility.

    For production use or custom logging, use the [Make] functor instead.
*)

val make : name:string -> 'a key
(** Create a new unique typed key for session storage. The name is for debugging. *)

val empty : t
(** Create an empty session *)

val get : t -> 'a key -> 'a option
(** Get a value from the session by key *)

val set : t -> 'a key -> 'a -> unit
(** Set a value in the session *)

val delete : t -> 'a key -> unit
(** Delete a key from the session *)

val exists : t -> 'a key -> bool
(** Check if a key exists in the session *)

val clear : t -> unit
(** Clear all session data *)

val get_or : t -> 'a key -> default:'a -> 'a
(** Get a value or return default if not present *)

val update : t -> 'a key -> ('a -> 'a) -> unit
(** Update a value if it exists (no-op if missing) *)

val modify : t -> 'a key -> default:'a -> ('a -> 'a) -> unit
(** Modify a value, using default if missing *)

(** {2 Session Store Interface} *)

module type STORE = sig
  type store
  (** The store type *)

  val create : unit -> store
  (** Create a new store *)

  val get_session : store -> user_id:int64 -> t
  (** Get session for a user (creates if missing) *)

  val set_session : store -> user_id:int64 -> t -> unit
  (** Save session for a user *)

  val delete_session : store -> user_id:int64 -> unit
  (** Delete a user's session *)

  val clear_all : store -> unit
  (** Clear all sessions *)
end

(** {2 Built-in Stores} *)

module Memory_store : STORE
(** In-memory session store (hashtable-based) *)
