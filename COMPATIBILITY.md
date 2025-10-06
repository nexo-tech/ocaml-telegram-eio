# Bot API Compatibility Policy

This document describes how ocaml-telegram-eio handles compatibility with Telegram Bot API versions.

## Overview

The Telegram Bot API evolves over time with new features, methods, and types. This library automatically generates OCaml types and methods from the Bot API specification, ensuring complete coverage and easy updates.

## Version Correspondence

### Library Version → Bot API Version

Each release documents which Bot API version was used for code generation:

| Library Version | Bot API Version | Release Date | Notes |
|-----------------|-----------------|--------------|-------|
| 0.1.0           | ~7.x           | 2025-10-06   | Initial release |

The Bot API version can be checked at runtime:

```ocaml
open Telegram

(* Get library version *)
let lib_version = Version.library_version  (* "0.1.0" *)

(* Get Bot API reference used *)
let api_ref = Version.bot_api_reference    (* Some "reference/api.html" *)
```

## Update Strategy

### When Telegram Releases Bot API Updates

**New Methods/Types (Backwards Compatible):**
- Library MINOR version bump (e.g., 0.1.0 → 0.2.0)
- New methods and types added automatically
- Existing code continues to work
- Update CHANGELOG with new features

**Breaking Changes (Rare):**
- Library MAJOR version bump if breaking (e.g., 1.x.y → 2.0.0)
- Deprecation warnings added first (at least one minor version)
- Migration guide provided in CHANGELOG
- Old methods marked with `[@deprecated]` attributes

**Bug Fixes/Clarifications:**
- Library PATCH version bump (e.g., 0.1.0 → 0.1.1)
- Fix incorrect types or behavior
- Document in CHANGELOG

## Checking for Bot API Updates

### Automatic Checking (Recommended)

Run the bootstrap script weekly to check for updates:

```bash
# Download latest Bot API specification
./scripts/bootstrap.sh

# Check if types need regeneration
./scripts/regenerate.sh

# If changes detected, review and test
git diff generated/
dune runtest
```

### Manual Checking

Visit https://core.telegram.org/bots/api and check the version/changelog:

1. Compare with your local `reference/api.html`
2. Download if changes exist:
   ```bash
   curl -o reference/api.html https://core.telegram.org/bots/api
   ```
3. Regenerate types:
   ```bash
   ./scripts/regenerate.sh
   ```

## Forward Compatibility

### Unknown Field Preservation

The library preserves unknown JSON fields in a special `unknown_fields` field:

```ocaml
type User.t = {
  id : int64;
  first_name : string;
  (* ... known fields ... *)
  unknown_fields : Telegram.Json_compat.Unknown_fields.t;
}
```

**Benefits:**
- Decoding doesn't fail when Telegram adds new fields
- Can inspect unknown fields for debugging
- Graceful degradation with new Bot API versions

**Example:**
```ocaml
(* Bot API adds a new "verified" field to User *)
(* Old library version still works: *)
match Gen_methods.get_me client () with
| Ok user ->
    (* Can access known fields *)
    Printf.printf "User: %s\n" user.first_name;
    (* New "verified" field is in unknown_fields *)
    (* Library update adds it as a proper field *)
| Error e -> (* handle error *)
```

### Optional Fields

Most Telegram types use optional fields extensively:

```ocaml
type Message.t = {
  message_id : int;
  date : int64;
  chat : Chat.t;
  from : User.t option;              (* Optional *)
  text : string option;              (* Optional *)
  reply_to_message : Message.t option; (* Optional *)
  (* ... many more optional fields ... *)
}
```

**Always check optional fields:**
```ocaml
match msg.text with
| Some text -> process_text text
| None -> (* Message has no text (could be photo, document, etc.) *)
```

## Backwards Compatibility Guarantees

### Current (0.x.y) - Unstable

**What we guarantee:**
- ✅ Unknown fields preserved (forward compatible)
- ✅ Changes documented in CHANGELOG
- ✅ Migration guides for breaking changes

**What we don't guarantee:**
- ⚠️ API may change between minor versions
- ⚠️ Types may be renamed/restructured
- ⚠️ Generated code may change

**Recommendation:** Pin to exact version in production:
```lisp
(depends (ocaml_telegram_eio (= 0.1.0)))
```

### Future (1.x.y) - Stable

