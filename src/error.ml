open Flo

(* Scoped logger for error analysis *)
module Log = Flo_scoped.Make(struct
  let namespace = "telegram.error"
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

  Log.trace_fields "is_retryable decision" ~fields:[
    Flo_semconv.error_message (Format.asprintf "%a" pp err);
    ("retryable", Value.bool retryable);
  ];

  (match err with
   | Http_error (code, _) when retryable ->
       Log.debug_fields "Retryable HTTP error detected" ~fields:[
         Flo_semconv.http_status_code code;
         Flo_semconv.error_type "HttpError";
         ("retryable", Value.bool true);
       ]
   | Api_error { code; description; parameters } when retryable ->
       (match parameters with
        | Some { retry_after = Some seconds; _ } ->
            Log.debug_fields "Retryable API error with retry_after" ~fields:[
              Flo_telegram.api_error_code code;
              Flo_telegram.api_error_description description;
              ("retry_after_seconds", Value.int seconds);
              ("retryable", Value.bool true);
            ]
        | _ ->
            Log.debug_fields "Retryable API error detected" ~fields:[
              Flo_telegram.api_error_code code;
              Flo_telegram.api_error_description description;
              ("retryable", Value.bool true);
            ])
   | Timeout when retryable ->
       Log.debug "Retryable timeout detected"
   | _ when not retryable ->
       Log.trace_fields "Non-retryable error" ~fields:[
         Flo_semconv.error_message (Format.asprintf "%a" pp err);
       ]
   | _ -> ());

  retryable

let retry_after err =
  let result = match err with
    | Api_error { parameters = Some { retry_after; _ }; _ } -> retry_after
    | _ -> None
  in
  (match result with
   | Some seconds ->
       Log.trace_fields "Extracted retry_after" ~fields:[
         ("retry_after_seconds", Value.int seconds);
       ]
   | None -> Log.trace "No retry_after in error");
  result

let parameters err =
  let result = match err with
    | Api_error { parameters; _ } -> parameters
    | _ -> None
  in
  (match result with
   | Some { retry_after; migrate_to_chat_id } ->
       Log.trace_fields "Extracted parameters" ~fields:[
         ("retry_after", Value.string (match retry_after with Some s -> string_of_int s | None -> "none"));
         ("migrate_to_chat_id", Value.string (match migrate_to_chat_id with Some cid -> Id.to_string cid | None -> "none"));
       ]
   | None -> Log.trace "No parameters in error");
  result

let or_fail = function
  | Ok x -> x
  | Error e -> failwith (Format.asprintf "%a" pp e)
