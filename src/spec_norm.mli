type t =
  | TInt64
  | TString
  | TBool
  | TFloat
  | TCustom of string
  | TArray of t
  | TUnion of t list

val parse_type : string -> t
val to_string : t -> string
val to_ocaml_type : t -> string
val ocaml_module_name : string -> string
val ocaml_type_ref : string -> string

val ocaml_field_name : string -> string
val ocaml_type_name : string -> string
