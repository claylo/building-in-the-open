# Handoff: Releases, Documentation, and Skill Testing

## Current State

Executed a 4-phase plan covering bito-lint release, MCP lazy-loading research, building-in-the-open release prep, and skill testing framework scaffolding.

### Done

**Phase 1 — bito-lint v0.1.0 release:**
- v0.1.0 live on crates.io. `cargo install bito-lint` verified from registry (not local path).
- GitHub Release exists with 3/8 platform binaries (darwin-arm64, linux-x64-gnu, windows-x64-msvc).
- 5 cross-compilation targets failed due to missing `rustup target add` in CD workflow.
- CD fix written in `~/source/claylo/bito-lint/.github/workflows/cd.yml` — uncommitted.
- Repo variables (`CRATES_IO_ENABLED`, `HOMEBREW_ENABLED`) and secrets (`CARGO_TOKEN`, `HOMEBREW_COMMITTER_TOKEN`) configured.

**Phase 2 — MCP lazy loading:**
- No per-server `autostart: false` exists in Claude Code. MCP Tool Search (Jan 2026) handles lazy loading automatically when tool schemas exceed 10% of context.
- bito-lint's 6 tools total ~1,283 tokens — below the threshold. `ENABLE_TOOL_SEARCH=auto:5` lowers it.
- Updated `~/source/claylo/bito-lint/docs/mcp-development.md` with context budget table and Tool Search docs.
- Updated `~/source/claylo/bito-lint/README.md` — full rewrite in Doc Writer voice (see Phase "README rewrite" below).

**Phase 3 — building-in-the-open release prep:**
- Created `CHANGELOG.md` (v0.1.0 entry).
- Created `docs/installation.md` and `docs/quickstart.md`.
- Updated `README.md` with Installation and Quickstart sections linking to new docs.
- Rewrote `.justfile` — removed stale Rust recipes, now uses installed `bito-lint` binary, added `lint <file>` single-file recipe.
- Updated `.gitignore` to exclude `test/scorecards/` and `target/`.
- `just lint-docs` verified working with installed binary.

**Phase 4 — Skill testing framework:**
- Full `test/` directory scaffolded with 5 scenarios (handoff, adr, design-doc, end-user-doc, changelog).
- `test/thresholds.toml` with per-skill quality thresholds.
- `test/run-skill-test.sh` — parses scenario front matter, sets up temp workspace, invokes Claude, runs bito-lint checks, writes JSON scorecard.
- `test/run-suite.sh` — smoke (N=1) and calibration (N>1) modes with variation reporting.
- `test/hooks/` — PostToolUse and Stop telemetry hooks.
- `.github/workflows/skill-test.yml` — manual workflow_dispatch.

**README rewrite (bito-lint):**
- Rewrote from scaffolding-style to Doc Writer voice. Leads with "bito = building in the open," real `analyze` output, 18-check table, pass/fail examples.
- Removed: AGENTS.md reference, Architecture/ConfigLoader internals, CI/CD/Dependabot section, Logging section, triple config format examples.
- bito-lint analyze results: Grade 14.0, 0% passive, style 93/100. Remaining flags are from example content in the checks table.

### Uncommitted across both repos

**bito-lint (`~/source/claylo/bito-lint`):**
- `.github/workflows/cd.yml` — cross-compilation fix (rustup target add, arm64 musl linker)
- `README.md` — full rewrite
- `docs/mcp-development.md` — context budget + lazy loading section

**building-in-the-open (this repo):**
- `.gitignore`, `.justfile`, `README.md` — modified
- `CHANGELOG.md`, `docs/installation.md`, `docs/quickstart.md` — new
- `.github/workflows/skill-test.yml` — new
- `test/` directory — new (scenarios, hooks, runners, thresholds)

## Next Steps

1. **Commit and push bito-lint changes.** CD fix + README rewrite + MCP docs. Consider a v0.1.1 patch to trigger CD and build remaining 5 platform binaries.
2. **Remove stale `Cargo.lock`** from building-in-the-open root (no Cargo.toml exists; leftover from bito-lint extraction).
3. **Commit and push building-in-the-open changes.** Create GitHub repo if not done: `gh repo create claylo/building-in-the-open --public --source=. --push`
4. **Tag v0.1.0** for building-in-the-open.
5. **Run skill tests** against real scenarios: `bash test/run-skill-test.sh test/scenarios/adr/01-simple-decision.md` — verify end-to-end.
6. **Calibrate thresholds** by running suite with N=3-5 and adjusting `test/thresholds.toml`.
7. **Design doc completeness template mismatch:** `docs/designs/2026-02-07-building-in-the-open-plugin-design.md` fails completeness check because it uses different section names than the `design-doc` template expects. Either update the template or the doc.

## Key Files

| File | Why |
|------|-----|
| `~/source/claylo/bito-lint/.github/workflows/cd.yml` | Cross-compilation fix — uncommitted |
| `~/source/claylo/bito-lint/README.md` | Full rewrite — uncommitted |
| `~/source/claylo/bito-lint/docs/mcp-development.md` | Context budget + lazy loading — uncommitted |
| `.justfile` | Rewritten to use installed bito-lint binary |
| `test/run-skill-test.sh` | Core scenario runner — new |
| `test/run-suite.sh` | Suite runner with variation reporting — new |
| `test/thresholds.toml` | Quality thresholds per skill — new |
| `.github/workflows/skill-test.yml` | Manual CI for skill tests — new |

## Gotchas

- **bito-lint grammar on markdown:** Reports "multiple consecutive spaces" for table alignment. These are false positives in markdown context.
- **Consistency check on example content:** The README's checks table mentions "color" and "colour" as examples, which triggers bito-lint's own consistency checker. Intentional, not a real issue.
- **Skill test runner needs `claude` CLI:** The `run-skill-test.sh` script uses `claude --print --dangerously-skip-permissions`. Won't work without Claude Code installed and `ANTHROPIC_API_KEY` set.
- **Design doc completeness:** The existing design doc uses sections like "Design principles" instead of "Approach" — bito-lint's design-doc template expects the latter. This predates the template.
- **Homebrew publishing skipped:** The CD `publish-homebrew` job depends on `publish-binaries` which partially failed, so the formula was never pushed to `claylo/homebrew-brew`.

## What Worked

- Installing bito-lint from crates.io (not local path) for real verification.
- Using `env("BITO_LINT", "bito-lint")` in justfile for overridable binary path.
- Simple TOML parser in shell (sed between section markers) works for flat thresholds.
- Front matter parsing with sed for scenario files — clean and portable.

## What Didn't Work

- `cargo install --path` for post-release validation — bypasses the registry entirely, verifies nothing about the published crate. Always use `cargo install <crate-name>` from the registry.
- `dtolnay/rust-toolchain` with `targets:` input — didn't reliably install cross-compilation targets when `rust-toolchain.toml` exists. Explicit `rustup target add` step is more reliable.

## Commands

```bash
# Verify bito-lint works
bito-lint info
bito-lint analyze README.md

# Run doc quality checks (building-in-the-open)
just lint-docs

# Check uncommitted changes across both repos
cd ~/source/claylo/bito-lint && git diff --stat
cd ~/source/claylo/building-in-the-open && git status --short

# Test a single skill scenario (requires claude CLI + API key)
bash test/run-skill-test.sh test/scenarios/adr/01-simple-decision.md

# Run full smoke suite
bash test/run-suite.sh --runs=1
```
