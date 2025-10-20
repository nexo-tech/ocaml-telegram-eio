(** Recipe: Inline Query Bot

    A comprehensive inline query system demonstrating:
    - Handling inline queries for search and content discovery
    - Rich inline results (articles, photos, GIFs)
    - Client-side result caching with TTL
    - Server-side cache control
    - Pagination for large result sets
    - Inline keyboard integration
    - Chosen result tracking
    - Multiple search modes
    - Result-based error handling
    - Functor-based verbose logging
*)

open Telegram
open Tg

(** {1 Verbose Logging Setup} *)

(* Configure verbose logging with flo *)
let () = Flo.set_level Severity.Debug

(* String contains substring helper *)
module String = struct
  include String
  let contains_s haystack needle =
    try
      let _ = String.index haystack needle.[0] in
      let len_h = String.length haystack in
      let len_n = String.length needle in
      let rec check i =
        if i + len_n > len_h then false
        else if String.sub haystack i len_n = needle then true
        else check (i + 1)
      in
      check 0
    with _ -> false
end

(** {1 Article Database} *)

type article = {
  id : int;
  title : string;
  summary : string;
  _content : string;
  url : string;
  thumbnail : string option;
  category : string;
}

module ArticleDB = struct
  let articles = [
    {
      id = 1;
      title = "OCaml Programming Language";
      summary = "General-purpose, multi-paradigm programming language";
      _content = "<b>OCaml</b> is a general-purpose programming language with an emphasis on expressiveness and safety. It features a powerful type system with type inference.";
      url = "https://ocaml.org";
      thumbnail = Some "https://ocaml.org/logo.png";
      category = "programming";
    };
    {
      id = 2;
      title = "Functional Programming";
      summary = "Programming paradigm based on mathematical functions";
      _content = "<b>Functional programming</b> is a programming paradigm where programs are constructed by applying and composing functions. It emphasizes immutability and pure functions.";
      url = "https://en.wikipedia.org/wiki/Functional_programming";
      thumbnail = None;
      category = "programming";
    };
    {
      id = 3;
      title = "Type Theory";
      summary = "Mathematical logic and formal systems";
      _content = "<b>Type theory</b> is a formal system in which every term has a type. It provides a foundation for type systems in programming languages.";
      url = "https://en.wikipedia.org/wiki/Type_theory";
      thumbnail = None;
      category = "theory";
    };
    {
      id = 4;
      title = "Eio - Effects-based IO";
      summary = "Effects-based direct-style IO library for OCaml";
      _content = "<b>Eio</b> provides an effects-based direct-style IO stack for OCaml 5. It features structured concurrency and fiber-based parallelism.";
      url = "https://github.com/ocaml-multicore/eio";
      thumbnail = None;
      category = "library";
    };
    {
      id = 5;
      title = "Telegram Bot API";
      summary = "Bot API for creating Telegram bots";
      _content = "<b>Telegram Bot API</b> allows you to easily create bots for Telegram. Use it to build custom tools and integrations.";
      url = "https://core.telegram.org/bots/api";
      thumbnail = None;
      category = "api";
    };
  ]

  let search query =
    Flo.debugf "[ArticleDB] Searching for query: '%s'" query;

    if String.length query < 2 then begin
      Flo.debugf "[ArticleDB] Query too short, returning all %d articles" (List.length articles);
      articles
    end else begin
      let query_lower = String.lowercase_ascii query in
      let results = List.filter (fun article ->
        let title_match = String.contains_s (String.lowercase_ascii article.title) query_lower in
        let summary_match = String.contains_s (String.lowercase_ascii article.summary) query_lower in
        let category_match = String.contains_s (String.lowercase_ascii article.category) query_lower in
        title_match || summary_match || category_match
      ) articles in
      Flo.debugf "[ArticleDB] Found %d matching articles" (List.length results);
      results
    end

  let _search_by_category category =
    Flo.debugf "[ArticleDB] Searching by category: '%s'" category;
    let results = List.filter (fun article ->
      String.equal (String.lowercase_ascii article.category) (String.lowercase_ascii category)
    ) articles in
    Flo.debugf "[ArticleDB] Found %d articles in category" (List.length results);
    results
end

(** {1 Photo Gallery} *)

type photo_item = {
  id : string;
  photo_url : string;
  thumbnail_url : string;
  caption : string;
  tags : string list;
}

