(** Large file transfer utilities with retry and resumption support *)

open Telegram

(** {1 Transfer Configuration} *)

type config = {
  limits : Limits.t;
  retry : Retry.config;
  chunk_size : int;  (** Chunk size for streaming (derived from limits) *)
}

val default_config : config
(** Default configuration using telegram_limits and exponential backoff retry *)

val make_config : ?limits:Limits.t -> ?retry:Retry.config -> unit -> config
(** Create custom configuration *)

(** {1 Upload with Retry} *)

val upload_with_retry :
  config ->
  Client.t ->
  path:string ->
  ?on_progress:(Upload.progress -> unit) ->
  (string * Http.part_value) list ->
  (Http.body, Error.t) result
(** Upload file with automatic retry on failure.

    This wraps Upload.with_progress with retry logic for mid-stream failures.

    Example:
    {[
      let config = Large_file.default_config in
      match Large_file.upload_with_retry config client ~path:"/path/to/large/file.mp4" [
        Upload.string_part ~name:"chat_id" ~value:"123";
        Upload.file_part ~name:"video" ~path:"/path/to/large/file.mp4" ();
      ] with
      | Ok body -> (* use body in API call *)
      | Error e -> (* handle error *)
    ]} *)

(** {1 Download with Retry} *)

val download_with_retry :
  config ->
  Client.t ->
  file_path:string ->
  Buffer.t ->
  (int64, Error.t) result
(** Download file with automatic retry on mid-stream failure.

    Retries the entire download on failure (Telegram doesn't support range requests).

    Example:
    {[
      let config = Large_file.default_config in
      let buf = Buffer.create 8192 in
      match Large_file.download_with_retry config client ~file_path:"path/to/file" buf with
      | Ok bytes -> Printf.printf "Downloaded %Ld bytes\n" bytes
      | Error e -> Error.pp Format.std_formatter e
    ]} *)

(** {1 Utilities} *)

val with_chunk_size : int -> config -> config
(** Update chunk size in configuration *)

val with_retry_attempts : int -> config -> config
(** Update max retry attempts in configuration *)
