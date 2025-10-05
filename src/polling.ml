(** Long polling implementation for Telegram Bot API. *)

open Telegram

type offset_storage = {
  load : unit -> int64 option;
  save : int64 -> unit;
}

type config = {
  timeout : int;
  limit : int;
  allowed_updates : string list option;
  on_error : (Error.t -> unit) option;
  offset_storage : offset_storage option;
  dedup_window : int;
}

let make ?(timeout = 30) ?(limit = 100) ?allowed_updates ?on_error ?offset_storage ?(dedup_window = 0) () =
  let limit = min limit 100 in (* Telegram API max is 100 *)
  { timeout; limit; allowed_updates; on_error; offset_storage; dedup_window }

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

(* Internal: deduplication window using a circular buffer of update_ids *)
module Dedup_window = struct
  type t = {
    size : int;
    buffer : int64 array;
    mutable pos : int;
    mutable count : int;
  }

  let create size =
    if size <= 0 then
      { size = 0; buffer = [||]; pos = 0; count = 0 }
    else
      { size; buffer = Array.make size 0L; pos = 0; count = 0 }

  let mem window update_id =
    if window.size = 0 then false
    else
      let rec check i remaining =
        if remaining <= 0 then false
        else if window.buffer.(i) = update_id then true
        else check ((i + 1) mod window.size) (remaining - 1)
      in
      check 0 window.count

  let add window update_id =
    if window.size > 0 then (
      window.buffer.(window.pos) <- update_id;
      window.pos <- (window.pos + 1) mod window.size;
      window.count <- min (window.count + 1) window.size
    )
end

(* Internal: extract update_id from Update.t *)
let get_update_id update =
  let module U = Telegram_generated.Gen_types.Update in
  let json = U.to_yojson update in
  match json with
  | `Assoc fields ->
      (match List.assoc_opt "update_id" fields with
       | Some (`Intlit s) -> Some (Int64.of_string s)
       | Some (`Int i) -> Some (Int64.of_int i)
       | _ -> None)
  | _ -> None

(* Internal: process a batch of updates with deduplication *)
let process_updates updates ~handler ~on_error ~dedup_window =
  List.iter (fun update ->
    match get_update_id update with
    | None ->
        (* No update_id found - shouldn't happen but process anyway *)
        (try handler update
         with exn ->
           let err = Error.Decode_error ("Handler exception: " ^ Printexc.to_string exn) in
           (match on_error with
            | Some f -> f err
            | None -> ()))
    | Some update_id ->
        (* Check if already seen *)
        if Dedup_window.mem dedup_window update_id then
          () (* Skip duplicate *)
        else (
          (* Mark as seen *)
          Dedup_window.add dedup_window update_id;
          (* Process update *)
          try handler update
          with exn ->
            let err = Error.Decode_error ("Handler exception: " ^ Printexc.to_string exn) in
            (match on_error with
             | Some f -> f err
             | None -> ())
        )
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

(* Internal: main polling loop with graceful shutdown *)
let rec polling_loop client config ~handler ~offset ~should_stop ~dedup_window =
  (* Fetch updates first, then check shutdown - this ensures in-flight updates are processed *)
  match get_updates client ~offset config with
  | Error err ->
      (* Check if we should stop before handling error *)
      if should_stop () then
        () (* Graceful shutdown - don't retry on errors during shutdown *)
      else (
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

        polling_loop client config ~handler ~offset ~should_stop ~dedup_window
      )

  | Ok updates ->
      (* Process updates with deduplication - always process fetched updates even during shutdown *)
      process_updates updates ~handler ~on_error:config.on_error ~dedup_window;

      (* Calculate next offset *)
      let new_offset = next_offset updates offset in

      (* Save offset if persistence is enabled *)
      (match config.offset_storage with
       | Some storage -> storage.save new_offset
       | None -> ());

      (* Check if we should stop AFTER processing updates *)
      if should_stop () then
        () (* Graceful shutdown - all fetched updates have been processed *)
      else
        (* Continue polling *)
        polling_loop client config ~handler ~offset:new_offset ~should_stop ~dedup_window

let run_with_config_and_switch client config sw ~handler =
  (* Use switch to detect cancellation *)
  let cancelled = ref false in
  Eio.Switch.on_release sw (fun () -> cancelled := true);

  let should_stop () = !cancelled in

  (* Load initial offset from storage or use 0 *)
  let initial_offset =
    match config.offset_storage with
    | Some storage -> (match storage.load () with Some o -> o | None -> 0L)
    | None -> 0L
  in

  (* Create deduplication window *)
  let dedup_window = Dedup_window.create config.dedup_window in

  polling_loop client config ~handler ~offset:initial_offset ~should_stop ~dedup_window

let run_with_config client config ~handler =
  (* Run without cancellation support *)
  let should_stop () = false in

  (* Load initial offset from storage or use 0 *)
  let initial_offset =
    match config.offset_storage with
    | Some storage -> (match storage.load () with Some o -> o | None -> 0L)
    | None -> 0L
  in

  (* Create deduplication window *)
  let dedup_window = Dedup_window.create config.dedup_window in

  polling_loop client config ~handler ~offset:initial_offset ~should_stop ~dedup_window

let run_with_switch client sw ~handler =
  run_with_config_and_switch client default sw ~handler

let run client ~handler =
  run_with_config client default ~handler
