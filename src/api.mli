(** Type-safe Telegram Bot API methods.

    This module provides functions for calling all Telegram Bot API methods.
    It includes both low-level primitives ([call], [call_method]) and
    high-level, auto-generated type-safe wrappers for each API method.

    The API methods are generated from the official Telegram Bot API specification
    and provide compile-time type safety for all parameters and return types.

    {2 Making API Calls}

    {[
      (* Type-safe method call *)
      let req = Api.send_message ~chat_id ~text:"Hello!" () in
      match Api.call client req with
      | Ok message -> (* Message.t *)
      | Error err -> (* Error.t *)

      (* With result syntax *)
      let open Result_syntax in
      let* message = Api.call client (Api.send_message ~chat_id ~text ()) in
      let* photo = Api.call client (Api.send_photo ~chat_id ~photo ()) in
      Ok ()
    ]}

    @see <https://core.telegram.org/bots/api> Official API documentation
*)

(** [call client request] executes a typed API request.

    This is the primary way to make API calls. Each API method returns a
    [Request.t] value that can be executed with [call].

    Returns [Ok result] on success, or [Error err] if the request fails.
    Use {!Error.is_retryable} to determine if an error can be retried.
*)
val call : Client.t -> 'a Request.t -> ('a, Error.t) result

(** {2 Request Builders}

    These functions create typed requests that can be executed with {!call}.
    They are re-exported from the {!Request} module for convenience.
*)

val send_message
  :  chat_id:Id.Chat.k Id.t
  -> text:string
  -> ?parse_mode:Types.parse_mode
  -> ?reply_parameters:Types.reply_parameters
  -> unit -> Types.message Request.t
(** [send_message ~chat_id ~text ()] creates a request to send a text message. *)

val send_photo
  :  chat_id:Id.Chat.k Id.t
  -> photo:[ `File_id of string | `Url of string | `Path of string ]
  -> ?caption:string
  -> unit -> Types.message Request.t
(** [send_photo ~chat_id ~photo ()] creates a request to send a photo. *)

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
