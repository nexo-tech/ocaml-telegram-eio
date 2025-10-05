type response_parameters = {
  migrate_to_chat_id : Id.Chat.k Id.t option;
  retry_after : int option;
}

type t =
  | Http_error of int * string
  | Api_error of { code : int; description : string; parameters : response_parameters option }
  | Decode_error of string
  | Timeout
  | Canceled
  | Not_implemented of string

let pp fmt = function
  | Http_error (c, b) -> Format.fprintf fmt "Http(%d): %s" c b
  | Api_error { code; description; parameters } ->
      (match parameters with
       | None -> Format.fprintf fmt "Api(%d): %s" code description
       | Some { retry_after; migrate_to_chat_id } ->
           Format.fprintf fmt "Api(%d): %s%s%s"
             code description
             (match retry_after with None -> "" | Some s -> Format.asprintf ", retry_after=%d" s)
             (match migrate_to_chat_id with None -> "" | Some cid -> Format.asprintf ", migrate_to_chat_id=%a" Id.pp cid))
  | Decode_error s -> Format.fprintf fmt "Decode: %s" s
  | Timeout -> Format.pp_print_string fmt "Timeout"
  | Canceled -> Format.pp_print_string fmt "Canceled"
  | Not_implemented s -> Format.fprintf fmt "Not_implemented: %s" s

let is_retryable = function
  | Http_error (code, _) -> code = 429 || (code >= 500 && code < 600)
  | Api_error { code; _ } -> code = 429 || (code >= 500 && code < 600)
  | Timeout -> true
  | Canceled -> false
  | Decode_error _ -> false
  | Not_implemented _ -> false

let retry_after = function
  | Api_error { parameters = Some { retry_after; _ }; _ } -> retry_after
  | _ -> None

let parameters = function
  | Api_error { parameters; _ } -> parameters
  | _ -> None

let or_fail = function
  | Ok x -> x
  | Error e -> failwith (Format.asprintf "%a" pp e)
