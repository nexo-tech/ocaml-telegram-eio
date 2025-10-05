type env = Eio_unix.Stdenv.base

type t

val create : env:env -> token:string -> ?base_url:string -> ?limits:Limits.t -> unit -> t

val token : t -> string
val base_url : t -> string
val env : t -> env
val limits : t -> Limits.t
