(** Keyboard builders for inline and reply keyboards *)

open Telegram.Types

(** {1 Inline Keyboards} *)

type inline
(** Inline keyboard button type *)

val inline : inline list list -> inline_keyboard_markup
(** Create an inline keyboard markup from rows of buttons *)

val url : text:string -> url:string -> inline
(** Create a URL button *)

val callback : text:string -> data:string -> inline
(** Create a callback button with data *)

(** {1 Reply Keyboards} *)

type reply_button = string
(** Reply keyboard button (simple text) *)

type reply_keyboard = reply_button list list
(** Reply keyboard as list of rows *)

val reply : ?resize:bool -> ?one_time:bool -> ?selective:bool -> reply_keyboard -> Yojson.Safe.t
(** Create a reply keyboard markup.
    - [resize]: Request clients to resize keyboard (default: true)
    - [one_time]: Hide keyboard after use (default: false)
    - [selective]: Show only to specific users (default: false) *)

val remove : ?selective:bool -> unit -> Yojson.Safe.t
(** Remove the current keyboard *)

val force_reply : ?selective:bool -> unit -> Yojson.Safe.t
(** Force user to reply to the message *)

(** {1 Layout Helpers} *)

module Layout : sig
  val row : 'a list -> 'a list list
  (** Create a single row *)

  val rows : 'a list list -> 'a list list
  (** Create multiple rows (identity function for clarity) *)

  val grid : columns:int -> 'a list -> 'a list list
  (** Arrange buttons in a grid with specified column count *)

  val vertical : 'a list -> 'a list list
  (** Arrange buttons vertically (one per row) *)

  val horizontal : 'a list -> 'a list list
  (** Arrange buttons horizontally (all in one row) *)
end

(** {1 Common Patterns} *)

module Patterns : sig
  val yes_no : ?yes_text:string -> ?no_text:string -> yes_data:string -> no_data:string -> unit -> inline_keyboard_markup
  (** Yes/No inline keyboard *)

  val confirm : ?confirm_text:string -> ?cancel_text:string -> confirm_data:string -> cancel_data:string -> unit -> inline_keyboard_markup
  (** Confirmation keyboard with confirm/cancel buttons *)

  val pagination : ?prev_text:string -> ?next_text:string -> prev_data:string -> next_data:string -> current_page:int -> total_pages:int -> unit -> inline_keyboard_markup
  (** Pagination keyboard (smart: hides buttons when not needed) *)

  val number_grid : callback_prefix:string -> unit -> inline_keyboard_markup
  (** Phone-style number pad (0-9) *)

  val menu_with_back : back_text:string -> back_data:string -> inline list -> inline_keyboard_markup
  (** Vertical menu with back button at bottom *)
end
