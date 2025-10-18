# CLEANUP.md

**Library Cleanup & Organization - Make It Presentable**

**Goal**: Remove obsolete files, consolidate documentation, eliminate ambiguity, and prepare a clean, professional library ready for release.

---

## Master Checklist

### Phase 1: Documentation Consolidation & Cleanup

**Goal**: Single source of truth for each concern. Keep only essential docs, remove redundant planning files.

- [x] Task 1.1: Consolidate planning documents
  - [x] Keep: `CHANGELOG.md`, `CONTRIBUTING.md`, `VERSIONING.md`, `COMPATIBILITY.md`
  - [x] Archive to `archive/` directory:
    - `PLAN.md` - historical planning, superseded by CONSISTENT_API.md progress
    - `API_DESIGN.md` - design notes, incorporated into actual implementation
    - `DOCS_PLAN.md` - documentation planning, tasks mostly complete
    - `BUILDER.md` - builder pattern notes, incorporated into Bot.mli
    - `LOGGING.md` - logging implementation notes, incorporated into Log.mli
    - `INTEGRATION_TESTING.md` - testing notes, should be in CONTRIBUTING.md
  - [x] Result: Single `archive/` folder with historical design docs

- [x] Task 1.2: Update README.md to match current state
  - [x] Remove references to archived planning docs
  - [x] Update project status (current completion percentage from CONSISTENT_API.md)
  - [x] Update examples list to match actual `examples/` directory
  - [x] Add clear "Quick Start" with simplest working example
  - [x] Add link to generated API docs
  - [x] Fix GitHub URLs (currently placeholder "yourusername")
  - [x] Add badges for build status, coverage (when CI is set up)

- [ ] Task 1.3: Consolidate CONSISTENT_API.md into ROADMAP.md
  - [ ] Rename `CONSISTENT_API.md` → `ROADMAP.md`
  - [ ] Keep only Phase 1 checklist (documentation examples implementation)
  - [ ] Add Phase 2 section for remaining library work from old PLAN.md
  - [ ] Clean up verbose task descriptions to be concise
  - [ ] Result: Single roadmap file tracking all remaining work

- [ ] Task 1.4: Consolidate CLAUDE.md into CONTRIBUTING.md
  - [ ] Move "Task Completion Policy" to CONTRIBUTING.md
  - [ ] Move "Result-Based Error Handling" to CONTRIBUTING.md or new ARCHITECTURE.md
  - [ ] Move "Error Handling in Documentation Examples" to CONTRIBUTING.md
  - [ ] Keep CLAUDE.md minimal (just Claude-specific automation instructions)
  - [ ] Result: Human contributors see full guide in CONTRIBUTING.md

### Phase 2: Examples Organization

**Goal**: Clear, well-organized examples that compile and demonstrate best practices.

- [ ] Task 2.1: Organize examples by category
  - [ ] Create subdirectories:
    - `examples/basic/` - hello_world, echo_bot, command_bot
    - `examples/recipes/` - recipe_*.ml files (cookbook examples)
    - `examples/advanced/` - task_1_1_*.ml files (comprehensive tutorials)
  - [ ] Update `examples/dune` to include all subdirectories
  - [ ] Update `examples/README.md` with categorized listing

- [ ] Task 2.2: Verify all examples compile
  - [ ] Run `dune build @examples` (or create this alias if needed)
  - [ ] Fix any compilation errors
  - [ ] Ensure zero warnings (library policy)
  - [ ] Document any examples requiring special setup (env vars, files)

- [ ] Task 2.3: Remove obsolete/stub examples
  - [ ] Review and remove:
    - `echo_polling.ml` - 365 bytes, likely stub/duplicate
    - `send_photo.ml` - 179 bytes, likely stub
  - [ ] Merge duplicates if any exist
  - [ ] Keep only examples that add unique value

- [ ] Task 2.4: Add examples index
  - [ ] Update `examples/README.md` with:
    - Table of contents by category
    - One-line description for each example
    - Prerequisites (env vars, files needed)
    - Expected output/behavior
  - [ ] Add comments in each example file with:
    - Purpose statement
    - How to run
    - Expected bot behavior

### Phase 3: Source Code Cleanup

**Goal**: Remove unused code, dead modules, ensure everything in `src/` is necessary.

- [ ] Task 3.1: Audit source modules for usage
  - [ ] Check each module in `src/` is exported in library interface
  - [ ] Check each module is used somewhere (not dead code)
  - [ ] Document public API surface in `src/dune` (public_name)
  - [ ] Remove any internal-only modules not needed

