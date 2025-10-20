(** Recipe: Poll and Quiz Bot

    A comprehensive poll and quiz system demonstrating:
    - Creating simple polls with multiple options
    - Enabling multiple answer selection
    - Timed polls with auto-close
    - Quiz mode with correct answers and explanations
    - Vote tracking for non-anonymous polls
    - Aggregating results from anonymous polls
    - Stopping polls and displaying final results
    - Leaderboard for quiz scoring
    - Result-based error handling
    - Functor-based verbose logging
*)

open Telegram
open Tg

(** {1 Verbose Logging Setup} *)

(* Configure verbose logging with flo *)
let () = Flo.set_level Severity.Debug

(** {1 Poll Option Helper} *)

let poll_option (text : string) : Telegram_generated.Gen_types.InputPollOption.t =
  Flo.debugf "[PollOption] Creating option: text='%s'" text;
  Telegram_generated.Gen_types.InputPollOption.{
    text;
    text_parse_mode = None;
    text_entities = None;
    unknown_fields = [];
  }

(** {1 Poll Metadata Storage} *)

(* Store poll metadata for stopping polls later *)
type poll_meta = {
  chat_id : Id.Chat.k Id.t;
  message_id : int64;
  poll_type : string; (* "poll" or "quiz" *)
  correct_option : int option; (* For quizzes *)
}

module PollMeta = struct
  (* poll_id -> poll_meta *)
  let store : (string, poll_meta) Hashtbl.t = Hashtbl.create 128

  let add poll_id meta =
    Flo.debugf "[PollMeta] Storing metadata: poll_id=%s, chat_id=%s, message_id=%Ld, type=%s"
      poll_id (Format.asprintf "%a" Id.pp meta.chat_id) meta.message_id meta.poll_type;
    Hashtbl.replace store poll_id meta

  let find poll_id =
    Flo.debugf "[PollMeta] Looking up metadata: poll_id=%s" poll_id;
    match Hashtbl.find_opt store poll_id with
    | Some meta ->
        Flo.successf "[PollMeta] ✅ Found metadata: type=%s" meta.poll_type;
        Some meta
    | None ->
        Flo.errorf "[PollMeta] ❌ No metadata found for poll_id=%s" poll_id;
        None

  let all_poll_ids () =
    Hashtbl.to_seq_keys store |> List.of_seq
end

(** {1 Vote Tracking for Non-Anonymous Polls} *)

module VoteTracker = struct
  module UMap = Hashtbl.Make(struct
    type t = int64
    let equal = Int64.equal
    let hash = Hashtbl.hash
  end)

  module PMap = Hashtbl.Make(struct
    type t = string
    let equal = String.equal
    let hash = Hashtbl.hash
  end)

  (* poll_id -> (user_id -> option_ids) *)
  let by_poll : (int64 list UMap.t) PMap.t = PMap.create 32

  let user_id_of_poll_answer (a : Telegram_generated.Gen_types.PollAnswer.t) : int64 option =
    match a.user, a.voter_chat with
    | Some u, _ ->
        Flo.debugf "[VoteTracker] User vote: user_id=%Ld" u.id;
        Some u.id
    | None, Some chat ->
        Flo.debugf "[VoteTracker] Chat vote: chat_id=%Ld" chat.id;
        Some chat.id
    | None, None ->
        Flo.debug "[VoteTracker] ⚠️  No user or chat in poll answer";
        None

  let track (a : Telegram_generated.Gen_types.PollAnswer.t) =
    Flo.debugf "[VoteTracker] Tracking poll answer: poll_id=%s, option_ids=[%s]"
      a.poll_id
      (a.option_ids |> List.map Int64.to_string |> String.concat ", ");

    match user_id_of_poll_answer a with
    | None -> ()
    | Some uid ->
        let table =
          match PMap.find_opt by_poll a.poll_id with
          | Some t ->
              Flo.debugf "[VoteTracker] Using existing table for poll_id=%s" a.poll_id;
              t
          | None ->
              Flo.debugf "[VoteTracker] Creating new table for poll_id=%s" a.poll_id;
              let t = UMap.create 128 in
              PMap.add by_poll a.poll_id t;
              t
        in
        UMap.replace table uid a.option_ids;
        Flo.successf "[VoteTracker] ✅ Tracked vote: user_id=%Ld" uid

  let get_user_votes poll_id : (int64 * int64 list) list =
    Flo.debugf "[VoteTracker] Getting all user votes for poll_id=%s" poll_id;
    match PMap.find_opt by_poll poll_id with
    | None ->
        Flo.debug "[VoteTracker] No votes found";
        []
    | Some t ->
        let votes = UMap.fold (fun uid opts acc -> (uid, opts) :: acc) t [] in
        Flo.debugf "[VoteTracker] Found %d user votes" (List.length votes);
        votes
