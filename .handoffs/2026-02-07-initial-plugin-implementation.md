# Handoff: Initial Plugin Implementation

**Date:** 2026-02-07
**Branch:** main
**State:** Yellow

> All tests pass (7/7), clippy clean, all artifacts pass quality gates (`just lint-docs`). Yellow because three skills remain unwritten and the plugin hasn't been verified as loadable.

## Where things stand

Phases 0-4 are substantially complete. The `building-in-the-open` plugin has:
- All 4 personas: `personas/{technical-writer,context-curator,doc-writer,marketing-copywriter}.md`
- 3 of 6 skills: `skills/{curating-context,writing-adrs,writing-design-docs}/SKILL.md`
- 3 document templates: `templates/{adr,handoff,design-doc}.md`
- 6 ADRs: `docs/decisions/0001-0006`
- 1 design doc: `docs/designs/2026-02-07-building-in-the-open-plugin-design.md`
- 1 editorial reviewer agent: `agents/editorial-reviewer.md`
- `bito-lint` Rust CLI: token counter, readability scorer, completeness checker (`crates/bito-lint/`)
- Justfile with `just lint-docs` (lint-handoffs, lint-adrs, lint-design-docs)
- Pre-commit hook script: `hooks/pre-commit-docs`

## Decisions made

- Composable persona layer (ADR-0001)
- Tone firewall on commit path (ADR-0002)
- Real tools for measurement, agents for judgment (ADR-0003)
- Prompted ADR extraction (ADR-0004)
- 2,000-token handoff budget (ADR-0005)
- PRIVATE_MEMORY.md gitignored, .handoffs/ committed (ADR-0006)
- Restructured to `crates/` layout matching `claylo-rs` template conventions
- MADR 4.0.0 for ADR format (not Nygard)

## What's next

1. **Write remaining 3 skills:**
   - `skills/writing-end-user-docs/SKILL.md` — uses Doc Writer persona, progressive disclosure structure
   - `skills/writing-changelogs/SKILL.md` — dual-persona (Technical Writer for CHANGELOG.md, Marketing Copywriter for release announcements)
   - `skills/editorial-review/SKILL.md` — wraps `agents/editorial-reviewer.md` into an invocable skill, coordinates all quality gates
2. **Create `docs/decisions/README.md`** — ADR index with status emoji per the `capturing-decisions` skill from `claylo-rs` template
3. **Verify plugin load path** — confirm that Claude Code (or other agent platforms) can discover and load skills from the `.claude-plugin/` structure
4. **Phase 5: Calibration** — populate persona calibration examples with real artifacts from this project rather than synthetic examples; editorial pass on all existing artifacts
5. **Consider `claylo-rs update`** — evaluate whether to bring in template scaffolding (CI, deny.toml, GitHub workflows) via the template system rather than hand-building

## Landmines

- **`curating-context` skill claims `/handoff` name.** Its frontmatter says `name: handoff`. This shadows the existing superpowers `handoff` skill. Intentional, but causes collision if both plugins installed. Test with both active.
- **`bito-lint` token counting is approximate.** Uses tiktoken `cl100k_base`, not Claude's tokenizer. For exact Claude counts, use the Anthropic token counting API (free, rate-limited). See `tokens.rs:8-10` for the note.
- **Readability targets are initial estimates.** The Flesch-Kincaid thresholds (≤8 for Doc Writer, ≤12 for Technical Writer) haven't been calibrated against real user-facing docs yet. The design doc states this explicitly.
- **`resolver = "2"` not `"3"`.** Cargo.toml uses resolver 2 to match the `claylo-rs` template conventions. Resolver 3 was in the initial version but was changed.
- **No `deny.toml` yet.** The `just deny` recipe exists but `cargo deny` will fail without a config file. Add one before enabling that check.
- **No CI.** No GitHub Actions workflow exists. The `claylo-rs` template generates one — consider pulling it in.
- **The design doc references `tools/` in some places.** The Rust crate moved to `crates/bito-lint`. The design doc's Tooling section doesn't reference the path at all (it says "hooks/"), so no update needed, but be aware of the rename if you encounter stale references.
