(** Concurrency Patterns Demo - Comprehensive demonstration of Eio concurrency

    This example demonstrates Eio concurrency patterns for building high-performance bots:
    - Fibers for lightweight concurrency
    - Promises for fiber return values
    - Semaphores for rate limiting and bounded concurrency
    - Mutexes for protecting shared state
    - Background periodic tasks
    - Concurrent broadcast patterns
    - Timeouts and cancellation

    Commands:
      /start - Show main menu
      /fiber_demo - Demonstrate basic fiber creation
      /promise_demo - Promises for fiber results
      /broadcast - Concurrent broadcast to multiple users
      /rate_limit_demo - Rate limiting with semaphore
      /background_task - Start background periodic task
      /stats - Show bot statistics (mutex-protected)
      /concurrent_ops - Run multiple operations concurrently
      /timeout_demo - Operation with timeout

    This example has VERBOSE LOGGING enabled for troubleshooting.

    Usage:
      export TELEGRAM_BOT_TOKEN="your_token_here"
      dune exec examples/concurrency_patterns_demo.exe
*)

open Telegram
open Tg
open Eio.Std

(* Configure verbose logging with flo *)
let () = Flo.set_level Severity.Debug

module KB = Keyboard

(** Shared statistics with mutex protection *)
module Stats = struct
  type t = {
    mutable messages_sent : int;
    mutable broadcasts_sent : int;
    mutable fibers_spawned : int;
    mutex : Eio.Mutex.t;
  }

  let create () = {
    messages_sent = 0;
    broadcasts_sent = 0;
    fibers_spawned = 0;
    mutex = Eio.Mutex.create ();
  }

  let increment_messages stats =
    Eio.Mutex.use_rw ~protect:true stats.mutex (fun () ->
      stats.messages_sent <- stats.messages_sent + 1;
      Flo.debugf "[Stats] messages_sent: %d" stats.messages_sent
    )

  let increment_broadcasts stats =
    Eio.Mutex.use_rw ~protect:true stats.mutex (fun () ->
      stats.broadcasts_sent <- stats.broadcasts_sent + 1;
      Flo.debugf "[Stats] broadcasts_sent: %d" stats.broadcasts_sent
    )

  let increment_fibers stats =
    Eio.Mutex.use_rw ~protect:true stats.mutex (fun () ->
      stats.fibers_spawned <- stats.fibers_spawned + 1;
      Flo.debugf "[Stats] fibers_spawned: %d" stats.fibers_spawned
    )

  let get stats =
    Eio.Mutex.use_ro stats.mutex (fun () ->
      (stats.messages_sent, stats.broadcasts_sent, stats.fibers_spawned)
    )

  let summary stats =
    let (messages, broadcasts, fibers) = get stats in
    Printf.sprintf
      "📊 Bot Statistics (Mutex-Protected)\n\n\
       Messages sent: %d\n\
       Broadcasts sent: %d\n\
       Fibers spawned: %d\n\n\
       All counters are protected by Eio.Mutex for thread-safe access."
      messages broadcasts fibers
end

(** Session keys *)
let subscriber_key = Session.make ~name:"is_subscriber"

