(* Unified generator: regenerates types (and optional method stubs) from reference/api.html. *)

let read_file path =
  let ic = open_in_bin path in
  let len = in_channel_length ic in
  let s = really_input_string ic len in
  close_in ic;
  s

let write_file path contents =
  let oc = open_out_bin path in
  output_string oc contents; close_out oc

let ensure_dir d = if Sys.file_exists d then () else Unix.mkdir d 0o755

let run_codegen_types ~in_path ~out_dir =
  let cmd = Printf.sprintf "_build/default/bin/spec_codegen_types.exe %s --out-dir %s" (Filename.quote in_path) (Filename.quote out_dir) in
  let rc = Sys.command cmd in
  if rc <> 0 then failwith ("failed running spec_codegen_types: " ^ cmd)

let run_codegen_methods ~in_path ~out_file =
  let cmd = Printf.sprintf "_build/default/bin/spec_codegen_methods.exe %s" (Filename.quote in_path) in
  let ic = Unix.open_process_in cmd in
  let buf = Buffer.create 4096 in
  (try
     while true do Buffer.add_string buf (input_line ic); Buffer.add_char buf '\n' done
   with End_of_file -> ());
  ignore (Unix.close_process_in ic);
  write_file out_file (Buffer.contents buf)

(* no cleanup pass; generator emits only valid constructs *)

let diff_strings a b =
  if String.length a = String.length b && a = b then None else Some "different"

let () =
  let args = Array.to_list Sys.argv |> List.tl in
  let in_path = ref "reference/api.html" in
  let out_dir = ref "generated" in
  let gen_methods = ref true in
  let check = ref false in
  let rec parse = function
    | [] -> ()
    | "--in" :: p :: tl -> in_path := p; parse tl
    | "--out-dir" :: d :: tl -> out_dir := d; parse tl
    | "--no-methods" :: tl -> gen_methods := false; parse tl
    | "--check" :: tl -> check := true; parse tl
    | _ :: tl -> parse tl
  in
  parse args;
  ensure_dir !out_dir;
  if !check then (
    (* Generate to a temp dir and compare with existing files *)
    let tmp = Filename.concat (Filename.get_temp_dir_name ()) ("tg_gen_" ^ string_of_int (Unix.getpid ())) in
    ensure_dir tmp;
    run_codegen_types ~in_path:!in_path ~out_dir:tmp;
    let new_ml = read_file (Filename.concat tmp "gen_types.ml") in
    let new_mli = read_file (Filename.concat tmp "gen_types.mli") in
    let old_ml_path = Filename.concat !out_dir "gen_types.ml" in
    let old_mli_path = Filename.concat !out_dir "gen_types.mli" in
    let old_ml = if Sys.file_exists old_ml_path then read_file old_ml_path else "" in
    let old_mli = if Sys.file_exists old_mli_path then read_file old_mli_path else "" in
    let types_diff = match diff_strings new_ml old_ml, diff_strings new_mli old_mli with
      | None, None -> false
      | _ -> true
    in
    let methods_diff = if !gen_methods then (
      let tmp_methods = Filename.concat tmp "gen_methods.ml" in
      run_codegen_methods ~in_path:!in_path ~out_file:tmp_methods;
      let new_methods = read_file tmp_methods in
      let old_methods_path = Filename.concat !out_dir "gen_methods.ml" in
      let old_methods = if Sys.file_exists old_methods_path then read_file old_methods_path else "" in
      match diff_strings new_methods old_methods with
      | None -> false
      | Some _ -> true
    ) else false
    in
    if types_diff || methods_diff then (
      print_endline "Mismatch: run without --check to write updated files"; exit 1
    ) else (
      print_endline "OK: all generated files are up-to-date"
    )
  ) else (
    run_codegen_types ~in_path:!in_path ~out_dir:!out_dir;
    if !gen_methods then (
      let out_file = Filename.concat !out_dir "gen_methods.ml" in
      run_codegen_methods ~in_path:!in_path ~out_file;
      (* write dune to compile gen_methods as a library *)
      let dune = Printf.sprintf "(library\n (name telegram_generated)\n (public_name ocaml_telegram_eio.generated)\n (libraries yojson ocaml_telegram_eio.telegram)\n (preprocess (pps ppx_deriving_yojson))\n (flags (:standard -w -69-33))\n (modules gen_types gen_methods))\n" in
      write_file (Filename.concat !out_dir "dune") dune;
      Printf.printf "Wrote methods stubs to %s\n" out_file
    )
  )
