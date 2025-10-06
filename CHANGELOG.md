# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Rate limiting and token bucket implementation (Task 10.1)
- Retry policies with exponential backoff (Task 10.2)
- Telemetry hooks for failures and slow calls (Task 10.3)
- Circuit breaker pattern (Task 10.4)
- Logging integration with Logs library (Task 11.1)
- Metrics with Prometheus client (Task 11.2)
- OpenTelemetry tracing hooks (Task 11.3)

### Planned
- Full Bot DSL router implementation
- Middleware pipeline
- Scene/state management
- Additional high-level helpers

## [0.1.0] - 2025-10-06

### Added - Initial Alpha Release

This is the first alpha release of ocaml-telegram-eio, a production-grade Telegram Bot API
client library for OCaml 5.x built on Eio for structured concurrency.

**Bot API Version:** 9.2 (October 2025)

#### Core Infrastructure (Phase 1)
- Layered architecture: Core types, HTTP abstraction, Low-level API, High-level DSL
- Result-based error handling (no exceptions by default)
- Phantom-typed identifiers (Chat, User, Message, etc.) for type safety
- Eio integration for direct-style structured concurrency
- HTTP backend abstraction with cohttp-eio default implementation
- JSON codecs with yojson and ppx_deriving_yojson
- Project structure with dune workspace, opam packaging, and CI skeleton

#### Type System and Code Generation (Phase 2-3)
- Spec-driven code generation from Telegram Bot API HTML reference
- Parser for "Available types" section (449 types extracted)
- Parser for "Available methods" section (232 methods extracted)
- Type normalization and OCaml field name mapping
- Generated types with inline JSON codecs (module rec for circular deps)
- Generated method wrappers with full type safety
- Unknown field preservation for forward compatibility
- Parse_mode polymorphic variants (Markdown, HTML, MarkdownV2)
- Curated roundtrip tests for generated types
- Golden tests for regression prevention

#### HTTP and Networking (Phase 4)
- HTTP client abstraction (Http.S signature)
- Cohttp-eio backend implementation
- HTTPS support with tls-eio and ca-certs
- Request timeouts (configurable via TELEGRAM_HTTP_TIMEOUT)
- Streaming multipart/form-data for file uploads
- Response parsing and error mapping
- SNI (Server Name Indication) support

#### Complete Bot API Coverage (Phase 5)
- All 232 Bot API methods auto-generated and typed
- Method categories:
  - Authentication: getMe, logOut, close
  - Messaging: sendMessage, forwardMessage, copyMessage
  - Media: sendPhoto, sendVideo, sendDocument, sendAudio, sendAnimation, sendVoice, sendVideoNote
  - Updates: getUpdates, setWebhook, deleteWebhook
  - Inline mode: answerInlineQuery, answerWebAppQuery
  - Payments: sendInvoice, answerShippingQuery, answerPreCheckoutQuery
  - Stars: createInvoiceLink, refundStarPayment
  - Admin: banChatMember, unbanChatMember, restrictChatMember
  - Groups: getChatAdministrators, getChatMember, getChatMemberCount
  - Topics: createForumTopic, editForumTopic, closeForumTopic
  - Polls: sendPoll, stopPoll
  - Games: sendGame, setGameScore, getGameHighScores
  - Web Apps: answerWebAppQuery
  - Stickers: sendSticker, getStickerSet, uploadStickerFile

#### Update Handling (Phase 6)
- Long polling runner with offset management
- Webhook runner with HTTP server
- Secret token verification for webhooks
- IP allowlist hooks for security
- Update batching and idempotency
- Graceful shutdown and draining
- Automatic retry on transient failures

#### High-Level Bot DSL (Phase 7 - Partial)
- Bot context object with typed methods
- Command parser with entity-aware text parsing
- Reply markup builders (keyboards)
- Error handling strategy (Result-based)
- Keyboard module with reply and inline keyboard builders
- Polling module for long polling
- Webhook module for webhook servers

#### Files and Media (Phase 8)
- File download by file_id and URLs
- Streaming file uploads (constant memory usage)
- Temporary storage with automatic cleanup
- Media groups with captions and entities
- Large file support with chunking strategies
- Album composition helpers
- Input file abstraction (file_id, URL, path, bytes, stream)

#### Payments and Monetization (Phase 9)
- Payment types and methods (auto-generated)
- Stars API for paid media and content
- Currency helpers with proper minor unit handling
- Invoice creation and management
- Shipping query handling
- Pre-checkout query handling
- Receipt validation

#### Testing Infrastructure (Phase 12)
- Unit tests for core modules (Client, Error, Id, Parse_mode, etc.)
- Golden tests for generated types and methods
- Property-based tests with QCheck for JSON roundtrips
- Integration tests with local Bot API server
- Concurrency tests under Eio switches and fibers
- Test coverage for error handling paths

