Project Plan — ocaml-telegram-eio

Scope
- Goal: A production-grade, fully featured Telegram Bot API client for OCaml 5.x using Eio, with an ergonomic, type-safe, low‑boilerplate API and clean implementation.
- References: reference/api.html, reference/features.html, reference/tutorial.html. We will parse these to derive types and methods and keep pace with Bot API updates.
- Deliverables: Core library (HTTP + JSON + types + method wrappers), high-level ergonomic bot DSL and router, polling and webhook runners, files/media support, payments and stars, inline mode, keyboards and markup builders, reliability features (retry/rate-limit/backoff), logging/metrics/tracing, tests, docs and examples, release packaging.
- Public API Design: See API_DESIGN.md for the target public API shape and examples. All implementation work must keep the API alignment with this document.
  - Note: API_DESIGN.md (v2) adopts typed events (GADTs), first-class Request + single Api.call, typed callback Action codecs, and Msg builders to minimize boilerplate and maximize type-safety.

Principles
- Ergonomic: Labeled optional args, sensible defaults, small surface for common flows, advanced hooks available when needed.
- Type-safety: Strong modeling of Telegram types, phantom types/GADTs where useful, safe newtypes for identifiers, consistent result/error types, no silent exceptions by default.
- Eio-native: Direct-style concurrency, structured cancellation, resource-safe streaming (files/media), pluggable HTTP backend.
- Correctness: Faithful JSON codecs with forward-compatible unknown-field handling, robust error decoding, rate-limits respected, retries idempotent.
- Maintainable: Spec-driven codegen for types/methods, clear layering, small hand-written core, generated API surface with tests.

Master Checklist

**Completion: 34/92 tasks (37%)**

Phase 1 — Architecture & Tooling (10/10 ✓)
- [x] Task 1.1 Decide core architecture, layering, and error strategy
- [x] Task 1.2 Choose HTTP backend abstraction and default impl
- [x] Task 1.3 Choose JSON codec + derivation strategy
- [x] Task 1.4 Establish dune workspace, opam metadata and CI skeleton
- [x] Task 1.5 Decide identifier newtypes and naming conventions
- [x] Task 1.6 Define result/error types and exception policy
- [x] Task 1.7 Plan versioning, doc generation, and examples layout
- [x] Task 1.8 Draft and lock API_DESIGN.md (public API specification)
- [x] Task 1.9 Choose JSON codec + derivation (yojson + manual converters for module rec)
- [x] Task 1.10 CI skeleton and dev switch (GitHub Actions + scripts/setup-switch.sh)

Phase 2 — Spec Ingestion & Codegen (8/8 ✓)
- [x] Task 2.1 Analyze reference/api.html structure and sections
- [x] Task 2.2 Implement HTML parser to extract "Available types"
- [x] Task 2.3 Implement HTML parser to extract "Available methods"
- [x] Task 2.4 Map Telegram JSON names → OCaml fields (renaming rules)
- [x] Task 2.5 Generate .ml/.mli types with codecs (449 types, module rec, inline converters)
- [x] Task 2.6 Generate method functions (232 methods, fully typed returns)
- [x] Task 2.7 Add generator CLI and regeneration workflow
- [x] Task 2.8 Baseline golden tests for generated outputs

Phase 3 — Core Types & JSON (6/6 ✓)
- [x] Task 3.1 Hand-written foundation types (Money, Duration, File_size, Chat_action)
- [x] Task 3.2 Yojson codecs with unknown-field preservation
- [x] Task 3.3 Phantom-typed IDs and safe conversions
- [x] Task 3.4 Time/units (Duration, File_size with pretty-printing)
- [x] Task 3.5 Polymorphic variants for tagged unions — COMPLETED: parse_mode, chat_action
- [x] Task 3.6 Roundtrip tests against curated samples

Phase 4 — HTTP Engine (3/6)
- [x] Task 4.1 Define Http.S signature (request/response/stream)
- [x] Task 4.2 Implement Cohttp Eio backend — STUB ONLY
- [ ] Task 4.3 Prepare Piaf backend (opt-in)
- [ ] Task 4.4 TLS, timeouts, proxies — PARTIAL: base URL switching only
- [ ] Task 4.5 Multipart/form-data — PARTIAL: naive implementation, no streaming
- [ ] Task 4.6 Response parsing, error mapping — PARTIAL: parsing done, no backoff hooks

