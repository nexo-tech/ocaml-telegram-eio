type 'a codec

val make : name:string -> encode:('a -> Yojson.Safe.t) -> decode:(Yojson.Safe.t -> ('a, string) result) -> 'a codec
val encode : secret:string -> 'a codec -> 'a -> string
val decode : secret:string -> 'a codec -> string -> ('a, string) result
