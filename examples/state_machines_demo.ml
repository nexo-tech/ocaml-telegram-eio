(** State Machines Demo - Comprehensive demonstration of state machine patterns

    This example demonstrates state machine patterns for conversational bots:
    - Simple enum-based state machines
    - States with embedded data
    - State transitions with validation
    - Branching conversation flows
    - State visualization and debugging
    - Session-based state persistence

    Demonstrations:
      1. Registration Flow - Simple linear state machine
      2. Order Flow - State with embedded cart data
      3. Support Ticket - Branching flow with categories

    Commands:
      /start - Show main menu
      /register - Start registration flow
      /order - Start ordering flow
      /support - Start support ticket flow
      /state_info - Show current state
      /reset - Reset all state machines

    This example has VERBOSE LOGGING enabled for troubleshooting.

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/state_machines_demo.exe
*)

open Telegram
open Tg

(* Configure verbose logging via functor composition *)
module Verbose_log = Log.Make (Log.Console) (struct
  let src = "StateMachineDemo"
  let level = Log.Debug
end)

module Verbose_session = Session.Make (Verbose_log)
module Verbose_polling = Polling.Make (Verbose_log)
module Verbose_bot = Bot.Make (Verbose_log) (Verbose_session) (Verbose_polling)

module KB = Keyboard

(** Registration state machine - Simple enum-based states *)
module Registration = struct
  type state =
    | Idle
    | AwaitingName
    | AwaitingAge
    | AwaitingConfirmation
    | Complete

  let state_key = Verbose_session.make ~name:"registration_state"
  let name_key = Verbose_session.make ~name:"reg_name"
  let age_key = Verbose_session.make ~name:"reg_age"

  let state_to_string = function
    | Idle -> "Idle"
    | AwaitingName -> "AwaitingName"
    | AwaitingAge -> "AwaitingAge"
    | AwaitingConfirmation -> "AwaitingConfirmation"
    | Complete -> "Complete"

  let start ctx =
    let open Verbose_bot.Ctx in
    Eio.traceln "[Registration] Starting: Idle → AwaitingName";
    session_set ctx state_key AwaitingName;

    let keyboard = KB.inline [
      [KB.callback ~text:"❌ Cancel" ~data:"reg:cancel"];
    ] in

    send ~keyboard ctx
      "📝 Registration Flow\n\n\
       Step 1/2: What's your name?"

  let handle_text ctx text =
    let open Verbose_bot.Ctx in
    let state = session_get_or ctx state_key ~default:Idle in

    Eio.traceln "[Registration] Current state: %s, Input: %s" (state_to_string state) text;

    match state with
    | Idle ->
        Ok ()  (* Not in registration *)

    | AwaitingName ->
        Eio.traceln "[Registration] Transition: AwaitingName → AwaitingAge";
        session_set ctx name_key text;
        session_set ctx state_key AwaitingAge;

        (match reply ctx "Step 2/2: How old are you?" with
         | Ok _ -> Ok ()
         | Error e -> Eio.traceln "[Registration] ✗ %a" Error.pp e; Ok ())

    | AwaitingAge ->
        (match int_of_string_opt text with
         | Some age ->
             Eio.traceln "[Registration] Transition: AwaitingAge → AwaitingConfirmation";
             session_set ctx age_key age;
             session_set ctx state_key AwaitingConfirmation;

             let name = session_get_or ctx name_key ~default:"" in

             let keyboard = KB.inline [
               [KB.callback ~text:"✅ Confirm" ~data:"reg:confirm"];
               [KB.callback ~text:"❌ Cancel" ~data:"reg:cancel"];
             ] in

             (match send ~keyboard ctx (Printf.sprintf
               "Please confirm:\n\
                Name: %s\n\
                Age: %d\n\n\
                Is this correct?" name age) with
              | Ok _ -> Ok ()
              | Error e -> Eio.traceln "[Registration] ✗ %a" Error.pp e; Ok ())

         | None ->
             (match reply ctx "Please enter a valid number for your age." with
              | Ok _ -> Ok ()
              | Error e -> Eio.traceln "[Registration] ✗ %a" Error.pp e; Ok ()))

    | AwaitingConfirmation ->
        (match reply ctx "Please use the buttons below to confirm or cancel." with
         | Ok _ -> Ok ()
         | Error e -> Eio.traceln "[Registration] ✗ %a" Error.pp e; Ok ())

    | Complete ->
        (match reply ctx "You've already completed registration! Use /reset to start over." with
         | Ok _ -> Ok ()
         | Error e -> Eio.traceln "[Registration] ✗ %a" Error.pp e; Ok ())

  let cancel ctx =
    let open Verbose_bot.Ctx in
    Eio.traceln "[Registration] Cancelling, state → Idle";
    session_set ctx state_key Idle;
    session_delete ctx name_key;
    session_delete ctx age_key;
    edit ctx "❌ Registration cancelled."

  let confirm ctx =
    let open Verbose_bot.Ctx in
    Eio.traceln "[Registration] Confirming, state → Complete";
    let name = session_get_or ctx name_key ~default:"" in
    let age = session_get_or ctx age_key ~default:0 in

    session_set ctx state_key Complete;

    edit ctx (Printf.sprintf
      "✅ Registration Complete!\n\n\
       Name: %s\n\
       Age: %d\n\n\
       Welcome aboard!" name age)
