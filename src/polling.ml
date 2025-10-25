(** Long polling implementation for Telegram Bot API with scoped logging *)

open Telegram

(** Scoped logger for polling operations *)
module Log = Flo_scoped.Make(struct
  let namespace = "telegram.polling"
end)

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
                  | Error msg ->
                      (* Warn level: validation errors (visible by default) *)
                      let json_str = Yojson.Safe.to_string update_json in
                      let preview = if String.length json_str > 500
                        then String.sub json_str 0 500 ^ "..."
                        else json_str in
                      Log.warnf "Failed to decode Update: %s" msg;
                      Log.debugf "Problematic JSON: %s" preview;
                      Error (Error.Decode_error msg))
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
      let seen_before = check 0 window.count in
      (* Debug level: deduplication details (hidden by default) *)
      Log.tracef "Deduplication check: update_id=%Ld, seen_before=%b" update_id seen_before;
      if seen_before then
        (* Warn level: duplicate detection (visible by default) *)
        Log.warnf "Duplicate update detected: update_id=%Ld" update_id;
      seen_before

  let add window update_id =
    if window.size > 0 then (
      window.buffer.(window.pos) <- update_id;
      window.pos <- (window.pos + 1) mod window.size;
      window.count <- min (window.count + 1) window.size;

      let oldest_id = if window.count > 0 then
        window.buffer.((window.pos - window.count + window.size) mod window.size)
      else 0L in
      (* Trace level: internal state details (hidden by default) *)
      Log.tracef "Deduplication window state: size=%d, oldest_id=%Ld" window.count oldest_id
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
        (* Debug level: update processing details (hidden by default) *)
        Log.debug "Processing update: update_id=none (malformed)";
        (try handler update
         with exn ->
           let err = Error.Decode_error ("Handler exception: " ^ Printexc.to_string exn) in
           (match on_error with
            | Some f -> f err
            | None -> ()))
    | Some update_id ->
        let module U = Telegram_generated.Gen_types.Update in
        let json = U.to_yojson update in
        let update_type = match json with
          | `Assoc fields ->
              let types = ["message"; "edited_message"; "channel_post"; "edited_channel_post";
                          "inline_query"; "chosen_inline_result"; "callback_query"; "shipping_query";
                          "pre_checkout_query"; "poll"; "poll_answer"; "my_chat_member"; "chat_member";
                          "chat_join_request"] in
              List.find_opt (fun t -> List.mem_assoc t fields) types
              |> Option.value ~default:"unknown"
          | _ -> "unknown"
        in
        (* Trace level: detailed update info (hidden by default) *)
        Log.tracef "Each update received: update_id=%Ld, type=%s" update_id update_type;

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
  | [] ->
      (* Trace level: internal state details (hidden by default) *)
      Log.tracef "Offset calculation: no updates, keeping offset=%Ld" current_offset;
      current_offset
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
      let new_offset = Int64.add max_id 1L in
      (* Trace level: internal state details (hidden by default) *)
      Log.tracef "Offset calculation and update: previous=%Ld, max_update_id=%Ld, next=%Ld"
        current_offset max_id new_offset;
      new_offset

(* Internal: main polling loop with graceful shutdown *)
let rec polling_loop client config ~handler ~offset ~should_stop ~dedup_window =
  (* Check for shutdown signal *)
  if should_stop () then (
    (* Debug level: internal state transitions (hidden by default) *)
    Log.debug "Shutdown signal received";
    (* Info level: lifecycle event (visible by default) *)
    Log.info "Graceful shutdown initiated";
    () (* Exit polling loop immediately *)
  ) else (
    (* Fetch updates first, then check shutdown - this ensures in-flight updates are processed *)
    match get_updates client ~offset config with
    | Error err ->
        (* Warn level: recoverable errors (visible by default) *)
        Log.warn_fields "getUpdates error (will retry)" ~fields:[
          Flo_semconv.error_message (Format.asprintf "%a" Error.pp err);
        ];

        (* Check if we should stop before handling error *)
        if should_stop () then (
          (* Info level: lifecycle event (visible by default) *)
          Log.info "Shutdown during error handling";
          () (* Graceful shutdown - don't retry on errors during shutdown *)
        ) else (
          (* Handle error *)
          (match config.on_error with
           | Some f -> f err
           | None -> ());

          (* Continue polling after a brief delay on errors *)
          (match err with
           | Error.Api_error { code = 429; parameters = Some { retry_after = Some delay; _ }; _ } ->
               (* Warn level: rate limiting (visible by default) *)
               Log.warnf "Rate limited: waiting %ds before retry" delay;
               (* Rate limited: respect retry_after *)
               Eio.Time.sleep (Client.env client)#clock (float_of_int delay)
           | Error.Timeout ->
               (* Debug level: expected timeouts in long polling (hidden by default) *)
               Log.debug "Long polling timeout (expected, continuing)"
           | Error.Http_error _ | Error.Decode_error _ ->
               (* HTTP or decode error: brief delay before retry *)
               Eio.Time.sleep (Client.env client)#clock 1.0
           | _ ->
               (* Other errors: brief delay *)
               Eio.Time.sleep (Client.env client)#clock 1.0);

          polling_loop client config ~handler ~offset ~should_stop ~dedup_window
        )

  | Ok updates ->
      let open Flo in
      (* Debug level: update fetching details (hidden by default) *)
      let count = List.length updates in
      if count > 0 then (
        let update_ids = List.filter_map get_update_id updates in
        let ids_str = String.concat ", " (List.map Int64.to_string update_ids) in
        Log.debug_fields "Received updates" ~fields:[
          ("count", Value.int count);
          ("update_ids", Value.string ids_str);
        ]
      );

      (* Process updates with deduplication - always process fetched updates even during shutdown *)
      if should_stop () && count > 0 then
        (* Info level: shutdown handling (visible by default) *)
        Log.infof "Processing in-flight updates before shutdown: count=%d" count;

      process_updates updates ~handler ~on_error:config.on_error ~dedup_window;

      if should_stop () && count > 0 then
        (* Debug level: internal state (hidden by default) *)
        Log.debugf "Update queue drained: processed %d updates" count;

      (* Calculate next offset *)
      let new_offset = next_offset updates offset in

      (* Save offset if persistence is enabled *)
      (match config.offset_storage with
       | Some storage ->
           (* Trace level: storage operations (hidden by default) *)
           Log.tracef "Storage operation: saving offset=%Ld" new_offset;
           storage.save new_offset;
           (* Debug level: storage confirmation (hidden by default) *)
           Log.debug_fields "Offset saved to storage" ~fields:[
             ("offset", Value.int64 new_offset);
           ]
       | None -> ());

      (* Check if we should stop AFTER processing updates *)
      if should_stop () then (
        (* Info level: lifecycle event (visible by default) *)
        Log.info "Shutdown complete";
        () (* Graceful shutdown - all fetched updates have been processed *)
      ) else
        (* Continue polling *)
        polling_loop client config ~handler ~offset:new_offset ~should_stop ~dedup_window
  )

let run_with_config_and_switch client config sw ~handler =
  (* Use switch to detect cancellation *)
  let cancelled = ref false in
  Eio.Switch.on_release sw (fun () -> cancelled := true);

  let should_stop () = !cancelled in

  (* Load initial offset from storage or use 0 *)
  let initial_offset =
    match config.offset_storage with
    | Some storage ->
        (* Debug level: storage operations (hidden by default) *)
        Log.debug "Storage operation: loading offset";
        (match storage.load () with
         | Some o ->
             let open Flo in
             (* Debug level: storage confirmation (hidden by default) *)
             Log.debug_fields "Offset loaded from storage" ~fields:[
               ("offset", Value.int64 o);
             ];
             o
         | None ->
             (* Warn level: storage issues (visible by default) *)
             Log.warn "Failed to load offset (using default): offset=0";
             0L)
    | None -> 0L
  in

  (* Create deduplication window *)
  let dedup_window = Dedup_window.create config.dedup_window in

  let open Flo in
  (* Info level: lifecycle event (visible by default) *)
  Log.info_fields "Long polling started" ~fields:[
    ("timeout", Value.int config.timeout);
    ("offset", Value.int64 initial_offset);
  ];

  polling_loop client config ~handler ~offset:initial_offset ~should_stop ~dedup_window

let run_with_config client config ~handler =
  (* Run without cancellation support *)
  let should_stop () = false in

  (* Load initial offset from storage or use 0 *)
  let initial_offset =
    match config.offset_storage with
    | Some storage ->
        (* Debug level: storage operations (hidden by default) *)
        Log.debug "Storage operation: loading offset";
        (match storage.load () with
         | Some o ->
             let open Flo in
             (* Debug level: storage confirmation (hidden by default) *)
             Log.debug_fields "Offset loaded from storage" ~fields:[
               ("offset", Value.int64 o);
             ];
             o
         | None ->
             (* Warn level: storage issues (visible by default) *)
             Log.warn "Failed to load offset (using default): offset=0";
             0L)
    | None -> 0L
  in

  (* Create deduplication window *)
  let dedup_window = Dedup_window.create config.dedup_window in

  let open Flo in
  (* Info level: lifecycle event (visible by default) *)
  Log.info_fields "Long polling started" ~fields:[
    ("timeout", Value.int config.timeout);
    ("offset", Value.int64 initial_offset);
  ];

  polling_loop client config ~handler ~offset:initial_offset ~should_stop ~dedup_window

let run_with_switch client sw ~handler =
  run_with_config_and_switch client default sw ~handler

let run client ~handler =
  run_with_config client default ~handler