- [ ] Task 3.2: Clean up generated code
  - [ ] Verify `generated/gen_types.ml` and `generated/gen_methods.ml` are current
  - [ ] Run `dune exec test/update_golden.exe` to fix golden test
  - [ ] Document regeneration process in README.md
  - [ ] Add version info comments to generated files

- [ ] Task 3.3: Review and clean bot.ml/bot.mli
  - [ ] Remove commented-out code
  - [ ] Ensure all public functions documented
  - [ ] Check for TODOs/FIXMEs, resolve or track in issues
  - [ ] Verify Result-based error handling throughout

- [ ] Task 3.4: Audit test files
  - [ ] Remove unused test utilities
  - [ ] Check all test files in `test/dune` are active
  - [ ] Document test organization in CONTRIBUTING.md
  - [ ] Ensure 100% pass rate: `dune runtest`

### Phase 4: Documentation Structure

**Goal**: Professional documentation setup ready for odoc publishing.

- [ ] Task 4.1: Review docs/ directory structure
  - [ ] Ensure all `.mld` files are referenced in `docs/dune`
  - [ ] Check `docs/index.mld` provides good overview
  - [ ] Remove any obsolete `.mld` files
  - [ ] Organize by topic (getting-started, recipes, advanced)

- [ ] Task 4.2: Generate and review API docs
  - [ ] Run `dune build @doc`
  - [ ] Review generated docs in `_build/default/_doc/_html/`
  - [ ] Fix any broken links or missing documentation
  - [ ] Ensure all public modules have module docstrings
  - [ ] Add examples to module documentation where helpful

- [ ] Task 4.3: Update docs/README.md
  - [ ] Document how to build docs
  - [ ] Document how to view docs locally
  - [ ] Document how to publish docs (GitHub Pages, etc.)
  - [ ] Link to online docs (once hosted)

### Phase 5: Build & Packaging

**Goal**: Clean build configuration, ready for opam publishing.

- [ ] Task 5.1: Clean up dune-project
  - [ ] Verify all dependencies are current
  - [ ] Check version numbers are correct
  - [ ] Update author/maintainer info
  - [ ] Fix GitHub URL (currently placeholder)
  - [ ] Add homepage, bug-reports, documentation URLs

- [ ] Task 5.2: Review opam file
  - [ ] Run `dune build ocaml_telegram_eio.opam` to regenerate
  - [ ] Check generated opam file is valid
  - [ ] Test local opam pin: `opam pin add . --yes`
  - [ ] Verify all dependencies install cleanly

- [ ] Task 5.3: Clean build artifacts
  - [ ] Add comprehensive `.gitignore` entries
  - [ ] Remove any committed build artifacts
  - [ ] Document clean build process in README
  - [ ] Add `make clean` or document `dune clean`

### Phase 6: Repository Hygiene

**Goal**: Professional Git repository ready for public release.

- [ ] Task 6.1: Review commit history
  - [ ] Check for any sensitive data (tokens, keys) in history
  - [ ] Consider squashing WIP commits before release
  - [ ] Tag current version: `git tag -a v0.1.0 -m "Initial release"`

- [ ] Task 6.2: Add repository metadata
  - [ ] Create/update `.gitattributes` for line endings
  - [ ] Add `CODE_OF_CONDUCT.md` if needed
  - [ ] Add `SECURITY.md` for vulnerability reporting
  - [ ] Add issue templates in `.github/ISSUE_TEMPLATE/`
  - [ ] Add PR template in `.github/PULL_REQUEST_TEMPLATE.md`

- [ ] Task 6.3: Set up CI/CD
  - [ ] GitHub Actions for:
    - Build on push/PR
    - Run tests
    - Generate docs
    - Lint/format checks
  - [ ] Add build status badge to README
  - [ ] Document CI setup in CONTRIBUTING.md

### Phase 7: Final Review & Polish

**Goal**: Everything clean, documented, and ready to show the world.

- [ ] Task 7.1: Documentation review pass
  - [ ] Proofread all markdown files
  - [ ] Check for broken internal links
  - [ ] Verify all code examples compile
  - [ ] Check for consistent terminology
  - [ ] Fix typos and formatting issues

- [ ] Task 7.2: Code review pass
  - [ ] Check for unused `open` statements
  - [ ] Verify consistent code style
  - [ ] Check for magic numbers (should be constants)
  - [ ] Review error messages for clarity
  - [ ] Ensure logging is appropriate (not too verbose/quiet)

