(** Typed session storage with phantom types *)

type 'a key
(** A typed key for session storage. The type parameter ensures type safety. *)

val make : name:string -> 'a key
(** Create a new unique typed key for session storage. The name is for debugging. *)

type t
(** Session storage type *)

(** {2 Core Operations} *)

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

(** {2 Convenience Helpers} *)

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
