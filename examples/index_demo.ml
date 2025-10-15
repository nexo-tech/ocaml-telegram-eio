(** Index Demo - Interactive documentation index and navigation

    This example demonstrates documentation index patterns:
    - Hierarchical documentation navigation
    - Documentation section organization
    - Quick access to all guides
    - Search across documentation topics
    - Overview and introduction

    Commands:
      /start - Show documentation index
      /overview - Library overview
      /getting_started - Getting started section
      /guides - API guides section
      /advanced - Advanced patterns
      /recipes - Cookbook & recipes
      /usecases - Bot use cases
      /reference - Reference & FAQ
      /search_docs <query> - Search documentation

    This example demonstrates DOCUMENTATION INDEX with verbose logging.

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/index_demo.exe
*)

open Telegram
open Tg

(* Configure verbose logging via functor composition *)
module Verbose_log = Log.Make (Log.Console) (struct
  let src = "DocIndex"
  let level = Log.Debug
end)

module Verbose_session = Session.Make (Verbose_log)
module Verbose_polling = Polling.Make (Verbose_log)
module Verbose_bot = Bot.Make (Verbose_log) (Verbose_session) (Verbose_polling)

module KB = Keyboard

(** Documentation topics *)
type doc_page = {
  id: string;
  title: string;
  description: string;
  section: string;
}

(** Documentation index *)
module DocIndex = struct
  let pages = [
    (* Getting Started *)
    { id = "getting_started"; title = "Getting Started";
      description = "Installation, setup, and your first bot";
      section = "Getting Started" };
    { id = "core_concepts"; title = "Core Concepts";
      description = "Bot lifecycle, updates, Eio concurrency, error handling";
      section = "Getting Started" };
    { id = "quick_start"; title = "Quick Start Tutorial";
      description = "Hands-on tutorials: echo bot, commands, keyboards";
      section = "Getting Started" };

    (* API Guides *)
    { id = "message_handling"; title = "Message Handling";
      description = "Message types, pattern matching, formatting";
      section = "API Guides" };
    { id = "command_dsl"; title = "Command DSL";
      description = "Command routing, argument parsing, middleware";
      section = "API Guides" };
    { id = "keyboard_api"; title = "Keyboard API";
      description = "Reply keyboards, inline keyboards, layouts";
      section = "API Guides" };
    { id = "callback_queries"; title = "Callback Queries";
      description = "Button presses, data encoding, state management";
      section = "API Guides" };
    { id = "media_files"; title = "Media and Files";
      description = "Photos, videos, documents, uploads, downloads";
      section = "API Guides" };

    (* Advanced Patterns *)
    { id = "state_machines"; title = "State Machines";
      description = "Conversation flows, FSM patterns, multi-step interactions";
      section = "Advanced Patterns" };
    { id = "middleware"; title = "Middleware Architecture";
      description = "Request/response middleware, auth, logging";
      section = "Advanced Patterns" };
    { id = "error_handling"; title = "Error Handling";
      description = "Result types, retry logic, graceful degradation";
      section = "Advanced Patterns" };
    { id = "concurrency"; title = "Concurrency Patterns";
      description = "Eio fibers, promises, switches, background tasks";
      section = "Advanced Patterns" };
    { id = "session_mgmt"; title = "Session Management";
      description = "User sessions, storage backends, expiration";
      section = "Advanced Patterns" };

    (* Recipes *)
    { id = "recipe_echo"; title = "Echo Bot Recipe";
      description = "Simple to sophisticated echo bots";
      section = "Recipes" };
    { id = "recipe_keyboard"; title = "Keyboard Bot Recipe";
      description = "Interactive menus, multi-level navigation";
      section = "Recipes" };
    { id = "recipe_file"; title = "File Handling Recipe";
      description = "Document uploads, downloads, albums";
      section = "Recipes" };
    { id = "recipe_payment"; title = "Payment Bot Recipe";
      description = "Invoices, checkout, payments";
      section = "Recipes" };

    (* Use Cases *)
    { id = "utility_bots"; title = "Utility Bots";
      description = "Weather, calculator, unit converter";
      section = "Use Cases" };
    { id = "content_bots"; title = "Content Bots";
      description = "News aggregation, RSS, media libraries";
      section = "Use Cases" };
    { id = "entertainment"; title = "Entertainment Bots";
      description = "Quizzes, trivia, jokes, random facts";
      section = "Use Cases" };
    { id = "integration"; title = "Integration Bots";
      description = "GitHub, CI/CD, database, API gateway";
      section = "Use Cases" };

    (* Reference *)
    { id = "migration"; title = "Migration Guide";
      description = "Migrating from Lwt/Async or other libraries";
      section = "Reference" };
    { id = "faq"; title = "FAQ";
      description = "Frequently asked questions and troubleshooting";
      section = "Reference" };
  ]

  let all_sections () =
    pages
    |> List.map (fun p -> p.section)
    |> List.sort_uniq compare

  let by_section section =
    List.filter (fun p -> p.section = section) pages

  let find_by_id id =
    List.find_opt (fun p -> p.id = id) pages

  let search query =
    let q_lower = String.lowercase_ascii query in
    let contains s sub =
      try
        let _ = Str.search_forward (Str.regexp_string sub) s 0 in
        true
      with Not_found -> false
    in

    List.filter (fun p ->
      let title_match = contains (String.lowercase_ascii p.title) q_lower in
      let desc_match = contains (String.lowercase_ascii p.description) q_lower in
      title_match || desc_match
    ) pages
