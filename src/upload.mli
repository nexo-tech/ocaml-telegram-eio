(** File upload helpers with progress tracking *)

(** {1 Progress Tracking} *)

type progress = {
  bytes_sent : int64;
  total_bytes : int64 option;
  percent : float option;  (** Percentage complete (0.0 to 100.0), None if total unknown *)
}

val progress_callback : (progress -> unit) -> Telegram.Http.progress_callback
(** Convert a high-level progress function to Http progress callback.

    Example:
    {[
      let on_progress p =
        match p.percent with
        | Some pct -> Printf.printf "\rProgress: %.1f%%" pct
        | None -> Printf.printf "\rSent: %Ld bytes" p.bytes_sent
      in
      Upload.progress_callback on_progress
    ]} *)

(** {1 File Upload Helpers} *)

val file_part : name:string -> ?filename:string -> ?content_type:string -> path:string -> unit -> (string * Telegram.Http.part_value)
(** Create a file part for multipart upload.

    - [name]: Form field name
    - [filename]: Filename to send (defaults to basename of path)
    - [content_type]: MIME type (defaults to "application/octet-stream")
    - [path]: Local file path to upload

    Example:
    {[
      let photo_part = Upload.file_part ~name:"photo" ~path:"/tmp/photo.jpg" ()
    ]} *)

val string_part : name:string -> value:string -> (string * Telegram.Http.part_value)
(** Create a string part for multipart upload.

    Example:
    {[
      let caption_part = Upload.string_part ~name:"caption" ~value:"My photo"
    ]} *)

(** {1 Convenience Functions} *)

val with_progress :
  ?on_progress:(progress -> unit) ->
  (string * Telegram.Http.part_value) list ->
  Telegram.Http.body
(** Create multipart body with optional progress tracking.

    Example:
    {[
      let body = Upload.with_progress ~on_progress [
        Upload.string_part ~name:"chat_id" ~value:"123456";
        Upload.file_part ~name:"photo" ~path:"/tmp/photo.jpg" ();
      ]
    ]} *)

val with_limits :
  ?on_progress:(progress -> unit) ->
  limits:Telegram.Limits.t ->
  (string * Telegram.Http.part_value) list ->
  (Telegram.Http.body, string) result
(** Create multipart body with size limit validation and optional progress tracking.

    Validates total upload size against limits before creating the body.
    Returns Error if the upload exceeds the configured limit.

    Example:
    {[
      let limits = Limits.telegram_limits in
      match Upload.with_limits ~limits [
        Upload.string_part ~name:"chat_id" ~value:"123456";
        Upload.file_part ~name:"photo" ~path:"/tmp/photo.jpg" ();
      ] with
      | Ok body -> (* use body *)
      | Error msg -> (* handle size limit error *)
    ]} *)