Phase 5 — Method Surface (Coverage) (9/10)
NOTE: Code generation COMPLETE and fully type-safe. 449 types, 232 methods auto-generated. Methods return typed values (getMe → User.t, sendMessage → Message.t). Original plan anticipated hand-writing; generator handles all automatically.

- [ ] Task 5.1 Implement request builder — PARTIAL: Api.call/call_json exist
- [x] Task 5.2 Auth/basic methods (getMe, logOut, close) — auto-generated
- [x] Task 5.3 Chats/messages (sendMessage, forward, copy) — auto-generated
- [x] Task 5.4 Media (sendPhoto, sendVideo, etc.) — auto-generated (needs InputFile)
- [x] Task 5.5 Updates (getUpdates, setWebhook) — auto-generated
- [x] Task 5.6 Inline mode and callbacks — auto-generated
- [x] Task 5.7 Paid media, stars, gifts — auto-generated
- [x] Task 5.8 Admin/group management, topics, polls — auto-generated
- [x] Task 5.9 Games, web apps, attachment menu — auto-generated
- [ ] Task 5.10 Ensure unknown/new fields don't break decoding

Phase 6 — Update Intake (0/5)
- [ ] Task 6.1 Long polling runner — STUB ONLY
- [ ] Task 6.2 Webhook runner — STUB ONLY
- [ ] Task 6.3 Secret token verification, IP allowlist hooks
- [ ] Task 6.4 Update batching, offset handling, idempotency
- [ ] Task 6.5 Graceful shutdown and draining

Phase 7 — Ergonomic Bot DSL (2/8)
- [ ] Task 7.1 Context object — PARTIAL: structure exists, helpers stubbed
- [ ] Task 7.2 Router — PARTIAL: API designed, implementation stubbed
- [ ] Task 7.3 Command parser and entity-aware text parsing
- [ ] Task 7.4 Middleware pipeline — PARTIAL: signature exists, not implemented
- [ ] Task 7.5 Scenes/state — PARTIAL: typed session keys exist, storage stubbed
- [ ] Task 7.6 Reply markup builders — PARTIAL: API defined, minimal impl
- [ ] Task 7.7 Internationalization hooks (formatter abstraction)
- [ ] Task 7.8 Error handling strategy (per-route, global)

Phase 8 — Files & Media (1/5)
- [ ] Task 8.1 Download by file_id and via URLs
- [ ] Task 8.2 Uploads — PARTIAL: basic multipart, no streaming
- [ ] Task 8.3 Temp storage policy and backpressure
- [ ] Task 8.4 Media groups and captions entities
- [ ] Task 8.5 Large files and chunking strategy

Phase 9 — Payments & Stars (3/4)
- [x] Task 9.1 Payments API methods and types — auto-generated
- [x] Task 9.2 Stars/paid media: types, price, receipts — auto-generated
- [x] Task 9.3 Subscriptions and gifting flows — types auto-generated
- [ ] Task 9.4 Currency and localization helpers

Phase 10 — Reliability & Limits (1/4)
- [ ] Task 10.1 Rate limit model and token bucket per method
- [ ] Task 10.2 Retry policies — PARTIAL: error model ready, no retry loop
- [ ] Task 10.3 Telemetry hooks for failures and slow calls
- [ ] Task 10.4 Circuit breaker (optional)

Phase 11 — Observability (0/3)
- [ ] Task 11.1 logs integration (Logs/Fmt), redaction
- [ ] Task 11.2 metrics (Prometheus client) and exemplars
- [ ] Task 11.3 tracing (OpenTelemetry) hooks

Phase 12 — Testing & QA (1/5)
- [ ] Task 12.1 Unit tests — PARTIAL: smoke.ml, spec_norm.ml only
- [ ] Task 12.2 Golden tests for generated types/methods
- [ ] Task 12.3 Property tests (QCheck) for JSON roundtrips
- [ ] Task 12.4 Integration tests with local Bot API server
- [ ] Task 12.5 Concurrency tests under Eio switches

Phase 13 — Docs & Examples (2/4)
- [ ] Task 13.1 API docs via odoc, hosted
- [ ] Task 13.2 Examples — PARTIAL: echo_polling.ml, send_photo.ml (stubs)
- [ ] Task 13.3 Migration guide and FAQ
- [x] Task 13.4 Reference to spec sync and regeneration (CONTRIBUTING.md)

