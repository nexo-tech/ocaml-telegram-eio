(** Utility Bots Use Case - Practical utility bot patterns

    This example demonstrates utility bot patterns:
    - Calculator bot with expression evaluation
    - Unit converter (temperature, distance, weight)
    - Random utilities (dice, coin, random number)
    - Time utilities (current time, timestamp)
    - Text utilities (word count, reverse, case conversion)

    Commands:
      /start - Show main menu
      /calc <expression> - Calculate expression (e.g., 2 + 3 * 4)
      /convert <value> <from> <to> - Convert units (e.g., 100 km mi)
      /roll_dice - Roll a 6-sided dice
      /flip_coin - Flip a coin
      /random <min> <max> - Random number in range
      /choose <option1> <option2> ... - Random choice
      /time - Show current time
      /timestamp - Unix timestamp
      /wordcount <text...> - Count words
      /reverse <text...> - Reverse text
      /upper <text...> - Convert to uppercase
      /lower <text...> - Convert to lowercase

    This example has VERBOSE LOGGING enabled for troubleshooting.

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/usecase_utility_bots_demo.exe
*)

open Telegram
open Tg

(* Configure verbose logging with flo *)
let () = Flo.set_level Severity.Debug

module KB = Keyboard

(** Calculator module - Expression evaluation *)
module Calculator = struct
  exception ParseError of string

  type token =
    | TNum of float
    | TPlus
    | TMinus
    | TMul
    | TDiv
    | TLParen
    | TRParen

  (** Tokenize expression string *)
  let tokenize s =
    Eio.traceln "[Calculator] Tokenizing: %s" s;
    let buf = Buffer.create 16 in
    let flush_num acc =
      if Buffer.length buf > 0 then
        let num_str = Buffer.contents buf in
        Buffer.clear buf;
        try
          TNum (float_of_string num_str) :: acc
        with _ -> raise (ParseError ("Invalid number: " ^ num_str))
      else acc
    in

    let rec tokenize_chars i acc =
      if i >= String.length s then
        List.rev (flush_num acc)
      else
        match s.[i] with
        | ' ' | '\t' -> tokenize_chars (i+1) acc
        | '+' -> tokenize_chars (i+1) (flush_num (TPlus :: acc))
        | '-' -> tokenize_chars (i+1) (flush_num (TMinus :: acc))
        | '*' -> tokenize_chars (i+1) (flush_num (TMul :: acc))
        | '/' -> tokenize_chars (i+1) (flush_num (TDiv :: acc))
        | '(' -> tokenize_chars (i+1) (flush_num (TLParen :: acc))
        | ')' -> tokenize_chars (i+1) (flush_num (TRParen :: acc))
        | c when (c >= '0' && c <= '9') || c = '.' ->
            Buffer.add_char buf c;
            tokenize_chars (i+1) acc
        | c ->
            raise (ParseError (Printf.sprintf "Unexpected character: %c" c))
    in
    tokenize_chars 0 []

  (** Recursive descent parser *)
  let rec parse_expr tokens pos =
    let (val1, pos1) = parse_term tokens pos in
    parse_expr_tail tokens pos1 val1

  and parse_expr_tail tokens pos left =
    if pos >= List.length tokens then (left, pos)
    else
      match List.nth tokens pos with
      | TPlus ->
          let (right, pos2) = parse_term tokens (pos + 1) in
          parse_expr_tail tokens pos2 (left +. right)
      | TMinus ->
          let (right, pos2) = parse_term tokens (pos + 1) in
          parse_expr_tail tokens pos2 (left -. right)
      | _ -> (left, pos)

  and parse_term tokens pos =
    let (val1, pos1) = parse_factor tokens pos in
    parse_term_tail tokens pos1 val1

  and parse_term_tail tokens pos left =
    if pos >= List.length tokens then (left, pos)
    else
      match List.nth tokens pos with
      | TMul ->
          let (right, pos2) = parse_factor tokens (pos + 1) in
          parse_term_tail tokens pos2 (left *. right)
      | TDiv ->
          let (right, pos2) = parse_factor tokens (pos + 1) in
          if right = 0.0 then raise (ParseError "Division by zero")
          else parse_term_tail tokens pos2 (left /. right)
      | _ -> (left, pos)

  and parse_factor tokens pos =
    if pos >= List.length tokens then
      raise (ParseError "Unexpected end of expression")
    else
      match List.nth tokens pos with
      | TNum n -> (n, pos + 1)
      | TMinus ->
          let (val1, pos1) = parse_factor tokens (pos + 1) in
          (-. val1, pos1)
      | TLParen ->
          let (val1, pos1) = parse_expr tokens (pos + 1) in
          if pos1 >= List.length tokens then
            raise (ParseError "Missing closing parenthesis")
          else
            (match List.nth tokens pos1 with
             | TRParen -> (val1, pos1 + 1)
             | _ -> raise (ParseError "Expected closing parenthesis"))
      | _ -> raise (ParseError "Expected number or '('")

  (** Evaluate expression *)
  let eval expr =
    Eio.traceln "[Calculator] Evaluating: %s" expr;
    try
      let tokens = tokenize expr in
      let (result, pos) = parse_expr tokens 0 in
      if pos < List.length tokens then
        Error "Unexpected tokens after expression"
      else (
        Eio.traceln "[Calculator] Result: %g" result;
        Ok result
      )
    with
    | ParseError msg ->
        Eio.traceln "[Calculator] Parse error: %s" msg;
        Error msg
    | exn ->
        let msg = Printexc.to_string exn in
        Eio.traceln "[Calculator] Error: %s" msg;
        Error msg
