type t = [ `Markdown | `MarkdownV2 | `HTML ]

let to_string = function
  | `Markdown -> "Markdown"
  | `MarkdownV2 -> "MarkdownV2"
  | `HTML -> "HTML"

let of_string = function
  | "Markdown" -> Some `Markdown
  | "MarkdownV2" -> Some `MarkdownV2
  | "HTML" -> Some `HTML
  | _ -> None

let to_yojson t = `String (to_string t)

let of_yojson = function
  | `String s -> (
      match of_string s with
      | Some m -> Ok m
      | None -> Error ("Unknown parse_mode: " ^ s)
    )
  | _ -> Error "Parse_mode: expected string"

let pp fmt t = Format.fprintf fmt "%s" (to_string t)

