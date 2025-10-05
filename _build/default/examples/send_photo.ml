let () =
  let open Tg in
  let chat = Telegram.Id.Chat.of_string "@channel" in
  let _req = Msg.photo (`Path "/tmp/pic.png") |> Msg.caption "hi" |> Msg.to_ chat in
  ignore _req
