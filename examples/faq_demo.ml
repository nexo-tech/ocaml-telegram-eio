(** FAQ Demo - Interactive Frequently Asked Questions bot

    This example demonstrates FAQ bot patterns with comprehensive answers:
    - Interactive FAQ navigation with categories
    - Search functionality
    - Code examples in answers
    - Troubleshooting guides
    - Quick answers to common questions

    Commands:
      /start - Show FAQ main menu
      /faq - Browse all FAQs
      /search <query> - Search FAQ
      /troubleshooting - Common issues
      /general - General questions
      /installation - Installation & setup
      /usage - Usage questions
      /architecture - Architecture questions

    This example demonstrates FAQ BOT PATTERNS with verbose logging.

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/faq_demo.exe
*)

open Telegram
open Tg

(* Configure verbose logging via functor composition *)
module Verbose_log = Log.Make (Log.Console) (struct
  let src = "FAQ"
  let level = Log.Debug
end)

module Verbose_session = Session.Make (Verbose_log)
module Verbose_polling = Polling.Make (Verbose_log)
module Verbose_bot = Bot.Make (Verbose_log) (Verbose_session) (Verbose_polling)

module KB = Keyboard

(** FAQ entries *)
type faq_entry = {
  id: string;
  question: string;
  answer: string;
  category: string;
  keywords: string list;
}

