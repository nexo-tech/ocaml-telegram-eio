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
}

(** Create a polling configuration with custom parameters.
    All parameters are optional with sensible defaults. *)
val make :
  ?timeout:int ->
  ?limit:int ->
  ?allowed_updates:string list ->
  ?on_error:(Telegram.Error.t -> unit) ->
  unit ->
  config

(** Default polling configuration.
    - timeout: 30 seconds
    - limit: 100 updates
    - allowed_updates: all types
    - on_error: ignore errors *)
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