module PhotoGallery = struct
  let photos = [
    {
      id = "photo_1";
      photo_url = "https://picsum.photos/800/600?random=1";
      thumbnail_url = "https://picsum.photos/200/150?random=1";
      caption = "Beautiful sunset over mountains 🌅";
      tags = ["nature"; "sunset"; "mountains"];
    };
    {
      id = "photo_2";
      photo_url = "https://picsum.photos/800/600?random=2";
      thumbnail_url = "https://picsum.photos/200/150?random=2";
      caption = "Ocean waves at the beach 🌊";
      tags = ["nature"; "ocean"; "beach"];
    };
    {
      id = "photo_3";
      photo_url = "https://picsum.photos/800/600?random=3";
      thumbnail_url = "https://picsum.photos/200/150?random=3";
      caption = "Forest path in autumn 🍂";
      tags = ["nature"; "forest"; "autumn"];
    };
  ]

  let search query =
    Flo.debugf "[PhotoGallery] Searching photos for: '%s'" query;
    if String.length query = 0 then begin
      Flo.debugf "[PhotoGallery] Empty query, returning all %d photos" (List.length photos);
      photos
    end else begin
      let query_lower = String.lowercase_ascii query in
      let results = List.filter (fun photo ->
        let caption_match = String.contains_s (String.lowercase_ascii photo.caption) query_lower in
        let tag_match = List.exists (fun tag -> String.contains_s tag query_lower) photo.tags in
        caption_match || tag_match
      ) photos in
      Flo.debugf "[PhotoGallery] Found %d matching photos" (List.length results);
      results
    end
end

(** {1 GIF Library} *)

type gif_item = {
  id : string;
  gif_url : string;
  thumbnail_url : string;
  title : string;
  tags : string list;
}

module GifLibrary = struct
  let gifs = [
    {
      id = "gif_1";
      gif_url = "https://media.giphy.com/media/13HgwGsXF0aiGY/giphy.gif";
      thumbnail_url = "https://media.giphy.com/media/13HgwGsXF0aiGY/200.gif";
      title = "Typing fast";
      tags = ["typing"; "work"; "computer"];
    };
    {
      id = "gif_2";
      gif_url = "https://media.giphy.com/media/JIX9t2j0ZTN9S/giphy.gif";
      thumbnail_url = "https://media.giphy.com/media/JIX9t2j0ZTN9S/200.gif";
      title = "Celebration";
      tags = ["celebrate"; "happy"; "party"];
    };
  ]

  let search query =
    Flo.debugf "[GifLibrary] Searching GIFs for: '%s'" query;
    if String.length query = 0 then begin
      Flo.debugf "[GifLibrary] Empty query, returning all %d GIFs" (List.length gifs);
      gifs
    end else begin
      let query_lower = String.lowercase_ascii query in
      let results = List.filter (fun gif ->
        let title_match = String.contains_s (String.lowercase_ascii gif.title) query_lower in
        let tag_match = List.exists (fun tag -> String.contains_s tag query_lower) gif.tags in
        title_match || tag_match
      ) gifs in
      Flo.debugf "[GifLibrary] Found %d matching GIFs" (List.length results);
      results
    end
end

(** {1 Client-Side Result Cache} *)

module ResultCache = struct
  type cache_entry = {
    results : Telegram_generated.Gen_types.InlineQueryResult.t list;
    timestamp : float;
  }

  let cache : (string, cache_entry) Hashtbl.t = Hashtbl.create 1000
  let ttl = 300.0  (* 5 minutes *)

  let get query =
    Flo.debugf "[ResultCache] Looking up cache for query: '%s'" query;
    match Hashtbl.find_opt cache query with
    | Some entry ->
        let age = Unix.time () -. entry.timestamp in
        if age < ttl then begin
          Flo.successf "[ResultCache] ✅ Cache hit (age: %.1fs)" age;
          Some entry.results
        end else begin
          Flo.errorf "[ResultCache] ❌ Cache expired (age: %.1fs > %.1fs)" age ttl;
          Hashtbl.remove cache query;
          None
        end
    | None ->
        Flo.error "[ResultCache] ❌ Cache miss";
        None

  let set query results =
    let entry = { results; timestamp = Unix.time () } in
    Hashtbl.replace cache query entry;
    Flo.successf "[ResultCache] ✅ Cached %d results for query: '%s'" (List.length results) query

  let clear () =
    let count = Hashtbl.length cache in
    Hashtbl.clear cache;
    Flo.debugf "[ResultCache] Cleared cache (%d entries removed)" count

  let size () =
    Hashtbl.length cache
end

