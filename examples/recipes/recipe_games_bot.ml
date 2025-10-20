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
    Flo.debugf "[Game] Game expired: id=%s, age=%.1fs, ttl=%ds" g.id age g.ttl_seconds;
  expired

let new_board () = Array.make 9 Empty

let new_game ~id ~chat_id ~x_user_id ~o_user_id =
  Flo.debugf "[Game] Creating new game: id=%s, x_user=%s, o_user=%s"
    id (Format.asprintf "%a" Id.pp x_user_id) (match o_user_id with Some u -> Id.to_string u | None -> "waiting");
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
        Flo.debugf "[GameLocks] Using existing lock for game: id=%s" id;
        m
    | None ->
        Flo.debugf "[GameLocks] Creating new lock for game: id=%s" id;
        let m = Eio.Mutex.create () in
        Hashtbl.replace table id m;
        m

  let _cleanup () =
    let count = Hashtbl.length table in
    if count > 0 then
      Flo.debugf "[GameLocks] Active locks: %d" count
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
          Flo.debugf "[GameLogic] Winner found: %s on line %d"
            (match w with X -> "X" | O -> "O" | Empty -> "Empty") i;
          result := Some w
      | None -> ()
    done;
    !result

  let board_full b =
    let full = Array.for_all (function Empty -> false | _ -> true) b in
    if full then
      Flo.debug "[GameLogic] Board is full";
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
    Flo.debugf "[GameLogic] Processing move: game=%s, user=%s, idx=%d" g.id (Format.asprintf "%a" Id.pp user_id) idx;

    if idx < 0 || idx > 8 then begin
      Flo.errorf "[GameLogic] ❌ Invalid index: %d" idx;
      None
    end else if Option.is_none g.o_user_id then begin
      Flo.error "[GameLogic] ❌ Game not started, waiting for O player";
      None
    end else begin
      let expected_user = match g.turn with Xp -> g.x_user_id | Op -> Option.get g.o_user_id in
      if Id.to_string user_id <> Id.to_string expected_user then begin
        Flo.errorf "[GameLogic] ❌ Wrong player: expected=%s, got=%s" (Format.asprintf "%a" Id.pp expected_user) (Format.asprintf "%a" Id.pp user_id);
        None
      end else begin
        match g.board.(idx) with
        | X | O ->
            Flo.errorf "[GameLogic] ❌ Cell already occupied: idx=%d, cell=%s"
              idx (cell_name g.board.(idx));
            None
        | Empty ->
            let mark = mark_of_player g.turn in
            g.board.(idx) <- mark;
            Flo.successf "[GameLogic] ✅ Move made: player=%s, idx=%d, mark=%s"
              (player_name g.turn) idx (cell_name mark);

            match winner g.board with
            | Some w ->
                Flo.debugf "[GameLogic] 🏆 Game won by: %s" (cell_name w);
                Some (g, `Win w)
            | None ->
                if board_full g.board then begin
                  Flo.debug "[GameLogic] 🤝 Game drawn";
                  Some (g, `Draw)
                end else begin
                  let next_turn = match g.turn with Xp -> Op | Op -> Xp in
                  Flo.debugf "[GameLogic] ➡️  Turn switches to: %s" (player_name next_turn);
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
        Flo.debugf "[Scoreboard] Found entry for user %s: W:%d D:%d L:%d"
          key e.wins e.draws e.losses;
        e
    | None ->
        Flo.debugf "[Scoreboard] New user %s" key;
        { wins = 0; draws = 0; losses = 0 }

  let set user_id e =
    let key = Id.to_string user_id in
    Hashtbl.replace table key e;
    Flo.debugf "[Scoreboard] Updated user %s: W:%d D:%d L:%d"
      key e.wins e.draws e.losses

  let record_win ~winner ~loser =
    Flo.debugf "[Scoreboard] Recording win: winner=%s, loser=%s" (Format.asprintf "%a" Id.pp winner) (Format.asprintf "%a" Id.pp loser);
    let w = get winner in
    let l = get loser in
    set winner { w with wins = w.wins + 1 };
    set loser { l with losses = l.losses + 1 }

  let record_draw ~x ~o =
    Flo.debugf "[Scoreboard] Recording draw: x=%s, o=%s" (Format.asprintf "%a" Id.pp x) (Format.asprintf "%a" Id.pp o);
    let a = get x in
    let b = get o in
    set x { a with draws = a.draws + 1 };
    set o { b with draws = b.draws + 1 }

  let top_n n =
    Flo.debugf "[Scoreboard] Getting top %d players" n;
    let players = Hashtbl.to_seq table |> List.of_seq in
    let sorted = List.sort (fun (_, a) (_, b) -> compare b.wins a.wins) players in
    let top = List.filteri (fun i _ -> i < n) sorted in
    Flo.debugf "[Scoreboard] Found %d players in top list" (List.length top);
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
    Flo.debugf "[BoardRenderer] Rendering keyboard for game: id=%s" g.id;

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
    Flo.debugf "[BoardRenderer] Serialized keyboard: %d bytes" (String.length json);
    json