**What we will guarantee:**
- ✅ No breaking changes in minor versions
- ✅ Deprecation warnings before removal
- ✅ At least one minor version deprecation period
- ✅ Migration guides for major version upgrades

**Recommendation:** Allow minor updates:
```lisp
(depends (ocaml_telegram_eio (and (>= 1.0.0) (< 2.0))))
```

## Handling Bot API Changes

### Scenario 1: New Method Added

**Example:** Telegram adds `sendPaidMedia` method

**Library Response:**
1. Bootstrap script detects new specification
2. Regenerate types automatically includes new method
3. MINOR version bump (0.1.0 → 0.2.0)
4. CHANGELOG documents new method

**User Action:**
- Update library version
- Start using new method immediately
- No changes to existing code

### Scenario 2: New Fields Added to Type

**Example:** `User` type gets new `is_premium` field

**Library Response:**
1. Regenerate adds field as `is_premium : bool option`
2. MINOR version bump
3. Old code continues working (field was in `unknown_fields`)

**User Action:**
- Update library version
- Access new field: `user.is_premium`
- Optional: update code to use new field

### Scenario 3: Field Type Changes (Rare)

**Example:** Field changes from `string` to `int64` (hypothetical)

**Library Response:**
1. MAJOR version bump (breaking change)
2. Deprecation warning in previous minor version
3. Migration guide in CHANGELOG
4. At least one minor version warning period

**User Action:**
- Review CHANGELOG
- Follow migration guide
- Update code to use new type
- Test thoroughly

### Scenario 4: Method Removed (Very Rare)

**Example:** Telegram deprecates old method

**Library Response:**
1. Mark method as `[@deprecated]` in minor version
2. Add deprecation message with alternative
3. Remove in next MAJOR version
4. Migration guide provided

**User Action:**
```ocaml
(* Old code with deprecated method *)
let _ = old_method client ~param ()
[@warning "-3"]  (* Suppress deprecation warning temporarily *)

(* Update to new method *)
let _ = new_method client ~param ()
```

## Testing Against Bot API Versions

### Unit Tests

Generated types have comprehensive tests:

```bash
# Run all tests
dune runtest

# Run specific test suite
dune runtest test/gen_types_test.ml
```

### Golden Tests

Golden tests detect unintended changes in generated code:

```bash
# Check golden test output
dune runtest test/golden/

# Update golden files if changes are intentional
dune promote
```

### Integration Tests

Test against actual Bot API (requires token):

```bash
export TELEGRAM_BOT_TOKEN="your_token"
dune runtest test/integration_test.ml
```

## Specification Management

### Bootstrap Script

The `scripts/bootstrap.sh` script manages API specification downloads:

**Features:**
- Downloads from official Telegram documentation
- Caches with timestamp metadata
- Detects Bot API version
- Suggests update if specification is stale (>7 days)

**Usage:**
```bash
# Download latest specification
./scripts/bootstrap.sh

# Force re-download even if fresh
FORCE_DOWNLOAD=1 ./scripts/bootstrap.sh
```

**What it downloads:**
- `reference/api.html` - Bot API specification (main)
- `reference/features.html` - Feature documentation
- `reference/tutorial.html` - Tutorial/guides

### Regeneration Workflow

After downloading updated specification:

```bash
# 1. Bootstrap (download spec)
./scripts/bootstrap.sh

# 2. Regenerate types and methods
./scripts/regenerate.sh

# 3. Check for changes
git diff generated/

# 4. Run tests
dune runtest

# 5. Update CHANGELOG
# Document new methods/types/changes

# 6. Bump version
# Edit dune-project and src/version.ml

# 7. Commit
git add generated/ reference/.version_cache CHANGELOG.md
git commit -m "Sync with Bot API X.Y"
```

### Reference Directory Structure

```
reference/
├── .gitignore          # Ignore HTML files (downloaded by bootstrap)
├── .version_cache      # Metadata (download time, version)
├── api.html            # (Not in git) Main Bot API spec
├── features.html       # (Not in git) Feature documentation
└── tutorial.html       # (Not in git) Tutorial
```

**Note:** HTML files are NOT committed to git. They are downloaded via bootstrap script.

## Deprecation Policy

### Current (0.x.y)

- Deprecated features noted in CHANGELOG
- May be removed in any minor version
- Use at your own risk

### Future (1.x.y)

**Deprecation Process:**