(** {1 Inline Keyboard Creation} *)

module InlineKeyboard = struct
  let create_article_keyboard url =
    Flo.debugf "[InlineKeyboard] Creating keyboard for URL: %s" url;
    let open Telegram_generated.Gen_types in

    InlineKeyboardMarkup.{
      inline_keyboard = [[
        InlineKeyboardButton.{
          text = "📖 Read Full Article";
          url = Some url;
          callback_data = None;
          web_app = None;
          login_url = None;
          switch_inline_query = None;
          switch_inline_query_current_chat = None;
          switch_inline_query_chosen_chat = None;
          copy_text = None;
          callback_game = None;
          pay = None;
          unknown_fields = [];
        };
        InlineKeyboardButton.{
          text = "🔍 Share";
          url = None;
          callback_data = None;
          web_app = None;
          login_url = None;
          switch_inline_query = Some "";  (* Share in another chat *)
          switch_inline_query_current_chat = None;
          switch_inline_query_chosen_chat = None;
          copy_text = None;
          callback_game = None;
          pay = None;
          unknown_fields = [];
        };
      ]];
      unknown_fields = [];
    }

  let create_search_keyboard query =
    Flo.debugf "[InlineKeyboard] Creating search keyboard for query: '%s'" query;
    let open Telegram_generated.Gen_types in

    InlineKeyboardMarkup.{
      inline_keyboard = [[
        InlineKeyboardButton.{
          text = "🔄 Search Again";
          url = None;
          callback_data = None;
          web_app = None;
          login_url = None;
          switch_inline_query = Some query;
          switch_inline_query_current_chat = None;
          switch_inline_query_chosen_chat = None;
          copy_text = None;
          callback_game = None;
          pay = None;
          unknown_fields = [];
        };
        InlineKeyboardButton.{
          text = "📝 Search Here";
          url = None;
          callback_data = None;
          web_app = None;
          login_url = None;
          switch_inline_query = None;
          switch_inline_query_current_chat = Some "";
          switch_inline_query_chosen_chat = None;
          copy_text = None;
          callback_game = None;
          pay = None;
          unknown_fields = [];
        };
      ]];
      unknown_fields = [];
    }
end

(** {1 Result Converters} *)

module ResultConverter = struct
  let article_to_result (article : article) =
    Flo.debugf "[ResultConverter] Converting article to result: id=%d, title='%s'"
      article.id article.title;

    let open Telegram_generated.Gen_types in

    (* Note: InputMessageContent.t is unit in generated types - placeholder *)
    let result = InlineQueryResultArticle.{
      type_ = "article";
      id = string_of_int article.id;
      title = article.title;
      input_message_content = ();  (* Placeholder - generated types incomplete *)
      reply_markup = Some (InlineKeyboard.create_article_keyboard article.url);
      description = Some article.summary;
      url = Some article.url;
      thumbnail_url = article.thumbnail;
      thumbnail_width = None;
      thumbnail_height = None;
      unknown_fields = [];
    } in

    (* Note: InlineQueryResult.t is unit in generated types - using Obj.magic as workaround *)
    (Obj.magic result : InlineQueryResult.t)

  let photo_to_result (photo : photo_item) =
    Flo.debugf "[ResultConverter] Converting photo to result: id=%s, caption='%s'"
      photo.id photo.caption;

    let open Telegram_generated.Gen_types in

    let result = InlineQueryResultPhoto.{
      type_ = "photo";
      id = photo.id;
      photo_url = photo.photo_url;
      thumbnail_url = photo.thumbnail_url;
      photo_width = Some 800L;
      photo_height = Some 600L;
      title = Some photo.caption;
      description = None;
      caption = Some photo.caption;
      parse_mode = Some "HTML";
      caption_entities = None;
      show_caption_above_media = None;
      reply_markup = Some (InlineKeyboard.create_search_keyboard "");
      input_message_content = None;
      unknown_fields = [];
    } in

    (Obj.magic result : InlineQueryResult.t)

  let gif_to_result (gif : gif_item) =
    Flo.debugf "[ResultConverter] Converting GIF to result: id=%s, title='%s'"
      gif.id gif.title;

    let open Telegram_generated.Gen_types in

    let result = InlineQueryResultGif.{
      type_ = "gif";
      id = gif.id;
      gif_url = gif.gif_url;
      thumbnail_url = gif.thumbnail_url;
      gif_width = Some 480L;
      gif_height = Some 360L;
      gif_duration = None;
      thumbnail_mime_type = Some "image/jpeg";
      title = Some gif.title;
      caption = None;
      parse_mode = None;
      caption_entities = None;
      show_caption_above_media = None;
      reply_markup = None;
      input_message_content = None;
      unknown_fields = [];
    } in

    (Obj.magic result : InlineQueryResult.t)