end

(** Order state machine - States with embedded data *)
module Order = struct
  type item = {
    id: int;
    name: string;
    price: float;
  }

  type state =
    | Browsing
    | ViewingItem of { item: item }
    | InCart of { items: item list }
    | CheckingOut of { items: item list; total: float }
    | Complete

  let state_key = Verbose_session.make ~name:"order_state"

  let items_db = [
    { id = 1; name = "Coffee"; price = 3.50 };
    { id = 2; name = "Tea"; price = 2.50 };
    { id = 3; name = "Cake"; price = 5.00 };
  ]

  let get_item id = List.find_opt (fun item -> item.id = id) items_db

  let state_to_string = function
    | Browsing -> "Browsing"
    | ViewingItem _ -> "ViewingItem"
    | InCart _ -> "InCart"
    | CheckingOut _ -> "CheckingOut"
    | Complete -> "Complete"

  let start ctx =
    let open Verbose_bot.Ctx in
    Eio.traceln "[Order] Starting: → Browsing";
    session_set ctx state_key Browsing;

    let buttons = List.map (fun item ->
      [KB.callback ~text:(Printf.sprintf "%s - $%.2f" item.name item.price) ~data:(Printf.sprintf "order:view:%d" item.id)]
    ) items_db in

    let keyboard = KB.inline (buttons @ [[KB.callback ~text:"🛒 View Cart" ~data:"order:cart"]]) in

    send ~keyboard ctx
      "🛍️ Order Flow\n\n\
       Choose an item to view:"

  let view_item ctx item =
    let open Verbose_bot.Ctx in
    Eio.traceln "[Order] Transition: Browsing → ViewingItem(id=%d)" item.id;

    session_set ctx state_key (ViewingItem { item });

    let keyboard = KB.inline [
      [KB.callback ~text:"➕ Add to Cart" ~data:(Printf.sprintf "order:add:%d" item.id)];
      [KB.callback ~text:"← Back to Menu" ~data:"order:menu"];
    ] in

    edit ~keyboard ctx (Printf.sprintf
      "📦 %s\n\n\
       Price: $%.2f\n\n\
       Add this to your cart?"
      item.name item.price)

  let add_to_cart ctx item =
    let open Verbose_bot.Ctx in

    let state = session_get_or ctx state_key ~default:Browsing in

    let items = match state with
      | InCart { items } -> item :: items
      | _ -> [item]
    in

    Eio.traceln "[Order] Transition: → InCart (items=%d)" (List.length items);
    session_set ctx state_key (InCart { items });

    let keyboard = KB.inline [
      [KB.callback ~text:"← Continue Shopping" ~data:"order:menu"];
      [KB.callback ~text:"🛒 View Cart" ~data:"order:cart"];
    ] in

    edit ~keyboard ctx (Printf.sprintf "✅ Added %s to cart!\n\nItems in cart: %d" item.name (List.length items))

  let show_cart ctx =
    let open Verbose_bot.Ctx in

    let state = session_get_or ctx state_key ~default:Browsing in

    match state with
    | InCart { items } | CheckingOut { items; _ } ->
        let total = List.fold_left (fun acc item -> acc +. item.price) 0.0 items in

        let item_lines = List.map (fun item ->
          Printf.sprintf "• %s - $%.2f" item.name item.price
        ) items |> String.concat "\n" in

        let keyboard = KB.inline [
          [KB.callback ~text:"✅ Checkout" ~data:"order:checkout"];
          [KB.callback ~text:"← Back to Menu" ~data:"order:menu"];
        ] in

        edit ~keyboard ctx (Printf.sprintf
          "🛒 Your Cart\n\n\
           %s\n\n\
           Total: $%.2f"
          item_lines total)

    | _ ->
        edit ctx "🛒 Your cart is empty!\n\nUse /order to start shopping."

  let checkout ctx =
    let open Verbose_bot.Ctx in

    let state = session_get_or ctx state_key ~default:Browsing in

    match state with
    | InCart { items } ->
        let total = List.fold_left (fun acc item -> acc +. item.price) 0.0 items in

        Eio.traceln "[Order] Transition: InCart → CheckingOut (total=$%.2f)" total;
        session_set ctx state_key (CheckingOut { items; total });

        let keyboard = KB.inline [
          [KB.callback ~text:"💳 Pay Now" ~data:"order:pay"];
          [KB.callback ~text:"❌ Cancel" ~data:"order:cancel"];
        ] in

        edit ~keyboard ctx (Printf.sprintf
          "💳 Checkout\n\n\
           Total: $%.2f\n\n\
           Ready to pay?"
          total)

    | _ ->
        edit ctx "Cart is empty!"

  let complete_payment ctx =
    let open Verbose_bot.Ctx in
    Eio.traceln "[Order] Transition: CheckingOut → Complete";

    session_set ctx state_key Complete;

    edit ctx "✅ Payment complete!\n\nThank you for your order!"
