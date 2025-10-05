type method_ = [ `GET | `POST ]

type header = string * string

type body =
  | Empty
  | String of string
  | Multipart of (string * [ `String of string | `File of string * string option * string ]) list

type response = {
  status : int;
  headers : header list;
  body : string;
}

module type S = sig
  type t
  val call : t -> meth:method_ -> url:string -> headers:header list -> body:body -> (response, Error.t) result
end

module Cohttp_eio : sig
  type t
  val v : unit -> t
  include S with type t := t
end