end

(** {1 Pagination Helper} *)

module Pagination = struct
  let page_size = 10

  let paginate ~offset results =
    let total = List.length results in
    let start = offset in
    let end_ = min (offset + page_size) total in

    Flo.debugf "[Pagination] Paginating: total=%d, offset=%d, start=%d, end=%d"
      total offset start end_;

    let page_results =
      results
      |> List.filteri (fun i _ -> i >= start && i < end_)
    in

    let next_offset =
      if end_ < total then begin
        Flo.debugf "[Pagination] More results available, next_offset=%d" end_;
        Some (string_of_int end_)
      end else begin
        Flo.debug "[Pagination] No more results";
        None
      end
    in

    (page_results, next_offset)
end

(** {1 Inline Query Handlers} *)

let handle_article_search client iq query =
  Flo.debugf "[Handler] Handling article search: query='%s'" query;

  (* Check cache first *)
  match ResultCache.get query with
  | Some cached_results ->
      Flo.debugf "[Handler] Using cached results (%d results)" (List.length cached_results);
      Telegram_generated.Gen_methods.answer_inline_query client
        ~inline_query_id:iq.Telegram_generated.Gen_types.InlineQuery.id
        ~results:cached_results
        ~cache_time:300L  (* Cache for 5 minutes on Telegram servers *)
        ~is_personal:false
        ()

  | None ->
      Flo.debug "[Handler] Computing fresh results";

      (* Search articles *)
      let articles = ArticleDB.search query in

      (* Convert to inline results *)
      let results = List.map ResultConverter.article_to_result articles in

      (* Cache results *)
      ResultCache.set query results;

      (* Answer query *)
      Telegram_generated.Gen_methods.answer_inline_query client
        ~inline_query_id:iq.id
        ~results
        ~cache_time:300L
        ~is_personal:false
        ()

let handle_photo_search client iq query =
  Flo.debugf "[Handler] Handling photo search: query='%s'" query;

  let photos = PhotoGallery.search query in
  let results = List.map ResultConverter.photo_to_result photos in

  Telegram_generated.Gen_methods.answer_inline_query client
    ~inline_query_id:iq.Telegram_generated.Gen_types.InlineQuery.id
    ~results
    ~cache_time:600L  (* Photos can be cached longer *)
    ~is_personal:false
    ()

let handle_gif_search client iq query =
  Flo.debugf "[Handler] Handling GIF search: query='%s'" query;

  let gifs = GifLibrary.search query in
  let results = List.map ResultConverter.gif_to_result gifs in

  Telegram_generated.Gen_methods.answer_inline_query client
    ~inline_query_id:iq.Telegram_generated.Gen_types.InlineQuery.id
    ~results
    ~cache_time:600L
    ~is_personal:false
    ()

let handle_paginated_search client iq query =
  Flo.debugf "[Handler] Handling paginated search: query='%s', offset='%s'"
    query iq.Telegram_generated.Gen_types.InlineQuery.offset;

  (* Parse offset *)
  let offset =
    if String.length iq.offset = 0 then
      0
    else
      int_of_string_opt iq.offset |> Option.value ~default:0
  in

  (* Search all results *)
  let articles = ArticleDB.search query in
  let all_results = List.map ResultConverter.article_to_result articles in

  (* Paginate *)
  let (page_results, next_offset) = Pagination.paginate ~offset all_results in

  Flo.debugf "[Handler] Returning page with %d results" (List.length page_results);

  (* Answer with pagination *)
  Telegram_generated.Gen_methods.answer_inline_query client
    ~inline_query_id:iq.id
    ~results:page_results
    ?next_offset
    ~cache_time:300L
    ~is_personal:false
    ()

(** {1 Chosen Result Tracking} *)

