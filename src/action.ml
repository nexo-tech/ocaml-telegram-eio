type 'a codec = {
  name : string;
  enc : 'a -> Yojson.Safe.t;
  dec : Yojson.Safe.t -> ('a, string) result;
}

let make ~name ~encode ~decode = { name; enc = encode; dec = decode }

let encode ~secret:_ c v =
  let _ = c.name in
  let payload = c.enc v in
  Yojson.Safe.to_string payload

let decode ~secret:_ c s =
  match Yojson.Safe.from_string s with
  | exception _ -> Error "invalid json"
  | json -> c.dec json
