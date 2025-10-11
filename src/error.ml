module Log = Log.Make (Log.Console) (struct
  let src = "Error"
  let level = Log.Info
end)

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
  | Internal_error of string

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
  | Internal_error s -> Format.fprintf fmt "Internal_error: %s" s

let is_retryable err =
  let retryable = match err with
    | Http_error (code, _) -> code = 429 || (code >= 500 && code < 600)
    | Api_error { code; _ } -> code = 429 || (code >= 500 && code < 600)
    | Timeout -> true
    | Canceled -> false
    | Decode_error _ -> false
    | Not_implemented _ -> false
    | Internal_error _ -> false
  in

  Log.debug' (fun () ->
    Format.asprintf "is_retryable decision: %a -> %b" pp err retryable
  );

  (match err with
   | Http_error (code, _) when retryable ->
       Log.warn "Retryable HTTP error detected: code=%d" code
   | Api_error { code; description; parameters } when retryable ->
       (match parameters with
        | Some { retry_after = Some seconds; _ } ->
            Log.warn "Retryable API error detected: code=%d, description=%s, retry_after=%ds"
              code description seconds
        | _ ->
            Log.warn "Retryable API error detected: code=%d, description=%s" code description)
   | Timeout when retryable ->
       Log.warn "Retryable timeout detected"
   | _ when not retryable ->
       Log.info "Non-retryable error: %a" pp err
   | _ -> ());

  retryable

let retry_after err =
  let result = match err with
    | Api_error { parameters = Some { retry_after; _ }; _ } -> retry_after
    | _ -> None
  in
  Log.debug' (fun () ->
    match result with
    | Some seconds -> Format.asprintf "Extracted retry_after: %d seconds" seconds
    | None -> "No retry_after in error"
  );
  result

let parameters err =
  let result = match err with
    | Api_error { parameters; _ } -> parameters
    | _ -> None
  in
  Log.debug' (fun () ->
    match result with
    | Some { retry_after; migrate_to_chat_id } ->
        Format.asprintf "Extracted parameters: retry_after=%s, migrate_to_chat_id=%s"
          (match retry_after with Some s -> string_of_int s | None -> "none")
          (match migrate_to_chat_id with Some cid -> Id.to_string cid | None -> "none")
    | None -> "No parameters in error"
  );
  result

let or_fail = function
  | Ok x -> x
  | Error e -> failwith (Format.asprintf "%a" pp e)
