type env = unit

type t = {
  env : env;
  token : string;
  base_url : string;
}

let create ~env ~token ?(base_url = "https://api.telegram.org") () = { env; token; base_url }

let token t = t.token
let base_url t = t.base_url
let env t = t.env