end

(** Support ticket state machine - Branching flows *)
module Support = struct
  type category = Technical | Billing | General

  type state =
    | Idle
    | SelectingCategory
    | CollectingDetails of { category: category }
    | AwaitingResponse of { category: category; details: string }
    | Resolved

  let state_key = Verbose_session.make ~name:"support_state"

  let category_to_string = function
    | Technical -> "Technical"
    | Billing -> "Billing"
    | General -> "General"

  let state_to_string = function
    | Idle -> "Idle"
    | SelectingCategory -> "SelectingCategory"
    | CollectingDetails { category } -> Printf.sprintf "CollectingDetails(%s)" (category_to_string category)
    | AwaitingResponse { category; _ } -> Printf.sprintf "AwaitingResponse(%s)" (category_to_string category)
    | Resolved -> "Resolved"

  let start ctx =
    let open Verbose_bot.Ctx in
    Eio.traceln "[Support] Starting: Idle → SelectingCategory";
    session_set ctx state_key SelectingCategory;

    let keyboard = KB.inline [
      [KB.callback ~text:"🔧 Technical Issue" ~data:"support:tech"];
      [KB.callback ~text:"💳 Billing Question" ~data:"support:billing"];
      [KB.callback ~text:"❓ General Inquiry" ~data:"support:general"];
    ] in

    send ~keyboard ctx
      "🎫 Support Ticket\n\n\
       What type of issue are you experiencing?"

  let select_category ctx category =
    let open Verbose_bot.Ctx in
    let cat_str = category_to_string category in

    Eio.traceln "[Support] Transition: SelectingCategory → CollectingDetails(%s)" cat_str;
    session_set ctx state_key (CollectingDetails { category });

    edit ctx (Printf.sprintf
      "📝 %s Support\n\n\
       Please describe your issue in detail."
      cat_str)

  let handle_details ctx text =
    let open Verbose_bot.Ctx in

    let state = session_get_or ctx state_key ~default:Idle in

    match state with
    | CollectingDetails { category } ->
        let cat_str = category_to_string category in
        Eio.traceln "[Support] Transition: CollectingDetails(%s) → AwaitingResponse" cat_str;

        session_set ctx state_key (AwaitingResponse { category; details = text });

        let keyboard = KB.inline [
          [KB.callback ~text:"✅ Mark Resolved" ~data:"support:resolve"];
        ] in

        (match send ~keyboard ctx (Printf.sprintf
          "🎫 Ticket Created\n\n\
           Category: %s\n\
           Details: %s\n\n\
           Our team will respond shortly.\n\
           (This is a demo - no actual ticket created)"
          cat_str text) with
         | Ok _ -> Ok ()
         | Error e -> Eio.traceln "[Support] ✗ %a" Error.pp e; Ok ())

    | _ ->
        Ok ()

  let resolve ctx =
    let open Verbose_bot.Ctx in
    Eio.traceln "[Support] Transition: AwaitingResponse → Resolved";

    session_set ctx state_key Resolved;

    edit ctx "✅ Ticket marked as resolved!\n\nThank you for using our support."
