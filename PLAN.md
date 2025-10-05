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

Phase 1 — Architecture & Tooling
- Task 1.1 Decide core architecture, layering, and error strategy
- Task 1.2 Choose HTTP backend abstraction and default impl
- Task 1.3 Choose JSON codec + derivation strategy
- Task 1.4 Establish dune workspace, opam metadata and CI skeleton
- Task 1.5 Decide identifier newtypes and naming conventions
- Task 1.6 Define result/error types and exception policy
- Task 1.7 Plan versioning, doc generation, and examples layout
- Task 1.8 Draft and lock API_DESIGN.md (public API specification)
 - Task 1.9 Choose JSON codec + derivation: yojson + ppx_deriving_yojson wired; generated Telegram.Types will auto-derive codecs; hand-written codecs possible for tricky unions. Unknown fields currently tolerated; preservation to be added during codegen.
 - Task 1.10 CI skeleton and dev switch: GitHub Actions workflow (Linux/macOS, OCaml 5.2.x) and scripts/setup-switch.sh to create a local opam switch and install deps.
  - Iterate to v2 features (typed events, Request/Api.call, Msg builders, Action codecs) and freeze public names before scaffolding.

Phase 2 — Spec Ingestion & Codegen
- Task 2.1 Analyze reference/api.html structure and sections
- Task 2.2 Implement HTML parser to extract “Available types”
- Task 2.3 Implement HTML parser to extract “Available methods”
- Task 2.4 Map Telegram JSON names → OCaml fields (renaming rules)
- Task 2.5 Generate .ml/.mli types with codecs + tests
- Task 2.6 Generate method functions and request schemas
- Task 2.7 Add generator CLI and regeneration workflow
- Task 2.8 Baseline golden tests for generated outputs

Phase 3 — Core Types & JSON
- Task 3.1 Hand-written foundation types (identifiers, common enums)
- Task 3.2 Yojson codecs with unknown-field preservation
- Task 3.3 Phantom-typed IDs and safe conversions
- Task 3.4 Time/units: seconds vs ms, file sizes
- Task 3.5 Polymorphic variants for tagged unions where ergonomic
- Task 3.6 Roundtrip tests against curated samples

Phase 4 — HTTP Engine
- Task 4.1 Define Http.S signature (request/response/stream)
- Task 4.2 Implement Cohttp Eio backend (default)
- Task 4.3 Prepare Piaf backend (opt-in)
- Task 4.4 TLS, timeouts, proxies, base URL switching (local server)
- Task 4.5 Multipart/form-data and streaming uploads
- Task 4.6 Response parsing, error mapping, backoff hooks

Phase 5 — Method Surface (Coverage)
- Task 5.1 Implement request builder and execution path
- Task 5.2 Cover auth/basic (getMe, logOut, close)
- Task 5.3 Cover chats/messages core (sendMessage, forward, copy)
- Task 5.4 Cover media (photo, video, audio, doc, voice, stickers)
- Task 5.5 Cover updates (getUpdates, setWebhook, deleteWebhook)
- Task 5.6 Cover inline mode and callbacks
- Task 5.7 Cover paid media, stars, gifts, subscriptions (9.x)
- Task 5.8 Cover admin/group management, topics, forum, polls
- Task 5.9 Cover games, web apps, attachment menu
- Task 5.10 Ensure unknown/new fields don’t break decoding

Phase 6 — Update Intake
- Task 6.1 Long polling runner with cancellation and backoff
- Task 6.2 Webhook runner with Eio HTTP server
- Task 6.3 Secret token verification, IP allowlist hooks
- Task 6.4 Update batching, offset handling, idempotency
- Task 6.5 Graceful shutdown and draining

Phase 7 — Ergonomic Bot DSL
- Task 7.1 Context object (chat, user, reply helpers)
- Task 7.2 Router with composable predicates and matchers
- Task 7.3 Command parser and entity-aware text parsing
- Task 7.4 Middleware pipeline (logging, rate-limit, auth)
- Task 7.5 Scenes/state (typed sessions via phantom keys)
- Task 7.6 Reply markup builders (keyboards, inline, menus)
- Task 7.7 Internationalization hooks (formatter abstraction)
- Task 7.8 Error handling strategy (per-route, global)

Phase 8 — Files & Media
- Task 8.1 Download by file_id and via URLs
- Task 8.2 Uploads: multipart builder and streaming
- Task 8.3 Temp storage policy and backpressure
- Task 8.4 Media groups and captions entities
- Task 8.5 Large files and chunking strategy

Phase 9 — Payments & Stars
- Task 9.1 Payments API methods and types
- Task 9.2 Stars/paid media: types, price, receipts
- Task 9.3 Subscriptions and gifting flows
- Task 9.4 Currency and localization helpers

Phase 10 — Reliability & Limits
- Task 10.1 Rate limit model and token bucket per method
- Task 10.2 Retry policies (jitter backoff, idempotency keys)
- Task 10.3 Telemetry hooks for failures and slow calls
- Task 10.4 Circuit breaker (optional)