end

(** {1 Leaderboard for Quizzes} *)

module Leaderboard = struct
  type entry = {
    user_id : int64;
    score : int;
  }

  let score_quiz ~poll_id ~correct_idx : entry list =
    Flo.debugf "[Leaderboard] Scoring quiz: poll_id=%s, correct_idx=%d" poll_id correct_idx;

    let user_votes = VoteTracker.get_user_votes poll_id in
    let scored =
      List.map (fun (uid, opts) ->
        let is_correct = List.exists (fun i -> Int64.to_int i = correct_idx) opts in
        let score = if is_correct then 1 else 0 in
        Flo.debugf "[Leaderboard] User %Ld: selected=[%s], correct=%b, score=%d"
          uid
          (opts |> List.map Int64.to_string |> String.concat ",")
          is_correct
          score;
        { user_id = uid; score }
      ) user_votes
    in

    let sorted = List.sort (fun a b -> Int.compare b.score a.score) scored in
    Flo.successf "[Leaderboard] ✅ Leaderboard generated: %d entries" (List.length sorted);
    sorted

  let format_leaderboard entries : string =
    if List.length entries = 0 then
      "📊 No votes recorded yet."
    else
      let lines = List.mapi (fun i entry ->
        let emoji = match i with
          | 0 -> "🥇"
          | 1 -> "🥈"
          | 2 -> "🥉"
          | _ -> "  "
        in
        Printf.sprintf "%s #%d - User %Ld: %s"
          emoji (i + 1) entry.user_id
          (if entry.score > 0 then "✅ Correct" else "❌ Incorrect")
      ) entries in
      "🏆 Quiz Leaderboard\n\n" ^ String.concat "\n" lines
end

(** {1 Poll Helper Functions} *)

let store_poll_from_message
    ~poll_type
    ~correct_option
    (msg : Telegram_generated.Gen_types.Message.t)
    (chat_id : Id.Chat.k Id.t) : unit =
  match msg.poll with
  | Some p ->
      Flo.debugf "[Store] Storing poll from message: poll_id=%s, poll_type=%s"
        p.id poll_type;
      PollMeta.add p.id { chat_id; message_id = msg.message_id; poll_type; correct_option }
  | None ->
      Flo.debug "[Store] ⚠️  Message has no poll attached"

(** {1 Command Handlers} *)

let handle_start ctx _args =
  Flo.debug "[Handler] /start command triggered";
  let open Bot.Ctx in

  let* user = require_user ctx in
  Flo.debugf "[Handler] User: id=%s, username=%s"
    (Format.asprintf "%a" Id.pp user.id)
    (match user.username with Some u -> u | None -> "none");

  let welcome_text =
    "🗳️  Welcome to the Poll & Quiz Bot!\n\n\
     I can create polls and quizzes for you.\n\n\
     Commands:\n\
     /poll <question>|<opt1>|<opt2>|... - Create a simple poll\n\
     /multipoll <question>|<opt1>|<opt2>|... - Poll with multiple answers\n\
     /timedpoll <seconds>|<question>|<opt1>|<opt2>|... - Timed poll\n\
     /quiz <question>|<correct>|<wrong1>|<wrong2>|... - Create a quiz (1st option is correct)\n\
     /results <poll_id> - Stop poll and show results\n\
     /leaderboard <poll_id> - Show quiz leaderboard\n\
     /list - List all active poll IDs\n\
     /help - Show this message"
  in

  let* _msg = answer ctx welcome_text in
  Flo.success "[Handler] ✅ Welcome message sent";
  Ok ()