(** FAQ database *)
module FAQ = struct
  let entries = [
    { id = "what_is";
      question = "What is ocaml-telegram-eio?";
      answer = "📚 ocaml-telegram-eio is a production-grade Telegram Bot API client for OCaml 5.x using Eio.\n\n\
                <b>Features:</b>\n\
                • Type-safe API with phantom types\n\
                • Direct-style concurrency (no monads!)\n\
                • 449 types, 232 methods (auto-generated)\n\
                • Streaming file uploads\n\
                • Forward compatible";
      category = "General";
      keywords = ["about"; "library"; "intro"] };

    { id = "why_eio";
      question = "Why Eio instead of Lwt/Async?";
      answer = "⚡ <b>Eio Advantages:</b>\n\n\
                1. Direct-style code (no let%lwt)\n\
                2. Structured concurrency (automatic cleanup)\n\
                3. Better performance\n\
                4. Natural backpressure\n\
                5. OCaml 5.x effects\n\n\
                <code>\n\
                (* Lwt *)\n\
                let%lwt r = fetch () in\n\
                Lwt.return r\n\n\
                (* Eio - direct! *)\n\
                let r = fetch () in\n\
                r\n\
                </code>";
      category = "General";
      keywords = ["eio"; "lwt"; "async"; "concurrency"] };

    { id = "ocaml_version";
      question = "What OCaml version do I need?";
      answer = "🔧 <b>OCaml 5.1 or later</b>\n\n\
                Required because:\n\
                • Eio needs effects support\n\
                • Library uses modern features\n\n\
                Check your version:\n\
                <code>ocaml --version</code>";
      category = "Installation";
      keywords = ["ocaml"; "version"; "requirement"] };

    { id = "installation";
      question = "How do I install it?";
      answer = "📦 <b>Installation Steps:</b>\n\n\
                <code>\n\
                # Clone repository\n\
                git clone https://github.com/user/ocaml-telegram-eio\n\
                cd ocaml-telegram-eio\n\n\
                # Install dependencies\n\
                opam install --deps-only .\n\n\
                # Build\n\
                dune build\n\n\
                # Run examples\n\
                export TELEGRAM_BOT_TOKEN=\"token\"\n\
                dune exec examples/echo_bot.exe\n\
                </code>";
      category = "Installation";
      keywords = ["install"; "setup"; "clone"; "build"] };

    { id = "get_token";
      question = "Where do I get a bot token?";
      answer = "🤖 <b>Get Bot Token:</b>\n\n\
                1. Talk to @BotFather on Telegram\n\
                2. Send /newbot\n\
                3. Follow instructions\n\
                4. Copy the token\n\
                5. Set environment variable:\n\n\
                <code>\n\
                export TELEGRAM_BOT_TOKEN=\"123:ABC-DEF\"\n\
                </code>\n\n\
                ⚠️ Never commit tokens to git!";
      category = "Installation";
      keywords = ["token"; "botfather"; "api"; "key"] };

    { id = "simple_bot";
      question = "How do I create a simple bot?";
      answer = "🎯 <b>Minimal Echo Bot:</b>\n\n\
                <code>\n\
                let () = Eio_main.run @@ fun env -&gt;\n\
                  let token = Sys.getenv \"TELEGRAM_BOT_TOKEN\" in\n\
                  let client = Telegram.Client.create ~env ~token () in\n\n\
                  Bot.make ~env ~client\n\
                  |&gt; Bot.command \"start\" (fun ctx _ -&gt;\n\
                      Bot.Ctx.reply ctx \"Hello!\")\n\
                  |&gt; Bot.on_text (fun ctx text -&gt;\n\
                      Bot.Ctx.reply ctx (\"Echo: \" ^ text))\n\
                  |&gt; Bot.run\n\
                </code>";
      category = "Usage";
      keywords = ["simple"; "echo"; "example"; "basic"] };

    { id = "send_photos";
      question = "How do I send photos?";
      answer = "📷 <b>Sending Photos:</b>\n\n\
                <code>\n\
                (* From file path *)\n\
                send_photo client ~chat_id\n\
                  ~photo:\"photo.jpg\"\n\
                  ~caption:\"My photo\" ()\n\n\
                (* From URL *)\n\
                send_photo client ~chat_id\n\
                  ~photo:\"https://example.com/pic.jpg\" ()\n\n\
                (* By file_id *)\n\
                send_photo client ~chat_id\n\
                  ~photo:\"AgACAgIAA...\" ()\n\
                </code>";
      category = "Usage";
      keywords = ["photo"; "image"; "send"; "file"] };

    { id = "keyboards";
      question = "How do I create keyboards?";
      answer = "⌨️ <b>Keyboard Types:</b>\n\n\
                <b>Inline keyboard:</b>\n\
                <code>\n\
                let kb = Keyboard.inline [\n\
                  [Keyboard.callback ~text:\"A\" ~data:\"opt_a\"];\n\
                  [Keyboard.callback ~text:\"B\" ~data:\"opt_b\"];\n\
                ]\n\
                </code>\n\n\
                <b>Reply keyboard:</b>\n\
                <code>\n\
                let kb = Keyboard.reply [\n\
                  [\"Button 1\"; \"Button 2\"];\n\
                  [\"Button 3\"];\n\
                ]\n\
                </code>";
      category = "Usage";
      keywords = ["keyboard"; "buttons"; "inline"; "reply"] };

    { id = "no_updates";
      question = "My bot isn't receiving updates";
      answer = "❌ <b>Troubleshooting:</b>\n\n\
                1. Check token with /getMe\n\
                2. Delete webhook:\n\
                   <code>delete_webhook client ()</code>\n\
                3. Verify polling is running\n\
                4. Check for other bot instances\n\
                5. Look for error messages in logs";
      category = "Troubleshooting";
      keywords = ["not receiving"; "no updates"; "polling"; "webhook"] };

    { id = "conflict_error";
      question = "I get 'Conflict: terminated by other getUpdates'";
      answer = "⚠️ <b>Conflict Error:</b>\n\n\
                <b>Cause:</b> Multiple polling instances\n\n\
                <b>Solutions:</b>\n\
                1. Stop other bot instances\n\
                2. Delete webhook:\n\
                   <code>delete_webhook client ()</code>\n\
                3. Ensure one polling loop per token";
      category = "Troubleshooting";
      keywords = ["conflict"; "getupdates"; "multiple"; "instances"] };

    { id = "telegram_tg";
      question = "What's the difference between Telegram.* and Tg.*?";
      answer = "📦 <b>Module Organization:</b>\n\n\
                <b>Telegram.*</b> - Low-level generated API:\n\
                • Telegram.Client - HTTP client\n\
                • Telegram.Id - Phantom-typed IDs\n\
                • Telegram_generated.Gen_methods - All API methods\n\n\
                <b>Tg.*</b> - High-level DSL:\n\
                • Tg.Bot - Builder pattern DSL\n\
                • Tg.Keyboard - Keyboard helpers\n\
                • Tg.Polling - Polling runner\n\n\
                <b>Recommendation:</b> Use Gen_methods for stability";
      category = "Architecture";
      keywords = ["telegram"; "tg"; "modules"; "namespace"] };

    { id = "phantom_types";
      question = "What are phantom types?";
      answer = "🔑 <b>Phantom Types:</b>\n\n\
                Type parameters that provide compile-time safety:\n\n\
                <code>\n\
                type +'k t\n\n\
                (* 'k is phantom - not in runtime *)\n\
                Chat.k Id.t  (* For chats *)\n\
                User.k Id.t  (* For users *)\n\
                </code>\n\n\
                <b>Benefits:</b>\n\
                • Can't mix chat/user IDs\n\
                • Self-documenting\n\
                • Zero runtime overhead\n\
                • Compile-time errors";
      category = "Architecture";
      keywords = ["phantom"; "types"; "safety"; "ids"] };
  ]

  let all_categories () =
    entries
    |> List.map (fun e -> e.category)
    |> List.sort_uniq compare

  let by_category category =
    List.filter (fun e -> e.category = category) entries

  let contains_substring s sub =
    try
      let _ = Str.search_forward (Str.regexp_string sub) s 0 in
      true
    with Not_found -> false

  let search query =
    let q_lower = String.lowercase_ascii query in
    List.filter (fun e ->
      let question_match = contains_substring (String.lowercase_ascii e.question) q_lower in
      let answer_match = contains_substring (String.lowercase_ascii e.answer) q_lower in
      let keyword_match = List.exists (fun k ->
        contains_substring (String.lowercase_ascii k) q_lower
      ) e.keywords in

      question_match || answer_match || keyword_match
    ) entries

  let find_by_id id =
    List.find_opt (fun e -> e.id = id) entries
