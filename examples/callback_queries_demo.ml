(** Callback Queries Demo - Comprehensive demonstration of callback query handling

    This example demonstrates all callback query features:
    - Basic callback handling with on_callback_data
    - Callback data encoding (simple, structured, typed)
    - State management with sessions
    - Common patterns (confirmation, pagination, toggles)
    - Message editing in response to callbacks
    - Answer callback query with different options

    Commands:
      /start - Show main menu
      /simple - Simple callback buttons
      /structured - Structured callback data (action:type:id)
      /typed - Type-safe callback encoding
      /confirm - Confirmation pattern
      /paginate - Pagination pattern
      /toggle - Toggle button pattern
      /answer_demo - Demonstrate answer_callback_query options

    This example has VERBOSE LOGGING enabled for troubleshooting.

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/callback_queries_demo.exe
*)

open Telegram
open Tg

(* Configure verbose logging via functor composition *)
module Verbose_log = Log.Make (Log.Console) (struct
  let src = "CallbackDemo"
  let level = Log.Debug
end)

module Verbose_session = Session.Make (Verbose_log)
module Verbose_polling = Polling.Make (Verbose_log)
module Verbose_bot = Bot.Make (Verbose_log) (Verbose_session) (Verbose_polling)

module KB = Keyboard

(** Type-safe callback action encoding *)
module CallbackAction = struct
  type t =
    | Like of int
    | Unlike of int
    | Delete of int
    | Edit of int
    | ViewItem of { item_id: int; page: int }

  let encode = function
    | Like id -> Printf.sprintf "like:%d" id
    | Unlike id -> Printf.sprintf "unlike:%d" id
    | Delete id -> Printf.sprintf "delete:%d" id
    | Edit id -> Printf.sprintf "edit:%d" id
    | ViewItem { item_id; page } -> Printf.sprintf "view:%d:%d" item_id page

  let decode data =
    match String.split_on_char ':' data with
    | ["like"; id] -> (try Some (Like (int_of_string id)) with _ -> None)
    | ["unlike"; id] -> (try Some (Unlike (int_of_string id)) with _ -> None)
    | ["delete"; id] -> (try Some (Delete (int_of_string id)) with _ -> None)
    | ["edit"; id] -> (try Some (Edit (int_of_string id)) with _ -> None)
    | ["view"; item_id; page] ->
        (try Some (ViewItem { item_id = int_of_string item_id; page = int_of_string page })
         with _ -> None)
    | _ -> None
end

(** Session keys for state management *)
let page_key = Verbose_session.make ~name:"current_page"
let likes_key = Verbose_session.make ~name:"liked_items"