end

let () =
  Printexc.record_backtrace true;
  Eio.traceln "=== Documentation Index Demo Starting ===";

  let token = match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None -> Printf.eprintf "TELEGRAM_BOT_TOKEN not set\n"; exit 1
  in

  Eio_main.run @@ fun env ->
  let client = Client.create ~env ~token () in

  Eio.traceln "🤖 Documentation Index Demo Started";
  Eio.traceln "Documentation pages: %d" (List.length DocIndex.pages);
  Eio.traceln "Documentation sections: %d" (List.length (DocIndex.all_sections ()));

  let session_store = Verbose_session.Memory_store.create () in

  Verbose_bot.make ~env ~client
  |> Verbose_bot.with_sessions (module Verbose_session.Memory_store) session_store

  (* /start - Main documentation index *)
  |> Verbose_bot.command "start" ~desc:"Show documentation index" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/start] Showing documentation index";

      let sections = DocIndex.all_sections () in
      let section_buttons = List.map (fun section ->
        [KB.callback ~text:section ~data:("section:" ^ section)]
      ) sections in

      let keyboard = KB.inline (section_buttons @ [
        [KB.callback ~text:"📖 Overview" ~data:"info:overview"];
        [KB.callback ~text:"🔍 Search Docs" ~data:"action:search_prompt"];
      ]) in

      let text =
        "📚 <b>ocaml-telegram-eio Documentation</b>\n\n\
         An ergonomic, type-safe Telegram Bot API client for OCaml 5, built on Eio.\n\n\
         <b>Documentation Sections:</b>\n\
         • Getting Started\n\
         • API Guides\n\
         • Advanced Patterns\n\
         • Recipes\n\
         • Use Cases\n\
         • Reference\n\n\
         Choose a section to explore:"
      in

      match send ~keyboard ctx text with
      | Ok _ -> Eio.traceln "[/start] ✓"; Ok ()
      | Error e -> Eio.traceln "[/start] ✗ %a" Error.pp e; Ok ()
    )

  (* /overview - Library overview *)
  |> Verbose_bot.command "overview" ~desc:"Library overview" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/overview] Showing overview";

      let text =
        "📖 <b>Library Overview</b>\n\n\
         ocaml-telegram-eio provides:\n\n\
         ✅ <b>Fully type-safe API</b>\n\
         All Telegram types and methods\n\n\
         ✅ <b>Effects-based concurrency</b>\n\
         Built on Eio (no monads!)\n\n\
         ✅ <b>Zero-cost abstractions</b>\n\
         Compile-time guarantees\n\n\
         ✅ <b>Comprehensive</b>\n\
         Polling, webhooks, files, payments\n\n\
         ✅ <b>Well-tested</b>\n\
         Unit, property, integration tests\n\n\
         Total: 449 types, 232 methods"
      in

      match reply ctx text with
      | Ok _ -> Eio.traceln "[/overview] ✓"; Ok ()
      | Error e -> Eio.traceln "[/overview] ✗ %a" Error.pp e; Ok ()
    )

  (* /search_docs - Search documentation *)
  |> Verbose_bot.command "search_docs" ~desc:"Search documentation" (fun ctx args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/search_docs] Searching documentation";

      match args with
      | [] ->
          (match reply ctx "Usage: /search_docs <query>\n\nExample: /search_docs keyboard" with
           | Ok _ -> Ok ()
           | Error e -> Eio.traceln "[/search_docs] ✗ %a" Error.pp e; Ok ())

      | _ ->
          let query = String.concat " " args in
          let results = DocIndex.search query in

          Eio.traceln "[/search_docs] Found %d results for: %s" (List.length results) query;

          if List.length results = 0 then
            (match reply ctx (Printf.sprintf "No documentation found for: %s" query) with
             | Ok _ -> Ok ()
             | Error e -> Eio.traceln "[/search_docs] ✗ %a" Error.pp e; Ok ())
          else
            let result_buttons = List.map (fun p ->
              [KB.callback ~text:(p.section ^ ": " ^ p.title) ~data:("page:" ^ p.id)]
            ) results in

            let keyboard = KB.inline result_buttons in

            let text = Printf.sprintf
              "🔍 <b>Documentation Search</b>\n\n\
               Query: %s\n\
               Found: %d pages"
              query (List.length results)
            in

            (match send ~keyboard ctx text with
             | Ok _ -> Eio.traceln "[/search_docs] ✓"; Ok ()
             | Error e -> Eio.traceln "[/search_docs] ✗ %a" Error.pp e; Ok ())
    )

  (* Callback: section:<name> *)
  |> Verbose_bot.on_callback (fun ctx data ->
      if String.starts_with ~prefix:"section:" data then (
        let open Verbose_bot.Ctx in
        let section = String.sub data 8 (String.length data - 8) in

        Eio.traceln "[section] Showing section: %s" section;

        let pages = DocIndex.by_section section in

        let page_buttons = List.map (fun p ->
          [KB.callback ~text:p.title ~data:("page:" ^ p.id)]
        ) pages in

        let keyboard = KB.inline (page_buttons @ [
          [KB.callback ~text:"← Back to Index" ~data:"action:index"];
        ]) in

        let text = Printf.sprintf
          "📂 <b>%s</b>\n\n\
           %d documentation pages:"
          section (List.length pages)
        in

        (match edit ~keyboard ctx text with
         | Ok () -> Ok ()
         | Error e -> Eio.traceln "[section] ✗ %a" Error.pp e; Ok ())
      ) else Ok ()
    )

  (* Callback: page:<id> *)
  |> Verbose_bot.on_callback (fun ctx data ->
      if String.starts_with ~prefix:"page:" data then (
        let open Verbose_bot.Ctx in
        let id = String.sub data 5 (String.length data - 5) in

        Eio.traceln "[page] Showing page: %s" id;

        match DocIndex.find_by_id id with
        | Some page ->
            let text = Printf.sprintf
              "📄 <b>%s</b>\n\n\
               %s\n\n\
               <i>Section: %s</i>\n\n\
               This page covers:\n\
               %s"
              page.title
              page.description
              page.section
              page.description
            in

            let keyboard = KB.inline [
              [KB.callback ~text:("← Back to " ^ page.section) ~data:("section:" ^ page.section)];
            ] in

            (match edit ~keyboard ctx text with
             | Ok () -> Eio.traceln "[page] ✓"; Ok ()
             | Error e -> Eio.traceln "[page] ✗ %a" Error.pp e; Ok ())

        | None ->
            (match edit ctx "❌ Page not found" with
             | Ok () -> Ok ()
             | Error e -> Eio.traceln "[page] ✗ %a" Error.pp e; Ok ())
      ) else Ok ()
    )

  (* Callback: info:overview *)
  |> Verbose_bot.on_callback_data "info:overview" (fun ctx ->
      let open Verbose_bot.Ctx in

      let text = Printf.sprintf
        "📖 <b>Library Overview</b>\n\n\
         ocaml-telegram-eio provides:\n\n\
         ✅ <b>Type-safe API</b>\n\
         449 types, 232 methods\n\n\
         ✅ <b>Eio concurrency</b>\n\
         Direct-style, no monads\n\n\
         ✅ <b>Production-ready</b>\n\
         Polling, webhooks, files, payments\n\n\
         ✅ <b>Well-tested</b>\n\
         Comprehensive test suite\n\n\
         ✅ <b>Documentation</b>\n\
         %d pages across %d sections"
        (List.length DocIndex.pages)
        (List.length (DocIndex.all_sections ()))
      in

      match edit ctx text with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[info:overview] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: action:index *)
  |> Verbose_bot.on_callback_data "action:index" (fun ctx ->
      let open Verbose_bot.Ctx in

      let sections = DocIndex.all_sections () in
      let section_buttons = List.map (fun section ->
        [KB.callback ~text:section ~data:("section:" ^ section)]
      ) sections in

      let keyboard = KB.inline (section_buttons @ [
        [KB.callback ~text:"📖 Overview" ~data:"info:overview"];
      ]) in

      let text =
        "📚 <b>Documentation Index</b>\n\n\
         Browse by section:"
      in

      match edit ~keyboard ctx text with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[action:index] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: action:search_prompt *)
  |> Verbose_bot.on_callback_data "action:search_prompt" (fun ctx ->
      let open Verbose_bot.Ctx in

      match edit ctx
        "🔍 <b>Search Documentation</b>\n\n\
         Use the /search_docs command:\n\n\
         <code>/search_docs &lt;query&gt;</code>\n\n\
         Examples:\n\
         • /search_docs keyboard\n\
         • /search_docs error\n\
         • /search_docs session"
      with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[action:search_prompt] ✗ %a" Error.pp e; Ok ()
    )

  |> Verbose_bot.run
