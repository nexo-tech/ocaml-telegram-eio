(** Content Bots Use Case - Content delivery and media library patterns

    This example demonstrates content bot patterns:
    - Content library with categories and tags
    - Subscription management (subscribe/unsubscribe)
    - Search and pagination
    - Daily digest scheduling
    - Media browsing with inline keyboards
    - Content recommendations

    Commands:
      /start - Show main menu
      /browse - Browse content library
      /search <query> - Search content by title/tags
      /category <name> - Filter by category
      /subscribe - Subscribe to daily digest
      /unsubscribe - Unsubscribe from digest
      /status - Show subscription status
      /latest - Show latest content (10 items)
      /recommendations - Personalized recommendations

    This example has VERBOSE LOGGING enabled for troubleshooting.

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/usecase_content_bots_demo.exe
*)

open Telegram
open Tg

(* Configure verbose logging with flo *)
let () = Flo.set_level Severity.Debug

module KB = Keyboard

(** Content item type *)
type content_item = {
  id: string;
  title: string;
  description: string;
  category: string;
  tags: string list;
  url: string;
  published: float;
}

(** Content library module *)
module ContentLibrary = struct
  let items = ref [
    { id = "1"; title = "OCaml Programming Guide";
      description = "Learn OCaml basics";
      category = "Tutorial"; tags = ["ocaml"; "programming"; "beginner"];
      url = "https://ocaml.org/docs";
      published = Unix.time () -. 86400.0 };

    { id = "2"; title = "Eio Structured Concurrency";
      description = "Effects-based concurrency";
      category = "Advanced"; tags = ["eio"; "concurrency"; "effects"];
      url = "https://github.com/ocaml-multicore/eio";
      published = Unix.time () -. 172800.0 };

    { id = "3"; title = "Telegram Bot API";
      description = "Official Telegram Bot documentation";
      category = "Reference"; tags = ["telegram"; "api"; "bots"];
      url = "https://core.telegram.org/bots/api";
      published = Unix.time () -. 259200.0 };

    { id = "4"; title = "Functional Programming Patterns";
      description = "Design patterns in functional style";
      category = "Tutorial"; tags = ["functional"; "patterns"; "design"];
      url = "https://example.com/fp-patterns";
      published = Unix.time () -. 345600.0 };

    { id = "5"; title = "Type-Driven Development";
      description = "Using types to guide development";
      category = "Advanced"; tags = ["types"; "tdd"; "ocaml"];
      url = "https://example.com/type-driven";
      published = Unix.time () -. 432000.0 };
  ]

  let contains_substring s sub =
    try
      let _ = Str.search_forward (Str.regexp_string sub) s 0 in
      true
    with Not_found -> false

  let search query =
    let q_lower = String.lowercase_ascii query in
    Eio.traceln "[ContentLibrary] Searching for: %s" query;

    List.filter (fun item ->
      let title_match = contains_substring (String.lowercase_ascii item.title) q_lower in
      let desc_match = contains_substring (String.lowercase_ascii item.description) q_lower in
      let tag_match = List.exists (fun tag ->
        contains_substring (String.lowercase_ascii tag) q_lower
      ) item.tags in

      title_match || desc_match || tag_match
    ) !items

  let by_category category =
    Eio.traceln "[ContentLibrary] Filtering by category: %s" category;
    List.filter (fun item ->
      String.equal (String.lowercase_ascii item.category) (String.lowercase_ascii category)
    ) !items

  let latest n =
    Eio.traceln "[ContentLibrary] Getting latest %d items" n;
    !items
    |> List.sort (fun a b -> compare b.published a.published)
    |> (fun lst -> if List.length lst > n then List.filteri (fun i _ -> i < n) lst else lst)

  let find_by_id id =
    List.find_opt (fun item -> item.id = id) !items

  let categories () =
    !items
    |> List.map (fun item -> item.category)
    |> List.sort_uniq compare
end

(** Subscription management *)
module Subscriptions = struct
  let subscribers = Hashtbl.create 100

  let subscribe user_id =
    Eio.traceln "[Subscriptions] User %Ld subscribed" user_id;
    Hashtbl.replace subscribers user_id ()

  let unsubscribe user_id =
    Eio.traceln "[Subscriptions] User %Ld unsubscribed" user_id;
    Hashtbl.remove subscribers user_id

  let is_subscribed user_id =
    Hashtbl.mem subscribers user_id

  let get_all () =
    Hashtbl.to_seq_keys subscribers |> List.of_seq

  let count () =
    Hashtbl.length subscribers
end

