(** Long polling for Telegram Bot API updates.

    This module provides an elegant, functional interface for receiving updates
    via long polling. It handles offset management, error recovery, and graceful
    shutdown automatically.

    {1 Basic Usage}

    {[
      let handler update =
        match update.message with
        | Some msg -> Printf.printf "Got message: %Ld\n" msg.message_id
        | None -> ()
      in

      Polling.run client ~handler
    ]}

    {1 Advanced Usage}

    {[
      let config = Polling.make
        ~timeout:30
        ~limit:100
        ~allowed_updates:["message"; "callback_query"]
        ~on_error:(fun err -> Logs.warn (fun m -> m "Error: %a" Error.pp err))
        ()
      in

      Polling.run_with_config client config ~handler
    ]}
*)

(** Offset persistence hook for resuming after restart.

    Implement this to persist the last processed offset to disk, database,
    or any other storage mechanism. This enables graceful restarts without
    losing or reprocessing updates.

    {[
      let persist_offset offset =
        (* Save to file, Redis, database, etc. *)
        let oc = open_out "bot_offset.txt" in
        output_string oc (Int64.to_string offset);
        close_out oc
      in

      let load_offset () =
        try
          let ic = open_in "bot_offset.txt" in
          let offset = Int64.of_string (input_line ic) in
          close_in ic;
          Some offset
        with _ -> None
    ]}
*)
type offset_storage = {
  load : unit -> int64 option;
    (** Load the last processed offset from storage.
        Return None if no offset is stored (first run). *)
  save : int64 -> unit;
    (** Save the current offset after processing updates.
        Called after each successful batch. *)
}

(** Configuration for long polling. *)
type config = {
  timeout : int;
    (** Long poll timeout in seconds (default: 30).
        How long to wait for new updates before returning. *)
  limit : int;
    (** Maximum number of updates to fetch at once (default: 100, max: 100). *)
  allowed_updates : string list option;
    (** List of update types to receive (default: all types).
        Examples: ["message", "callback_query", "inline_query"] *)
  on_error : (Telegram.Error.t -> unit) option;
    (** Optional callback for handling errors (default: ignore errors). *)
  offset_storage : offset_storage option;
    (** Optional offset persistence for resuming after restart (default: None).
        When provided, the offset is automatically saved after each batch
        and loaded on startup. This prevents reprocessing updates after restart. *)
  dedup_window : int;
    (** Deduplication window size (default: 0 = disabled).
        When > 0, maintains a sliding window of the last N update_ids to detect
        and skip duplicate updates. Useful for at-least-once delivery guarantees.
        Recommended: 100-1000 depending on update frequency. *)
}

(** Create a polling configuration with custom parameters.
    All parameters are optional with sensible defaults. *)
val make :
  ?timeout:int ->
  ?limit:int ->
  ?allowed_updates:string list ->
  ?on_error:(Telegram.Error.t -> unit) ->
  ?offset_storage:offset_storage ->
  ?dedup_window:int ->
  unit ->
  config

(** Default polling configuration.
    - timeout: 30 seconds
    - limit: 100 updates
    - allowed_updates: all types
    - on_error: ignore errors
    - offset_storage: None (no persistence)
    - dedup_window: 0 (no deduplication) *)
val default : config

(** Run long polling with default configuration.

    This is the simplest way to start receiving updates. The handler is called
    for each update received. The polling loop continues until the program is
    terminated or an unrecoverable error occurs.

    @param client The Telegram client
    @param handler Function called for each update
*)
val run :
  Telegram.Client.t ->
  handler:(Telegram_generated.Gen_types.Update.t -> unit) ->
  unit

(** Run long polling with custom configuration.

    Provides full control over polling parameters and error handling.

    @param client The Telegram client
    @param config Custom polling configuration
    @param handler Function called for each update
*)
val run_with_config :
  Telegram.Client.t ->
  config ->
  handler:(Telegram_generated.Gen_types.Update.t -> unit) ->
  unit

(** Run long polling with Eio-based cancellation support.

    This variant allows graceful shutdown by cancelling the Eio switch.
    The function returns when the switch is cancelled or an unrecoverable
    error occurs.

    {[
      Eio.Switch.run @@ fun sw ->
      Polling.run_with_switch client sw ~handler;
      (* Cancelling sw will stop the polling loop *)
    ]}

    @param client The Telegram client
    @param sw Eio switch for cancellation
    @param handler Function called for each update
*)
val run_with_switch :
  Telegram.Client.t ->
  Eio.Switch.t ->
  handler:(Telegram_generated.Gen_types.Update.t -> unit) ->
  unit

