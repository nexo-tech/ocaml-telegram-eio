(** Command DSL Demo - Comprehensive demonstration of the command API

    This example demonstrates all command DSL features:
    - Basic commands with no arguments
    - Commands with manual argument parsing
    - Commands with typed argument parsers (command_with)
    - Argument parsing helpers (expect_1, expect_2, parse_int, parse_bool)
    - Command descriptions for automatic /help generation
    - Commands with remaining arguments (join_rest)
    - Builder pattern API composition

    Commands:
      /start - Welcome message
      /help - Auto-generated command list with descriptions
      /echo <text...> - Echo back the provided text
      /calc <num1> <num2> - Add two numbers
      /greet <name> - Greet someone by name
      /remind <title> <note...> - Save a reminder with title and content
      /check <yes/no/true/false> - Parse boolean values
      /multiply <a> <b> <c> - Multiply three numbers
      /info - Show bot information

    This example has VERBOSE LOGGING enabled for troubleshooting.

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/command_dsl_demo.exe
*)

open Telegram
open Tg

(* Configure verbose logging with flo *)
let () = Flo.set_level Severity.Debug

(* Argument parsers for command_with *)
module Parsers = struct
  (* Parser for single integer *)
  let int_parser args =
    match Bot.Args.expect_1 args with
    | None -> Error "Expected exactly 1 argument"
    | Some s ->
        match Bot.Args.parse_int s with
        | None -> Error "Argument must be a valid integer"
        | Some n -> Ok n

  (* Parser for two integers *)
  let two_ints_parser args =
    match Bot.Args.expect_2 args with
    | None -> Error "Expected exactly 2 arguments"
    | Some (a_str, b_str) ->
        match Bot.Args.parse_int a_str, Bot.Args.parse_int b_str with
        | Some a, Some b -> Ok (a, b)
        | None, _ -> Error "First argument must be a valid integer"
        | _, None -> Error "Second argument must be a valid integer"

  (* Parser for three integers *)
  let three_ints_parser args =
    match Bot.Args.expect_3 args with
    | None -> Error "Expected exactly 3 arguments"
    | Some (a_str, b_str, c_str) ->
        match Bot.Args.parse_int a_str, Bot.Args.parse_int b_str, Bot.Args.parse_int c_str with
        | Some a, Some b, Some c -> Ok (a, b, c)
        | None, _, _ -> Error "First argument must be a valid integer"
        | _, None, _ -> Error "Second argument must be a valid integer"
        | _, _, None -> Error "Third argument must be a valid integer"

  (* Parser for single string *)
  let string_parser args =
    match Bot.Args.expect_1 args with
    | None -> Error "Expected exactly 1 argument"
    | Some s -> Ok s

  (* Parser for boolean *)
  let bool_parser args =
    match Bot.Args.expect_1 args with
    | None -> Error "Expected exactly 1 argument (yes/no, true/false, 1/0)"
    | Some s ->
        match Bot.Args.parse_bool s with
        | None -> Error "Argument must be yes/no, true/false, or 1/0"
        | Some b -> Ok b
end

