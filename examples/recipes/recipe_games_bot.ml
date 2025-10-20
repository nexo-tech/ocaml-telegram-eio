(** Recipe: Games Bot (Tic-Tac-Toe)

    A comprehensive turn-based game system demonstrating:
    - Game state management with typed sessions
    - Turn-based gameplay with inline keyboards
    - Player management (join, turns, validation)
    - Win/draw/loss detection
    - Scoreboard and leaderboard
    - Rematch functionality
    - Game expiration with TTL
    - Per-game locking for thread safety
    - Result-based error handling
    - Functor-based verbose logging
*)

open Telegram
open Tg

(** {1 Verbose Logging Setup} *)

(* Configure verbose logging with flo *)
let () = Flo.set_level Severity.Debug

(** {1 Game State Types} *)

type cell = Empty | X | O

type board = cell array  (* length 9; indices 0..8 *)

type player = Xp | Op

type game_state = {
  id : string;
  _chat_id : Id.Chat.k Id.t;
  board : board;
  turn : player;
  x_user_id : Id.User.k Id.t;
  o_user_id : Id.User.k Id.t option;
  started_at : float;
  ttl_seconds : int;
}

let game_key : game_state Session.key = Session.make ~name:"ttt_game"

let now () = Unix.gettimeofday ()

let expired g =
  let age = now () -. g.started_at in
  let expired = age > float_of_int g.ttl_seconds in
  if expired then
    Eio.traceln "[Game] Game expired: id=%s, age=%.1fs, ttl=%ds" g.id age g.ttl_seconds;
  expired

let new_board () = Array.make 9 Empty

let new_game ~id ~chat_id ~x_user_id ~o_user_id =
  Eio.traceln "[Game] Creating new game: id=%s, x_user=%a, o_user=%s"
    id Id.pp x_user_id (match o_user_id with Some u -> Id.to_string u | None -> "waiting");
  {
    id;
    _chat_id = chat_id;
    board = new_board ();
    turn = Xp;
    x_user_id;
    o_user_id;
    started_at = now ();
    ttl_seconds = 1800;  (* 30 minutes *)
  }

(** {1 Game Locks} *)

module GameLocks = struct
  let table : (string, Eio.Mutex.t) Hashtbl.t = Hashtbl.create 128

  let get id =
    match Hashtbl.find_opt table id with
    | Some m ->
        Eio.traceln "[GameLocks] Using existing lock for game: id=%s" id;
        m
    | None ->
        Eio.traceln "[GameLocks] Creating new lock for game: id=%s" id;
        let m = Eio.Mutex.create () in
        Hashtbl.replace table id m;
        m

  let _cleanup () =
    let count = Hashtbl.length table in
    if count > 0 then
      Eio.traceln "[GameLocks] Active locks: %d" count
end

(** {1 Game Logic} *)

