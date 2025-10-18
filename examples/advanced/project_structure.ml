(** Project Structure Demo - Self-documenting project organization patterns

    This example demonstrates recommended project structure for Telegram bots:
    - Module organization and separation of concerns
    - Configuration management patterns
    - Library vs executable separation
    - Recommended directory layouts (small, medium, large)
    - Dune configuration examples
    - Self-inspection commands showing structure

    Commands:
      /start - Show main menu
      /structure - Show recommended project structure
      /small - Small bot structure (single file)
      /medium - Medium bot structure (module per feature)
      /large - Large bot structure (layered architecture)
      /this_bot - Show this bot's structure
      /dune_config - Show dune configuration examples
      /best_practices - Project organization best practices
      /modules - Show module organization

    This example demonstrates CLEAN PROJECT ORGANIZATION with verbose logging.

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/project_structure_demo.exe
*)

open Telegram
open Tg

(* Configure verbose logging via functor composition *)
module Verbose_log = Log.Make (Log.Console) (struct
  let src = "ProjectStructure"
  let level = Log.Debug
end)

module Verbose_session = Session.Make (Verbose_log)
module Verbose_polling = Polling.Make (Verbose_log)
module Verbose_bot = Bot.Make (Verbose_log) (Verbose_session) (Verbose_polling)

module KB = Keyboard

