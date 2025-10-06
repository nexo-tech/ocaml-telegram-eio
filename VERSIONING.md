# Versioning Policy

This document describes the versioning policy for ocaml-telegram-eio.

## Semantic Versioning

This project adheres to [Semantic Versioning 2.0.0](https://semver.org/).

### Version Format

```
MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]
```

Examples:
- `0.1.0` - Initial alpha release
- `0.2.0-alpha.1` - Alpha pre-release
- `1.0.0-beta.2` - Beta pre-release
- `1.0.0-rc.1` - Release candidate
- `1.0.0` - First stable release
- `1.2.3` - Stable patch release

## Version Components

### MAJOR (Breaking Changes)

Increment when making incompatible API changes:

**Examples of breaking changes:**
- Removing public modules, types, or functions
- Changing function signatures (parameters, return types)
- Renaming modules or changing module structure
- Changing behavior that code depends on
- Removing or changing error types
- Modifying phantom type parameters

**What constitutes a breaking change:**
```ocaml
(* Breaking: changing signature *)
val send_message : client -> chat_id:Id.Chat.t -> text:string -> (Message.t, Error.t) result
(* to *)
val send_message : client -> chat_id:Id.Chat.t -> text:string -> ?parse_mode:string -> (Message.t, Error.t) result
(* This is OK - adding optional parameter is backwards compatible *)

(* Breaking: removing function *)
val get_me : client -> (User.t, Error.t) result
(* Removed - this breaks existing code *)

(* Breaking: changing return type *)
val poll : client -> handler:(update -> unit) -> unit
(* to *)
val poll : client -> handler:(update -> unit) -> (unit, Error.t) result
```

**Not breaking:**
- Adding new modules, types, or functions
- Adding optional parameters (with defaults)
- Adding fields to records (with unknown_fields mechanism)
- Deprecating (but not removing) features
- Bug fixes that change behavior to match documentation

### MINOR (New Features)

Increment when adding functionality in a backwards-compatible manner:

**Examples of minor version changes:**
- Adding new modules (Telegram.NewFeature)
- Adding new functions to existing modules
- Adding optional parameters to functions (with sensible defaults)
- Adding new types or variants
- Adding new methods from Bot API updates
- Performance improvements without API changes
- Deprecating features (marking for future removal)

**Examples:**
```ocaml
(* Adding new optional parameter - MINOR *)
val send_message
  : client
  -> chat_id:Id.Chat.t
  -> text:string
  -> ?parse_mode:string       (* existing *)
  -> ?reply_markup:string     (* NEW - optional with default *)
  -> (Message.t, Error.t) result

(* Adding new function - MINOR *)
val send_poll
  : client
  -> chat_id:Id.Chat.t
  -> question:string
  -> options:string list
  -> (Message.t, Error.t) result

(* Adding new module - MINOR *)
module Payments : sig
  val send_invoice : ...
end
```

### PATCH (Bug Fixes)

Increment for backwards-compatible bug fixes:

**Examples of patch changes:**
- Fixing bugs that don't change API
- Fixing incorrect behavior to match documentation
- Documentation improvements
- Internal refactoring without API changes
- Dependency updates (if no API impact)
- Performance improvements (if no API changes)
- Test improvements

**Examples:**
```ocaml
(* Bug fix: incorrect field type *)
type User.t = {
  id : int64;
  first_name : string;
  username : string option;  (* was: string - this is a PATCH fix *)
}

(* Bug fix: incorrect error handling *)
let send_message client ~chat_id ~text =
  (* Before: crashed on timeout *)
  (* After: returns Error (Timeout) *)
  ...
```

## Pre-release Versions

### Alpha (`-alpha.N`)

**Purpose**: Early development, API exploration

**Characteristics:**
- API may change frequently
- Features incomplete or experimental
- May have known bugs
- Not recommended for production
- Documentation may be incomplete

**Example**: `0.2.0-alpha.1`

**When to use:**
- Major refactoring in progress
- Exploring new API designs
- Soliciting early feedback

### Beta (`-beta.N`)

**Purpose**: Feature complete, API stabilizing

**Characteristics:**
- All planned features implemented
- API mostly stable (only minor changes expected)
- Suitable for testing and feedback
- Documentation complete
- Known bugs being fixed

**Example**: `0.3.0-beta.2`

**When to use:**
- Feature complete for the release
- Ready for broader testing
- API unlikely to change significantly

### Release Candidate (`-rc.N`)

**Purpose**: Production-ready if no critical issues found

**Characteristics:**
- API frozen (no changes except critical fixes)
- All tests passing
- Documentation reviewed and complete
- Ready for production if no issues found
- Only critical bug fixes accepted

**Example**: `1.0.0-rc.1`

**When to use:**
- Preparing for stable release
- Final testing phase
- Confidence in stability

## Stability Levels

### 0.x.y (Current - Unstable)

**Status**: Alpha/Beta quality

**Guarantees:**
- ⚠️ API may change between minor versions
- ⚠️ Breaking changes possible in any release
- ⚠️ Limited backwards compatibility
- ✅ Changes documented in CHANGELOG
- ✅ Migration guides provided for major changes

**Recommendation**:
- Suitable for experimentation and early adoption
- Pin to specific version in production
- Review CHANGELOG before upgrading

### 1.x.y (Future - Stable)

**Status**: Production quality

**Guarantees:**
- ✅ API stable across minor versions
- ✅ Breaking changes only in major versions (2.0, 3.0, etc.)
- ✅ Deprecation warnings before removal
- ✅ Migration guides for all breaking changes
- ✅ Semantic versioning strictly followed

**Recommendation**:
- Suitable for production use
- Safe to upgrade patch versions
- Review deprecations before minor upgrades
- Plan for migration on major upgrades

## Bot API Version Tracking

The library is synchronized with the [Telegram Bot API](https://core.telegram.org/bots/api).

### Version Correspondence

Each release documents the Bot API version used:

```markdown
## [0.2.0] - 2025-11-01

### Bot API Sync
- Synchronized with Bot API 7.0 (October 2025)
- Added: sendPaidMedia, getPaidMediaInfo
- Added: TransactionPartner types
```

### Update Policy

**When Bot API updates:**
1. Minor version bump (e.g., 0.1.0 → 0.2.0)
2. Regenerate types and methods from updated spec
3. Document new/changed types in CHANGELOG
4. Preserve backwards compatibility where possible

**Breaking changes in Bot API:**
- If Telegram removes a method/type: deprecate in minor, remove in next major
- If Telegram changes behavior: document and update

See [Task 14.3](PLAN.md) and [COMPATIBILITY.md](COMPATIBILITY.md) for details.

## Version Bumping Workflow

### For Maintainers

**1. Determine version bump:**
```bash
# Check what changed since last release
git log v0.1.0..HEAD --oneline

# Classify changes:
# - Breaking changes? → MAJOR
# - New features? → MINOR
# - Bug fixes only? → PATCH
```

**2. Update version:**
```bash
# Edit version in these files:
# - dune-project (version field)
# - src/version.ml (library_version)

# Example: bumping to 0.2.0
sed -i '' 's/(version 0.1.0)/(version 0.2.0)/' dune-project
sed -i '' 's/library_version = "0.1.0"/library_version = "0.2.0"/' src/version.ml

# Regenerate opam file
dune build
```

**3. Update CHANGELOG.md:**
```markdown
## [0.2.0] - 2025-11-01

### Added
- New feature X
- Support for Bot API method Y

### Changed
- Improved performance of Z

### Fixed
- Bug in error handling

### Deprecated
- Old function X (use Y instead)
```

**4. Tag and release:**
```bash
git add dune-project src/version.ml CHANGELOG.md ocaml_telegram_eio.opam
git commit -m "Bump version to 0.2.0"
git tag -a v0.2.0 -m "Release version 0.2.0"
git push origin dev --tags
```

**5. Create GitHub release:**
- Go to GitHub Releases
- Create release from tag v0.2.0
- Copy CHANGELOG entry as release notes
- Attach any relevant artifacts

## Deprecation Policy

**Current (0.x.y):**
- Deprecations noted in CHANGELOG
- No guarantee on how long deprecated features remain
- May be removed in next minor version

**Future (1.x.y):**
- Deprecated features remain for at least one minor version
- Deprecation warnings in documentation
- `[@deprecated]` attributes in code
- Migration guide provided
- Removal only in next major version

**Example deprecation:**
```ocaml
(** [old_function] is deprecated. Use {!new_function} instead.
    This function will be removed in version 2.0.0. *)
val old_function : unit -> unit
  [@@deprecated "Use new_function instead"]

(** Replacement for [old_function] with improved API. *)
val new_function : unit -> unit
```

## Version Constraints

### For Library Users

**Recommended constraints in opam/dune:**

```lisp
; Conservative: pin to minor version
(ocaml_telegram_eio (>= 0.1.0) (< 0.2.0))

; Moderate: allow patches
(ocaml_telegram_eio (>= 0.1.0) (< 0.2~))

; Aggressive: allow minor updates
(ocaml_telegram_eio (>= 0.1.0) (< 1.0))

; For stable 1.x+ versions:
(ocaml_telegram_eio (>= 1.0.0) (< 2.0))
```

### For Development

```bash
# Pin to development version
opam pin add ocaml_telegram_eio .

# Install specific version
opam install ocaml_telegram_eio.0.1.0
```

## Release Checklist

Before releasing a new version:

- [ ] All tests passing (`dune runtest`)
- [ ] Documentation builds (`dune build @doc`)
- [ ] CHANGELOG.md updated with all changes
- [ ] Version bumped in dune-project
- [ ] Version bumped in src/version.ml
- [ ] opam file regenerated (`dune build`)
- [ ] opam lint passes (`opam lint ocaml_telegram_eio.opam`)
- [ ] Examples tested with new version
- [ ] Migration guide updated (if breaking changes)
- [ ] Git tag created (vX.Y.Z)
- [ ] Changes pushed to repository
- [ ] GitHub release created with CHANGELOG entry

## Questions?

- See [CHANGELOG.md](CHANGELOG.md) for release history
- See [CONTRIBUTING.md](CONTRIBUTING.md) for development workflow
- Open an issue for questions about versioning policy
