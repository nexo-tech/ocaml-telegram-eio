type +'k t
module Chat : sig
  type k
  val of_int : int64 -> k t
  val of_username : string -> k t
  val of_string : string -> k t
end
module User : sig
  type k
  val of_int : int64 -> k t
  val of_username : string -> k t
end
module Message : sig
  type k
  val of_int : int -> k t
end
val pp : 'k t Fmt.t
val to_string : 'k t -> string

module Token : sig
  type t
  val of_string : string -> t
  val to_string : t -> string
end

module Update : sig
  type k
  val of_int : int64 -> k t
end

module File_id : sig
  type t
  val of_string : string -> t
  val to_string : t -> string
end
