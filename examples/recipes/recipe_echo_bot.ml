(** Recipe: Echo Bot with Transformations and Styles

    This example demonstrates echo bot patterns from recipe_echo_bot.mld:
    - Text transformations (uppercase, lowercase, reverse, l33t speak, etc.)
    - Formatting styles (plain, bold, italic, code, quote)
    - Session-based user preferences
    - Smart context-aware responses
    - Message statistics tracking

    This example has VERBOSE LOGGING enabled to help troubleshoot issues.
    Every step is logged to stderr so you can see exactly what's happening.

    Commands:
      /start - Welcome message with feature list
      /help - Show available commands
      /transform <type> - Set text transformation
      /style <type> - Set formatting style
      /stats - Show message statistics
      /reset - Reset all preferences
      <any text> - Echo with current transform + style

    Available transformations:
      upper, lower, reverse, l33t, novowels, count, freq

    Available styles:
      plain, bold, italic, code, quote

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/recipe_echo_bot.exe

    What you'll see in the logs:
      - Bot initialization and session setup
      - Route registration for each command
      - Session state management (get/set preferences)
      - Transformation and styling application
      - Statistics tracking
*)

open Telegram
open Tg

(* Configure verbose logging via functor composition *)
module Verbose_log = Log.Make (Log.Console) (struct
  let src = "EchoBot"
  let level = Log.Debug  (* Enable debug logging *)
end)

module Verbose_session = Session.Make (Verbose_log)
module Verbose_polling = Polling.Make (Verbose_log)
module Verbose_bot = Bot.Make (Verbose_log) (Verbose_session) (Verbose_polling)

(** Text transformation logic - pure functions *)
module Transform = struct
  type t =
    | Uppercase
    | Lowercase
    | Reverse
    | L33t
    | Remove_vowels
    | Word_count
    | Character_frequency

  let to_string = function
    | Uppercase -> "uppercase"
    | Lowercase -> "lowercase"
    | Reverse -> "reverse"
    | L33t -> "l33t"
    | Remove_vowels -> "novowels"
    | Word_count -> "count"
    | Character_frequency -> "freq"

  let of_string = function
    | "upper" | "uppercase" -> Some Uppercase
    | "lower" | "lowercase" -> Some Lowercase
    | "reverse" -> Some Reverse
    | "l33t" | "leet" -> Some L33t
    | "novowels" | "rmvowels" -> Some Remove_vowels
    | "count" | "wc" -> Some Word_count
    | "freq" | "charfreq" -> Some Character_frequency
    | _ -> None

  let uppercase text =
    String.uppercase_ascii text

  let lowercase text =
    String.lowercase_ascii text

  let reverse text =
    String.to_seq text
    |> List.of_seq
    |> List.rev
    |> List.to_seq
    |> String.of_seq

  let l33t_speak text =
    let replace c =
      match c with
      | 'a' | 'A' -> '4'
      | 'e' | 'E' -> '3'
      | 'i' | 'I' -> '1'
      | 'o' | 'O' -> '0'
      | 's' | 'S' -> '5'
      | 't' | 'T' -> '7'
      | _ -> c
    in
    String.map replace text

  let remove_vowels text =
    let is_vowel c =
      match Char.lowercase_ascii c with
      | 'a' | 'e' | 'i' | 'o' | 'u' -> true
      | _ -> false
    in
    String.to_seq text
    |> Seq.filter (fun c -> not (is_vowel c))
    |> String.of_seq

  let word_count text =
    let words = String.split_on_char ' ' text
                |> List.filter (fun w -> w <> "") in
    Printf.sprintf "📊 Word Count: %d\n\nWords:\n%s"
      (List.length words)
      (String.concat "\n• " words)

  let character_frequency text =
    let freq = Hashtbl.create 26 in
    String.iter (fun c ->
      let count = Hashtbl.find_opt freq c |> Option.value ~default:0 in
      Hashtbl.replace freq c (count + 1)
    ) text;

    let sorted = Hashtbl.to_seq freq
      |> List.of_seq
      |> List.sort (fun (_, a) (_, b) -> compare b a)
    in

    let lines = sorted |> List.map (fun (c, count) ->
      Printf.sprintf "%c: %d" c count
    ) in

    "📊 Character Frequency:\n" ^ String.concat "\n" lines

  let apply transform text =
    match transform with
    | Uppercase -> uppercase text
    | Lowercase -> lowercase text
    | Reverse -> reverse text
    | L33t -> l33t_speak text
    | Remove_vowels -> remove_vowels text
    | Word_count -> word_count text
    | Character_frequency -> character_frequency text
