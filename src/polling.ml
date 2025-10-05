(** Long polling implementation for Telegram Bot API. *)

open Telegram

type config = {
  timeout : int;
  limit : int;
  allowed_updates : string list option;
  on_error : (Error.t -> unit) option;
}

let make ?(timeout = 30) ?(limit = 100) ?allowed_updates ?on_error () =
  let limit = min limit 100 in (* Telegram API max is 100 *)
  { timeout; limit; allowed_updates; on_error }

let default = make ()

(* Internal: call getUpdates with offset and config *)
let get_updates client ~offset config =
  let params = [
    ("offset", Param.int64 offset);
    ("timeout", Param.int (config.timeout));
    ("limit", Param.int (config.limit));
  ] @ (match config.allowed_updates with
       | None -> []
       | Some updates -> [("allowed_updates", Param.list (List.map Param.string updates))])
  in

  match Api.call_method client ~method_name:"getUpdates" params with
  | Error err -> Error err
  | Ok json ->
      (* Parse the result as array of Updates *)
      (match json with
       | `List updates_json ->
           (* Decode each update *)
           let rec decode_updates acc = function
             | [] -> Ok (List.rev acc)
             | update_json :: rest ->
                 (match Telegram_generated.Gen_types.Update.of_yojson update_json with
                  | Ok update -> decode_updates (update :: acc) rest
                  | Error msg -> Error (Error.Decode_error msg))
           in
           decode_updates [] updates_json
       | _ -> Error (Error.Decode_error "Expected array of updates"))

(* Internal: process a batch of updates *)
let process_updates updates ~handler ~on_error =
  List.iter (fun update ->
    try
      handler update
    with exn ->
      (* Catch handler exceptions to prevent polling loop from crashing *)
      let err = Error.Decode_error ("Handler exception: " ^ Printexc.to_string exn) in
      (match on_error with
       | Some f -> f err
       | None -> ())
  ) updates

(* Internal: compute next offset from updates *)
let next_offset updates current_offset =
  match updates with
  | [] -> current_offset
  | _ ->
      (* Get the highest update_id and add 1 *)
      let module U = Telegram_generated.Gen_types.Update in
      let max_id = List.fold_left (fun acc update ->
        (* Access update_id - we extract it from JSON roundtrip *)
        let json = U.to_yojson update in
        match json with
        | `Assoc fields ->
            (match List.assoc_opt "update_id" fields with
             | Some (`Intlit s) -> Int64.max acc (Int64.of_string s)
             | Some (`Int i) -> Int64.max acc (Int64.of_int i)
             | _ -> acc)
        | _ -> acc
      ) 0L updates in
      Int64.add max_id 1L

(* Internal: main polling loop *)
let rec polling_loop client config ~handler ~offset ~should_stop =
  if should_stop () then
    () (* Graceful shutdown *)
  else
    match get_updates client ~offset config with
    | Error err ->
        (* Handle error *)
        (match config.on_error with
         | Some f -> f err
         | None -> ());

        (* Continue polling after a brief delay on errors *)
        (match err with
         | Error.Api_error { code = 429; parameters = Some { retry_after = Some delay; _ }; _ } ->
             (* Rate limited: respect retry_after *)
             Eio.Time.sleep (Client.env client)#clock (float_of_int delay)
         | Error.Timeout ->
             (* Timeout is expected in long polling, just continue *)
             ()
         | Error.Http_error _ | Error.Decode_error _ ->
             (* HTTP or decode error: brief delay before retry *)
             Eio.Time.sleep (Client.env client)#clock 1.0
         | _ ->
             (* Other errors: brief delay *)
             Eio.Time.sleep (Client.env client)#clock 1.0);

        polling_loop client config ~handler ~offset ~should_stop

    | Ok updates ->
        (* Process updates *)
        process_updates updates ~handler ~on_error:config.on_error;

        (* Calculate next offset *)
        let new_offset = next_offset updates offset in

        (* Continue polling *)
        polling_loop client config ~handler ~offset:new_offset ~should_stop

let run_with_config_and_switch client config sw ~handler =
  (* Use switch to detect cancellation *)
  let cancelled = ref false in
  Eio.Switch.on_release sw (fun () -> cancelled := true);

  let should_stop () = !cancelled in
  polling_loop client config ~handler ~offset:0L ~should_stop

let run_with_config client config ~handler =
  (* Run without cancellation support *)
  let should_stop () = false in
  polling_loop client config ~handler ~offset:0L ~should_stop

let run_with_switch client sw ~handler =
  run_with_config_and_switch client default sw ~handler

let run client ~handler =
  run_with_config client default ~handler
