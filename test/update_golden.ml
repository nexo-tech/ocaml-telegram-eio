(* Utility to update golden test baselines.

   Run this after intentionally changing the generator or spec:
     dune exec test/update_golden.exe

   This copies generated/*.ml* to test/golden/ for new baselines.
*)

let copy_file src dst =
  let ic = open_in_bin src in
  Fun.protect ~finally:(fun () -> close_in_noerr ic) (fun () ->
    let oc = open_out_bin dst in
    Fun.protect ~finally:(fun () -> close_out_noerr oc) (fun () ->
      let buf = Bytes.create 8192 in
      let rec loop () =
        let n = input ic buf 0 8192 in
        if n > 0 then (
          output oc buf 0 n;
          loop ()
        )
      in
      loop ()
    )
  )

let () =
  let files = [
    "gen_types.ml";
    "gen_methods.ml";
  ] in

  (* Ensure golden directory exists *)
  (try Unix.mkdir "test/golden" 0o755 with Unix.Unix_error (Unix.EEXIST, _, _) -> ());

  (* Copy each file *)
  List.iter (fun name ->
    let src = Filename.concat "generated" name in
    let dst = Filename.concat "test/golden" name in

    if not (Sys.file_exists src) then (
      Printf.eprintf "Warning: source file not found: %s\n" src;
      Printf.eprintf "Run: ./scripts/regenerate.sh\n%!";
      exit 1
    );

    Printf.printf "Updating %s -> %s\n%!" src dst;
    copy_file src dst
  ) files;

  Printf.printf "\nGolden baselines updated successfully.\n";
  Printf.printf "Run tests with: dune test\n%!"
