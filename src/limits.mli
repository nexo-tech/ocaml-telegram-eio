(** Resource limits and policies for uploads/downloads *)

(** {1 File Size Limits} *)

type size_limit =
  | Unlimited
  | Max_bytes of int64
  | Max_mb of int  (** Megabytes *)

val size_limit_bytes : size_limit -> int64 option
(** Convert size limit to bytes (None for Unlimited) *)

val check_size : size_limit -> int64 -> (unit, string) result
(** Check if size is within limit *)

(** {1 Policy Configuration} *)

type t = {
  max_upload_size : size_limit;
  max_download_size : size_limit;
  temp_dir : string option;  (** Temporary directory for file operations (None = system default) *)
  request_timeout : float option;  (** Request timeout in seconds (None = no timeout) *)
  chunk_size : int;  (** Chunk size for streaming (default: 16384 bytes) *)
}

val default : t
(** Default policy:
    - Unlimited upload/download sizes
    - System temp directory
    - No request timeout
    - 16KB chunk size *)

val telegram_limits : t
(** Telegram API limits:
    - Max upload: 50MB (2000MB for local bot API)
    - Max download: 20MB
    - System temp directory
    - 60s request timeout
    - 16KB chunk size *)

(** {1 Policy Builders} *)

val with_max_upload : int -> t -> t
(** Set max upload size in MB *)

val with_max_download : int -> t -> t
(** Set max download size in MB *)

val with_temp_dir : string -> t -> t
(** Set temporary directory *)

val with_timeout : float -> t -> t
(** Set request timeout in seconds *)

val with_chunk_size : int -> t -> t
(** Set chunk size for streaming *)

(** {1 Policy Application} *)

val check_upload_size : t -> int64 -> (unit, string) result
(** Check if upload size is within policy limits *)

val check_download_size : t -> int64 -> (unit, string) result
(** Check if download size is within policy limits *)

val get_temp_dir : t -> string
(** Get temp directory (system default if not configured) *)

val get_chunk_size : t -> int
(** Get chunk size for streaming *)
