(** Resource limits and policies for uploads/downloads *)

(** {1 File Size Limits} *)

type size_limit =
  | Unlimited
  | Max_bytes of int64
  | Max_mb of int

let size_limit_bytes = function
  | Unlimited -> None
  | Max_bytes n -> Some n
  | Max_mb mb -> Some (Int64.mul (Int64.of_int mb) 1_048_576L)

let check_size limit size =
  match size_limit_bytes limit with
  | None -> Ok ()
  | Some max_bytes ->
      if size <= max_bytes then Ok ()
      else Error (Printf.sprintf "Size %Ld exceeds limit %Ld" size max_bytes)

(** {1 Policy Configuration} *)

type t = {
  max_upload_size : size_limit;
  max_download_size : size_limit;
  temp_dir : string option;
  request_timeout : float option;
  chunk_size : int;
}

let default = {
  max_upload_size = Unlimited;
  max_download_size = Unlimited;
  temp_dir = None;
  request_timeout = None;
  chunk_size = 16384;
}

let telegram_limits = {
  max_upload_size = Max_mb 50;
  max_download_size = Max_mb 20;
  temp_dir = None;
  request_timeout = Some 60.0;
  chunk_size = 16384;
}

(** {1 Policy Builders} *)

let with_max_upload mb t =
  { t with max_upload_size = Max_mb mb }

let with_max_download mb t =
  { t with max_download_size = Max_mb mb }

let with_temp_dir dir t =
  { t with temp_dir = Some dir }

let with_timeout timeout t =
  { t with request_timeout = Some timeout }

let with_chunk_size size t =
  { t with chunk_size = size }

(** {1 Policy Application} *)

let check_upload_size t size =
  check_size t.max_upload_size size

let check_download_size t size =
  check_size t.max_download_size size

let get_temp_dir t =
  match t.temp_dir with
  | Some dir -> dir
  | None -> Filename.get_temp_dir_name ()

let get_chunk_size t = t.chunk_size
