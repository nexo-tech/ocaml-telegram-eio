# Integration Testing

This document describes how to run integration tests for ocaml-telegram-eio against a mock Telegram Bot API server.

## Overview

Integration tests validate the library's interaction with a Telegram Bot API server. Instead of using the production Telegram API, we use a mock server ([telegram-test-api](https://github.com/jehy/telegram-test-api)) that provides a test environment without requiring real API credentials.

## Prerequisites

- Docker and Docker Compose installed
- OCaml development environment set up

## Quick Start

### 1. Start the Mock Server

```bash
docker compose -f docker-compose.test.yml up -d
```

This starts the telegram-test-api server on `http://localhost:9001`.

### 2. Run Integration Tests

```bash
INTEGRATION_TESTS=1 dune exec test/integration_test.exe
```

Or run all tests including integration tests:

```bash
INTEGRATION_TESTS=1 dune runtest
```

### 3. Stop the Mock Server

```bash
docker compose -f docker-compose.test.yml down
```

## Test Structure

Integration tests are located in `test/integration_test.ml` and cover:

- **Server Connectivity**: Verify mock server is running and accessible
- **Basic API Methods**: getMe, sendMessage, getUpdates
- **Advanced Features**: File uploads, error handling, webhook info
- **Error Scenarios**: Invalid parameters, network errors, API errors

## Mock Server vs Real Server

### Mock Server (telegram-test-api)
- ✅ No API credentials required
- ✅ Fast and predictable
- ✅ Runs in CI/CD
- ✅ Isolated testing
- ❌ Limited feature coverage
- ❌ May not match production behavior exactly

### Real Local Server (tdlib/telegram-bot-api)
- ✅ Official implementation
- ✅ Complete feature coverage
- ✅ Matches production behavior
- ❌ Requires API ID and Hash from https://my.telegram.org
- ❌ Connects to real Telegram infrastructure
- ❌ Slower and more complex

## Configuration

The mock server configuration is in `docker-compose.test.yml`:

```yaml
services:
  telegram-test-api:
    image: ghcr.io/jehy/telegram-test-api:latest
    ports:
      - "9001:9001"
```

Test configuration is in `test/integration_test.ml`:

```ocaml
let test_api_url = "http://localhost:9001"
let test_token = "test_token"  (* Mock server accepts any token *)
```

## Running in CI/CD

Integration tests are skipped by default (marked as `Slow). To enable in CI:

```yaml
# .github/workflows/test.yml
- name: Start mock server
  run: docker compose -f docker-compose.test.yml up -d

- name: Run integration tests
  run: INTEGRATION_TESTS=1 dune runtest

- name: Stop mock server
  run: docker compose -f docker-compose.test.yml down
```

## Current Implementation Status

The integration test framework is currently a **placeholder structure** that demonstrates:

1. How to check if the mock server is available
2. How to conditionally run tests based on environment variables
3. The structure of integration tests

**Full implementation requires**:
- Eio runtime environment in test context
- Client initialization with custom API URL
- Real API method calls
- Response validation
- Error handling verification

This provides a solid foundation for future integration test implementation while documenting the approach and infrastructure.

## Troubleshooting

### Server not starting
```bash
# Check if port 9001 is already in use
lsof -i :9001

# View server logs
docker compose -f docker-compose.test.yml logs
```

### Tests are skipped
```bash
# Ensure INTEGRATION_TESTS=1 is set
echo $INTEGRATION_TESTS

# Check server is running
curl http://localhost:9001/health
```

### Docker issues
```bash
# Clean up and restart
docker compose -f docker-compose.test.yml down
docker compose -f docker-compose.test.yml up -d --force-recreate
```

## Future Enhancements

- [ ] Implement full Eio-based integration tests
- [ ] Add tests for all major API methods
- [ ] Test concurrent request handling
- [ ] Add timeout and retry scenario tests
- [ ] Test file upload/download with large files
- [ ] Add webhook integration tests
- [ ] Performance benchmarking against mock server

## References

- [telegram-test-api](https://github.com/jehy/telegram-test-api) - Mock server implementation
- [Telegram Bot API](https://core.telegram.org/bots/api) - Official API documentation
- [tdlib/telegram-bot-api](https://github.com/tdlib/telegram-bot-api) - Official local server
