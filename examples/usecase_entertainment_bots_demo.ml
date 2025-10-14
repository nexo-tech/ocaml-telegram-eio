(** Entertainment Bots Use Case - Quiz, trivia, jokes, and random facts

    This example demonstrates entertainment bot patterns:
    - Quiz bot with multiple choice questions
    - Score tracking and leaderboards
    - Random fact generator
    - Joke bot with fallback
    - Question banks and random selection
    - Interactive quiz with inline keyboards

    Commands:
      /start - Show main menu
      /quiz - Start a quiz (random question)
      /score - Show your current score
      /leaderboard - Show top scorers
      /fact - Random interesting fact
      /joke - Random joke
      /riddle - Random riddle
      /reset_score - Reset your score

    This example has VERBOSE LOGGING enabled for troubleshooting.

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/usecase_entertainment_bots_demo.exe
*)

open Telegram
open Tg

(* Configure verbose logging via functor composition *)
module Verbose_log = Log.Make (Log.Console) (struct
  let src = "EntertainmentBots"
  let level = Log.Debug
end)

module Verbose_session = Session.Make (Verbose_log)
module Verbose_polling = Polling.Make (Verbose_log)
module Verbose_bot = Bot.Make (Verbose_log) (Verbose_session) (Verbose_polling)

module KB = Keyboard

(** Question type for quiz *)
type question = {
  id: string;
  text: string;
  options: string list;
  correct_index: int;
  explanation: string option;
}

(** Quiz state *)
type quiz_state = {
  current_question_id: string;
  correct_index: int;
  questions_asked: int;
  correct_answers: int;
}

(** Question bank *)
module QuestionBank = struct
  let questions = [
    { id = "q1";
      text = "Which programming language uses algebraic data types and pattern matching?";
      options = ["Python"; "OCaml"; "JavaScript"; "Go"];
      correct_index = 1;
      explanation = Some "OCaml has powerful algebraic data types (ADTs) and exhaustive pattern matching!" };

    { id = "q2";
      text = "What is 2 + 2 * 3?";
      options = ["12"; "8"; "10"; "6"];
      correct_index = 1;
      explanation = Some "Order of operations: 2 + (2 * 3) = 2 + 6 = 8" };

    { id = "q3";
      text = "Which city is the capital of France?";
      options = ["Berlin"; "Madrid"; "Paris"; "Rome"];
      correct_index = 2;
      explanation = None };

    { id = "q4";
      text = "What does Eio provide for OCaml?";
      options = ["Graphics library"; "Structured concurrency"; "Database ORM"; "Web framework"];
      correct_index = 1;
      explanation = Some "Eio brings structured concurrency with algebraic effects to OCaml!" };

    { id = "q5";
      text = "Which is the largest planet in our solar system?";
      options = ["Earth"; "Mars"; "Jupiter"; "Saturn"];
      correct_index = 2;
      explanation = Some "Jupiter is the largest planet, more than twice as massive as all other planets combined!" };
  ]

  let pick_random () =
    let q = List.nth questions (Random.int (List.length questions)) in
    Eio.traceln "[QuestionBank] Selected question: %s" q.id;
    q

  let find_by_id id =
    List.find_opt (fun q -> q.id = id) questions
end

(** Random facts *)
module Facts = struct
  let facts = [
    "🐫 OCaml is named after the Objective Caml language, which was itself based on Caml.";
    "🌍 The Telegram Bot API serves over 8 billion requests daily!";
    "⚡ Eio uses algebraic effects for structured concurrency without monads.";
    "🔢 The first computer programmer was Ada Lovelace in the 1840s.";
    "🎯 OCaml's type system can catch many bugs at compile-time that other languages catch at runtime.";
    "🚀 Telegram bots can handle millions of users with proper architecture.";
    "🧠 Pattern matching in OCaml is exhaustive - the compiler warns about missing cases!";
    "💡 Functional programming often leads to fewer bugs due to immutability.";
  ]

  let random () =
    let fact = List.nth facts (Random.int (List.length facts)) in
    Eio.traceln "[Facts] Selected fact (index %d/%d)" (Random.int (List.length facts)) (List.length facts);
    fact
