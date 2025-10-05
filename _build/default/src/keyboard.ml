open Telegram.Types

type inline = inline_keyboard_button

let inline rows : inline_keyboard_markup = rows

let url ~text ~url = Url_button { text; url }

let callback ~text ~data = Callback_button { text; data }
