(** File download helpers for Telegram Bot API *)

(** {1 File Information} *)

type file_info = {
  file_id : string;
  file_unique_id : string;
  file_size : int64 option;
  file_path : string option;
}
(** File information returned by getFile *)

val get_file : Telegram.Client.t -> file_id:string -> (file_info, Telegram.Error.t) result
(** Get file information from Telegram.

    Call this first to get the file_path needed for downloading.
    The file_path is valid for at least 1 hour.

    Example:
    {[
      match Download.get_file client ~file_id with
      | Ok info -> Printf.printf "File size: %Ld bytes\n" (Option.get info.file_size)
      | Error e -> Printf.eprintf "Error: %a\n" Telegram.Error.pp e
    ]} *)

(** {1 Download URLs} *)

val download_url : Telegram.Client.t -> file_path:string -> string
(** Build download URL from file_path.

    Format: https://api.telegram.org/file/bot<token>/<file_path>

    Example:
    {[
      let url = Download.download_url client ~file_path:"photos/file_0.jpg"
    ]} *)

val download_url_from_info : Telegram.Client.t -> file_info -> string option
(** Build download URL from file_info (returns None if file_path is missing) *)

(** {1 Streaming Downloads} *)

val to_buffer :
  Telegram.Client.t ->
  file_path:string ->
  Buffer.t ->
  (int64, Telegram.Error.t) result
(** Stream file contents to a buffer.

    Returns the number of bytes written on success.
    Does not load entire file into memory before writing - streams incrementally.

    Example:
    {[
      let buf = Buffer.create 4096 in
      match Download.to_buffer client ~file_path buf with
      | Ok bytes -> Printf.printf "Downloaded %Ld bytes\n" bytes
      | Error e -> Printf.eprintf "Error: %a\n" Telegram.Error.pp e
    ]} *)

val to_string : Telegram.Client.t -> file_path:string -> (string, Telegram.Error.t) result
(** Download file contents as a string.

    Warning: Loads entire file into memory. Use to_sink for large files.

    Example:
    {[
      match Download.to_string client ~file_path with
      | Ok contents -> Printf.printf "Got %d bytes\n" (String.length contents)
      | Error e -> Printf.eprintf "Error: %a\n" Telegram.Error.pp e
    ]} *)

(** {1 Combined Operations} *)

val get_and_download :
  Telegram.Client.t ->
  file_id:string ->
  Buffer.t ->
  (int64, Telegram.Error.t) result
(** Convenience function: get file info and download in one call.

    Equivalent to calling get_file followed by to_buffer.
    Returns Error if file_path is missing from the File response.

    Example:
    {[
      let buf = Buffer.create 4096 in
      match Download.get_and_download client ~file_id buf with
      | Ok bytes -> Printf.printf "Downloaded %Ld bytes\n" bytes
      | Error e -> Printf.eprintf "Error: %a\n" Telegram.Error.pp e
    ]} *)

val get_and_download_string :
  Telegram.Client.t ->
  file_id:string ->
  (string, Telegram.Error.t) result
(** Convenience function: get file info and download as string.

    Warning: Loads entire file into memory. Use get_and_download for large files. *)