end

let () =
  Printexc.record_backtrace true;
  Eio.traceln "=== State Machines Demo Starting ===";

  let token = match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None -> Printf.eprintf "TELEGRAM_BOT_TOKEN not set\n"; exit 1
  in

  Eio_main.run @@ fun env ->
  let client = Client.create ~env ~token () in

  Eio.traceln "🤖 State Machines Demo Bot Started";

  let session_store = Verbose_session.Memory_store.create () in

  Verbose_bot.make ~env ~client
  |> Verbose_bot.with_sessions (module Verbose_session.Memory_store) session_store

  (* /start - Main menu *)
  |> Verbose_bot.command "start" ~desc:"Show main menu" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/start] Showing main menu";

      let keyboard = KB.inline [
        [KB.callback ~text:"📝 Registration Flow" ~data:"demo:register"];
        [KB.callback ~text:"🛍️ Order Flow" ~data:"demo:order"];
        [KB.callback ~text:"🎫 Support Ticket" ~data:"demo:support"];
        [KB.callback ~text:"🔍 State Info" ~data:"demo:state_info"];
      ] in

      let text =
        "🤖 State Machines Demo\n\n\
         This demonstrates conversation flows using state machines.\n\n\
         Choose a demonstration:"
      in

      match send ~keyboard ctx text with
      | Ok _ -> Eio.traceln "[/start] ✓"; Ok ()
      | Error e -> Eio.traceln "[/start] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: demo:register *)
  |> Verbose_bot.on_callback_data "demo:register" (fun ctx ->
      match Registration.start ctx with
      | Ok _ -> Ok ()
      | Error e -> Eio.traceln "[demo:register] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: demo:order *)
  |> Verbose_bot.on_callback_data "demo:order" (fun ctx ->
      match Order.start ctx with
      | Ok _ -> Ok ()
      | Error e -> Eio.traceln "[demo:order] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: demo:support *)
  |> Verbose_bot.on_callback_data "demo:support" (fun ctx ->
      match Support.start ctx with
      | Ok _ -> Ok ()
      | Error e -> Eio.traceln "[demo:support] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: demo:state_info *)
  |> Verbose_bot.on_callback_data "demo:state_info" (fun ctx ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[state_info] Showing state information";

      let reg_state = session_get_or ctx Registration.state_key ~default:Registration.Idle in
      let order_state = session_get_or ctx Order.state_key ~default:Order.Browsing in
      let support_state = session_get_or ctx Support.state_key ~default:Support.Idle in

      let text = Printf.sprintf
        "🔍 Current State Information\n\n\
         Registration: %s\n\
         Order: %s\n\
         Support: %s\n\n\
         Each state machine maintains independent state."
        (Registration.state_to_string reg_state)
        (Order.state_to_string order_state)
        (Support.state_to_string support_state)
      in

      match edit ctx text with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[state_info] ✗ %a" Error.pp e; Ok ()
    )

  (* Registration callbacks *)
  |> Verbose_bot.on_callback_data "reg:confirm" (fun ctx ->
      match Registration.confirm ctx with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[reg:confirm] ✗ %a" Error.pp e; Ok ()
    )

  |> Verbose_bot.on_callback_data "reg:cancel" (fun ctx ->
      match Registration.cancel ctx with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[reg:cancel] ✗ %a" Error.pp e; Ok ()
    )

  (* Order callbacks *)
  |> Verbose_bot.on_callback_data "order:menu" (fun ctx ->
      match Order.start ctx with
      | Ok _ -> Ok ()
      | Error e -> Eio.traceln "[order:menu] ✗ %a" Error.pp e; Ok ()
    )

  |> Verbose_bot.on_callback (fun ctx data ->
      if String.starts_with ~prefix:"order:view:" data then (
        let id_str = String.sub data 11 (String.length data - 11) in
        let id = int_of_string id_str in

        match Order.get_item id with
        | Some item ->
            (match Order.view_item ctx item with
             | Ok () -> Ok ()
             | Error e -> Eio.traceln "[order:view] ✗ %a" Error.pp e; Ok ())
        | None ->
            Ok ()
      ) else Ok ()
    )

  |> Verbose_bot.on_callback (fun ctx data ->
      if String.starts_with ~prefix:"order:add:" data then (
        let id_str = String.sub data 10 (String.length data - 10) in
        let id = int_of_string id_str in

        match Order.get_item id with
        | Some item ->
            (match Order.add_to_cart ctx item with
             | Ok () -> Ok ()
             | Error e -> Eio.traceln "[order:add] ✗ %a" Error.pp e; Ok ())
        | None ->
            Ok ()
      ) else Ok ()
    )

  |> Verbose_bot.on_callback_data "order:cart" (fun ctx ->
      match Order.show_cart ctx with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[order:cart] ✗ %a" Error.pp e; Ok ()
    )

  |> Verbose_bot.on_callback_data "order:checkout" (fun ctx ->
      match Order.checkout ctx with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[order:checkout] ✗ %a" Error.pp e; Ok ()
    )

  |> Verbose_bot.on_callback_data "order:pay" (fun ctx ->
      match Order.complete_payment ctx with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[order:pay] ✗ %a" Error.pp e; Ok ()
    )

  |> Verbose_bot.on_callback_data "order:cancel" (fun ctx ->
      let open Verbose_bot.Ctx in
      session_set ctx Order.state_key Order.Browsing;
      match edit ctx "❌ Order cancelled" with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[order:cancel] ✗ %a" Error.pp e; Ok ()
    )

  (* Support ticket callbacks *)
  |> Verbose_bot.on_callback_data "support:tech" (fun ctx ->
      match Support.select_category ctx Support.Technical with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[support:tech] ✗ %a" Error.pp e; Ok ()
    )

  |> Verbose_bot.on_callback_data "support:billing" (fun ctx ->
      match Support.select_category ctx Support.Billing with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[support:billing] ✗ %a" Error.pp e; Ok ()
    )

  |> Verbose_bot.on_callback_data "support:general" (fun ctx ->
      match Support.select_category ctx Support.General with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[support:general] ✗ %a" Error.pp e; Ok ()
    )

  |> Verbose_bot.on_callback_data "support:resolve" (fun ctx ->
      match Support.resolve ctx with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[support:resolve] ✗ %a" Error.pp e; Ok ()
    )

  (* Text handler - routes to active state machine *)
  |> Verbose_bot.on_text (fun ctx text ->
      let open Verbose_bot.Ctx in

      (* Check which state machine is active *)
      let reg_state = session_get_or ctx Registration.state_key ~default:Registration.Idle in
      let support_state = session_get_or ctx Support.state_key ~default:Support.Idle in

      (* Route to registration if active *)
      let result = if reg_state <> Registration.Idle && reg_state <> Registration.Complete then
        Registration.handle_text ctx text
      else
        Ok ()
      in

      (* Route to support if active *)
      match result with
      | Ok () when support_state <> Support.Idle && support_state <> Support.Resolved ->
          Support.handle_details ctx text
      | _ -> result
    )

  (* /reset - Reset all state machines *)
  |> Verbose_bot.command "reset" ~desc:"Reset all state machines" (fun ctx _args ->
      let open Verbose_bot.Ctx in
      Eio.traceln "[/reset] Resetting all state machines";

      session_set ctx Registration.state_key Registration.Idle;
      session_set ctx Order.state_key Order.Browsing;
      session_set ctx Support.state_key Support.Idle;
      session_delete ctx Registration.name_key;
      session_delete ctx Registration.age_key;

      match reply ctx
        "🔄 All state machines reset!\n\n\
         • Registration → Idle\n\
         • Order → Browsing\n\
         • Support → Idle\n\n\
         Use /start to begin."
      with
      | Ok _ -> Eio.traceln "[/reset] ✓"; Ok ()
      | Error e -> Eio.traceln "[/reset] ✗ %a" Error.pp e; Ok ()
    )

  |> Verbose_bot.run