end

let () =
  Printexc.record_backtrace true;
  Eio.traceln "=== FAQ Demo Starting ===";

  let token = match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None -> Printf.eprintf "TELEGRAM_BOT_TOKEN not set\n"; exit 1
  in

  Eio_main.run @@ fun env ->
  let client = Client.create ~env ~token () in

  Eio.traceln "🤖 FAQ Demo Started";
  Eio.traceln "FAQ entries loaded: %d" (List.length FAQ.entries);

  let session_store = Verbose_session.Memory_store.create () in

  Verbose_bot.make ~env ~client
  |> Verbose_bot.with_sessions (module Verbose_session.Memory_store) session_store

  (* /start - Main menu *)
  |> Verbose_bot.command "start" ~desc:"Show FAQ main menu" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/start] Showing FAQ main menu";

      let categories = FAQ.all_categories () in
      let cat_buttons = List.map (fun cat ->
        [KB.callback ~text:cat ~data:("category:" ^ cat)]
      ) categories in

      let keyboard = KB.inline (cat_buttons @ [
        [KB.callback ~text:"🔍 Search FAQ" ~data:"action:search_prompt"];
        [KB.callback ~text:"📋 Browse All" ~data:"action:browse_all"];
      ]) in

      let text =
        "❓ <b>Frequently Asked Questions</b>\n\n\
         Browse FAQ by category or search:\n\n\
         📚 Choose a category or action below."
      in

      match send ~keyboard ctx text with
      | Ok _ -> Eio.traceln "[/start] ✓"; Ok ()
      | Error e -> Eio.traceln "[/start] ✗ %a" Error.pp e; Ok ()
    )

  (* /search - Search FAQ *)
  |> Verbose_bot.command "search" ~desc:"Search FAQ" (fun ctx args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/search] Searching FAQ";

      match args with
      | [] ->
          (match reply ctx "Usage: /search <query>\n\nExample: /search keyboard" with
           | Ok _ -> Ok ()
           | Error e -> Eio.traceln "[/search] ✗ %a" Error.pp e; Ok ())

      | _ ->
          let query = String.concat " " args in
          let results = FAQ.search query in

          Eio.traceln "[/search] Found %d results for: %s" (List.length results) query;

          if List.length results = 0 then
            (match reply ctx (Printf.sprintf "No FAQ found for: %s" query) with
             | Ok _ -> Ok ()
             | Error e -> Eio.traceln "[/search] ✗ %a" Error.pp e; Ok ())
          else
            let result_buttons = List.map (fun e ->
              [KB.callback ~text:e.question ~data:("faq:" ^ e.id)]
            ) results in

            let keyboard = KB.inline result_buttons in

            let text = Printf.sprintf
              "🔍 <b>Search Results</b>\n\n\
               Query: %s\n\
               Found: %d FAQs"
              query (List.length results)
            in

            (match send ~keyboard ctx text with
             | Ok _ -> Eio.traceln "[/search] ✓"; Ok ()
             | Error e -> Eio.traceln "[/search] ✗ %a" Error.pp e; Ok ())
    )

  (* /troubleshooting - Quick troubleshooting *)
  |> Verbose_bot.command "troubleshooting" ~desc:"Common issues" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/troubleshooting] Showing troubleshooting";

      let troubleshooting_faqs = FAQ.by_category "Troubleshooting" in

      let faq_buttons = List.map (fun e ->
        [KB.callback ~text:e.question ~data:("faq:" ^ e.id)]
      ) troubleshooting_faqs in

      let keyboard = KB.inline faq_buttons in

      let text = Printf.sprintf
        "🔧 <b>Troubleshooting</b>\n\n\
         Common issues and solutions:\n\
         %d topics available"
        (List.length troubleshooting_faqs)
      in

      match send ~keyboard ctx text with
      | Ok _ -> Eio.traceln "[/troubleshooting] ✓"; Ok ()
      | Error e -> Eio.traceln "[/troubleshooting] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: category:<name> *)
  |> Verbose_bot.on_callback (fun ctx data ->
      if String.starts_with ~prefix:"category:" data then (
        let open Verbose_bot.Ctx in
        let category = String.sub data 9 (String.length data - 9) in

        Eio.traceln "[category] Filtering by: %s" category;

        let faqs = FAQ.by_category category in

        let faq_buttons = List.map (fun e ->
          [KB.callback ~text:e.question ~data:("faq:" ^ e.id)]
        ) faqs in

        let keyboard = KB.inline (faq_buttons @ [
          [KB.callback ~text:"← Back to Categories" ~data:"action:categories"];
        ]) in

        let text = Printf.sprintf
          "📂 <b>%s</b>\n\n\
           %d questions in this category:"
          category (List.length faqs)
        in

        (match edit ~keyboard ctx text with
         | Ok () -> Ok ()
         | Error e -> Eio.traceln "[category] ✗ %a" Error.pp e; Ok ())
      ) else Ok ()
    )

  (* Callback: faq:<id> *)
  |> Verbose_bot.on_callback (fun ctx data ->
      if String.starts_with ~prefix:"faq:" data then (
        let open Verbose_bot.Ctx in
        let id = String.sub data 4 (String.length data - 4) in

        Eio.traceln "[faq] Showing FAQ: %s" id;

        match FAQ.find_by_id id with
        | Some entry ->
            let text = Printf.sprintf
              "❓ <b>%s</b>\n\n%s"
              entry.question
              entry.answer
            in

            let keyboard = KB.inline [
              [KB.callback ~text:("← Back to " ^ entry.category) ~data:("category:" ^ entry.category)];
            ] in

            (match edit ~keyboard ctx text with
             | Ok () -> Eio.traceln "[faq] ✓"; Ok ()
             | Error e -> Eio.traceln "[faq] ✗ %a" Error.pp e; Ok ())

        | None ->
            (match edit ctx "❌ FAQ not found" with
             | Ok () -> Ok ()
             | Error e -> Eio.traceln "[faq] ✗ %a" Error.pp e; Ok ())
      ) else Ok ()
    )

  (* Callback: action:categories *)
  |> Verbose_bot.on_callback_data "action:categories" (fun ctx ->
      let open Verbose_bot.Ctx in

      let categories = FAQ.all_categories () in
      let cat_buttons = List.map (fun cat ->
        [KB.callback ~text:cat ~data:("category:" ^ cat)]
      ) categories in

      let keyboard = KB.inline cat_buttons in

      match edit ~keyboard ctx "📂 <b>FAQ Categories</b>\n\nChoose a category:" with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[action:categories] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: action:browse_all *)
  |> Verbose_bot.on_callback_data "action:browse_all" (fun ctx ->
      let open Verbose_bot.Ctx in

      let all_faqs = FAQ.entries in

      let faq_buttons = List.map (fun e ->
        [KB.callback ~text:(e.category ^ ": " ^ e.question) ~data:("faq:" ^ e.id)]
      ) all_faqs in

      let keyboard = KB.inline faq_buttons in

      let text = Printf.sprintf
        "📋 <b>All FAQs</b>\n\n\
         Total: %d questions"
        (List.length all_faqs)
      in

      match edit ~keyboard ctx text with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[action:browse_all] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: action:search_prompt *)
  |> Verbose_bot.on_callback_data "action:search_prompt" (fun ctx ->
      let open Verbose_bot.Ctx in

      match edit ctx
        "🔍 <b>Search FAQ</b>\n\n\
         Use the /search command:\n\n\
         <code>/search &lt;query&gt;</code>\n\n\
         Examples:\n\
         • /search keyboard\n\
         • /search photo\n\
         • /search eio"
      with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[action:search_prompt] ✗ %a" Error.pp e; Ok ()
    )

  |> Verbose_bot.run
