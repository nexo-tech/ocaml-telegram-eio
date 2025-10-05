open Types

type _ t =
  | Send_message : {
      chat_id : Id.Chat.k Id.t;
      text : string;
      parse_mode : parse_mode option;
      reply_parameters : reply_parameters option;
    } -> Types.message t
  | Send_photo : {
      chat_id : Id.Chat.k Id.t;
      photo : [ `File_id of string | `Url of string | `Path of string ];
      caption : string option;
    } -> Types.message t

val send_message
  :  chat_id:Id.Chat.k Id.t
  -> text:string
  -> ?parse_mode:parse_mode
  -> ?reply_parameters:reply_parameters
  -> unit -> Types.message t

val send_photo
  :  chat_id:Id.Chat.k Id.t
  -> photo:[ `File_id of string | `Url of string | `Path of string ]
  -> ?caption:string
  -> unit -> Types.message t

(* A minimal subset sufficient for examples; more will be generated later. *)
