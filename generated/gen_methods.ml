(* Generated method wrappers (typed). *)
open Telegram
open Yojson.Safe
open Gen_types

(* getMe [getme] -> User *)
let get_me (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"getMe" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match User.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* logOut [logout] -> Boolean *)
let log_out (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"logOut" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* close [close] -> Boolean *)
let close (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"close" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* sendMessage [sendmessage] -> Message *)
let send_message (client:Client.t) ~chat_id ~text ?business_connection_id ?message_thread_id ?direct_messages_topic_id ?parse_mode ?entities ?link_preview_options ?disable_notification ?protect_content ?allow_paid_broadcast ?message_effect_id ?suggested_post_parameters ?reply_parameters ?reply_markup () =
  let params = List.filter_map (fun x -> x) [
    (match business_connection_id with None -> None | Some v -> Some ("business_connection_id", `String v));
    Some ("chat_id", `String (Id.to_string chat_id));
    (match message_thread_id with None -> None | Some v -> Some ("message_thread_id", `Intlit (Int64.to_string v)));
    (match direct_messages_topic_id with None -> None | Some v -> Some ("direct_messages_topic_id", `Intlit (Int64.to_string v)));
    Some ("text", `String text);
    (match parse_mode with None -> None | Some v -> Some ("parse_mode", `String v));
    (match entities with None -> None | Some v -> Some ("entities", `List (List.map (fun x -> MessageEntity.to_yojson x) v)));
    (match link_preview_options with None -> None | Some v -> Some ("link_preview_options", LinkPreviewOptions.to_yojson v));
    (match disable_notification with None -> None | Some v -> Some ("disable_notification", `Bool v));
    (match protect_content with None -> None | Some v -> Some ("protect_content", `Bool v));
    (match allow_paid_broadcast with None -> None | Some v -> Some ("allow_paid_broadcast", `Bool v));
    (match message_effect_id with None -> None | Some v -> Some ("message_effect_id", `String v));
    (match suggested_post_parameters with None -> None | Some v -> Some ("suggested_post_parameters", SuggestedPostParameters.to_yojson v));
    (match reply_parameters with None -> None | Some v -> Some ("reply_parameters", ReplyParameters.to_yojson v));
    (match reply_markup with None -> None | Some v -> Some ("reply_markup", `String v));
  ] in
  match Api.call_json client ~method_name:"sendMessage" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match Message.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* forwardMessage [forwardmessage] -> Message *)
let forward_message (client:Client.t) ~chat_id ~from_chat_id ~message_id ?message_thread_id ?direct_messages_topic_id ?video_start_timestamp ?disable_notification ?protect_content ?suggested_post_parameters () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    (match message_thread_id with None -> None | Some v -> Some ("message_thread_id", `Intlit (Int64.to_string v)));
    (match direct_messages_topic_id with None -> None | Some v -> Some ("direct_messages_topic_id", `Intlit (Int64.to_string v)));
    Some ("from_chat_id", `String from_chat_id);
    (match video_start_timestamp with None -> None | Some v -> Some ("video_start_timestamp", `Intlit (Int64.to_string v)));
    (match disable_notification with None -> None | Some v -> Some ("disable_notification", `Bool v));
    (match protect_content with None -> None | Some v -> Some ("protect_content", `Bool v));
    (match suggested_post_parameters with None -> None | Some v -> Some ("suggested_post_parameters", SuggestedPostParameters.to_yojson v));
    Some ("message_id", `Intlit (Int64.to_string message_id));
  ] in
  match Api.call_json client ~method_name:"forwardMessage" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match Message.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* forwardMessages [forwardmessages] -> MessageId *)
let forward_messages (client:Client.t) ~chat_id ~from_chat_id ~message_ids ?message_thread_id ?direct_messages_topic_id ?disable_notification ?protect_content () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    (match message_thread_id with None -> None | Some v -> Some ("message_thread_id", `Intlit (Int64.to_string v)));
    (match direct_messages_topic_id with None -> None | Some v -> Some ("direct_messages_topic_id", `Intlit (Int64.to_string v)));
    Some ("from_chat_id", `String from_chat_id);
    Some ("message_ids", `List (List.map (fun x -> `Intlit (Int64.to_string x)) message_ids));
    (match disable_notification with None -> None | Some v -> Some ("disable_notification", `Bool v));
    (match protect_content with None -> None | Some v -> Some ("protect_content", `Bool v));
  ] in
  match Api.call_json client ~method_name:"forwardMessages" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match MessageId.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* copyMessage [copymessage] -> MessageId *)
let copy_message (client:Client.t) ~chat_id ~from_chat_id ~message_id ?message_thread_id ?direct_messages_topic_id ?video_start_timestamp ?caption ?parse_mode ?caption_entities ?show_caption_above_media ?disable_notification ?protect_content ?allow_paid_broadcast ?suggested_post_parameters ?reply_parameters ?reply_markup () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    (match message_thread_id with None -> None | Some v -> Some ("message_thread_id", `Intlit (Int64.to_string v)));
    (match direct_messages_topic_id with None -> None | Some v -> Some ("direct_messages_topic_id", `Intlit (Int64.to_string v)));
    Some ("from_chat_id", `String from_chat_id);
    Some ("message_id", `Intlit (Int64.to_string message_id));
    (match video_start_timestamp with None -> None | Some v -> Some ("video_start_timestamp", `Intlit (Int64.to_string v)));
    (match caption with None -> None | Some v -> Some ("caption", `String v));
    (match parse_mode with None -> None | Some v -> Some ("parse_mode", `String v));
    (match caption_entities with None -> None | Some v -> Some ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) v)));
    (match show_caption_above_media with None -> None | Some v -> Some ("show_caption_above_media", `Bool v));
    (match disable_notification with None -> None | Some v -> Some ("disable_notification", `Bool v));
    (match protect_content with None -> None | Some v -> Some ("protect_content", `Bool v));
    (match allow_paid_broadcast with None -> None | Some v -> Some ("allow_paid_broadcast", `Bool v));
    (match suggested_post_parameters with None -> None | Some v -> Some ("suggested_post_parameters", SuggestedPostParameters.to_yojson v));
    (match reply_parameters with None -> None | Some v -> Some ("reply_parameters", ReplyParameters.to_yojson v));
    (match reply_markup with None -> None | Some v -> Some ("reply_markup", `String v));
  ] in
  match Api.call_json client ~method_name:"copyMessage" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match MessageId.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* copyMessages [copymessages] -> MessageId *)
let copy_messages (client:Client.t) ~chat_id ~from_chat_id ~message_ids ?message_thread_id ?direct_messages_topic_id ?disable_notification ?protect_content ?remove_caption () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    (match message_thread_id with None -> None | Some v -> Some ("message_thread_id", `Intlit (Int64.to_string v)));
    (match direct_messages_topic_id with None -> None | Some v -> Some ("direct_messages_topic_id", `Intlit (Int64.to_string v)));
    Some ("from_chat_id", `String from_chat_id);
    Some ("message_ids", `List (List.map (fun x -> `Intlit (Int64.to_string x)) message_ids));
    (match disable_notification with None -> None | Some v -> Some ("disable_notification", `Bool v));
    (match protect_content with None -> None | Some v -> Some ("protect_content", `Bool v));
    (match remove_caption with None -> None | Some v -> Some ("remove_caption", `Bool v));
  ] in
  match Api.call_json client ~method_name:"copyMessages" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match MessageId.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* sendPhoto [sendphoto] -> Message *)
let send_photo (client:Client.t) ~chat_id ~photo ?business_connection_id ?message_thread_id ?direct_messages_topic_id ?caption ?parse_mode ?caption_entities ?show_caption_above_media ?has_spoiler ?disable_notification ?protect_content ?allow_paid_broadcast ?message_effect_id ?suggested_post_parameters ?reply_parameters ?reply_markup () =
  let params = List.filter_map (fun x -> x) [
    (match business_connection_id with None -> None | Some v -> Some ("business_connection_id", `String v));
    Some ("chat_id", `String (Id.to_string chat_id));
    (match message_thread_id with None -> None | Some v -> Some ("message_thread_id", `Intlit (Int64.to_string v)));
    (match direct_messages_topic_id with None -> None | Some v -> Some ("direct_messages_topic_id", `Intlit (Int64.to_string v)));
    Some ("photo", `String photo);
    (match caption with None -> None | Some v -> Some ("caption", `String v));
    (match parse_mode with None -> None | Some v -> Some ("parse_mode", `String v));
    (match caption_entities with None -> None | Some v -> Some ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) v)));
    (match show_caption_above_media with None -> None | Some v -> Some ("show_caption_above_media", `Bool v));
    (match has_spoiler with None -> None | Some v -> Some ("has_spoiler", `Bool v));
    (match disable_notification with None -> None | Some v -> Some ("disable_notification", `Bool v));
    (match protect_content with None -> None | Some v -> Some ("protect_content", `Bool v));
    (match allow_paid_broadcast with None -> None | Some v -> Some ("allow_paid_broadcast", `Bool v));
    (match message_effect_id with None -> None | Some v -> Some ("message_effect_id", `String v));
    (match suggested_post_parameters with None -> None | Some v -> Some ("suggested_post_parameters", SuggestedPostParameters.to_yojson v));
    (match reply_parameters with None -> None | Some v -> Some ("reply_parameters", ReplyParameters.to_yojson v));
    (match reply_markup with None -> None | Some v -> Some ("reply_markup", `String v));
  ] in
  match Api.call_json client ~method_name:"sendPhoto" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match Message.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* sendAudio [sendaudio] -> Message *)
let send_audio (client:Client.t) ~chat_id ~audio ?business_connection_id ?message_thread_id ?direct_messages_topic_id ?caption ?parse_mode ?caption_entities ?duration ?performer ?title ?thumbnail ?disable_notification ?protect_content ?allow_paid_broadcast ?message_effect_id ?suggested_post_parameters ?reply_parameters ?reply_markup () =
  let params = List.filter_map (fun x -> x) [
    (match business_connection_id with None -> None | Some v -> Some ("business_connection_id", `String v));
    Some ("chat_id", `String (Id.to_string chat_id));
    (match message_thread_id with None -> None | Some v -> Some ("message_thread_id", `Intlit (Int64.to_string v)));
    (match direct_messages_topic_id with None -> None | Some v -> Some ("direct_messages_topic_id", `Intlit (Int64.to_string v)));
    Some ("audio", `String audio);
    (match caption with None -> None | Some v -> Some ("caption", `String v));
    (match parse_mode with None -> None | Some v -> Some ("parse_mode", `String v));
    (match caption_entities with None -> None | Some v -> Some ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) v)));
    (match duration with None -> None | Some v -> Some ("duration", `Intlit (Int64.to_string v)));
    (match performer with None -> None | Some v -> Some ("performer", `String v));
    (match title with None -> None | Some v -> Some ("title", `String v));
    (match thumbnail with None -> None | Some v -> Some ("thumbnail", `String v));
    (match disable_notification with None -> None | Some v -> Some ("disable_notification", `Bool v));
    (match protect_content with None -> None | Some v -> Some ("protect_content", `Bool v));
    (match allow_paid_broadcast with None -> None | Some v -> Some ("allow_paid_broadcast", `Bool v));
    (match message_effect_id with None -> None | Some v -> Some ("message_effect_id", `String v));
    (match suggested_post_parameters with None -> None | Some v -> Some ("suggested_post_parameters", SuggestedPostParameters.to_yojson v));
    (match reply_parameters with None -> None | Some v -> Some ("reply_parameters", ReplyParameters.to_yojson v));
    (match reply_markup with None -> None | Some v -> Some ("reply_markup", `String v));
  ] in
  match Api.call_json client ~method_name:"sendAudio" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match Message.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* sendDocument [senddocument] -> Message *)
let send_document (client:Client.t) ~chat_id ~document ?business_connection_id ?message_thread_id ?direct_messages_topic_id ?thumbnail ?caption ?parse_mode ?caption_entities ?disable_content_type_detection ?disable_notification ?protect_content ?allow_paid_broadcast ?message_effect_id ?suggested_post_parameters ?reply_parameters ?reply_markup () =
  let params = List.filter_map (fun x -> x) [
    (match business_connection_id with None -> None | Some v -> Some ("business_connection_id", `String v));
    Some ("chat_id", `String (Id.to_string chat_id));
    (match message_thread_id with None -> None | Some v -> Some ("message_thread_id", `Intlit (Int64.to_string v)));
    (match direct_messages_topic_id with None -> None | Some v -> Some ("direct_messages_topic_id", `Intlit (Int64.to_string v)));
    Some ("document", `String document);
    (match thumbnail with None -> None | Some v -> Some ("thumbnail", `String v));
    (match caption with None -> None | Some v -> Some ("caption", `String v));
    (match parse_mode with None -> None | Some v -> Some ("parse_mode", `String v));
    (match caption_entities with None -> None | Some v -> Some ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) v)));
    (match disable_content_type_detection with None -> None | Some v -> Some ("disable_content_type_detection", `Bool v));
    (match disable_notification with None -> None | Some v -> Some ("disable_notification", `Bool v));
    (match protect_content with None -> None | Some v -> Some ("protect_content", `Bool v));
    (match allow_paid_broadcast with None -> None | Some v -> Some ("allow_paid_broadcast", `Bool v));
    (match message_effect_id with None -> None | Some v -> Some ("message_effect_id", `String v));
    (match suggested_post_parameters with None -> None | Some v -> Some ("suggested_post_parameters", SuggestedPostParameters.to_yojson v));
    (match reply_parameters with None -> None | Some v -> Some ("reply_parameters", ReplyParameters.to_yojson v));
    (match reply_markup with None -> None | Some v -> Some ("reply_markup", `String v));
  ] in
  match Api.call_json client ~method_name:"sendDocument" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match Message.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* sendVideo [sendvideo] -> Message *)
