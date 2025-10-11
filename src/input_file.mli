(* InputFile type for Telegram Bot API file uploads.

   The Telegram Bot API supports three ways to pass files:
   1. file_id - A file that already exists on Telegram servers
   2. URL - An HTTP URL for Telegram to download
   3. Upload - A new file to upload (multipart/form-data)

   This module provides an elegant, type-safe API for all three methods.

   Example usage:

     (* Reference existing file *)
     let photo = InputFile.file_id "AgACAgIAAxkBAAIC..." in

     (* Download from URL *)
     let photo = InputFile.url "https://example.com/photo.jpg" in

     (* Upload local file *)
     let photo = InputFile.path "/path/to/photo.jpg" in

     (* Upload with custom filename and mime type *)
     let doc = InputFile.upload
       ~filename:"report.pdf"
       ~mime_type:"application/pdf"
       "/path/to/report.pdf" in

     (* Use in API calls *)
     Gen_methods.send_photo client ~chat_id ~photo ()
*)

type t

(** Reference a file that already exists on Telegram servers.
    The file_id is obtained from previous API responses. *)
val file_id : string -> t

(** Reference a file via HTTP URL.
    Telegram will download the file from the given URL.
    The URL must be publicly accessible. *)
val url : string -> t

(** Upload a file from a local path.
    Uses the basename of the path as the filename and guesses mime type.

    Example: `path "/photos/cat.jpg"` → filename="cat.jpg", mime="image/jpeg"
*)
val path : string -> t

(** Alias for [path]. Commonly used in documentation examples. *)
val file : string -> t

(** Upload a file with explicit filename and optional mime type.
    Provides full control over the upload parameters.

    @param filename The filename to use (e.g., "document.pdf")
    @param mime_type Optional MIME type (e.g., "application/pdf")
    @param path Local filesystem path to the file
*)
val upload : filename:string -> ?mime_type:string -> string -> t

(** Convert InputFile to a JSON-safe string representation.
    - file_id: returns the file_id string
    - url: returns the URL string
    - upload: returns a placeholder (actual file data handled separately)

    This is used for JSON encoding of the field value.
*)
val to_string : t -> string

(** Check if this InputFile represents an upload (requires multipart encoding). *)
val is_upload : t -> bool

(** Extract multipart part for upload.
    Returns None for file_id and url.
    Returns Some (field_name, filename, mime_type option, path) for uploads.
*)
val to_multipart_part : field_name:string -> t -> (string * string * string option * string) option

(** Pretty printer for debugging. *)
val pp : t Fmt.t
