(* Request parameter encoding for Telegram Bot API.

   This module provides utilities for encoding request parameters,
   supporting both JSON-only requests and multipart/form-data for file uploads.

   The key insight: parameters are built as a list, and we automatically
   detect if any contain file uploads to choose the encoding method.
*)

(** A request parameter value. *)
type value =
  | String of string
  | Int of int
  | Int64 of int64
  | Bool of bool
  | Float of float
  | File of Input_file.t
  | Json of Yojson.Safe.t  (* For complex objects *)
  | List of value list

(** A named parameter. *)
type t = string * value

(** Smart constructors for parameter values. *)

val string : string -> value
val int : int -> value
val int64 : int64 -> value
val bool : bool -> value
val float : float -> value
val file : Input_file.t -> value
val json : Yojson.Safe.t -> value
val list : value list -> value

(** Convenience: wrap value in optional parameter.
    Returns None if value is None, Some (name, value) otherwise. *)
val opt : string -> 'a option -> ('a -> value) -> t option

(** Check if any parameter contains a file upload. *)
val has_files : t list -> bool

(** Encode parameters as JSON for application/json requests. *)
val to_json : t list -> Yojson.Safe.t

(** Encode parameters as multipart/form-data.
    Returns list of (field_name, part) suitable for Http.Multipart. *)
val to_multipart : t list -> (string * [ `String of string | `File of string * string option * string ]) list
