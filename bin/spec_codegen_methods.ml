(* Generate method wrappers. For now, emit wrappers for sendMessage using Request constructors
   and generic wrappers for others calling Api.call_json returning Yojson.Safe.t. *)

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
  match find_sub s tag with None -> s | Some i -> String.sub s i (String.length s - i)

let strip_tags s =
  let len = String.length s in
  let buf = Buffer.create len in
  let rec loop i in_tag =
    if i >= len then Buffer.contents buf |> String.trim
    else if in_tag then if s.[i] = '>' then loop (i+1) false else loop (i+1) true
    else if s.[i] = '<' then loop (i+1) true
    else (Buffer.add_char buf s.[i]; loop (i+1) false)
  in loop 0 false

type param = { name : string; typ : string; required : bool; description : string }
type m = { anchor : string; name : string; returns : string option; params : param list }

let _use_param_description (p:param) = ignore p.description

let parse_methods s =
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
              | Some a_end -> (match find_sub s "</h4>" ~from:a_end with
                  | None -> List.rev acc
                  | Some h_end ->
                      let name = strip_tags (String.sub s a_end (h_end - a_end)) |> String.trim in
                      let next_h4 = find_sub s "<h4><a class=\"anchor\" name=\"" ~from:(h_end+1) in
                      let limit = match next_h4 with None -> String.length s | Some p -> p in
                      let returns =
                        match find_sub s "<p>" ~from:h_end with
                        | Some p_start when p_start < limit -> (
                            match find_sub s "</p>" ~from:(p_start+3) with
                            | None -> None
                            | Some p_end ->
                                let p_html = String.sub s (p_start+3) (p_end - (p_start+3)) in
                                (* First check for explicit "Returns True" or success mentions *)
                                let txt = strip_tags p_html |> String.lowercase_ascii in
                                let has_returns_true =
                                  (match find_sub txt "returns" with
                                   | Some ret_pos ->
                                       let after = String.sub txt ret_pos (String.length txt - ret_pos) in
                                       (match find_sub after "true" with
                                        | Some t_pos when t_pos < 50 -> true
                                        | _ -> false)
                                   | None -> false) ||
                                  (match find_sub txt "on success" with Some _ -> true | None -> false) &&
                                  (match find_sub txt "true" with Some _ -> true | None -> false)
                                in
                                if has_returns_true then Some "Boolean"
                                else
                                  (* Otherwise look for type anchor links, filtering out method refs *)
                                  let rec find_last_type_link acc pos =
                                    match find_sub p_html "<a" ~from:pos with
                                    | None -> acc
                                    | Some a_start ->
                                        (match find_sub p_html "href=\"#" ~from:a_start with
                                         | Some href_start when href_start < a_start + 20 ->
                                             let href_id_start = href_start + 7 in
                                             (match find_sub p_html "\"" ~from:href_id_start with
                                              | None -> find_last_type_link acc (a_start + 1)
                                              | Some href_id_end ->
                                                  let _href_id = String.sub p_html href_id_start (href_id_end - href_id_start) in
                                                  (match find_sub p_html ">" ~from:a_start with
                                                   | None -> find_last_type_link acc (a_start + 1)
                                                   | Some gt ->
                                                       (match find_sub p_html "</a>" ~from:gt with
                                                        | None -> find_last_type_link acc (gt + 1)
                                                        | Some en ->
                                                            let link_text = strip_tags (String.sub p_html (gt+1) (en - (gt+1))) in
                                                            (* Skip if link text is all lowercase (likely a method reference) *)
                                                            let has_uppercase =
                                                              let rec check i =
                                                                if i >= String.length link_text then false
                                                                else match link_text.[i] with
                                                                  | 'A'..'Z' -> true
                                                                  | _ -> check (i + 1)
                                                              in check 0
                                                            in
                                                            if has_uppercase then find_last_type_link (Some link_text) (en + 1)
                                                            else find_last_type_link acc (en + 1))))
                                         | _ -> find_last_type_link acc (a_start + 1))
                                  in
                                  find_last_type_link None 0)
                        | _ -> None in
                      let params =
                        match find_sub s "<table" ~from:h_end with
                        | Some t_start when t_start < limit ->
                            (match find_sub s "</table>" ~from:t_start with
                             | None -> []
                             | Some t_end ->
                                 let tbl = String.sub s t_start (t_end - t_start + 8) in
                                 let rec rows acc pos =
                                   match find_sub tbl "<tr>" ~from:pos with
                                   | None -> List.rev acc
                                   | Some r_start -> (match find_sub tbl "</tr>" ~from:(r_start+4) with None -> List.rev acc | Some r_end -> rows (String.sub tbl (r_start+4) (r_end - (r_start+4)) :: acc) (r_end+5))
                                 in
                                 (match rows [] 0 with
                                  | _hdr :: data_rows ->
                                      let parse_row row_html =
                                        let rec cells acc pos =
                                          match find_sub row_html "<t" ~from:pos with
                                          | None -> List.rev acc
                                          | Some st -> (match find_sub row_html ">" ~from:st with None -> List.rev acc | Some gt -> (match find_sub row_html "</t" ~from:gt with None -> List.rev acc | Some en -> cells (String.sub row_html (gt+1) (en - (gt+1)) :: acc) (en+3)))
                                        in
                                        match List.map strip_tags (cells [] 0) with
                                        | n :: t :: req :: d :: _ -> Some { name = n; typ = t; required = String.lowercase_ascii req = "yes"; description = d }
                                        | _ -> None
                                      in
                                      List.filter_map parse_row data_rows
                                  | _ -> []))
                        | _ -> []
                      in
                      loop ({ anchor; name; returns; params } :: acc) (h_end + 5))))
  in
  loop [] 0

