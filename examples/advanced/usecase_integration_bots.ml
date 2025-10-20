(** Integration Bots Use Case - External system integration patterns

    This example demonstrates integration bot patterns:
    - GitHub-style webhook simulation (push, PR, issue events)
    - CI/CD status checking and notifications
    - Database query bot with whitelisted safe queries
    - API gateway pattern (proxy commands to backend)
    - Admin-only integration commands
    - Error handling for external services

    Commands:
      /start - Show main menu
      /ci_status - Check CI/CD build status
      /db_query <query> - Run whitelisted database query
      /api_call <endpoint> - Call backend API
      /webhook_test - Simulate GitHub webhook event
      /integration_status - Show all integration statuses

    Admin Commands (require ADMIN_USER_IDS):
      /broadcast_github - Broadcast simulated GitHub event
      /trigger_ci - Trigger CI build (simulated)

    Environment Variables:
      ADMIN_USER_IDS - Comma-separated admin user IDs

    This example has VERBOSE LOGGING enabled for troubleshooting.

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      export ADMIN_USER_IDS="your_user_id"
      dune exec examples/usecase_integration_bots_demo.exe
*)

open Telegram
open Tg

(* Configure verbose logging with flo *)
let () = Flo.set_level Severity.Debug

module KB = Keyboard

(** Simulated GitHub integration *)
module GitHub = struct
  type event_type = Push | PullRequest | Issue | Release
  [@@warning "-37"]  (* Unused constructors ok in demo *)

  type event = {
    event_type: event_type;
    repo: string;
    author: string;
    message: string;
    url: string;
  }

  let event_type_to_string = function
    | Push -> "push"
    | PullRequest -> "pull_request"
    | Issue -> "issue"
    | Release -> "release"

  let format_event event =
    let emoji = match event.event_type with
      | Push -> "⬆️"
      | PullRequest -> "🔀"
      | Issue -> "🐛"
      | Release -> "🚀"
    in

    Printf.sprintf
      "%s <b>%s</b>\n\n\
       Repository: %s\n\
       Author: %s\n\
       %s\n\n\
       %s"
      emoji
      (event_type_to_string event.event_type)
      event.repo
      event.author
      event.message
      event.url

  let simulate_push () =
    Eio.traceln "[GitHub] Simulating push event";
    {
      event_type = Push;
      repo = "ocaml/telegram-eio";
      author = "developer";
      message = "feat: Add new feature X";
      url = "https://github.com/ocaml/telegram-eio/commit/abc123";
    }

  let simulate_pr () =
    Eio.traceln "[GitHub] Simulating PR event";
    {
      event_type = PullRequest;
      repo = "ocaml/telegram-eio";
      author = "contributor";
      message = "Fix: Resolve issue #42";
      url = "https://github.com/ocaml/telegram-eio/pull/123";
    }
end

(** Simulated CI/CD integration *)
module CICD = struct
  type build_status = Pending | Running | Success | Failed | Canceled
  [@@warning "-37"]  (* Unused constructors ok in demo *)

  type build = {
    project: string;
    branch: string;
    status: build_status;
    started_at: float;
    duration: float option;
  }
  [@@warning "-69"]  (* Unused fields ok in demo *)

  let status_to_string = function
    | Pending -> "⏳ Pending"
    | Running -> "🔄 Running"
    | Success -> "✅ Success"
    | Failed -> "❌ Failed"
    | Canceled -> "⚠️ Canceled"

  let current_build = ref {
    project = "telegram-bot";
    branch = "main";
    status = Success;
    started_at = Unix.time ();
    duration = Some 45.0;
  }

  let get_status () =
    Eio.traceln "[CICD] Getting build status";
    !current_build

  let trigger_build project branch =
    Eio.traceln "[CICD] Triggering build: %s/%s" project branch;
    let new_build = {
      project;
      branch;
      status = Running;
      started_at = Unix.time ();
      duration = None;
    } in
    current_build := new_build;
    new_build

  let format_build build =
    let duration_str = match build.duration with
      | Some d -> Printf.sprintf "%.1fs" d
      | None -> "in progress"
    in

    Printf.sprintf
      "🔧 <b>CI/CD Build Status</b>\n\n\
       Project: %s\n\
       Branch: %s\n\
       Status: %s\n\
       Duration: %s"
      build.project
      build.branch
      (status_to_string build.status)
      duration_str
