module K = struct
  type 'a t = int
end

type 'a key = 'a K.t

type boxed = B : 'a key * 'a -> boxed

type t = {
  mutable store : boxed list;
}

let make ~name:_ = Hashtbl.hash (Obj.new_block Obj.closure_tag 0)

let empty = { store = [] }

let get s k =
  let rec go = function
    | [] -> None
    | B (k', v) :: tl -> if k = k' then Some (Obj.magic v) else go tl
  in
  go s.store

let set s k v =
  s.store <- B (k, v) :: List.filter (fun (B (k', _)) -> k <> k') s.store