let handle_help ctx _args =
  Flo.debug "[Handler] /help command triggered";
  let open Bot.Ctx in

  let help_text =
    "📚 Help - Poll & Quiz Bot\n\n\
     🗳️  Polls:\n\
     /poll - Create simple poll (single choice)\n\
     /multipoll - Multiple choice poll\n\
     /timedpoll - Auto-closing poll\n\n\
     🧠 Quizzes:\n\
     /quiz - Quiz with correct answer\n\
     /leaderboard - Show quiz rankings\n\n\
     📊 Results:\n\
     /results - Stop poll and show final results\n\
     /list - List active polls\n\n\
     Format: /poll Question|Option1|Option2|Option3\n\
     Example: /poll Favorite language?|OCaml|Haskell|Rust"
  in

  let* _msg = answer ctx help_text in
  Flo.success "[Handler] ✅ Help sent";
  Ok ()

let handle_poll ctx args =
  Flo.debugf "[Handler] /poll command triggered with args: [%s]"
    (String.concat " " args);

  let open Bot.Ctx in
  let client = client ctx in
  let chat_id = chat ctx in

  match args with
  | [] ->
      Flo.error "[Handler] ❌ No arguments provided";
      let* _ = answer ctx "Usage: /poll <question>|<opt1>|<opt2>|..." in
      Ok ()
  | question_and_opts ->
      let raw = String.concat " " question_and_opts in
      Flo.debugf "[Handler] Raw input: '%s'" raw;
      let parts = String.split_on_char '|' raw in
      match parts with
      | question :: options when List.length options >= 2 ->
          Flo.debugf "[Handler] Creating poll: question='%s', options=%d"
            question (List.length options);

          let options = List.map poll_option options in
          let* msg = Telegram_generated.Gen_methods.send_poll client
            ~chat_id ~question ~options () in

          store_poll_from_message ~poll_type:"poll" ~correct_option:None msg chat_id;
          Flo.success "[Handler] ✅ Poll created successfully";
          Ok ()
      | _ ->
          Flo.error "[Handler] ❌ Not enough options provided";
          let* _ = answer ctx "Provide at least two options separated by |" in
          Ok ()

let handle_multipoll ctx args =
  Flo.debug "[Handler] /multipoll command triggered";
  let open Bot.Ctx in
  let client = client ctx in
  let chat_id = chat ctx in

  match args with
  | [] ->
      let* _ = answer ctx "Usage: /multipoll <question>|<opt1>|<opt2>|..." in
      Ok ()
  | question_and_opts ->
      let raw = String.concat " " question_and_opts in
      let parts = String.split_on_char '|' raw in
      match parts with
      | question :: options when List.length options >= 2 ->
          Flo.debugf "[Handler] Creating multi-answer poll: question='%s'" question;
          let options = List.map poll_option options in
          let* msg = Telegram_generated.Gen_methods.send_poll client
            ~chat_id ~question ~options ~allows_multiple_answers:true () in

          store_poll_from_message ~poll_type:"poll" ~correct_option:None msg chat_id;
          Flo.success "[Handler] ✅ Multi-answer poll created";
          Ok ()
      | _ ->
          let* _ = answer ctx "Provide at least two options separated by |" in
          Ok ()