end

(** Simulated database integration *)
module Database = struct
  type query_result = (string * string) list list
  [@@warning "-34"]  (* Unused type ok in demo *)

  let whitelisted_queries = [
    "user_count";
    "active_users";
    "recent_messages";
  ]

  let run_query query params =
    Eio.traceln "[Database] Running query: %s with params: [%s]"
      query (String.concat ", " params);

    if not (List.mem query whitelisted_queries) then
      Error (Printf.sprintf "Query '%s' not whitelisted" query)
    else
      match query with
      | "user_count" ->
          Ok [["count", "42"]]
      | "active_users" ->
          Ok [
            ["id", "1"; "name", "Alice"];
            ["id", "2"; "name", "Bob"];
            ["id", "3"; "name", "Carol"];
          ]
      | "recent_messages" ->
          Ok [
            ["time", "10:30"; "user", "Alice"; "text", "Hello"];
            ["time", "10:35"; "user", "Bob"; "text", "Hi there"];
          ]
      | _ ->
          Error "Unknown query"

  let format_results results =
    if List.length results = 0 then
      "(empty result)"
    else
      List.map (fun row ->
        row
        |> List.map (fun (k, v) -> Printf.sprintf "%s: %s" k v)
        |> String.concat ", "
      ) results
      |> String.concat "\n"
end

(** Simulated backend API integration *)
module BackendAPI = struct
  type api_response = {
    success: bool;
    message: string;
    data: string option;
  }

  let call endpoint params =
    Eio.traceln "[BackendAPI] Calling endpoint: %s with params: [%s]"
      endpoint (String.concat ", " params);

    (* Simulate API call with random success/failure *)
    match endpoint with
    | "users" ->
        Ok { success = true; message = "Users retrieved"; data = Some "3 users found" }
    | "create_item" ->
        Ok { success = true; message = "Item created"; data = Some "ID: 42" }
    | "stats" ->
        Ok { success = true; message = "Stats retrieved"; data = Some "Messages: 1337, Users: 42" }
    | _ ->
        Error (Printf.sprintf "Unknown endpoint: %s" endpoint)

  let format_response response =
    let status = if response.success then "✅" else "❌" in
    let data_str = match response.data with
      | Some d -> Printf.sprintf "\n\nData: %s" d
      | None -> ""
    in

    Printf.sprintf
      "%s <b>API Response</b>\n\n\
       %s%s"
      status response.message data_str
end

(** Admin authorization *)
module AdminAuth = struct
  let admin_user_ids () =
    match Sys.getenv_opt "ADMIN_USER_IDS" with
    | Some ids ->
        String.split_on_char ',' ids
        |> List.filter_map (fun s ->
            match Int64.of_string_opt (String.trim s) with
            | Some id -> Some (Id.User.of_int id)
            | None -> None)
    | None -> []

  let is_admin user_id =
    let admins = admin_user_ids () in
    let user_id_str = Id.to_string user_id in
    List.exists (fun admin_id ->
      Id.to_string admin_id = user_id_str
    ) admins
end