(** Project structure templates *)
module Templates = struct
  let small_structure =
    "📁 <b>Small Bot Structure</b>\n\
     (for bots &lt;200 lines)\n\n\
     <code>\n\
     my_bot/\n\
     ├── dune-project\n\
     ├── bin/\n\
     │   ├── dune\n\
     │   └── main.ml       # Everything in one file\n\
     └── .gitignore\n\
     </code>\n\n\
     <b>When to use:</b>\n\
     • Learning and prototypes\n\
     • Single-purpose bots (echo, calculator)\n\
     • Quick experiments\n\n\
     <b>Advantages:</b>\n\
     • Simple, no overhead\n\
     • Easy to understand\n\
     • Fast iteration"

  let medium_structure =
    "📁 <b>Medium Bot Structure</b>\n\
     (for bots 200-1000 lines)\n\n\
     <code>\n\
     my_bot/\n\
     ├── dune-project\n\
     ├── lib/\n\
     │   ├── dune\n\
     │   ├── config.ml      # Configuration\n\
     │   ├── types.ml       # Custom types\n\
     │   ├── commands.ml    # Command handlers\n\
     │   ├── callbacks.ml   # Callback handlers\n\
     │   └── keyboards.ml   # Keyboard builders\n\
     ├── bin/\n\
     │   ├── dune\n\
     │   └── main.ml        # Entry point\n\
     └── test/\n\
         ├── dune\n\
         └── test_commands.ml\n\
     </code>\n\n\
     <b>When to use:</b>\n\
     • Feature-rich bots\n\
     • Multiple commands\n\
     • Team projects\n\n\
     <b>Advantages:</b>\n\
     • Clear module boundaries\n\
     • Testable components\n\
     • Reusable library code"

  let large_structure =
    "📁 <b>Large Bot Structure</b>\n\
     (for bots 1000+ lines)\n\n\
     <code>\n\
     my_bot/\n\
     ├── dune-project\n\
     ├── lib/\n\
     │   ├── dune\n\
     │   ├── domain/        # Business logic\n\
     │   │   ├── user.ml\n\
     │   │   ├── order.ml\n\
     │   │   └── payment.ml\n\
     │   ├── bot/           # Bot layer\n\
     │   │   ├── commands.ml\n\
     │   │   ├── callbacks.ml\n\
     │   │   └── middleware.ml\n\
     │   ├── storage/       # Persistence\n\
     │   │   ├── database.ml\n\
     │   │   └── cache.ml\n\
     │   └── utils/         # Shared utilities\n\
     │       └── config.ml\n\
     ├── bin/\n\
     ├── test/\n\
     └── config/\n\
     </code>\n\n\
     <b>When to use:</b>\n\
     • Production bots\n\
     • Complex business logic\n\
     • Multiple developers\n\n\
     <b>Advantages:</b>\n\
     • Clear layering\n\
     • Isolated testing\n\
     • Team scalability"

  let dune_examples =
    "⚙️ <b>Dune Configuration</b>\n\n\
     <b>1. dune-project</b>\n\
     <code>\n\
     (lang dune 3.7)\n\
     (name my_bot)\n\
     (generate_opam_files true)\n\
     (package\n\
      (name my_bot)\n\
      (depends\n\
       (ocaml (&gt;= 5.1.0))\n\
       (eio_main (&gt;= 0.12))\n\
       (ocaml_telegram_eio)))\n\
     </code>\n\n\
     <b>2. lib/dune (Library)</b>\n\
     <code>\n\
     (library\n\
      (name my_bot_lib)\n\
      (libraries\n\
       ocaml_telegram_eio.telegram\n\
       ocaml_telegram_eio.tg\n\
       yojson))\n\
     </code>\n\n\
     <b>3. bin/dune (Executable)</b>\n\
     <code>\n\
     (executable\n\
      (name main)\n\
      (libraries my_bot_lib eio_main))\n\
     </code>"

  let best_practices =
    "✅ <b>Project Organization Best Practices</b>\n\n\
     <b>Separation of Concerns:</b>\n\
     • Business logic in lib/domain/\n\
     • Bot handlers in lib/bot/\n\
     • Storage in lib/storage/\n\
     • Entry point in bin/\n\n\
     <b>Module Naming:</b>\n\
     • commands.ml - Command handlers\n\
     • callbacks.ml - Callback handlers\n\
     • keyboards.ml - Keyboard builders\n\
     • types.ml - Type definitions\n\
     • config.ml - Configuration\n\n\
     <b>Testing:</b>\n\
     • test/ directory for tests\n\
     • test_<module>.ml naming\n\
     • Unit tests for business logic\n\
     • Integration tests for handlers\n\n\
     <b>Configuration:</b>\n\
     • Environment variables for secrets\n\
     • Config files for settings\n\
     • Separate dev/prod configs\n\n\
     <b>Documentation:</b>\n\
     • README.md with setup instructions\n\
     • Module-level docstrings\n\
     • Examples in docs/"

  let this_bot_structure =
    "📁 <b>This Bot's Structure</b>\n\n\
     This demo follows the simple single-file pattern:\n\n\
     <code>\n\
     examples/\n\
     └── project_structure_demo.ml\n\
     </code>\n\n\
     <b>What this bot demonstrates:</b>\n\
     • Project structure templates\n\
     • Dune configuration\n\
     • Module organization patterns\n\
     • Best practices\n\n\
     <b>Module organization within this file:</b>\n\
     • Verbose_log, Verbose_session, Verbose_bot - Functor composition\n\
     • Templates - Static content module\n\
     • Main - Bot builder with commands\n\n\
     For a real bot, you'd split these into separate files."

  let module_organization =
    "📦 <b>Module Organization Patterns</b>\n\n\
     <b>By Feature (Recommended):</b>\n\
     <code>\n\
     lib/\n\
     ├── user_commands.ml   # /profile, /settings\n\
     ├── admin_commands.ml  # /stats, /broadcast\n\
     ├── payment_flow.ml    # /buy, /checkout\n\
     └── help_commands.ml   # /help, /about\n\
     </code>\n\n\
     <b>By Layer (For Large Bots):</b>\n\
     <code>\n\
     lib/\n\
     ├── domain/      # Pure business logic\n\
     ├── bot/         # Telegram handlers\n\
     ├── storage/     # Database/cache\n\
     └── utils/       # Shared utilities\n\
     </code>\n\n\
     <b>By Update Type:</b>\n\
     <code>\n\
     lib/\n\
     ├── commands.ml   # Command handlers\n\
     ├── callbacks.ml  # Callback handlers\n\
     ├── inline.ml     # Inline query handlers\n\
     └── messages.ml   # Message handlers\n\
     </code>"
end

