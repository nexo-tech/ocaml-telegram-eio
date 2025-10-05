type env
type t

val create : env:env -> token:string -> ?base_url:string -> unit -> t

val token : t -> string
val base_url : t -> string
val env : t -> env