let send_video (client:Client.t) ~chat_id ~video ?business_connection_id ?message_thread_id ?direct_messages_topic_id ?duration ?width ?height ?thumbnail ?cover ?start_timestamp ?caption ?parse_mode ?caption_entities ?show_caption_above_media ?has_spoiler ?supports_streaming ?disable_notification ?protect_content ?allow_paid_broadcast ?message_effect_id ?suggested_post_parameters ?reply_parameters ?reply_markup () =
  let params = List.filter_map (fun x -> x) [
    (match business_connection_id with None -> None | Some v -> Some ("business_connection_id", `String v));
    Some ("chat_id", `String (Id.to_string chat_id));
    (match message_thread_id with None -> None | Some v -> Some ("message_thread_id", `Intlit (Int64.to_string v)));
    (match direct_messages_topic_id with None -> None | Some v -> Some ("direct_messages_topic_id", `Intlit (Int64.to_string v)));
    Some ("video", `String video);
    (match duration with None -> None | Some v -> Some ("duration", `Intlit (Int64.to_string v)));
    (match width with None -> None | Some v -> Some ("width", `Intlit (Int64.to_string v)));
    (match height with None -> None | Some v -> Some ("height", `Intlit (Int64.to_string v)));
    (match thumbnail with None -> None | Some v -> Some ("thumbnail", `String v));
    (match cover with None -> None | Some v -> Some ("cover", `String v));
    (match start_timestamp with None -> None | Some v -> Some ("start_timestamp", `Intlit (Int64.to_string v)));
    (match caption with None -> None | Some v -> Some ("caption", `String v));
    (match parse_mode with None -> None | Some v -> Some ("parse_mode", `String v));
    (match caption_entities with None -> None | Some v -> Some ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) v)));
    (match show_caption_above_media with None -> None | Some v -> Some ("show_caption_above_media", `Bool v));
    (match has_spoiler with None -> None | Some v -> Some ("has_spoiler", `Bool v));
    (match supports_streaming with None -> None | Some v -> Some ("supports_streaming", `Bool v));
    (match disable_notification with None -> None | Some v -> Some ("disable_notification", `Bool v));
    (match protect_content with None -> None | Some v -> Some ("protect_content", `Bool v));
    (match allow_paid_broadcast with None -> None | Some v -> Some ("allow_paid_broadcast", `Bool v));
    (match message_effect_id with None -> None | Some v -> Some ("message_effect_id", `String v));
    (match suggested_post_parameters with None -> None | Some v -> Some ("suggested_post_parameters", SuggestedPostParameters.to_yojson v));
    (match reply_parameters with None -> None | Some v -> Some ("reply_parameters", ReplyParameters.to_yojson v));
    (match reply_markup with None -> None | Some v -> Some ("reply_markup", `String v));
  ] in
  match Api.call_json client ~method_name:"sendVideo" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match Message.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* sendAnimation [sendanimation] -> Message *)
let send_animation (client:Client.t) ~chat_id ~animation ?business_connection_id ?message_thread_id ?direct_messages_topic_id ?duration ?width ?height ?thumbnail ?caption ?parse_mode ?caption_entities ?show_caption_above_media ?has_spoiler ?disable_notification ?protect_content ?allow_paid_broadcast ?message_effect_id ?suggested_post_parameters ?reply_parameters ?reply_markup () =
  let params = List.filter_map (fun x -> x) [
    (match business_connection_id with None -> None | Some v -> Some ("business_connection_id", `String v));
    Some ("chat_id", `String (Id.to_string chat_id));
    (match message_thread_id with None -> None | Some v -> Some ("message_thread_id", `Intlit (Int64.to_string v)));
    (match direct_messages_topic_id with None -> None | Some v -> Some ("direct_messages_topic_id", `Intlit (Int64.to_string v)));
    Some ("animation", `String animation);
    (match duration with None -> None | Some v -> Some ("duration", `Intlit (Int64.to_string v)));
    (match width with None -> None | Some v -> Some ("width", `Intlit (Int64.to_string v)));
    (match height with None -> None | Some v -> Some ("height", `Intlit (Int64.to_string v)));
    (match thumbnail with None -> None | Some v -> Some ("thumbnail", `String v));
    (match caption with None -> None | Some v -> Some ("caption", `String v));
    (match parse_mode with None -> None | Some v -> Some ("parse_mode", `String v));
    (match caption_entities with None -> None | Some v -> Some ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) v)));
    (match show_caption_above_media with None -> None | Some v -> Some ("show_caption_above_media", `Bool v));
    (match has_spoiler with None -> None | Some v -> Some ("has_spoiler", `Bool v));
    (match disable_notification with None -> None | Some v -> Some ("disable_notification", `Bool v));
    (match protect_content with None -> None | Some v -> Some ("protect_content", `Bool v));
    (match allow_paid_broadcast with None -> None | Some v -> Some ("allow_paid_broadcast", `Bool v));
    (match message_effect_id with None -> None | Some v -> Some ("message_effect_id", `String v));
    (match suggested_post_parameters with None -> None | Some v -> Some ("suggested_post_parameters", SuggestedPostParameters.to_yojson v));
    (match reply_parameters with None -> None | Some v -> Some ("reply_parameters", ReplyParameters.to_yojson v));
    (match reply_markup with None -> None | Some v -> Some ("reply_markup", `String v));
  ] in
  match Api.call_json client ~method_name:"sendAnimation" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match Message.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* sendVoice [sendvoice] -> Message *)
let send_voice (client:Client.t) ~chat_id ~voice ?business_connection_id ?message_thread_id ?direct_messages_topic_id ?caption ?parse_mode ?caption_entities ?duration ?disable_notification ?protect_content ?allow_paid_broadcast ?message_effect_id ?suggested_post_parameters ?reply_parameters ?reply_markup () =
  let params = List.filter_map (fun x -> x) [
    (match business_connection_id with None -> None | Some v -> Some ("business_connection_id", `String v));
    Some ("chat_id", `String (Id.to_string chat_id));
    (match message_thread_id with None -> None | Some v -> Some ("message_thread_id", `Intlit (Int64.to_string v)));
    (match direct_messages_topic_id with None -> None | Some v -> Some ("direct_messages_topic_id", `Intlit (Int64.to_string v)));
    Some ("voice", `String voice);
    (match caption with None -> None | Some v -> Some ("caption", `String v));
    (match parse_mode with None -> None | Some v -> Some ("parse_mode", `String v));
    (match caption_entities with None -> None | Some v -> Some ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) v)));
    (match duration with None -> None | Some v -> Some ("duration", `Intlit (Int64.to_string v)));
    (match disable_notification with None -> None | Some v -> Some ("disable_notification", `Bool v));
    (match protect_content with None -> None | Some v -> Some ("protect_content", `Bool v));
    (match allow_paid_broadcast with None -> None | Some v -> Some ("allow_paid_broadcast", `Bool v));
    (match message_effect_id with None -> None | Some v -> Some ("message_effect_id", `String v));
    (match suggested_post_parameters with None -> None | Some v -> Some ("suggested_post_parameters", SuggestedPostParameters.to_yojson v));
    (match reply_parameters with None -> None | Some v -> Some ("reply_parameters", ReplyParameters.to_yojson v));
    (match reply_markup with None -> None | Some v -> Some ("reply_markup", `String v));
  ] in
  match Api.call_json client ~method_name:"sendVoice" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match Message.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* sendVideoNote [sendvideonote] -> Message *)
let send_video_note (client:Client.t) ~chat_id ~video_note ?business_connection_id ?message_thread_id ?direct_messages_topic_id ?duration ?length ?thumbnail ?disable_notification ?protect_content ?allow_paid_broadcast ?message_effect_id ?suggested_post_parameters ?reply_parameters ?reply_markup () =
  let params = List.filter_map (fun x -> x) [
    (match business_connection_id with None -> None | Some v -> Some ("business_connection_id", `String v));
    Some ("chat_id", `String (Id.to_string chat_id));
    (match message_thread_id with None -> None | Some v -> Some ("message_thread_id", `Intlit (Int64.to_string v)));
    (match direct_messages_topic_id with None -> None | Some v -> Some ("direct_messages_topic_id", `Intlit (Int64.to_string v)));
    Some ("video_note", `String video_note);
    (match duration with None -> None | Some v -> Some ("duration", `Intlit (Int64.to_string v)));
    (match length with None -> None | Some v -> Some ("length", `Intlit (Int64.to_string v)));
    (match thumbnail with None -> None | Some v -> Some ("thumbnail", `String v));
    (match disable_notification with None -> None | Some v -> Some ("disable_notification", `Bool v));
    (match protect_content with None -> None | Some v -> Some ("protect_content", `Bool v));
    (match allow_paid_broadcast with None -> None | Some v -> Some ("allow_paid_broadcast", `Bool v));
    (match message_effect_id with None -> None | Some v -> Some ("message_effect_id", `String v));
    (match suggested_post_parameters with None -> None | Some v -> Some ("suggested_post_parameters", SuggestedPostParameters.to_yojson v));
    (match reply_parameters with None -> None | Some v -> Some ("reply_parameters", ReplyParameters.to_yojson v));
    (match reply_markup with None -> None | Some v -> Some ("reply_markup", `String v));
  ] in
  match Api.call_json client ~method_name:"sendVideoNote" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match Message.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* sendPaidMedia [sendpaidmedia] -> Message *)
let send_paid_media (client:Client.t) ~chat_id ~star_count ~media ?business_connection_id ?message_thread_id ?direct_messages_topic_id ?payload ?caption ?parse_mode ?caption_entities ?show_caption_above_media ?disable_notification ?protect_content ?allow_paid_broadcast ?suggested_post_parameters ?reply_parameters ?reply_markup () =
  let params = List.filter_map (fun x -> x) [
    (match business_connection_id with None -> None | Some v -> Some ("business_connection_id", `String v));
    Some ("chat_id", `String (Id.to_string chat_id));
    (match message_thread_id with None -> None | Some v -> Some ("message_thread_id", `Intlit (Int64.to_string v)));
    (match direct_messages_topic_id with None -> None | Some v -> Some ("direct_messages_topic_id", `Intlit (Int64.to_string v)));
    Some ("star_count", `Intlit (Int64.to_string star_count));
    Some ("media", `List (List.map (fun x -> InputPaidMedia.to_yojson x) media));
    (match payload with None -> None | Some v -> Some ("payload", `String v));
    (match caption with None -> None | Some v -> Some ("caption", `String v));
    (match parse_mode with None -> None | Some v -> Some ("parse_mode", `String v));
    (match caption_entities with None -> None | Some v -> Some ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) v)));
    (match show_caption_above_media with None -> None | Some v -> Some ("show_caption_above_media", `Bool v));
    (match disable_notification with None -> None | Some v -> Some ("disable_notification", `Bool v));
    (match protect_content with None -> None | Some v -> Some ("protect_content", `Bool v));
    (match allow_paid_broadcast with None -> None | Some v -> Some ("allow_paid_broadcast", `Bool v));
    (match suggested_post_parameters with None -> None | Some v -> Some ("suggested_post_parameters", SuggestedPostParameters.to_yojson v));
    (match reply_parameters with None -> None | Some v -> Some ("reply_parameters", ReplyParameters.to_yojson v));
    (match reply_markup with None -> None | Some v -> Some ("reply_markup", `String v));
  ] in
  match Api.call_json client ~method_name:"sendPaidMedia" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match Message.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* sendMediaGroup [sendmediagroup] -> Message *)
let send_media_group (client:Client.t) ~chat_id ~media ?business_connection_id ?message_thread_id ?direct_messages_topic_id ?disable_notification ?protect_content ?allow_paid_broadcast ?message_effect_id ?reply_parameters () =
  let params = List.filter_map (fun x -> x) [
    (match business_connection_id with None -> None | Some v -> Some ("business_connection_id", `String v));
    Some ("chat_id", `String (Id.to_string chat_id));
    (match message_thread_id with None -> None | Some v -> Some ("message_thread_id", `Intlit (Int64.to_string v)));
    (match direct_messages_topic_id with None -> None | Some v -> Some ("direct_messages_topic_id", `Intlit (Int64.to_string v)));
    Some ("media", `List (List.map (fun x -> InputMediaVideo.to_yojson x) media));
    (match disable_notification with None -> None | Some v -> Some ("disable_notification", `Bool v));
    (match protect_content with None -> None | Some v -> Some ("protect_content", `Bool v));
    (match allow_paid_broadcast with None -> None | Some v -> Some ("allow_paid_broadcast", `Bool v));
    (match message_effect_id with None -> None | Some v -> Some ("message_effect_id", `String v));
    (match reply_parameters with None -> None | Some v -> Some ("reply_parameters", ReplyParameters.to_yojson v));
  ] in
  match Api.call_json client ~method_name:"sendMediaGroup" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match Message.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* sendLocation [sendlocation] -> Message *)
let send_location (client:Client.t) ~chat_id ~latitude ~longitude ?business_connection_id ?message_thread_id ?direct_messages_topic_id ?horizontal_accuracy ?live_period ?heading ?proximity_alert_radius ?disable_notification ?protect_content ?allow_paid_broadcast ?message_effect_id ?suggested_post_parameters ?reply_parameters ?reply_markup () =
  let params = List.filter_map (fun x -> x) [
    (match business_connection_id with None -> None | Some v -> Some ("business_connection_id", `String v));
    Some ("chat_id", `String (Id.to_string chat_id));
    (match message_thread_id with None -> None | Some v -> Some ("message_thread_id", `Intlit (Int64.to_string v)));
    (match direct_messages_topic_id with None -> None | Some v -> Some ("direct_messages_topic_id", `Intlit (Int64.to_string v)));
    Some ("latitude", latitude);
    Some ("longitude", longitude);
    (match horizontal_accuracy with None -> None | Some v -> Some ("horizontal_accuracy", v));
    (match live_period with None -> None | Some v -> Some ("live_period", `Intlit (Int64.to_string v)));
    (match heading with None -> None | Some v -> Some ("heading", `Intlit (Int64.to_string v)));
    (match proximity_alert_radius with None -> None | Some v -> Some ("proximity_alert_radius", `Intlit (Int64.to_string v)));
    (match disable_notification with None -> None | Some v -> Some ("disable_notification", `Bool v));
    (match protect_content with None -> None | Some v -> Some ("protect_content", `Bool v));
    (match allow_paid_broadcast with None -> None | Some v -> Some ("allow_paid_broadcast", `Bool v));
    (match message_effect_id with None -> None | Some v -> Some ("message_effect_id", `String v));
    (match suggested_post_parameters with None -> None | Some v -> Some ("suggested_post_parameters", SuggestedPostParameters.to_yojson v));
    (match reply_parameters with None -> None | Some v -> Some ("reply_parameters", ReplyParameters.to_yojson v));
    (match reply_markup with None -> None | Some v -> Some ("reply_markup", `String v));
  ] in
  match Api.call_json client ~method_name:"sendLocation" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match Message.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* sendVenue [sendvenue] -> Message *)