let handle_timedpoll ctx args =
  Flo.debug "[Handler] /timedpoll command triggered";
  let open Bot.Ctx in
  let client = client ctx in
  let chat_id = chat ctx in

  match args with
  | [] ->
      let* _ = answer ctx "Usage: /timedpoll <seconds>|<question>|<opt1>|<opt2>|..." in
      Ok ()
  | time_and_rest ->
      let raw = String.concat " " time_and_rest in
      let parts = String.split_on_char '|' raw in
      match parts with
      | seconds_str :: question :: options when List.length options >= 2 ->
          (match int_of_string_opt seconds_str with
           | Some seconds when seconds > 0 && seconds <= 600 ->
               Flo.debugf "[Handler] Creating timed poll: duration=%ds, question='%s'"
                 seconds question;
               let options = List.map poll_option options in
               let* msg = Telegram_generated.Gen_methods.send_poll client
                 ~chat_id ~question ~options
                 ~open_period:(Int64.of_int seconds) () in

               store_poll_from_message ~poll_type:"poll" ~correct_option:None msg chat_id;
               Flo.successf "[Handler] ✅ Timed poll created: %ds" seconds;
               Ok ()
           | _ ->
               let* _ = answer ctx "Invalid duration. Use 1-600 seconds." in
               Ok ()
          )
      | _ ->
          let* _ = answer ctx "Format: /timedpoll <seconds>|<question>|<opt1>|<opt2>|..." in
          Ok ()

let handle_quiz ctx args =
  Flo.debug "[Handler] /quiz command triggered";
  let open Bot.Ctx in
  let client = client ctx in
  let chat_id = chat ctx in

  match args with
  | [] ->
      let* _ = answer ctx "Usage: /quiz <question>|<correct_option>|<wrong1>|<wrong2>|..." in
      Ok ()
  | question_and_opts ->
      let raw = String.concat " " question_and_opts in
      Flo.debugf "[Handler] Raw quiz input: '%s'" raw;
      let parts = String.split_on_char '|' raw in
      match parts with
      | question :: options when List.length options >= 2 ->
          Flo.debugf "[Handler] Creating quiz: question='%s', options=%d (1st is correct)"
            question (List.length options);

          (* First option is the correct one *)
          let correct_option_id = 0L in
          let options_values = List.map poll_option options in

          let* msg = Telegram_generated.Gen_methods.send_poll client
            ~chat_id ~question ~options:options_values
            ~type_:"quiz"
            ~correct_option_id
            ~explanation:"<b>Quiz completed!</b> Check the results."
            ~explanation_parse_mode:"HTML"
            ~is_anonymous:false  (* Enable vote tracking *)
            () in

          store_poll_from_message ~poll_type:"quiz" ~correct_option:(Some 0) msg chat_id;
          Flo.success "[Handler] ✅ Quiz created (non-anonymous for tracking)";
          Ok ()
      | _ ->
          let* _ = answer ctx "Provide at least two options separated by |" in
          Ok ()

let handle_results ctx args =
  Flo.debug "[Handler] /results command triggered";
  let open Bot.Ctx in
  let client = client ctx in

  match args with
  | [] ->
      let* _ = answer ctx "Usage: /results <poll_id>\nUse /list to see active polls." in
      Ok ()
  | poll_id :: _ ->
      Flo.debugf "[Handler] Stopping poll: poll_id=%s" poll_id;
      (match PollMeta.find poll_id with
       | None ->
           Flo.error "[Handler] ❌ Unknown poll_id";
           let* _ = answer ctx "Unknown poll ID. Use /list to see active polls." in
           Ok ()
       | Some { chat_id; message_id; poll_type; _ } ->
           Flo.debug "[Handler] Found poll metadata, stopping...";
           let* poll = Telegram_generated.Gen_methods.stop_poll client
             ~chat_id ~message_id () in

           Flo.debug "[Handler] Poll stopped, formatting results";
           let results =
             poll.options
             |> List.mapi (fun i (opt : Telegram_generated.Gen_types.PollOption.t) ->
                  let count = Int64.to_int opt.voter_count in
                  Flo.debugf "[Handler] Option %d: '%s' - %d votes" i opt.text count;
                  Printf.sprintf "%c) %s — %d %s"
                    (Char.chr (65 + i)) opt.text count
                    (if count = 1 then "vote" else "votes"))
             |> String.concat "\n"
           in

           let header = match poll_type with
             | "quiz" -> "🧠 Quiz Results"
             | _ -> "📊 Poll Results"
           in

           let* _ = answer ctx (header ^ "\n\n" ^ results) in
           Flo.success "[Handler] ✅ Results sent";
           Ok ()
      )

