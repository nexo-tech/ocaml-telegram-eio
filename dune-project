(lang dune 3.7)
(name ocaml_telegram_eio)
(version 0.1.0)
(generate_opam_files true)

(source (github oleg-nexo/ocaml_telegram_eio))
(license MIT)
(authors "Oleg Pustovit <oleg@nexo.sh>")
(maintainers "Oleg Pustovit <oleg@nexo.sh>")
(homepage "https://github.com/oleg-nexo/ocaml_telegram_eio")
(bug_reports "https://github.com/oleg-nexo/ocaml_telegram_eio/issues")
(documentation "https://oleg-nexo.github.io/ocaml_telegram_eio/")

(package
 (name ocaml_telegram_eio)
 (synopsis "Type-safe Telegram Bot API client for OCaml using Eio")
 (description "\
ocaml-telegram-eio is a production-grade Telegram Bot API client library for OCaml 5.x
built on Eio for structured concurrency.

Features:
- Fully type-safe API with phantom-typed identifiers
- Complete Bot API coverage: 449 types, 232 methods (auto-generated from spec)
- Direct-style concurrency using Eio effects (no monads, no callbacks)
- Forward-compatible: preserves unknown fields for new Bot API features
- Streaming file uploads and downloads for efficient memory usage
- Long polling and webhook support
- Comprehensive error handling with Result types
- Property-based and integration tested

The library provides both low-level generated methods (Telegram_generated.Gen_methods)
and high-level ergonomic helpers (Tg.Polling, Tg.Keyboard, etc.) for building bots.")
 (depends
  ;; Core dependencies
  (ocaml (>= 5.1.0))
  (dune (>= 3.7))

  ;; Runtime dependencies
  (eio (>= 0.12))
  (eio_main (>= 0.12))
  (yojson (>= 2.0.0))
  (ppx_deriving (>= 5.0))
  (ppx_deriving_yojson (>= 3.7.0))

  ;; HTTP and networking
  (cohttp (>= 5.0))
  (cohttp-eio (>= 5.0))
  (tls-eio (>= 0.17.0))
  (ca-certs (>= 0.2.0))
  (mirage-crypto-rng-eio (>= 0.11.0))
  (uri (>= 4.0))
  (domain-name (>= 0.4.0))
  (cstruct (>= 6.0))

  ;; Logging (from GitHub - pinned to latest commit with scoped logging)
  ;; Pin command: opam pin add flo ./flo -y && opam pin add ppx_flo ./flo -y
  ;; Commit: b45f6452061ef309767eb8e9985532c41abdfeaa (2025-10-22)
  (flo (>= 0.1.0))
  (ppx_flo (>= 0.1.0))
  (ptime (>= 1.0))  ;; Required by flo

  ;; Code generation and parsing
  (re (>= 1.10.0))

  ;; Test dependencies
  (alcotest :with-test)
  (qcheck :with-test)
  (qcheck-alcotest :with-test)

  ;; Documentation
  (odoc :with-doc))
 (tags
  ("telegram" "bot" "api" "eio" "effects" "async" "concurrency")))
