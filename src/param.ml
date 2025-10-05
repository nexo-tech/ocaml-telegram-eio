(* Request parameter encoding for Telegram Bot API. *)

type value =
  | String of string
  | Int of int
  | Int64 of int64
  | Bool of bool
  | Float of float
  | File of Input_file.t
  | Json of Yojson.Safe.t
  | List of value list

type t = string * value

(* Smart constructors *)
let string s = String s
let int i = Int i
let int64 i = Int64 i
let bool b = Bool b
let float f = Float f
let file f = File f
let json j = Json j
let list vs = List vs

let opt name value_opt constructor =
  match value_opt with
  | None -> None
  | Some v -> Some (name, constructor v)

(* Check if value contains files *)
let rec value_has_files = function
  | File f -> Input_file.is_upload f
  | List vs -> List.exists value_has_files vs
  | String _ | Int _ | Int64 _ | Bool _ | Float _ | Json _ -> false

let has_files params =
  List.exists (fun (_name, value) -> value_has_files value) params

(* Convert value to JSON *)
let rec value_to_json = function
  | String s -> `String s
  | Int i -> `Int i
  | Int64 i -> `Intlit (Int64.to_string i)
  | Bool b -> `Bool b
  | Float f -> `Float f
  | File f -> `String (Input_file.to_string f)
  | Json j -> j
  | List vs -> `List (List.map value_to_json vs)

let to_json params =
  let fields = List.map (fun (name, value) -> (name, value_to_json value)) params in
  `Assoc fields

(* Extract files and convert value to multipart string *)
let value_to_multipart_string = function
  | String s -> s
  | Int i -> string_of_int i
  | Int64 i -> Int64.to_string i
  | Bool b -> if b then "true" else "false"
  | Float f -> string_of_float f
  | File f -> Input_file.to_string f
  | Json j -> Yojson.Safe.to_string j
  | List vs ->
      (* For multipart, lists are JSON-encoded *)
      Yojson.Safe.to_string (`List (List.map value_to_json vs))

let rec collect_files field_name = function
  | File f ->
      (match Input_file.to_multipart_part ~field_name f with
       | Some (fn, filename, mime, path) ->
           [fn, `File (filename, mime, path)]
       | None -> [])
  | List vs ->
      (* Files in lists need unique field names *)
      List.mapi (fun i v ->
        collect_files (Printf.sprintf "%s[%d]" field_name i) v
      ) vs |> List.concat
  | String _ | Int _ | Int64 _ | Bool _ | Float _ | Json _ -> []

let to_multipart params =
  (* Collect all file fields first *)
  let file_fields = List.map (fun (name, value) ->
    collect_files name value
  ) params |> List.concat in

  (* Get set of field names that are files *)
  let file_field_names = List.map fst file_fields in

  (* Only add regular fields for non-file parameters *)
  let regular_fields = List.filter_map (fun (name, value) ->
    if List.mem name file_field_names && value_has_files value then
      None
    else
      Some (name, `String (value_to_multipart_string value))
  ) params in

  regular_fields @ file_fields