end

(** Jokes *)
module Jokes = struct
  let jokes = [
    "Why do programmers prefer dark mode? Because light attracts bugs! 🐛";
    "Why did the functional programmer get lost? They couldn't find their state! 🗺️";
    "What's a bot's favorite music genre? Algorithm and blues! 🎵";
    "Why do OCaml developers write such reliable code? They're always in the Result! ✅";
    "How many programmers does it take to change a light bulb? None, that's a hardware problem! 💡";
    "What do you call a bot that's always happy? An optimist-ic compiler! 😊";
  ]

  let random () =
    let joke = List.nth jokes (Random.int (List.length jokes)) in
    Eio.traceln "[Jokes] Selected joke (index %d/%d)" (Random.int (List.length jokes)) (List.length jokes);
    joke
end

(** Riddles *)
module Riddles = struct
  type riddle = {
    question: string;
    answer: string;
  }

  let riddles = [
    { question = "I speak without a mouth and hear without ears. I have no body, but come alive with wind. What am I?";
      answer = "An echo" };
    { question = "The more you take, the more you leave behind. What am I?";
      answer = "Footsteps" };
    { question = "What has keys but no locks, space but no room, and you can enter but can't go inside?";
      answer = "A keyboard" };
  ]

  let random () =
    List.nth riddles (Random.int (List.length riddles))
end

(** Leaderboard *)
module Leaderboard = struct
  (* user_id -> (username, score) *)
  let scores : (int64, string * int) Hashtbl.t = Hashtbl.create 100

  let update_score user_id username score =
    Eio.traceln "[Leaderboard] Updating score: %Ld (%s) = %d" user_id username score;
    Hashtbl.replace scores user_id (username, score)

  let top_n n =
    Hashtbl.to_seq scores
    |> List.of_seq
    |> List.sort (fun (_, (_, score1)) (_, (_, score2)) -> compare score2 score1)
    |> (fun lst -> if List.length lst > n then List.filteri (fun i _ -> i < n) lst else lst)

  let format_leaderboard n =
    let top = top_n n in

    if List.length top = 0 then
      "🏆 <b>Leaderboard</b>\n\nNo scores yet. Play /quiz to get on the board!"
    else
      let lines = List.mapi (fun i (_, (username, score)) ->
        let medal = match i with
          | 0 -> "🥇"
          | 1 -> "🥈"
          | 2 -> "🥉"
          | _ -> Printf.sprintf "%d." (i + 1)
        in
        Printf.sprintf "%s %s - %d points" medal username score
      ) top |> String.concat "\n" in

      Printf.sprintf "🏆 <b>Leaderboard</b>\n\n%s" lines
end

(** Session keys *)
let quiz_state_key = Verbose_session.make ~name:"quiz_state"
let riddle_answer_key = Verbose_session.make ~name:"riddle_answer"