#### Documentation and Examples (Phase 13)
- API documentation via odoc with hosted output
- Four complete example bots:
  - echo_bot.ml: Simple echo bot with long polling
  - command_bot.ml: Command routing and argument parsing
  - keyboard_bot.ml: Interactive keyboards and callbacks
  - file_bot.ml: File uploads and downloads
- Migration guide from Lwt/Async and other libraries
- Comprehensive FAQ with troubleshooting
- API design rationale document
- Contributing guide with spec regeneration workflow

#### Packaging and Release (Phase 14)
- Comprehensive opam package metadata
- MIT License
- README with quick start and feature overview
- Semantic versioning policy (this changelog)
- Complete dependency list with version constraints
- Installation and development instructions

### Architecture Highlights

- **Type Safety**: Phantom-typed IDs prevent mixing different ID types at compile time
- **Forward Compatibility**: Unknown JSON fields preserved for future Bot API updates
- **Performance**: Streaming I/O for files, no global locks, minimal overhead
- **Reliability**: Result-based error handling, structured concurrency, automatic cleanup
- **Maintainability**: Spec-driven codegen keeps API in sync with Telegram updates

### Dependencies

**Core Runtime**:
- OCaml 5.1.0+ (for Eio effects)
- Eio 0.12+ (structured concurrency)
- yojson 2.0+ (JSON parsing)
- cohttp-eio 5.0+ (HTTP client)
- tls-eio 0.17+ (HTTPS support)

**Testing**:
- alcotest (unit testing)
- qcheck (property-based testing)

**Documentation**:
- odoc (API documentation generation)

See [ocaml_telegram_eio.opam](ocaml_telegram_eio.opam) for complete list.

### Known Limitations

- High-level Bot DSL router is designed but not fully implemented
- Rate limiting must be implemented by users (Task 10.1 pending)
- Retry policies must be implemented by users (Task 10.2 pending)
- No built-in logging/metrics/tracing (Tasks 11.1-11.3 pending)
- Middleware pipeline signature exists but not implemented
- Scene/state management API designed but stubbed

### Breaking Changes

None - this is the initial release.

### Migration Guide

See [docs/MIGRATION.md](docs/MIGRATION.md) for detailed migration guides from:
- Lwt/Async to Eio
- Other Telegram bot libraries
- Raw Bot API calls to typed methods

### Security

- HTTPS with certificate verification (ca-certs)
- Webhook secret token support
- No credentials in logs (use redaction in your logging setup)
- Unknown field preservation doesn't expose sensitive data

### Contributors

- Oleg Pustovit <oleg@nexo.sh> - Initial implementation

---

## Version History

- **0.1.0** (2025-10-06) - Initial alpha release with complete Bot API coverage

## Versioning Policy

This project follows [Semantic Versioning 2.0.0](https://semver.org/):

### Version Format: MAJOR.MINOR.PATCH

**MAJOR** version increments when:
- Incompatible API changes (breaking changes)
- Removal of deprecated features
- Major architectural redesigns

**MINOR** version increments when:
- New features added in a backwards-compatible manner
- New Bot API types or methods added
- Deprecations (but not removals)
- Significant performance improvements

**PATCH** version increments when:
- Backwards-compatible bug fixes
- Documentation improvements
- Dependency updates (if no API changes)
- Performance improvements without API changes

### Stability Guarantees

**0.x.y releases (Current)**:
- Alpha/Beta quality
- API may change between minor versions
- No strong stability guarantees
- Suitable for early adopters and testing

**1.x.y releases (Future)**:
- Stable API with strong backwards compatibility
- Breaking changes only in major versions
- Deprecation warnings before removal (at least one minor version)
- Suitable for production use

### Bot API Version Tracking

The library tracks the Telegram Bot API version used for code generation:
- Regenerate types/methods when Bot API updates
- Minor version bump when regenerating (new types/methods added)
- Document Bot API version in each release

See [Task 14.3](PLAN.md) for detailed Bot API compatibility policy.

### Deprecation Policy (1.0+)

When stable (1.0+):
1. Deprecated features will remain for at least one minor version
2. Deprecation warnings in documentation and docstrings
3. Migration guide provided in CHANGELOG
4. Removal only in next major version

### Pre-release Versions

- `-alpha.N`: Early development, frequent breaking changes
- `-beta.N`: Feature complete, API stabilizing, bug fixes only
- `-rc.N`: Release candidate, production-ready if no issues found

Example: `0.2.0-alpha.1`, `1.0.0-beta.2`, `1.0.0-rc.1`

---

## Development

See [CONTRIBUTING.md](CONTRIBUTING.md) for development workflow, including:
- How to regenerate types from Bot API spec
- Testing requirements for contributions
- Code review process
- Release procedure
