(* Concurrency tests for Eio switches: cancellation, timeout, and shutdown behavior *)

open Eio.Std

(* Cancellation tests *)

let test_switch_cancellation () =
  Eio_main.run @@ fun _env ->
  let cleanup_called = ref false in
  let completed = ref false in

  (Eio.Switch.run @@ fun sw ->
    Eio.Switch.on_release sw (fun () -> cleanup_called := true);
    Eio.Fiber.fork ~sw (fun () ->
      completed := true
    )
  );

  (* Verify cleanup was called when switch completes normally *)
  Alcotest.(check bool) "cleanup called" true !cleanup_called;
  Alcotest.(check bool) "fiber completed" true !completed

let test_explicit_cancellation () =
  Eio_main.run @@ fun _env ->
  let completed = ref false in
  let cancelled = ref false in

  try
    Eio.Switch.run @@ fun sw ->
      Eio.Switch.on_release sw (fun () -> cancelled := true);
      Eio.Fiber.fork ~sw (fun () ->
        Eio.Fiber.yield ();
        Eio.Fiber.yield ();
        completed := true
      );
      (* Explicit cancellation via exception *)
      failwith "cancelled"
  with
  | Failure _ ->
      Alcotest.(check bool) "cancelled flag set" true !cancelled;
      Alcotest.(check bool) "operation not completed" false !completed

let test_nested_switch_cancellation () =
  Eio_main.run @@ fun _env ->
  let outer_cleanup = ref false in
  let inner_cleanup = ref false in

  (Eio.Switch.run @@ fun outer_sw ->
    Eio.Switch.on_release outer_sw (fun () -> outer_cleanup := true);

    Eio.Fiber.fork ~sw:outer_sw (fun () ->
      Eio.Switch.run @@ fun inner_sw ->
        Eio.Switch.on_release inner_sw (fun () -> inner_cleanup := true)
    )
  );

  Alcotest.(check bool) "outer switch cleanup called" true !outer_cleanup;
  Alcotest.(check bool) "inner switch cleanup called" true !inner_cleanup

(* Timeout tests *)

let test_timeout_expires () =
  Eio_main.run @@ fun env ->
  let result = ref None in

  try
    Eio.Time.with_timeout_exn env#clock 0.01 (fun () ->
      (* Sleep longer than timeout *)
      Eio.Time.sleep env#clock 1.0;
      result := Some "completed"
    )
  with
  | Eio.Time.Timeout ->
      Alcotest.(check (option string)) "timeout occurred" None !result

let test_timeout_completes_in_time () =
  Eio_main.run @@ fun env ->
  let result = ref None in

  Eio.Time.with_timeout_exn env#clock 1.0 (fun () ->
    Eio.Time.sleep env#clock 0.01;
    result := Some "completed"
  );

  Alcotest.(check (option string)) "operation completed" (Some "completed") !result

let test_nested_timeouts () =
  Eio_main.run @@ fun env ->
  let result = ref None in

  try
    Eio.Time.with_timeout_exn env#clock 1.0 (fun () ->
      try
        Eio.Time.with_timeout_exn env#clock 0.01 (fun () ->
          Eio.Time.sleep env#clock 0.5;
          result := Some "inner"
        )
      with
      | Eio.Time.Timeout ->
          result := Some "inner_timeout"
    )
  with
  | Eio.Time.Timeout ->
      result := Some "outer_timeout"
  ;

  Alcotest.(check (option string)) "inner timeout triggered" (Some "inner_timeout") !result

(* Shutdown behavior tests *)

let test_clean_shutdown () =
  Eio_main.run @@ fun _env ->
  let cleanup_count = ref 0 in

  (Eio.Switch.run @@ fun sw ->
    Eio.Switch.on_release sw (fun () -> incr cleanup_count);
    Eio.Switch.on_release sw (fun () -> incr cleanup_count);
    Eio.Switch.on_release sw (fun () -> incr cleanup_count)
  );

  Alcotest.(check int) "all cleanup handlers called" 3 !cleanup_count

let test_shutdown_order () =
  Eio_main.run @@ fun _env ->
  let order = ref [] in

  (Eio.Switch.run @@ fun sw ->
    Eio.Switch.on_release sw (fun () -> order := "first" :: !order);
    Eio.Switch.on_release sw (fun () -> order := "second" :: !order);
    Eio.Switch.on_release sw (fun () -> order := "third" :: !order)
  );

  (* Cleanup handlers run in FIFO order (same order as registration) *)
  Alcotest.(check (list string)) "cleanup FIFO order" ["first"; "second"; "third"] !order