let send_venue (client:Client.t) ~chat_id ~latitude ~longitude ~title ~address ?business_connection_id ?message_thread_id ?direct_messages_topic_id ?foursquare_id ?foursquare_type ?google_place_id ?google_place_type ?disable_notification ?protect_content ?allow_paid_broadcast ?message_effect_id ?suggested_post_parameters ?reply_parameters ?reply_markup () =
  let params = List.filter_map (fun x -> x) [
    (match business_connection_id with None -> None | Some v -> Some ("business_connection_id", `String v));
    Some ("chat_id", `String (Id.to_string chat_id));
    (match message_thread_id with None -> None | Some v -> Some ("message_thread_id", `Intlit (Int64.to_string v)));
    (match direct_messages_topic_id with None -> None | Some v -> Some ("direct_messages_topic_id", `Intlit (Int64.to_string v)));
    Some ("latitude", latitude);
    Some ("longitude", longitude);
    Some ("title", `String title);
    Some ("address", `String address);
    (match foursquare_id with None -> None | Some v -> Some ("foursquare_id", `String v));
    (match foursquare_type with None -> None | Some v -> Some ("foursquare_type", `String v));
    (match google_place_id with None -> None | Some v -> Some ("google_place_id", `String v));
    (match google_place_type with None -> None | Some v -> Some ("google_place_type", `String v));
    (match disable_notification with None -> None | Some v -> Some ("disable_notification", `Bool v));
    (match protect_content with None -> None | Some v -> Some ("protect_content", `Bool v));
    (match allow_paid_broadcast with None -> None | Some v -> Some ("allow_paid_broadcast", `Bool v));
    (match message_effect_id with None -> None | Some v -> Some ("message_effect_id", `String v));
    (match suggested_post_parameters with None -> None | Some v -> Some ("suggested_post_parameters", SuggestedPostParameters.to_yojson v));
    (match reply_parameters with None -> None | Some v -> Some ("reply_parameters", ReplyParameters.to_yojson v));
    (match reply_markup with None -> None | Some v -> Some ("reply_markup", `String v));
  ] in
  match Api.call_json client ~method_name:"sendVenue" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match Message.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* sendContact [sendcontact] -> Message *)
let send_contact (client:Client.t) ~chat_id ~phone_number ~first_name ?business_connection_id ?message_thread_id ?direct_messages_topic_id ?last_name ?vcard ?disable_notification ?protect_content ?allow_paid_broadcast ?message_effect_id ?suggested_post_parameters ?reply_parameters ?reply_markup () =
  let params = List.filter_map (fun x -> x) [
    (match business_connection_id with None -> None | Some v -> Some ("business_connection_id", `String v));
    Some ("chat_id", `String (Id.to_string chat_id));
    (match message_thread_id with None -> None | Some v -> Some ("message_thread_id", `Intlit (Int64.to_string v)));
    (match direct_messages_topic_id with None -> None | Some v -> Some ("direct_messages_topic_id", `Intlit (Int64.to_string v)));
    Some ("phone_number", `String phone_number);
    Some ("first_name", `String first_name);
    (match last_name with None -> None | Some v -> Some ("last_name", `String v));
    (match vcard with None -> None | Some v -> Some ("vcard", `String v));
    (match disable_notification with None -> None | Some v -> Some ("disable_notification", `Bool v));
    (match protect_content with None -> None | Some v -> Some ("protect_content", `Bool v));
    (match allow_paid_broadcast with None -> None | Some v -> Some ("allow_paid_broadcast", `Bool v));
    (match message_effect_id with None -> None | Some v -> Some ("message_effect_id", `String v));
    (match suggested_post_parameters with None -> None | Some v -> Some ("suggested_post_parameters", SuggestedPostParameters.to_yojson v));
    (match reply_parameters with None -> None | Some v -> Some ("reply_parameters", ReplyParameters.to_yojson v));
    (match reply_markup with None -> None | Some v -> Some ("reply_markup", `String v));
  ] in
  match Api.call_json client ~method_name:"sendContact" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match Message.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* sendPoll [sendpoll] -> Message *)
let send_poll (client:Client.t) ~chat_id ~question ~options ?business_connection_id ?message_thread_id ?question_parse_mode ?question_entities ?is_anonymous ?type_ ?allows_multiple_answers ?correct_option_id ?explanation ?explanation_parse_mode ?explanation_entities ?open_period ?close_date ?is_closed ?disable_notification ?protect_content ?allow_paid_broadcast ?message_effect_id ?reply_parameters ?reply_markup () =
  let params = List.filter_map (fun x -> x) [
    (match business_connection_id with None -> None | Some v -> Some ("business_connection_id", `String v));
    Some ("chat_id", `String (Id.to_string chat_id));
    (match message_thread_id with None -> None | Some v -> Some ("message_thread_id", `Intlit (Int64.to_string v)));
    Some ("question", `String question);
    (match question_parse_mode with None -> None | Some v -> Some ("question_parse_mode", `String v));
    (match question_entities with None -> None | Some v -> Some ("question_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) v)));
    Some ("options", `List (List.map (fun x -> InputPollOption.to_yojson x) options));
    (match is_anonymous with None -> None | Some v -> Some ("is_anonymous", `Bool v));
    (match type_ with None -> None | Some v -> Some ("type_", `String v));
    (match allows_multiple_answers with None -> None | Some v -> Some ("allows_multiple_answers", `Bool v));
    (match correct_option_id with None -> None | Some v -> Some ("correct_option_id", `Intlit (Int64.to_string v)));
    (match explanation with None -> None | Some v -> Some ("explanation", `String v));
    (match explanation_parse_mode with None -> None | Some v -> Some ("explanation_parse_mode", `String v));
    (match explanation_entities with None -> None | Some v -> Some ("explanation_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) v)));
    (match open_period with None -> None | Some v -> Some ("open_period", `Intlit (Int64.to_string v)));
    (match close_date with None -> None | Some v -> Some ("close_date", `Intlit (Int64.to_string v)));
    (match is_closed with None -> None | Some v -> Some ("is_closed", `Bool v));
    (match disable_notification with None -> None | Some v -> Some ("disable_notification", `Bool v));
    (match protect_content with None -> None | Some v -> Some ("protect_content", `Bool v));
    (match allow_paid_broadcast with None -> None | Some v -> Some ("allow_paid_broadcast", `Bool v));
    (match message_effect_id with None -> None | Some v -> Some ("message_effect_id", `String v));
    (match reply_parameters with None -> None | Some v -> Some ("reply_parameters", ReplyParameters.to_yojson v));
    (match reply_markup with None -> None | Some v -> Some ("reply_markup", `String v));
  ] in
  match Api.call_json client ~method_name:"sendPoll" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match Message.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* sendChecklist [sendchecklist] -> Message *)
let send_checklist (client:Client.t) ~business_connection_id ~chat_id ~checklist ?disable_notification ?protect_content ?message_effect_id ?reply_parameters ?reply_markup () =
  let params = List.filter_map (fun x -> x) [
    Some ("business_connection_id", `String business_connection_id);
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("checklist", InputChecklist.to_yojson checklist);
    (match disable_notification with None -> None | Some v -> Some ("disable_notification", `Bool v));
    (match protect_content with None -> None | Some v -> Some ("protect_content", `Bool v));
    (match message_effect_id with None -> None | Some v -> Some ("message_effect_id", `String v));
    (match reply_parameters with None -> None | Some v -> Some ("reply_parameters", ReplyParameters.to_yojson v));
    (match reply_markup with None -> None | Some v -> Some ("reply_markup", InlineKeyboardMarkup.to_yojson v));
  ] in
  match Api.call_json client ~method_name:"sendChecklist" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match Message.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* sendDice [senddice] -> Message *)
let send_dice (client:Client.t) ~chat_id ?business_connection_id ?message_thread_id ?direct_messages_topic_id ?emoji ?disable_notification ?protect_content ?allow_paid_broadcast ?message_effect_id ?suggested_post_parameters ?reply_parameters ?reply_markup () =
  let params = List.filter_map (fun x -> x) [
    (match business_connection_id with None -> None | Some v -> Some ("business_connection_id", `String v));
    Some ("chat_id", `String (Id.to_string chat_id));
    (match message_thread_id with None -> None | Some v -> Some ("message_thread_id", `Intlit (Int64.to_string v)));
    (match direct_messages_topic_id with None -> None | Some v -> Some ("direct_messages_topic_id", `Intlit (Int64.to_string v)));
    (match emoji with None -> None | Some v -> Some ("emoji", `String v));
    (match disable_notification with None -> None | Some v -> Some ("disable_notification", `Bool v));
    (match protect_content with None -> None | Some v -> Some ("protect_content", `Bool v));
    (match allow_paid_broadcast with None -> None | Some v -> Some ("allow_paid_broadcast", `Bool v));
    (match message_effect_id with None -> None | Some v -> Some ("message_effect_id", `String v));
    (match suggested_post_parameters with None -> None | Some v -> Some ("suggested_post_parameters", SuggestedPostParameters.to_yojson v));
    (match reply_parameters with None -> None | Some v -> Some ("reply_parameters", ReplyParameters.to_yojson v));
    (match reply_markup with None -> None | Some v -> Some ("reply_markup", `String v));
  ] in
  match Api.call_json client ~method_name:"sendDice" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match Message.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* sendChatAction [sendchataction] -> Boolean *)
let send_chat_action (client:Client.t) ~chat_id ~action ?business_connection_id ?message_thread_id () =
  let params = List.filter_map (fun x -> x) [
    (match business_connection_id with None -> None | Some v -> Some ("business_connection_id", `String v));
    Some ("chat_id", `String (Id.to_string chat_id));
    (match message_thread_id with None -> None | Some v -> Some ("message_thread_id", `Intlit (Int64.to_string v)));
    Some ("action", `String action);
  ] in
  match Api.call_json client ~method_name:"sendChatAction" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* setMessageReaction [setmessagereaction] -> Boolean *)
let set_message_reaction (client:Client.t) ~chat_id ~message_id ?reaction ?is_big () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("message_id", `Intlit (Int64.to_string message_id));
    (match reaction with None -> None | Some v -> Some ("reaction", `List (List.map (fun x -> ReactionType.to_yojson x) v)));
    (match is_big with None -> None | Some v -> Some ("is_big", `Bool v));
  ] in
  match Api.call_json client ~method_name:"setMessageReaction" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* getUserProfilePhotos [getuserprofilephotos] -> UserProfilePhotos *)
let get_user_profile_photos (client:Client.t) ~user_id ?offset ?limit () =
  let params = List.filter_map (fun x -> x) [
    Some ("user_id", `Intlit (Int64.to_string user_id));
    (match offset with None -> None | Some v -> Some ("offset", `Intlit (Int64.to_string v)));
    (match limit with None -> None | Some v -> Some ("limit", `Intlit (Int64.to_string v)));
  ] in
  match Api.call_json client ~method_name:"getUserProfilePhotos" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match UserProfilePhotos.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* setUserEmojiStatus [setuseremojistatus] -> Boolean *)
let set_user_emoji_status (client:Client.t) ~user_id ?emoji_status_custom_emoji_id ?emoji_status_expiration_date () =
  let params = List.filter_map (fun x -> x) [
    Some ("user_id", `Intlit (Int64.to_string user_id));
    (match emoji_status_custom_emoji_id with None -> None | Some v -> Some ("emoji_status_custom_emoji_id", `String v));
    (match emoji_status_expiration_date with None -> None | Some v -> Some ("emoji_status_expiration_date", `Intlit (Int64.to_string v)));
  ] in
  match Api.call_json client ~method_name:"setUserEmojiStatus" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* getFile [getfile] -> getFile *)
let get_file (client:Client.t) ~file_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("file_id", `String file_id);
  ] in
  match Api.call_json client ~method_name:"getFile" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match GetFile.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* banChatMember [banchatmember] -> Boolean *)
let ban_chat_member (client:Client.t) ~chat_id ~user_id ?until_date ?revoke_messages () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("user_id", `Intlit (Int64.to_string user_id));
    (match until_date with None -> None | Some v -> Some ("until_date", `Intlit (Int64.to_string v)));
    (match revoke_messages with None -> None | Some v -> Some ("revoke_messages", `Bool v));
  ] in
  match Api.call_json client ~method_name:"banChatMember" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* unbanChatMember [unbanchatmember] -> Boolean *)
let unban_chat_member (client:Client.t) ~chat_id ~user_id ?only_if_banned () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("user_id", `Intlit (Int64.to_string user_id));
    (match only_if_banned with None -> None | Some v -> Some ("only_if_banned", `Bool v));
  ] in
  match Api.call_json client ~method_name:"unbanChatMember" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* restrictChatMember [restrictchatmember] -> Boolean *)
let restrict_chat_member (client:Client.t) ~chat_id ~user_id ~permissions ?use_independent_chat_permissions ?until_date () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("user_id", `Intlit (Int64.to_string user_id));
    Some ("permissions", ChatPermissions.to_yojson permissions);
    (match use_independent_chat_permissions with None -> None | Some v -> Some ("use_independent_chat_permissions", `Bool v));
    (match until_date with None -> None | Some v -> Some ("until_date", `Intlit (Int64.to_string v)));
  ] in
  match Api.call_json client ~method_name:"restrictChatMember" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* promoteChatMember [promotechatmember] -> Boolean *)
let promote_chat_member (client:Client.t) ~chat_id ~user_id ?is_anonymous ?can_manage_chat ?can_delete_messages ?can_manage_video_chats ?can_restrict_members ?can_promote_members ?can_change_info ?can_invite_users ?can_post_stories ?can_edit_stories ?can_delete_stories ?can_post_messages ?can_edit_messages ?can_pin_messages ?can_manage_topics ?can_manage_direct_messages () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("user_id", `Intlit (Int64.to_string user_id));
    (match is_anonymous with None -> None | Some v -> Some ("is_anonymous", `Bool v));
    (match can_manage_chat with None -> None | Some v -> Some ("can_manage_chat", `Bool v));
    (match can_delete_messages with None -> None | Some v -> Some ("can_delete_messages", `Bool v));
    (match can_manage_video_chats with None -> None | Some v -> Some ("can_manage_video_chats", `Bool v));
    (match can_restrict_members with None -> None | Some v -> Some ("can_restrict_members", `Bool v));
    (match can_promote_members with None -> None | Some v -> Some ("can_promote_members", `Bool v));
    (match can_change_info with None -> None | Some v -> Some ("can_change_info", `Bool v));
    (match can_invite_users with None -> None | Some v -> Some ("can_invite_users", `Bool v));
    (match can_post_stories with None -> None | Some v -> Some ("can_post_stories", `Bool v));
    (match can_edit_stories with None -> None | Some v -> Some ("can_edit_stories", `Bool v));
    (match can_delete_stories with None -> None | Some v -> Some ("can_delete_stories", `Bool v));
    (match can_post_messages with None -> None | Some v -> Some ("can_post_messages", `Bool v));
    (match can_edit_messages with None -> None | Some v -> Some ("can_edit_messages", `Bool v));
    (match can_pin_messages with None -> None | Some v -> Some ("can_pin_messages", `Bool v));
    (match can_manage_topics with None -> None | Some v -> Some ("can_manage_topics", `Bool v));
    (match can_manage_direct_messages with None -> None | Some v -> Some ("can_manage_direct_messages", `Bool v));
  ] in
  match Api.call_json client ~method_name:"promoteChatMember" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* setChatAdministratorCustomTitle [setchatadministratorcustomtitle] -> Boolean *)
let set_chat_administrator_custom_title (client:Client.t) ~chat_id ~user_id ~custom_title () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("user_id", `Intlit (Int64.to_string user_id));
    Some ("custom_title", `String custom_title);
  ] in
  match Api.call_json client ~method_name:"setChatAdministratorCustomTitle" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* banChatSenderChat [banchatsenderchat] -> Boolean *)
let ban_chat_sender_chat (client:Client.t) ~chat_id ~sender_chat_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("sender_chat_id", `Intlit (Int64.to_string sender_chat_id));
  ] in
  match Api.call_json client ~method_name:"banChatSenderChat" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* unbanChatSenderChat [unbanchatsenderchat] -> Boolean *)
