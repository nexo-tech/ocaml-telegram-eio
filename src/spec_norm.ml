let is_whitespace = function ' ' | '\n' | '\t' | '\r' -> true | _ -> false

let trim s =
  let n = String.length s in
  let i = ref 0 and j = ref (n - 1) in
  while !i < n && is_whitespace s.[!i] do incr i done;
  while !j >= !i && is_whitespace s.[!j] do decr j done;
  if !j < !i then "" else String.sub s !i (!j - !i + 1)


let split_on substr s =
  let rec aux acc i =
    match String.index_from_opt s i substr.[0] with
    | None -> List.rev (String.sub s i (String.length s - i) :: acc)
    | Some k when k + String.length substr <= String.length s && String.sub s k (String.length substr) = substr ->
        aux (String.sub s i (k - i) :: acc) (k + String.length substr)
    | Some k -> aux acc (k + 1)
  in
  aux [] 0

type t =
  | TInt64
  | TString
  | TBool
  | TFloat
  | TCustom of string
  | TArray of t
  | TUnion of t list

let rec to_string = function
  | TInt64 -> "int64"
  | TString -> "string"
  | TBool -> "bool"
  | TFloat -> "float"
  | TCustom s -> s
  | TArray t -> to_string t ^ " list"
  | TUnion ts -> String.concat " | " (List.map to_string ts)

let rec parse_type s =
  let s = trim s in
  match s with
  | "Integer" -> TInt64
  | "String" -> TString
  | "Boolean" -> TBool
  | "True" -> TBool
  | "Float" -> TFloat
  | _ when String.length s >= 9 && String.sub s 0 9 = "Array of " ->
      let inner = String.sub s 9 (String.length s - 9) |> parse_type in
      TArray inner
  | _ ->
      (* union split by " or " *)
      let parts = split_on " or " s |> List.map trim |> List.filter (fun x -> x <> "") in
      begin match parts with
      | [] -> TCustom s
      | [one] -> TCustom one
      | many ->
          let ts = List.map parse_type many in
          TUnion ts
      end

let is_reserved = function
  | "and"|"as"|"assert"|"begin"|"class"|"constraint"|"do"|"done"|"downto"|"else"
  | "end"|"exception"|"external"|"false"|"for"|"fun"|"function"|"functor"|"if"|"in"
  | "include"|"inherit"|"initializer"|"lazy"|"let"|"match"|"method"|"mod"|"module"
  | "mutable"|"new"|"nonrec"|"object"|"of"|"open"|"or"|"private"|"rec"|"sig"|"struct"
  | "then"|"to"|"true"|"try"|"type"|"val"|"virtual"|"when"|"while"|"with" -> true
  | _ -> false

let sanitize_ident s =
  let b = Buffer.create (String.length s) in
  String.iter (fun c ->
    match c with
    | 'a'..'z' | '0'..'9' | '_' -> Buffer.add_char b c
    | 'A'..'Z' -> Buffer.add_char b (Char.lowercase_ascii c)
    | _ -> Buffer.add_char b '_'
  ) s;
  let r = Buffer.contents b in
  if is_reserved r then r ^ "_" else r

let ocaml_field_name s = sanitize_ident s

let ocaml_type_name s =
  (* convert CamelCase / TitleCase to snake_case *)
  let rec go acc i =
    if i >= String.length s then List.rev acc else
    let c = s.[i] in
    if i > 0 && Char.uppercase_ascii c = c && Char.lowercase_ascii c <> c then
      go ((String.make 1 (Char.lowercase_ascii c)) :: "_" :: acc) (i+1)
    else go ((String.make 1 (Char.lowercase_ascii c)) :: acc) (i+1)
  in
  sanitize_ident (String.concat "" (go [] 0))
