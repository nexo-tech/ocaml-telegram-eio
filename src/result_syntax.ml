let ( let* ) m f = match m with Ok x -> f x | Error e -> Error e
let ( let+ ) m f = match m with Ok x -> Ok (f x) | Error e -> Error e