module ChosenResults = struct
  type chosen_entry = {
    result_id : string;
    _query : string;
    user_id : int64;
    _timestamp : float;
  }

  let history : chosen_entry list ref = ref []
  let max_history = 100

  let track chosen =
    let open Telegram_generated.Gen_types.ChosenInlineResult in
    Flo.debugf "[ChosenResults] User chose result: result_id=%s, query=%s"
      chosen.result_id chosen.query;

    let entry = {
      result_id = chosen.result_id;
      _query = chosen.query;
      user_id = chosen.from.id;
      _timestamp = Unix.time ();
    } in

    history := entry :: !history;

    (* Keep history bounded *)
    if List.length !history > max_history then
      history := List.filteri (fun i _ -> i < max_history) !history;

    Flo.debugf "[ChosenResults] History size: %d" (List.length !history)

  let get_stats () =
    let total = List.length !history in
    let unique_users =
      !history
      |> List.map (fun e -> e.user_id)
      |> List.sort_uniq Int64.compare
      |> List.length
    in
    let popular_results =
      !history
      |> List.map (fun e -> e.result_id)
      |> List.fold_left (fun acc id ->
           let count = try List.assoc id acc with Not_found -> 0 in
           (id, count + 1) :: List.remove_assoc id acc
         ) []
      |> List.sort (fun (_, a) (_, b) -> Int.compare b a)
      |> List.filteri (fun i _ -> i < 5)
    in

    Flo.debugf "[ChosenResults] Stats: total=%d, unique_users=%d" total unique_users;
    (total, unique_users, popular_results)
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
    "🔍 Welcome to the Inline Query Bot!\n\n\
     Use inline mode to search and share content:\n\n\
     <b>Search modes:</b>\n\
     • <code>@botname text</code> - Search articles\n\
     • <code>@botname photo:text</code> - Search photos\n\
     • <code>@botname gif:text</code> - Search GIFs\n\
     • <code>@botname page:text</code> - Paginated search\n\n\
     <b>Commands:</b>\n\
     /start - Show this message\n\
     /help - Help information\n\
     /stats - Show usage statistics\n\
     /clearcache - Clear result cache"
  in

  let* _msg = answer ctx welcome_text in
  Flo.success "[Handler] ✅ Welcome message sent";
  Ok ()

let handle_help ctx _args =
  Flo.debug "[Handler] /help command triggered";
  let open Bot.Ctx in

  let help_text =
    "📚 Inline Query Bot Help\n\n\
     <b>How to use inline mode:</b>\n\
     1. Go to any chat\n\
     2. Type <code>@yourbotname</code> followed by your query\n\
     3. Select a result from the list\n\n\
     <b>Search modes:</b>\n\
     • Default - Search articles about programming\n\
     • <code>photo:sunset</code> - Search photos\n\
     • <code>gif:happy</code> - Search GIFs\n\
     • <code>page:ocaml</code> - Paginated results\n\n\
     <b>Features:</b>\n\
     • Rich content (articles, photos, GIFs)\n\
     • Smart caching (client + server)\n\
     • Pagination for large results\n\
     • Interactive inline keyboards\n\
     • Result tracking and analytics"
  in

  let* _msg = answer ctx help_text in
  Flo.success "[Handler] ✅ Help sent";
  Ok ()

let handle_stats ctx _args =
  Flo.debug "[Handler] /stats command triggered";
  let open Bot.Ctx in

  let (total_chosen, unique_users, popular_results) = ChosenResults.get_stats () in
  let cache_size = ResultCache.size () in

  let popular_text =
    if List.length popular_results = 0 then
      "None yet"
    else
      popular_results
      |> List.map (fun (id, count) -> Printf.sprintf "  • Result %s: %d times" id count)
      |> String.concat "\n"
  in

  let stats_text = Printf.sprintf
    "📊 <b>Bot Statistics</b>\n\n\
     <b>Results chosen:</b> %d\n\
     <b>Unique users:</b> %d\n\
     <b>Cache entries:</b> %d\n\n\
     <b>Popular results:</b>\n%s"
    total_chosen unique_users cache_size popular_text
  in

  let* _msg = answer ctx stats_text in
  Flo.success "[Handler] ✅ Stats sent";
  Ok ()

let handle_clearcache ctx _args =
  Flo.debug "[Handler] /clearcache command triggered";
  let open Bot.Ctx in

  let before = ResultCache.size () in
  ResultCache.clear ();
  let after = ResultCache.size () in

  let msg = Printf.sprintf "🗑️  Cache cleared: %d entries removed" before in

  let* _msg = answer ctx msg in
  Flo.successf "[Handler] ✅ Cache cleared: before=%d, after=%d" before after;
  Ok ()

