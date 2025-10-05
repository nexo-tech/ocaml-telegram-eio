type method_ = [ `GET | `POST ]

type header = string * string

type part_value = [ `String of string | `File of string * string option * string ]

type progress_callback = bytes_sent:int64 -> total_bytes:int64 option -> unit
(** Progress callback for upload operations.
    - [bytes_sent]: Number of bytes sent so far
    - [total_bytes]: Total bytes to send (None if unknown) *)

type body =
  | Empty
  | String of string
  | Multipart of (string * part_value) list
  | Multipart_progress of (string * part_value) list * progress_callback
  (** Multipart upload with progress callback *)

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
  val v : ?chunk_size:int -> unit -> t
  include S with type t := t
end
