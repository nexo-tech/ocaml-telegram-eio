(** Telegram Bot API HTTP client.

    This module provides the core HTTP client for communicating with the
    Telegram Bot API. It handles authentication, request/response serialization,
    and provides access to the Eio environment for concurrent operations.

    {2 Example}

    {[
      open Eio.Std

      let () =
        Eio_main.run @@ fun env ->
        let token = Sys.getenv "TELEGRAM_BOT_TOKEN" in
        let client = Client.create ~env ~token () in

        (* Use client with Api module *)
        let req = Api.get_me () in
        match Api.call client req with
        | Ok me -> Printf.printf "Bot: %s\n" me.User.first_name
        | Error err -> Printf.eprintf "Error: %s\n" (Error.to_string err)
    ]}
*)

(** The Eio environment type required for I/O operations. *)
type env = Eio_unix.Stdenv.base

(** Abstract client type. Contains the bot token, base URL, rate limits,
    and Eio environment. *)
type t

(** [create ~env ~token ?base_url ?limits ()] creates a new Telegram Bot API client.

    @param env The Eio environment (network, clock, etc.)
    @param token Your bot's authentication token from BotFather
    @param base_url Optional custom API endpoint (default: https://api.telegram.org)
    @param limits Optional rate limits (default: Limits.default)

    The token is automatically included in all API requests as part of the URL path.
*)
val create : env:env -> token:string -> ?base_url:string -> ?limits:Limits.t -> unit -> t

(** Get the bot token. *)
val token : t -> string

(** Get the base API URL. *)
val base_url : t -> string

(** Get the Eio environment. *)
val env : t -> env

(** Get the configured rate limits. *)
val limits : t -> Limits.t
