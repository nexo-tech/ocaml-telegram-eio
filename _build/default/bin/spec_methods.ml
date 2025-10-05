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

let slice_from_anchor s name =
  let tag = "<a class=\"anchor\" name=\"" ^ name ^ "\"" in
  match find_sub s tag with
  | None -> s
  | Some i -> String.sub s i (String.length s - i)

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

let parse_params_table tbl_html =
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
        let cols = List.map strip_tags (cells [] 0) in
        match cols with
        | name :: typ :: required :: desc :: _ ->
            let optional = String.lowercase_ascii required <> "yes" in
            let open Telegram.Spec_ast in
            Some { name; typ; optional; description = desc }
        | _ -> None
      in
      List.filter_map parse_row data_rows
  | _ -> []

let parse_returns p_html =
  let txt = strip_tags p_html in
  match find_sub p_html "<a" with
  | Some a_start ->
      (match find_sub p_html ">" ~from:a_start with
       | None -> None
       | Some gt -> (match find_sub p_html "</a>" ~from:gt with None -> None | Some en -> Some (strip_tags (String.sub p_html (gt+1) (en - (gt+1))))))
  | None ->
      let lower = String.lowercase_ascii txt in
      if String.contains lower 't' && (String.length lower >= 4 && String.sub lower 0 4 = "true") then Some "Boolean" else None

let scan_methods s =
  let rec loop acc pos =
    match find_sub s "<h4><a class=\"anchor\" name=\"" ~from:pos with
    | None -> List.rev acc
    | Some i ->
        let name_start = i + 28 in
        (match find_sub s "\"" ~from:name_start with
         | None -> List.rev acc
         | Some name_end ->
             let m_anchor = String.sub s name_start (name_end - name_start) in
             (match find_sub s "</a>" ~from:name_end with
              | None -> List.rev acc
              | Some a_end -> (match find_sub s "</h4>" ~from:a_end with
                  | None -> List.rev acc
                  | Some h_end ->
                      let m_name = strip_tags (String.sub s a_end (h_end - a_end)) |> String.trim in
                      let next_h4 = find_sub s "<h4><a class=\"anchor\" name=\"" ~from:(h_end+1) in
                      let limit = match next_h4 with None -> String.length s | Some p -> p in
                      let returns = (match find_sub s "<p>" ~from:h_end with Some p_start when p_start < limit -> (match find_sub s "</p>" ~from:(p_start+3) with None -> None | Some p_end -> if p_end <= limit then parse_returns (String.sub s (p_start+3) (p_end - (p_start+3))) else None) | _ -> None) in
                      let params = (match find_sub s "<table" ~from:h_end with Some t_start when t_start < limit -> (match find_sub s "</table>" ~from:t_start with None -> [] | Some t_end -> if t_end <= limit then parse_params_table (String.sub s t_start (t_end - t_start + 8)) else []) | _ -> []) in
                      let open Telegram.Spec_ast in
                      let def = { m_anchor; m_name; returns; params } in
                      loop (def :: acc) (h_end + 5))))
  in
  loop [] 0

let () =
  let path = if Array.length Sys.argv > 1 then Sys.argv.(1) else "reference/api.html" in
  let s = read_file path in
  let s = slice_from_anchor s "available-methods" in
  let defs = scan_methods s in
  List.iter (fun d -> print_endline (Telegram.Spec_ast.pp_mdef d); print_endline "") defs