Phase 11 — Observability
- Task 11.1 logs integration (Logs/Fmt), redaction
- Task 11.2 metrics (Prometheus client) and exemplars
- Task 11.3 tracing (OpenTelemetry) hooks

Phase 12 — Testing & QA
- Task 12.1 Unit tests for codecs and builders
- Task 12.2 Golden tests for generated types/methods
- Task 12.3 Property tests (QCheck) for JSON roundtrips
- Task 12.4 Integration tests with local Bot API server
- Task 12.5 Concurrency tests under Eio switches

Phase 13 — Docs & Examples
- Task 13.1 API docs via odoc, hosted
- Task 13.2 Examples: echo, commands, inline, media, payments
- Task 13.3 Migration guide and FAQ
- Task 13.4 Reference to spec sync and regeneration

Phase 14 — Packaging & Release
- Task 14.1 opam packaging and dune-release config
- Task 14.2 Semantic versioning and changelog
- Task 14.3 Compatibility policy with Bot API versions


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
- Codegen from AST into lib/telegram/types.ml(i) with ppx_deriving_yojson.
- Emit docstrings harvested from reference.
- Generate roundtrip tests stubs per type.

Task 2.6 — Generate method functions and request schemas
- Emit lib/telegram/methods.ml(i): typed functions with labeled optional params and defaults; encoder selects JSON vs multipart per method.
- Return ('a, Error.t) result.

Task 2.7 — Add generator CLI and regeneration workflow
- bin/telegram_gen: reads reference/api.html, writes generated modules; supports --check to verify cleanliness.
- Document in CONTRIBUTING how to regenerate when Bot API updates.

Task 2.8 — Baseline golden tests for generated outputs
- Golden files for generated .ml(i) to detect spec changes; CI diff if drift.

Task 3.1 — Hand-written foundation types (identifiers, common enums)
- Modules: Ids, Money, Parse_mode, Chat_member_status, etc., with codecs and invariants.

Task 3.2 — Yojson codecs with unknown-field preservation
- For core objects prone to extensions (Message, Update), keep extra fields map for forward compatibility.

Task 3.3 — Phantom-typed IDs and safe conversions
- type 'k Id.t with phantom markers Chat_k, User_k; functions ensure no accidental mixing.

Task 3.4 — Time/units: seconds vs ms, file sizes
- Provide safe constructors and printers; validate ranges from reference when available.

Task 3.5 — Polymorphic variants for tagged unions where ergonomic
- For content types (message kinds), use [ `Text | `Photo of ... | ... ] where it simplifies matching.

Task 3.6 — Roundtrip tests against curated samples
- Build a sample corpus of real-world JSON snippets from docs and bots; ensure decode/encode stability (modulo ordering).

Task 4.1 — Define Http.S signature (request/response/stream)
- Abstract over method, headers, query, body, streams; backpressure-friendly interface over Eio flows.

Task 4.2 — Implement Cohttp Eio backend (default)
- Streaming request/response, timeouts, TLS via Eio.Net.

Task 4.3 — Prepare Piaf backend (opt-in)
- Ensure identical Http.S semantics; provide separate package sublib.

Task 4.4 — TLS, timeouts, proxies, base URL switching (local server)
- Support https://api.telegram.org and local Bot API server URL; honor proxies from env.

Task 4.5 — Multipart/form-data and streaming uploads
- Multipart builder that can stream large files; support file_id, URL, and input file; file name and mime type helpers.

Task 4.6 — Response parsing, error mapping, backoff hooks
- Decode {ok; result|description; error_code; parameters}; surface retry_after and migrate_to_chat_id.

Task 5.1 — Implement request builder and execution path
- Single path to construct URL, method, query/body, headers; JSON vs multipart selection; consistent error handling.

Task 5.2 — Cover auth/basic (getMe, logOut, close)
- Ensure token handling and base URL logic correct; simple smoke tests.

Task 5.3 — Cover chats/messages core (sendMessage, forward, copy)
- Rich options: parse modes, entities, disable_web_page_preview, reply_parameters.

Task 5.4 — Cover media (photo, video, audio, doc, voice, stickers)
- InputFile abstraction; thumbnails; duration, width/height; spoilers.

Task 5.5 — Cover updates (getUpdates, setWebhook, deleteWebhook)
- Long polling and webhook plumbing; secret token.

Task 5.6 — Cover inline mode and callbacks
- answerInlineQuery, editMessage*; callback query answer; switching between chat/inline contexts ergonomically.

Task 5.7 — Cover paid media, stars, gifts, subscriptions (9.x)
- Types and methods present in reference/api.html (Recent changes section); guarded behind availability constants.

Task 5.8 — Cover admin/group management, topics, forum, polls
- All standard endpoints; ensure argument ergonomics via labeled optionals with defaults.

Task 5.9 — Cover games, web apps, attachment menu
- GameHighScore, setGameScore; web app data handling; attachment menu integration types.

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
