open Error

type method_ = [ `GET | `POST ]
type header = string * string

type part_value =
  [ `String of string
  | `File of string * string option * string ]

type body =
  | Empty
  | String of string
  | Multipart of (string * part_value) list

type response = { status : int; headers : header list; body : string }

module type S = sig
  type t
  val call : t -> meth:method_ -> url:string -> headers:header list -> body:body -> (response, Error.t) result
end

module Cohttp_eio = struct
  type t = unit

  let v () = ()

  let call _t ~meth:_ ~url:_ ~headers:_ ~body:_ : (response, Error.t) result =
    Error (Not_implemented "HTTP backend is not enabled in this build")
end