let () =
  Printexc.record_backtrace true;
  Eio.traceln "=== Callback Queries Demo Starting ===";

  let token = match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None -> Printf.eprintf "TELEGRAM_BOT_TOKEN not set\n"; exit 1
  in

  Eio_main.run @@ fun env ->
  let client = Client.create ~env ~token () in

  Eio.traceln "🤖 Callback Queries Demo Bot Started";

  let session_store = Verbose_session.Memory_store.create () in

  Verbose_bot.make ~env ~client
  |> Verbose_bot.with_sessions (module Verbose_session.Memory_store) session_store

  (* /start - Main menu *)
  |> Verbose_bot.command "start" ~desc:"Show main menu" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/start] Showing main menu";

      let keyboard = KB.inline [
        [KB.callback ~text:"📝 Simple Callbacks" ~data:"demo:simple"];
        [KB.callback ~text:"🔗 Structured Data" ~data:"demo:structured"];
        [KB.callback ~text:"🎯 Type-Safe Actions" ~data:"demo:typed"];
        [KB.callback ~text:"✅ Confirmation Pattern" ~data:"demo:confirm"];
        [KB.callback ~text:"📄 Pagination" ~data:"demo:paginate"];
        [KB.callback ~text:"🔘 Toggle Buttons" ~data:"demo:toggle"];
      ] in

      match send ~keyboard ctx "🎮 Callback Queries Demo\n\nChoose a demonstration:" with
      | Ok _ -> Eio.traceln "[/start] ✓"; Ok ()
      | Error e -> Eio.traceln "[/start] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: demo:simple *)
  |> Verbose_bot.on_callback_data "demo:simple" (fun ctx ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[demo:simple] Showing simple callbacks";

      let keyboard = KB.inline [
        [KB.callback ~text:"Button A" ~data:"simple:a"];
        [KB.callback ~text:"Button B" ~data:"simple:b"];
        [KB.callback ~text:"Button C" ~data:"simple:c"];
        [KB.callback ~text:"← Back" ~data:"demo:menu"];
      ] in

      match edit ~keyboard ctx
        "📝 Simple Callbacks\n\n\
         These buttons use simple string data.\n\
         Press any button to see the result."
      with
      | Ok () -> Eio.traceln "[demo:simple] ✓"; Ok ()
      | Error e -> Eio.traceln "[demo:simple] ✗ %a" Error.pp e; Ok ()
    )

  (* Handle simple button presses *)
  |> Verbose_bot.on_callback_data "simple:a" (fun ctx ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[simple:a] Button A pressed";
      match edit ctx "✅ You pressed Button A!" with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[simple:a] ✗ %a" Error.pp e; Ok ()
    )

  |> Verbose_bot.on_callback_data "simple:b" (fun ctx ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[simple:b] Button B pressed";
      match edit ctx "✅ You pressed Button B!" with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[simple:b] ✗ %a" Error.pp e; Ok ()
    )

  |> Verbose_bot.on_callback_data "simple:c" (fun ctx ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[simple:c] Button C pressed";
      match edit ctx "✅ You pressed Button C!" with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[simple:c] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: demo:structured *)
  |> Verbose_bot.on_callback_data "demo:structured" (fun ctx ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[demo:structured] Showing structured data";

      let keyboard = KB.inline [
        [KB.callback ~text:"Edit Post #42" ~data:"edit:post:42"];
        [KB.callback ~text:"Delete Post #42" ~data:"delete:post:42"];
        [KB.callback ~text:"View Comment #7" ~data:"view:comment:7"];
        [KB.callback ~text:"← Back" ~data:"demo:menu"];
      ] in

      match edit ~keyboard ctx
        "🔗 Structured Callback Data\n\n\
         Format: action:type:id\n\
         The data contains multiple values separated by colons."
      with
      | Ok () -> Eio.traceln "[demo:structured] ✓"; Ok ()
      | Error e -> Eio.traceln "[demo:structured] ✗ %a" Error.pp e; Ok ()
    )

  (* Handle structured callbacks with parsing *)
  |> Verbose_bot.on_callback (fun ctx data ->
      let open Verbose_bot.Ctx in

      match String.split_on_char ':' data with
      | ["edit"; typ; id] ->
          Eio.traceln "[structured] Edit %s #%s" typ id;
          (match edit ctx (Printf.sprintf "✏️ Editing %s #%s" typ id) with
           | Ok () -> Ok ()
           | Error e -> Eio.traceln "[structured] ✗ %a" Error.pp e; Ok ())

      | ["delete"; typ; id] ->
          Eio.traceln "[structured] Delete %s #%s" typ id;
          (match edit ctx (Printf.sprintf "🗑️ Deleted %s #%s" typ id) with
           | Ok () -> Ok ()
           | Error e -> Eio.traceln "[structured] ✗ %a" Error.pp e; Ok ())

      | ["view"; typ; id] ->
          Eio.traceln "[structured] View %s #%s" typ id;
          (match edit ctx (Printf.sprintf "👁️ Viewing %s #%s" typ id) with
           | Ok () -> Ok ()
           | Error e -> Eio.traceln "[structured] ✗ %a" Error.pp e; Ok ())

      | _ ->
          (* Not a structured callback *)
          Ok ()
    )

  (* Callback: demo:typed *)
  |> Verbose_bot.on_callback_data "demo:typed" (fun ctx ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[demo:typed] Showing type-safe callbacks";

      let keyboard = KB.inline [
        [KB.callback ~text:"👍 Like Item #5" ~data:(CallbackAction.encode (CallbackAction.Like 5))];
        [KB.callback ~text:"✏️ Edit Item #10" ~data:(CallbackAction.encode (CallbackAction.Edit 10))];
        [KB.callback ~text:"🗑️ Delete Item #3" ~data:(CallbackAction.encode (CallbackAction.Delete 3))];
        [KB.callback ~text:"← Back" ~data:"demo:menu"];
      ] in

      match edit ~keyboard ctx
        "🎯 Type-Safe Callback Actions\n\n\
         These callbacks use a typed ADT for encoding/decoding.\n\
         Compile-time safety for callback data structure."
      with
      | Ok () -> Eio.traceln "[demo:typed] ✓"; Ok ()
      | Error e -> Eio.traceln "[demo:typed] ✗ %a" Error.pp e; Ok ()
    )

  (* Handle typed callbacks *)
  |> Verbose_bot.on_callback (fun ctx data ->
      let open Verbose_bot.Ctx in

      match CallbackAction.decode data with
      | Some (CallbackAction.Like id) ->
          Eio.traceln "[typed] Like item %d" id;

          (* Get current likes from session *)
          let likes = session_get_or ctx likes_key ~default:[] in
          let updated_likes = id :: likes in
          session_set ctx likes_key updated_likes;

          (match edit ctx (Printf.sprintf "👍 You liked item #%d!\n\nTotal items liked: %d" id (List.length updated_likes)) with
           | Ok () -> Ok ()
           | Error e -> Eio.traceln "[typed] ✗ %a" Error.pp e; Ok ())

      | Some (CallbackAction.Unlike id) ->
          Eio.traceln "[typed] Unlike item %d" id;

          let likes = session_get_or ctx likes_key ~default:[] in
          let updated_likes = List.filter ((<>) id) likes in
          session_set ctx likes_key updated_likes;

          (match edit ctx (Printf.sprintf "💔 You unliked item #%d\n\nTotal items liked: %d" id (List.length updated_likes)) with
           | Ok () -> Ok ()
           | Error e -> Eio.traceln "[typed] ✗ %a" Error.pp e; Ok ())

      | Some (CallbackAction.Edit id) ->
          Eio.traceln "[typed] Edit item %d" id;
          (match edit ctx (Printf.sprintf "✏️ Editing item #%d\n\n(Edit interface would appear here)" id) with
           | Ok () -> Ok ()
           | Error e -> Eio.traceln "[typed] ✗ %a" Error.pp e; Ok ())

      | Some (CallbackAction.Delete id) ->
          Eio.traceln "[typed] Delete item %d" id;
          (match edit ctx (Printf.sprintf "🗑️ Item #%d deleted" id) with
           | Ok () -> Ok ()
           | Error e -> Eio.traceln "[typed] ✗ %a" Error.pp e; Ok ())

      | Some (CallbackAction.ViewItem { item_id; page }) ->
          Eio.traceln "[typed] View item %d from page %d" item_id page;

          let keyboard = KB.inline [
            [KB.callback ~text:"← Back to Page" ~data:(Printf.sprintf "page:%d" page)];
          ] in

          (match edit ~keyboard ctx (Printf.sprintf "👁️ Viewing Item #%d\n\n(From page %d)" item_id page) with
           | Ok () -> Ok ()
           | Error e -> Eio.traceln "[typed] ✗ %a" Error.pp e; Ok ())

      | None ->
          (* Not a typed callback *)
          Ok ()
    )

  (* Callback: demo:confirm *)
  |> Verbose_bot.on_callback_data "demo:confirm" (fun ctx ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[demo:confirm] Showing confirmation pattern";

      let keyboard = KB.inline [
        [KB.callback ~text:"🗑️ Delete Item" ~data:"confirm:delete:123"];
        [KB.callback ~text:"← Back" ~data:"demo:menu"];
      ] in

      match edit ~keyboard ctx
        "✅ Confirmation Pattern\n\n\
         This demonstrates the confirmation pattern for destructive actions."
      with
      | Ok () -> Eio.traceln "[demo:confirm] ✓"; Ok ()
      | Error e -> Eio.traceln "[demo:confirm] ✗ %a" Error.pp e; Ok ()
    )

  (* Handle initial delete request - show confirmation *)
  |> Verbose_bot.on_callback (fun ctx data ->
      let open Verbose_bot.Ctx in

      match String.split_on_char ':' data with
      | ["confirm"; "delete"; id] ->
          Eio.traceln "[confirm] Requesting confirmation for delete:%s" id;

          let keyboard = KB.inline [
            [
              KB.callback ~text:"🗑️ Yes, Delete" ~data:(Printf.sprintf "delete_confirmed:%s" id);
              KB.callback ~text:"✗ Cancel" ~data:"delete_cancelled";
            ];
          ] in

          (match edit ~keyboard ctx (Printf.sprintf "⚠️ Delete item #%s?\n\nThis action cannot be undone!" id) with
           | Ok () -> Ok ()
           | Error e -> Eio.traceln "[confirm] ✗ %a" Error.pp e; Ok ())

      | _ -> Ok ()
    )

  (* Handle delete confirmation *)
  |> Verbose_bot.on_callback (fun ctx data ->
      let open Verbose_bot.Ctx in

      if String.starts_with ~prefix:"delete_confirmed:" data then (
        let id = String.sub data 17 (String.length data - 17) in
        Eio.traceln "[delete_confirmed] Deleting item %s" id;

        (match edit ctx (Printf.sprintf "✅ Item #%s deleted successfully!" id) with
         | Ok () -> Ok ()
         | Error e -> Eio.traceln "[delete_confirmed] ✗ %a" Error.pp e; Ok ())
      ) else Ok ()
    )

  |> Verbose_bot.on_callback_data "delete_cancelled" (fun ctx ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[delete_cancelled] Deletion cancelled";

      match edit ctx "❌ Deletion cancelled" with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[delete_cancelled] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: demo:paginate *)
  |> Verbose_bot.on_callback_data "demo:paginate" (fun ctx ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[demo:paginate] Showing pagination pattern";

      (* Reset to page 1 *)
      session_set ctx page_key 1;

      let keyboard = KB.Patterns.pagination
        ~prev_data:"page:0"
        ~next_data:"page:2"
        ~current_page:1
        ~total_pages:5
        ()
      in

      match edit ~keyboard ctx
        "📄 Pagination Pattern\n\n\
         Current page: 1 of 5\n\n\
         Smart pagination hides disabled buttons (no prev on page 1)."
      with
      | Ok () -> Eio.traceln "[demo:paginate] ✓"; Ok ()
      | Error e -> Eio.traceln "[demo:paginate] ✗ %a" Error.pp e; Ok ()
    )

  (* Handle page navigation *)
  |> Verbose_bot.on_callback (fun ctx data ->
      let open Verbose_bot.Ctx in

      if String.starts_with ~prefix:"page:" data then (
        let page_str = String.sub data 5 (String.length data - 5) in
        let page = int_of_string page_str in
        Eio.traceln "[page] Navigating to page %d" page;

        (* Save current page in session *)
        session_set ctx page_key page;

        let total_pages = 5 in
        let keyboard = KB.Patterns.pagination
          ~prev_data:(Printf.sprintf "page:%d" (page - 1))
          ~next_data:(Printf.sprintf "page:%d" (page + 1))
          ~current_page:page
          ~total_pages
          ()
        in

        (match edit ~keyboard ctx (Printf.sprintf "📄 Current page: %d of %d" page total_pages) with
         | Ok () -> Ok ()
         | Error e -> Eio.traceln "[page] ✗ %a" Error.pp e; Ok ())
      ) else Ok ()
    )

  (* Callback: demo:toggle *)
  |> Verbose_bot.on_callback_data "demo:toggle" (fun ctx ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[demo:toggle] Showing toggle pattern";

      (* Initialize toggle state *)
      let notifications_key = Verbose_session.make ~name:"notifications_enabled" in
      let enabled = session_get_or ctx notifications_key ~default:true in

      let button_text = if enabled then "🔔 Notifications: ON" else "🔕 Notifications: OFF" in

      let keyboard = KB.inline [
        [KB.callback ~text:button_text ~data:"toggle:notifications"];
        [KB.callback ~text:"← Back" ~data:"demo:menu"];
      ] in

      match edit ~keyboard ctx
        "🔘 Toggle Button Pattern\n\n\
         Press the button to toggle the state.\n\
         State is stored in session."
      with
      | Ok () -> Eio.traceln "[demo:toggle] ✓"; Ok ()
      | Error e -> Eio.traceln "[demo:toggle] ✗ %a" Error.pp e; Ok ()
    )

  (* Handle toggle *)
  |> Verbose_bot.on_callback_data "toggle:notifications" (fun ctx ->
      let open Verbose_bot.Ctx in
      let notifications_key = Verbose_session.make ~name:"notifications_enabled" in

      let enabled = session_get_or ctx notifications_key ~default:true in
      let new_state = not enabled in
      session_set ctx notifications_key new_state;

      Eio.traceln "[toggle] Notifications: %b → %b" enabled new_state;

      let button_text = if new_state then "🔔 Notifications: ON" else "🔕 Notifications: OFF" in

      let keyboard = KB.inline [
        [KB.callback ~text:button_text ~data:"toggle:notifications"];
        [KB.callback ~text:"← Back" ~data:"demo:menu"];
      ] in

      match edit ~keyboard ctx
        (Printf.sprintf
          "🔘 Toggle Button Pattern\n\n\
           Notifications are now: %s"
          (if new_state then "ON ✅" else "OFF ❌"))
      with
      | Ok () -> Eio.traceln "[toggle] ✓"; Ok ()
      | Error e -> Eio.traceln "[toggle] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: demo:menu - Back to main menu *)
  |> Verbose_bot.on_callback_data "demo:menu" (fun ctx ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[demo:menu] Returning to main menu";

      let keyboard = KB.inline [
        [KB.callback ~text:"📝 Simple Callbacks" ~data:"demo:simple"];
        [KB.callback ~text:"🔗 Structured Data" ~data:"demo:structured"];
        [KB.callback ~text:"🎯 Type-Safe Actions" ~data:"demo:typed"];
        [KB.callback ~text:"✅ Confirmation Pattern" ~data:"demo:confirm"];
        [KB.callback ~text:"📄 Pagination" ~data:"demo:paginate"];
        [KB.callback ~text:"🔘 Toggle Buttons" ~data:"demo:toggle"];
      ] in

      match edit ~keyboard ctx "🎮 Callback Queries Demo\n\nChoose a demonstration:" with
      | Ok () -> Eio.traceln "[demo:menu] ✓"; Ok ()
      | Error e -> Eio.traceln "[demo:menu] ✗ %a" Error.pp e; Ok ()
    )

  |> Verbose_bot.run
