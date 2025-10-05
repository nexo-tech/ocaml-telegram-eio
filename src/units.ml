module Duration = struct
  type t = int64  (* seconds *)

  let seconds n = Int64.of_int n

  let of_int64 n = n

  let to_int t = Int64.to_int t

  let to_int64 t = t

  let pp fmt t =
    let n = Int64.to_int t in
    if n < 60 then
      Format.fprintf fmt "%ds" n
    else if n < 3600 then
      let m = n / 60 in
      let s = n mod 60 in
      if s = 0 then Format.fprintf fmt "%dm" m
      else Format.fprintf fmt "%dm%ds" m s
    else
      let h = n / 3600 in
      let m = (n mod 3600) / 60 in
      let s = n mod 60 in
      if m = 0 && s = 0 then Format.fprintf fmt "%dh" h
      else if s = 0 then Format.fprintf fmt "%dh%dm" h m
      else Format.fprintf fmt "%dh%dm%ds" h m s

  let to_string t = Format.asprintf "%a" pp t

  let to_yojson t = `Int (Int64.to_int t)

  let of_yojson = function
    | `Int n -> Ok (Int64.of_int n)
    | `Intlit s -> (try Ok (Int64.of_string s) with _ -> Error "Duration: invalid integer")
    | _ -> Error "Duration: expected integer"
end

module File_size = struct
  type t = int64  (* bytes *)

  let bytes n = n

  let to_int64 t = t

  let pp fmt t =
    let open Int64 in
    let kb = 1024L in
    let mb = mul kb 1024L in
    let gb = mul mb 1024L in
    let tb = mul gb 1024L in

    if t < kb then
      Format.fprintf fmt "%Ld B" t
    else if t < mb then
      let kb_val = to_float t /. to_float kb in
      Format.fprintf fmt "%.1f KB" kb_val
    else if t < gb then
      let mb_val = to_float t /. to_float mb in
      Format.fprintf fmt "%.1f MB" mb_val
    else if t < tb then
      let gb_val = to_float t /. to_float gb in
      Format.fprintf fmt "%.1f GB" gb_val
    else
      let tb_val = to_float t /. to_float tb in
      Format.fprintf fmt "%.1f TB" tb_val

  let to_string t = Format.asprintf "%a" pp t

  let to_yojson t = `Intlit (Int64.to_string t)

  let of_yojson = function
    | `Int n -> Ok (Int64.of_int n)
    | `Intlit s -> (try Ok (Int64.of_string s) with _ -> Error "File_size: invalid integer")
    | _ -> Error "File_size: expected integer"
end
