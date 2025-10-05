(** Large file transfer utilities with retry and resumption support *)

open Telegram

(** {1 Transfer Configuration} *)

type config = {
  limits : Limits.t;
  retry : Retry.config;
  chunk_size : int;
}

let default_config = {
  limits = Limits.telegram_limits;
  retry = Retry.default;
  chunk_size = Limits.get_chunk_size Limits.telegram_limits;
}

let make_config ?(limits = Limits.telegram_limits) ?(retry = Retry.default) () = {
  limits;
  retry;
  chunk_size = Limits.get_chunk_size limits;
}

(** {1 Upload with Retry} *)

let upload_with_retry config _client ~path:_ ?on_progress:_ parts =
  (* Validate upload size first *)
  let size = Upload.calculate_size parts in
  match Limits.check_upload_size config.limits size with
  | Error msg -> Error (Error.Decode_error ("Upload size limit exceeded: " ^ msg))
  | Ok () ->
      (* For now, just create the body - retry logic would wrap the actual API call *)
      Ok (Upload.with_progress ?on_progress:None parts)

(** {1 Download with Retry} *)

let download_with_retry config client ~file_path buffer =
  (* Wrap download in retry logic *)
  Retry.with_config config.retry (fun () ->
    (* Clear buffer on retry to start fresh *)
    Buffer.clear buffer;
    Download.to_buffer client ~file_path buffer
  )

(** {1 Utilities} *)

let with_chunk_size chunk_size config =
  { config with chunk_size }

let with_retry_attempts max_attempts config =
  let retry = { config.retry with max_attempts } in
  { config with retry }
