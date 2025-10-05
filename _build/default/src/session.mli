type 'a key

val make : name:string -> 'a key

type t

val empty : t
val get : t -> 'a key -> 'a option
val set : t -> 'a key -> 'a -> unit