let () =
  Printexc.record_backtrace true;
  Flo.info "=== Command DSL Demo Starting ===";

  let token = match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None -> Printf.eprintf "TELEGRAM_BOT_TOKEN not set\n"; exit 1
  in

  Eio_main.run @@ fun env ->
  let client = Client.create ~env ~token () in

  Flo.info "🤖 Command DSL Demo Bot Started";

  Bot.make ~env ~client

  (* /start - Welcome message *)
  |> Bot.command "start" ~desc:"Welcome message" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/start] User started bot";

      match reply ctx
        "👋 Welcome to Command DSL Demo!\n\n\
         This bot demonstrates the command API features.\n\
         Try /help to see all available commands."
      with
      | Ok _ -> Flo.debug "[/start] ✓"; Ok ()
      | Error e -> Flo.debugf "[/start] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /help - Auto-generated help from command descriptions *)
  |> Bot.command "help" ~desc:"Show available commands" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/help] Generating help message";

      (* In a real implementation, commands() would return list of (name, desc) *)
      let help_text =
        "📚 Available Commands:\n\n\
         /start - Welcome message\n\
         /help - Show available commands\n\
         /echo <text...> - Echo back your text\n\
         /calc <num1> <num2> - Add two numbers\n\
         /subtract <a> <b> - Subtract two numbers\n\
         /multiply <a> <b> <c> - Multiply three numbers\n\
         /square <n> - Square a number\n\
         /greet <name> - Greet someone\n\
         /remind <title> <note...> - Create reminder\n\
         /check <yes/no> - Parse boolean value\n\
         /info - Show bot information"
      in

      match reply ctx help_text with
      | Ok _ -> Flo.debug "[/help] ✓"; Ok ()
      | Error e -> Flo.debugf "[/help] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /echo - Basic command with raw string arguments *)
  |> Bot.command "echo" ~desc:"Echo back your text" (fun ctx args ->
      let open Bot.Ctx in
      Flo.debugf "[/echo] Args count: %d" (List.length args);

      match args with
      | [] ->
          Flo.debug "[/echo] No arguments provided";
          (match reply ctx "Usage: /echo <text...>\n\nExample: /echo Hello World!" with
           | Ok _ -> Ok ()
           | Error e -> Flo.debugf "[/echo] Error: %s" (Format.asprintf "%a" Error.pp e); Ok ())
      | _ ->
          let text = String.concat " " args in
          Flo.debugf "[/echo] Echoing: %s" text;
          (match reply ctx (Printf.sprintf "🔊 You said: %s" text) with
           | Ok _ -> Flo.debug "[/echo] ✓"; Ok ()
           | Error e -> Flo.debugf "[/echo] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ())
    )

  (* /calc - Command with manual two-argument parsing *)
  |> Bot.command "calc" ~desc:"Add two numbers" (fun ctx args ->
      let open Bot.Ctx in
      Flo.debug "[/calc] Parsing arguments";

      match Bot.Args.expect_2 args with
      | None ->
          Flo.debug "[/calc] Wrong argument count";
          (match reply ctx "Usage: /calc <num1> <num2>\n\nExample: /calc 5 3" with
           | Ok _ -> Ok ()
           | Error e -> Flo.debugf "[/calc] Error: %s" (Format.asprintf "%a" Error.pp e); Ok ())
      | Some (a_str, b_str) ->
          Flo.debugf "[/calc] Parsing: %s + %s" a_str b_str;
          (match Bot.Args.parse_int a_str, Bot.Args.parse_int b_str with
           | Some a, Some b ->
               let result = a + b in
               Flo.debugf "[/calc] Result: %d + %d = %d" a b result;
               (match reply ctx (Printf.sprintf "🧮 %d + %d = %d" a b result) with
                | Ok _ -> Flo.debug "[/calc] ✓"; Ok ()
                | Error e -> Flo.debugf "[/calc] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ())
           | None, _ ->
               (match reply ctx "❌ First argument must be a valid number" with
                | Ok _ -> Ok ()
                | Error e -> Flo.debugf "[/calc] Error: %s" (Format.asprintf "%a" Error.pp e); Ok ())
           | _, None ->
               (match reply ctx "❌ Second argument must be a valid number" with
                | Ok _ -> Ok ()
                | Error e -> Flo.debugf "[/calc] Error: %s" (Format.asprintf "%a" Error.pp e); Ok ()))
    )

  (* /multiply - Command with typed parser using command_with *)
  |> Bot.command_with "multiply" ~desc:"Multiply three numbers"
      Parsers.three_ints_parser
      (fun ctx (a, b, c) ->
        let open Bot.Ctx in
        Flo.debugf "[/multiply] Computing: %d * %d * %d" a b c;

        let result = a * b * c in
        let response = Printf.sprintf "🔢 %d × %d × %d = %d" a b c result in

        match reply ctx response with
        | Ok _ -> Flo.debug "[/multiply] ✓"; Ok ()
        | Error e -> Flo.debugf "[/multiply] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
      )

  (* /greet - Command with single string argument using command_with *)
  |> Bot.command_with "greet" ~desc:"Greet someone"
      Parsers.string_parser
      (fun ctx name ->
        let open Bot.Ctx in
        Flo.debugf "[/greet] Greeting: %s" name;

        let response = Printf.sprintf "👋 Hello, %s! Nice to meet you!" name in

        match reply ctx response with
        | Ok _ -> Flo.debug "[/greet] ✓"; Ok ()
        | Error e -> Flo.debugf "[/greet] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
      )

  (* /check - Command with boolean parser using command_with *)
  |> Bot.command_with "check" ~desc:"Parse boolean value"
      Parsers.bool_parser
      (fun ctx value ->
        let open Bot.Ctx in
        Flo.debugf "[/check] Boolean value: %b" value;

        let response = if value then
          "✅ You said YES! (true)"
        else
          "❌ You said NO! (false)"
        in

        match reply ctx response with
        | Ok _ -> Flo.debug "[/check] ✓"; Ok ()
        | Error e -> Flo.debugf "[/check] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
      )

  (* /remind - Command with title and remaining text *)
  |> Bot.command "remind" ~desc:"Create reminder" (fun ctx args ->
      let open Bot.Ctx in
      Flo.debug "[/remind] Processing reminder";

      match args with
      | [] ->
          Flo.debug "[/remind] No arguments";
          (match reply ctx "Usage: /remind <title> <note...>\n\nExample: /remind Meeting Discuss project timeline" with
           | Ok _ -> Ok ()
           | Error e -> Flo.debugf "[/remind] Error: %s" (Format.asprintf "%a" Error.pp e); Ok ())
      | title :: _ ->
          let note = Bot.Args.join_rest args 1 in
          Flo.debugf "[/remind] Title: %s, Note: %s" title note;

          let response = Printf.sprintf
            "📝 Reminder Created!\n\n\
             Title: %s\n\
             Note: %s\n\n\
             (This is a demo - reminders are not actually saved)"
            title note
          in

          (match reply ctx response with
           | Ok _ -> Flo.debug "[/remind] ✓"; Ok ()
           | Error e -> Flo.debugf "[/remind] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ())
    )

  (* /square - Command using int_parser with command_with *)
  |> Bot.command_with "square" ~desc:"Square a number"
      Parsers.int_parser
      (fun ctx n ->
        let open Bot.Ctx in
        Flo.debugf "[/square] Computing: %d²" n;

        let result = n * n in
        let response = Printf.sprintf "📐 %d² = %d" n result in

        match reply ctx response with
        | Ok _ -> Flo.debug "[/square] ✓"; Ok ()
        | Error e -> Flo.debugf "[/square] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
      )

  (* /subtract - Command using two_ints_parser with command_with *)
  |> Bot.command_with "subtract" ~desc:"Subtract two numbers"
      Parsers.two_ints_parser
      (fun ctx (a, b) ->
        let open Bot.Ctx in
        Flo.debugf "[/subtract] Computing: %d - %d" a b;

        let result = a - b in
        let response = Printf.sprintf "➖ %d - %d = %d" a b result in

        match reply ctx response with
        | Ok _ -> Flo.debug "[/subtract] ✓"; Ok ()
        | Error e -> Flo.debugf "[/subtract] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
      )

  (* /info - Show bot information *)
  |> Bot.command "info" ~desc:"Show bot information" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/info] Showing bot info";

      let info_text =
        "ℹ️ Command DSL Demo Bot\n\n\
         🔧 Features Demonstrated:\n\
         • Basic commands (/start, /help)\n\
         • Raw argument parsing (/echo, /calc)\n\
         • Typed parsers with command_with (/multiply, /greet, /check)\n\
         • Remaining arguments (/remind)\n\
         • Argument helpers (expect_1, expect_2, parse_int, parse_bool)\n\
         • Builder pattern API\n\
         • Functor-based verbose logging\n\n\
         📚 Try /help to see all commands!"
      in

      match reply ctx info_text with
      | Ok _ -> Flo.debug "[/info] ✓"; Ok ()
      | Error e -> Flo.debugf "[/info] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  |> Bot.run
