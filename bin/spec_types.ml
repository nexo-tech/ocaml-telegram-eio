
let read_file path =
  let ic = open_in_bin path in
  let len = in_channel_length ic in
  let s = really_input_string ic len in
  close_in ic;
  s

let find_sub ?(from=0) s sub =
  let len = String.length s and lsub = String.length sub in
  let rec loop i =
    if i + lsub > len then None
    else if String.sub s i lsub = sub then Some i
    else loop (i+1)
  in
  loop from

let find_between s ~start_anchor ~end_anchor =
  let start_tag = "<a class=\"anchor\" name=\"" ^ start_anchor ^ "\"" in
  let end_tag = "<a class=\"anchor\" name=\"" ^ end_anchor ^ "\"" in
  let pos_start = match find_sub s start_tag with Some i -> i | None -> 0 in
  let pos_end = match find_sub s end_tag ~from:pos_start with Some i -> i | None -> String.length s in
  String.sub s pos_start (pos_end - pos_start)

let strip_tags s =
  let len = String.length s in
  let buf = Buffer.create len in
  let rec loop i in_tag =
    if i >= len then Buffer.contents buf |> String.trim
    else if in_tag then
      if s.[i] = '>' then loop (i+1) false else loop (i+1) true
    else if s.[i] = '<' then loop (i+1) true
    else (Buffer.add_char buf s.[i]; loop (i+1) false)
  in
  loop 0 false

let parse_table tbl_html =
  let rec collect_rows acc pos =
    match find_sub tbl_html "<tr>" ~from:pos with
    | None -> List.rev acc
    | Some i ->
        (match find_sub tbl_html "</tr>" ~from:(i+4) with
         | None -> List.rev acc
         | Some j -> collect_rows (String.sub tbl_html (i+4) (j - (i+4)) :: acc) (j+5))
  in
  match collect_rows [] 0 with
  | _hdr :: data_rows ->
      let parse_row row_html =
        let rec cells acc pos =
          match find_sub row_html "<td" ~from:pos with
          | None -> List.rev acc
          | Some st ->
              let st = match find_sub row_html ">" ~from:st with Some k -> k+1 | None -> st in
              (match find_sub row_html "</td>" ~from:st with
               | None -> List.rev acc
               | Some en -> cells (String.sub row_html st (en - st) :: acc) (en+5))
        in
        match cells [] 0 with
        | name :: typ :: desc :: _ ->
            let optional =
              let lower = String.lowercase_ascii desc in
              String.length lower >= 9 && String.sub lower 0 9 = "optional."
            in
            let open Telegram.Spec_ast in
            Some { name = strip_tags name; typ = strip_tags typ; optional; description = strip_tags desc }
        | _ -> None
      in
      List.filter_map parse_row data_rows
  | _ -> []

let scan_types_section s =
  let rec loop acc pos =
    match find_sub s "<h4><a class=\"anchor\" name=\"" ~from:pos with
    | None -> List.rev acc
    | Some i ->
        let name_start = i + 28 in
        (match find_sub s "\"" ~from:name_start with
         | None -> List.rev acc
         | Some name_end ->
             let anchor = String.sub s name_start (name_end - name_start) in
             (match find_sub s "</a>" ~from:name_end with
              | None -> List.rev acc
              | Some a_end ->
                  (match find_sub s "</h4>" ~from:a_end with
                   | None -> List.rev acc
                   | Some h_end ->
                       let title = strip_tags (String.sub s a_end (h_end - a_end)) in
                       (* Find the next h4 tag to know where this type's section ends *)
                       let next_h4_pos = match find_sub s "<h4><a class=\"anchor\" name=\"" ~from:(h_end + 5) with
                         | Some pos -> pos
                         | None -> String.length s
                       in
                       (* find first table after h4 but before next h4 *)
                       (match find_sub s "<table" ~from:h_end with
                        | None ->
                            let open Telegram.Spec_ast in
                            loop ({ anchor; title = String.trim title; fields = []; is_union = false } :: acc) (h_end + 5)
                        | Some t_start when t_start < next_h4_pos ->
                            (* Table is within this type's section *)
                            (match find_sub s "</table>" ~from:t_start with
                             | None ->
                                 let open Telegram.Spec_ast in
                                 loop ({ anchor; title = String.trim title; fields = []; is_union = false } :: acc) (h_end + 5)
                             | Some t_end ->
                                 let tbl = String.sub s t_start (t_end - t_start + 8) in
                                 let fields = parse_table tbl in
                                 let open Telegram.Spec_ast in
                                 loop ({ anchor; title = String.trim title; fields; is_union = false } :: acc) (h_end + 5))
                        | Some _ ->
                            (* Table is in the next type's section, so this type has no table *)
                            let open Telegram.Spec_ast in
                            loop ({ anchor; title = String.trim title; fields = []; is_union = false } :: acc) (h_end + 5)))))
  in
  loop [] 0

let () =
  let path = if Array.length Sys.argv > 1 then Sys.argv.(1) else "reference/api.html" in
  let s = read_file path in
  let section = find_between s ~start_anchor:"available-types" ~end_anchor:"available-methods" in
  let defs = scan_types_section section in
  List.iter (fun d -> print_endline (Telegram.Spec_ast.pp_tdef d); print_endline "" ) defs
