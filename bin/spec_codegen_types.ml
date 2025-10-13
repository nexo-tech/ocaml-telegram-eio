(* Code generator for Telegram types from reference/api.html
   Usage:
     spec_codegen_types [reference/api.html] [--out-dir DIR]
   Prints generated code to stdout if --out-dir is not provided. *)

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

(* no-op; we scan the whole document and validate headings by table headers *)

let parse_types s : Telegram.Spec_ast.tdef list =
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
                      let title = strip_tags (String.sub s a_end (h_end - a_end)) |> String.trim in
                      (* Find the next h4 tag to know where this type's section ends *)
                      let next_h4_pos = match find_sub s "<h4><a class=\"anchor\" name=\"" ~from:(h_end + 5) with
                        | Some pos -> pos
                        | None -> String.length s
                      in
                      (* Check if this is a discriminated union type by looking for "can be one of" *)
                      let is_union =
                        match find_sub s "<table" ~from:h_end with
                        | Some t_start when t_start < next_h4_pos ->
                            let desc_section = String.sub s h_end (t_start - h_end) |> String.lowercase_ascii in
                            String.length desc_section > 0 &&
                            (find_sub desc_section "can be one of" <> None ||
                             find_sub desc_section "one of the following" <> None)
                        | _ -> false
                      in
                      let table =
                        match find_sub s "<table" ~from:h_end with
                        | Some t_start when t_start < next_h4_pos ->
                            (match find_sub s "</table>" ~from:t_start with
                             | None -> None
                             | Some t_end -> Some (String.sub s t_start (t_end - t_start + 8)))
                        | _ -> None
                      in
                      let fields =
                        match table with
                        | None -> []
                        | Some tbl ->
                            let rec rows acc pos =
                              match find_sub tbl "<tr>" ~from:pos with
                              | None -> List.rev acc
                              | Some r_start -> (match find_sub tbl "</tr>" ~from:(r_start+4) with None -> List.rev acc | Some r_end -> rows (String.sub tbl (r_start+4) (r_end - (r_start+4)) :: acc) (r_end+5))
                            in
                            (match rows [] 0 with
                             | hdr :: data_rows ->
                                 (* verify header has Field/Type/Description *)
                                 let rec ths acc pos =
                                   match find_sub hdr "<th" ~from:pos with
                                   | None -> List.rev acc
                                   | Some st -> (match find_sub hdr ">" ~from:st with None -> List.rev acc | Some gt -> (match find_sub hdr "</th>" ~from:gt with None -> List.rev acc | Some en -> ths (String.sub hdr (gt+1) (en - (gt+1)) :: acc) (en+5)))
                                 in
                                 let heads = List.map strip_tags (ths [] 0) in
                                 if not (List.mem "Field" heads && List.mem "Type" heads) then [] else
                                 let parse_row row_html =
                                   let rec cells acc pos =
                                     match find_sub row_html "<t" ~from:pos with
                                     | None -> List.rev acc
                                     | Some st -> (match find_sub row_html ">" ~from:st with None -> List.rev acc | Some gt -> (match find_sub row_html "</t" ~from:gt with None -> List.rev acc | Some en -> cells (String.sub row_html (gt+1) (en - (gt+1)) :: acc) (en+3)))
                                   in
                                   match List.map strip_tags (cells [] 0) with
                                   | name :: typ :: desc :: _ ->
                                       let optional = let low = String.lowercase_ascii desc in String.length low >= 9 && String.sub low 0 9 = "optional." in
                                       let open Telegram.Spec_ast in
                                       Some { name; typ; optional; description = desc }
                                   | _ -> None
                                 in
                                 List.filter_map parse_row data_rows
                             | _ -> [])
                      in
                      let def = (let open Telegram.Spec_ast in { anchor; title; fields; is_union }) in
                      loop (def :: acc) (h_end + 5))))
  in
  loop [] 0

let rec norm_deps acc (t:Telegram.Spec_norm.t) =
  let open Telegram.Spec_norm in
  match t with
  | TInt64 | TString | TBool | TFloat -> acc
  | TCustom s -> (ocaml_module_name s) :: acc
  | TArray t -> norm_deps acc t
  | TUnion ts -> List.fold_left norm_deps acc ts