let () =
  Printexc.record_backtrace true;
  Eio.traceln "=== Project Structure Demo Starting ===";

  let token = match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None -> Printf.eprintf "TELEGRAM_BOT_TOKEN not set\n"; exit 1
  in

  Eio_main.run @@ fun env ->
  let client = Client.create ~env ~token () in

  Eio.traceln "🤖 Project Structure Demo Started";

  let session_store = Verbose_session.Memory_store.create () in

  Verbose_bot.make ~env ~client
  |> Verbose_bot.with_sessions (module Verbose_session.Memory_store) session_store

  (* /start - Main menu *)
  |> Verbose_bot.command "start" ~desc:"Show main menu" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/start] Showing main menu";

      let keyboard = KB.inline [
        [KB.callback ~text:"📁 Small Bot" ~data:"structure:small"];
        [KB.callback ~text:"📁 Medium Bot" ~data:"structure:medium"];
        [KB.callback ~text:"📁 Large Bot" ~data:"structure:large"];
        [KB.callback ~text:"⚙️ Dune Config" ~data:"info:dune"];
        [KB.callback ~text:"✅ Best Practices" ~data:"info:practices"];
        [KB.callback ~text:"📦 Modules" ~data:"info:modules"];
      ] in

      let text =
        "📚 <b>Project Structure Guide</b>\n\n\
         Learn how to organize Telegram bot projects for maintainability and scalability.\n\n\
         Choose a topic to explore:"
      in

      match send ~keyboard ctx text with
      | Ok _ -> Eio.traceln "[/start] ✓"; Ok ()
      | Error e -> Eio.traceln "[/start] ✗ %a" Error.pp e; Ok ()
    )

  (* /small - Small bot structure *)
  |> Verbose_bot.command "small" ~desc:"Small bot structure" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/small] Showing small bot structure";

      match reply ctx Templates.small_structure with
      | Ok _ -> Eio.traceln "[/small] ✓"; Ok ()
      | Error e -> Eio.traceln "[/small] ✗ %a" Error.pp e; Ok ()
    )

  (* /medium - Medium bot structure *)
  |> Verbose_bot.command "medium" ~desc:"Medium bot structure" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/medium] Showing medium bot structure";

      match reply ctx Templates.medium_structure with
      | Ok _ -> Eio.traceln "[/medium] ✓"; Ok ()
      | Error e -> Eio.traceln "[/medium] ✗ %a" Error.pp e; Ok ()
    )

  (* /large - Large bot structure *)
  |> Verbose_bot.command "large" ~desc:"Large bot structure" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/large] Showing large bot structure";

      match reply ctx Templates.large_structure with
      | Ok _ -> Eio.traceln "[/large] ✓"; Ok ()
      | Error e -> Eio.traceln "[/large] ✗ %a" Error.pp e; Ok ()
    )

  (* /this_bot - Show this bot's structure *)
  |> Verbose_bot.command "this_bot" ~desc:"Show this bot's structure" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/this_bot] Showing this bot's structure";

      match reply ctx Templates.this_bot_structure with
      | Ok _ -> Eio.traceln "[/this_bot] ✓"; Ok ()
      | Error e -> Eio.traceln "[/this_bot] ✗ %a" Error.pp e; Ok ()
    )

  (* /dune_config - Dune configuration examples *)
  |> Verbose_bot.command "dune_config" ~desc:"Dune configuration examples" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/dune_config] Showing dune examples";

      match reply ctx Templates.dune_examples with
      | Ok _ -> Eio.traceln "[/dune_config] ✓"; Ok ()
      | Error e -> Eio.traceln "[/dune_config] ✗ %a" Error.pp e; Ok ()
    )

  (* /best_practices - Best practices *)
  |> Verbose_bot.command "best_practices" ~desc:"Project best practices" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/best_practices] Showing best practices";

      match reply ctx Templates.best_practices with
      | Ok _ -> Eio.traceln "[/best_practices] ✓"; Ok ()
      | Error e -> Eio.traceln "[/best_practices] ✗ %a" Error.pp e; Ok ()
    )

  (* /modules - Module organization *)
  |> Verbose_bot.command "modules" ~desc:"Module organization patterns" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/modules] Showing module organization";

      match reply ctx Templates.module_organization with
      | Ok _ -> Eio.traceln "[/modules] ✓"; Ok ()
      | Error e -> Eio.traceln "[/modules] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: structure:* *)
  |> Verbose_bot.on_callback_data "structure:small" (fun ctx ->
      let open Verbose_bot.Ctx in
      match edit ctx Templates.small_structure with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[structure:small] ✗ %a" Error.pp e; Ok ()
    )

  |> Verbose_bot.on_callback_data "structure:medium" (fun ctx ->
      let open Verbose_bot.Ctx in
      match edit ctx Templates.medium_structure with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[structure:medium] ✗ %a" Error.pp e; Ok ()
    )

  |> Verbose_bot.on_callback_data "structure:large" (fun ctx ->
      let open Verbose_bot.Ctx in
      match edit ctx Templates.large_structure with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[structure:large] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: info:* *)
  |> Verbose_bot.on_callback_data "info:dune" (fun ctx ->
      let open Verbose_bot.Ctx in
      match edit ctx Templates.dune_examples with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[info:dune] ✗ %a" Error.pp e; Ok ()
    )

  |> Verbose_bot.on_callback_data "info:practices" (fun ctx ->
      let open Verbose_bot.Ctx in
      match edit ctx Templates.best_practices with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[info:practices] ✗ %a" Error.pp e; Ok ()
    )

  |> Verbose_bot.on_callback_data "info:modules" (fun ctx ->
      let open Verbose_bot.Ctx in
      match edit ctx Templates.module_organization with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[info:modules] ✗ %a" Error.pp e; Ok ()
    )

  |> Verbose_bot.run
