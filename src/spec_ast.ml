type field = {
  name : string;
  typ : string;
  optional : bool;
  description : string;
}

type tdef = {
  anchor : string;
  title : string;
  fields : field list;
}

let pp_field (f : field) =
  Printf.sprintf "- %s : %s%s -- %s"
    f.name f.typ (if f.optional then " (optional)" else "") f.description

let pp_tdef (d : tdef) =
  let header = Printf.sprintf "[%s] %s" d.anchor d.title in
  let body = String.concat "\n" (List.map pp_field d.fields) in
  header ^ "\n" ^ body

type mdef = {
  m_anchor : string;
  m_name : string;
  returns : string option;
  params : field list;
}

let pp_mdef (m : mdef) =
  let header = Printf.sprintf "[%s] %s -> %s" m.m_anchor m.m_name (match m.returns with None -> "?" | Some r -> r) in
  let body = String.concat "\n" (List.map pp_field m.params) in
  header ^ "\n" ^ body