let gen_ml defs =
  let open Telegram.Spec_norm in
  let b = Buffer.create 16384 in
  (* topo sort modules by dependencies to avoid forward refs *)
  let nodes = List.map (fun (d:Telegram.Spec_ast.tdef) ->
    let mname = ocaml_module_name d.title in
    let deps = List.fold_left (fun acc (f:Telegram.Spec_ast.field) ->
      norm_deps acc (parse_type f.typ)
    ) [] d.fields |> List.filter (fun x -> x <> mname)
    in (mname, d, deps)
  ) defs in
  let module M = struct type t = { name:string; def:Telegram.Spec_ast.tdef; deps:string list } end in
  let nodes = List.map (fun (n,d,ds) -> { M.name=n; def=d; deps=ds }) nodes in
  let rec topo acc remaining ready_names =
    match remaining with
    | [] -> List.rev acc
    | _ ->
        let (ready, not_ready) = List.partition (fun (x:M.t) -> List.for_all (fun d -> List.mem d ready_names) x.deps) remaining in
        (match ready with
        | [] -> (* cycle or unresolved; break by selecting one *)
            let x = List.hd not_ready in
            topo (x.def :: acc) (List.tl not_ready) (x.name :: ready_names)
        | rs ->
            let names = List.fold_left (fun a r -> r.M.name :: a) ready_names rs in
            topo (List.fold_left (fun a r -> r.M.def :: a) acc rs) not_ready names)
  in
  let ordered_defs = topo [] nodes [] in

  (* Generate type definitions with inline yojson converters *)
  let first = ref true in
  List.iter (fun (d:Telegram.Spec_ast.tdef) ->
    let mname = ocaml_module_name d.title in

    (* Helper to generate the type definition (used in both sig and struct) *)
    let gen_type_def () =
      if d.fields = [] then (
        Buffer.add_string b "  type t = unit\n"
      ) else (
        Buffer.add_string b "  type t = {\n";
        List.iter (fun (f:Telegram.Spec_ast.field) ->
          let fname = ocaml_field_name f.name in
          let ocaml_t = parse_type f.typ |> to_ocaml_type in
          let ocaml_t = if String.equal ocaml_t (mname ^ ".t") then "t" else ocaml_t in
          (* For union types, make all fields optional except type_ *)
          let is_optional = f.optional || (d.is_union && f.name <> "type") in
          let ocaml_t = if is_optional then ocaml_t ^ " option" else ocaml_t in
          Buffer.add_string b ("    " ^ fname ^ " : " ^ ocaml_t ^ ";\n")
        ) d.fields;
        Buffer.add_string b "    unknown_fields : Telegram.Json_compat.Unknown_fields.t;\n";
        Buffer.add_string b "  }\n"
      )
    in

    (* Generate signature with exposed record type *)
    if !first then (
      Buffer.add_string b ("module rec " ^ mname ^ " : sig\n");
      gen_type_def ();
      Buffer.add_string b "  val to_yojson : t -> Yojson.Safe.t\n";
      Buffer.add_string b "  val of_yojson : Yojson.Safe.t -> (t, string) result\n";
      Buffer.add_string b "end = struct\n"
    ) else (
      Buffer.add_string b ("and " ^ mname ^ " : sig\n");
      gen_type_def ();
      Buffer.add_string b "  val to_yojson : t -> Yojson.Safe.t\n";
      Buffer.add_string b "  val of_yojson : Yojson.Safe.t -> (t, string) result\n";
      Buffer.add_string b "end = struct\n"
    );

    (* Type definition in struct (same as signature) *)
    gen_type_def ();

    (* to_yojson implementation *)
    if d.fields = [] then (
      Buffer.add_string b "  let to_yojson (_ : t) : Yojson.Safe.t = `Null\n"
    ) else (
      Buffer.add_string b "  let to_yojson (v : t) : Yojson.Safe.t =\n";
      (* Separate required and optional fields for cleaner code generation *)
      (* For union types, all fields except type_ are optional *)
      let required_fields = List.filter (fun (f:Telegram.Spec_ast.field) ->
        not f.optional && not (d.is_union && f.name <> "type")
      ) d.fields in
      let optional_fields = List.filter (fun (f:Telegram.Spec_ast.field) ->
        f.optional || (d.is_union && f.name <> "type")
      ) d.fields in

      Buffer.add_string b "    `Assoc (\n";

      (* Required fields as a simple list *)
      if required_fields <> [] then (
        Buffer.add_string b "      [\n";
        List.iteri (fun i (f:Telegram.Spec_ast.field) ->
          let fname = ocaml_field_name f.name in
          let json_name = f.name in
          let typ = parse_type f.typ in
          let rec gen_encoder t var =
            match t with
            | TInt64 -> Printf.sprintf "`Intlit (Int64.to_string %s)" var
            | TString -> Printf.sprintf "`String %s" var
            | TBool -> Printf.sprintf "`Bool %s" var
            | TFloat -> Printf.sprintf "`Float %s" var
            | TCustom s -> Printf.sprintf "%s.to_yojson %s" (ocaml_module_name s) var
            | TArray inner -> Printf.sprintf "`List (List.map (fun x -> %s) %s)" (gen_encoder inner "x") var
            | TUnion _ -> Printf.sprintf "`String %s" var
          in
          let sep = if i < List.length required_fields - 1 then ";\n" else "\n" in
          Buffer.add_string b (Printf.sprintf "        (\"%s\", %s)%s" json_name (gen_encoder typ ("v." ^ fname)) sep)
        ) required_fields;
        Buffer.add_string b "      ]"
      ) else (
        Buffer.add_string b "      []"
      );

      (* Optional fields - each wrapped in match to return [] or singleton list *)
      List.iter (fun (f:Telegram.Spec_ast.field) ->
        let fname = ocaml_field_name f.name in
        let json_name = f.name in
        let typ = parse_type f.typ in
        let rec gen_encoder t var =
          match t with
          | TInt64 -> Printf.sprintf "`Intlit (Int64.to_string %s)" var
          | TString -> Printf.sprintf "`String %s" var
          | TBool -> Printf.sprintf "`Bool %s" var
          | TFloat -> Printf.sprintf "`Float %s" var
          | TCustom s -> Printf.sprintf "%s.to_yojson %s" (ocaml_module_name s) var
          | TArray inner -> Printf.sprintf "`List (List.map (fun x -> %s) %s)" (gen_encoder inner "x") var
          | TUnion _ -> Printf.sprintf "`String %s" var
        in
        Buffer.add_string b " @\n";
        Buffer.add_string b (Printf.sprintf "      (match v.%s with None -> [] | Some x -> [(\"%s\", %s)])"
          fname json_name (gen_encoder typ "x"))
      ) optional_fields;

      Buffer.add_string b " @\n";
      Buffer.add_string b "      Telegram.Json_compat.Unknown_fields.to_assoc v.unknown_fields)\n"
    );

    (* of_yojson implementation *)
    if d.fields = [] then (
      Buffer.add_string b "  let of_yojson (_ : Yojson.Safe.t) : (t, string) result = Ok (Obj.magic () : t)\n"
    ) else (
      Buffer.add_string b "  let of_yojson (j : Yojson.Safe.t) : (t, string) result =\n";
      Buffer.add_string b "    match j with\n";
      Buffer.add_string b "    | `Assoc fields ->\n";
      Buffer.add_string b "        let open Yojson.Safe.Util in\n";
      Buffer.add_string b "        let uf = Telegram.Json_compat.Unknown_fields.create () in\n";
      Buffer.add_string b "        (try\n";

      (* Field extraction *)
      List.iter (fun (f:Telegram.Spec_ast.field) ->
        let fname = ocaml_field_name f.name in
        let json_name = f.name in
        let typ = parse_type f.typ in
        let rec gen_decoder t json_expr =
          match t with
          | TInt64 -> Printf.sprintf "(match %s with `Int i -> Int64.of_int i | `Intlit s -> Int64.of_string s | _ -> raise (Type_error (\"Expected int\", %s)))" json_expr json_expr
          | TString -> Printf.sprintf "(to_string %s)" json_expr
          | TBool -> Printf.sprintf "(to_bool %s)" json_expr
          | TFloat -> Printf.sprintf "(to_float %s)" json_expr
          | TCustom s -> Printf.sprintf "(match %s.of_yojson %s with Ok v -> v | Error e -> raise (Type_error (e, %s)))" (ocaml_module_name s) json_expr json_expr
          | TArray inner -> Printf.sprintf "(List.map (fun x -> %s) (to_list %s))" (gen_decoder inner "x") json_expr
          | TUnion _ -> Printf.sprintf "(to_string %s)" json_expr
        in
        Buffer.add_string b (Printf.sprintf "          Telegram.Json_compat.Unknown_fields.mark_known uf \"%s\";\n" json_name);
        (* For union types, make all fields optional except type_ *)
        let is_optional = f.optional || (d.is_union && f.name <> "type") in
        if is_optional then
          Buffer.add_string b (Printf.sprintf "          let %s = match List.assoc_opt \"%s\" fields with None | Some `Null -> None | Some x -> Some (%s) in\n"
            fname json_name (gen_decoder typ "x"))
        else
          (* Required field - wrap with better error handling *)
          Buffer.add_string b (Printf.sprintf "          let %s = (try %s with Not_found -> raise (Type_error (\"Missing required field '%s'\", `Null))) in\n"
            fname (gen_decoder typ (Printf.sprintf "(List.assoc \"%s\" fields)" json_name)) json_name)
      ) d.fields;

      (* Capture unknown fields *)
      Buffer.add_string b "          let unknown_fields = Telegram.Json_compat.Unknown_fields.capture uf fields in\n";

      (* Construct record *)
      Buffer.add_string b "          Ok { ";
      List.iteri (fun i (f:Telegram.Spec_ast.field) ->
        let fname = ocaml_field_name f.name in
        if i > 0 then Buffer.add_string b "; ";
        Buffer.add_string b (fname ^ " = " ^ fname)
      ) d.fields;
      Buffer.add_string b "; unknown_fields }\n";
      Buffer.add_string b "        with\n";
      (* Include type name in error messages for better debugging *)
      let type_name = d.title in
      Buffer.add_string b (Printf.sprintf "        | Not_found -> Error \"Missing required field in %s\"\n" type_name);
      Buffer.add_string b "        | Type_error (msg, _) -> Error msg)\n";
      Buffer.add_string b (Printf.sprintf "    | _ -> Error \"Expected JSON object for %s\"\n" type_name)
    );

    Buffer.add_string b "end\n";
    first := false
  ) ordered_defs;
  Buffer.contents b