let unban_chat_sender_chat (client:Client.t) ~chat_id ~sender_chat_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("sender_chat_id", `Intlit (Int64.to_string sender_chat_id));
  ] in
  match Api.call_json client ~method_name:"unbanChatSenderChat" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* setChatPermissions [setchatpermissions] -> Boolean *)
let set_chat_permissions (client:Client.t) ~chat_id ~permissions ?use_independent_chat_permissions () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("permissions", ChatPermissions.to_yojson permissions);
    (match use_independent_chat_permissions with None -> None | Some v -> Some ("use_independent_chat_permissions", `Bool v));
  ] in
  match Api.call_json client ~method_name:"setChatPermissions" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* exportChatInviteLink [exportchatinvitelink] -> ? *)
let export_chat_invite_link (client:Client.t) ~chat_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
  ] in
  match Api.call_json client ~method_name:"exportChatInviteLink" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* createChatInviteLink [createchatinvitelink] -> ChatInviteLink *)
let create_chat_invite_link (client:Client.t) ~chat_id ?name ?expire_date ?member_limit ?creates_join_request () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    (match name with None -> None | Some v -> Some ("name", `String v));
    (match expire_date with None -> None | Some v -> Some ("expire_date", `Intlit (Int64.to_string v)));
    (match member_limit with None -> None | Some v -> Some ("member_limit", `Intlit (Int64.to_string v)));
    (match creates_join_request with None -> None | Some v -> Some ("creates_join_request", `Bool v));
  ] in
  match Api.call_json client ~method_name:"createChatInviteLink" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match ChatInviteLink.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* editChatInviteLink [editchatinvitelink] -> ChatInviteLink *)
let edit_chat_invite_link (client:Client.t) ~chat_id ~invite_link ?name ?expire_date ?member_limit ?creates_join_request () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("invite_link", `String invite_link);
    (match name with None -> None | Some v -> Some ("name", `String v));
    (match expire_date with None -> None | Some v -> Some ("expire_date", `Intlit (Int64.to_string v)));
    (match member_limit with None -> None | Some v -> Some ("member_limit", `Intlit (Int64.to_string v)));
    (match creates_join_request with None -> None | Some v -> Some ("creates_join_request", `Bool v));
  ] in
  match Api.call_json client ~method_name:"editChatInviteLink" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match ChatInviteLink.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* createChatSubscriptionInviteLink [createchatsubscriptioninvitelink] -> ChatInviteLink *)
let create_chat_subscription_invite_link (client:Client.t) ~chat_id ~subscription_period ~subscription_price ?name () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    (match name with None -> None | Some v -> Some ("name", `String v));
    Some ("subscription_period", `Intlit (Int64.to_string subscription_period));
    Some ("subscription_price", `Intlit (Int64.to_string subscription_price));
  ] in
  match Api.call_json client ~method_name:"createChatSubscriptionInviteLink" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match ChatInviteLink.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* editChatSubscriptionInviteLink [editchatsubscriptioninvitelink] -> ChatInviteLink *)
let edit_chat_subscription_invite_link (client:Client.t) ~chat_id ~invite_link ?name () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("invite_link", `String invite_link);
    (match name with None -> None | Some v -> Some ("name", `String v));
  ] in
  match Api.call_json client ~method_name:"editChatSubscriptionInviteLink" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match ChatInviteLink.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* revokeChatInviteLink [revokechatinvitelink] -> ChatInviteLink *)
let revoke_chat_invite_link (client:Client.t) ~chat_id ~invite_link () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("invite_link", `String invite_link);
  ] in
  match Api.call_json client ~method_name:"revokeChatInviteLink" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match ChatInviteLink.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* approveChatJoinRequest [approvechatjoinrequest] -> Boolean *)
let approve_chat_join_request (client:Client.t) ~chat_id ~user_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("user_id", `Intlit (Int64.to_string user_id));
  ] in
  match Api.call_json client ~method_name:"approveChatJoinRequest" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* declineChatJoinRequest [declinechatjoinrequest] -> Boolean *)
let decline_chat_join_request (client:Client.t) ~chat_id ~user_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("user_id", `Intlit (Int64.to_string user_id));
  ] in
  match Api.call_json client ~method_name:"declineChatJoinRequest" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* setChatPhoto [setchatphoto] -> Boolean *)
let set_chat_photo (client:Client.t) ~chat_id ~photo () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("photo", InputFile.to_yojson photo);
  ] in
  match Api.call_json client ~method_name:"setChatPhoto" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* deleteChatPhoto [deletechatphoto] -> Boolean *)
let delete_chat_photo (client:Client.t) ~chat_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
  ] in
  match Api.call_json client ~method_name:"deleteChatPhoto" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* setChatTitle [setchattitle] -> Boolean *)
let set_chat_title (client:Client.t) ~chat_id ~title () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("title", `String title);
  ] in
  match Api.call_json client ~method_name:"setChatTitle" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* setChatDescription [setchatdescription] -> Boolean *)
let set_chat_description (client:Client.t) ~chat_id ?description () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    (match description with None -> None | Some v -> Some ("description", `String v));
  ] in
  match Api.call_json client ~method_name:"setChatDescription" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* pinChatMessage [pinchatmessage] -> Boolean *)
let pin_chat_message (client:Client.t) ~chat_id ~message_id ?business_connection_id ?disable_notification () =
  let params = List.filter_map (fun x -> x) [
    (match business_connection_id with None -> None | Some v -> Some ("business_connection_id", `String v));
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("message_id", `Intlit (Int64.to_string message_id));
    (match disable_notification with None -> None | Some v -> Some ("disable_notification", `Bool v));
  ] in
  match Api.call_json client ~method_name:"pinChatMessage" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* unpinChatMessage [unpinchatmessage] -> Boolean *)
let unpin_chat_message (client:Client.t) ~chat_id ?business_connection_id ?message_id () =
  let params = List.filter_map (fun x -> x) [
    (match business_connection_id with None -> None | Some v -> Some ("business_connection_id", `String v));
    Some ("chat_id", `String (Id.to_string chat_id));
    (match message_id with None -> None | Some v -> Some ("message_id", `Intlit (Int64.to_string v)));
  ] in
  match Api.call_json client ~method_name:"unpinChatMessage" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* unpinAllChatMessages [unpinallchatmessages] -> Boolean *)
let unpin_all_chat_messages (client:Client.t) ~chat_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
  ] in
  match Api.call_json client ~method_name:"unpinAllChatMessages" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* leaveChat [leavechat] -> Boolean *)
let leave_chat (client:Client.t) ~chat_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
  ] in
  match Api.call_json client ~method_name:"leaveChat" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* getChat [getchat] -> ChatFullInfo *)
let get_chat (client:Client.t) ~chat_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
  ] in
  match Api.call_json client ~method_name:"getChat" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match ChatFullInfo.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* getChatAdministrators [getchatadministrators] -> ChatMember *)
let get_chat_administrators (client:Client.t) ~chat_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
  ] in
  match Api.call_json client ~method_name:"getChatAdministrators" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match ChatMember.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* getChatMemberCount [getchatmembercount] -> ? *)
let get_chat_member_count (client:Client.t) ~chat_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
  ] in
  match Api.call_json client ~method_name:"getChatMemberCount" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* getChatMember [getchatmember] -> ChatMember *)
let get_chat_member (client:Client.t) ~chat_id ~user_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("user_id", `Intlit (Int64.to_string user_id));
  ] in
  match Api.call_json client ~method_name:"getChatMember" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match ChatMember.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* setChatStickerSet [setchatstickerset] -> Boolean *)
let set_chat_sticker_set (client:Client.t) ~chat_id ~sticker_set_name () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("sticker_set_name", `String sticker_set_name);
  ] in
  match Api.call_json client ~method_name:"setChatStickerSet" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* deleteChatStickerSet [deletechatstickerset] -> Boolean *)
let delete_chat_sticker_set (client:Client.t) ~chat_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
  ] in
  match Api.call_json client ~method_name:"deleteChatStickerSet" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* getForumTopicIconStickers [getforumtopiciconstickers] -> Sticker *)
let get_forum_topic_icon_stickers (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"getForumTopicIconStickers" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match Sticker.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* createForumTopic [createforumtopic] -> ForumTopic *)
let create_forum_topic (client:Client.t) ~chat_id ~name ?icon_color ?icon_custom_emoji_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("name", `String name);
    (match icon_color with None -> None | Some v -> Some ("icon_color", `Intlit (Int64.to_string v)));
    (match icon_custom_emoji_id with None -> None | Some v -> Some ("icon_custom_emoji_id", `String v));
  ] in
  match Api.call_json client ~method_name:"createForumTopic" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match ForumTopic.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* editForumTopic [editforumtopic] -> Boolean *)
let edit_forum_topic (client:Client.t) ~chat_id ~message_thread_id ?name ?icon_custom_emoji_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("message_thread_id", `Intlit (Int64.to_string message_thread_id));
    (match name with None -> None | Some v -> Some ("name", `String v));
    (match icon_custom_emoji_id with None -> None | Some v -> Some ("icon_custom_emoji_id", `String v));
  ] in
  match Api.call_json client ~method_name:"editForumTopic" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* closeForumTopic [closeforumtopic] -> Boolean *)
let close_forum_topic (client:Client.t) ~chat_id ~message_thread_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("message_thread_id", `Intlit (Int64.to_string message_thread_id));
  ] in
  match Api.call_json client ~method_name:"closeForumTopic" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* reopenForumTopic [reopenforumtopic] -> Boolean *)
let reopen_forum_topic (client:Client.t) ~chat_id ~message_thread_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("message_thread_id", `Intlit (Int64.to_string message_thread_id));
  ] in
  match Api.call_json client ~method_name:"reopenForumTopic" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* deleteForumTopic [deleteforumtopic] -> Boolean *)
let delete_forum_topic (client:Client.t) ~chat_id ~message_thread_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("message_thread_id", `Intlit (Int64.to_string message_thread_id));
  ] in
  match Api.call_json client ~method_name:"deleteForumTopic" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* unpinAllForumTopicMessages [unpinallforumtopicmessages] -> Boolean *)
let unpin_all_forum_topic_messages (client:Client.t) ~chat_id ~message_thread_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("message_thread_id", `Intlit (Int64.to_string message_thread_id));
  ] in
  match Api.call_json client ~method_name:"unpinAllForumTopicMessages" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* editGeneralForumTopic [editgeneralforumtopic] -> Boolean *)
let edit_general_forum_topic (client:Client.t) ~chat_id ~name () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("name", `String name);
  ] in
  match Api.call_json client ~method_name:"editGeneralForumTopic" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* closeGeneralForumTopic [closegeneralforumtopic] -> Boolean *)
let close_general_forum_topic (client:Client.t) ~chat_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
  ] in
  match Api.call_json client ~method_name:"closeGeneralForumTopic" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* reopenGeneralForumTopic [reopengeneralforumtopic] -> Boolean *)
let reopen_general_forum_topic (client:Client.t) ~chat_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
  ] in
  match Api.call_json client ~method_name:"reopenGeneralForumTopic" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* hideGeneralForumTopic [hidegeneralforumtopic] -> Boolean *)
let hide_general_forum_topic (client:Client.t) ~chat_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
  ] in
  match Api.call_json client ~method_name:"hideGeneralForumTopic" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* unhideGeneralForumTopic [unhidegeneralforumtopic] -> Boolean *)
let unhide_general_forum_topic (client:Client.t) ~chat_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
  ] in
  match Api.call_json client ~method_name:"unhideGeneralForumTopic" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* unpinAllGeneralForumTopicMessages [unpinallgeneralforumtopicmessages] -> Boolean *)
let unpin_all_general_forum_topic_messages (client:Client.t) ~chat_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
  ] in
  match Api.call_json client ~method_name:"unpinAllGeneralForumTopicMessages" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* answerCallbackQuery [answercallbackquery] -> Boolean *)
let answer_callback_query (client:Client.t) ~callback_query_id ?text ?show_alert ?url ?cache_time () =
  let params = List.filter_map (fun x -> x) [
    Some ("callback_query_id", `String callback_query_id);
    (match text with None -> None | Some v -> Some ("text", `String v));
    (match show_alert with None -> None | Some v -> Some ("show_alert", `Bool v));
    (match url with None -> None | Some v -> Some ("url", `String v));
    (match cache_time with None -> None | Some v -> Some ("cache_time", `Intlit (Int64.to_string v)));
  ] in
  match Api.call_json client ~method_name:"answerCallbackQuery" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* getUserChatBoosts [getuserchatboosts] -> UserChatBoosts *)
let get_user_chat_boosts (client:Client.t) ~chat_id ~user_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("user_id", `Intlit (Int64.to_string user_id));
  ] in
  match Api.call_json client ~method_name:"getUserChatBoosts" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match UserChatBoosts.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* getBusinessConnection [getbusinessconnection] -> BusinessConnection *)
let get_business_connection (client:Client.t) ~business_connection_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("business_connection_id", `String business_connection_id);
  ] in
  match Api.call_json client ~method_name:"getBusinessConnection" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match BusinessConnection.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* setMyCommands [setmycommands] -> Boolean *)
let set_my_commands (client:Client.t) ~commands ?scope ?language_code () =
  let params = List.filter_map (fun x -> x) [
    Some ("commands", `List (List.map (fun x -> BotCommand.to_yojson x) commands));
    (match scope with None -> None | Some v -> Some ("scope", BotCommandScope.to_yojson v));
    (match language_code with None -> None | Some v -> Some ("language_code", `String v));
  ] in
  match Api.call_json client ~method_name:"setMyCommands" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* deleteMyCommands [deletemycommands] -> Boolean *)
let delete_my_commands (client:Client.t) ?scope ?language_code () =
  let params = List.filter_map (fun x -> x) [
    (match scope with None -> None | Some v -> Some ("scope", BotCommandScope.to_yojson v));
    (match language_code with None -> None | Some v -> Some ("language_code", `String v));
  ] in
  match Api.call_json client ~method_name:"deleteMyCommands" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* getMyCommands [getmycommands] -> BotCommand *)