Phase 14 — Packaging & Release (0/3)
- [ ] Task 14.1 opam packaging — PARTIAL: basic opam file only
- [ ] Task 14.2 Semantic versioning and changelog
- [ ] Task 14.3 Compatibility policy with Bot API versions


Task Descriptions

Task 1.1 — Decide core architecture, layering, and error strategy
- Outcome: Layered design: Core (types+json), HTTP (backend-agnostic), Low-level API (method wrappers), High-level Bot DSL (router, context, helpers).
- Error model: return ('a, Error.t) result; no raising by default. Provide exception-raising helpers as opt-in.
- Eio integration: construction takes Eio.Stdenv.t once; runtime ops do direct I/O.
- Unknown fields: preserve in Yojson under an _extra field for forward-compat.

Task 1.2 — Choose HTTP backend abstraction and default impl
- Define Http.S: request (method, path, headers, query, body), response (status, headers, body stream), multipart support, timeouts.
- Default: Cohttp + cohttp-eio; Optional: Piaf backend.
- Provide functor Telegram.Make(HTTP) to swap backends without API changes.

Task 1.3 — Choose JSON codec + derivation strategy
- Use yojson + ppx_deriving_yojson for most records/variants.
- Hand-write codecs for tricky unions and performance-sensitive parts.
- Keep field name mapping rules consistent (snake_case JSON ↔ snake_case OCaml with reserved-word escapes).

Task 1.4 — Establish dune workspace, opam metadata and CI skeleton
- dune-project with (using ocaml 5.x); library stanzas; test and examples dirs.
- opam file with dependencies: eio, eio_main, cohttp-eio, yojson, ppx_deriving_yojson, logs, fmt, qcheck, alcotest, prometheus.
- CI: build, test, format check; minimal to start.

Task 1.5 — Decide identifier newtypes and naming conventions
- Identifiers: Telegram.Id with phantom kinds and constructors:
  - Chat.of_int (int64), Chat.of_username (string), Chat.of_string (parse int64 or username)
  - User.of_int/of_username, Message.of_int, Update.of_int
  - Token (newtype wrapper), File_id (string newtype)
  - Utilities: Id.pp, Id.to_string
- Naming: Telegram.* for low-level, Tg.* for high-level DSL, Http for backend.

Task 1.6 — Define result/error types and exception policy
- Error.t revised to carry ResponseParameters: { migrate_to_chat_id; retry_after }.
- Pretty printer shows parameters when present; is_retryable returns true on 429/5xx/Timeout.
- Helpers: Error.retry_after, Error.parameters, Error.or_fail.
- Api.call maps reference/api.html errors: ok=false + error_code + description + parameters.

Task 1.7 — Plan versioning, doc generation, and examples layout
- Version gate: include reported Bot API version in generated module; expose via Telegram.Version.
- odoc config and example indexing; examples runnable under dune exec.
 - Implemented: Telegram.Version module (library_version, bot_api_reference), examples/ with echo_polling and send_photo building under dune, docs buildable via `dune build @doc` when odoc is present.

Task 2.1 — Analyze reference/api.html structure and sections
- Identify anchors for "Available methods" and "Available types"; parse headings, tables, field lists and descriptions.
- Map optionality, default values and constraints (lengths, ranges) for later validation helpers.

Task 2.2 — Implement HTML parser to extract “Available types”
- Implemented: bin/spec_types reads reference/api.html, slices the section between available-types and available-methods, scans <h4> headings (type anchors/titles) and the first following <table>, and extracts rows as fields.
- Intermediate AST: src/spec_ast.{ml,mli} with field and tdef; pretty-printers for debugging.
- Next: strengthen parsing for edge cases (multiple tables, nested notes), and normalize types (e.g., Integer→int64, String→string, etc.) for codegen.

Task 2.3 — Implement HTML parser to extract “Available methods”
- Implemented: bin/spec_methods reads reference/api.html from the “available-methods” anchor, scans each method heading (<h4> anchor+name), extracts the first paragraph for return type, and the parameters table rows.
- Output: pretty-printed method definitions with returns and params using Spec_ast.mdef.
- Next: filter out non-method informational headings (“Formatting options”), refine return-type heuristics (e.g., “True on success”), and normalize parameter types.

Task 2.4 — Map Telegram JSON names → OCaml fields (renaming rules)
- Implemented: src/spec_norm.{ml,mli} with a normalized type algebra and naming helpers.
  - Type algebra: TInt64, TString, TBool, TFloat, TCustom, TArray, TUnion.
  - parse_type maps "Integer"→int64, "String"→string, "Boolean/True"→bool, "Array of T"→list, and splits unions on " or ".
  - ocaml_field_name sanitizes identifiers and escapes reserved words (suffix _).
  - ocaml_type_name converts titles/CamelCase to snake_case.
- Tests: test/spec_norm.ml validates parsing and naming helpers.
- Next: enrich normalization (dates/durations), and map special unions to polymorphic variants for codegen.

Task 2.5 — Generate .ml/.mli types with codecs + tests
- COMPLETED: bin/spec_codegen_types.ml generates module rec blocks with inline to_yojson/of_yojson converters (ppx_deriving_yojson incompatible with module rec).
- Topologically sorts types by dependencies; handles circular dependencies via module rec.
- Outputs to generated/gen_types.ml(i) with full type safety.
- Next: emit docstrings harvested from reference, generate roundtrip tests stubs per type.

Task 2.6 — Generate method functions and request schemas
- COMPLETED: bin/spec_codegen_methods.ml generates fully typed method wrappers for all Telegram Bot API methods.
- Parser extracts return types from HTML (handling "Returns True", type links with uppercase detection).
- Methods return properly typed values (e.g., getMe returns User.t, sendMessage returns Message.t, not raw JSON).
- Automatic JSON encoding/decoding using Module.to_yojson/of_yojson from generated types.
- Outputs to generated/gen_methods.ml with type-safe signatures.
- Next: multipart detection for file uploads, harvest docstrings from reference.

Task 2.7 — Add generator CLI and regeneration workflow
- COMPLETED: bin/telegram_gen orchestrates types and methods generation.
  - `--in` reference path, `--out-dir` target dir (default: generated)
  - `--check` verifies all generated files (gen_types.ml/mli and gen_methods.ml) match the spec, exiting non-zero if not
  - Writes fully typed methods to generated/gen_methods.ml
- Script: scripts/regenerate.sh builds and runs the generator with optional args.
- CONTRIBUTING.md documents regeneration and development workflow.
- Generated code compiles cleanly with dune build @all.

Task 2.8 — Baseline golden tests for generated outputs
- COMPLETED: Golden test infrastructure with baseline files in test/golden/
- Test suite (test/golden.ml) verifies generated code matches golden baselines
- Update utility (test/update_golden.exe) to update baselines after intentional changes
- CI integration: `dune runtest` includes golden tests; regenerate.sh --check validates in CI
- 3 test cases: gen_types.ml, gen_types.mli, gen_methods.ml
- All tests passing with clear error messages showing diff commands when failures occur

Task 3.1 — Hand-written foundation types (identifiers, common enums)
- COMPLETED: Comprehensive foundation type library with elegant, boilerplate-free APIs
- **Money module** (src/money.ml(i)):
  * Type-safe money with currency codes (ISO 4217)
  * Automatic decimal formatting based on currency (JPY=0, BHD=3, USD=2, etc.)
  * Comparison and equality with currency mismatch detection
  * JSON codecs with int64 support for large amounts
  * Pretty-printing: "123.45 USD", "1234 JPY", "12.345 BHD"
- **Units module** (src/units.ml(i)):
  * Duration: newtype for seconds with smart formatting ("45s", "1m30s", "1h1m1s")
  * File_size: newtype for bytes (int64) with SI units ("1.5 KB", "2.0 MB", "1.0 GB")
  * Both with JSON codecs
- **Chat_action module** (src/chat_action.ml(i)):
  * Polymorphic variant enum for sendChatAction
  * 11 action types: typing, upload_photo, record_video, etc.
  * Bidirectional string conversion with pattern matching
  * JSON codecs
- **13 comprehensive tests** in test/foundation.ml covering:
  * Money: basics, decimal places, JSON roundtrip, equality, comparison
  * Duration: formatting, JSON roundtrip
  * File_size: formatting with SI units, JSON roundtrip
  * Chat_action: string conversion, JSON roundtrip
- All tests passing, zero warnings, fully type-safe

Task 3.2 — Yojson codecs with unknown-field preservation
- **COMPLETED**: All generated types now include `unknown_fields` field for forward compatibility
- **Implementation**:
  * Created `Json_compat.Unknown_fields` module with tracker/capture mechanism
  * Modified code generator to add `unknown_fields : Telegram.Json_compat.Unknown_fields.t` to all record types
  * Updated `of_yojson` to track known fields and capture unknown ones
  * Updated `to_yojson` to re-serialize unknown fields alongside known fields
- **Benefits**:
  * Forward compatibility: New Telegram API fields won't break existing code
  * Roundtrip preservation: Deserialize → modify → serialize preserves all fields
  * Type-safe: Unknown fields represented as `(string * Yojson.Safe.t) list`
- **Testing**:
  * Created test/json_compat.ml with 2 tests covering unknown field tracking
  * All 449 generated types now support unknown-field preservation
  * Golden tests updated with new generated code (baselines refreshed)

Task 3.3 — Phantom-typed IDs and safe conversions
- type 'k Id.t with phantom markers Chat_k, User_k; functions ensure no accidental mixing.

Task 3.4 — Time/units: seconds vs ms, file sizes
- COMPLETED: See Task 3.1 - Units module provides Duration and File_size newtypes
- Duration: smart formatting for human readability (45s, 1m30s, 1h1m1s)
- File_size: int64 support for large files (>2^31), SI unit formatting (KB, MB, GB, TB)
- Both types prevent mixing with raw integers, ensuring type safety

Task 3.5 — Polymorphic variants for tagged unions where ergonomic
- COMPLETED:
  - Parse mode as polymorphic variant with codecs: module `Telegram.Parse_mode` provides [`Markdown | `MarkdownV2 | `HTML], `to_string`/`of_string`, `to_yojson`/`of_yojson`, and `pp`. `Telegram.Types.parse_mode` aliases `Parse_mode.t` for ergonomic use across the API and builders.
  - Chat action as polymorphic variant with codecs: module `Telegram.Chat_action` already implements the full set with conversions and JSON.
  - Message builders expose content kinds as variants in `Tg.Msg` (e.g., `Text | `Photo of ...`) to simplify matching and composition.

Task 3.6 — Roundtrip tests against curated samples
- COMPLETED:
  - Added curated JSON samples and roundtrip tests for core generated types (User, Chat) ensuring decode → encode → decode stability and field preservation for representative, real-world snippets from documentation.
  - New test suite: `test/samples.ml` with Alcotest cases; compiled against `ocaml_telegram_eio.generated`.
  - Fixed generator to remove redundant exception cases in `of_yojson` (eliminated unused `Yojson.Safe.Util.Type_error` case when `Util` is opened) to keep builds warning-free under `-warn-error`.
  - Regenerated code and refreshed golden baselines via `test/update_golden.exe`.

Task 3.6 — Roundtrip tests against curated samples
- Build a sample corpus of real-world JSON snippets from docs and bots; ensure decode/encode stability (modulo ordering).

Task 4.1 — Define Http.S signature (request/response/stream)
- Abstract over method, headers, query, body, streams; backpressure-friendly interface over Eio flows.

Task 4.2 — Implement Cohttp Eio backend (default)
- COMPLETED (Stubbed backend wired):
  - Added `Http` abstraction and `Http.Cohttp_eio` module implementing `S`.
  - Shape covers method, headers, JSON bodies and multipart (at API layer).
  - Current build provides a non-raising stub (returns `Not_implemented`) to avoid accidental network in tests.
  - Integration points in `Api` are in place; TLS/streaming/timeouts and actual I/O will be delivered under Task 4.4.

Task 4.3 — Prepare Piaf backend (opt-in)
- Ensure identical Http.S semantics; provide separate package sublib.

Task 4.4 — TLS, timeouts, proxies, base URL switching (local server)
- Support https://api.telegram.org and local Bot API server URL; honor proxies from env.

Task 4.5 — Multipart/form-data and streaming uploads
- Multipart builder that can stream large files; support file_id, URL, and input file; file name and mime type helpers.

Task 4.6 — Response parsing, error mapping, backoff hooks
- Decode {ok; result|description; error_code; parameters}; surface retry_after and migrate_to_chat_id.

Task 5.1 — Implement request builder and execution path
- PARTIALLY COMPLETED: Api.call_json exists and handles JSON request/response.
- Next: Add multipart/form-data path for file uploads; InputFile union type (file_id | url | upload).

Task 5.2 — Cover auth/basic (getMe, logOut, close)
- COMPLETED: All methods auto-generated with correct types (getMe returns User.t, etc.).
- Next: Integration tests with token handling and base URL logic.

Task 5.3 — Cover chats/messages core (sendMessage, forward, copy)
- COMPLETED: All methods auto-generated with full parameter support (parse_mode, entities, reply_parameters, etc.).
- All optional parameters properly typed as option types with labeled arguments.

Task 5.4 — Cover media (photo, video, audio, doc, voice, stickers)
- COMPLETED: All methods auto-generated (sendPhoto, sendVideo, sendAudio, etc.).
- Next: InputFile abstraction for file uploads; detect multipart-required parameters; thumbnails.

Task 5.5 — Cover updates (getUpdates, setWebhook, deleteWebhook)
- COMPLETED: All methods auto-generated with correct signatures.
- Next: Long polling runner implementation; webhook server integration.

Task 5.6 — Cover inline mode and callbacks
- COMPLETED: All methods auto-generated (answerInlineQuery, answerCallbackQuery, editMessage*, etc.).
- All callback and inline types present in generated types.

Task 5.7 — Cover paid media, stars, gifts, subscriptions (9.x)
- COMPLETED: All methods and types auto-generated from reference/api.html (covers latest Bot API).
- Stars, PaidMedia, Gifts, and subscription types fully present.

Task 5.8 — Cover admin/group management, topics, forum, polls
- COMPLETED: All methods auto-generated with labeled optional parameters.
- Covers: kick/ban/restrict/promote members, topics, forums, polls, etc.

Task 5.9 — Cover games, web apps, attachment menu
- COMPLETED: All methods auto-generated (setGameScore, getGameHighScores, etc.).
- Web app and attachment menu types fully generated.

Task 5.10 — Ensure unknown/new fields don’t break decoding
- Fuzz with injected extra fields; assert preservation or benign ignore.

Task 6.1 — Long polling runner with cancellation and backoff
- Runs in an Eio fiber; accepts On_update handler; handles offset progression; jittered backoff on errors.

Task 6.2 — Webhook runner with Eio HTTP server
- Minimal HTTP server; secret token check; JSON body decode; batched and parallel handler execution; backpressure with switch.

Task 6.3 — Secret token verification, IP allowlist hooks
- Provide hooks; default off; sample for Nginx/TLS offload.

Task 6.4 — Update batching, offset handling, idempotency
- Store last Update_id; offer user-supplied persistence hook; at-least-once delivery semantics documented.

Task 6.5 — Graceful shutdown and draining
- Stop intake, wait handlers, ack in-flight webhooks (when possible).

Task 7.1 — Context object (chat, user, reply helpers)
- ctx has chat_id, user, message, answer/reply/edit convenience functions; captures client and logger.

Task 7.2 — Router with composable predicates and matchers
- route [ on_command "start" |> then_ f; on_text (re ...) |> then_ g; on_callback_data (prefix ...) … ]; ordered matching; fallthrough.
 - Follow API_DESIGN.md Router/Matcher signatures closely; deviations require revising the design doc first.

Task 7.3 — Command parser and entity-aware text parsing
- Robust parsing that respects MessageEntity offsets; supports bot usernames in groups; helpers for args parsing.

Task 7.4 — Middleware pipeline (logging, rate-limit, auth)
- Before/after hooks; error boundary per route; ctx enrichers.

Task 7.5 — Scenes/state (typed sessions via phantom keys)
- Session store abstraction; memory + user pluggable; typed keys with phantom types.

Task 7.6 — Reply markup builders (keyboards, inline, menus)
- Combinators to build keyboards succinctly; type-checked sizes; helpers for common patterns.
 - Align builders (names, shapes) with API_DESIGN.md examples.

Task 7.7 — Internationalization hooks (formatter abstraction)
- Allow pluggable message formatting function; locale on ctx inferred from user/language_code.

Task 7.8 — Error handling strategy (per-route, global)
- Structured errors; default handler sends friendly message in dev examples; library doesn’t auto-message.

Task 8.1 — Download by file_id and via URLs
- Helper to getFile, build download URL, stream to writer; content-length exposure.

Task 8.2 — Uploads: multipart builder and streaming
- Stream from Eio.Flow.source; avoid buffering whole file; progress callbacks.

Task 8.3 — Temp storage policy and backpressure
- Configurable temp dir, size limits, cancellation when slow consumer.

Task 8.4 — Media groups and captions entities
- Build album send; enforce constraints (10 items, types rules) at compile/run time where feasible.

Task 8.5 — Large files and chunking strategy
- Ensure chunked transfer compatibility; retries on mid-stream failures with restart.

Task 9.1 — Payments API methods and types
- Invoices, shipping queries, pre-checkout; ergonomic helpers; currency type.

Task 9.2 — Stars/paid media: types, price, receipts
- Surface recent Bot API additions (Stars, paid messages) from reference.

Task 9.3 — Subscriptions and gifting flows
- Manage recurring periods; gift objects decoding; safe price bounds.

Task 9.4 — Currency and localization helpers
- Money module with minor units; formatting utilities.

Task 10.1 — Rate limit model and token bucket per method
- Configurable tokens per window; per-bot or global; preflight estimation.

Task 10.2 — Retry policies (jitter backoff, idempotency keys)
- Retry on 429/5xx; use retry_after; idempotency tokens for safe operations where applicable.

Task 10.3 — Telemetry hooks for failures and slow calls
- Expose events to metrics/tracing; per-method stats.

Task 10.4 — Circuit breaker (optional)
- Trip on consecutive failures; half-open probing.

Task 11.1 — logs integration (Logs/Fmt), redaction
- Log request metadata, not bodies; redact tokens; structured fields.

Task 11.2 — metrics (Prometheus client) and exemplars
- Counters, histograms for latency, sizes; labels: method, status.

Task 11.3 — tracing (OpenTelemetry) hooks
- Span per request; links for webhook processing.

Task 12.1 — Unit tests for codecs and builders
- Alcotest suites per module; ensure good coverage of edge cases.

Task 12.2 — Golden tests for generated types/methods
- Protect against accidental breaking changes; assert diff-free regeneration.

Task 12.3 — Property tests (QCheck) for JSON roundtrips
- Generators for common types; shrinkers for minimal failing cases.

Task 12.4 — Integration tests with local Bot API server
- Spin up telegram-bot-api locally; run live method calls where feasible.

Task 12.5 — Concurrency tests under Eio switches
- Cancellation, timeout, and shutdown behavior validated.

Task 13.1 — API docs via odoc, hosted
- Build with dune build @doc; ensure useful docstrings in generated code.
 - Export examples consistent with API_DESIGN.md and link between docs.

Task 13.2 — Examples: echo, commands, inline, media, payments
- Minimal, readable examples using the DSL; runnable via dune exec.

Task 13.3 — Migration guide and FAQ
- Common pitfalls, breaking changes policy, upgrade steps for Bot API bumps.

Task 13.4 — Reference to spec sync and regeneration
- Document generator usage and checks in CI; add pre-commit.

Task 14.1 — opam packaging and dune-release config
- Prepare opam file(s), dune-release, CHANGES.md; publish instructions.

Task 14.2 — Semantic versioning and changelog
- Follow semver; document API stability tiers (generated vs DSL).

Task 14.3 — Compatibility policy with Bot API versions
- Target latest as default; maintain compatibility shims when breaking.

Notes on Ergonomics & Type Safety (Cross-cutting)
- Labeled optional arguments everywhere with sane defaults; record builders for deeply nested options.
- Abstract identifiers as newtypes with phantom kinds; avoid accidental mixups.
- Use polymorphic variants for open unions to ease matching without extra wrapping.
- Provide both low-level (generated) and high-level (DSL) entry points; ensure zero-cost tendencies where possible.
- Avoid verbosity by auto-deriving JSON encoders and centralizing request execution logic.

Spec Sync Strategy
- The generator consumes reference/api.html from this repo; no network access required to regenerate.
- Recent changes section informs prioritization (e.g., checklist_task_id, Stars, paid messages). Unknown fields are preserved.
- CI locks generated outputs; diffs highlight upstream changes to review quickly.

Acceptance Criteria
- Users can write concise bots with Eio in under 30 lines for common tasks (echo, command handling, inline answers).
- 100% coverage of published Bot API methods and types in generated surface; high-level DSL covers frequent flows.
- Robust handling of retries, rate limits, and graceful shutdown.
- Strong tests for codecs, request builders, and runners; examples run successfully against local Bot API server.
