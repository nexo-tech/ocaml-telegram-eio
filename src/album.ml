(** High-level API for sending media groups (albums) *)

open Telegram

(** Re-export Media_group types *)

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

let photo = Media_group.photo
let video = Media_group.video

(** {1 Building Media Groups} *)

let create = Media_group.create
let add = Media_group.add
let try_add = Media_group.try_add
let build = Media_group.build
let of_list = Media_group.of_list

(** {1 Sending Media Groups} *)

let send client ~chat_id ?disable_notification ?protect_content album =
  (* Convert media group to JSON *)
  let media_json = Telegram.Media_group.to_yojson album in

  (* Build parameters *)
  let params = [
    ("chat_id", `String (Telegram.Id.to_string chat_id));
    ("media", media_json);
  ] @ (match disable_notification with None -> [] | Some v -> [("disable_notification", `Bool v)])
    @ (match protect_content with None -> [] | Some v -> [("protect_content", `Bool v)])
  in

  (* Call API *)
  match Telegram.Api.call_json client ~method_name:"sendMediaGroup" (`Assoc params) with
  | Error e -> Error e
  | Ok json ->
      (* The response is an array of Messages *)
      match json with
      | `List msgs ->
          let open Telegram_generated.Gen_types.Message in
          let results = List.map of_yojson msgs in
          let rec collect_results acc = function
            | [] -> Ok (List.rev acc)
            | (Ok msg :: rest) -> collect_results (msg :: acc) rest
            | (Error e :: _) -> Error (Telegram.Error.Decode_error e)
          in
          collect_results [] results
      | _ -> Error (Telegram.Error.Decode_error "Expected array of messages")