- [ ] Task 7.3: Public API audit
  - [ ] Review all exported modules for clarity
  - [ ] Check function naming consistency
  - [ ] Verify type signatures are user-friendly
  - [ ] Document any breaking changes since last version
  - [ ] Plan any final API changes before v1.0

- [ ] Task 7.4: Pre-release checklist
  - [ ] All tests pass: `dune runtest`
  - [ ] No compiler warnings: `dune build --force`
  - [ ] Documentation builds: `dune build @doc`
  - [ ] Examples compile: `dune build @examples` (or equivalent)
  - [ ] README is accurate and compelling
  - [ ] CHANGELOG is up to date
  - [ ] Version number is correct in dune-project

---

## File Organization Summary

### Keep in Root
- `README.md` - Main entry point
- `CHANGELOG.md` - Version history
- `CONTRIBUTING.md` - Contributor guide (expanded)
- `VERSIONING.md` - Semantic versioning policy
- `COMPATIBILITY.md` - Bot API compatibility info
- `ROADMAP.md` - Future work (renamed from CONSISTENT_API.md)
- `LICENSE` - MIT license
- `dune-project` - Project metadata
- `*.opam` - Package file

### Archive to `archive/`
- `PLAN.md` - Historical planning
- `API_DESIGN.md` - Design exploration
- `DOCS_PLAN.md` - Documentation planning
- `BUILDER.md` - Builder pattern notes
- `LOGGING.md` - Logging implementation notes
- `INTEGRATION_TESTING.md` - Testing notes

### Remove Completely
- `CLAUDE.md` - Move to `.claude/` or similar (out of user-facing docs)
- Any duplicate or obsolete files discovered during cleanup

### Directory Structure (Target)
```
ocaml_telegram_eio/
├── README.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── VERSIONING.md
├── COMPATIBILITY.md
├── ROADMAP.md
├── LICENSE
├── dune-project
├── ocaml_telegram_eio.opam
│
├── archive/               # Historical design docs
│   ├── PLAN.md
│   ├── API_DESIGN.md
│   ├── DOCS_PLAN.md
│   ├── BUILDER.md
│   ├── LOGGING.md
│   └── INTEGRATION_TESTING.md
│
├── src/                   # Library source
│   ├── *.ml
│   ├── *.mli
│   └── dune
│
├── generated/             # Code-generated files
│   ├── gen_types.ml
│   └── gen_methods.ml
│
├── bin/                   # Code generators
│   └── ...
│
├── test/                  # Test suite
│   └── ...
│
├── examples/              # Organized examples
│   ├── README.md          # Examples index
│   ├── basic/             # Simple examples
│   │   ├── hello_world.ml
│   │   ├── echo_bot.ml
│   │   └── command_bot.ml
│   ├── recipes/           # Cookbook examples
│   │   └── recipe_*.ml
│   └── advanced/          # Comprehensive tutorials
│       └── task_*.ml
│
├── docs/                  # Documentation sources
│   ├── README.md
│   ├── index.mld
│   ├── getting_started.mld
│   ├── core_concepts.mld
│   └── ...
│
├── scripts/               # Development scripts
│   ├── bootstrap.sh
│   └── regenerate.sh
│
├── reference/             # Telegram API spec cache
│   └── api.html
│
└── .github/               # GitHub configuration
    └── workflows/
```

---

## Success Criteria

After completing all tasks, the library should have:

1. **Clear Documentation**
   - README is accurate and compelling
   - Contributing guide covers all workflows
   - API docs build cleanly
   - Examples are organized and well-documented

2. **Clean Codebase**
   - Zero compiler warnings
   - 100% test pass rate
   - No dead code or unused modules
   - Consistent code style

3. **Professional Repository**
   - Clean commit history
   - CI/CD pipeline working
   - Issue/PR templates in place
   - Security and conduct policies documented

4. **Ready for Release**
   - Version tagged
   - CHANGELOG updated
   - opam file valid
   - Can install via `opam pin`

5. **No Ambiguity**
   - Single source of truth for each topic
   - Clear separation: design docs (archived) vs. public docs (current)
   - Examples demonstrate actual, working API
   - Roadmap shows future work clearly

---

## Notes

- This cleanup should be done incrementally, one phase at a time
- Each task should end with `dune build` and `dune runtest` passing
- Archive files, don't delete - they have historical value
- Keep CLAUDE.md but move it out of main docs (`.claude/` directory)
- Focus on user-facing quality: what would a new user see first?
