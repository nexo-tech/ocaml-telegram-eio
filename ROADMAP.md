# ROADMAP.md

**Library Development Roadmap**

This document tracks the progress of library development in two phases:
- **Phase 1**: Documentation examples implementation (COMPLETE ✓)
- **Phase 2**: Remaining library features and production readiness

---

## Phase 1: Documentation & Examples (37/37 tasks - 100% ✓)

**Goal**: Implement every example from documentation in `examples/` directory with clean, functional API.

**Status**: COMPLETE - All 37 documentation tasks finished. All examples compile, demonstrate best practices, and use Result-based error handling with verbose logging.

### Summary by Section

- ✅ **Phase 1.1.1**: Core Concepts & Getting Started (3/3 tasks)
- ✅ **Phase 1.1.2**: Recipe Examples - Cookbook (12/12 tasks)
- ✅ **Phase 1.1.3**: API Components (9/9 tasks)
- ✅ **Phase 1.1.4**: Advanced Patterns (4/4 tasks)
- ✅ **Phase 1.1.5**: Use Cases (4/4 tasks)
- ✅ **Phase 1.1.6**: Project Setup & Development (3/3 tasks)
- ✅ **Phase 1.1.7**: Reference & FAQ (2/2 tasks)

**Key Achievements**:
- 40+ working examples covering all documentation
- Functional builder pattern (`Bot.make |> command |> run`)
- Result-based error handling throughout
- Comprehensive logging for troubleshooting
- All examples compile with zero warnings

---

## Phase 2: Library Features & Production Readiness (7/14 tasks - 50%)

**Goal**: Complete remaining library features for production use.

### 2.1: Reliability & Limits (1/4 tasks)

- [ ] **Task 2.1.1**: Rate limit model with token bucket per method
  - Implement configurable rate limiting for Bot API methods
  - Track limits per method group (e.g., sendMessage vs sendPhoto)
  - Provide backpressure mechanism when approaching limits

- [ ] **Task 2.1.2**: Retry policies with exponential backoff
  - Automatic retry for transient errors (network, 429, 500)
  - Configurable retry strategies (attempts, delays, jitter)
  - Respect Retry-After headers from Bot API

- [ ] **Task 2.1.3**: Telemetry hooks for failures and slow calls
  - Callbacks for request failures
  - Metrics for request latency
  - Hooks for custom monitoring/alerting

- [ ] **Task 2.1.4**: Circuit breaker (optional)
  - Automatic failure detection
  - Circuit open/half-open/closed states
  - Configurable thresholds and recovery

### 2.2: Observability (0/3 tasks)

- [ ] **Task 2.2.1**: Structured logging integration
  - Integration with OCaml Logs library
  - Log level filtering
  - Sensitive data redaction (tokens, user data)

- [ ] **Task 2.2.2**: Metrics and monitoring
  - Prometheus client integration
  - Request/response metrics
  - Error rate tracking
  - Latency histograms

- [ ] **Task 2.2.3**: Distributed tracing
  - OpenTelemetry integration
  - Trace context propagation
  - Span annotations for API calls

### 2.3: Advanced Bot DSL (3/4 tasks)

- [x] **Task 2.3.1**: Context and routing - COMPLETE
  - Context with phantom types
  - Event routing system
  - Handler composition

- [x] **Task 2.3.2**: Command parser and text parsing - COMPLETE
  - Bot.Args helpers (expect_*, parse_*, join_*)
  - Entity-aware text extraction
  - Argument validation

- [x] **Task 2.3.3**: Reply markup builders - COMPLETE
  - Keyboard.reply and Keyboard.inline
  - Type-safe keyboard construction
  - Layout helpers

- [ ] **Task 2.3.4**: Middleware pipeline improvements
  - Composable middleware stack
  - Built-in middleware (logging, auth, rate limiting)
  - Error recovery middleware

### 2.4: Backend & Performance (3/3 tasks)

- [x] **Task 2.4.1**: HTTP backend abstraction - COMPLETE
  - Http.S signature defined
  - Cohttp-eio implementation
  - Functor-based backend selection

- [x] **Task 2.4.2**: TLS, timeouts, proxies - COMPLETE
  - TLS support via tls-eio
  - Configurable timeouts
  - Proxy support

- [x] **Task 2.4.3**: Streaming uploads/downloads - COMPLETE
  - Efficient streaming file I/O
  - Large file support
  - Memory-efficient media handling

---

## Completion Summary

| Phase | Tasks Complete | Progress |
|-------|---------------|----------|
| Phase 1: Documentation & Examples | 37/37 | 100% ✓ |
| Phase 2: Production Features | 7/14 | 50% |
| **Total** | **44/51** | **86%** |

---

## Next Steps

### High Priority
1. **Rate Limiting** (Task 2.1.1) - Critical for production bots
2. **Retry Policies** (Task 2.1.2) - Improve reliability
3. **Middleware Pipeline** (Task 2.3.4) - Complete DSL functionality

### Medium Priority
4. **Structured Logging** (Task 2.2.1) - Better observability
5. **Metrics** (Task 2.2.2) - Production monitoring

### Low Priority
6. **Circuit Breaker** (Task 2.1.4) - Nice-to-have for high-volume bots
7. **Distributed Tracing** (Task 2.2.3) - Advanced use cases

---

## Version Planning

- **v0.1.0** (Current - Alpha): Core functionality, all examples ✓
- **v0.2.0** (Next): Rate limiting, retry policies, improved middleware
- **v0.3.0**: Observability (logging, metrics)
- **v1.0.0**: Production-ready with all Phase 2 features

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development workflow and guidelines.

To work on a specific task:
1. Check this roadmap for open tasks
2. Read the task description
3. Implement with tests
4. Update this file to mark task complete
5. Submit PR with reference to task number