let handle_leaderboard ctx args =
  Flo.debug "[Handler] /leaderboard command triggered";
  let open Bot.Ctx in

  match args with
  | [] ->
      let* _ = answer ctx "Usage: /leaderboard <poll_id>\nUse /list to see active polls." in
      Ok ()
  | poll_id :: _ ->
      Flo.debugf "[Handler] Generating leaderboard for poll_id=%s" poll_id;
      (match PollMeta.find poll_id with
       | None ->
           let* _ = answer ctx "Unknown poll ID. Use /list to see active polls." in
           Ok ()
       | Some { poll_type; correct_option; _ } ->
           if poll_type <> "quiz" then begin
             Flo.debug "[Handler] ⚠️  Not a quiz, cannot generate leaderboard";
             let* _ = answer ctx "Leaderboards are only available for quizzes." in
             Ok ()
           end else begin
             match correct_option with
             | None ->
                 let* _ = answer ctx "No correct answer recorded for this quiz." in
                 Ok ()
             | Some correct_idx ->
                 Flo.debugf "[Handler] Scoring quiz with correct_idx=%d" correct_idx;
                 let entries = Leaderboard.score_quiz ~poll_id ~correct_idx in
                 let leaderboard_text = Leaderboard.format_leaderboard entries in
                 let* _ = answer ctx leaderboard_text in
                 Flo.success "[Handler] ✅ Leaderboard sent";
                 Ok ()
           end
      )

let handle_list ctx _args =
  Flo.debug "[Handler] /list command triggered";
  let open Bot.Ctx in

  let poll_ids = PollMeta.all_poll_ids () in
  Flo.debugf "[Handler] Found %d active polls" (List.length poll_ids);

  if List.length poll_ids = 0 then begin
    let* _ = answer ctx "📝 No active polls yet.\n\nCreate one with /poll or /quiz!" in
    Ok ()
  end else begin
    let poll_list =
      poll_ids
      |> List.mapi (fun i pid ->
           match PollMeta.find pid with
           | Some { poll_type; _ } ->
               let emoji = if poll_type = "quiz" then "🧠" else "🗳️" in
               Printf.sprintf "%d. %s %s (%s)" (i + 1) emoji pid poll_type
           | None ->
               Printf.sprintf "%d. %s (unknown)" (i + 1) pid
         )
      |> String.concat "\n"
    in
    let* _ = answer ctx ("📝 Active Polls:\n\n" ^ poll_list) in
    Flo.success "[Handler] ✅ Poll list sent";
    Ok ()
  end

(** {1 Vote Tracking Handler} *)

let handle_poll_answer _ctx update =
  Flo.debug "[Handler] Processing update for poll_answer";
  match update.Telegram_generated.Gen_types.Update.poll_answer with
  | Some ans ->
      Flo.debugf "[Handler] Poll answer received: poll_id=%s" ans.poll_id;
      VoteTracker.track ans;
      Ok ()
  | None ->
      Ok ()

(** {1 Build Routes} *)

