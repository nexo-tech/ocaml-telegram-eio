(* Retry and backoff strategies for Telegram Bot API. *)

module Strategy = struct
  type t =
    | Immediate
    | Fixed of float
    | Exponential of { initial : float; max : float; multiplier : float }
    | Exponential_jitter of { initial : float; max : float; jitter : float; multiplier : float }
    | Telegram_aware of t option

  let immediate = Immediate

  let fixed delay = Fixed delay

  let exponential ?(initial = 1.0) ?(max = 60.0) ?(multiplier = 2.0) () =
    Exponential { initial; max; multiplier }

  let exponential_jitter ?(initial = 1.0) ?(max = 60.0) ?(jitter = 0.1) () =
    let multiplier = 2.0 in
    Exponential_jitter { initial; max; jitter; multiplier }

  let telegram_aware ?(fallback = exponential ()) () =
    Telegram_aware (Some fallback)

  let rec next_delay strategy ~attempt ~error =
    let apply_jitter jitter delay =
      let variance = delay *. jitter in
      let random_offset = Random.float (2.0 *. variance) -. variance in
      delay +. random_offset
    in

    match strategy with
    | Immediate -> 0.0
    | Fixed delay -> delay
    | Exponential { initial; max; multiplier } ->
        let delay = initial *. (multiplier ** float_of_int (attempt - 1)) in
        Float.min delay max
    | Exponential_jitter { initial; max; jitter; multiplier } ->
        let delay = initial *. (multiplier ** float_of_int (attempt - 1)) in
        let capped = Float.min delay max in
        Float.max 0.0 (apply_jitter jitter capped)
    | Telegram_aware fallback_opt ->
        (* Check if error has retry_after hint *)
        (match error with
         | Some err ->
             (match Error.retry_after err with
              | Some seconds -> float_of_int seconds
              | None ->
                  (* Fall back to exponential strategy *)
                  (match fallback_opt with
                   | Some fallback -> next_delay fallback ~attempt ~error
                   | None -> next_delay (exponential ()) ~attempt ~error))
         | None ->
             (match fallback_opt with
              | Some fallback -> next_delay fallback ~attempt ~error
              | None -> next_delay (exponential ()) ~attempt ~error))
end

type config = {
  strategy : Strategy.t;
  max_attempts : int;
  on_retry : (attempt:int -> error:Error.t -> delay:float -> unit) option;
}

let default = {
  strategy = Strategy.exponential ();
  max_attempts = 3;
  on_retry = None;
}

let make ?(strategy = Strategy.exponential ()) ?(max_attempts = 3) ?on_retry () =
  { strategy; max_attempts; on_retry }

let with_config config f =
  let rec attempt n =
    match f () with
    | Ok _ as ok -> ok
    | Error e when n >= config.max_attempts -> Error e
    | Error e when not (Error.is_retryable e) -> Error e
    | Error e ->
        let delay = Strategy.next_delay config.strategy ~attempt:n ~error:(Some e) in
        (* Invoke retry callback if provided *)
        (match config.on_retry with
         | Some callback -> callback ~attempt:n ~error:e ~delay
         | None -> ());
        (* Sleep for the calculated delay *)
        Unix.sleepf delay;
        (* Retry *)
        attempt (n + 1)
  in
  attempt 1

let with_strategy strategy f =
  with_config { default with strategy } f

let with_default f =
  with_config default f
