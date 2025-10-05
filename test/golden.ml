(* Golden tests for generated code.

   These tests ensure that regenerating from reference/api.html produces
   identical output, protecting against unintended changes.

   To update golden files after intentional changes:
     dune exec test/update_golden.exe
   or:
     cp generated/*.ml* test/golden/
*)

let read_file path =
  let ic = open_in_bin path in
  Fun.protect ~finally:(fun () -> close_in_noerr ic) (fun () ->
    let len = in_channel_length ic in
    really_input_string ic len
  )

(* Dune runs tests from project root, so paths are relative to workspace root *)
let project_root =
  (* Try to find project root by looking for dune-project *)
  let rec find_root dir =
    let dune_project = Filename.concat dir "dune-project" in
    if Sys.file_exists dune_project then dir
    else
      let parent = Filename.dirname dir in
      if parent = dir then Sys.getcwd () (* reached filesystem root *)
      else find_root parent
  in
  find_root (Sys.getcwd ())

let golden_dir = Filename.concat project_root "test/golden"
let generated_dir = Filename.concat project_root "generated"

let test_file_matches name () =
  let golden_path = Filename.concat golden_dir name in
  let generated_path = Filename.concat generated_dir name in

  if not (Sys.file_exists golden_path) then
    Alcotest.failf "Golden file missing: %s\nRun: dune exec test/update_golden.exe" golden_path;

  if not (Sys.file_exists generated_path) then
    Alcotest.failf "Generated file missing: %s\nRun: ./scripts/regenerate.sh" generated_path;

  let golden_content = read_file golden_path in
  let generated_content = read_file generated_path in

  if golden_content <> generated_content then (
    (* Show diff hint *)
    let diff_cmd = Printf.sprintf "diff -u %s %s | head -50" golden_path generated_path in
    Alcotest.failf
      "Generated file differs from golden baseline for %s\n\
       To see differences: %s\n\
       To update golden (if change is intentional): dune exec test/update_golden.exe"
      name diff_cmd
  );

  (* Files match - test passes *)
  Alcotest.(check bool) (name ^ " matches golden") true true

let () =
  let open Alcotest in
  run "Golden tests" [
    "generated_types", [
      test_case "gen_types.ml matches golden" `Quick (test_file_matches "gen_types.ml");
      test_case "gen_types.mli matches golden" `Quick (test_file_matches "gen_types.mli");
    ];
    "generated_methods", [
      test_case "gen_methods.ml matches golden" `Quick (test_file_matches "gen_methods.ml");
    ];
  ]