let gen_mli defs =
  let open Telegram.Spec_norm in
  let b = Buffer.create 4096 in
  List.iter (fun (d:Telegram.Spec_ast.tdef) ->
    let mname = ocaml_module_name d.title in
    Buffer.add_string b ("module " ^ mname ^ " : sig\n");

    (* Generate type definition (same as in sig part of .ml) *)
    if d.fields = [] then (
      Buffer.add_string b "  type t = unit\n"
    ) else (
      Buffer.add_string b "  type t = {\n";
      List.iter (fun (f:Telegram.Spec_ast.field) ->
        let fname = ocaml_field_name f.name in
        let ocaml_t = parse_type f.typ |> to_ocaml_type in
        let ocaml_t = if String.equal ocaml_t (mname ^ ".t") then "t" else ocaml_t in
        let ocaml_t = if f.optional then ocaml_t ^ " option" else ocaml_t in
        Buffer.add_string b ("    " ^ fname ^ " : " ^ ocaml_t ^ ";\n")
      ) d.fields;
      Buffer.add_string b "    unknown_fields : Telegram.Json_compat.Unknown_fields.t;\n";
      Buffer.add_string b "  }\n"
    );

    Buffer.add_string b "  val to_yojson : t -> Yojson.Safe.t\n";
    Buffer.add_string b "  val of_yojson : Yojson.Safe.t -> (t, string) result\n";
    Buffer.add_string b "end\n"
  ) defs;
  Buffer.contents b

let () =
  let args = Array.to_list Sys.argv |> List.tl in
  let path, out_dir =
    match args with
    | [] -> ("reference/api.html", None)
    | [p] -> (p, None)
    | [p; "--out-dir"; d] -> (p, Some d)
    | p :: _ -> (p, None)
  in
  let s = read_file path in
  let defs = parse_types s in
  let ml = "(* Generated from reference/api.html *)\n" ^ gen_ml defs in
  let mli = gen_mli defs in
  match out_dir with
  | None -> print_string ml
  | Some dir ->
      let oc = open_out (Filename.concat dir "gen_types.ml") in
      output_string oc ml; close_out oc;
      let oc = open_out (Filename.concat dir "gen_types.mli") in
      output_string oc mli; close_out oc;
      Printf.printf "Wrote %d type(s) to %s\n" (List.length defs) dir