(** Run long polling with full control: custom config and switch.

    Combines custom configuration with Eio switch-based cancellation.

    @param client The Telegram client
    @param config Custom polling configuration
    @param sw Eio switch for cancellation
    @param handler Function called for each update
*)
val run_with_config_and_switch :
  Telegram.Client.t ->
  config ->
  Eio.Switch.t ->
  handler:(Telegram_generated.Gen_types.Update.t -> unit) ->
  unit

(** {1 Delivery Semantics and Idempotency}

    {2 At-Least-Once Delivery}

    Telegram's getUpdates API provides {b at-least-once delivery} semantics:
    - Updates may be delivered more than once in certain failure scenarios
    - Updates are never lost (unless they expire after 24 hours)
    - Order is guaranteed per chat, but not globally

    {2 Why Duplicates Happen}

    Duplicates can occur in several scenarios:
    1. {b Network failures}: Request succeeds but response is lost
    2. {b Process crashes}: Offset saved before processing completes
    3. {b Telegram retries}: Rare internal Telegram server retries

    {2 Deduplication Strategy}

    Enable deduplication to handle at-least-once semantics safely:

    {[
      let config = Polling.make
        ~dedup_window:1000  (* Track last 1000 update IDs *)
        ()
      in
      Polling.run_with_config client config ~handler
    ]}

    The deduplication window:
    - Maintains a sliding window of recently seen update_ids
    - Automatically skips updates that were already processed
    - Memory usage: ~8KB per 1000 updates (Int64 per update_id)
    - Recommended size: 100-1000 depending on update frequency

    {2 Offset Persistence}

    Persist offsets to resume gracefully after restarts:

    {[
      let storage = {
        Polling.load = (fun () ->
          try
            let ic = open_in "offset.txt" in
            let offset = Int64.of_string (input_line ic) in
            close_in ic;
            Some offset
          with _ -> None
        );
        save = (fun offset ->
          let oc = open_out "offset.txt" in
          output_string oc (Int64.to_string offset);
          close_out oc
        );
      } in

      let config = Polling.make
        ~offset_storage:storage
        ~dedup_window:1000  (* Still needed for crash scenarios *)
        ()
    ]}

    {b Important}: Even with offset persistence, use deduplication! If your process
    crashes between processing an update and saving the offset, the same update
    will be redelivered on restart.

    {2 Exactly-Once Processing}

    To achieve exactly-once semantics in your application:
    1. Enable deduplication in polling config
    2. Make your handler idempotent (safe to call multiple times)
    3. Use database transactions with unique constraints on update_id
    4. Consider distributed locks for critical operations

    Example idempotent handler:
    {[
      let handler db update =
        (* Extract update_id *)
        let update_id = get_update_id update in

        (* Use database transaction with unique constraint *)
        Database.transaction db @@ fun tx ->
        try
          Database.insert tx "processed_updates"
            ~values:["update_id", update_id];
          (* Process update - will only run once due to constraint *)
          process_update update
        with Database.Unique_violation ->
          (* Already processed, skip *)
          ()
    ]}

    {2 Offset Management}

    Offsets are managed automatically:
    - Initial offset: 0 (or loaded from offset_storage if provided)
    - After each batch: offset = max(update_ids) + 1
    - Telegram guarantees: offset N means "give me updates after N-1"

    The offset is advanced {b after} processing, ensuring at-least-once delivery.
    If processing fails, the same updates will be fetched again.

    {2 Best Practices}

    1. {b Production bots}: Enable both offset_storage and dedup_window
    2. {b Development/testing}: Use defaults (no persistence, no dedup)
    3. {b High-volume bots}: Increase dedup_window to 1000+
    4. {b Crash recovery}: Always use dedup_window, even with persistence
    5. {b Handler errors}: Don't throw exceptions - use on_error callback instead
*)

(** {1 Examples}

    {2 Simple Bot (Development)}

    {[
      Polling.run client ~handler:(fun update ->
        match update.message with
        | Some msg -> Printf.printf "Message: %s\n" msg.text
        | None -> ()
      )
    ]}

    {2 Production Bot with Persistence}

    {[
      let storage = {
        Polling.load = (fun () ->
          (* Load from Redis, database, file, etc. *)
          Database.query_one "SELECT offset FROM bot_state WHERE id = 1"
        );
        save = (fun offset ->
          (* Save to persistent storage *)
          Database.execute
            "INSERT INTO bot_state (id, offset) VALUES (1, ?)
             ON CONFLICT (id) DO UPDATE SET offset = ?"
            [offset; offset]
        );
      } in

      let config = Polling.make
        ~timeout:30
        ~dedup_window:1000
        ~offset_storage:storage
        ~on_error:(fun err ->
          Logs.err (fun m -> m "Polling error: %a" Error.pp err)
        )
        ()
      in

      Eio.Switch.run @@ fun sw ->
      Polling.run_with_config_and_switch client config sw ~handler
    ]}
*)
