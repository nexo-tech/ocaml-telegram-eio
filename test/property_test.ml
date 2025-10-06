(* Property tests for JSON roundtrips using QCheck *)

open Telegram
open QCheck

(* Generators for core types *)

let gen_int64 =
  (* Generate int64 from int pairs to get full range *)
  Gen.map (fun i -> Int64.of_int i) Gen.int

let gen_currency =
  let currencies = [
    "USD"; "EUR"; "GBP"; "JPY"; "CNY"; "RUB"; "INR"; "BRL";
    "CAD"; "AUD"; "CHF"; "KRW"; "BHD"; "IQD"; "JOD"; "KWD";
    "BIF"; "CLP"; "VND"; "XYZ" (* XYZ for unknown currency testing *)
  ] in
  Gen.oneofl currencies

let gen_money =
  Gen.map2
    (fun currency amount -> Money.make ~currency ~amount)
    gen_currency
    gen_int64

let gen_parse_mode =
  Gen.oneofl [`Markdown; `MarkdownV2; `HTML]

let gen_chat_action =
  Gen.oneofl [
    `Typing; `Upload_photo; `Record_video; `Upload_video;
    `Record_voice; `Upload_voice; `Upload_document; `Choose_sticker;
    `Find_location; `Record_video_note; `Upload_video_note
  ]

let gen_duration =
  Gen.map Units.Duration.of_int64 gen_int64

let gen_file_size =
  Gen.map Units.File_size.bytes gen_int64

(* Shrinkers *)

let shrink_money m =
  let currency = Money.currency m in
  let amount = Money.amount m in
  Iter.map (fun a -> Money.make ~currency ~amount:a) (Shrink.int64 amount)

let shrink_duration d =
  Iter.map Units.Duration.of_int64 (Shrink.int64 (Units.Duration.to_int64 d))

let shrink_file_size fs =
  Iter.map Units.File_size.bytes (Shrink.int64 (Units.File_size.to_int64 fs))

(* Property tests *)

let prop_money_json_roundtrip =
  Test.make ~name:"Money JSON roundtrip"
    ~count:1000
    (make ~shrink:shrink_money gen_money)
    (fun money ->
      match Money.of_yojson (Money.to_yojson money) with
      | Ok decoded ->
          Money.currency decoded = Money.currency money &&
          Money.amount decoded = Money.amount money
      | Error _ -> false)

let prop_parse_mode_json_roundtrip =
  Test.make ~name:"Parse_mode JSON roundtrip"
    ~count:100
    (make gen_parse_mode)
    (fun mode ->
      match Parse_mode.of_yojson (Parse_mode.to_yojson mode) with
      | Ok decoded -> decoded = mode
      | Error _ -> false)

let prop_chat_action_json_roundtrip =
  Test.make ~name:"Chat_action JSON roundtrip"
    ~count:100
    (make gen_chat_action)
    (fun action ->
      match Chat_action.of_yojson (Chat_action.to_yojson action) with
      | Ok decoded -> decoded = action
      | Error _ -> false)

let prop_duration_json_roundtrip =
  Test.make ~name:"Duration JSON roundtrip"
    ~count:1000
    (make ~shrink:shrink_duration gen_duration)
    (fun duration ->
      match Units.Duration.of_yojson (Units.Duration.to_yojson duration) with
      | Ok decoded ->
          Units.Duration.to_int64 decoded = Units.Duration.to_int64 duration
      | Error _ -> false)

let prop_file_size_json_roundtrip =
  Test.make ~name:"File_size JSON roundtrip"
    ~count:1000
    (make ~shrink:shrink_file_size gen_file_size)
    (fun file_size ->
      match Units.File_size.of_yojson (Units.File_size.to_yojson file_size) with
      | Ok decoded ->
          Units.File_size.to_int64 decoded = Units.File_size.to_int64 file_size
      | Error _ -> false)

(* Additional properties: serialization stability *)

let prop_money_json_idempotent =
  Test.make ~name:"Money JSON serialization is idempotent"
    ~count:1000
    (make ~shrink:shrink_money gen_money)
    (fun money ->
      let json1 = Money.to_yojson money in
      match Money.of_yojson json1 with
      | Ok decoded ->
          let json2 = Money.to_yojson decoded in
          json1 = json2
      | Error _ -> false)

let prop_parse_mode_string_roundtrip =
  Test.make ~name:"Parse_mode string roundtrip"
    ~count:100
    (make gen_parse_mode)
    (fun mode ->
      let s = Parse_mode.to_string mode in
      match Parse_mode.of_string s with
      | Some decoded -> decoded = mode
      | None -> false)

let prop_chat_action_string_roundtrip =
  Test.make ~name:"Chat_action string roundtrip"
    ~count:100
    (make gen_chat_action)
    (fun action ->
      let s = Chat_action.to_string action in
      match Chat_action.of_string s with
      | Some decoded -> decoded = action
      | None -> false)

(* Money properties: semantic constraints *)

let prop_money_equal_reflexive =
  Test.make ~name:"Money.equal is reflexive"
    ~count:1000
    (make ~shrink:shrink_money gen_money)
    (fun money -> Money.equal money money)

let prop_money_equal_symmetric =
  Test.make ~name:"Money.equal is symmetric"
    ~count:1000
    (make Gen.(pair gen_money gen_money))
    (fun (m1, m2) ->
      if Money.currency m1 <> Money.currency m2 then true
      else Money.equal m1 m2 = Money.equal m2 m1)

let prop_money_compare_consistent =
  Test.make ~name:"Money.compare is consistent with equal"
    ~count:1000
    (make Gen.(pair gen_money gen_money))
    (fun (m1, m2) ->
      if Money.currency m1 <> Money.currency m2 then true
      else (Money.compare m1 m2 = 0) = Money.equal m1 m2)

(* Run all tests *)

let () =
  let suite = [
    prop_money_json_roundtrip;
    prop_parse_mode_json_roundtrip;
    prop_chat_action_json_roundtrip;
    prop_duration_json_roundtrip;
    prop_file_size_json_roundtrip;
    prop_money_json_idempotent;
    prop_parse_mode_string_roundtrip;
    prop_chat_action_string_roundtrip;
    prop_money_equal_reflexive;
    prop_money_equal_symmetric;
    prop_money_compare_consistent;
  ] in

  let alcotest_suite = List.map QCheck_alcotest.to_alcotest suite in
  Alcotest.run "Property tests" [
    "json_roundtrips", alcotest_suite
  ]