end

(** Formatting styles *)
module Style = struct
  type t =
    | Plain
    | Bold
    | Italic
    | Code
    | Quote

  let to_string = function
    | Plain -> "plain"
    | Bold -> "bold"
    | Italic -> "italic"
    | Code -> "code"
    | Quote -> "quote"

  let of_string = function
    | "plain" -> Some Plain
    | "bold" -> Some Bold
    | "italic" -> Some Italic
    | "code" -> Some Code
    | "quote" -> Some Quote
    | _ -> None

  let escape_html text =
    let replace_char c =
      match c with
      | '<' -> "&lt;"
      | '>' -> "&gt;"
      | '&' -> "&amp;"
      | '"' -> "&quot;"
      | _ -> String.make 1 c
    in
    String.to_seq text
    |> Seq.map replace_char
    |> List.of_seq
    |> String.concat ""

  let apply style text =
    match style with
    | Plain -> text
    | Bold -> Printf.sprintf "<b>%s</b>" (escape_html text)
    | Italic -> Printf.sprintf "<i>%s</i>" (escape_html text)
    | Code -> Printf.sprintf "<code>%s</code>" (escape_html text)
    | Quote ->
        let lines = String.split_on_char '\n' text in
        lines
        |> List.map (fun line -> "❝ " ^ line)
        |> String.concat "\n"
end

(** Smart echo logic - context-aware responses *)
module Smart = struct
  let contains_substring haystack needle =
    try
      let _ = Str.search_forward (Str.regexp_string needle) haystack 0 in
      true
    with Not_found -> false

  let get_prefix text =
    let text_lower = String.lowercase_ascii text in

    (* Question detection *)
    if String.contains text '?' then
      "🤔"

    (* Greeting detection *)
    else if String.starts_with ~prefix:"hello" text_lower
         || String.starts_with ~prefix:"hi" text_lower then
      "👋"

    (* Gratitude detection *)
    else if contains_substring text_lower "thank" then
      "😊"

    (* Farewell detection *)
    else if String.starts_with ~prefix:"bye" text_lower
         || String.starts_with ~prefix:"goodbye" text_lower then
      "👋"

    (* Excitement detection *)
    else if String.contains text '!' then
      "🎉"

    (* Default *)
    else
      "📝"
end

