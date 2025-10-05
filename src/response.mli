(* Response parsing and error mapping for Telegram Bot API.

   This module provides a centralized, type-safe way to parse Telegram API
   responses, handling both success and error cases with proper error mapping.

   The Telegram Bot API returns responses in the following format:

   Success:
   {
     "ok": true,
     "result": <result_data>
   }

   Error:
   {
     "ok": false,
     "error_code": 400,
     "description": "Bad Request: message text is empty",
     "parameters": {
       "retry_after": 30,              // optional, for rate limiting
       "migrate_to_chat_id": 123456    // optional, for group migrations
     }
   }

   Example usage:

     let open Response in
     parse_json response_body
     |> bind_result (fun result_json ->
         User.of_yojson result_json
         |> Result.map_error (fun msg -> Error.Decode_error msg))
*)

(** Parse a JSON response body into a result.
    Returns Ok with the "result" field on success,
    or Error with a properly mapped error on failure. *)
val parse_json : string -> (Yojson.Safe.t, Error.t) result

(** Parse a JSON response and decode the result using the provided decoder.
    This is a convenience function that combines parse_json with a decoder.
    The decoder should return Error msg on failure, which will be wrapped
    in Error.Decode_error. *)
val parse_and_decode :
  string ->
  (Yojson.Safe.t -> ('a, string) result) ->
  ('a, Error.t) result

(** Lower-level function: parse already-parsed JSON into a result. *)
val of_yojson : Yojson.Safe.t -> (Yojson.Safe.t, Error.t) result

(** Extract error information from a Telegram error response JSON. *)
val extract_error : Yojson.Safe.t -> Error.t

(** Bind a result decoder over a successful response.
    The decoder receives the result JSON and returns either Ok value
    or Error with an Error.t (typically Decode_error). *)
val bind_result :
  (Yojson.Safe.t -> ('a, Error.t) result) ->
  (Yojson.Safe.t, Error.t) result ->
  ('a, Error.t) result
