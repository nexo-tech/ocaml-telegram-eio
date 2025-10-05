let read_file path =
  let ic = open_in_bin path in
  let len = in_channel_length ic in
  let s = really_input_string ic len in
  close_in ic;
  s

let line_of_pos s pos =
  let rec loop i line =
    if i >= pos then line else
    let nl = try String.index_from s i '\n' with Not_found -> String.length s in
    if nl >= pos then line + 1 else loop (nl + 1) (line + 1)
  in
  loop 0 0

let scan_headings s =
  let rex = Re.Perl.compile_pat "<h([1-6])><a class=\\\"anchor\\\" name=\\\"([^\\\"]+)\\\" [^>]*>.*?</a>([^<]+)</h\\1>" in
  let rec aux acc start =
    match Re.exec_opt ~pos:start rex s with
    | None -> List.rev acc
    | Some g ->
        let whole = Re.Group.get g 0 in
        let level = int_of_string (Re.Group.get g 1) in
        let anchor = Re.Group.get g 2 in
        let title = String.trim (Re.Group.get g 3) in
        let pos = Re.Group.start g 0 in
        let line = line_of_pos s pos in
        let next = pos + String.length whole in
        aux ((level, anchor, title, line) :: acc) next
  in
  aux [] 0

let () =
  let path = if Array.length Sys.argv > 1 then Sys.argv.(1) else "reference/api.html" in
  let s = read_file path in
  let hs = scan_headings s in
  let print (lvl, anchor, title, line) =
    Printf.printf "h%d %s %s :%d\n" lvl anchor title (line + 1)
  in
  List.iter print hs;
  match List.find_opt (fun (_, a, _, _) -> a = "available-types") hs with
  | Some (_, _, _, l) -> Printf.printf "Available types anchor at line %d\n" (l + 1)
  | None -> Printf.printf "Available types anchor not found\n";
  match List.find_opt (fun (_, a, _, _) -> a = "available-methods") hs with
  | Some (_, _, _, l) -> Printf.printf "Available methods anchor at line %d\n" (l + 1)
  | None -> Printf.printf "Available methods anchor not found\n"