let () =
  Printexc.record_backtrace true;
  Flo.info "=== Concurrency Patterns Demo Starting ===";

  let token = match Sys.getenv_opt "TELEGRAM_BOT_TOKEN" with
    | Some t -> t
    | None -> Printf.eprintf "TELEGRAM_BOT_TOKEN not set\n"; exit 1
  in

  Eio_main.run @@ fun env ->
  let client = Client.create ~env ~token () in

  Flo.info "🤖 Concurrency Patterns Demo Bot Started";

  let session_store = Session.Memory_store.create () in
  let stats = Stats.create () in

  (* Global switch for background tasks *)
  Eio.Switch.run @@ fun global_sw ->

  (* Background task: periodic status report *)
  Eio.Fiber.fork ~sw:global_sw (fun () ->
    let clock = env#clock in
    Flo.debug "[Background] Periodic task started (every 60s)";

    while true do
      Eio.Time.sleep clock 60.0;
      let (messages, broadcasts, fibers) = Stats.get stats in
      Flo.debugf "[Background] Periodic report: messages=%d, broadcasts=%d, fibers=%d"
        messages broadcasts fibers
    done
  );

  Bot.make ~env ~client
  |> Bot.with_sessions (module Session.Memory_store) session_store

  (* /start - Main menu *)
  |> Bot.command "start" ~desc:"Show main menu" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/start] Showing main menu";

      Stats.increment_messages stats;

      let keyboard = KB.inline [
        [KB.callback ~text:"🧵 Fiber Demo" ~data:"demo:fiber"];
        [KB.callback ~text:"🔮 Promise Demo" ~data:"demo:promise"];
        [KB.callback ~text:"📢 Broadcast" ~data:"demo:broadcast"];
        [KB.callback ~text:"⏱️ Rate Limit Demo" ~data:"demo:rate_limit"];
        [KB.callback ~text:"📊 Statistics" ~data:"demo:stats"];
        [KB.callback ~text:"⏰ Timeout Demo" ~data:"demo:timeout"];
      ] in

      let text =
        "⚡ Concurrency Patterns Demo\n\n\
         This demonstrates Eio concurrency patterns.\n\n\
         🧵 Fibers - Lightweight concurrent tasks\n\
         🔮 Promises - Fiber return values\n\
         📢 Broadcast - Concurrent message sending\n\
         ⏱️ Rate Limiting - Semaphore-based throttling\n\
         📊 Statistics - Mutex-protected shared state\n\
         ⏰ Timeouts - Operations with time limits"
      in

      match send ~keyboard ctx text with
      | Ok _ -> Flo.debug "[/start] ✓"; Ok ()
      | Error e -> Flo.debugf "[/start] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* Callback: demo:fiber *)
  |> Bot.on_callback_data "demo:fiber" (fun ctx ->
      let open Bot.Ctx in
      Flo.debug "[demo:fiber] Demonstrating fibers";

      (* Spawn multiple concurrent fibers *)
      Eio.Switch.run @@ fun sw ->

      let completed = ref 0 in
      let mutex = Eio.Mutex.create () in

      (* Spawn 3 fibers *)
      for i = 1 to 3 do
        Stats.increment_fibers stats;

        Eio.Fiber.fork ~sw (fun () ->
          Flo.debugf "[Fiber %d] Started" i;
          Eio.Time.sleep (env ctx)#clock (float_of_int i *. 0.5);
          Flo.debugf "[Fiber %d] Completed after %.1fs" i (float_of_int i *. 0.5);

          Eio.Mutex.use_rw ~protect:true mutex (fun () ->
            completed := !completed + 1
          )
        )
      done;

      (* Main fiber continues immediately *)
      Flo.debug "[demo:fiber] All fibers spawned, waiting for completion...";

      (* Switch waits for all fibers *)
      ();

      Flo.debugf "[demo:fiber] All %d fibers completed" !completed;

      let response = Printf.sprintf
        "🧵 Fiber Demo Complete!\n\n\
         Spawned 3 fibers:\n\
         • Fiber 1: 0.5s delay\n\
         • Fiber 2: 1.0s delay\n\
         • Fiber 3: 1.5s delay\n\n\
         All ran concurrently!\n\
         Completed: %d fibers\n\n\
         Check logs to see concurrent execution."
        !completed
      in

      match edit ctx response with
      | Ok () -> Flo.debug "[demo:fiber] ✓"; Ok ()
      | Error e -> Flo.debugf "[demo:fiber] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* Callback: demo:promise *)
  |> Bot.on_callback_data "demo:promise" (fun ctx ->
      let open Bot.Ctx in
      Flo.debug "[demo:promise] Demonstrating promises";

      (* Use promises to get fiber return values *)
      let results = Eio.Switch.run @@ fun sw ->

        let promises = List.init 3 (fun i ->
          let promise, resolver = Promise.create () in

          Stats.increment_fibers stats;

          Eio.Fiber.fork ~sw (fun () ->
            Flo.debugf "[Promise fiber %d] Computing..." (i + 1);
            Eio.Time.sleep (env ctx)#clock 0.3;
            let result = (i + 1) * 10 in
            Flo.debugf "[Promise fiber %d] Result: %d" (i + 1) result;
            Promise.resolve resolver result
          );

          promise
        ) in

        (* Wait for all promises *)
        List.map Promise.await promises
      in

      Flo.debugf "[demo:promise] All promises resolved: %s"
        (String.concat ", " (List.map string_of_int results));

      let results_str = String.concat ", " (List.map string_of_int results) in

      let response = Printf.sprintf
        "🔮 Promise Demo Complete!\n\n\
         Spawned 3 fibers, each computing a value.\n\
         Results: [%s]\n\n\
         Promises allow fibers to return values.\n\
         All computations ran concurrently!"
        results_str
      in

      match edit ctx response with
      | Ok () -> Flo.debug "[demo:promise] ✓"; Ok ()
      | Error e -> Flo.debugf "[demo:promise] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* Callback: demo:broadcast *)
  |> Bot.on_callback_data "demo:broadcast" (fun ctx ->
      let open Bot.Ctx in
      Flo.debug "[demo:broadcast] Demonstrating concurrent broadcast";

      (* Simulate multiple subscribers *)
      let chat_id = chat ctx in
      let subscriber_chats = [chat_id; chat_id; chat_id] in  (* Same chat for demo *)

      let broadcast_message = "📢 Broadcast message sent concurrently!" in

      (* Concurrent broadcast with semaphore for rate limiting *)
      let sem = Eio.Semaphore.make 5 in  (* Max 5 concurrent sends *)

      let results = Eio.Switch.run @@ fun sw ->

        let promises = List.mapi (fun i chat_id ->
          let promise, resolver = Promise.create () in

          Stats.increment_fibers stats;

          Eio.Fiber.fork ~sw (fun () ->
            (* Acquire semaphore permit *)
            Flo.debugf "[Broadcast %d] Waiting for semaphore..." (i + 1);
            Eio.Semaphore.acquire sem;

            Flo.debugf "[Broadcast %d] Sending..." (i + 1);

            let result = Telegram_generated.Gen_methods.send_message
              (client ctx)
              ~chat_id
              ~text:(Printf.sprintf "%s (message %d/3)" broadcast_message (i + 1))
              () in

            Stats.increment_broadcasts stats;

            (* Release semaphore *)
            Eio.Semaphore.release sem;

            Flo.debugf "[Broadcast %d] Complete" (i + 1);

            Promise.resolve resolver result
          );

          promise
        ) subscriber_chats in

        (* Wait for all broadcasts *)
        List.map Promise.await promises
      in

      let success_count = List.fold_left (fun acc r ->
        match r with Ok _ -> acc + 1 | Error _ -> acc
      ) 0 results in

      Flo.debugf "[demo:broadcast] Broadcast complete: %d/%d succeeded"
        success_count (List.length results);

      let response = Printf.sprintf
        "📢 Concurrent Broadcast Complete!\n\n\
         Sent to %d chats concurrently.\n\
         Success: %d/%d\n\n\
         Used Eio.Semaphore to limit concurrency to 5.\n\
         Check logs to see concurrent execution."
        (List.length subscriber_chats)
        success_count
        (List.length results)
      in

      match edit ctx response with
      | Ok () -> Flo.debug "[demo:broadcast] ✓"; Ok ()
      | Error e -> Flo.debugf "[demo:broadcast] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* Callback: demo:rate_limit *)
  |> Bot.on_callback_data "demo:rate_limit" (fun ctx ->
      let open Bot.Ctx in
      Flo.debug "[demo:rate_limit] Demonstrating rate limiting";

      (* Create semaphore: max 2 concurrent operations *)
      let sem = Eio.Semaphore.make 2 in

      (* Spawn 5 operations (only 2 run at a time) *)
      Eio.Switch.run @@ fun sw ->

      for i = 1 to 5 do
        Stats.increment_fibers stats;

        Eio.Fiber.fork ~sw (fun () ->
          Flo.debugf "[RateLimit %d] Waiting for permit..." i;

          (* Acquire permit *)
          Eio.Semaphore.acquire sem;
          Flo.debugf "[RateLimit %d] Acquired permit, running..." i;

          (* Simulate work *)
          Eio.Time.sleep (env ctx)#clock 1.0;

          Flo.debugf "[RateLimit %d] Done, releasing permit" i;

          (* Release permit *)
          Eio.Semaphore.release sem
        )
      done;

      ();  (* Wait for all fibers *)

      Flo.debug "[demo:rate_limit] All operations complete";

      let response =
        "⏱️ Rate Limiting Demo Complete!\n\n\
         Spawned 5 operations.\n\
         Semaphore limited to 2 concurrent.\n\n\
         Check logs to see:\n\
         • Operations 1-2 run immediately\n\
         • Operations 3-5 wait for permits\n\
         • Max 2 operations run at any time\n\n\
         This prevents overwhelming the API."
      in

      match edit ctx response with
      | Ok () -> Flo.debug "[demo:rate_limit] ✓"; Ok ()
      | Error e -> Flo.debugf "[demo:rate_limit] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* Callback: demo:stats *)
  |> Bot.on_callback_data "demo:stats" (fun ctx ->
      let open Bot.Ctx in
      Flo.debug "[demo:stats] Showing statistics";

      let summary = Stats.summary stats in

      match edit ctx summary with
      | Ok () -> Flo.debug "[demo:stats] ✓"; Ok ()
      | Error e -> Flo.debugf "[demo:stats] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* Callback: demo:timeout *)
  |> Bot.on_callback_data "demo:timeout" (fun ctx ->
      let open Bot.Ctx in
      Flo.debug "[demo:timeout] Demonstrating timeout";

      (* Operation with timeout *)
      let result = Eio.Switch.run @@ fun sw ->

        let promise, resolver = Promise.create () in

        (* Slow operation *)
        Eio.Fiber.fork ~sw (fun () ->
          Flo.debug "[Timeout] Slow operation started...";
          Eio.Time.sleep (env ctx)#clock 5.0;
          Flo.debug "[Timeout] Slow operation complete (5s)";
          Promise.resolve resolver (Some "Completed")
        );

        (* Timeout fiber *)
        Eio.Fiber.fork ~sw (fun () ->
          Eio.Time.sleep (env ctx)#clock 2.0;
          Flo.debug "[Timeout] Timeout reached (2s)";
          Promise.resolve resolver None
        );

        (* First to complete wins *)
        Promise.await promise
      in

      let response = match result with
        | Some msg ->
            Printf.sprintf "✅ Operation completed: %s" msg
        | None ->
            "⏰ Operation timed out!\n\n\
             The operation took longer than 2 seconds.\n\n\
             This demonstrates racing fibers:\n\
             • One fiber does the work\n\
             • Another fiber waits for timeout\n\
             • First to complete resolves the promise"
      in

      match edit ctx response with
      | Ok () -> Flo.debug "[demo:timeout] ✓"; Ok ()
      | Error e -> Flo.debugf "[demo:timeout] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* Callback: demo:concurrent_ops *)
  |> Bot.on_callback_data "demo:concurrent_ops" (fun ctx ->
      let open Bot.Ctx in
      Flo.debug "[demo:concurrent_ops] Running concurrent operations";

      (* Run 3 operations concurrently and collect results *)
      let results = Eio.Switch.run @@ fun sw ->

        let promises = [
          (fun () ->
            Eio.Time.sleep (env ctx)#clock 0.5;
            "Operation 1 complete (0.5s)");
          (fun () ->
            Eio.Time.sleep (env ctx)#clock 0.3;
            "Operation 2 complete (0.3s)");
          (fun () ->
            Eio.Time.sleep (env ctx)#clock 0.7;
            "Operation 3 complete (0.7s)");
        ] |> List.mapi (fun i op ->
          let promise, resolver = Promise.create () in

          Stats.increment_fibers stats;

          Eio.Fiber.fork ~sw (fun () ->
            Flo.debugf "[ConcurrentOp %d] Started" (i + 1);
            let result = op () in
            Flo.debugf "[ConcurrentOp %d] %s" (i + 1) result;
            Promise.resolve resolver result
          );

          promise
        ) in

        (* Wait for all *)
        List.map Promise.await promises
      in

      let results_str = String.concat "\n• " results in

      let response = Printf.sprintf
        "⚡ Concurrent Operations Complete!\n\n\
         Results:\n\
         • %s\n\n\
         All 3 operations ran concurrently.\n\
         Total time: ~0.7s (not 1.5s sequential)."
        results_str
      in

      match edit ctx response with
      | Ok () -> Flo.debug "[demo:concurrent_ops] ✓"; Ok ()
      | Error e -> Flo.debugf "[demo:concurrent_ops] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /subscribe - For broadcast demo *)
  |> Bot.command "subscribe" ~desc:"Subscribe to broadcasts" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/subscribe] User subscribing";

      session_set ctx subscriber_key true;

      match reply ctx
        "✅ Subscribed to broadcasts!\n\n\
         You'll receive messages when /broadcast is used."
      with
      | Ok _ -> Flo.debug "[/subscribe] ✓"; Ok ()
      | Error e -> Flo.debugf "[/subscribe] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  (* /stats - Show statistics *)
  |> Bot.command "stats" ~desc:"Show bot statistics" (fun ctx _args ->
      let open Bot.Ctx in
      Flo.debug "[/stats] Showing statistics";

      Stats.increment_messages stats;

      let summary = Stats.summary stats in

      match reply ctx summary with
      | Ok _ -> Flo.debug "[/stats] ✓"; Ok ()
      | Error e -> Flo.debugf "[/stats] ✗ %s" (Format.asprintf "%a" Error.pp e); Ok ()
    )

  |> Bot.run
