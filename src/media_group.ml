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

let photo ?caption ?parse_mode ?(show_caption_above = false) ?(has_spoiler = false) file =
  Photo (file, { caption; parse_mode; show_caption_above; has_spoiler })

let video
    ?caption
    ?parse_mode
    ?(show_caption_above = false)
    ?(has_spoiler = false)
    ?width
    ?height
    ?duration
    ?(supports_streaming = false)
    ?thumbnail
    file =
  Video (file, {
    caption;
    parse_mode;
    show_caption_above;
    has_spoiler;
    width;
    height;
    duration;
    supports_streaming;
    thumbnail;
  })

(** {1 Media Group Builder} *)

type t = item list  (* Guaranteed to have 2-10 items *)

type builder = {
  items : item list;
  count : int;
}

let create item1 item2 = {
  items = [item1; item2];
  count = 2;
}

let add item builder =
  if builder.count >= 10 then
    builder  (* Silently ignore if already at max - use try_add for error handling *)
  else
    { items = item :: builder.items; count = builder.count + 1 }

let try_add item builder =
  if builder.count >= 10 then
    Error (Printf.sprintf "Media group already has maximum of 10 items")
  else
    Ok { items = item :: builder.items; count = builder.count + 1 }

let build builder = List.rev builder.items

let items t = t

let size t = List.length t

(** {1 Convenience Functions} *)

let of_list lst =
  let len = List.length lst in
  if len < 2 then
    Error "Media group must have at least 2 items"
  else if len > 10 then
    Error "Media group cannot have more than 10 items"
  else
    Ok lst

let to_list t = t

(** {1 Serialization} *)

let input_file_to_string (file : Input_file.t) =
  (* For uploads, we need attach:// prefix *)
  if Input_file.is_upload file then
    match Input_file.to_multipart_part ~field_name:"media" file with
    | Some (_, filename, _, _) -> "attach://" ^ filename
    | None -> Input_file.to_string file
  else
    Input_file.to_string file

let item_to_yojson (item : item) : Yojson.Safe.t =
  match item with
  | Photo (file, opts) ->
      let fields = [
        ("type", `String "photo");
        ("media", `String (input_file_to_string file));
      ] in
      let fields = match opts.caption with
        | None -> fields
        | Some c -> fields @ [("caption", `String c)]
      in
      let fields = match opts.parse_mode with
        | None -> fields
        | Some pm -> fields @ [("parse_mode", `String (Parse_mode.to_string pm))]
      in
      let fields = if opts.show_caption_above
        then fields @ [("show_caption_above_media", `Bool true)]
        else fields
      in
      let fields = if opts.has_spoiler
        then fields @ [("has_spoiler", `Bool true)]
        else fields
      in
      `Assoc fields

  | Video (file, opts) ->
      let fields = [
        ("type", `String "video");
        ("media", `String (input_file_to_string file));
      ] in
      let fields = match opts.thumbnail with
        | None -> fields
        | Some t -> fields @ [("thumbnail", `String (input_file_to_string t))]
      in
      let fields = match opts.caption with
        | None -> fields
        | Some c -> fields @ [("caption", `String c)]
      in
      let fields = match opts.parse_mode with
        | None -> fields
        | Some pm -> fields @ [("parse_mode", `String (Parse_mode.to_string pm))]
      in
      let fields = if opts.show_caption_above
        then fields @ [("show_caption_above_media", `Bool true)]
        else fields
      in
      let fields = match opts.width with
        | None -> fields
        | Some w -> fields @ [("width", `Int w)]
      in
      let fields = match opts.height with
        | None -> fields
        | Some h -> fields @ [("height", `Int h)]
      in
      let fields = match opts.duration with
        | None -> fields
        | Some d -> fields @ [("duration", `Int d)]
      in
      let fields = if opts.supports_streaming
        then fields @ [("supports_streaming", `Bool true)]
        else fields
      in
      let fields = if opts.has_spoiler
        then fields @ [("has_spoiler", `Bool true)]
        else fields
      in
      `Assoc fields

let to_yojson (t : t) : Yojson.Safe.t =
  `List (List.map item_to_yojson t)
