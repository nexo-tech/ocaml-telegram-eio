(** Recipe: Echo Bot with Transformations and Styles

    This example demonstrates echo bot patterns from recipe_echo_bot.mld:
    - Text transformations (uppercase, lowercase, reverse, l33t speak, etc.)
    - Formatting styles (plain, bold, italic, code, quote)
    - Session-based user preferences
    - Smart context-aware responses
    - Message statistics tracking

    This example has VERBOSE LOGGING enabled to help troubleshoot issues.
    Every step is logged using the flo library with structured fields.

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

(* Configure verbose logging with flo *)
let () = Flo.set_level Severity.Debug

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
  let open Flo in

  info "=== Recipe: Echo Bot Starting ===";
  debug "Loading configuration...";

  let token =
    match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t ->
        success_fields "Bot token loaded" ~fields:[
          ("source", Value.string "TELEGRAM_BOT_TOKEN");
          ("token_length", Value.int (String.length t));
        ];
        debug_fields "Token details" ~fields:[
          ("prefix", Value.string (String.sub t 0 (min 8 (String.length t))));
          ("suffix", Value.string (if String.length t > 8 then String.sub t (String.length t - 4) 4 else ""));
        ];
        t
    | None ->
        fatal "TELEGRAM_BOT_TOKEN environment variable not set";
        Printf.eprintf "Error: TELEGRAM_BOT_TOKEN not set\n";
        exit 1
  in

  debug "Starting Eio event loop...";
  Eio_main.run @@ fun env ->

  debug "Creating Telegram HTTP client...";
  let client = Client.create ~env ~token () in
  success_fields "HTTP client created" ~fields:[
    ("base_url", Value.string (Client.base_url client));
  ];

  info "";
  info "Echo Bot with Transformations Started!";
  info "";
  info "Features:";
  info "   • Text transformations (upper, lower, reverse, l33t, etc.)";
  info "   • Formatting styles (plain, bold, italic, code, quote)";
  info "   • Session-based user preferences";
  info "   • Smart context-aware prefixes";
  info "   • Message statistics tracking";
  info "";
  info "Watching for updates (long polling)...";
  info "";

  (* Session keys for user preferences *)
  let transform_key = Session.make ~name:"transform" in
  let style_key = Session.make ~name:"style" in
  let count_key = Session.make ~name:"echo_count" in

  (* Build bot using functional builder pattern *)
  debug "Building bot with functional API...";
  Bot.make ~env ~client
  (* Add global error handler *)
  |> Bot.on_error (fun ctx exn ->
      error "";
      error_fields "Uncaught error in handler" ~fields:[
        Flo_semconv.error_type (Printexc.to_string exn);
        Flo_semconv.error_message (Printexc.to_string exn);
        Flo_semconv.error_stack_trace (Printexc.get_backtrace ());
        ("user_id", Value.string (match Bot.Ctx.user ctx with
         | Some u -> Id.to_string u.id
         | None -> "none"));
        ("username", Value.string (match Bot.Ctx.user ctx with
         | Some u -> Option.value ~default:"<none>" u.username
         | None -> "<none>"));
      ];
      match Bot.Ctx.reply ctx "Sorry, an error occurred. Please try again." with
      | Ok _ -> success "Error notification sent"
      | Error e -> warn_fields "Failed to send error message" ~fields:[
          Flo_semconv.error_message (Format.asprintf "%a" Error.pp e);
        ];
      error "";
    )

  (* /start command *)
  |> (fun bot -> debug "Registering route: command 'start'"; bot)
  |> Bot.command "start" ~desc:"Welcome message" (fun ctx _args ->
      Flo.with_span "command_start" (fun () ->
        Bot.Ctx.with_handler_context ctx (fun () ->
          info "";
          info "Received /start command";

          let open Bot.Ctx in
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
          success "Handler /start completed";
          info "";
          Ok ()
        )
      )
    )

  (* /help command *)
  |> (fun bot -> debug "Registering route: command 'help'"; bot)
  |> Bot.command "help" ~desc:"Show help" (fun ctx _args ->
      Flo.with_span "command_help" (fun () ->
        Bot.Ctx.with_handler_context ctx (fun () ->
          info "";
          info "Received /help command";

          let open Bot.Ctx in
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
          success "Handler /help completed";
          info "";
          Ok ()
        )
      )
    )

  (* /transform command *)
  |> (fun bot -> debug "Registering route: command 'transform'"; bot)
  |> Bot.command "transform" ~desc:"Set text transformation" (fun ctx args ->
      Flo.with_span "command_transform" (fun () ->
        Bot.Ctx.with_handler_context ctx (fun () ->
          info "";
          info_fields "Received /transform command" ~fields:[
            ("args", Value.string (String.concat " " args));
          ];

          let open Bot.Ctx in
          let* () =
            match Bot.Args.expect_1 args with
            | Some transform_str ->
                debug_fields "Parsing transform" ~fields:[
                  ("transform", Value.string transform_str);
                ];
                (match Transform.of_string transform_str with
                 | Some transform ->
                     success_fields "Valid transform" ~fields:[
                       ("transform", Value.string (Transform.to_string transform));
                     ];
                     session_set ctx transform_key transform;
                     debug "Session updated with new transform";
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
                     warn_fields "Invalid transform" ~fields:[
                       ("transform", Value.string transform_str);
                     ];
                     reply_ ctx
                       "❌ Invalid transformation\n\n\
                        Available: upper, lower, reverse, l33t, novowels, count, freq")
            | None ->
                warn "No argument provided";
                reply_ ctx "Usage: /transform <upper|lower|reverse|l33t|novowels|count|freq>"
          in
          success "Handler /transform completed";
          info "";
          Ok ()
        )
      )
    )

  (* /style command *)
  |> (fun bot -> debug "Registering route: command 'style'"; bot)
  |> Bot.command "style" ~desc:"Set formatting style" (fun ctx args ->
      Flo.with_span "command_style" (fun () ->
        Bot.Ctx.with_handler_context ctx (fun () ->
          info "";
          info_fields "Received /style command" ~fields:[
            ("args", Value.string (String.concat " " args));
          ];

          let open Bot.Ctx in
          let* () =
            match Bot.Args.expect_1 args with
            | Some style_str ->
                debug_fields "Parsing style" ~fields:[
                  ("style", Value.string style_str);
                ];
                (match Style.of_string style_str with
                 | Some style ->
                     success_fields "Valid style" ~fields:[
                       ("style", Value.string (Style.to_string style));
                     ];
                     session_set ctx style_key style;
                     debug "Session updated with new style";
                     let response = match style with
                       | Plain -> "✓ Style: plain text"
                       | Bold -> "✓ Style: <b>bold</b>"
                       | Italic -> "✓ Style: <i>italic</i>"
                       | Code -> "✓ Style: <code>code</code>"
                       | Quote -> "✓ Style: ❝ quote"
                     in
                     reply_ ctx response
                 | None ->
                     warn_fields "Invalid style" ~fields:[
                       ("style", Value.string style_str);
                     ];
                     reply_ ctx
                       "❌ Invalid style\n\n\
                        Available: plain, bold, italic, code, quote")
            | None ->
                warn "No argument provided";
                reply_ ctx "Usage: /style <plain|bold|italic|code|quote>"
          in
          success "Handler /style completed";
          info "";
          Ok ()
        )
      )
    )

  (* /stats command *)
  |> (fun bot -> debug "Registering route: command 'stats'"; bot)
  |> Bot.command "stats" ~desc:"Show statistics" (fun ctx _args ->
      Flo.with_span "command_stats" (fun () ->
        Bot.Ctx.with_handler_context ctx (fun () ->
          info "";
          info "Received /stats command";

          let count = Bot.Ctx.session_get_or ctx count_key ~default:0 in
          debug_fields "Retrieved statistics" ~fields:[
            ("message_count", Value.int count);
          ];

          let transform = Bot.Ctx.session_get_or ctx transform_key ~default:Transform.Uppercase in
          let style = Bot.Ctx.session_get_or ctx style_key ~default:Style.Plain in
          debug_fields "Current preferences" ~fields:[
            ("transform", Value.string (Transform.to_string transform));
            ("style", Value.string (Style.to_string style));
          ];

          let open Bot.Ctx in
          let* () = reply_ ctx
            (Printf.sprintf
              "📊 Your Statistics:\n\n\
               Messages echoed: %d\n\
               Transform: %s\n\
               Style: %s"
              count
              (Transform.to_string transform)
              (Style.to_string style)) in
          success "Handler /stats completed";
          info "";
          Ok ()
        )
      )
    )

  (* /reset command *)
  |> (fun bot -> debug "Registering route: command 'reset'"; bot)
  |> Bot.command "reset" ~desc:"Reset preferences" (fun ctx _args ->
      Flo.with_span "command_reset" (fun () ->
        Bot.Ctx.with_handler_context ctx (fun () ->
          info "";
          info "Received /reset command";

          Bot.Ctx.session_clear ctx;
          debug "Session cleared";

          let open Bot.Ctx in
          let* () = reply_ ctx "✓ All preferences reset to defaults" in
          success "Handler /reset completed";
          info "";
          Ok ()
        )
      )
    )

  (* on_text handler - echo with transform + style *)
  |> (fun bot -> debug "Registering route: on_text (echo handler)"; bot)
  |> Bot.on_text (fun ctx text ->
      Flo.with_span "text_message" (fun () ->
        Bot.Ctx.with_handler_context ctx (fun () ->
          info "";
          info_fields "Text message received" ~fields:[
            ("text_length", Value.int (String.length text));
            ("text_preview", Value.string (if String.length text > 50
              then String.sub text 0 50 ^ "..."
              else text));
          ];

          (* Track message count *)
          Bot.Ctx.session_modify ctx count_key ~default:0 (fun n -> n + 1);
          let new_count = Bot.Ctx.session_get_or ctx count_key ~default:0 in
          debug_fields "Message count updated" ~fields:[
            ("count", Value.int new_count);
          ];

          (* Get user preferences *)
          let transform = Bot.Ctx.session_get_or ctx transform_key ~default:Transform.Uppercase in
          let style = Bot.Ctx.session_get_or ctx style_key ~default:Style.Plain in
          debug_fields "User preferences" ~fields:[
            ("transform", Value.string (Transform.to_string transform));
            ("style", Value.string (Style.to_string style));
          ];

          (* Apply transformation *)
          debug "Applying transformation...";
          let transformed = Transform.apply transform text in
          debug_fields "Transformed text" ~fields:[
            ("length", Value.int (String.length transformed));
            ("preview", Value.string (if String.length transformed > 50
              then String.sub transformed 0 50 ^ "..."
              else transformed));
          ];

          (* Apply style *)
          debug "Applying style...";
          let formatted = Style.apply style transformed in

          (* Add smart prefix *)
          let prefix = Smart.get_prefix text in
          debug_fields "Smart prefix selected" ~fields:[
            ("prefix", Value.string prefix);
          ];
          let response = prefix ^ " " ^ formatted in

          let open Bot.Ctx in
          let* () = reply_ ctx response in
          success "Handler completed successfully";
          info "";
          Ok ()
        )
      )
    )

  |> (fun bot ->
      success "All routes registered";
      debug "Starting bot...";
      info "";
      bot)
  |> Bot.run
