# Handoff: 1.0.0 Release Prep — Skills Overhaul

**Date:** 2026-03-02
**Branch:** release-prep
**State:** Yellow

> Yellow = all changes are uncommitted. No tests broken, but nothing committed or pushed yet.

## Where things stand

The `release-prep` branch has ~940 lines of uncommitted changes across 31 files. Skills have been renamed, decoupled from superpowers, and a new onboarding skill was added. README was rewritten for a dual audience (devs + technical writers). Release blockers (LICENSE files, CHANGELOG bump to 1.0.0, hook simplification) are resolved but uncommitted.

## Decisions made

- **1.0.0 not 0.1.0** — Clay's call, reflected in CHANGELOG and plugin.json
- **`writing-adrs` → `capturing-decisions`** — directory renamed, 10 active cross-refs updated, 6 historical files left untouched
- **`curating-context` skill name changed from `handoff`** — avoids conflicting with existing `/handoff` commands; `UserPromptSubmit` hook suggests the skill when `/handoff` appears in messages
- **Only `writing-design-docs` gets with/without-superpowers split** — other skills genericized inline (1-2 line changes each)
- **ADR template merged** — added `rejected` status, optional markers, `Neutral` from bito-lint version
- **README dual audience** — opener addresses both developers and technical writers; links to Jennifer Oakley, UX Writing Hub, Mintlify articles
- **New `onboarding` skill** — brainstorming-style interview that generates `.bito-lint.yaml` from writer's answers

## What's next

1. **Clay: update bito-lint** to support `.bito.yaml` in addition to `.bito-lint.yaml` — then update onboarding skill config references
2. **Review `docs/quickstart.md`** for stale content — hasn't been fully reviewed this session
3. **Commit all changes** on `release-prep` branch — Clay runs his own `git commit`
4. **Set GitHub repo description** — `gh repo edit claylo/building-in-the-open --description "..."`
5. **Merge `release-prep` → `main`** and tag `v1.0.0`
6. **Consider updating design doc** (`docs/designs/2026-02-07-...`) — still references `writing-adrs` in 4 places; it's marked "Implemented" not archived

## Landmines

- **Nothing is committed.** All 31 files are unstaged on `release-prep`. The branch is at the same commit as `main` (69e9b28). A `git checkout .` would destroy everything.
- **Installed plugin cache has old skills.** The cached version at `~/.claude/plugins/cache/building-in-the-open-dev/` still references `writing-adrs` and has `name: handoff`. A fresh install/reinstall will pick up the new versions.
- **`check-docs-on-write.sh` now requires `bito-lint lint` support.** The simplified hook calls `bito-lint lint` instead of per-type checks. This requires bito-lint v0.2.0+ with the rules/lint feature. Older bito-lint versions will silently pass (the `lint` subcommand won't exist, command fails, hook exits 0 due to `||` handling).
- **9 new untracked files** need `git add`: LICENSE-APACHE, LICENSE-MIT, marketplace.json, hooks/README.md, hooks/check-docs-on-write.sh, skills/building-in-the-open/SKILL.md, skills/onboarding/SKILL.md, and 2 files in skills/writing-design-docs/references/.
