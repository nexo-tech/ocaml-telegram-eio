open Types

type _ t =
  | Send_message : {
      chat_id : Id.Chat.k Id.t;
      text : string;
      parse_mode : parse_mode option;
      reply_parameters : reply_parameters option;
    } -> message t
  | Send_photo : {
      chat_id : Id.Chat.k Id.t;
      photo : [ `File_id of string | `Url of string | `Path of string ];
      caption : string option;
    } -> message t

let send_message ~chat_id ~text ?parse_mode ?reply_parameters () =
  Send_message { chat_id; text; parse_mode; reply_parameters }

let send_photo ~chat_id ~photo ?caption () =
  Send_photo { chat_id; photo; caption }