end

(** {1 Command Handlers} *)

let handle_start ctx _args =
  Flo.debug "[Handler] /start command triggered";
  let open Bot.Ctx in

  let* user = require_user ctx in
  Flo.debugf "[Handler] User: id=%s, username=%s"
    (Format.asprintf "%a" Id.pp user.id)
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
  Flo.success "[Handler] ✅ Welcome message sent";
  Ok ()

let handle_new ctx _args =
  Flo.debug "[Handler] /new command triggered";
  let open Bot.Ctx in

  let* user = require_user ctx in
  let chat_id = chat ctx in

  (* Generate game ID *)
  let game_id = Printf.sprintf "ttt_%d_%f" (Random.int 1000000) (Unix.time ()) in

  Flo.debugf "[Handler] Creating new game: game_id=%s, creator=%s" game_id (Format.asprintf "%a" Id.pp user.id);

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
  Flo.success "[Handler] ✅ New game created, waiting for O player";
  Ok ()

let handle_stats ctx _args =
  Flo.debug "[Handler] /stats command triggered";
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
  Flo.success "[Handler] ✅ Stats sent";
  Ok ()

let handle_leaderboard ctx _args =
  Flo.debug "[Handler] /leaderboard command triggered";
  let open Bot.Ctx in

  let top_players = Scoreboard.top_n 10 in
  let leaderboard_text = Scoreboard.format_leaderboard top_players in

  let* _msg = answer ctx leaderboard_text in
  Flo.successf "[Handler] ✅ Leaderboard sent: %d players" (List.length top_players);
  Ok ()

let handle_help ctx _args =
  Flo.debug "[Handler] /help command triggered";
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
  Flo.success "[Handler] ✅ Help sent";
  Ok ()

(** {1 Callback Handlers} *)

let handle_join ctx callback_query =
  Flo.debug "[Handler] Processing join callback";
  let open Bot.Ctx in

  let data = Option.value ~default:"" callback_query.Telegram_generated.Gen_types.CallbackQuery.data in

  if not (String.starts_with ~prefix:"ttt:join:" data) then
    Ok ()
  else begin
    let game_id = String.sub data 9 (String.length data - 9) in
    Flo.debugf "[Handler] Join request for game: game_id=%s" game_id;

    let* user = require_user ctx in
    let chat_id = chat ctx in

    match session_get ctx game_key with
    | None ->
        Flo.error "[Handler] ❌ No game found in session";
        let client = client ctx in
        let* _result = Telegram_generated.Gen_methods.answer_callback_query client
          ~callback_query_id:callback_query.id
          ~text:"Game not found"
          ~show_alert:true
          ()
        in
        Ok ()
    | Some game when game.id <> game_id ->
        Flo.errorf "[Handler] ❌ Wrong game: expected=%s, got=%s" game.id game_id;
        let client = client ctx in
        let* _result = Telegram_generated.Gen_methods.answer_callback_query client
          ~callback_query_id:callback_query.id
          ~text:"Wrong game"
          ()
        in
        Ok ()
    | Some game when Option.is_some game.o_user_id ->
        Flo.error "[Handler] ❌ Game already has O player";
        let client = client ctx in
        let* _result = Telegram_generated.Gen_methods.answer_callback_query client
          ~callback_query_id:callback_query.id
          ~text:"Game already full"
          ()
        in
        Ok ()
    | Some game when Id.to_string game.x_user_id = Id.to_string user.id ->
        Flo.error "[Handler] ❌ Creator cannot join as O";
        let client = client ctx in
        let* _result = Telegram_generated.Gen_methods.answer_callback_query client
          ~callback_query_id:callback_query.id
          ~text:"You are already X player"
          ()
        in
        Ok ()
    | Some game ->
        Flo.successf "[Handler] ✅ Player joining as O: user_id=%s" (Format.asprintf "%a" Id.pp user.id);

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

        Flo.success "[Handler] ✅ Game started";
        Ok ()
  end