let () =
  Eio.traceln "=== Recipe: Echo Bot Starting ===";
  Eio.traceln "[Init] Loading configuration...";

  let token =
    match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t ->
        Eio.traceln "[Init] ✓ Bot token loaded from TELEGRAM_BOT_TOKEN";
        Eio.traceln "[Init]   Token: %s...%s (length=%d)"
          (String.sub t 0 (min 8 (String.length t)))
          (if String.length t > 8 then String.sub t (String.length t - 4) 4 else "")
          (String.length t);
        t
    | None ->
        Eio.traceln "[Init] ✗ TELEGRAM_BOT_TOKEN environment variable not set";
        Printf.eprintf "Error: TELEGRAM_BOT_TOKEN not set\n";
        exit 1
  in

  Eio.traceln "[Init] Starting Eio event loop...";
  Eio_main.run @@ fun env ->

  Eio.traceln "[Init] Creating Telegram HTTP client...";
  let client = Client.create ~env ~token () in
  Eio.traceln "[Init] ✓ HTTP client created (base_url=%s)" (Client.base_url client);

  Eio.traceln "";
  Eio.traceln "🤖 Echo Bot with Transformations Started!";
  Eio.traceln "";
  Eio.traceln "📋 Features:";
  Eio.traceln "   • Text transformations (upper, lower, reverse, l33t, etc.)";
  Eio.traceln "   • Formatting styles (plain, bold, italic, code, quote)";
  Eio.traceln "   • Session-based user preferences";
  Eio.traceln "   • Smart context-aware prefixes";
  Eio.traceln "   • Message statistics tracking";
  Eio.traceln "";
  Eio.traceln "🔍 Watching for updates (long polling)...";
  Eio.traceln "";

  (* Session keys for user preferences *)
  let transform_key = Verbose_session.make ~name:"transform" in
  let style_key = Verbose_session.make ~name:"style" in
  let count_key = Verbose_session.make ~name:"echo_count" in

  (* Build bot using functional builder pattern *)
  Eio.traceln "[Builder] Building bot with functional API...";
  Verbose_bot.make ~env ~client
  (* Add global error handler *)
  |> Verbose_bot.on_error (fun ctx exn ->
      Eio.traceln "";
      Eio.traceln "[Error] ❌❌❌ Uncaught error in handler ❌❌❌";
      Eio.traceln "[Error] Error: %s" (Printexc.to_string exn);
      Eio.traceln "[Error] User: %s"
        (match Verbose_bot.Ctx.user ctx with
         | Some u -> Printf.sprintf "id=%s username=%s"
             (Id.to_string u.id)
             (Option.value ~default:"<none>" u.username)
         | None -> "none");
      match Verbose_bot.Ctx.reply ctx "❌ Sorry, an error occurred. Please try again." with
      | Ok _ -> Eio.traceln "[Error] ✓ Error notification sent"
      | Error e -> Eio.traceln "[Error] ✗ Failed to send error: %a" Error.pp e;
      Eio.traceln "";
    )

  (* /start command *)
  |> (fun bot -> Eio.traceln "[Builder] Registering route: command 'start'"; bot)
  |> Verbose_bot.command "start" ~desc:"Welcome message" (fun ctx _args ->
      Eio.traceln "";
      Eio.traceln "[Handler:start] >>> /start command received";

      let open Verbose_bot.Ctx in
      let* () = reply_ ctx
        "👋 Welcome to Echo Bot Plus!\n\n\
         ✨ Features:\n\
         • Text transformations\n\
         • Formatting styles\n\
         • Smart context awareness\n\
         • Statistics tracking\n\n\
         📝 Commands:\n\
         /transform <type> - Set transformation\n\
         /style <type> - Set formatting style\n\
         /stats - Show your statistics\n\
         /reset - Reset preferences\n\
         /help - Show detailed help\n\n\
         💬 Send me any message to try it out!" in
      Eio.traceln "[Handler:start] <<< /start completed";
      Eio.traceln "";
      Ok ()
    )

  (* /help command *)
  |> (fun bot -> Eio.traceln "[Builder] Registering route: command 'help'"; bot)
  |> Verbose_bot.command "help" ~desc:"Show help" (fun ctx _args ->
      Eio.traceln "";
      Eio.traceln "[Handler:help] >>> /help command received";

      let open Verbose_bot.Ctx in
      let* () = reply_ ctx
        "📖 Echo Bot Help\n\n\
         🔄 Transformations:\n\
         /transform upper - UPPERCASE\n\
         /transform lower - lowercase\n\
         /transform reverse - esrever\n\
         /transform l33t - 1337 5p34k\n\
         /transform novowels - rmv vwls\n\
         /transform count - Word count\n\
         /transform freq - Character frequency\n\n\
         🎨 Styles:\n\
         /style plain - Normal text\n\
         /style bold - <b>Bold text</b>\n\
         /style italic - <i>Italic text</i>\n\
         /style code - <code>Code text</code>\n\
         /style quote - ❝ Quoted text\n\n\
         📊 Other:\n\
         /stats - View statistics\n\
         /reset - Reset all settings" in
      Eio.traceln "[Handler:help] <<< /help completed";
      Eio.traceln "";
      Ok ()
    )

  (* /transform command *)
  |> (fun bot -> Eio.traceln "[Builder] Registering route: command 'transform'"; bot)
  |> Verbose_bot.command "transform" ~desc:"Set text transformation" (fun ctx args ->
      Eio.traceln "";
      Eio.traceln "[Handler:transform] >>> /transform command received";
      Eio.traceln "[Handler:transform] Args: %s" (String.concat " " args);

      let open Verbose_bot.Ctx in
      let* () =
        match Bot.Args.expect_1 args with
        | Some transform_str ->
            Eio.traceln "[Handler:transform] Parsing transform: '%s'" transform_str;
            (match Transform.of_string transform_str with
             | Some transform ->
                 Eio.traceln "[Handler:transform] ✓ Valid transform: %s" (Transform.to_string transform);
                 session_set ctx transform_key transform;
                 Eio.traceln "[Handler:transform] Session updated with new transform";
                 let response = match transform with
                   | Uppercase -> "✓ Transformation: UPPERCASE"
                   | Lowercase -> "✓ Transformation: lowercase"
                   | Reverse -> "✓ Transformation: esrever"
                   | L33t -> "✓ 7r4n5f0rm4710n: 1337"
                   | Remove_vowels -> "✓ Trnsfrmtn: rmv vwls"
                   | Word_count -> "✓ Transformation: word count"
                   | Character_frequency -> "✓ Transformation: char frequency"
                 in
                 reply_ ctx response
             | None ->
                 Eio.traceln "[Handler:transform] ✗ Invalid transform: '%s'" transform_str;
                 reply_ ctx
                   "❌ Invalid transformation\n\n\
                    Available: upper, lower, reverse, l33t, novowels, count, freq")
        | None ->
            Eio.traceln "[Handler:transform] ✗ No argument provided";
            reply_ ctx "Usage: /transform <upper|lower|reverse|l33t|novowels|count|freq>"
      in
      Eio.traceln "[Handler:transform] <<< /transform completed";
      Eio.traceln "";
      Ok ()
    )

  (* /style command *)
  |> (fun bot -> Eio.traceln "[Builder] Registering route: command 'style'"; bot)
  |> Verbose_bot.command "style" ~desc:"Set formatting style" (fun ctx args ->
      Eio.traceln "";
      Eio.traceln "[Handler:style] >>> /style command received";
      Eio.traceln "[Handler:style] Args: %s" (String.concat " " args);

      let open Verbose_bot.Ctx in
      let* () =
        match Bot.Args.expect_1 args with
        | Some style_str ->
            Eio.traceln "[Handler:style] Parsing style: '%s'" style_str;
            (match Style.of_string style_str with
             | Some style ->
                 Eio.traceln "[Handler:style] ✓ Valid style: %s" (Style.to_string style);
                 session_set ctx style_key style;
                 Eio.traceln "[Handler:style] Session updated with new style";
                 let response = match style with
                   | Plain -> "✓ Style: plain text"
                   | Bold -> "✓ Style: <b>bold</b>"
                   | Italic -> "✓ Style: <i>italic</i>"
                   | Code -> "✓ Style: <code>code</code>"
                   | Quote -> "✓ Style: ❝ quote"
                 in
                 reply_ ctx response
             | None ->
                 Eio.traceln "[Handler:style] ✗ Invalid style: '%s'" style_str;
                 reply_ ctx
                   "❌ Invalid style\n\n\
                    Available: plain, bold, italic, code, quote")
        | None ->
            Eio.traceln "[Handler:style] ✗ No argument provided";
            reply_ ctx "Usage: /style <plain|bold|italic|code|quote>"
      in
      Eio.traceln "[Handler:style] <<< /style completed";
      Eio.traceln "";
      Ok ()
    )

  (* /stats command *)
  |> (fun bot -> Eio.traceln "[Builder] Registering route: command 'stats'"; bot)
  |> Verbose_bot.command "stats" ~desc:"Show statistics" (fun ctx _args ->
      Eio.traceln "";
      Eio.traceln "[Handler:stats] >>> /stats command received";

      let count = Verbose_bot.Ctx.session_get_or ctx count_key ~default:0 in
      Eio.traceln "[Handler:stats] Message count: %d" count;

      let transform = Verbose_bot.Ctx.session_get_or ctx transform_key ~default:Transform.Uppercase in
      let style = Verbose_bot.Ctx.session_get_or ctx style_key ~default:Style.Plain in
      Eio.traceln "[Handler:stats] Current transform: %s, style: %s"
        (Transform.to_string transform) (Style.to_string style);

      let open Verbose_bot.Ctx in
      let* () = reply_ ctx
        (Printf.sprintf
          "📊 Your Statistics:\n\n\
           Messages echoed: %d\n\
           Transform: %s\n\
           Style: %s"
          count
          (Transform.to_string transform)
          (Style.to_string style)) in
      Eio.traceln "[Handler:stats] <<< /stats completed";
      Eio.traceln "";
      Ok ()
    )

  (* /reset command *)
  |> (fun bot -> Eio.traceln "[Builder] Registering route: command 'reset'"; bot)
  |> Verbose_bot.command "reset" ~desc:"Reset preferences" (fun ctx _args ->
      Eio.traceln "";
      Eio.traceln "[Handler:reset] >>> /reset command received";

      Verbose_bot.Ctx.session_clear ctx;
      Eio.traceln "[Handler:reset] Session cleared";

      let open Verbose_bot.Ctx in
      let* () = reply_ ctx "✓ All preferences reset to defaults" in
      Eio.traceln "[Handler:reset] <<< /reset completed";
      Eio.traceln "";
      Ok ()
    )

  (* on_text handler - echo with transform + style *)
  |> (fun bot -> Eio.traceln "[Builder] Registering route: on_text (echo handler)"; bot)
  |> Verbose_bot.on_text (fun ctx text ->
      Eio.traceln "";
      Eio.traceln "[Handler:echo] >>> Text message received";
      Eio.traceln "[Handler:echo] Text: \"%s\" (length=%d)" text (String.length text);

      (* Track message count *)
      Verbose_bot.Ctx.session_modify ctx count_key ~default:0 (fun n -> n + 1);
      let new_count = Verbose_bot.Ctx.session_get_or ctx count_key ~default:0 in
      Eio.traceln "[Handler:echo] Message count updated: %d" new_count;

      (* Get user preferences *)
      let transform = Verbose_bot.Ctx.session_get_or ctx transform_key ~default:Transform.Uppercase in
      let style = Verbose_bot.Ctx.session_get_or ctx style_key ~default:Style.Plain in
      Eio.traceln "[Handler:echo] Preferences: transform=%s, style=%s"
        (Transform.to_string transform) (Style.to_string style);

      (* Apply transformation *)
      Eio.traceln "[Handler:echo] Applying transformation...";
      let transformed = Transform.apply transform text in
      Eio.traceln "[Handler:echo] Transformed: \"%s\" (length=%d)"
        (if String.length transformed > 50 then String.sub transformed 0 50 ^ "..." else transformed)
        (String.length transformed);

      (* Apply style *)
      Eio.traceln "[Handler:echo] Applying style...";
      let formatted = Style.apply style transformed in

      (* Add smart prefix *)
      let prefix = Smart.get_prefix text in
      Eio.traceln "[Handler:echo] Smart prefix: %s" prefix;
      let response = prefix ^ " " ^ formatted in

      let open Verbose_bot.Ctx in
      let* () = reply_ ctx response in
      Eio.traceln "[Handler:echo] <<< Echo handler completed";
      Eio.traceln "";
      Ok ()
    )

  |> (fun bot ->
      Eio.traceln "[Builder] ✓ All routes registered";
      Eio.traceln "[Builder] Starting bot...";
      Eio.traceln "";
      bot)
  |> Verbose_bot.run