let () =
  Printexc.record_backtrace true;
  Eio.traceln "=== Integration Bots Demo Starting ===";

  let token = match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None -> Printf.eprintf "TELEGRAM_BOT_TOKEN not set\n"; exit 1
  in

  Eio_main.run @@ fun env ->
  let client = Client.create ~env ~token () in

  Eio.traceln "🤖 Integration Bots Demo Started";
  Eio.traceln "Admin users: %d configured" (List.length (AdminAuth.admin_user_ids ()));

  let session_store = Session.Memory_store.create () in

  Bot.make ~env ~client
  |> Bot.with_sessions (module Session.Memory_store) session_store

  (* /start - Main menu *)
  |> Bot.command "start" ~desc:"Show main menu" (fun ctx _args ->
      let open Bot.Ctx in
      Eio.traceln "[/start] Showing main menu";

      let keyboard = KB.inline [
        [KB.callback ~text:"🔧 CI/CD Status" ~data:"action:ci_status"];
        [KB.callback ~text:"💾 Database Query" ~data:"action:db_query"];
        [KB.callback ~text:"🌐 API Call" ~data:"action:api_call"];
        [KB.callback ~text:"📢 GitHub Event" ~data:"action:github"];
      ] in

      let text =
        "🔗 <b>Integration Bots Demo</b>\n\n\
         Connect Telegram to external systems:\n\n\
         🔧 CI/CD - Build status monitoring\n\
         💾 Database - Safe query execution\n\
         🌐 API Gateway - Backend API calls\n\
         📢 GitHub - Webhook event simulation\n\n\
         This demonstrates integration patterns."
      in

      match send ~keyboard ctx text with
      | Ok _ -> Eio.traceln "[/start] ✓"; Ok ()
      | Error e -> Eio.traceln "[/start] ✗ %a" Error.pp e; Ok ()
    )

  (* /ci_status - Check CI/CD status *)
  |> Bot.command "ci_status" ~desc:"Check CI/CD build status" (fun ctx _args ->
      let open Bot.Ctx in
      Eio.traceln "[/ci_status] Checking build status";

      let build = CICD.get_status () in
      let text = CICD.format_build build in

      match reply ctx text with
      | Ok _ -> Eio.traceln "[/ci_status] ✓"; Ok ()
      | Error e -> Eio.traceln "[/ci_status] ✗ %a" Error.pp e; Ok ()
    )

  (* /db_query - Database query *)
  |> Bot.command "db_query" ~desc:"Run database query" (fun ctx args ->
      let open Bot.Ctx in
      Eio.traceln "[/db_query] Database query request";

      match args with
      | [] ->
          let queries_list = String.concat ", " Database.whitelisted_queries in
          let text = Printf.sprintf
            "Usage: /db_query <query>\n\n\
             Whitelisted queries:\n\
             %s"
            queries_list
          in
          (match reply ctx text with
           | Ok _ -> Ok ()
           | Error e -> Eio.traceln "[/db_query] ✗ %a" Error.pp e; Ok ())

      | query :: params ->
          (match Database.run_query query params with
           | Ok results ->
               Eio.traceln "[/db_query] Query succeeded, %d rows" (List.length results);
               let formatted = Database.format_results results in
               let text = Printf.sprintf
                 "💾 <b>Query Results</b>\n\n\
                  Query: %s\n\n\
                  <code>%s</code>"
                 query formatted
               in
               (match reply ctx text with
                | Ok _ -> Eio.traceln "[/db_query] ✓"; Ok ()
                | Error e -> Eio.traceln "[/db_query] ✗ %a" Error.pp e; Ok ())

           | Error msg ->
               Eio.traceln "[/db_query] Query failed: %s" msg;
               (match reply ctx (Printf.sprintf "❌ Query failed: %s" msg) with
                | Ok _ -> Ok ()
                | Error e -> Eio.traceln "[/db_query] ✗ %a" Error.pp e; Ok ()))
    )

  (* /api_call - Backend API call *)
  |> Bot.command "api_call" ~desc:"Call backend API" (fun ctx args ->
      let open Bot.Ctx in
      Eio.traceln "[/api_call] API call request";

      match args with
      | [] ->
          (match reply ctx
            "Usage: /api_call <endpoint> [params...]\n\n\
             Examples:\n\
             • /api_call users\n\
             • /api_call stats\n\
             • /api_call create_item item1"
           with
           | Ok _ -> Ok ()
           | Error e -> Eio.traceln "[/api_call] ✗ %a" Error.pp e; Ok ())

      | endpoint :: params ->
          (match BackendAPI.call endpoint params with
           | Ok response ->
               Eio.traceln "[/api_call] API call succeeded";
               let text = BackendAPI.format_response response in
               (match reply ctx text with
                | Ok _ -> Eio.traceln "[/api_call] ✓"; Ok ()
                | Error e -> Eio.traceln "[/api_call] ✗ %a" Error.pp e; Ok ())

           | Error msg ->
               Eio.traceln "[/api_call] API call failed: %s" msg;
               (match reply ctx (Printf.sprintf "❌ API call failed: %s" msg) with
                | Ok _ -> Ok ()
                | Error e -> Eio.traceln "[/api_call] ✗ %a" Error.pp e; Ok ()))
    )

  (* /webhook_test - Simulate webhook *)
  |> Bot.command "webhook_test" ~desc:"Simulate GitHub webhook" (fun ctx _args ->
      let open Bot.Ctx in
      Eio.traceln "[/webhook_test] Simulating GitHub webhook";

      let keyboard = KB.inline [
        [KB.callback ~text:"⬆️ Simulate Push" ~data:"webhook:push"];
        [KB.callback ~text:"🔀 Simulate PR" ~data:"webhook:pr"];
      ] in

      let text =
        "📢 <b>GitHub Webhook Simulation</b>\n\n\
         Choose an event type to simulate:"
      in

      match send ~keyboard ctx text with
      | Ok _ -> Eio.traceln "[/webhook_test] ✓"; Ok ()
      | Error e -> Eio.traceln "[/webhook_test] ✗ %a" Error.pp e; Ok ()
    )

  (* /integration_status - Show all integration statuses *)
  |> Bot.command "integration_status" ~desc:"Show integration status" (fun ctx _args ->
      let open Bot.Ctx in
      Eio.traceln "[/integration_status] Showing integration status";

      let build = CICD.get_status () in
      let build_status = CICD.status_to_string build.status in

      let text = Printf.sprintf
        "🔗 <b>Integration Status</b>\n\n\
         <b>CI/CD:</b>\n\
         Status: %s\n\
         Project: %s\n\
         Branch: %s\n\n\
         <b>Database:</b>\n\
         Whitelisted queries: %d\n\n\
         <b>Backend API:</b>\n\
         Connected: ✅\n\n\
         <b>GitHub Webhooks:</b>\n\
         Configured: ✅ (simulated)"
        build_status
        build.project
        build.branch
        (List.length Database.whitelisted_queries)
      in

      match reply ctx text with
      | Ok _ -> Eio.traceln "[/integration_status] ✓"; Ok ()
      | Error e -> Eio.traceln "[/integration_status] ✗ %a" Error.pp e; Ok ()
    )

  (* /trigger_ci - Trigger CI build (admin only) *)
  |> Bot.command "trigger_ci" ~desc:"Trigger CI build (admin)" (fun ctx args ->
      let open Bot.Ctx in
      Eio.traceln "[/trigger_ci] CI build trigger request";

      (* Check admin *)
      match user ctx with
      | Some u when AdminAuth.is_admin u.id ->
          Eio.traceln "[/trigger_ci] Admin access granted";

          (match args with
           | [project; branch] ->
               let build = CICD.trigger_build project branch in
               let text = Printf.sprintf
                 "🔧 <b>CI Build Triggered</b>\n\n\
                  Project: %s\n\
                  Branch: %s\n\
                  Status: %s"
                 build.project
                 build.branch
                 (CICD.status_to_string build.status)
               in

               (match reply ctx text with
                | Ok _ -> Eio.traceln "[/trigger_ci] ✓"; Ok ()
                | Error e -> Eio.traceln "[/trigger_ci] ✗ %a" Error.pp e; Ok ())

           | _ ->
               (match reply ctx "Usage: /trigger_ci <project> <branch>" with
                | Ok _ -> Ok ()
                | Error e -> Eio.traceln "[/trigger_ci] ✗ %a" Error.pp e; Ok ()))

      | Some _ ->
          Eio.traceln "[/trigger_ci] Admin access denied";
          (match reply ctx "❌ Admin access required." with
           | Ok _ -> Ok ()
           | Error e -> Eio.traceln "[/trigger_ci] ✗ %a" Error.pp e; Ok ())

      | None ->
          Ok ()
    )

  (* Callback: action:ci_status *)
  |> Bot.on_callback_data "action:ci_status" (fun ctx ->
      let open Bot.Ctx in

      let build = CICD.get_status () in
      let text = CICD.format_build build in

      match edit ctx text with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[action:ci_status] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: action:db_query *)
  |> Bot.on_callback_data "action:db_query" (fun ctx ->
      let open Bot.Ctx in

      let query_buttons = List.map (fun q ->
        [KB.callback ~text:q ~data:("db:" ^ q)]
      ) Database.whitelisted_queries in

      let keyboard = KB.inline query_buttons in

      let text =
        "💾 <b>Database Queries</b>\n\n\
         Select a whitelisted query:"
      in

      match edit ~keyboard ctx text with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[action:db_query] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: db:<query> *)
  |> Bot.on_callback (fun ctx data ->
      if String.starts_with ~prefix:"db:" data then (
        let open Bot.Ctx in
        let query = String.sub data 3 (String.length data - 3) in

        Eio.traceln "[db] Running query: %s" query;

        (match Database.run_query query [] with
         | Ok results ->
             let formatted = Database.format_results results in
             let text = Printf.sprintf
               "💾 <b>Query Results</b>\n\n\
                Query: %s\n\n\
                <code>%s</code>"
               query formatted
             in
             (match edit ctx text with
              | Ok () -> Ok ()
              | Error e -> Eio.traceln "[db] ✗ %a" Error.pp e; Ok ())

         | Error msg ->
             (match edit ctx (Printf.sprintf "❌ %s" msg) with
              | Ok () -> Ok ()
              | Error e -> Eio.traceln "[db] ✗ %a" Error.pp e; Ok ()))
      ) else Ok ()
    )

  (* Callback: action:api_call *)
  |> Bot.on_callback_data "action:api_call" (fun ctx ->
      let open Bot.Ctx in

      let api_buttons = [
        [KB.callback ~text:"Users" ~data:"api:users"];
        [KB.callback ~text:"Stats" ~data:"api:stats"];
        [KB.callback ~text:"Create Item" ~data:"api:create_item"];
      ] in

      let keyboard = KB.inline api_buttons in

      match edit ~keyboard ctx "🌐 <b>Backend API</b>\n\nSelect an endpoint:" with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[action:api_call] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: api:<endpoint> *)
  |> Bot.on_callback (fun ctx data ->
      if String.starts_with ~prefix:"api:" data then (
        let open Bot.Ctx in
        let endpoint = String.sub data 4 (String.length data - 4) in

        Eio.traceln "[api] Calling endpoint: %s" endpoint;

        (match BackendAPI.call endpoint [] with
         | Ok response ->
             let text = BackendAPI.format_response response in
             (match edit ctx text with
              | Ok () -> Ok ()
              | Error e -> Eio.traceln "[api] ✗ %a" Error.pp e; Ok ())

         | Error msg ->
             (match edit ctx (Printf.sprintf "❌ %s" msg) with
              | Ok () -> Ok ()
              | Error e -> Eio.traceln "[api] ✗ %a" Error.pp e; Ok ()))
      ) else Ok ()
    )

  (* Callback: action:github *)
  |> Bot.on_callback_data "action:github" (fun ctx ->
      let open Bot.Ctx in

      let keyboard = KB.inline [
        [KB.callback ~text:"⬆️ Push Event" ~data:"webhook:push"];
        [KB.callback ~text:"🔀 PR Event" ~data:"webhook:pr"];
      ] in

      match edit ~keyboard ctx "📢 <b>GitHub Webhook</b>\n\nSimulate an event:" with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[action:github] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: webhook:push *)
  |> Bot.on_callback_data "webhook:push" (fun ctx ->
      let open Bot.Ctx in
      Eio.traceln "[webhook:push] Simulating push event";

      let event = GitHub.simulate_push () in
      let text = GitHub.format_event event in

      match edit ctx text with
      | Ok () -> Eio.traceln "[webhook:push] ✓"; Ok ()
      | Error e -> Eio.traceln "[webhook:push] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: webhook:pr *)
  |> Bot.on_callback_data "webhook:pr" (fun ctx ->
      let open Bot.Ctx in
      Eio.traceln "[webhook:pr] Simulating PR event";

      let event = GitHub.simulate_pr () in
      let text = GitHub.format_event event in

      match edit ctx text with
      | Ok () -> Eio.traceln "[webhook:pr] ✓"; Ok ()
      | Error e -> Eio.traceln "[webhook:pr] ✗ %a" Error.pp e; Ok ()
    )

  |> Bot.run
