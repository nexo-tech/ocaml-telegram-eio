(** Type-safe media group (album) builder for Telegram Bot API *)

(** {1 Media Items} *)

type photo_options = {
  caption : string option;
  parse_mode : Parse_mode.t option;
  show_caption_above : bool;
  has_spoiler : bool;
}

type video_options = {
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

type item =
  | Photo of Input_file.t * photo_options
  | Video of Input_file.t * video_options

val photo : ?caption:string -> ?parse_mode:Parse_mode.t -> ?show_caption_above:bool -> ?has_spoiler:bool -> Input_file.t -> item
(** Create a photo item for media group.

    Example:
    {[
      Media_group.photo ~caption:"Beautiful sunset" (Input_file.path "/path/to/photo.jpg")
    ]} *)

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
(** Create a video item for media group.

    Example:
    {[
      Media_group.video
        ~caption:"Amazing video"
        ~supports_streaming:true
        (Input_file.path "/path/to/video.mp4")
    ]} *)

(** {1 Media Group Builder} *)

type t
(** Media group containing 2-10 items *)

type builder
(** Builder for constructing media groups with compile-time size guarantees *)

val create : item -> item -> builder
(** Start building a media group with exactly 2 items (minimum required).

    Example:
    {[
      Media_group.create
        (Media_group.photo (Input_file.path "photo1.jpg"))
        (Media_group.photo (Input_file.path "photo2.jpg"))
    ]} *)

val add : item -> builder -> builder
(** Add an item to the media group (up to 10 total).

    Returns Error if adding would exceed the 10-item limit.

    Example:
    {[
      Media_group.create photo1 photo2
      |> Media_group.add photo3
      |> Media_group.add photo4
    ]} *)

val try_add : item -> builder -> (builder, string) result
(** Try to add an item, returning Result.

    Returns Error if the group already has 10 items.

    Example:
    {[
      match Media_group.try_add photo11 group with
      | Ok g -> g
      | Error msg -> (* handle error *)
    ]} *)

val build : builder -> t
(** Finalize the media group.

    The resulting group is guaranteed to have 2-10 items. *)

val items : t -> item list
(** Get the list of items in the media group (guaranteed 2-10 items). *)

val size : t -> int
(** Get the number of items in the media group (guaranteed 2-10). *)

(** {1 Convenience Functions} *)

val of_list : item list -> (t, string) result
(** Create a media group from a list of items.

    Returns Error if the list has fewer than 2 or more than 10 items.

    Example:
    {[
      match Media_group.of_list [photo1; photo2; photo3] with
      | Ok group -> (* use group *)
      | Error msg -> (* handle error *)
    ]} *)

val to_list : t -> item list
(** Convert media group to a list of items. *)

(** {1 Serialization} *)

val to_yojson : t -> Yojson.Safe.t
(** Convert media group to JSON array for API calls. *)