let get_my_commands (client:Client.t) ?scope ?language_code () =
  let params = List.filter_map (fun x -> x) [
    (match scope with None -> None | Some v -> Some ("scope", BotCommandScope.to_yojson v));
    (match language_code with None -> None | Some v -> Some ("language_code", `String v));
  ] in
  match Api.call_json client ~method_name:"getMyCommands" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match BotCommand.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* setMyName [setmyname] -> Boolean *)
let set_my_name (client:Client.t) ?name ?language_code () =
  let params = List.filter_map (fun x -> x) [
    (match name with None -> None | Some v -> Some ("name", `String v));
    (match language_code with None -> None | Some v -> Some ("language_code", `String v));
  ] in
  match Api.call_json client ~method_name:"setMyName" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* getMyName [getmyname] -> BotName *)
let get_my_name (client:Client.t) ?language_code () =
  let params = List.filter_map (fun x -> x) [
    (match language_code with None -> None | Some v -> Some ("language_code", `String v));
  ] in
  match Api.call_json client ~method_name:"getMyName" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match BotName.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* setMyDescription [setmydescription] -> Boolean *)
let set_my_description (client:Client.t) ?description ?language_code () =
  let params = List.filter_map (fun x -> x) [
    (match description with None -> None | Some v -> Some ("description", `String v));
    (match language_code with None -> None | Some v -> Some ("language_code", `String v));
  ] in
  match Api.call_json client ~method_name:"setMyDescription" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* getMyDescription [getmydescription] -> BotDescription *)
let get_my_description (client:Client.t) ?language_code () =
  let params = List.filter_map (fun x -> x) [
    (match language_code with None -> None | Some v -> Some ("language_code", `String v));
  ] in
  match Api.call_json client ~method_name:"getMyDescription" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match BotDescription.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* setMyShortDescription [setmyshortdescription] -> Boolean *)
let set_my_short_description (client:Client.t) ?short_description ?language_code () =
  let params = List.filter_map (fun x -> x) [
    (match short_description with None -> None | Some v -> Some ("short_description", `String v));
    (match language_code with None -> None | Some v -> Some ("language_code", `String v));
  ] in
  match Api.call_json client ~method_name:"setMyShortDescription" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* getMyShortDescription [getmyshortdescription] -> BotShortDescription *)
let get_my_short_description (client:Client.t) ?language_code () =
  let params = List.filter_map (fun x -> x) [
    (match language_code with None -> None | Some v -> Some ("language_code", `String v));
  ] in
  match Api.call_json client ~method_name:"getMyShortDescription" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match BotShortDescription.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* setChatMenuButton [setchatmenubutton] -> Boolean *)
let set_chat_menu_button (client:Client.t) ?chat_id ?menu_button () =
  let params = List.filter_map (fun x -> x) [
    (match chat_id with None -> None | Some v -> Some ("chat_id", `Intlit (Int64.to_string v)));
    (match menu_button with None -> None | Some v -> Some ("menu_button", MenuButton.to_yojson v));
  ] in
  match Api.call_json client ~method_name:"setChatMenuButton" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* getChatMenuButton [getchatmenubutton] -> MenuButton *)
let get_chat_menu_button (client:Client.t) ?chat_id () =
  let params = List.filter_map (fun x -> x) [
    (match chat_id with None -> None | Some v -> Some ("chat_id", `Intlit (Int64.to_string v)));
  ] in
  match Api.call_json client ~method_name:"getChatMenuButton" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match MenuButton.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* setMyDefaultAdministratorRights [setmydefaultadministratorrights] -> Boolean *)
let set_my_default_administrator_rights (client:Client.t) ?rights ?for_channels () =
  let params = List.filter_map (fun x -> x) [
    (match rights with None -> None | Some v -> Some ("rights", ChatAdministratorRights.to_yojson v));
    (match for_channels with None -> None | Some v -> Some ("for_channels", `Bool v));
  ] in
  match Api.call_json client ~method_name:"setMyDefaultAdministratorRights" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* getMyDefaultAdministratorRights [getmydefaultadministratorrights] -> ChatAdministratorRights *)
let get_my_default_administrator_rights (client:Client.t) ?for_channels () =
  let params = List.filter_map (fun x -> x) [
    (match for_channels with None -> None | Some v -> Some ("for_channels", `Bool v));
  ] in
  match Api.call_json client ~method_name:"getMyDefaultAdministratorRights" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match ChatAdministratorRights.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* getAvailableGifts [getavailablegifts] -> Gifts *)
let get_available_gifts (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"getAvailableGifts" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match Gifts.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* sendGift [sendgift] -> Boolean *)
let send_gift (client:Client.t) ~gift_id ?user_id ?chat_id ?pay_for_upgrade ?text ?text_parse_mode ?text_entities () =
  let params = List.filter_map (fun x -> x) [
    (match user_id with None -> None | Some v -> Some ("user_id", `Intlit (Int64.to_string v)));
    (match chat_id with None -> None | Some v -> Some ("chat_id", `String v));
    Some ("gift_id", `String gift_id);
    (match pay_for_upgrade with None -> None | Some v -> Some ("pay_for_upgrade", `Bool v));
    (match text with None -> None | Some v -> Some ("text", `String v));
    (match text_parse_mode with None -> None | Some v -> Some ("text_parse_mode", `String v));
    (match text_entities with None -> None | Some v -> Some ("text_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) v)));
  ] in
  match Api.call_json client ~method_name:"sendGift" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* giftPremiumSubscription [giftpremiumsubscription] -> Boolean *)
let gift_premium_subscription (client:Client.t) ~user_id ~month_count ~star_count ?text ?text_parse_mode ?text_entities () =
  let params = List.filter_map (fun x -> x) [
    Some ("user_id", `Intlit (Int64.to_string user_id));
    Some ("month_count", `Intlit (Int64.to_string month_count));
    Some ("star_count", `Intlit (Int64.to_string star_count));
    (match text with None -> None | Some v -> Some ("text", `String v));
    (match text_parse_mode with None -> None | Some v -> Some ("text_parse_mode", `String v));
    (match text_entities with None -> None | Some v -> Some ("text_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) v)));
  ] in
  match Api.call_json client ~method_name:"giftPremiumSubscription" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* verifyUser [verifyuser] -> Boolean *)
let verify_user (client:Client.t) ~user_id ?custom_description () =
  let params = List.filter_map (fun x -> x) [
    Some ("user_id", `Intlit (Int64.to_string user_id));
    (match custom_description with None -> None | Some v -> Some ("custom_description", `String v));
  ] in
  match Api.call_json client ~method_name:"verifyUser" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* verifyChat [verifychat] -> Boolean *)
let verify_chat (client:Client.t) ~chat_id ?custom_description () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    (match custom_description with None -> None | Some v -> Some ("custom_description", `String v));
  ] in
  match Api.call_json client ~method_name:"verifyChat" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* removeUserVerification [removeuserverification] -> Boolean *)
let remove_user_verification (client:Client.t) ~user_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("user_id", `Intlit (Int64.to_string user_id));
  ] in
  match Api.call_json client ~method_name:"removeUserVerification" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* removeChatVerification [removechatverification] -> Boolean *)
let remove_chat_verification (client:Client.t) ~chat_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
  ] in
  match Api.call_json client ~method_name:"removeChatVerification" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* readBusinessMessage [readbusinessmessage] -> Boolean *)
let read_business_message (client:Client.t) ~business_connection_id ~chat_id ~message_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("business_connection_id", `String business_connection_id);
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("message_id", `Intlit (Int64.to_string message_id));
  ] in
  match Api.call_json client ~method_name:"readBusinessMessage" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* deleteBusinessMessages [deletebusinessmessages] -> Boolean *)
let delete_business_messages (client:Client.t) ~business_connection_id ~message_ids () =
  let params = List.filter_map (fun x -> x) [
    Some ("business_connection_id", `String business_connection_id);
    Some ("message_ids", `List (List.map (fun x -> `Intlit (Int64.to_string x)) message_ids));
  ] in
  match Api.call_json client ~method_name:"deleteBusinessMessages" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* setBusinessAccountName [setbusinessaccountname] -> Boolean *)
let set_business_account_name (client:Client.t) ~business_connection_id ~first_name ?last_name () =
  let params = List.filter_map (fun x -> x) [
    Some ("business_connection_id", `String business_connection_id);
    Some ("first_name", `String first_name);
    (match last_name with None -> None | Some v -> Some ("last_name", `String v));
  ] in
  match Api.call_json client ~method_name:"setBusinessAccountName" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* setBusinessAccountUsername [setbusinessaccountusername] -> Boolean *)
let set_business_account_username (client:Client.t) ~business_connection_id ?username () =
  let params = List.filter_map (fun x -> x) [
    Some ("business_connection_id", `String business_connection_id);
    (match username with None -> None | Some v -> Some ("username", `String v));
  ] in
  match Api.call_json client ~method_name:"setBusinessAccountUsername" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* setBusinessAccountBio [setbusinessaccountbio] -> Boolean *)
let set_business_account_bio (client:Client.t) ~business_connection_id ?bio () =
  let params = List.filter_map (fun x -> x) [
    Some ("business_connection_id", `String business_connection_id);
    (match bio with None -> None | Some v -> Some ("bio", `String v));
  ] in
  match Api.call_json client ~method_name:"setBusinessAccountBio" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* setBusinessAccountProfilePhoto [setbusinessaccountprofilephoto] -> Boolean *)
let set_business_account_profile_photo (client:Client.t) ~business_connection_id ~photo ?is_public () =
  let params = List.filter_map (fun x -> x) [
    Some ("business_connection_id", `String business_connection_id);
    Some ("photo", InputProfilePhoto.to_yojson photo);
    (match is_public with None -> None | Some v -> Some ("is_public", `Bool v));
  ] in
  match Api.call_json client ~method_name:"setBusinessAccountProfilePhoto" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* removeBusinessAccountProfilePhoto [removebusinessaccountprofilephoto] -> Boolean *)
let remove_business_account_profile_photo (client:Client.t) ~business_connection_id ?is_public () =
  let params = List.filter_map (fun x -> x) [
    Some ("business_connection_id", `String business_connection_id);
    (match is_public with None -> None | Some v -> Some ("is_public", `Bool v));
  ] in
  match Api.call_json client ~method_name:"removeBusinessAccountProfilePhoto" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* setBusinessAccountGiftSettings [setbusinessaccountgiftsettings] -> Boolean *)
let set_business_account_gift_settings (client:Client.t) ~business_connection_id ~show_gift_button ~accepted_gift_types () =
  let params = List.filter_map (fun x -> x) [
    Some ("business_connection_id", `String business_connection_id);
    Some ("show_gift_button", `Bool show_gift_button);
    Some ("accepted_gift_types", AcceptedGiftTypes.to_yojson accepted_gift_types);
  ] in
  match Api.call_json client ~method_name:"setBusinessAccountGiftSettings" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* getBusinessAccountStarBalance [getbusinessaccountstarbalance] -> StarAmount *)
let get_business_account_star_balance (client:Client.t) ~business_connection_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("business_connection_id", `String business_connection_id);
  ] in
  match Api.call_json client ~method_name:"getBusinessAccountStarBalance" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match StarAmount.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* transferBusinessAccountStars [transferbusinessaccountstars] -> Boolean *)
let transfer_business_account_stars (client:Client.t) ~business_connection_id ~star_count () =
  let params = List.filter_map (fun x -> x) [
    Some ("business_connection_id", `String business_connection_id);
    Some ("star_count", `Intlit (Int64.to_string star_count));
  ] in
  match Api.call_json client ~method_name:"transferBusinessAccountStars" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* getBusinessAccountGifts [getbusinessaccountgifts] -> OwnedGifts *)
let get_business_account_gifts (client:Client.t) ~business_connection_id ?exclude_unsaved ?exclude_saved ?exclude_unlimited ?exclude_limited ?exclude_unique ?sort_by_price ?offset ?limit () =
  let params = List.filter_map (fun x -> x) [
    Some ("business_connection_id", `String business_connection_id);
    (match exclude_unsaved with None -> None | Some v -> Some ("exclude_unsaved", `Bool v));
    (match exclude_saved with None -> None | Some v -> Some ("exclude_saved", `Bool v));
    (match exclude_unlimited with None -> None | Some v -> Some ("exclude_unlimited", `Bool v));
    (match exclude_limited with None -> None | Some v -> Some ("exclude_limited", `Bool v));
    (match exclude_unique with None -> None | Some v -> Some ("exclude_unique", `Bool v));
    (match sort_by_price with None -> None | Some v -> Some ("sort_by_price", `Bool v));
    (match offset with None -> None | Some v -> Some ("offset", `String v));
    (match limit with None -> None | Some v -> Some ("limit", `Intlit (Int64.to_string v)));
  ] in
  match Api.call_json client ~method_name:"getBusinessAccountGifts" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match OwnedGifts.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* convertGiftToStars [convertgifttostars] -> Boolean *)
let convert_gift_to_stars (client:Client.t) ~business_connection_id ~owned_gift_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("business_connection_id", `String business_connection_id);
    Some ("owned_gift_id", `String owned_gift_id);
  ] in
  match Api.call_json client ~method_name:"convertGiftToStars" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* upgradeGift [upgradegift] -> Boolean *)
let upgrade_gift (client:Client.t) ~business_connection_id ~owned_gift_id ?keep_original_details ?star_count () =
  let params = List.filter_map (fun x -> x) [
    Some ("business_connection_id", `String business_connection_id);
    Some ("owned_gift_id", `String owned_gift_id);
    (match keep_original_details with None -> None | Some v -> Some ("keep_original_details", `Bool v));
    (match star_count with None -> None | Some v -> Some ("star_count", `Intlit (Int64.to_string v)));
  ] in
  match Api.call_json client ~method_name:"upgradeGift" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* transferGift [transfergift] -> Boolean *)
let transfer_gift (client:Client.t) ~business_connection_id ~owned_gift_id ~new_owner_chat_id ?star_count () =
  let params = List.filter_map (fun x -> x) [
    Some ("business_connection_id", `String business_connection_id);
    Some ("owned_gift_id", `String owned_gift_id);
    Some ("new_owner_chat_id", `Intlit (Int64.to_string new_owner_chat_id));
    (match star_count with None -> None | Some v -> Some ("star_count", `Intlit (Int64.to_string v)));
  ] in
  match Api.call_json client ~method_name:"transferGift" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* postStory [poststory] -> Story *)
let post_story (client:Client.t) ~business_connection_id ~content ~active_period ?caption ?parse_mode ?caption_entities ?areas ?post_to_chat_page ?protect_content () =
  let params = List.filter_map (fun x -> x) [
    Some ("business_connection_id", `String business_connection_id);
    Some ("content", InputStoryContent.to_yojson content);
    Some ("active_period", `Intlit (Int64.to_string active_period));
    (match caption with None -> None | Some v -> Some ("caption", `String v));
    (match parse_mode with None -> None | Some v -> Some ("parse_mode", `String v));
    (match caption_entities with None -> None | Some v -> Some ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) v)));
    (match areas with None -> None | Some v -> Some ("areas", `List (List.map (fun x -> StoryArea.to_yojson x) v)));
    (match post_to_chat_page with None -> None | Some v -> Some ("post_to_chat_page", `Bool v));
    (match protect_content with None -> None | Some v -> Some ("protect_content", `Bool v));
  ] in
  match Api.call_json client ~method_name:"postStory" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match Story.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* editStory [editstory] -> Story *)
let edit_story (client:Client.t) ~business_connection_id ~story_id ~content ?caption ?parse_mode ?caption_entities ?areas () =
  let params = List.filter_map (fun x -> x) [
    Some ("business_connection_id", `String business_connection_id);
    Some ("story_id", `Intlit (Int64.to_string story_id));
    Some ("content", InputStoryContent.to_yojson content);
    (match caption with None -> None | Some v -> Some ("caption", `String v));
    (match parse_mode with None -> None | Some v -> Some ("parse_mode", `String v));
    (match caption_entities with None -> None | Some v -> Some ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) v)));
    (match areas with None -> None | Some v -> Some ("areas", `List (List.map (fun x -> StoryArea.to_yojson x) v)));
  ] in
  match Api.call_json client ~method_name:"editStory" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match Story.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* deleteStory [deletestory] -> Boolean *)
let delete_story (client:Client.t) ~business_connection_id ~story_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("business_connection_id", `String business_connection_id);
    Some ("story_id", `Intlit (Int64.to_string story_id));
  ] in
  match Api.call_json client ~method_name:"deleteStory" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* editMessageText [editmessagetext] -> Boolean *)
let edit_message_text (client:Client.t) ~text ?business_connection_id ?chat_id ?message_id ?inline_message_id ?parse_mode ?entities ?link_preview_options ?reply_markup () =
  let params = List.filter_map (fun x -> x) [
    (match business_connection_id with None -> None | Some v -> Some ("business_connection_id", `String v));
    (match chat_id with None -> None | Some v -> Some ("chat_id", `String v));
    (match message_id with None -> None | Some v -> Some ("message_id", `Intlit (Int64.to_string v)));
    (match inline_message_id with None -> None | Some v -> Some ("inline_message_id", `String v));
    Some ("text", `String text);
    (match parse_mode with None -> None | Some v -> Some ("parse_mode", `String v));
    (match entities with None -> None | Some v -> Some ("entities", `List (List.map (fun x -> MessageEntity.to_yojson x) v)));
    (match link_preview_options with None -> None | Some v -> Some ("link_preview_options", LinkPreviewOptions.to_yojson v));
    (match reply_markup with None -> None | Some v -> Some ("reply_markup", InlineKeyboardMarkup.to_yojson v));
  ] in
  match Api.call_json client ~method_name:"editMessageText" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* editMessageCaption [editmessagecaption] -> Boolean *)