1. **Minor Version N**: Mark as deprecated
   ```ocaml
   [@deprecated "Use new_method instead. Will be removed in 2.0.0"]
   val old_method : ...
   ```

2. **Minor Version N+1**: Keep deprecated, add warnings
   - Deprecation documented in CHANGELOG
   - Migration guide provided

3. **Major Version N+2**: Remove deprecated feature
   - Breaking change documented
   - Migration guide in CHANGELOG

**Minimum Deprecation Period:** One minor version

## Bot API Rate Limits

The Bot API has rate limits that are separate from library versions:

- **Messages per second**: ~30 per second
- **Messages per minute**: ~20 per minute to same chat
- **Total per second**: ~30 across all chats

**Library Support:**
- Rate limiting is user responsibility (Task 10.1 planned)
- Errors include `retry_after` parameter when rate limited

**Handling rate limits:**
```ocaml
match Gen_methods.send_message client ~chat_id ~text () with
| Ok msg -> Ok msg
| Error err when Error.is_retryable err ->
    (* Check for rate limit *)
    (match Error.retry_after err with
     | Some seconds ->
         (* Wait and retry *)
         Unix.sleep seconds;
         Gen_methods.send_message client ~chat_id ~text ()
     | None ->
         (* Other retryable error *)
         Error err)
| Error err -> Error err
```

## Version Check at Runtime

Detect version mismatches at runtime:

```ocaml
(* Check library version *)
let check_version () =
  Printf.printf "Library version: %s\n" Telegram.Version.library_version;

  (* Make a test API call to verify Bot API compatibility *)
  match Telegram_generated.Gen_methods.get_me client () with
  | Ok user ->
      Printf.printf "Bot API working: @%s\n"
        (Option.value user.username ~default:"");
      Ok ()
  | Error err ->
      Printf.eprintf "Bot API compatibility issue: %a\n"
        Telegram.Error.pp err;
      Error err
```

## Reporting Compatibility Issues

If you encounter Bot API compatibility issues:

1. **Check Bot API version:**
   - Visit https://core.telegram.org/bots/api
   - Compare with library version (see table above)

2. **Update specification:**
   ```bash
   ./scripts/bootstrap.sh
   ./scripts/regenerate.sh
   ```

3. **Still broken? Report issue:**
   - GitHub Issues: https://github.com/yourusername/ocaml-telegram-eio/issues
   - Include: library version, Bot API version, error message
   - Provide: minimal reproduction code

4. **Workaround:**
   - Use older library version temporarily
   - Pin to known-working version
   - Wait for library update

## Migration Guide

See [CHANGELOG.md](CHANGELOG.md) for version-specific migration guides.

### General Migration Tips

**Updating to new minor version (0.1.0 → 0.2.0):**
1. Review CHANGELOG for new features
2. Update opam/dune dependency
3. Check for deprecation warnings
4. Optional: use new features

**Updating to new major version (1.0.0 → 2.0.0):**
1. Read migration guide in CHANGELOG
2. Check breaking changes list
3. Update code following guide
4. Run full test suite
5. Deploy gradually (canary/staging first)

## FAQ

**Q: How often does Telegram update the Bot API?**

A: Typically every few months. Major updates occur 2-4 times per year.

**Q: Will my bot break if Telegram updates the Bot API?**

A: No. The library preserves unknown fields, so new Bot API versions won't break existing code. You just won't have typed access to new features until you update the library.

**Q: Can I use this library with older Bot API versions?**

A: The library is generated from the latest specification. However, unknown field preservation means it should work with newer Bot API versions than it was generated for.

**Q: How do I know which Bot API features are available?**

A: Check the version correspondence table above, or inspect `reference/.version_cache` after running bootstrap script.

**Q: What if I need a feature from newer Bot API?**

A: Run `./scripts/bootstrap.sh && ./scripts/regenerate.sh` to update to latest Bot API. Then update your library version and use the new feature.

**Q: Can I contribute Bot API updates?**

A: Yes! Run bootstrap script, regenerate types, test, and submit PR. See [CONTRIBUTING.md](CONTRIBUTING.md).

## See Also

- [CHANGELOG.md](CHANGELOG.md) - Version history and release notes
- [VERSIONING.md](VERSIONING.md) - Semantic versioning policy
- [CONTRIBUTING.md](CONTRIBUTING.md) - Development workflow
- [Telegram Bot API](https://core.telegram.org/bots/api) - Official documentation