(** Session keys *)
let subscribed_key = Session.make ~name:"is_subscribed"
let last_browse_offset_key = Session.make ~name:"browse_offset"

(** Format content item for display *)
let format_item item =
  let tags_str = String.concat ", " item.tags in
  Printf.sprintf
    "📄 <b>%s</b>\n\n\
     %s\n\n\
     Category: %s\n\
     Tags: %s\n\
     Link: %s"
    item.title
    item.description
    item.category
    tags_str
    item.url

(** Create pagination keyboard *)
let pagination_keyboard items offset page_size prefix =
  let total = List.length items in
  let has_prev = offset > 0 in
  let has_next = offset + page_size < total in

  let prev_btn = if has_prev then
    [KB.callback ~text:"⟵ Prev" ~data:(Printf.sprintf "%s:page:%d" prefix (max 0 (offset - page_size)))]
  else [] in

  let next_btn = if has_next then
    [KB.callback ~text:"Next ⟶" ~data:(Printf.sprintf "%s:page:%d" prefix (offset + page_size))]
  else [] in

  let nav_row = if prev_btn <> [] || next_btn <> [] then
    [prev_btn @ next_btn]
  else [] in

  nav_row

let () =
  Printexc.record_backtrace true;
  Eio.traceln "=== Content Bots Demo Starting ===";

  let token = match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None -> Printf.eprintf "TELEGRAM_BOT_TOKEN not set\n"; exit 1
  in

  Eio_main.run @@ fun env ->
  let client = Client.create ~env ~token () in

  Eio.traceln "🤖 Content Bots Demo Started";
  Eio.traceln "Content items loaded: %d" (List.length !(ContentLibrary.items));

  let session_store = Session.Memory_store.create () in

  (* Global switch for background tasks *)
  Eio.Switch.run @@ fun global_sw ->

  (* Background task: Daily digest at 9:00 AM (simulated with 2 minute interval for demo) *)
  Eio.Fiber.fork ~sw:global_sw (fun () ->
    let clock = env#clock in
    Eio.traceln "[Background] Daily digest scheduler started (every 2 minutes for demo)";

    while true do
      Eio.Time.sleep clock 120.0;  (* 2 minutes for demo, use 86400 for daily *)

      let subscriber_count = Subscriptions.count () in
      Eio.traceln "[Background] Sending daily digest to %d subscribers" subscriber_count;

      if subscriber_count > 0 then (
        let latest = ContentLibrary.latest 3 in
        let digest_text =
          let items_text = List.map (fun item ->
            Printf.sprintf "• %s\n  %s" item.title item.url
          ) latest |> String.concat "\n\n" in

          Printf.sprintf
            "📰 <b>Daily Content Digest</b>\n\n\
             Here are the latest 3 items:\n\n\
             %s\n\n\
             Use /unsubscribe to stop receiving digests."
            items_text
        in

        Subscriptions.get_all () |> List.iter (fun user_id ->
          let chat_id = Id.Chat.of_int user_id in
          match Telegram_generated.Gen_methods.send_message
            client ~chat_id ~text:digest_text () with
          | Ok _ -> Eio.traceln "[Background] Digest sent to user %Ld" user_id
          | Error e -> Eio.traceln "[Background] Failed to send to %Ld: %a" user_id Error.pp e
        )
      )
    done
  );

  Bot.make ~env ~client
  |> Bot.with_sessions (module Session.Memory_store) session_store

  (* /start - Main menu *)
  |> Bot.command "start" ~desc:"Show main menu" (fun ctx _args ->
      let open Bot.Ctx in
      Eio.traceln "[/start] Showing main menu";

      let keyboard = KB.inline [
        [KB.callback ~text:"📚 Browse Content" ~data:"action:browse"];
        [KB.callback ~text:"🔍 Search" ~data:"action:search_prompt"];
        [KB.callback ~text:"📂 Categories" ~data:"action:categories"];
        [KB.callback ~text:"✉️ Subscribe to Digest" ~data:"action:subscribe"];
      ] in

      let text =
        "📰 <b>Content Bot Demo</b>\n\n\
         Access curated content with:\n\
         • Browsing and pagination\n\
         • Search by title/tags\n\
         • Category filtering\n\
         • Daily digest subscriptions\n\n\
         Choose an option below:"
      in

      match send ~keyboard ctx text with
      | Ok _ -> Eio.traceln "[/start] ✓"; Ok ()
      | Error e -> Eio.traceln "[/start] ✗ %a" Error.pp e; Ok ()
    )

  (* /browse - Browse content library *)
  |> Bot.command "browse" ~desc:"Browse content library" (fun ctx _args ->
      let open Bot.Ctx in
      Eio.traceln "[/browse] Browsing content";

      let items = !(ContentLibrary.items) in
      let offset = 0 in
      session_set ctx last_browse_offset_key offset;

      let page_size = 3 in
      let slice = List.filteri (fun i _ -> i >= offset && i < offset + page_size) items in

      let item_buttons = List.map (fun item ->
        [KB.callback ~text:item.title ~data:("view:" ^ item.id)]
      ) slice in

      let nav_buttons = pagination_keyboard items offset page_size "browse" in

      let keyboard = KB.inline (item_buttons @ nav_buttons) in

      let text = Printf.sprintf
        "📚 <b>Content Library</b>\n\n\
         Showing %d-%d of %d items"
        (offset + 1)
        (min (offset + page_size) (List.length items))
        (List.length items)
      in

      match send ~keyboard ctx text with
      | Ok _ -> Eio.traceln "[/browse] ✓"; Ok ()
      | Error e -> Eio.traceln "[/browse] ✗ %a" Error.pp e; Ok ()
    )

  (* /search - Search content *)
  |> Bot.command "search" ~desc:"Search content" (fun ctx args ->
      let open Bot.Ctx in
      Eio.traceln "[/search] Searching content";

      match args with
      | [] ->
          (match reply ctx "Usage: /search <query>\n\nExample: /search ocaml" with
           | Ok _ -> Ok ()
           | Error e -> Eio.traceln "[/search] ✗ %a" Error.pp e; Ok ())

      | _ ->
          let query = String.concat " " args in
          let results = ContentLibrary.search query in

          Eio.traceln "[/search] Found %d results for: %s" (List.length results) query;

          if List.length results = 0 then
            (match reply ctx (Printf.sprintf "No results found for: %s" query) with
             | Ok _ -> Ok ()
             | Error e -> Eio.traceln "[/search] ✗ %a" Error.pp e; Ok ())
          else
            let item_buttons = List.map (fun item ->
              [KB.callback ~text:item.title ~data:("view:" ^ item.id)]
            ) results in

            let keyboard = KB.inline item_buttons in

            let text = Printf.sprintf
              "🔍 <b>Search Results</b>\n\n\
               Query: %s\n\
               Found: %d items"
              query (List.length results)
            in

            (match send ~keyboard ctx text with
             | Ok _ -> Eio.traceln "[/search] ✓"; Ok ()
             | Error e -> Eio.traceln "[/search] ✗ %a" Error.pp e; Ok ())
    )

  (* /category - Filter by category *)
  |> Bot.command "category" ~desc:"Filter by category" (fun ctx args ->
      let open Bot.Ctx in
      Eio.traceln "[/category] Filtering by category";

      match args with
      | [] ->
          let categories = ContentLibrary.categories () in
          let cat_buttons = List.map (fun cat ->
            [KB.callback ~text:cat ~data:("cat:" ^ cat)]
          ) categories in

          let keyboard = KB.inline cat_buttons in

          let text = Printf.sprintf
            "📂 <b>Categories</b>\n\n\
             Available: %d categories"
            (List.length categories)
          in

          (match send ~keyboard ctx text with
           | Ok _ -> Ok ()
           | Error e -> Eio.traceln "[/category] ✗ %a" Error.pp e; Ok ())

      | _ ->
          let category = String.concat " " args in
          let results = ContentLibrary.by_category category in

          Eio.traceln "[/category] Found %d items in category: %s"
            (List.length results) category;

          if List.length results = 0 then
            (match reply ctx (Printf.sprintf "No items in category: %s" category) with
             | Ok _ -> Ok ()
             | Error e -> Eio.traceln "[/category] ✗ %a" Error.pp e; Ok ())
          else
            let item_buttons = List.map (fun item ->
              [KB.callback ~text:item.title ~data:("view:" ^ item.id)]
            ) results in

            let keyboard = KB.inline item_buttons in

            let text = Printf.sprintf
              "📂 <b>Category: %s</b>\n\n\
               Items: %d"
              category (List.length results)
            in

            (match send ~keyboard ctx text with
             | Ok _ -> Eio.traceln "[/category] ✓"; Ok ()
             | Error e -> Eio.traceln "[/category] ✗ %a" Error.pp e; Ok ())
    )

  (* /latest - Show latest content *)
  |> Bot.command "latest" ~desc:"Show latest content" (fun ctx _args ->
      let open Bot.Ctx in
      Eio.traceln "[/latest] Showing latest content";

      let latest = ContentLibrary.latest 5 in

      let item_buttons = List.map (fun item ->
        [KB.callback ~text:item.title ~data:("view:" ^ item.id)]
      ) latest in

      let keyboard = KB.inline item_buttons in

      let text = Printf.sprintf
        "⭐ <b>Latest Content</b>\n\n\
         Showing %d most recent items:"
        (List.length latest)
      in

      match send ~keyboard ctx text with
      | Ok _ -> Eio.traceln "[/latest] ✓"; Ok ()
      | Error e -> Eio.traceln "[/latest] ✗ %a" Error.pp e; Ok ()
    )

  (* /subscribe - Subscribe to digest *)
  |> Bot.command "subscribe" ~desc:"Subscribe to daily digest" (fun ctx _args ->
      let open Bot.Ctx in
      Eio.traceln "[/subscribe] Processing subscription";

      match user ctx with
      | Some u ->
          let user_id_str = Id.to_string u.id in
          let user_id = Int64.of_string user_id_str in

          Subscriptions.subscribe user_id;
          session_set ctx subscribed_key true;

          Eio.traceln "[/subscribe] User %Ld subscribed (total: %d)"
            user_id (Subscriptions.count ());

          let text =
            "✅ <b>Subscribed!</b>\n\n\
             You'll receive a daily digest with the latest content.\n\n\
             Digest schedule: Every 2 minutes (demo)\n\
             (In production: Daily at 9:00 AM)\n\n\
             Use /unsubscribe to stop."
          in

          (match reply ctx text with
           | Ok _ -> Eio.traceln "[/subscribe] ✓"; Ok ()
           | Error e -> Eio.traceln "[/subscribe] ✗ %a" Error.pp e; Ok ())

      | None ->
          Eio.traceln "[/subscribe] No user in context";
          Ok ()
    )

  (* /unsubscribe - Unsubscribe from digest *)
  |> Bot.command "unsubscribe" ~desc:"Unsubscribe from digest" (fun ctx _args ->
      let open Bot.Ctx in
      Eio.traceln "[/unsubscribe] Processing unsubscription";

      match user ctx with
      | Some u ->
          let user_id_str = Id.to_string u.id in
          let user_id = Int64.of_string user_id_str in

          Subscriptions.unsubscribe user_id;
          session_set ctx subscribed_key false;

          Eio.traceln "[/unsubscribe] User %Ld unsubscribed (remaining: %d)"
            user_id (Subscriptions.count ());

          (match reply ctx
            "❌ <b>Unsubscribed</b>\n\n\
             You won't receive daily digests anymore.\n\n\
             Use /subscribe to re-enable."
           with
           | Ok _ -> Eio.traceln "[/unsubscribe] ✓"; Ok ()
           | Error e -> Eio.traceln "[/unsubscribe] ✗ %a" Error.pp e; Ok ())

      | None ->
          Ok ()
    )

  (* /status - Subscription status *)
  |> Bot.command "status" ~desc:"Show subscription status" (fun ctx _args ->
      let open Bot.Ctx in
      Eio.traceln "[/status] Showing status";

      match user ctx with
      | Some u ->
          let user_id_str = Id.to_string u.id in
          let user_id = Int64.of_string user_id_str in
          let is_subscribed = Subscriptions.is_subscribed user_id in

          let text = Printf.sprintf
            "ℹ️ <b>Subscription Status</b>\n\n\
             Daily digest: %s\n\
             Total subscribers: %d\n\
             Content items: %d"
            (if is_subscribed then "✅ Subscribed" else "❌ Not subscribed")
            (Subscriptions.count ())
            (List.length !(ContentLibrary.items))
          in

          (match reply ctx text with
           | Ok _ -> Eio.traceln "[/status] ✓"; Ok ()
           | Error e -> Eio.traceln "[/status] ✗ %a" Error.pp e; Ok ())

      | None ->
          Ok ()
    )

  (* Callback: view:<id> - View content item *)
  |> Bot.on_callback (fun ctx data ->
      if String.starts_with ~prefix:"view:" data then (
        let open Bot.Ctx in
        let id = String.sub data 5 (String.length data - 5) in
        Eio.traceln "[view] Viewing item: %s" id;

        match ContentLibrary.find_by_id id with
        | Some item ->
            let text = format_item item in
            (match edit ctx text with
             | Ok () -> Eio.traceln "[view] ✓"; Ok ()
             | Error e -> Eio.traceln "[view] ✗ %a" Error.pp e; Ok ())
        | None ->
            (match edit ctx "❌ Content not found" with
             | Ok () -> Ok ()
             | Error e -> Eio.traceln "[view] ✗ %a" Error.pp e; Ok ())
      ) else Ok ()
    )

  (* Callback: browse:page:<offset> - Pagination *)
  |> Bot.on_callback (fun ctx data ->
      if String.starts_with ~prefix:"browse:page:" data then (
        let open Bot.Ctx in
        let offset_str = String.sub data 12 (String.length data - 12) in
        let offset = int_of_string offset_str in

        Eio.traceln "[browse:page] Offset: %d" offset;

        session_set ctx last_browse_offset_key offset;

        let items = !(ContentLibrary.items) in
        let page_size = 3 in
        let slice = List.filteri (fun i _ -> i >= offset && i < offset + page_size) items in

        let item_buttons = List.map (fun item ->
          [KB.callback ~text:item.title ~data:("view:" ^ item.id)]
        ) slice in

        let nav_buttons = pagination_keyboard items offset page_size "browse" in

        let keyboard = KB.inline (item_buttons @ nav_buttons) in

        let text = Printf.sprintf
          "📚 <b>Content Library</b>\n\n\
           Showing %d-%d of %d items"
          (offset + 1)
          (min (offset + page_size) (List.length items))
          (List.length items)
        in

        (match edit ~keyboard ctx text with
         | Ok () -> Eio.traceln "[browse:page] ✓"; Ok ()
         | Error e -> Eio.traceln "[browse:page] ✗ %a" Error.pp e; Ok ())
      ) else Ok ()
    )

  (* Callback: cat:<category> - Category filter *)
  |> Bot.on_callback (fun ctx data ->
      if String.starts_with ~prefix:"cat:" data then (
        let open Bot.Ctx in
        let category = String.sub data 4 (String.length data - 4) in
        Eio.traceln "[cat] Filtering by: %s" category;

        let results = ContentLibrary.by_category category in

        let item_buttons = List.map (fun item ->
          [KB.callback ~text:item.title ~data:("view:" ^ item.id)]
        ) results in

        let keyboard = KB.inline item_buttons in

        let text = Printf.sprintf
          "📂 <b>%s</b>\n\n\
           Items: %d"
          category (List.length results)
        in

        (match edit ~keyboard ctx text with
         | Ok () -> Ok ()
         | Error e -> Eio.traceln "[cat] ✗ %a" Error.pp e; Ok ())
      ) else Ok ()
    )

  (* Callback: action:browse *)
  |> Bot.on_callback_data "action:browse" (fun ctx ->
      let open Bot.Ctx in

      let items = !(ContentLibrary.items) in
      let offset = 0 in
      let page_size = 3 in
      let slice = List.filteri (fun i _ -> i >= offset && i < offset + page_size) items in

      let item_buttons = List.map (fun item ->
        [KB.callback ~text:item.title ~data:("view:" ^ item.id)]
      ) slice in

      let nav_buttons = pagination_keyboard items offset page_size "browse" in

      let keyboard = KB.inline (item_buttons @ nav_buttons) in

      let text = Printf.sprintf "📚 <b>Content Library</b>\n\nShowing 1-%d of %d items"
        (min page_size (List.length items)) (List.length items) in

      match edit ~keyboard ctx text with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[action:browse] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: action:categories *)
  |> Bot.on_callback_data "action:categories" (fun ctx ->
      let open Bot.Ctx in

      let categories = ContentLibrary.categories () in
      let cat_buttons = List.map (fun cat ->
        [KB.callback ~text:cat ~data:("cat:" ^ cat)]
      ) categories in

      let keyboard = KB.inline cat_buttons in

      match edit ~keyboard ctx "📂 <b>Categories</b>\n\nChoose a category:" with
      | Ok () -> Ok ()
      | Error e -> Eio.traceln "[action:categories] ✗ %a" Error.pp e; Ok ()
    )

  (* Callback: action:subscribe *)
  |> Bot.on_callback_data "action:subscribe" (fun ctx ->
      let open Bot.Ctx in

      match user ctx with
      | Some u ->
          let user_id_str = Id.to_string u.id in
          let user_id = Int64.of_string user_id_str in
          Subscriptions.subscribe user_id;
          session_set ctx subscribed_key true;

          (match edit ctx
            "✅ <b>Subscribed!</b>\n\n\
             You'll receive daily digests.\n\
             Use /unsubscribe to stop."
           with
           | Ok () -> Ok ()
           | Error e -> Eio.traceln "[action:subscribe] ✗ %a" Error.pp e; Ok ())
      | None -> Ok ()
    )

  |> Bot.run
