val call : Client.t -> 'a Request.t -> ('a, Error.t) result
val call_json : Client.t -> method_name:string -> Yojson.Safe.t -> (Yojson.Safe.t, Error.t) result
