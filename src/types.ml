(* no open; refer to Id via direct module reference *)

type user = {
  id : Id.User.k Id.t;
  username : string option;
}

type message = {
  message_id : int;
  chat_id : Id.Chat.k Id.t;
  text : string option;
}

type inline_query = {
  id : string;
  from_user : user;
  query : string;
}

type parse_mode = Parse_mode.t

type message_entity = unit

type reply_parameters = {
  message_id : int option;
}

type inline_keyboard_button =
  | Url_button of { text : string; url : string }
  | Callback_button of { text : string; data : string }

type inline_keyboard_markup = inline_keyboard_button list list