let handle_move ctx callback_query =
  Flo.debug "[Handler] Processing move callback";
  let open Bot.Ctx in

  let data = Option.value ~default:"" callback_query.Telegram_generated.Gen_types.CallbackQuery.data in

  if String.starts_with ~prefix:"ttt:join:" data then
    Ok ()  (* Handled by handle_join *)
  else if not (String.starts_with ~prefix:"ttt:" data) then
    Ok ()
  else begin
    match String.split_on_char ':' data with
    | ["ttt"; game_id; idx_str] ->
        Flo.debugf "[Handler] Move attempt: game_id=%s, idx=%s" game_id idx_str;

        let* user = require_user ctx in
        let client = client ctx in
        let chat_id = chat ctx in

        (match session_get ctx game_key with
         | None ->
             Flo.error "[Handler] ❌ No active game";
             let* _result = Telegram_generated.Gen_methods.answer_callback_query client
               ~callback_query_id:callback_query.id
               ~text:"No active game"
               ()
             in
             Ok ()
         | Some game when game.id <> game_id ->
             Flo.error "[Handler] ❌ Wrong game";
             let* _result = Telegram_generated.Gen_methods.answer_callback_query client
               ~callback_query_id:callback_query.id
               ~text:"Wrong game"
               ()
             in
             Ok ()
         | Some game when expired game ->
             Flo.error "[Handler] ❌ Game expired";
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
                   Flo.error "[Handler] ❌ Invalid move";
                   let* _result = Telegram_generated.Gen_methods.answer_callback_query client
                     ~callback_query_id:callback_query.id
                     ~text:"Invalid move"
                     ()
                   in
                   Ok ()
               | Some (game', `Continue) ->
                   Flo.success "[Handler] ✅ Move processed, game continues";
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

                   Flo.debugf "[Handler] 🏆 Game won by user: %s" (Format.asprintf "%a" Id.pp winner_user);
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

                   Flo.success "[Handler] ✅ Win recorded";
                   Ok ()
               | Some (game', `Draw) ->
                   Flo.debug "[Handler] 🤝 Game drawn";
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

                   Flo.success "[Handler] ✅ Draw recorded";
                   Ok ()
             )
        )
    | _ ->
        Flo.debugf "[Handler] ⚠️  Malformed callback data: %s" data;
        Ok ()
  end

let handle_callback_events ctx update =
  Flo.debug "[Handler] Checking for callback query";

  match update.Telegram_generated.Gen_types.Update.callback_query with
  | Some cq ->
      Flo.debugf "[Handler] Callback query received: query_id=%s" cq.id;
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
  Flo.debug "[Builder] Registering routes...";

  let bot = bot |> Bot.command "start" handle_start in
  Flo.success "[Builder] ✅ Registered /start";

  let bot = bot |> Bot.command "new" handle_new in
  Flo.success "[Builder] ✅ Registered /new";

  let bot = bot |> Bot.command "stats" handle_stats in
  Flo.success "[Builder] ✅ Registered /stats";

  let bot = bot |> Bot.command "leaderboard" handle_leaderboard in
  Flo.success "[Builder] ✅ Registered /leaderboard";

  let bot = bot |> Bot.command "help" handle_help in
  Flo.success "[Builder] ✅ Registered /help";

  (* Register callback handler *)
  let bot = bot |> Bot.on Bot.Event.any handle_callback_events in
  Flo.success "[Builder] ✅ Registered callback event handler";

  Flo.debug "[Builder] All routes registered";
  bot

(** {1 Main Entry Point} *)

let () =
  Eio_main.run @@ fun env ->
  Flo.debug "";
  Flo.info "╔══════════════════════════════════════════════════════════════════╗";
  Flo.info "║                     Tic-Tac-Toe Bot                              ║";
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

  Flo.info "[Polling] Starting long polling...";
  Flo.info "[Polling] Bot is ready to receive updates";
  Flo.debug "";
  Flo.info "╔══════════════════════════════════════════════════════════════════╗";
  Flo.info "║                     Bot is Ready!                                ║";
  Flo.info "╚══════════════════════════════════════════════════════════════════╝";
  Flo.info "[Polling] Waiting for messages...";
  Flo.debug "";
  Flo.info "Features:";
  Flo.debug "  - Turn-based Tic-Tac-Toe gameplay";
  Flo.debug "  - Inline keyboard UI (3x3 grid)";
  Flo.debug "  - Player management (join, turns, validation)";
  Flo.debug "  - Win/draw/loss detection";
  Flo.debug "  - Scoreboard and leaderboard";
  Flo.debug "  - Game expiration (30 min TTL)";
  Flo.debug "  - Per-game locking for thread safety";
  Flo.debug "  - Session-based game state";
  Flo.debug "  - Result-based error handling";
  Flo.debug "";

  Bot.run bot