let build_routes bot =
  Flo.debug "[Builder] Registering routes...";

  let bot = bot |> Bot.command "start" handle_start in
  Flo.success "[Builder] ✅ Registered /start";

  let bot = bot |> Bot.command "help" handle_help in
  Flo.success "[Builder] ✅ Registered /help";

  let bot = bot |> Bot.command "poll" handle_poll in
  Flo.success "[Builder] ✅ Registered /poll";

  let bot = bot |> Bot.command "multipoll" handle_multipoll in
  Flo.success "[Builder] ✅ Registered /multipoll";

  let bot = bot |> Bot.command "timedpoll" handle_timedpoll in
  Flo.success "[Builder] ✅ Registered /timedpoll";

  let bot = bot |> Bot.command "quiz" handle_quiz in
  Flo.success "[Builder] ✅ Registered /quiz";

  let bot = bot |> Bot.command "results" handle_results in
  Flo.success "[Builder] ✅ Registered /results";

  let bot = bot |> Bot.command "leaderboard" handle_leaderboard in
  Flo.success "[Builder] ✅ Registered /leaderboard";

  let bot = bot |> Bot.command "list" handle_list in
  Flo.success "[Builder] ✅ Registered /list";

  (* Register poll_answer handler using Event.any *)
  let bot = bot |> Bot.on Bot.Event.any handle_poll_answer in
  Flo.success "[Builder] ✅ Registered poll_answer tracker";

  Flo.debug "[Builder] All routes registered";
  bot

(** {1 Main Entry Point} *)

let () =
  Eio_main.run @@ fun env ->
  Flo.debug "";
  Flo.info "╔══════════════════════════════════════════════════════════════════╗";
  Flo.info "║                     Poll & Quiz Bot                              ║";
  Flo.info "╚══════════════════════════════════════════════════════════════════╝";
  Flo.debug "";

  (* Phase 1: Initialize *)
  Flo.info "╔══════════════════════════════════════════════════════════════════╗";
  Flo.info "║                     Phase 1: Initialize                          ║";
  Flo.info "╚══════════════════════════════════════════════════════════════════╝";

  let token =
    match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t ->
        Flo.info "[Init] ✅ Token loaded from environment";
        t
    | None ->
        Flo.info "[Init] ❌ TELEGRAM_BOT_TOKEN not set";
        failwith "TELEGRAM_BOT_TOKEN environment variable not set"
  in

  let telegram_client = Telegram.Client.create ~env ~token () in
  Flo.info "[Init] Client created successfully";

  (* Phase 2: Build bot *)
  Flo.debug "";
  Flo.info "╔══════════════════════════════════════════════════════════════════╗";
  Flo.info "║                     Phase 2: Build Bot                           ║";
  Flo.info "╚══════════════════════════════════════════════════════════════════╝";

  let bot = Bot.make ~env ~client:telegram_client in
  let bot = build_routes bot in

  Flo.info "[Init] Bot created successfully";

  (* Phase 3: Start polling *)
  Flo.debug "";
  Flo.info "╔══════════════════════════════════════════════════════════════════╗";
  Flo.info "║                     Phase 3: Start Polling                       ║";
  Flo.info "╚══════════════════════════════════════════════════════════════════╝";

  Flo.info "[Polling] Starting long polling with poll/poll_answer updates...";
  Flo.info "[Polling] Bot is ready to receive updates";
  Flo.debug "";
  Flo.info "╔══════════════════════════════════════════════════════════════════╗";
  Flo.info "║                     Bot is Ready!                                ║";
  Flo.info "╚══════════════════════════════════════════════════════════════════╝";
  Flo.info "[Polling] Waiting for messages...";
  Flo.debug "";
  Flo.info "Features:";
  Flo.debug "  - Simple polls with single choice";
  Flo.debug "  - Multiple answer polls";
  Flo.debug "  - Timed polls with auto-close";
  Flo.debug "  - Quiz mode with correct answers";
  Flo.debug "  - Vote tracking for non-anonymous polls";
  Flo.debug "  - Poll results and leaderboards";
  Flo.debug "  - Result-based error handling";
  Flo.debug "";

  Bot.run bot
