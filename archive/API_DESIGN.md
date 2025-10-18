API Design — ocaml-telegram-eio (v2)

Design Goals (refined)
- Zero-boilerplate: one-line router wiring, handlers that work with typed values directly.
- Haskell-like ergonomics: typed event matchers (GADTs), composable routing with (&), typed callback data codecs, functional builders.
- Type-safety first: phantom-typed IDs, typed scopes (chat/inline), request builders with compile-time constraints where feasible.
- Direct-style with Result: Eio-native concurrency; ('a, Error.t) result with monadic operators for clarity.
- Performance: streaming I/O for media, no global locks, small constant overhead.

Top-level Namespace
- Telegram: low-level types and API (generated types; Request/Api; Error; Id; Client).
- Tg: curated reexports for day-to-day usage (Bot DSL, Msg builders, Keyboard, Session, Result_syntax).

Public Modules (user-facing)
- Telegram.Id — phantom-typed identifiers.
- Telegram.Types — generated schema types/codecs.
- Telegram.Error — error categories and utilities.
- Telegram.Client — client creation and HTTP plumbing.
- Telegram.Api — low-level call runner over typed requests.
- Telegram.Request — typed request values (sendMessage, sendPhoto, …) as first-class values.
- Tg.Bot — high-level DSL: typed routing and context operations.
- Tg.Keyboard — builders for reply/inline keyboards (safe sizing).
- Tg.Msg — typed message builders (text/photo/video/album) with composable options.
- Tg.Action — typed codec for callback_data/deep-linking payloads (versioned + HMAC).
- Tg.Session — typed sessions with phantom keys.
- Tg.Result_syntax — let* and let+ for ('a, Error.t) result.

Core Types
- Identifiers (phantom kinds)
  ```ocaml
  module Id : sig
    type +'k t
    module Chat : sig type k val of_int : int64 -> k Id.t end
    module User : sig type k val of_int : int64 -> k Id.t end
    module Message : sig type k val of_int : int -> k Id.t end
  end
  ```
- Input files
  ```ocaml
  type input_file =
    [ `File_id of string
    | `Url of string
    | `Path of string
    | `Bytes of string
    | `Stream of { src : < Eio.Flow.source ; .. > ; filename : string ; mime : string option } ]
  ```

Low-level API (algebra)
- First-class requests and a single runner; simplifies testing and composition.
  ```ocaml
  module Request : sig
    type 'a t
    val send_message
      :  chat_id:Id.Chat.t
      -> text:string
      -> ?parse_mode:Telegram.Types.parse_mode
      -> ?reply_parameters:Telegram.Types.reply_parameters
      -> unit -> Telegram.Types.message t
    val send_photo
      :  chat_id:Id.Chat.t
      -> photo:input_file
      -> ?caption:string -> unit -> Telegram.Types.message t
    (* ... all methods generated ... *)
  end

  module Api : sig
    val call : Telegram.Client.t -> 'a Request.t -> ('a, Telegram.Error.t) result
  end
  ```

High-level DSL (typed events + Bot monad)
- Typed events provide ergonomic matching with compile-time guarantees.
  ```ocaml
  module Bot : sig
    type t
    type 's ctx   (* 's is the scope: [ `Chat | `Inline | `Any ] *)

    module Event : sig
      type 'a t
      val message : Telegram.Types.message t
      val text : string t
      val command : string -> string list t           (* args *)
      val callback : 'a Tg.Action.codec -> 'a t       (* typed callback_data *)
      val inline_query : Telegram.Types.inline_query t
      val any : Telegram.Types.update t
      val ( & ) : 'a t -> 'b t -> ('a * 'b) t         (* combine matchers *)
      val when_ : 'a t -> ('a -> bool) -> 'a t        (* filter *)
    end

    type route

    module BotM : sig
      type 'a t = 's ctx -> ('a, Telegram.Error.t) result
      val return : 'a -> 'a t
      val bind : 'a t -> ('a -> 'b t) -> 'b t
    end

    module Ctx : sig
      type +'s t = 's ctx
      val client : _ t -> Telegram.Client.t
      val env : _ t -> Eio.Stdenv.t
      val chat : [ `Chat ] t -> Id.Chat.t
      val user : _ t -> Telegram.Types.user option
      val message : [ `Chat ] t -> Telegram.Types.message
      val reply : [ `Chat ] t -> string -> (Telegram.Types.message, Telegram.Error.t) result
    end

    val on : ('a Event.t) -> ('a -> unit BotM.t) -> route
    val router : ?middlewares:(unit -> unit BotM.t) list -> route list -> t

    val run_polling : env:Eio.Stdenv.t -> client:Telegram.Client.t -> t -> unit
    val run_webhook
      :  env:Eio.Stdenv.t -> client:Telegram.Client.t -> secret_token:string
      -> addr:[ `Tcp of (Eio.Net.Ipaddr.t * int) ] -> t -> unit
  end
  ```

Typed Callback Data and Deep Links
- Eliminates stringly-typed callback_data; encodes/decodes typed payloads with integrity protection.
  ```ocaml
  module Action : sig
    type 'a codec
    val make : name:string -> encode:('a -> Yojson.Safe.t) -> decode:(Yojson.Safe.t -> ('a, string) result) -> 'a codec
    val encode : secret:string -> 'a codec -> 'a -> string
    val decode : secret:string -> 'a codec -> string -> ('a, string) result
  end
  ```

Unified Message Builders (ergonomic send)
- Functional builders to describe outgoing messages; run via Api.call.
  ```ocaml
  module Msg : sig
    type 'ret t
    val text : string -> Telegram.Types.message t
    val photo : input_file -> Telegram.Types.message t
    val caption : string -> 'ret t -> 'ret t
    val parse_mode : Telegram.Types.parse_mode -> Telegram.Types.message t -> Telegram.Types.message t
    val to_ : Id.Chat.t -> 'ret t -> 'ret Telegram.Request.t
  end
  ```

Keyboards
```ocaml
module Keyboard : sig
  type inline
  val inline : inline list list -> Telegram.Types.inline_keyboard_markup
  val url : text:string -> url:string -> inline
  val callback : text:string -> data:string -> inline
end
```

Sessions and Middleware
```ocaml
module Session : sig
  type 'a key
  val make : name:string -> 'a key
  val get : 's Bot.ctx -> 'a key -> 'a option
  val set : 's Bot.ctx -> 'a key -> 'a -> unit
end

(* Middleware is just BotM.t that runs before each handler *)
```

Errors and Result Syntax
```ocaml
module Result_syntax : sig
  val ( let* ) : ('a, Telegram.Error.t) result -> ('a -> ('b, Telegram.Error.t) result) -> ('b, Telegram.Error.t) result
  val ( let+ ) : ('a, Telegram.Error.t) result -> ('a -> 'b) -> ('b, Telegram.Error.t) result
end
```

Examples (reworked)

1) Minimal Echo (Polling) with typed events
```ocaml
open Tg
open Result_syntax

let app =
  Bot.router [
    Bot.on Bot.Event.(command "start") (fun args ->
      fun ctx ->
        let* _ = Bot.Ctx.reply ctx "Welcome!" in
        Ok ()) ;
    Bot.on Bot.Event.(text) (fun txt ->
      fun ctx ->
        let* _ = Bot.Ctx.reply ctx ("Echo: " ^ txt) in
        Ok ())
  ]

let () =
  Eio_main.run @@ fun env ->
  let client = Telegram.Client.create ~env ~token:(Sys.getenv "BOT_TOKEN") () in
  Bot.run_polling ~env ~client app
```

