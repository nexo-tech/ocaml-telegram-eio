(** Execute a typed request. *)
val call : Client.t -> 'a Request.t -> ('a, Error.t) result

(** Call a method with JSON parameters (legacy, for simple requests). *)
val call_json : Client.t -> method_name:string -> Yojson.Safe.t -> (Yojson.Safe.t, Error.t) result

(** Call a method with parameters (auto-detects JSON vs multipart encoding).
    This is the recommended API for generated methods.

    Automatically uses multipart/form-data if any parameter contains file uploads,
    otherwise uses application/json for efficiency.

    Example:
      Api.call_method client ~method_name:"sendPhoto"
        [ "chat_id", Param.string (Id.to_string chat_id)
        ; "photo", Param.file (Input_file.path "/path/to/photo.jpg")
        ; "caption", Param.string "Hello!" ]
*)
val call_method : Client.t -> method_name:string -> Param.t list -> (Yojson.Safe.t, Error.t) result