module GameLogic = struct
  let win_lines = [|
    [|0;1;2|]; [|3;4;5|]; [|6;7;8|];  (* rows *)
    [|0;3;6|]; [|1;4;7|]; [|2;5;8|];  (* cols *)
    [|0;4;8|]; [|2;4;6|];             (* diags *)
  |]

  let winner (b : board) : cell option =
    let check a b c =
      match a, b, c with
      | X, X, X -> Some X
      | O, O, O -> Some O
      | _ -> None
    in

    let result = ref None in
    for i = 0 to Array.length win_lines - 1 do
      let l = win_lines.(i) in
      match check b.(l.(0)) b.(l.(1)) b.(l.(2)) with
      | Some w ->
          Eio.traceln "[GameLogic] Winner found: %s on line %d"
            (match w with X -> "X" | O -> "O" | Empty -> "Empty") i;
          result := Some w
      | None -> ()
    done;
    !result

  let board_full b =
    let full = Array.for_all (function Empty -> false | _ -> true) b in
    if full then
      Eio.traceln "[GameLogic] Board is full";
    full

  let mark_of_player = function
    | Xp -> X
    | Op -> O

  let player_name = function
    | Xp -> "X"
    | Op -> "O"

  let cell_name = function
    | Empty -> "Empty"
    | X -> "X"
    | O -> "O"

  let handle_move (g : game_state) user_id idx : (game_state * [ `Continue | `Win of cell | `Draw ]) option =
    Eio.traceln "[GameLogic] Processing move: game=%s, user=%a, idx=%d" g.id Id.pp user_id idx;

    if idx < 0 || idx > 8 then begin
      Eio.traceln "[GameLogic] ❌ Invalid index: %d" idx;
      None
    end else if Option.is_none g.o_user_id then begin
      Eio.traceln "[GameLogic] ❌ Game not started, waiting for O player";
      None
    end else begin
      let expected_user = match g.turn with Xp -> g.x_user_id | Op -> Option.get g.o_user_id in
      if Id.to_string user_id <> Id.to_string expected_user then begin
        Eio.traceln "[GameLogic] ❌ Wrong player: expected=%a, got=%a" Id.pp expected_user Id.pp user_id;
        None
      end else begin
        match g.board.(idx) with
        | X | O ->
            Eio.traceln "[GameLogic] ❌ Cell already occupied: idx=%d, cell=%s"
              idx (cell_name g.board.(idx));
            None
        | Empty ->
            let mark = mark_of_player g.turn in
            g.board.(idx) <- mark;
            Eio.traceln "[GameLogic] ✅ Move made: player=%s, idx=%d, mark=%s"
              (player_name g.turn) idx (cell_name mark);

            match winner g.board with
            | Some w ->
                Eio.traceln "[GameLogic] 🏆 Game won by: %s" (cell_name w);
                Some (g, `Win w)
            | None ->
                if board_full g.board then begin
                  Eio.traceln "[GameLogic] 🤝 Game drawn";
                  Some (g, `Draw)
                end else begin
                  let next_turn = match g.turn with Xp -> Op | Op -> Xp in
                  Eio.traceln "[GameLogic] ➡️  Turn switches to: %s" (player_name next_turn);
                  Some ({ g with turn = next_turn }, `Continue)
                end
      end
    end
end

(** {1 Scoreboard} *)

module Scoreboard = struct
  type entry = {
    wins : int;
    draws : int;
    losses : int;
  }

  let table : (string, entry) Hashtbl.t = Hashtbl.create 1000

  let get user_id =
    let key = Id.to_string user_id in
    match Hashtbl.find_opt table key with
    | Some e ->
        Eio.traceln "[Scoreboard] Found entry for user %s: W:%d D:%d L:%d"
          key e.wins e.draws e.losses;
        e
    | None ->
        Eio.traceln "[Scoreboard] New user %s" key;
        { wins = 0; draws = 0; losses = 0 }

  let set user_id e =
    let key = Id.to_string user_id in
    Hashtbl.replace table key e;
    Eio.traceln "[Scoreboard] Updated user %s: W:%d D:%d L:%d"
      key e.wins e.draws e.losses

  let record_win ~winner ~loser =
    Eio.traceln "[Scoreboard] Recording win: winner=%a, loser=%a" Id.pp winner Id.pp loser;
    let w = get winner in
    let l = get loser in
    set winner { w with wins = w.wins + 1 };
    set loser { l with losses = l.losses + 1 }

  let record_draw ~x ~o =
    Eio.traceln "[Scoreboard] Recording draw: x=%a, o=%a" Id.pp x Id.pp o;
    let a = get x in
    let b = get o in
    set x { a with draws = a.draws + 1 };
    set o { b with draws = b.draws + 1 }

  let top_n n =
    Eio.traceln "[Scoreboard] Getting top %d players" n;
    let players = Hashtbl.to_seq table |> List.of_seq in
    let sorted = List.sort (fun (_, a) (_, b) -> compare b.wins a.wins) players in
    let top = List.filteri (fun i _ -> i < n) sorted in
    Eio.traceln "[Scoreboard] Found %d players in top list" (List.length top);
    top

  let format_leaderboard entries =
    if List.length entries = 0 then
      "🏆 <b>Leaderboard</b>\n\nNo games played yet."
    else
      let lines = List.mapi (fun i (user_id, e) ->
        let medal = match i with
          | 0 -> "🥇"
          | 1 -> "🥈"
          | 2 -> "🥉"
          | _ -> Printf.sprintf "%d." (i + 1)
        in
        Printf.sprintf "%s User %s — W:%d D:%d L:%d"
          medal user_id e.wins e.draws e.losses
      ) entries in
      "🏆 <b>Leaderboard</b>\n\n" ^ String.concat "\n" lines
end

(** {1 Board Rendering} *)

module BoardRenderer = struct
  let cell_text = function
    | Empty -> "·"
    | X -> "❌"
    | O -> "⭕"

  let render_keyboard (g : game_state) =
    Eio.traceln "[BoardRenderer] Rendering keyboard for game: id=%s" g.id;

    let open Telegram_generated.Gen_types in
    let rows =
      List.init 3 (fun r ->
        List.init 3 (fun c ->
          let i = r * 3 + c in
          let text = cell_text g.board.(i) in
          let callback_data = Printf.sprintf "ttt:%s:%d" g.id i in
          InlineKeyboardButton.{
            text;
            url = None;
            callback_data = Some callback_data;
            web_app = None;
            login_url = None;
            switch_inline_query = None;
            switch_inline_query_current_chat = None;
            switch_inline_query_chosen_chat = None;
            copy_text = None;
            callback_game = None;
            pay = None;
            unknown_fields = [];
          }
        )
      )
    in

    InlineKeyboardMarkup.{
      inline_keyboard = rows;
      unknown_fields = [];
    }

  let board_text g =
    let turn_symbol = match g.turn with Xp -> "❌" | Op -> "⭕" in
    let turn_name = match g.turn with Xp -> "X" | Op -> "O" in

    Printf.sprintf
      "🎮 <b>Tic-Tac-Toe</b>\n\n\
       Turn: %s %s\n\
       X: User %s\n\
       O: User %s"
      turn_symbol turn_name
      (Id.to_string g.x_user_id)
      (Option.fold ~none:"Waiting..." ~some:Id.to_string g.o_user_id)

  let serialize_keyboard keyboard =
    let open Telegram_generated.Gen_types in
    let json = Yojson.Safe.to_string (InlineKeyboardMarkup.to_yojson keyboard) in
    Eio.traceln "[BoardRenderer] Serialized keyboard: %d bytes" (String.length json);
    json
end

(** {1 Command Handlers} *)

let handle_start ctx _args =
  Eio.traceln "[Handler] /start command triggered";
  let open Bot.Ctx in

  let* user = require_user ctx in
  Eio.traceln "[Handler] User: id=%a, username=%s"
    Id.pp user.id
    (match user.username with Some u -> u | None -> "none");

  let welcome_text =
    "🎮 <b>Tic-Tac-Toe Bot</b>\n\n\
     Welcome to Tic-Tac-Toe! Challenge your friends to a game.\n\n\
     <b>Commands:</b>\n\
     /new - Start a new game\n\
     /stats - View your statistics\n\
     /leaderboard - View top players\n\
     /help - Show help information\n\n\
     <b>How to Play:</b>\n\
     1. Start a game with /new\n\
     2. Wait for another player to join\n\
     3. Take turns clicking squares\n\
     4. Get 3 in a row to win!"
  in

  let* _msg = answer ctx welcome_text in
  Eio.traceln "[Handler] ✅ Welcome message sent";
  Ok ()

let handle_new ctx _args =
  Eio.traceln "[Handler] /new command triggered";
  let open Bot.Ctx in

  let* user = require_user ctx in
  let chat_id = chat ctx in

  (* Generate game ID *)
  let game_id = Printf.sprintf "ttt_%d_%f" (Random.int 1000000) (Unix.time ()) in

  Eio.traceln "[Handler] Creating new game: game_id=%s, creator=%a" game_id Id.pp user.id;

  (* Create game state with creator as X, waiting for O *)
  let game = new_game ~id:game_id ~chat_id ~x_user_id:user.id ~o_user_id:None in

  (* Save to session *)
  let () = session_set ctx game_key game in

  (* Create join button using high-level API *)
  let join_button = Types.Callback_button {
    text = "Join as ⭕";
    data = Printf.sprintf "ttt:join:%s" game_id
  } in

  let game_text = Printf.sprintf
    "🎮 <b>New Game!</b>\n\n\
     Game ID: <code>%s</code>\n\
     ❌ X: User %s\n\
     ⭕ O: Waiting...\n\n\
     Click the button below to join!"
    game_id (Id.to_string user.id)
  in

  let* _msg = send ctx game_text ~keyboard:[[join_button]] in
  Eio.traceln "[Handler] ✅ New game created, waiting for O player";
  Ok ()

let handle_stats ctx _args =
  Eio.traceln "[Handler] /stats command triggered";
  let open Bot.Ctx in

  let* user = require_user ctx in

  let entry = Scoreboard.get user.id in

  let stats_text = Printf.sprintf
    "📊 <b>Your Statistics</b>\n\n\
     User ID: %s\n\
     🏆 Wins: %d\n\
     🤝 Draws: %d\n\
     ❌ Losses: %d\n\
     📈 Total Games: %d\n\
     💯 Win Rate: %.1f%%"
    (Id.to_string user.id)
    entry.wins
    entry.draws
    entry.losses
    (entry.wins + entry.draws + entry.losses)
    (if entry.wins + entry.losses > 0 then
       float_of_int entry.wins /. float_of_int (entry.wins + entry.losses) *. 100.0
     else 0.0)
  in

  let* _msg = answer ctx stats_text in
  Eio.traceln "[Handler] ✅ Stats sent";
  Ok ()

let handle_leaderboard ctx _args =
  Eio.traceln "[Handler] /leaderboard command triggered";
  let open Bot.Ctx in

  let top_players = Scoreboard.top_n 10 in
  let leaderboard_text = Scoreboard.format_leaderboard top_players in

  let* _msg = answer ctx leaderboard_text in
  Eio.traceln "[Handler] ✅ Leaderboard sent: %d players" (List.length top_players);
  Ok ()

let handle_help ctx _args =
  Eio.traceln "[Handler] /help command triggered";
  let open Bot.Ctx in

  let help_text =
    "🎮 <b>Tic-Tac-Toe Help</b>\n\n\
     <b>Game Rules:</b>\n\
     • Two players take turns\n\
     • Place your mark (X or O) in a square\n\
     • Get 3 in a row (horizontal, vertical, or diagonal) to win\n\
     • If all squares are filled with no winner, it's a draw\n\n\
     <b>Commands:</b>\n\
     /new - Start a new game\n\
     /stats - View your statistics\n\
     /leaderboard - View top 10 players\n\
     /help - Show this help\n\n\
     <b>How to Play:</b>\n\
     1. Use /new to create a game\n\
     2. Another player clicks \"Join as ⭕\"\n\
     3. Click on empty squares (·) to make your move\n\
     4. The game ends when someone wins or it's a draw\n\n\
     <b>Tips:</b>\n\
     • Games expire after 30 minutes of inactivity\n\
     • Your statistics are tracked automatically\n\
     • Check the leaderboard to see top players"
  in

  let* _msg = answer ctx help_text in
  Eio.traceln "[Handler] ✅ Help sent";
  Ok ()

(** {1 Callback Handlers} *)

let handle_join ctx callback_query =
  Eio.traceln "[Handler] Processing join callback";
  let open Bot.Ctx in

  let data = Option.value ~default:"" callback_query.Telegram_generated.Gen_types.CallbackQuery.data in

  if not (String.starts_with ~prefix:"ttt:join:" data) then
    Ok ()
  else begin
    let game_id = String.sub data 9 (String.length data - 9) in
    Eio.traceln "[Handler] Join request for game: game_id=%s" game_id;

    let* user = require_user ctx in
    let chat_id = chat ctx in

    match session_get ctx game_key with
    | None ->
        Eio.traceln "[Handler] ❌ No game found in session";
        let client = client ctx in
        let* _result = Telegram_generated.Gen_methods.answer_callback_query client
          ~callback_query_id:callback_query.id
          ~text:"Game not found"
          ~show_alert:true
          ()
        in
        Ok ()
    | Some game when game.id <> game_id ->
        Eio.traceln "[Handler] ❌ Wrong game: expected=%s, got=%s" game.id game_id;
        let client = client ctx in
        let* _result = Telegram_generated.Gen_methods.answer_callback_query client
          ~callback_query_id:callback_query.id
          ~text:"Wrong game"
          ()
        in
        Ok ()
    | Some game when Option.is_some game.o_user_id ->
        Eio.traceln "[Handler] ❌ Game already has O player";
        let client = client ctx in
        let* _result = Telegram_generated.Gen_methods.answer_callback_query client
          ~callback_query_id:callback_query.id
          ~text:"Game already full"
          ()
        in
        Ok ()
    | Some game when Id.to_string game.x_user_id = Id.to_string user.id ->
        Eio.traceln "[Handler] ❌ Creator cannot join as O";
        let client = client ctx in
        let* _result = Telegram_generated.Gen_methods.answer_callback_query client
          ~callback_query_id:callback_query.id
          ~text:"You are already X player"
          ()
        in
        Ok ()
    | Some game ->
        Eio.traceln "[Handler] ✅ Player joining as O: user_id=%a" Id.pp user.id;

        (* Update game with O player *)
        let game' = { game with o_user_id = Some user.id } in
        session_set ctx game_key game';

        (* Answer callback *)
        let client = client ctx in
        let* _result = Telegram_generated.Gen_methods.answer_callback_query client
          ~callback_query_id:callback_query.id
          ~text:"You joined as ⭕!"
          ()
        in

        (* Send game board *)
        let board_msg = BoardRenderer.board_text game' in
        let keyboard = BoardRenderer.render_keyboard game' in
        let keyboard_json = BoardRenderer.serialize_keyboard keyboard in

        let* _board = Telegram_generated.Gen_methods.send_message client
          ~chat_id
          ~text:board_msg
          ~reply_markup:keyboard_json
          ()
        in

        Eio.traceln "[Handler] ✅ Game started";
        Ok ()
  end

let handle_move ctx callback_query =
  Eio.traceln "[Handler] Processing move callback";
  let open Bot.Ctx in

  let data = Option.value ~default:"" callback_query.Telegram_generated.Gen_types.CallbackQuery.data in

  if String.starts_with ~prefix:"ttt:join:" data then
    Ok ()  (* Handled by handle_join *)
  else if not (String.starts_with ~prefix:"ttt:" data) then
    Ok ()
  else begin
    match String.split_on_char ':' data with
    | ["ttt"; game_id; idx_str] ->
        Eio.traceln "[Handler] Move attempt: game_id=%s, idx=%s" game_id idx_str;

        let* user = require_user ctx in
        let client = client ctx in
        let chat_id = chat ctx in

        (match session_get ctx game_key with
         | None ->
             Eio.traceln "[Handler] ❌ No active game";
             let* _result = Telegram_generated.Gen_methods.answer_callback_query client
               ~callback_query_id:callback_query.id
               ~text:"No active game"
               ()
             in
             Ok ()
         | Some game when game.id <> game_id ->
             Eio.traceln "[Handler] ❌ Wrong game";
             let* _result = Telegram_generated.Gen_methods.answer_callback_query client
               ~callback_query_id:callback_query.id
               ~text:"Wrong game"
               ()
             in
             Ok ()
         | Some game when expired game ->
             Eio.traceln "[Handler] ❌ Game expired";
             session_delete ctx game_key;
             let* _result = Telegram_generated.Gen_methods.answer_callback_query client
               ~callback_query_id:callback_query.id
               ~text:"Game expired"
               ~show_alert:true
               ()
             in
             Ok ()
         | Some game ->
             let lock = GameLocks.get game.id in
             Eio.Mutex.use_rw ~protect:true lock (fun () ->
               match GameLogic.handle_move game user.id (int_of_string idx_str) with
               | None ->
                   Eio.traceln "[Handler] ❌ Invalid move";
                   let* _result = Telegram_generated.Gen_methods.answer_callback_query client
                     ~callback_query_id:callback_query.id
                     ~text:"Invalid move"
                     ()
                   in
                   Ok ()
               | Some (game', `Continue) ->
                   Eio.traceln "[Handler] ✅ Move processed, game continues";
                   session_set ctx game_key game';

                   (* Update board *)
                   let* () = match callback_query.message with
                    | Some msg ->
                        let board_msg = BoardRenderer.board_text game' in
                        let keyboard = BoardRenderer.render_keyboard game' in
                        let* _result = Telegram_generated.Gen_methods.edit_message_text client
                          ~chat_id:(Id.to_string chat_id)
                          ~message_id:msg.message_id
                          ~text:board_msg
                          ~reply_markup:keyboard
                          ()
                        in
                        Ok ()
                    | None -> Ok ()
                   in

                   let* _result = Telegram_generated.Gen_methods.answer_callback_query client
                     ~callback_query_id:callback_query.id
                     ()
                   in
                   Ok ()
               | Some (game', `Win winner) ->
                   let (winner_user, loser_user) = match winner with
                     | X -> (game'.x_user_id, Option.get game'.o_user_id)
                     | O -> (Option.get game'.o_user_id, game'.x_user_id)
                     | Empty -> failwith "Empty cell cannot win"
                   in

                   Eio.traceln "[Handler] 🏆 Game won by user: %a" Id.pp winner_user;
                   session_delete ctx game_key;

                   (* Record win *)
                   Scoreboard.record_win ~winner:winner_user ~loser:loser_user;

                   let win_text = Printf.sprintf
                     "🏆 <b>Game Over!</b>\n\n\
                      Winner: User %s (%s)\n\n\
                      Congratulations!"
                     (Id.to_string winner_user)
                     (match winner with X -> "❌ X" | O -> "⭕ O" | Empty -> "")
                   in

                   let* _ = send ctx win_text in

                   let* _result = Telegram_generated.Gen_methods.answer_callback_query client
                     ~callback_query_id:callback_query.id
                     ~text:"You won! 🎉"
                     ()
                   in

                   Eio.traceln "[Handler] ✅ Win recorded";
                   Ok ()
               | Some (game', `Draw) ->
                   Eio.traceln "[Handler] 🤝 Game drawn";
                   session_delete ctx game_key;

                   (* Record draw *)
                   Scoreboard.record_draw ~x:game'.x_user_id ~o:(Option.get game'.o_user_id);

                   let draw_text =
                     "🤝 <b>Game Over!</b>\n\n\
                      It's a draw!\n\n\
                      Well played both players!"
                   in

                   let* _ = send ctx draw_text in

                   let* _result = Telegram_generated.Gen_methods.answer_callback_query client
                     ~callback_query_id:callback_query.id
                     ~text:"It's a draw!"
                     ()
                   in

                   Eio.traceln "[Handler] ✅ Draw recorded";
                   Ok ()
             )
        )
    | _ ->
        Eio.traceln "[Handler] ⚠️  Malformed callback data: %s" data;
        Ok ()
  end

let handle_callback_events ctx update =
  Eio.traceln "[Handler] Checking for callback query";

  match update.Telegram_generated.Gen_types.Update.callback_query with
  | Some cq ->
      Eio.traceln "[Handler] Callback query received: query_id=%s" cq.id;
      let data = Option.value ~default:"" cq.data in

      if String.starts_with ~prefix:"ttt:join:" data then
        handle_join ctx cq
      else if String.starts_with ~prefix:"ttt:" data then
        handle_move ctx cq
      else
        Ok ()
  | None ->
      Ok ()

(** {1 Build Routes} *)

let build_routes bot =
  Eio.traceln "[Builder] Registering routes...";

  let bot = bot |> Bot.command "start" handle_start in
  Eio.traceln "[Builder] ✅ Registered /start";

  let bot = bot |> Bot.command "new" handle_new in
  Eio.traceln "[Builder] ✅ Registered /new";

  let bot = bot |> Bot.command "stats" handle_stats in
  Eio.traceln "[Builder] ✅ Registered /stats";

  let bot = bot |> Bot.command "leaderboard" handle_leaderboard in
  Eio.traceln "[Builder] ✅ Registered /leaderboard";

  let bot = bot |> Bot.command "help" handle_help in
  Eio.traceln "[Builder] ✅ Registered /help";

  (* Register callback handler *)
  let bot = bot |> Bot.on Bot.Event.any handle_callback_events in
  Eio.traceln "[Builder] ✅ Registered callback event handler";

  Eio.traceln "[Builder] All routes registered";
  bot

(** {1 Main Entry Point} *)

let () =
  Eio_main.run @@ fun env ->
  Eio.traceln "";
  Eio.traceln "╔══════════════════════════════════════════════════════════════════╗";
  Eio.traceln "║                     Tic-Tac-Toe Bot                              ║";
  Eio.traceln "╚══════════════════════════════════════════════════════════════════╝";
  Eio.traceln "";

  (* Phase 1: Initialize *)
  Eio.traceln "╔══════════════════════════════════════════════════════════════════╗";
  Eio.traceln "║                     Phase 1: Initialize                          ║";
  Eio.traceln "╚══════════════════════════════════════════════════════════════════╝";

  let token =
    match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t ->
        Eio.traceln "[Init] ✅ Token loaded from environment";
        t
    | None ->
        Eio.traceln "[Init] ❌ TELEGRAM_BOT_TOKEN not set";
        failwith "TELEGRAM_BOT_TOKEN environment variable not set"
  in

  let telegram_client = Telegram.Client.create ~env ~token () in
  Eio.traceln "[Init] Client created successfully";

  (* Phase 2: Build bot *)
  Eio.traceln "";
  Eio.traceln "╔══════════════════════════════════════════════════════════════════╗";
  Eio.traceln "║                     Phase 2: Build Bot                           ║";
  Eio.traceln "╚══════════════════════════════════════════════════════════════════╝";

  let bot = Bot.make ~env ~client:telegram_client in
  let bot = build_routes bot in

  Eio.traceln "[Init] Bot created successfully";

  (* Phase 3: Start polling *)
  Eio.traceln "";
  Eio.traceln "╔══════════════════════════════════════════════════════════════════╗";
  Eio.traceln "║                     Phase 3: Start Polling                       ║";
  Eio.traceln "╚══════════════════════════════════════════════════════════════════╝";

  Eio.traceln "[Polling] Starting long polling...";
  Eio.traceln "[Polling] Bot is ready to receive updates";
  Eio.traceln "";
  Eio.traceln "╔══════════════════════════════════════════════════════════════════╗";
  Eio.traceln "║                     Bot is Ready!                                ║";
  Eio.traceln "╚══════════════════════════════════════════════════════════════════╝";
  Eio.traceln "[Polling] Waiting for messages...";
  Eio.traceln "";
  Eio.traceln "Features:";
  Eio.traceln "  - Turn-based Tic-Tac-Toe gameplay";
  Eio.traceln "  - Inline keyboard UI (3x3 grid)";
  Eio.traceln "  - Player management (join, turns, validation)";
  Eio.traceln "  - Win/draw/loss detection";
  Eio.traceln "  - Scoreboard and leaderboard";
  Eio.traceln "  - Game expiration (30 min TTL)";
  Eio.traceln "  - Per-game locking for thread safety";
  Eio.traceln "  - Session-based game state";
  Eio.traceln "  - Result-based error handling";
  Eio.traceln "";

  Bot.run bot
