(** Scoped logger for client operations *)
module Log = Flo_scoped.Make(struct
  let namespace = "telegram.client"
end)

type env = Eio_unix.Stdenv.base

type t = {
  env : env;
  token : string;
  base_url : string;
  limits : Limits.t;
}

let create ~env ~token ?(base_url = "https://api.telegram.org") ?(limits = Limits.telegram_limits) () =
  let open Flo in

  (* Info level: lifecycle event (visible by default) *)
  Log.info "Creating Telegram Bot API client";

  (* Debug level: internal configuration details (hidden by default) *)
  Log.debug_fields "Client configuration" ~fields:[
    ("base_url", Value.string base_url);
    ("token_length", Value.int (String.length token));
    ("has_custom_limits", Value.bool (limits != Limits.telegram_limits));
  ];

  { env; token; base_url; limits }

let token t = t.token
let base_url t = t.base_url
let env t = t.env
let limits t = t.limits
