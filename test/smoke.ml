open Alcotest

let test_msg_builder () =
  let chat = Telegram.Id.Chat.of_int 1L in
  let req = Tg.Msg.text "Hi" |> Tg.Msg.to_ chat in
  match req with
  | Telegram.Request.Send_message { text; _ } -> check string "text" "Hi" text
  | _ -> fail "expected Send_message"

let test_parse_mode () =
  let chat = Telegram.Id.Chat.of_int 1L in
  let req = Tg.Msg.text "Hi" |> Tg.Msg.parse_mode `MarkdownV2 |> Tg.Msg.to_ chat in
  match req with
  | Telegram.Request.Send_message { parse_mode = Some `MarkdownV2; _ } -> ()
  | _ -> fail "expected parse_mode=MarkdownV2"

let test_chat_username () =
  let chat = Telegram.Id.Chat.of_username "@channel" in
  let req = Tg.Msg.text "Hi" |> Tg.Msg.to_ chat in
  match req with
  | Telegram.Request.Send_message { chat_id; _ } ->
      Alcotest.(check string) "username" "@channel" (Telegram.Id.to_string chat_id)
  | _ -> fail "expected Send_message"

let suite = [
  ("builders", [ test_case "text" `Quick test_msg_builder
               ; test_case "parse_mode" `Quick test_parse_mode
               ; test_case "chat username" `Quick test_chat_username ]);
]

let () = run "ocaml-telegram-eio" suite
