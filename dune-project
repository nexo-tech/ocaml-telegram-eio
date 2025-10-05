(lang dune 3.7)
(name ocaml_telegram_eio)
(generate_opam_files false)

(package
 (name ocaml_telegram_eio)
 (synopsis "Telegram Bot API client for OCaml (Eio)")
 (description "Ergonomic, type-safe Telegram Bot API client and DSL using Eio.")
 (depends
  (ocaml (>= 5.2))
  eio
  yojson
 ))
