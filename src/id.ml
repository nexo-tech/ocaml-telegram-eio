type +'k t = Int64 of int64 | Username of string

module Chat = struct
  type k
  let of_int i = (Int64 i : k t)
  let of_username s = (Username s : k t)
  let of_string s =
    match Int64.of_string_opt s with
    | Some i -> (Int64 i : k t)
    | None -> (Username s : k t)
end

module User = struct
  type k
  let of_int i = (Int64 i : k t)
  let of_username s = (Username s : k t)
end

module Message = struct
  type k
  let of_int i = (Int64 (Int64.of_int i) : k t)
end

let pp fmt = function
  | Int64 i -> Format.fprintf fmt "%Ld" i
  | Username s -> Format.pp_print_string fmt s

let to_string = function
  | Int64 i -> Int64.to_string i
  | Username s -> s

module Token = struct
  type t = string
  let of_string s = s
  let to_string t = t
end

module Update = struct
  type k
  let of_int i = (Int64 i : k t)
end

module File_id = struct
  type t = string
  let of_string s = s
  let to_string s = s
end
