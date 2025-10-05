(* JSON forward compatibility utilities. *)

module Unknown_fields = struct
  type tracker = {
    mutable known : string list;
  }

  type t = (string * Yojson.Safe.t) list

  let empty = []

  let is_empty t = t = []

  let create () = { known = [] }

  let mark_known t name =
    if not (List.mem name t.known) then
      t.known <- name :: t.known

  let capture t all_fields =
    List.filter (fun (name, _) -> not (List.mem name t.known)) all_fields

  let to_assoc t = t

  let count t = List.length t

  let pp fmt t =
    if is_empty t then
      Format.fprintf fmt "{}"
    else
      Format.fprintf fmt "{ %s }"
        (String.concat ", "
          (List.map (fun (k, _) -> Printf.sprintf "%S: <value>" k) t))
end
