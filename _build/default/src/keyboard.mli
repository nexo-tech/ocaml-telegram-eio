open Telegram.Types

type inline

val inline : inline list list -> inline_keyboard_markup
val url : text:string -> url:string -> inline
val callback : text:string -> data:string -> inline
