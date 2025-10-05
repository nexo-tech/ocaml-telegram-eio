(* Example: Echo bot using Tg.Msg builders
   Note: Api.call currently uses a stub HTTP backend; this example
   demonstrates API usage but does not perform network I/O yet. *)

let () =
  let open Tg in
  let chat = Telegram.Id.Chat.of_int 1L in
  let _req = Msg.text "Hello" |> Msg.to_ chat in
  (* In a real app: create Client, then Api.call client _req *)
  ()
