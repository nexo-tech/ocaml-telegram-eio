(** High-level API for sending media groups (albums) *)

open Telegram

(** Re-export Media_group types for convenience *)

type photo_options = Media_group.photo_options = {
  caption : string option;
  parse_mode : Parse_mode.t option;
  show_caption_above : bool;
  has_spoiler : bool;
}

type video_options = Media_group.video_options = {
  caption : string option;
  parse_mode : Parse_mode.t option;
  show_caption_above : bool;
  has_spoiler : bool;
  width : int option;
  height : int option;
  duration : int option;
  supports_streaming : bool;
  thumbnail : Input_file.t option;
}

type item = Media_group.item =
  | Photo of Input_file.t * photo_options
  | Video of Input_file.t * video_options

type t = Media_group.t
type builder = Media_group.builder

(** {1 Item Constructors} *)

val photo : ?caption:string -> ?parse_mode:Parse_mode.t -> ?show_caption_above:bool -> ?has_spoiler:bool -> Input_file.t -> item
val video :
  ?caption:string ->
  ?parse_mode:Parse_mode.t ->
  ?show_caption_above:bool ->
  ?has_spoiler:bool ->
  ?width:int ->
  ?height:int ->
  ?duration:int ->
  ?supports_streaming:bool ->
  ?thumbnail:Input_file.t ->
  Input_file.t -> item

(** {1 Building Media Groups} *)

val create : item -> item -> builder
val add : item -> builder -> builder
val try_add : item -> builder -> (builder, string) result
val build : builder -> t
val of_list : item list -> (t, string) result

(** {1 Sending Media Groups} *)

val send :
  Client.t ->
  chat_id:Id.Chat.k Id.t ->
  ?disable_notification:bool ->
  ?protect_content:bool ->
  t ->
  (Telegram_generated.Gen_types.Message.t list, Error.t) result
(** Send a media group (album) to a chat.

    The media group must contain 2-10 items (enforced by the type system).

    Example:
    {[
      let album = Album.create
        (Album.photo ~caption:"First" (Input_file.path "photo1.jpg"))
        (Album.photo ~caption:"Second" (Input_file.path "photo2.jpg"))
        |> Album.add (Album.photo (Input_file.path "photo3.jpg"))
        |> Album.build
      in
      match Album.send client ~chat_id album with
      | Ok messages -> Printf.printf "Sent %d messages\n" (List.length messages)
      | Error e -> Error.pp Format.std_formatter e
    ]} *)
