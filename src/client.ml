type env = Eio_unix.Stdenv.base

type t = {
  env : env;
  token : string;
  base_url : string;
  limits : Limits.t;
}

let create ~env ~token ?(base_url = "https://api.telegram.org") ?(limits = Limits.telegram_limits) () =
  { env; token; base_url; limits }

let token t = t.token
let base_url t = t.base_url
let env t = t.env
let limits t = t.limits