let edit_message_caption (client:Client.t) ?business_connection_id ?chat_id ?message_id ?inline_message_id ?caption ?parse_mode ?caption_entities ?show_caption_above_media ?reply_markup () =
  let params = List.filter_map (fun x -> x) [
    (match business_connection_id with None -> None | Some v -> Some ("business_connection_id", `String v));
    (match chat_id with None -> None | Some v -> Some ("chat_id", `String v));
    (match message_id with None -> None | Some v -> Some ("message_id", `Intlit (Int64.to_string v)));
    (match inline_message_id with None -> None | Some v -> Some ("inline_message_id", `String v));
    (match caption with None -> None | Some v -> Some ("caption", `String v));
    (match parse_mode with None -> None | Some v -> Some ("parse_mode", `String v));
    (match caption_entities with None -> None | Some v -> Some ("caption_entities", `List (List.map (fun x -> MessageEntity.to_yojson x) v)));
    (match show_caption_above_media with None -> None | Some v -> Some ("show_caption_above_media", `Bool v));
    (match reply_markup with None -> None | Some v -> Some ("reply_markup", InlineKeyboardMarkup.to_yojson v));
  ] in
  match Api.call_json client ~method_name:"editMessageCaption" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* editMessageMedia [editmessagemedia] -> Boolean *)
let edit_message_media (client:Client.t) ~media ?business_connection_id ?chat_id ?message_id ?inline_message_id ?reply_markup () =
  let params = List.filter_map (fun x -> x) [
    (match business_connection_id with None -> None | Some v -> Some ("business_connection_id", `String v));
    (match chat_id with None -> None | Some v -> Some ("chat_id", `String v));
    (match message_id with None -> None | Some v -> Some ("message_id", `Intlit (Int64.to_string v)));
    (match inline_message_id with None -> None | Some v -> Some ("inline_message_id", `String v));
    Some ("media", InputMedia.to_yojson media);
    (match reply_markup with None -> None | Some v -> Some ("reply_markup", InlineKeyboardMarkup.to_yojson v));
  ] in
  match Api.call_json client ~method_name:"editMessageMedia" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* editMessageLiveLocation [editmessagelivelocation] -> Boolean *)
let edit_message_live_location (client:Client.t) ~latitude ~longitude ?business_connection_id ?chat_id ?message_id ?inline_message_id ?live_period ?horizontal_accuracy ?heading ?proximity_alert_radius ?reply_markup () =
  let params = List.filter_map (fun x -> x) [
    (match business_connection_id with None -> None | Some v -> Some ("business_connection_id", `String v));
    (match chat_id with None -> None | Some v -> Some ("chat_id", `String v));
    (match message_id with None -> None | Some v -> Some ("message_id", `Intlit (Int64.to_string v)));
    (match inline_message_id with None -> None | Some v -> Some ("inline_message_id", `String v));
    Some ("latitude", latitude);
    Some ("longitude", longitude);
    (match live_period with None -> None | Some v -> Some ("live_period", `Intlit (Int64.to_string v)));
    (match horizontal_accuracy with None -> None | Some v -> Some ("horizontal_accuracy", v));
    (match heading with None -> None | Some v -> Some ("heading", `Intlit (Int64.to_string v)));
    (match proximity_alert_radius with None -> None | Some v -> Some ("proximity_alert_radius", `Intlit (Int64.to_string v)));
    (match reply_markup with None -> None | Some v -> Some ("reply_markup", InlineKeyboardMarkup.to_yojson v));
  ] in
  match Api.call_json client ~method_name:"editMessageLiveLocation" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* stopMessageLiveLocation [stopmessagelivelocation] -> Boolean *)
let stop_message_live_location (client:Client.t) ?business_connection_id ?chat_id ?message_id ?inline_message_id ?reply_markup () =
  let params = List.filter_map (fun x -> x) [
    (match business_connection_id with None -> None | Some v -> Some ("business_connection_id", `String v));
    (match chat_id with None -> None | Some v -> Some ("chat_id", `String v));
    (match message_id with None -> None | Some v -> Some ("message_id", `Intlit (Int64.to_string v)));
    (match inline_message_id with None -> None | Some v -> Some ("inline_message_id", `String v));
    (match reply_markup with None -> None | Some v -> Some ("reply_markup", InlineKeyboardMarkup.to_yojson v));
  ] in
  match Api.call_json client ~method_name:"stopMessageLiveLocation" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* editMessageChecklist [editmessagechecklist] -> Message *)
let edit_message_checklist (client:Client.t) ~business_connection_id ~chat_id ~message_id ~checklist ?reply_markup () =
  let params = List.filter_map (fun x -> x) [
    Some ("business_connection_id", `String business_connection_id);
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("message_id", `Intlit (Int64.to_string message_id));
    Some ("checklist", InputChecklist.to_yojson checklist);
    (match reply_markup with None -> None | Some v -> Some ("reply_markup", InlineKeyboardMarkup.to_yojson v));
  ] in
  match Api.call_json client ~method_name:"editMessageChecklist" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match Message.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* editMessageReplyMarkup [editmessagereplymarkup] -> Boolean *)
let edit_message_reply_markup (client:Client.t) ?business_connection_id ?chat_id ?message_id ?inline_message_id ?reply_markup () =
  let params = List.filter_map (fun x -> x) [
    (match business_connection_id with None -> None | Some v -> Some ("business_connection_id", `String v));
    (match chat_id with None -> None | Some v -> Some ("chat_id", `String v));
    (match message_id with None -> None | Some v -> Some ("message_id", `Intlit (Int64.to_string v)));
    (match inline_message_id with None -> None | Some v -> Some ("inline_message_id", `String v));
    (match reply_markup with None -> None | Some v -> Some ("reply_markup", InlineKeyboardMarkup.to_yojson v));
  ] in
  match Api.call_json client ~method_name:"editMessageReplyMarkup" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* stopPoll [stoppoll] -> Poll *)
let stop_poll (client:Client.t) ~chat_id ~message_id ?business_connection_id ?reply_markup () =
  let params = List.filter_map (fun x -> x) [
    (match business_connection_id with None -> None | Some v -> Some ("business_connection_id", `String v));
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("message_id", `Intlit (Int64.to_string message_id));
    (match reply_markup with None -> None | Some v -> Some ("reply_markup", InlineKeyboardMarkup.to_yojson v));
  ] in
  match Api.call_json client ~method_name:"stopPoll" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match Poll.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* approveSuggestedPost [approvesuggestedpost] -> Boolean *)
let approve_suggested_post (client:Client.t) ~chat_id ~message_id ?send_date () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("message_id", `Intlit (Int64.to_string message_id));
    (match send_date with None -> None | Some v -> Some ("send_date", `Intlit (Int64.to_string v)));
  ] in
  match Api.call_json client ~method_name:"approveSuggestedPost" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* declineSuggestedPost [declinesuggestedpost] -> Boolean *)
let decline_suggested_post (client:Client.t) ~chat_id ~message_id ?comment () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("message_id", `Intlit (Int64.to_string message_id));
    (match comment with None -> None | Some v -> Some ("comment", `String v));
  ] in
  match Api.call_json client ~method_name:"declineSuggestedPost" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* deleteMessage [deletemessage] -> Boolean *)
let delete_message (client:Client.t) ~chat_id ~message_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("message_id", `Intlit (Int64.to_string message_id));
  ] in
  match Api.call_json client ~method_name:"deleteMessage" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* deleteMessages [deletemessages] -> Boolean *)
let delete_messages (client:Client.t) ~chat_id ~message_ids () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    Some ("message_ids", `List (List.map (fun x -> `Intlit (Int64.to_string x)) message_ids));
  ] in
  match Api.call_json client ~method_name:"deleteMessages" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* Sticker [sticker] -> ? *)
let sticker (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"Sticker" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* StickerSet [stickerset] -> ? *)
let sticker_set (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"StickerSet" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* MaskPosition [maskposition] -> ? *)
let mask_position (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"MaskPosition" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* InputSticker [inputsticker] -> ? *)
let input_sticker (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InputSticker" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* sendSticker [sendsticker] -> Message *)
let send_sticker (client:Client.t) ~chat_id ~sticker ?business_connection_id ?message_thread_id ?direct_messages_topic_id ?emoji ?disable_notification ?protect_content ?allow_paid_broadcast ?message_effect_id ?suggested_post_parameters ?reply_parameters ?reply_markup () =
  let params = List.filter_map (fun x -> x) [
    (match business_connection_id with None -> None | Some v -> Some ("business_connection_id", `String v));
    Some ("chat_id", `String (Id.to_string chat_id));
    (match message_thread_id with None -> None | Some v -> Some ("message_thread_id", `Intlit (Int64.to_string v)));
    (match direct_messages_topic_id with None -> None | Some v -> Some ("direct_messages_topic_id", `Intlit (Int64.to_string v)));
    Some ("sticker", `String sticker);
    (match emoji with None -> None | Some v -> Some ("emoji", `String v));
    (match disable_notification with None -> None | Some v -> Some ("disable_notification", `Bool v));
    (match protect_content with None -> None | Some v -> Some ("protect_content", `Bool v));
    (match allow_paid_broadcast with None -> None | Some v -> Some ("allow_paid_broadcast", `Bool v));
    (match message_effect_id with None -> None | Some v -> Some ("message_effect_id", `String v));
    (match suggested_post_parameters with None -> None | Some v -> Some ("suggested_post_parameters", SuggestedPostParameters.to_yojson v));
    (match reply_parameters with None -> None | Some v -> Some ("reply_parameters", ReplyParameters.to_yojson v));
    (match reply_markup with None -> None | Some v -> Some ("reply_markup", `String v));
  ] in
  match Api.call_json client ~method_name:"sendSticker" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match Message.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* getStickerSet [getstickerset] -> StickerSet *)
let get_sticker_set (client:Client.t) ~name () =
  let params = List.filter_map (fun x -> x) [
    Some ("name", `String name);
  ] in
  match Api.call_json client ~method_name:"getStickerSet" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match StickerSet.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* getCustomEmojiStickers [getcustomemojistickers] -> Sticker *)
let get_custom_emoji_stickers (client:Client.t) ~custom_emoji_ids () =
  let params = List.filter_map (fun x -> x) [
    Some ("custom_emoji_ids", `List (List.map (fun x -> `String x) custom_emoji_ids));
  ] in
  match Api.call_json client ~method_name:"getCustomEmojiStickers" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match Sticker.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* uploadStickerFile [uploadstickerfile] -> File *)
let upload_sticker_file (client:Client.t) ~user_id ~sticker ~sticker_format () =
  let params = List.filter_map (fun x -> x) [
    Some ("user_id", `Intlit (Int64.to_string user_id));
    Some ("sticker", InputFile.to_yojson sticker);
    Some ("sticker_format", `String sticker_format);
  ] in
  match Api.call_json client ~method_name:"uploadStickerFile" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match File.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* createNewStickerSet [createnewstickerset] -> Boolean *)