let snake s =
  let b = Buffer.create (String.length s) in
  String.iteri (fun i c ->
    if i > 0 && Char.uppercase_ascii c = c && Char.lowercase_ascii c <> c then (Buffer.add_char b '_'; Buffer.add_char b (Char.lowercase_ascii c))
    else Buffer.add_char b (Char.lowercase_ascii c)
  ) s; Buffer.contents b

let is_method (m:m) =
  let a = m.anchor in
  let n = String.length a in
  n > 0 &&
  let ok = ref true in
  for i = 0 to n - 1 do
    let c = a.[i] in
    if not ((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9')) then ok := false
  done; !ok && (not (String.contains m.name ' '))

(* decode helpers removed; return raw JSON instead *)

let rec to_json ocaml_t var_name =
  let t = String.trim ocaml_t in
  if t = "bool" then Some ("`Bool " ^ var_name)
  else if t = "string" then Some ("`String " ^ var_name)
  else if t = "int64" then Some ("`Intlit (Int64.to_string " ^ var_name ^ ")")
  else if String.length t > 5 && String.sub t (String.length t - 5) 5 = " list" then
    let inner = String.sub t 0 (String.length t - 5) in
    Some ("`List (List.map (fun x -> " ^ (match to_json inner "x" with Some e -> e | None -> "x") ^ ") " ^ var_name ^ ")")
  else if String.length t > 2 && String.sub t (String.length t - 2) 2 = ".t" then
    let module_name = String.sub t 0 (String.length t - 2) in
    Some (module_name ^ ".to_yojson " ^ var_name)
  else None

let rec decode_apply ocaml_t json_expr =
  let t = String.trim ocaml_t in
  if t = "bool" then "Ok (Yojson.Safe.Util.to_bool " ^ json_expr ^ ")"
  else if t = "string" then "Ok (Yojson.Safe.Util.to_string " ^ json_expr ^ ")"
  else if t = "int64" then "Ok (match " ^ json_expr ^ " with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | j -> Int64.of_string (Yojson.Safe.Util.to_string j))"
  else if String.length t > 5 && String.sub t (String.length t - 5) 5 = " list" then
    let inner = String.sub t 0 (String.length t - 5) in
    "Ok (List.map (fun jj -> match " ^ (decode_apply inner "jj") ^ " with Ok v -> v | Error _ -> failwith \"decode\") (Yojson.Safe.Util.to_list " ^ json_expr ^ "))"
  else if String.length t > 2 && String.sub t (String.length t - 2) 2 = ".t" then
    let module_name = String.sub t 0 (String.length t - 2) in
    "(match " ^ module_name ^ ".of_yojson " ^ json_expr ^ " with Ok v -> Ok v | Error msg -> Error (Error.Decode_error msg))"
  else "Ok " ^ json_expr

let pp_generated (defs:m list) =
  let open Telegram.Spec_norm in
  let b = Buffer.create 4096 in
  Buffer.add_string b "(* Generated method wrappers (typed). *)\nopen Telegram\nopen Yojson.Safe\nopen Gen_types\n\n";
  List.iter (fun meth ->
    if is_method meth then (
      let fname = snake meth.name in
      let returns = match meth.returns with None -> "?" | Some r -> r in
      Buffer.add_string b (Printf.sprintf "(* %s [%s] -> %s *)\n" meth.name meth.anchor returns);
      (* function signature *)
      let required, optional = List.partition (fun (p:param) -> p.required) meth.params in
      Buffer.add_string b ("let " ^ fname ^ " (client:Client.t) ");
      List.iter (fun (p:param) -> Buffer.add_string b ("~" ^ Telegram.Spec_norm.ocaml_field_name p.name ^ " ")) required;
      List.iter (fun (p:param) -> Buffer.add_string b ("?" ^ Telegram.Spec_norm.ocaml_field_name p.name ^ " ")) optional;
      Buffer.add_string b "() =\n";
      (* build JSON assoc *)
      Buffer.add_string b "  let params = List.filter_map (fun x -> x) [\n";
      List.iter (fun (p:param) ->
        let nm = ocaml_field_name p.name in
        let oc_t = to_ocaml_type (parse_type p.typ) in
        let encode =
          if String.equal nm "chat_id" then "`String (Id.to_string chat_id)"
          else (match to_json oc_t nm with Some e -> e | None -> nm)
        in
        if p.required then Buffer.add_string b ("    Some (\"" ^ nm ^ "\", " ^ encode ^ ");\n")
        else Buffer.add_string b ("    (match " ^ nm ^ " with None -> None | Some v -> Some (\"" ^ nm ^ "\", " ^ (match to_json oc_t "v" with Some e -> e | None -> "v") ^ "));\n")
      ) meth.params;
      Buffer.add_string b "  ] in\n";
      Buffer.add_string b ("  match Api.call_json client ~method_name:\"" ^ meth.name ^ "\" (`Assoc params) with\n");
      Buffer.add_string b "  | Error e -> Error e\n";
      (match meth.returns with
       | None -> Buffer.add_string b "  | Ok j -> Ok j\n\n"
       | Some r ->
          let oc_rt = to_ocaml_type (parse_type r) in
          let decoder = decode_apply oc_rt "j" in
          Buffer.add_string b ("  | Ok j -> " ^ decoder ^ "\n\n"))
    )
  ) defs;
  Buffer.contents b

let () =
  let args = Array.to_list Sys.argv |> List.tl in
  let path = match args with [] -> "reference/api.html" | p :: _ -> p in
  let s = read_file path in
  let s = slice_from_anchor s "available-methods" in
  let defs = parse_methods s in
  print_string (pp_generated defs)