end

(** Unit converter module *)
module UnitConverter = struct
  (** Convert temperature *)
  let celsius_to_fahrenheit c = c *. 9.0 /. 5.0 +. 32.0
  let fahrenheit_to_celsius f = (f -. 32.0) *. 5.0 /. 9.0

  (** Convert distance *)
  let km_to_miles km = km /. 1.60934
  let miles_to_km mi = mi *. 1.60934

  (** Convert weight *)
  let kg_to_pounds kg = kg *. 2.20462
  let pounds_to_kg lb = lb /. 2.20462

  (** Convert units *)
  let convert value from_unit to_unit =
    Eio.traceln "[UnitConverter] Converting: %.4g %s to %s" value from_unit to_unit;

    let from_lower = String.lowercase_ascii from_unit in
    let to_lower = String.lowercase_ascii to_unit in

    match from_lower, to_lower with
    (* Temperature *)
    | "c", "f" | "celsius", "fahrenheit" ->
        Ok (celsius_to_fahrenheit value, "°F")
    | "f", "c" | "fahrenheit", "celsius" ->
        Ok (fahrenheit_to_celsius value, "°C")

    (* Distance *)
    | "km", "mi" | "km", "miles" | "kilometers", "miles" ->
        Ok (km_to_miles value, "mi")
    | "mi", "km" | "miles", "km" | "miles", "kilometers" ->
        Ok (miles_to_km value, "km")

    (* Weight *)
    | "kg", "lb" | "kg", "pounds" | "kilograms", "pounds" ->
        Ok (kg_to_pounds value, "lb")
    | "lb", "kg" | "pounds", "kg" | "pounds", "kilograms" ->
        Ok (pounds_to_kg value, "kg")

    | _ ->
        Error (Printf.sprintf "Unknown conversion: %s to %s" from_unit to_unit)
end

(** Text utilities *)
module TextUtils = struct
  let word_count text =
    let words = String.split_on_char ' ' text
                |> List.filter (fun s -> String.length s > 0) in
    List.length words

  let char_count text =
    String.length text

  let reverse text =
    String.to_seq text
    |> List.of_seq
    |> List.rev
    |> List.to_seq
    |> String.of_seq
end