let create_new_sticker_set (client:Client.t) ~user_id ~name ~title ~stickers ?sticker_type ?needs_repainting () =
  let params = List.filter_map (fun x -> x) [
    Some ("user_id", `Intlit (Int64.to_string user_id));
    Some ("name", `String name);
    Some ("title", `String title);
    Some ("stickers", `List (List.map (fun x -> InputSticker.to_yojson x) stickers));
    (match sticker_type with None -> None | Some v -> Some ("sticker_type", `String v));
    (match needs_repainting with None -> None | Some v -> Some ("needs_repainting", `Bool v));
  ] in
  match Api.call_json client ~method_name:"createNewStickerSet" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* addStickerToSet [addstickertoset] -> Boolean *)
let add_sticker_to_set (client:Client.t) ~user_id ~name ~sticker () =
  let params = List.filter_map (fun x -> x) [
    Some ("user_id", `Intlit (Int64.to_string user_id));
    Some ("name", `String name);
    Some ("sticker", InputSticker.to_yojson sticker);
  ] in
  match Api.call_json client ~method_name:"addStickerToSet" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* setStickerPositionInSet [setstickerpositioninset] -> Boolean *)
let set_sticker_position_in_set (client:Client.t) ~sticker ~position () =
  let params = List.filter_map (fun x -> x) [
    Some ("sticker", `String sticker);
    Some ("position", `Intlit (Int64.to_string position));
  ] in
  match Api.call_json client ~method_name:"setStickerPositionInSet" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* deleteStickerFromSet [deletestickerfromset] -> Boolean *)
let delete_sticker_from_set (client:Client.t) ~sticker () =
  let params = List.filter_map (fun x -> x) [
    Some ("sticker", `String sticker);
  ] in
  match Api.call_json client ~method_name:"deleteStickerFromSet" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* replaceStickerInSet [replacestickerinset] -> Boolean *)
let replace_sticker_in_set (client:Client.t) ~user_id ~name ~old_sticker ~sticker () =
  let params = List.filter_map (fun x -> x) [
    Some ("user_id", `Intlit (Int64.to_string user_id));
    Some ("name", `String name);
    Some ("old_sticker", `String old_sticker);
    Some ("sticker", InputSticker.to_yojson sticker);
  ] in
  match Api.call_json client ~method_name:"replaceStickerInSet" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* setStickerEmojiList [setstickeremojilist] -> Boolean *)
let set_sticker_emoji_list (client:Client.t) ~sticker ~emoji_list () =
  let params = List.filter_map (fun x -> x) [
    Some ("sticker", `String sticker);
    Some ("emoji_list", `List (List.map (fun x -> `String x) emoji_list));
  ] in
  match Api.call_json client ~method_name:"setStickerEmojiList" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* setStickerKeywords [setstickerkeywords] -> Boolean *)
let set_sticker_keywords (client:Client.t) ~sticker ?keywords () =
  let params = List.filter_map (fun x -> x) [
    Some ("sticker", `String sticker);
    (match keywords with None -> None | Some v -> Some ("keywords", `List (List.map (fun x -> `String x) v)));
  ] in
  match Api.call_json client ~method_name:"setStickerKeywords" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* setStickerMaskPosition [setstickermaskposition] -> Boolean *)
let set_sticker_mask_position (client:Client.t) ~sticker ?mask_position () =
  let params = List.filter_map (fun x -> x) [
    Some ("sticker", `String sticker);
    (match mask_position with None -> None | Some v -> Some ("mask_position", MaskPosition.to_yojson v));
  ] in
  match Api.call_json client ~method_name:"setStickerMaskPosition" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* setStickerSetTitle [setstickersettitle] -> Boolean *)
let set_sticker_set_title (client:Client.t) ~name ~title () =
  let params = List.filter_map (fun x -> x) [
    Some ("name", `String name);
    Some ("title", `String title);
  ] in
  match Api.call_json client ~method_name:"setStickerSetTitle" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* setStickerSetThumbnail [setstickersetthumbnail] -> Boolean *)
let set_sticker_set_thumbnail (client:Client.t) ~name ~user_id ~format ?thumbnail () =
  let params = List.filter_map (fun x -> x) [
    Some ("name", `String name);
    Some ("user_id", `Intlit (Int64.to_string user_id));
    (match thumbnail with None -> None | Some v -> Some ("thumbnail", `String v));
    Some ("format", `String format);
  ] in
  match Api.call_json client ~method_name:"setStickerSetThumbnail" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* setCustomEmojiStickerSetThumbnail [setcustomemojistickersetthumbnail] -> Boolean *)
let set_custom_emoji_sticker_set_thumbnail (client:Client.t) ~name ?custom_emoji_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("name", `String name);
    (match custom_emoji_id with None -> None | Some v -> Some ("custom_emoji_id", `String v));
  ] in
  match Api.call_json client ~method_name:"setCustomEmojiStickerSetThumbnail" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* deleteStickerSet [deletestickerset] -> Boolean *)
let delete_sticker_set (client:Client.t) ~name () =
  let params = List.filter_map (fun x -> x) [
    Some ("name", `String name);
  ] in
  match Api.call_json client ~method_name:"deleteStickerSet" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* InlineQuery [inlinequery] -> ? *)
let inline_query (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InlineQuery" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* answerInlineQuery [answerinlinequery] -> Boolean *)
let answer_inline_query (client:Client.t) ~inline_query_id ~results ?cache_time ?is_personal ?next_offset ?button () =
  let params = List.filter_map (fun x -> x) [
    Some ("inline_query_id", `String inline_query_id);
    Some ("results", `List (List.map (fun x -> InlineQueryResult.to_yojson x) results));
    (match cache_time with None -> None | Some v -> Some ("cache_time", `Intlit (Int64.to_string v)));
    (match is_personal with None -> None | Some v -> Some ("is_personal", `Bool v));
    (match next_offset with None -> None | Some v -> Some ("next_offset", `String v));
    (match button with None -> None | Some v -> Some ("button", InlineQueryResultsButton.to_yojson v));
  ] in
  match Api.call_json client ~method_name:"answerInlineQuery" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* InlineQueryResultsButton [inlinequeryresultsbutton] -> ? *)
let inline_query_results_button (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InlineQueryResultsButton" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* InlineQueryResult [inlinequeryresult] -> ? *)
let inline_query_result (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InlineQueryResult" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* InlineQueryResultArticle [inlinequeryresultarticle] -> ? *)
let inline_query_result_article (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InlineQueryResultArticle" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* InlineQueryResultPhoto [inlinequeryresultphoto] -> ? *)
let inline_query_result_photo (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InlineQueryResultPhoto" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* InlineQueryResultGif [inlinequeryresultgif] -> ? *)
let inline_query_result_gif (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InlineQueryResultGif" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* InlineQueryResultMpeg4Gif [inlinequeryresultmpeg4gif] -> ? *)
let inline_query_result_mpeg4_gif (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InlineQueryResultMpeg4Gif" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* InlineQueryResultVideo [inlinequeryresultvideo] -> ? *)
let inline_query_result_video (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InlineQueryResultVideo" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* InlineQueryResultAudio [inlinequeryresultaudio] -> ? *)
let inline_query_result_audio (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InlineQueryResultAudio" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* InlineQueryResultVoice [inlinequeryresultvoice] -> ? *)
let inline_query_result_voice (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InlineQueryResultVoice" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* InlineQueryResultDocument [inlinequeryresultdocument] -> ? *)
let inline_query_result_document (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InlineQueryResultDocument" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* InlineQueryResultLocation [inlinequeryresultlocation] -> ? *)
let inline_query_result_location (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InlineQueryResultLocation" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* InlineQueryResultVenue [inlinequeryresultvenue] -> ? *)
let inline_query_result_venue (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InlineQueryResultVenue" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* InlineQueryResultContact [inlinequeryresultcontact] -> ? *)
let inline_query_result_contact (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InlineQueryResultContact" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* InlineQueryResultGame [inlinequeryresultgame] -> Game *)
let inline_query_result_game (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InlineQueryResultGame" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match Game.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* InlineQueryResultCachedPhoto [inlinequeryresultcachedphoto] -> ? *)
let inline_query_result_cached_photo (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InlineQueryResultCachedPhoto" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* InlineQueryResultCachedGif [inlinequeryresultcachedgif] -> ? *)
let inline_query_result_cached_gif (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InlineQueryResultCachedGif" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* InlineQueryResultCachedMpeg4Gif [inlinequeryresultcachedmpeg4gif] -> ? *)
let inline_query_result_cached_mpeg4_gif (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InlineQueryResultCachedMpeg4Gif" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* InlineQueryResultCachedSticker [inlinequeryresultcachedsticker] -> ? *)
let inline_query_result_cached_sticker (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InlineQueryResultCachedSticker" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* InlineQueryResultCachedDocument [inlinequeryresultcacheddocument] -> ? *)
let inline_query_result_cached_document (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InlineQueryResultCachedDocument" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* InlineQueryResultCachedVideo [inlinequeryresultcachedvideo] -> ? *)
let inline_query_result_cached_video (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InlineQueryResultCachedVideo" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* InlineQueryResultCachedVoice [inlinequeryresultcachedvoice] -> ? *)
let inline_query_result_cached_voice (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InlineQueryResultCachedVoice" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* InlineQueryResultCachedAudio [inlinequeryresultcachedaudio] -> ? *)
let inline_query_result_cached_audio (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InlineQueryResultCachedAudio" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* InputMessageContent [inputmessagecontent] -> ? *)
let input_message_content (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InputMessageContent" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* InputTextMessageContent [inputtextmessagecontent] -> ? *)
let input_text_message_content (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InputTextMessageContent" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* InputLocationMessageContent [inputlocationmessagecontent] -> ? *)
let input_location_message_content (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InputLocationMessageContent" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* InputVenueMessageContent [inputvenuemessagecontent] -> ? *)
let input_venue_message_content (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InputVenueMessageContent" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* InputContactMessageContent [inputcontactmessagecontent] -> ? *)
let input_contact_message_content (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InputContactMessageContent" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* InputInvoiceMessageContent [inputinvoicemessagecontent] -> ? *)
let input_invoice_message_content (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"InputInvoiceMessageContent" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* ChosenInlineResult [choseninlineresult] -> ? *)
let chosen_inline_result (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"ChosenInlineResult" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* answerWebAppQuery [answerwebappquery] -> SentWebAppMessage *)
let answer_web_app_query (client:Client.t) ~web_app_query_id ~result () =
  let params = List.filter_map (fun x -> x) [
    Some ("web_app_query_id", `String web_app_query_id);
    Some ("result", InlineQueryResult.to_yojson result);
  ] in
  match Api.call_json client ~method_name:"answerWebAppQuery" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match SentWebAppMessage.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* SentWebAppMessage [sentwebappmessage] -> ? *)
let sent_web_app_message (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"SentWebAppMessage" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* savePreparedInlineMessage [savepreparedinlinemessage] -> PreparedInlineMessage *)
let save_prepared_inline_message (client:Client.t) ~user_id ~result ?allow_user_chats ?allow_bot_chats ?allow_group_chats ?allow_channel_chats () =
  let params = List.filter_map (fun x -> x) [
    Some ("user_id", `Intlit (Int64.to_string user_id));
    Some ("result", InlineQueryResult.to_yojson result);
    (match allow_user_chats with None -> None | Some v -> Some ("allow_user_chats", `Bool v));
    (match allow_bot_chats with None -> None | Some v -> Some ("allow_bot_chats", `Bool v));
    (match allow_group_chats with None -> None | Some v -> Some ("allow_group_chats", `Bool v));
    (match allow_channel_chats with None -> None | Some v -> Some ("allow_channel_chats", `Bool v));
  ] in
  match Api.call_json client ~method_name:"savePreparedInlineMessage" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match PreparedInlineMessage.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* PreparedInlineMessage [preparedinlinemessage] -> ? *)
let prepared_inline_message (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"PreparedInlineMessage" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* sendInvoice [sendinvoice] -> Message *)
let send_invoice (client:Client.t) ~chat_id ~title ~description ~payload ~currency ~prices ?message_thread_id ?direct_messages_topic_id ?provider_token ?max_tip_amount ?suggested_tip_amounts ?start_parameter ?provider_data ?photo_url ?photo_size ?photo_width ?photo_height ?need_name ?need_phone_number ?need_email ?need_shipping_address ?send_phone_number_to_provider ?send_email_to_provider ?is_flexible ?disable_notification ?protect_content ?allow_paid_broadcast ?message_effect_id ?suggested_post_parameters ?reply_parameters ?reply_markup () =
  let params = List.filter_map (fun x -> x) [
    Some ("chat_id", `String (Id.to_string chat_id));
    (match message_thread_id with None -> None | Some v -> Some ("message_thread_id", `Intlit (Int64.to_string v)));
    (match direct_messages_topic_id with None -> None | Some v -> Some ("direct_messages_topic_id", `Intlit (Int64.to_string v)));
    Some ("title", `String title);
    Some ("description", `String description);
    Some ("payload", `String payload);
    (match provider_token with None -> None | Some v -> Some ("provider_token", `String v));
    Some ("currency", `String currency);
    Some ("prices", `List (List.map (fun x -> LabeledPrice.to_yojson x) prices));
    (match max_tip_amount with None -> None | Some v -> Some ("max_tip_amount", `Intlit (Int64.to_string v)));
    (match suggested_tip_amounts with None -> None | Some v -> Some ("suggested_tip_amounts", `List (List.map (fun x -> `Intlit (Int64.to_string x)) v)));
    (match start_parameter with None -> None | Some v -> Some ("start_parameter", `String v));
    (match provider_data with None -> None | Some v -> Some ("provider_data", `String v));
    (match photo_url with None -> None | Some v -> Some ("photo_url", `String v));
    (match photo_size with None -> None | Some v -> Some ("photo_size", `Intlit (Int64.to_string v)));
    (match photo_width with None -> None | Some v -> Some ("photo_width", `Intlit (Int64.to_string v)));
    (match photo_height with None -> None | Some v -> Some ("photo_height", `Intlit (Int64.to_string v)));
    (match need_name with None -> None | Some v -> Some ("need_name", `Bool v));
    (match need_phone_number with None -> None | Some v -> Some ("need_phone_number", `Bool v));
    (match need_email with None -> None | Some v -> Some ("need_email", `Bool v));
    (match need_shipping_address with None -> None | Some v -> Some ("need_shipping_address", `Bool v));
    (match send_phone_number_to_provider with None -> None | Some v -> Some ("send_phone_number_to_provider", `Bool v));
    (match send_email_to_provider with None -> None | Some v -> Some ("send_email_to_provider", `Bool v));
    (match is_flexible with None -> None | Some v -> Some ("is_flexible", `Bool v));
    (match disable_notification with None -> None | Some v -> Some ("disable_notification", `Bool v));
    (match protect_content with None -> None | Some v -> Some ("protect_content", `Bool v));
    (match allow_paid_broadcast with None -> None | Some v -> Some ("allow_paid_broadcast", `Bool v));
    (match message_effect_id with None -> None | Some v -> Some ("message_effect_id", `String v));
    (match suggested_post_parameters with None -> None | Some v -> Some ("suggested_post_parameters", SuggestedPostParameters.to_yojson v));
    (match reply_parameters with None -> None | Some v -> Some ("reply_parameters", ReplyParameters.to_yojson v));
    (match reply_markup with None -> None | Some v -> Some ("reply_markup", InlineKeyboardMarkup.to_yojson v));
  ] in
  match Api.call_json client ~method_name:"sendInvoice" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match Message.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* createInvoiceLink [createinvoicelink] -> ? *)
let create_invoice_link (client:Client.t) ~title ~description ~payload ~currency ~prices ?business_connection_id ?provider_token ?subscription_period ?max_tip_amount ?suggested_tip_amounts ?provider_data ?photo_url ?photo_size ?photo_width ?photo_height ?need_name ?need_phone_number ?need_email ?need_shipping_address ?send_phone_number_to_provider ?send_email_to_provider ?is_flexible () =
  let params = List.filter_map (fun x -> x) [
    (match business_connection_id with None -> None | Some v -> Some ("business_connection_id", `String v));
    Some ("title", `String title);
    Some ("description", `String description);
    Some ("payload", `String payload);
    (match provider_token with None -> None | Some v -> Some ("provider_token", `String v));
    Some ("currency", `String currency);
    Some ("prices", `List (List.map (fun x -> LabeledPrice.to_yojson x) prices));
    (match subscription_period with None -> None | Some v -> Some ("subscription_period", `Intlit (Int64.to_string v)));
    (match max_tip_amount with None -> None | Some v -> Some ("max_tip_amount", `Intlit (Int64.to_string v)));
    (match suggested_tip_amounts with None -> None | Some v -> Some ("suggested_tip_amounts", `List (List.map (fun x -> `Intlit (Int64.to_string x)) v)));
    (match provider_data with None -> None | Some v -> Some ("provider_data", `String v));
    (match photo_url with None -> None | Some v -> Some ("photo_url", `String v));
    (match photo_size with None -> None | Some v -> Some ("photo_size", `Intlit (Int64.to_string v)));
    (match photo_width with None -> None | Some v -> Some ("photo_width", `Intlit (Int64.to_string v)));
    (match photo_height with None -> None | Some v -> Some ("photo_height", `Intlit (Int64.to_string v)));
    (match need_name with None -> None | Some v -> Some ("need_name", `Bool v));
    (match need_phone_number with None -> None | Some v -> Some ("need_phone_number", `Bool v));
    (match need_email with None -> None | Some v -> Some ("need_email", `Bool v));
    (match need_shipping_address with None -> None | Some v -> Some ("need_shipping_address", `Bool v));
    (match send_phone_number_to_provider with None -> None | Some v -> Some ("send_phone_number_to_provider", `Bool v));
    (match send_email_to_provider with None -> None | Some v -> Some ("send_email_to_provider", `Bool v));
    (match is_flexible with None -> None | Some v -> Some ("is_flexible", `Bool v));
  ] in
  match Api.call_json client ~method_name:"createInvoiceLink" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* answerShippingQuery [answershippingquery] -> Boolean *)
let answer_shipping_query (client:Client.t) ~shipping_query_id ~ok ?shipping_options ?error_message () =
  let params = List.filter_map (fun x -> x) [
    Some ("shipping_query_id", `String shipping_query_id);
    Some ("ok", `Bool ok);
    (match shipping_options with None -> None | Some v -> Some ("shipping_options", `List (List.map (fun x -> ShippingOption.to_yojson x) v)));
    (match error_message with None -> None | Some v -> Some ("error_message", `String v));
  ] in
  match Api.call_json client ~method_name:"answerShippingQuery" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* answerPreCheckoutQuery [answerprecheckoutquery] -> Boolean *)
let answer_pre_checkout_query (client:Client.t) ~pre_checkout_query_id ~ok ?error_message () =
  let params = List.filter_map (fun x -> x) [
    Some ("pre_checkout_query_id", `String pre_checkout_query_id);
    Some ("ok", `Bool ok);
    (match error_message with None -> None | Some v -> Some ("error_message", `String v));
  ] in
  match Api.call_json client ~method_name:"answerPreCheckoutQuery" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* getMyStarBalance [getmystarbalance] -> StarAmount *)
let get_my_star_balance (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"getMyStarBalance" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match StarAmount.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* getStarTransactions [getstartransactions] -> StarTransactions *)
let get_star_transactions (client:Client.t) ?offset ?limit () =
  let params = List.filter_map (fun x -> x) [
    (match offset with None -> None | Some v -> Some ("offset", `Intlit (Int64.to_string v)));
    (match limit with None -> None | Some v -> Some ("limit", `Intlit (Int64.to_string v)));
  ] in
  match Api.call_json client ~method_name:"getStarTransactions" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match StarTransactions.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* refundStarPayment [refundstarpayment] -> Boolean *)
let refund_star_payment (client:Client.t) ~user_id ~telegram_payment_charge_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("user_id", `Intlit (Int64.to_string user_id));
    Some ("telegram_payment_charge_id", `String telegram_payment_charge_id);
  ] in
  match Api.call_json client ~method_name:"refundStarPayment" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* editUserStarSubscription [edituserstarsubscription] -> Boolean *)