let () =
  Printexc.record_backtrace true;
  Random.self_init ();
  Eio.traceln "=== Entertainment Bots Demo Starting ===";

  let token = match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None -> Printf.eprintf "TELEGRAM_BOT_TOKEN not set\n"; exit 1
  in

  Eio_main.run @@ fun env ->
  let client = Client.create ~env ~token () in

  Eio.traceln "🤖 Entertainment Bots Demo Started";
  Eio.traceln "Question bank: %d questions" (List.length QuestionBank.questions);
  Eio.traceln "Fact bank: %d facts" (List.length Facts.facts);
  Eio.traceln "Joke bank: %d jokes" (List.length Jokes.jokes);

  let session_store = Verbose_session.Memory_store.create () in

  Verbose_bot.make ~env ~client
  |> Verbose_bot.with_sessions (module Verbose_session.Memory_store) session_store

  (* /start - Main menu *)
  |> Verbose_bot.command "start" ~desc:"Show main menu" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/start] Showing main menu";

      let keyboard = KB.inline [
        [KB.callback ~text:"❓ Start Quiz" ~data:"action:quiz"];
        [KB.callback ~text:"🤓 Random Fact" ~data:"action:fact"];
        [KB.callback ~text:"😄 Joke" ~data:"action:joke"];
        [KB.callback ~text:"🧩 Riddle" ~data:"action:riddle"];
        [KB.callback ~text:"🏆 Leaderboard" ~data:"action:leaderboard"];
      ] in

      let text =
        "🎮 <b>Entertainment Bots Demo</b>\n\n\
         Test your knowledge and have fun!\n\n\
         ❓ Quiz - Multiple choice questions\n\
         🤓 Facts - Interesting facts\n\
         😄 Jokes - Programming jokes\n\
         🧩 Riddles - Brain teasers\n\
         🏆 Leaderboard - Top scores\n\n\
         Choose an option below:"
      in

      match send ~keyboard ctx text with
      | Ok _ -> Eio.traceln "[/start] ✓"; Ok ()
      | Error e -> Eio.traceln "[/start] ✗ %a" Error.pp e; Ok ()
    )

  (* /quiz - Start quiz *)
  |> Verbose_bot.command "quiz" ~desc:"Start quiz" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/quiz] Starting quiz";

      let question = QuestionBank.pick_random () in

      (* Initialize or update quiz state *)
      let state = {
        current_question_id = question.id;
        correct_index = question.correct_index;
        questions_asked = 1;
        correct_answers = 0;
      } in

      session_set ctx quiz_state_key state;

      (* Create answer buttons *)
      let answer_buttons = List.mapi (fun i opt ->
        let letter = Char.chr (65 + i) in (* A, B, C, D *)
        [KB.callback ~text:(Printf.sprintf "%c) %s" letter opt) ~data:(Printf.sprintf "quiz:answer:%s:%d" question.id i)]
      ) question.options in

      let keyboard = KB.inline answer_buttons in

      let text = Printf.sprintf "❓ <b>Quiz Question</b>\n\n%s" question.text in

      match send ~keyboard ctx text with
      | Ok _ -> Eio.traceln "[/quiz] ✓"; Ok ()
      | Error e -> Eio.traceln "[/quiz] ✗ %a" Error.pp e; Ok ()
    )

  (* Handle quiz answers *)
  |> Verbose_bot.on_callback (fun ctx data ->
      if String.starts_with ~prefix:"quiz:answer:" data then (
        let open Verbose_bot.Ctx in

        let parts = String.split_on_char ':' data in
        match parts with
        | ["quiz"; "answer"; qid; idx_str] ->
            Eio.traceln "[quiz:answer] Question: %s, Answer: %s" qid idx_str;

            let selected_idx = int_of_string idx_str in

            (match session_get ctx quiz_state_key with
             | None ->
                 Eio.traceln "[quiz:answer] No quiz state, use /quiz to start";
                 Ok ()

             | Some state when state.current_question_id <> qid ->
                 Eio.traceln "[quiz:answer] Stale question (expected %s, got %s)"
                   state.current_question_id qid;
                 Ok ()

             | Some state ->
                 let is_correct = selected_idx = state.correct_index in
                 let () = Eio.traceln "[quiz:answer] Answer %s (correct=%d, selected=%d)"
                   (if is_correct then "CORRECT" else "WRONG")
                   state.correct_index selected_idx in

                 let new_score = if is_correct then state.correct_answers + 1 else state.correct_answers in
                 let new_questions_asked = state.questions_asked + 1 in

                 (* Update leaderboard *)
                 let () = match user ctx with
                  | Some u ->
                      let user_id_str = Id.to_string u.id in
                      let user_id = Int64.of_string user_id_str in
                      let username = Option.value u.username ~default:"Anonymous" in
                      Leaderboard.update_score user_id username new_score
                  | None -> () in

                 (* Get question for explanation *)
                 let question_opt = QuestionBank.find_by_id qid in

                 let feedback = if is_correct then
                   match question_opt with
                   | Some q when q.explanation <> None ->
                       Printf.sprintf "✅ Correct!\n\n%s" (Option.get q.explanation)
                   | _ -> "✅ Correct!"
                 else
                   match question_opt with
                   | Some q ->
                       let correct_option = List.nth q.options q.correct_index in
                       Printf.sprintf "❌ Wrong. The correct answer is: %s" correct_option
                   | None -> "❌ Wrong."
                 in

                 let score_text = Printf.sprintf
                   "\n\nScore: %d/%d"
                   new_score new_questions_asked
                 in

                 (* Pick next question *)
                 let next_question = QuestionBank.pick_random () in

                 let next_state = {
                   current_question_id = next_question.id;
                   correct_index = next_question.correct_index;
                   questions_asked = new_questions_asked;
                   correct_answers = new_score;
                 } in

                 let () = session_set ctx quiz_state_key next_state in

                 let next_buttons = List.mapi (fun i opt ->
                   let letter = Char.chr (65 + i) in
                   [KB.callback ~text:(Printf.sprintf "%c) %s" letter opt)
                    ~data:(Printf.sprintf "quiz:answer:%s:%d" next_question.id i)]
                 ) next_question.options in

                 let keyboard = KB.inline next_buttons in

                 let full_text = Printf.sprintf
                   "%s%s\n\n<b>Next Question:</b>\n\n%s"
                   feedback score_text next_question.text
                 in

                 (match edit ~keyboard ctx full_text with
                  | Ok () -> Eio.traceln "[quiz:answer] ✓"; Ok ()
                  | Error e -> Eio.traceln "[quiz:answer] ✗ %a" Error.pp e; Ok ())
            )

        | _ -> Ok ()
      ) else Ok ()
    )

  (* /score - Show current score *)
  |> Verbose_bot.command "score" ~desc:"Show your quiz score" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/score] Showing score";

      match session_get ctx quiz_state_key with
      | None ->
          (match reply ctx "No active quiz. Use /quiz to start!" with
           | Ok _ -> Ok ()
           | Error e -> Eio.traceln "[/score] ✗ %a" Error.pp e; Ok ())

      | Some state ->
          let text = Printf.sprintf
            "📊 <b>Your Score</b>\n\n\
             Correct: %d/%d\n\
             Accuracy: %.1f%%\n\n\
             Use /quiz to continue playing!"
            state.correct_answers
            state.questions_asked
            (if state.questions_asked > 0 then
               float_of_int state.correct_answers /. float_of_int state.questions_asked *. 100.0
             else 0.0)
          in

          (match reply ctx text with
           | Ok _ -> Eio.traceln "[/score] ✓"; Ok ()
           | Error e -> Eio.traceln "[/score] ✗ %a" Error.pp e; Ok ())
    )

  (* /leaderboard - Show top scores *)
  |> Verbose_bot.command "leaderboard" ~desc:"Show top scorers" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/leaderboard] Showing leaderboard";

      let leaderboard_text = Leaderboard.format_leaderboard 10 in

      match reply ctx leaderboard_text with
      | Ok _ -> Eio.traceln "[/leaderboard] ✓"; Ok ()
      | Error e -> Eio.traceln "[/leaderboard] ✗ %a" Error.pp e; Ok ()
    )

  (* /fact - Random fact *)
  |> Verbose_bot.command "fact" ~desc:"Random interesting fact" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/fact] Generating random fact";

      let fact = Facts.random () in

      match reply ctx fact with
      | Ok _ -> Eio.traceln "[/fact] ✓"; Ok ()
      | Error e -> Eio.traceln "[/fact] ✗ %a" Error.pp e; Ok ()
    )

  (* /joke - Random joke *)
  |> Verbose_bot.command "joke" ~desc:"Random joke" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/joke] Generating random joke";

      let joke = Jokes.random () in

      match reply ctx ("😄 " ^ joke) with
      | Ok _ -> Eio.traceln "[/joke] ✓"; Ok ()
      | Error e -> Eio.traceln "[/joke] ✗ %a" Error.pp e; Ok ()
    )

  (* /riddle - Random riddle *)
  |> Verbose_bot.command "riddle" ~desc:"Random riddle" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/riddle] Generating random riddle";

      let riddle = Riddles.random () in

      (* Store answer in session *)
      session_set ctx riddle_answer_key riddle.answer;

      let keyboard = KB.inline [
        [KB.callback ~text:"🔍 Show Answer" ~data:"riddle:answer"];
      ] in

      let text = Printf.sprintf "🧩 <b>Riddle</b>\n\n%s" riddle.question in

      match send ~keyboard ctx text with
      | Ok _ -> Eio.traceln "[/riddle] ✓"; Ok ()
      | Error e -> Eio.traceln "[/riddle] ✗ %a" Error.pp e; Ok ()
    )

  (* /reset_score - Reset score *)
  |> Verbose_bot.command "reset_score" ~desc:"Reset your score" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/reset_score] Resetting score";

      session_delete ctx quiz_state_key;

      match reply ctx
        "🔄 Score reset!\n\n\
         Your quiz progress has been cleared.\n\
         Use /quiz to start fresh."
      with
      | Ok _ -> Eio.traceln "[/reset_score] ✓"; Ok ()
      | Error e -> Eio.traceln "[/reset_score] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: action:quiz *)
  |> Verbose_bot.on_callback_data "action:quiz" (fun ctx ->
      let open Verbose_bot.Ctx in

      let question = QuestionBank.pick_random () in

      let state = {
        current_question_id = question.id;
        correct_index = question.correct_index;
        questions_asked = 1;
        correct_answers = 0;
      } in

      session_set ctx quiz_state_key state;

      let answer_buttons = List.mapi (fun i opt ->
        let letter = Char.chr (65 + i) in
        [KB.callback ~text:(Printf.sprintf "%c) %s" letter opt) ~data:(Printf.sprintf "quiz:answer:%s:%d" question.id i)]
      ) question.options in

      let keyboard = KB.inline answer_buttons in

      match edit ~keyboard ctx (Printf.sprintf "❓ <b>Quiz Question</b>\n\n%s" question.text) with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[action:quiz] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: action:fact *)
  |> Verbose_bot.on_callback_data "action:fact" (fun ctx ->
      let open Verbose_bot.Ctx in
      let fact = Facts.random () in
      match edit ctx fact with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[action:fact] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: action:joke *)
  |> Verbose_bot.on_callback_data "action:joke" (fun ctx ->
      let open Verbose_bot.Ctx in
      let joke = Jokes.random () in
      match edit ctx ("😄 " ^ joke) with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[action:joke] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: action:riddle *)
  |> Verbose_bot.on_callback_data "action:riddle" (fun ctx ->
      let open Verbose_bot.Ctx in

      let riddle = Riddles.random () in
      session_set ctx riddle_answer_key riddle.answer;

      let keyboard = KB.inline [
        [KB.callback ~text:"🔍 Show Answer" ~data:"riddle:answer"];
      ] in

      match edit ~keyboard ctx (Printf.sprintf "🧩 <b>Riddle</b>\n\n%s" riddle.question) with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[action:riddle] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: action:leaderboard *)
  |> Verbose_bot.on_callback_data "action:leaderboard" (fun ctx ->
      let open Verbose_bot.Ctx in
      let leaderboard_text = Leaderboard.format_leaderboard 10 in
      match edit ctx leaderboard_text with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[action:leaderboard] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: riddle:answer *)
  |> Verbose_bot.on_callback_data "riddle:answer" (fun ctx ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[riddle:answer] Showing riddle answer";

      match session_get ctx riddle_answer_key with
      | Some answer ->
          let text = Printf.sprintf "🧩 <b>Answer</b>\n\n%s" answer in
          (match edit ctx text with
           | Ok () -> Ok ()
           | Error e -> Eio.traceln "[riddle:answer] ✗ %a" Error.pp e; Ok ())
      | None ->
          (match edit ctx "No riddle in progress. Use /riddle to start!" with
           | Ok () -> Ok ()
           | Error e -> Eio.traceln "[riddle:answer] ✗ %a" Error.pp e; Ok ())
    )

  |> Verbose_bot.run
