# Handoff: Initial Plugin Implementation

**Date:** 2026-02-07
**Branch:** main
**State:** Yellow

> No tests exist yet. Yellow because Phases 0-2 are complete (structure, personas, templates, ADRs, three skills), but no skills are wired into a working plugin load path and no tooling hooks exist.

## Where things stand

The `building-in-the-open` plugin has its full directory structure, two of four personas (Technical Writer, Context Curator), all three document templates (ADR/MADR 4.0.0, handoff, design doc), three of six skills (`curating-context`, `writing-adrs`, `writing-design-docs`), the editorial reviewer agent template, and six ADRs. The design doc is complete and accepted.

**Not yet built:** Doc Writer and Marketing Copywriter personas (Phase 4), three skills (`writing-end-user-docs`, `writing-changelogs`, `editorial-review`), and all tooling hooks (Phase 3).

## Decisions made

- Composable persona layer over per-skill voice definitions (ADR-0001)
- Tone firewall gates the commit path, not the writing path (ADR-0002)
- Deterministic tools for measurement, agents for judgment (ADR-0003)
- Prompted ADR extraction from design docs, not automatic (ADR-0004)
- 2,000-token hard budget for public handoffs, enforced by tooling (ADR-0005)
- `PRIVATE_MEMORY.md` gitignored, `.handoffs/` committed (ADR-0006)

## What's next

1. **Phase 3: Tooling hooks** — Token counter (`tiktoken-rs` or equivalent), readability scorer, section completeness checker. These go in `hooks/`. Need to decide on specific CLI tools.
2. **Phase 4: Doc Writer + Marketing Copywriter personas** — `personas/doc-writer.md`, `personas/marketing-copywriter.md`. Voice definitions with calibration examples, following the pattern established in the existing two personas.
3. **Phase 4: `writing-end-user-docs` and `writing-changelogs` skills** — Depend on Phase 4 personas.
4. **Phase 5: `editorial-review` skill** — Wraps `agents/editorial-reviewer.md` into an invocable skill with the full quality gate pipeline.
5. **Git: first commit** — Everything is untracked. Commit all Phase 0-2 artifacts together.

## Landmines

- **Plugin isn't loadable yet.** `.claude-plugin/plugin.json` exists but no verification that Claude Code (or any other agent platform) discovers and loads skills from this structure. Verify the plugin load path before writing more skills.
- **The `curating-context` skill claims the `/handoff` name.** Frontmatter: `name: handoff`. This intentionally shadows the existing superpowers `handoff` skill. Be aware of the collision during testing with both plugins installed.
- **No git commits exist.** Everything is untracked.
- **Readability targets are initial estimates.** Flesch-Kincaid ≤ 8 (Doc Writer), ≤ 12 (Technical Writer). Phase 3 calibrates against real artifacts.
- **MADR 4.0.0 frontmatter uses YAML.** Some doc site generators may need configuration for `---` delimited frontmatter.