let () =
  Printexc.record_backtrace true;
  Random.self_init ();
  Eio.traceln "=== Utility Bots Demo Starting ===";

  let token = match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None -> Printf.eprintf "TELEGRAM_BOT_TOKEN not set\n"; exit 1
  in

  Eio_main.run @@ fun env ->
  let client = Client.create ~env ~token () in

  Eio.traceln "🤖 Utility Bots Demo Started";

  let session_store = Session.Memory_store.create () in

  Bot.make ~env ~client
  |> Bot.with_sessions (module Session.Memory_store) session_store

  (* /start - Main menu *)
  |> Bot.command "start" ~desc:"Show main menu" (fun ctx _args ->
      let open Bot.Ctx in
      Eio.traceln "[/start] Showing main menu";

      let text =
        "🛠️ <b>Utility Bots Demo</b>\n\n\
         <b>🧮 Calculator:</b>\n\
         /calc <expr> - Evaluate expression\n\n\
         <b>↔️ Unit Converter:</b>\n\
         /convert <value> <from> <to>\n\n\
         <b>🎲 Random:</b>\n\
         /roll_dice - Roll dice\n\
         /flip_coin - Flip coin\n\
         /random <min> <max> - Random number\n\
         /choose <options...> - Random choice\n\n\
         <b>🕐 Time:</b>\n\
         /time - Current time\n\
         /timestamp - Unix timestamp\n\n\
         <b>📝 Text:</b>\n\
         /wordcount <text> - Count words\n\
         /reverse <text> - Reverse text\n\
         /upper, /lower - Case conversion"
      in

      match reply ctx text with
      | Ok _ -> Eio.traceln "[/start] ✓"; Ok ()
      | Error e -> Eio.traceln "[/start] ✗ %a" Error.pp e; Ok ()
    )

  (* /calc - Calculator *)
  |> Bot.command "calc" ~desc:"Calculate expression" (fun ctx args ->
      let open Bot.Ctx in
      Eio.traceln "[/calc] Calculating expression";

      match args with
      | [] ->
          (match reply ctx
            "Usage: /calc <expression>\n\n\
             Examples:\n\
             • /calc 2 + 3\n\
             • /calc 10 * (5 + 2)\n\
             • /calc 100 / 4 - 5\n\n\
             Supports: +, -, *, /, ()"
           with
           | Ok _ -> Ok ()
           | Error e -> Eio.traceln "[/calc] ✗ %a" Error.pp e; Ok ())

      | _ ->
          let expr = String.concat " " args in

          (match Calculator.eval expr with
           | Ok result ->
               Eio.traceln "[/calc] Success: %s = %g" expr result;
               let response = Printf.sprintf "🧮 %s = %g" expr result in
               (match reply ctx response with
                | Ok _ -> Eio.traceln "[/calc] ✓"; Ok ()
                | Error e -> Eio.traceln "[/calc] ✗ %a" Error.pp e; Ok ())

           | Error msg ->
               Eio.traceln "[/calc] Error: %s" msg;
               (match reply ctx (Printf.sprintf "❌ %s" msg) with
                | Ok _ -> Ok ()
                | Error e -> Eio.traceln "[/calc] ✗ %a" Error.pp e; Ok ()))
    )

  (* /convert - Unit converter *)
  |> Bot.command "convert" ~desc:"Convert units" (fun ctx args ->
      let open Bot.Ctx in
      Eio.traceln "[/convert] Converting units";

      match args with
      | [value_str; from_unit; to_unit] ->
          (match float_of_string_opt value_str with
           | None ->
               (match reply ctx "❌ Value must be a number" with
                | Ok _ -> Ok ()
                | Error e -> Eio.traceln "[/convert] ✗ %a" Error.pp e; Ok ())

           | Some value ->
               (match UnitConverter.convert value from_unit to_unit with
                | Ok (result, unit) ->
                    Eio.traceln "[/convert] %g %s = %g %s" value from_unit result unit;
                    let response = Printf.sprintf "↔️ %.4g %s = %.4g %s" value from_unit result unit in
                    (match reply ctx response with
                     | Ok _ -> Eio.traceln "[/convert] ✓"; Ok ()
                     | Error e -> Eio.traceln "[/convert] ✗ %a" Error.pp e; Ok ())

                | Error msg ->
                    Eio.traceln "[/convert] Error: %s" msg;
                    (match reply ctx
                      ("❌ " ^ msg ^ "\n\n\
                        Supported: C↔F, km↔mi, kg↔lb")
                     with
                     | Ok _ -> Ok ()
                     | Error e -> Eio.traceln "[/convert] ✗ %a" Error.pp e; Ok ())))

      | _ ->
          (match reply ctx
            "Usage: /convert <value> <from> <to>\n\n\
             Examples:\n\
             • /convert 100 C F\n\
             • /convert 10 km mi\n\
             • /convert 70 kg lb\n\n\
             Supported: C↔F, km↔mi, kg↔lb"
           with
           | Ok _ -> Ok ()
           | Error e -> Eio.traceln "[/convert] ✗ %a" Error.pp e; Ok ())
    )

  (* /roll_dice - Random dice *)
  |> Bot.command "roll_dice" ~desc:"Roll a dice" (fun ctx _args ->
      let open Bot.Ctx in
      let result = Random.int 6 + 1 in
      Eio.traceln "[/roll_dice] Rolled: %d" result;

      let emoji = match result with
        | 1 -> "⚀"
        | 2 -> "⚁"
        | 3 -> "⚂"
        | 4 -> "⚃"
        | 5 -> "⚄"
        | 6 -> "⚅"
        | _ -> "🎲"
      in

      let response = Printf.sprintf "%s You rolled a %d!" emoji result in

      match reply ctx response with
      | Ok _ -> Eio.traceln "[/roll_dice] ✓"; Ok ()
      | Error e -> Eio.traceln "[/roll_dice] ✗ %a" Error.pp e; Ok ()
    )

  (* /flip_coin - Random coin flip *)
  |> Bot.command "flip_coin" ~desc:"Flip a coin" (fun ctx _args ->
      let open Bot.Ctx in
      let result = if Random.bool () then "Heads" else "Tails" in
      Eio.traceln "[/flip_coin] Result: %s" result;

      let response = Printf.sprintf "🪙 %s!" result in

      match reply ctx response with
      | Ok _ -> Eio.traceln "[/flip_coin] ✓"; Ok ()
      | Error e -> Eio.traceln "[/flip_coin] ✗ %a" Error.pp e; Ok ()
    )

  (* /random - Random number in range *)
  |> Bot.command "random" ~desc:"Random number in range" (fun ctx args ->
      let open Bot.Ctx in
      Eio.traceln "[/random] Generating random number";

      match args with
      | [min_str; max_str] ->
          (match int_of_string_opt min_str, int_of_string_opt max_str with
           | Some min_val, Some max_val when min_val < max_val ->
               let range = max_val - min_val + 1 in
               let result = Random.int range + min_val in
               Eio.traceln "[/random] Generated: %d (range: %d-%d)" result min_val max_val;

               let response = Printf.sprintf "🎲 Random number: %d\n(Range: %d-%d)" result min_val max_val in

               (match reply ctx response with
                | Ok _ -> Eio.traceln "[/random] ✓"; Ok ()
                | Error e -> Eio.traceln "[/random] ✗ %a" Error.pp e; Ok ())

           | _, _ ->
               (match reply ctx "❌ Both arguments must be valid integers with min < max" with
                | Ok _ -> Ok ()
                | Error e -> Eio.traceln "[/random] ✗ %a" Error.pp e; Ok ()))

      | _ ->
          (match reply ctx
            "Usage: /random <min> <max>\n\n\
             Example: /random 1 100"
           with
           | Ok _ -> Ok ()
           | Error e -> Eio.traceln "[/random] ✗ %a" Error.pp e; Ok ())
    )

  (* /choose - Random choice *)
  |> Bot.command "choose" ~desc:"Choose random option" (fun ctx args ->
      let open Bot.Ctx in
      Eio.traceln "[/choose] Choosing from %d options" (List.length args);

      match args with
      | [] | [_] ->
          (match reply ctx
            "Usage: /choose <option1> <option2> ...\n\n\
             Example: /choose Pizza Burger Salad"
           with
           | Ok _ -> Ok ()
           | Error e -> Eio.traceln "[/choose] ✗ %a" Error.pp e; Ok ())

      | options ->
          let choice = List.nth options (Random.int (List.length options)) in
          Eio.traceln "[/choose] Selected: %s" choice;

          let response = Printf.sprintf "🎯 I choose: <b>%s</b>" choice in

          (match reply ctx response with
           | Ok _ -> Eio.traceln "[/choose] ✓"; Ok ()
           | Error e -> Eio.traceln "[/choose] ✗ %a" Error.pp e; Ok ())
    )

  (* /time - Current time *)
  |> Bot.command "time" ~desc:"Show current time" (fun ctx _args ->
      let open Bot.Ctx in
      Eio.traceln "[/time] Showing current time";

      let now = Unix.time () in
      let tm = Unix.localtime now in

      let response = Printf.sprintf
        "🕐 <b>Current Time</b>\n\n\
         Local: %02d:%02d:%02d\n\
         Date: %04d-%02d-%02d\n\
         Unix timestamp: %.0f"
        tm.tm_hour tm.tm_min tm.tm_sec
        (tm.tm_year + 1900) (tm.tm_mon + 1) tm.tm_mday
        now
      in

      match reply ctx response with
      | Ok _ -> Eio.traceln "[/time] ✓"; Ok ()
      | Error e -> Eio.traceln "[/time] ✗ %a" Error.pp e; Ok ()
    )

  (* /timestamp - Unix timestamp *)
  |> Bot.command "timestamp" ~desc:"Unix timestamp" (fun ctx _args ->
      let open Bot.Ctx in
      let timestamp = Unix.time () |> int_of_float in
      Eio.traceln "[/timestamp] Current timestamp: %d" timestamp;

      let response = Printf.sprintf "⏱️ Unix timestamp: %d" timestamp in

      match reply ctx response with
      | Ok _ -> Eio.traceln "[/timestamp] ✓"; Ok ()
      | Error e -> Eio.traceln "[/timestamp] ✗ %a" Error.pp e; Ok ()
    )

  (* /wordcount - Count words *)
  |> Bot.command "wordcount" ~desc:"Count words in text" (fun ctx args ->
      let open Bot.Ctx in
      Eio.traceln "[/wordcount] Counting words";

      match args with
      | [] ->
          (match reply ctx "Usage: /wordcount <text...>" with
           | Ok _ -> Ok ()
           | Error e -> Eio.traceln "[/wordcount] ✗ %a" Error.pp e; Ok ())

      | _ ->
          let text = String.concat " " args in
          let words = TextUtils.word_count text in
          let chars = TextUtils.char_count text in

          Eio.traceln "[/wordcount] Words: %d, Chars: %d" words chars;

          let response = Printf.sprintf
            "📊 <b>Text Statistics</b>\n\n\
             Text: %s\n\n\
             Words: %d\n\
             Characters: %d"
            text words chars
          in

          (match reply ctx response with
           | Ok _ -> Eio.traceln "[/wordcount] ✓"; Ok ()
           | Error e -> Eio.traceln "[/wordcount] ✗ %a" Error.pp e; Ok ())
    )

  (* /reverse - Reverse text *)
  |> Bot.command "reverse" ~desc:"Reverse text" (fun ctx args ->
      let open Bot.Ctx in
      Eio.traceln "[/reverse] Reversing text";

      match args with
      | [] ->
          (match reply ctx "Usage: /reverse <text...>" with
           | Ok _ -> Ok ()
           | Error e -> Eio.traceln "[/reverse] ✗ %a" Error.pp e; Ok ())

      | _ ->
          let text = String.concat " " args in
          let reversed = TextUtils.reverse text in

          Eio.traceln "[/reverse] %s → %s" text reversed;

          let response = Printf.sprintf "🔄 %s" reversed in

          (match reply ctx response with
           | Ok _ -> Eio.traceln "[/reverse] ✓"; Ok ()
           | Error e -> Eio.traceln "[/reverse] ✗ %a" Error.pp e; Ok ())
    )

  (* /upper - Uppercase text *)
  |> Bot.command "upper" ~desc:"Convert to uppercase" (fun ctx args ->
      let open Bot.Ctx in

      match args with
      | [] ->
          (match reply ctx "Usage: /upper <text...>" with
           | Ok _ -> Ok ()
           | Error e -> Eio.traceln "[/upper] ✗ %a" Error.pp e; Ok ())

      | _ ->
          let text = String.concat " " args in
          let upper = String.uppercase_ascii text in

          let response = Printf.sprintf "🔠 %s" upper in

          (match reply ctx response with
           | Ok _ -> Eio.traceln "[/upper] ✓"; Ok ()
           | Error e -> Eio.traceln "[/upper] ✗ %a" Error.pp e; Ok ())
    )

  (* /lower - Lowercase text *)
  |> Bot.command "lower" ~desc:"Convert to lowercase" (fun ctx args ->
      let open Bot.Ctx in

      match args with
      | [] ->
          (match reply ctx "Usage: /lower <text...>" with
           | Ok _ -> Ok ()
           | Error e -> Eio.traceln "[/lower] ✗ %a" Error.pp e; Ok ())

      | _ ->
          let text = String.concat " " args in
          let lower = String.lowercase_ascii text in

          let response = Printf.sprintf "🔡 %s" lower in

          (match reply ctx response with
           | Ok _ -> Eio.traceln "[/lower] ✓"; Ok ()
           | Error e -> Eio.traceln "[/lower] ✗ %a" Error.pp e; Ok ())
    )

  |> Bot.run
