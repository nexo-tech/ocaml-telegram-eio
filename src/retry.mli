(* Retry and backoff strategies for Telegram Bot API.

   This module provides elegant, composable retry strategies with support
   for exponential backoff, jitter, and respect for Telegram's retry_after hints.

   Example usage:

     let strategy = Retry.Strategy.exponential ~initial:1.0 ~max:30.0 () in
     Retry.with_strategy strategy @@ fun () ->
       Api.call client request
*)

(** Backoff strategy determines wait time between retries. *)
module Strategy : sig
  type t

  (** No backoff - immediately retry (not recommended for production). *)
  val immediate : t

  (** Fixed delay between retries. *)
  val fixed : float -> t

  (** Exponential backoff with optional max delay.
      Doubles the delay after each attempt: initial, initial*2, initial*4, ...

      @param initial Initial delay in seconds (default: 1.0)
      @param max Maximum delay in seconds (default: 60.0)
      @param multiplier Multiplier for exponential growth (default: 2.0)
  *)
  val exponential : ?initial:float -> ?max:float -> ?multiplier:float -> unit -> t

  (** Exponential backoff with jitter to avoid thundering herd.
      Adds random variance to exponential delays.

      @param jitter Amount of jitter (0.0 to 1.0, default: 0.1 means ±10%)
  *)
  val exponential_jitter : ?initial:float -> ?max:float -> ?jitter:float -> unit -> t

  (** Respect Telegram's retry_after hint, falling back to exponential.
      This is the recommended strategy for production use.
  *)
  val telegram_aware : ?fallback:t -> unit -> t

  (** Calculate the next delay given the current attempt number and optional error. *)
  val next_delay : t -> attempt:int -> error:Error.t option -> float
end

(** Retry configuration. *)
type config = {
  strategy : Strategy.t;
  max_attempts : int;  (** Maximum number of retry attempts (default: 3) *)
  on_retry : (attempt:int -> error:Error.t -> delay:float -> unit) option;
    (** Optional callback invoked before each retry *)
}

(** Default retry configuration with exponential backoff. *)
val default : config

(** Create a custom retry configuration. *)
val make :
  ?strategy:Strategy.t ->
  ?max_attempts:int ->
  ?on_retry:(attempt:int -> error:Error.t -> delay:float -> unit) ->
  unit ->
  config

(** Execute a function with retries according to the given configuration.
    Only retries on errors where Error.is_retryable returns true.

    Example:
      Retry.with_config config @@ fun () ->
        Api.call client request
*)
val with_config : config -> (unit -> ('a, Error.t) result) -> ('a, Error.t) result

(** Execute a function with retries using a specific strategy.
    Uses default max_attempts (3) and no retry callback.
*)
val with_strategy : Strategy.t -> (unit -> ('a, Error.t) result) -> ('a, Error.t) result

(** Execute a function with retries using the default configuration. *)
val with_default : (unit -> ('a, Error.t) result) -> ('a, Error.t) result