let edit_user_star_subscription (client:Client.t) ~user_id ~telegram_payment_charge_id ~is_canceled () =
  let params = List.filter_map (fun x -> x) [
    Some ("user_id", `Intlit (Int64.to_string user_id));
    Some ("telegram_payment_charge_id", `String telegram_payment_charge_id);
    Some ("is_canceled", `Bool is_canceled);
  ] in
  match Api.call_json client ~method_name:"editUserStarSubscription" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* LabeledPrice [labeledprice] -> ? *)
let labeled_price (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"LabeledPrice" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* Invoice [invoice] -> ? *)
let invoice (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"Invoice" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* ShippingAddress [shippingaddress] -> ? *)
let shipping_address (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"ShippingAddress" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* OrderInfo [orderinfo] -> ? *)
let order_info (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"OrderInfo" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* ShippingOption [shippingoption] -> ? *)
let shipping_option (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"ShippingOption" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* SuccessfulPayment [successfulpayment] -> ? *)
let successful_payment (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"SuccessfulPayment" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* RefundedPayment [refundedpayment] -> ? *)
let refunded_payment (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"RefundedPayment" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* ShippingQuery [shippingquery] -> ? *)
let shipping_query (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"ShippingQuery" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* PreCheckoutQuery [precheckoutquery] -> ? *)
let pre_checkout_query (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"PreCheckoutQuery" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* PaidMediaPurchased [paidmediapurchased] -> ? *)
let paid_media_purchased (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"PaidMediaPurchased" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* RevenueWithdrawalState [revenuewithdrawalstate] -> ? *)
let revenue_withdrawal_state (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"RevenueWithdrawalState" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* RevenueWithdrawalStatePending [revenuewithdrawalstatepending] -> ? *)
let revenue_withdrawal_state_pending (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"RevenueWithdrawalStatePending" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* RevenueWithdrawalStateSucceeded [revenuewithdrawalstatesucceeded] -> ? *)
let revenue_withdrawal_state_succeeded (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"RevenueWithdrawalStateSucceeded" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* RevenueWithdrawalStateFailed [revenuewithdrawalstatefailed] -> ? *)
let revenue_withdrawal_state_failed (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"RevenueWithdrawalStateFailed" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* AffiliateInfo [affiliateinfo] -> ? *)
let affiliate_info (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"AffiliateInfo" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* TransactionPartner [transactionpartner] -> ? *)
let transaction_partner (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"TransactionPartner" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* TransactionPartnerUser [transactionpartneruser] -> ? *)
let transaction_partner_user (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"TransactionPartnerUser" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* TransactionPartnerChat [transactionpartnerchat] -> ? *)
let transaction_partner_chat (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"TransactionPartnerChat" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* TransactionPartnerAffiliateProgram [transactionpartneraffiliateprogram] -> ? *)
let transaction_partner_affiliate_program (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"TransactionPartnerAffiliateProgram" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* TransactionPartnerFragment [transactionpartnerfragment] -> ? *)
let transaction_partner_fragment (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"TransactionPartnerFragment" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* TransactionPartnerTelegramAds [transactionpartnertelegramads] -> ? *)
let transaction_partner_telegram_ads (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"TransactionPartnerTelegramAds" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* TransactionPartnerTelegramApi [transactionpartnertelegramapi] -> ? *)
let transaction_partner_telegram_api (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"TransactionPartnerTelegramApi" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* TransactionPartnerOther [transactionpartnerother] -> ? *)
let transaction_partner_other (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"TransactionPartnerOther" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* StarTransaction [startransaction] -> ? *)
let star_transaction (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"StarTransaction" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* StarTransactions [startransactions] -> ? *)
let star_transactions (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"StarTransactions" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* PassportData [passportdata] -> ? *)
let passport_data (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"PassportData" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* PassportFile [passportfile] -> ? *)
let passport_file (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"PassportFile" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* EncryptedPassportElement [encryptedpassportelement] -> ? *)
let encrypted_passport_element (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"EncryptedPassportElement" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* EncryptedCredentials [encryptedcredentials] -> EncryptedPassportElement *)
let encrypted_credentials (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"EncryptedCredentials" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match EncryptedPassportElement.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* setPassportDataErrors [setpassportdataerrors] -> Boolean *)
let set_passport_data_errors (client:Client.t) ~user_id ~errors () =
  let params = List.filter_map (fun x -> x) [
    Some ("user_id", `Intlit (Int64.to_string user_id));
    Some ("errors", `List (List.map (fun x -> PassportElementError.to_yojson x) errors));
  ] in
  match Api.call_json client ~method_name:"setPassportDataErrors" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* PassportElementError [passportelementerror] -> ? *)
let passport_element_error (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"PassportElementError" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* PassportElementErrorDataField [passportelementerrordatafield] -> ? *)
let passport_element_error_data_field (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"PassportElementErrorDataField" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* PassportElementErrorFrontSide [passportelementerrorfrontside] -> ? *)
let passport_element_error_front_side (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"PassportElementErrorFrontSide" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* PassportElementErrorReverseSide [passportelementerrorreverseside] -> ? *)
let passport_element_error_reverse_side (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"PassportElementErrorReverseSide" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* PassportElementErrorSelfie [passportelementerrorselfie] -> ? *)
let passport_element_error_selfie (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"PassportElementErrorSelfie" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* PassportElementErrorFile [passportelementerrorfile] -> ? *)
let passport_element_error_file (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"PassportElementErrorFile" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* PassportElementErrorFiles [passportelementerrorfiles] -> ? *)
let passport_element_error_files (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"PassportElementErrorFiles" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* PassportElementErrorTranslationFile [passportelementerrortranslationfile] -> ? *)
let passport_element_error_translation_file (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"PassportElementErrorTranslationFile" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* PassportElementErrorTranslationFiles [passportelementerrortranslationfiles] -> ? *)
let passport_element_error_translation_files (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"PassportElementErrorTranslationFiles" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* PassportElementErrorUnspecified [passportelementerrorunspecified] -> ? *)
let passport_element_error_unspecified (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"PassportElementErrorUnspecified" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* sendGame [sendgame] -> Message *)
let send_game (client:Client.t) ~chat_id ~game_short_name ?business_connection_id ?message_thread_id ?disable_notification ?protect_content ?allow_paid_broadcast ?message_effect_id ?reply_parameters ?reply_markup () =
  let params = List.filter_map (fun x -> x) [
    (match business_connection_id with None -> None | Some v -> Some ("business_connection_id", `String v));
    Some ("chat_id", `String (Id.to_string chat_id));
    (match message_thread_id with None -> None | Some v -> Some ("message_thread_id", `Intlit (Int64.to_string v)));
    Some ("game_short_name", `String game_short_name);
    (match disable_notification with None -> None | Some v -> Some ("disable_notification", `Bool v));
    (match protect_content with None -> None | Some v -> Some ("protect_content", `Bool v));
    (match allow_paid_broadcast with None -> None | Some v -> Some ("allow_paid_broadcast", `Bool v));
    (match message_effect_id with None -> None | Some v -> Some ("message_effect_id", `String v));
    (match reply_parameters with None -> None | Some v -> Some ("reply_parameters", ReplyParameters.to_yojson v));
    (match reply_markup with None -> None | Some v -> Some ("reply_markup", InlineKeyboardMarkup.to_yojson v));
  ] in
  match Api.call_json client ~method_name:"sendGame" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match Message.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* Game [game] -> ? *)
let game (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"Game" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* CallbackGame [callbackgame] -> ? *)
let callback_game (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"CallbackGame" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

(* setGameScore [setgamescore] -> Boolean *)
let set_game_score (client:Client.t) ~user_id ~score ?force ?disable_edit_message ?chat_id ?message_id ?inline_message_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("user_id", `Intlit (Int64.to_string user_id));
    Some ("score", `Intlit (Int64.to_string score));
    (match force with None -> None | Some v -> Some ("force", `Bool v));
    (match disable_edit_message with None -> None | Some v -> Some ("disable_edit_message", `Bool v));
    (match chat_id with None -> None | Some v -> Some ("chat_id", `Intlit (Int64.to_string v)));
    (match message_id with None -> None | Some v -> Some ("message_id", `Intlit (Int64.to_string v)));
    (match inline_message_id with None -> None | Some v -> Some ("inline_message_id", `String v));
  ] in
  match Api.call_json client ~method_name:"setGameScore" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok (Yojson.Safe.Util.to_bool j)

(* getGameHighScores [getgamehighscores] -> GameHighScore *)
let get_game_high_scores (client:Client.t) ~user_id ?chat_id ?message_id ?inline_message_id () =
  let params = List.filter_map (fun x -> x) [
    Some ("user_id", `Intlit (Int64.to_string user_id));
    (match chat_id with None -> None | Some v -> Some ("chat_id", `Intlit (Int64.to_string v)));
    (match message_id with None -> None | Some v -> Some ("message_id", `Intlit (Int64.to_string v)));
    (match inline_message_id with None -> None | Some v -> Some ("inline_message_id", `String v));
  ] in
  match Api.call_json client ~method_name:"getGameHighScores" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> (match GameHighScore.of_yojson j with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))

(* GameHighScore [gamehighscore] -> ? *)
let game_high_score (client:Client.t) () =
  let params = List.filter_map (fun x -> x) [
  ] in
  match Api.call_json client ~method_name:"GameHighScore" (`Assoc params) with
  | Error e -> Error e
  | Ok j -> Ok j