2) Typed callback_data with Action codec
```ocaml
type ping = { at : int64 }
let ping_codec = Tg.Action.make
  ~name:"ping"
  ~encode:(fun p -> `Assoc ["at", `String (Int64.to_string p.at)])
  ~decode:(function `Assoc [ ("at", `String s) ] -> Ok { at = Int64.of_string s } | _ -> Error "bad")

let kb secret =
  let data = Tg.Action.encode ~secret ping_codec { at = Int64.of_float (Unix.gettime ()) } in
  Tg.Keyboard.inline [ [ Tg.Keyboard.callback ~text:"Ping" ~data ] ]

let app secret =
  Bot.router [
    Bot.on Bot.Event.(callback ping_codec) (fun payload ->
      fun ctx -> let* _ = Bot.Ctx.reply ctx "Pong!" in Ok ())
  ]
```

3) Unified send with Msg builders
```ocaml
let send_welcome env client chat_id =
  let open Telegram in
  let req = Tg.Msg.text "Hello" |> Tg.Msg.to_ chat_id in
  Api.call client req
```

4) Inline queries
```ocaml
let app =
  Bot.router [
    Bot.on Bot.Event.inline_query (fun iq -> fun ctx ->
      (* build results ... *)
      let req = Telegram.Request.answer_inline_query ~inline_query_id:iq.id ~results:[] () in
      Telegram.Api.call (Bot.Ctx.client ctx) req)
  ]
```

5) Media streaming upload
```ocaml
let send_photo client chat_id path =
  let req = Telegram.Request.send_photo ~chat_id ~photo:(`Path path) () in
  Telegram.Api.call client req
```

Why this is better
- Less ceremony: one Api.call entry point; Msg builders avoid dozens of positional options.
- Typed events: handlers only run when required parts exist; fewer option types.
- Typed callback payloads: no ad-hoc JSON packing; safer upgrades via versioned codecs.
- Separation of concerns: Request describes intent; Api.call performs I/O; Bot DSL composes handlers.
- Haskell-like composability: (&) to combine matchers; BotM monad for clean, linear code.