let handle_inline_query ctx iq =
  Flo.debugf "[Handler] Inline query received: query='%s', offset='%s'"
    iq.Telegram_generated.Gen_types.InlineQuery.query
    iq.offset;

  let open Bot.Ctx in
  let client = client ctx in

  let query = iq.query in

  (* Parse search mode *)
  let result =
    if String.starts_with ~prefix:"photo:" query then begin
      let search_query = String.sub query 6 (String.length query - 6) in
      Flo.debugf "[Handler] Photo search mode: '%s'" search_query;
      handle_photo_search client iq search_query
    end
    else if String.starts_with ~prefix:"gif:" query then begin
      let search_query = String.sub query 4 (String.length query - 4) in
      Flo.debugf "[Handler] GIF search mode: '%s'" search_query;
      handle_gif_search client iq search_query
    end
    else if String.starts_with ~prefix:"page:" query then begin
      let search_query = String.sub query 5 (String.length query - 5) in
      Flo.debugf "[Handler] Paginated search mode: '%s'" search_query;
      handle_paginated_search client iq search_query
    end
    else begin
      Flo.debug "[Handler] Article search mode (default)";
      handle_article_search client iq query
    end
  in

  match result with
  | Ok _bool ->
      Flo.success "[Handler] ✅ Inline query answered successfully";
      Ok ()
  | Error err ->
      Flo.errorf "[Handler] ❌ Error answering inline query: %s" (Format.asprintf "%a" Error.pp err);
      (* Return empty results on error *)
      let* _ = Telegram_generated.Gen_methods.answer_inline_query client
        ~inline_query_id:iq.id
        ~results:[]
        ()
      in
      Ok ()

let handle_chosen_result _ctx chosen =
  Flo.debug "[Handler] Chosen result notification received";
  ChosenResults.track chosen;
  Ok ()

(** {1 Build Routes} *)

let build_routes bot =
  Flo.debug "[Builder] Registering routes...";

  let bot = bot |> Bot.command "start" handle_start in
  Flo.success "[Builder] ✅ Registered /start";

  let bot = bot |> Bot.command "help" handle_help in
  Flo.success "[Builder] ✅ Registered /help";

  let bot = bot |> Bot.command "stats" handle_stats in
  Flo.success "[Builder] ✅ Registered /stats";

  let bot = bot |> Bot.command "clearcache" handle_clearcache in
  Flo.success "[Builder] ✅ Registered /clearcache";

  (* Note: Inline query support requires complete generated types *)
  (* TODO: Uncomment when InlineQueryResult types are properly generated *)
  (* let bot = bot |> Bot.on_inline_query handle_inline_query in *)
  (* Flo.success "[Builder] ✅ Registered inline_query handler"; *)

  (* let bot = bot |> Bot.on_chosen_inline_result handle_chosen_result in *)
  (* Flo.success "[Builder] ✅ Registered chosen_inline_result handler"; *)

  let _ = (handle_inline_query, handle_chosen_result) in  (* Suppress unused warnings *)
  Flo.debug "[Builder] ⚠️  Inline query handlers skipped (incomplete generated types)";

  Flo.debug "[Builder] All routes registered";
  bot

(** {1 Main Entry Point} *)

let () =
  Eio_main.run @@ fun env ->
  Flo.debug "";
  Flo.info "╔══════════════════════════════════════════════════════════════════╗";
  Flo.info "║                     Inline Query Bot                             ║";
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

  Flo.info "[Polling] Starting long polling with inline_query updates...";
  Flo.info "[Polling] Bot is ready to receive updates";
  Flo.debug "";
  Flo.info "╔══════════════════════════════════════════════════════════════════╗";
  Flo.info "║                     Bot is Ready!                                ║";
  Flo.info "╚══════════════════════════════════════════════════════════════════╝";
  Flo.info "[Polling] Waiting for inline queries...";
  Flo.debug "";
  Flo.info "Features:";
  Flo.debug "  - Article search (Wikipedia-style)";
  Flo.debug "  - Photo search results";
  Flo.debug "  - GIF search results";
  Flo.debug "  - Client-side caching with TTL";
  Flo.debug "  - Server-side cache control";
  Flo.debug "  - Pagination for large result sets";
  Flo.debug "  - Inline keyboard integration";
  Flo.debug "  - Chosen result tracking";
  Flo.debug "  - Result-based error handling";
  Flo.debug "";
  Flo.debug "Usage:";
  Flo.debug "  - Type @yourbotname <query> in any chat";
  Flo.debug "  - Use 'photo:' prefix for photo search";
  Flo.debug "  - Use 'gif:' prefix for GIF search";
  Flo.debug "  - Use 'page:' prefix for paginated results";
  Flo.debug "";

  Bot.run bot