let test_fiber_coordination () =
  Eio_main.run @@ fun _env ->
  let results = ref [] in

  (Eio.Switch.run @@ fun sw ->
    Eio.Fiber.fork ~sw (fun () ->
      results := "fiber1" :: !results
    );

    Eio.Fiber.fork ~sw (fun () ->
      results := "fiber2" :: !results
    );

    Eio.Fiber.fork ~sw (fun () ->
      results := "fiber3" :: !results
    )
  );

  (* All fibers should complete *)
  Alcotest.(check int) "all fibers completed" 3 (List.length !results)

let test_promise_resolution () =
  Eio_main.run @@ fun _env ->
  let p, r = Promise.create () in

  Eio.Switch.run @@ fun sw ->
    Eio.Fiber.fork ~sw (fun () ->
      Eio.Fiber.yield ();
      Promise.resolve r "result"
    );

    let result = Promise.await p in
    Alcotest.(check string) "promise resolved" "result" result

let test_promise_cancellation () =
  Eio_main.run @@ fun _env ->
  let p, _r = Promise.create () in
  let result = ref None in
  let cleanup_called = ref false in

  try
    Eio.Switch.run @@ fun sw ->
      Eio.Switch.on_release sw (fun () -> cleanup_called := true);
      Eio.Fiber.fork ~sw (fun () ->
        try
          result := Some (Promise.await p)
        with
        | _ -> ()  (* Promise await was cancelled *)
      );
      (* Cancel by raising exception *)
      Eio.Fiber.yield ();
      failwith "cancel"
  with
  | Failure _ -> ()
  ;

  Alcotest.(check (option string)) "promise not resolved" None !result;
  Alcotest.(check bool) "cleanup was called" true !cleanup_called

let test_concurrent_operations () =
  Eio_main.run @@ fun _env ->
  let counter = ref 0 in
  let mutex = Eio.Mutex.create () in

  (Eio.Switch.run @@ fun sw ->
    for _i = 1 to 10 do
      Eio.Fiber.fork ~sw (fun () ->
        for _j = 1 to 100 do
          Eio.Mutex.use_rw mutex ~protect:false (fun () ->
            incr counter
          )
        done
      )
    done
  );

  Alcotest.(check int) "counter incremented correctly" 1000 !counter

(* Resource cleanup tests *)

let test_exception_triggers_cleanup () =
  Eio_main.run @@ fun _env ->
  let cleanup_called = ref false in

  try
    Eio.Switch.run @@ fun sw ->
      Eio.Switch.on_release sw (fun () -> cleanup_called := true);
      failwith "test exception"
  with
  | Failure _ ->
      Alcotest.(check bool) "cleanup called on exception" true !cleanup_called

let test_multiple_fibers_cleanup () =
  Eio_main.run @@ fun _env ->
  let cleanup_count = ref 0 in

  (Eio.Switch.run @@ fun sw ->
    for _i = 1 to 5 do
      Eio.Switch.on_release sw (fun () -> incr cleanup_count);
      Eio.Fiber.fork ~sw (fun () ->
        ()
      )
    done
  );

  Alcotest.(check int) "all fiber cleanups called" 5 !cleanup_count

(* Test suite *)

let () =
  let open Alcotest in
  run "Concurrency tests (Eio)" [
    "cancellation", [
      test_case "switch_cancellation" `Quick test_switch_cancellation;
      test_case "explicit_cancellation" `Quick test_explicit_cancellation;
      test_case "nested_switch_cancellation" `Quick test_nested_switch_cancellation;
    ];
    "timeout", [
      test_case "timeout_expires" `Quick test_timeout_expires;
      test_case "timeout_completes_in_time" `Quick test_timeout_completes_in_time;
      test_case "nested_timeouts" `Quick test_nested_timeouts;
    ];
    "shutdown", [
      test_case "clean_shutdown" `Quick test_clean_shutdown;
      test_case "shutdown_order" `Quick test_shutdown_order;
      test_case "fiber_coordination" `Quick test_fiber_coordination;
      test_case "promise_resolution" `Quick test_promise_resolution;
      test_case "promise_cancellation" `Quick test_promise_cancellation;
      test_case "concurrent_operations" `Quick test_concurrent_operations;
    ];
    "cleanup", [
      test_case "exception_triggers_cleanup" `Quick test_exception_triggers_cleanup;
      test_case "multiple_fibers_cleanup" `Quick test_multiple_fibers_cleanup;
    ];
  ]
