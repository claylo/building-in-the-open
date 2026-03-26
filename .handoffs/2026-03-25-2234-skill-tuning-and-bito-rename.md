# Handoff: Skill Tuning and bito Rename

**Date:** 2026-03-25
**Branch:** fix/tune-skills
**State:** Yellow

> Yellow = everything works, but uncommitted changes on the branch need review before commit.

## Where things stand

All plugin references updated from `bito-lint` to `bito` following the tool's rename to v1.0.0. Three rounds of tessl skill reviews drove description rewrites, content trims, frontmatter additions, and dynamic context injection. Scores improved from 63-90 (R1) to 83-98 (R3). One commit pushed on this branch (the rename); remaining work (descriptions, frontmatter, content trims, tessl tooling) is uncommitted.

## Decisions made

- **`bito-lint` → `bito` everywhere** — binary name, env vars (`BITO_LINT_*` → `BITO_*`), npm scope (`@claylo/bito`), hook scripts. Backward compat `.bito-lint.*` config names documented but not the default.
- **`package.json` added** — declares `@claylo/bito` as dependency. SessionStart hook auto-installs into `${CLAUDE_PLUGIN_DATA}` if bito isn't on PATH. Supports future mcpb distribution.
- **Description pattern: "[What]. Use when [triggers]."** — all 8 skill descriptions rewritten. Biggest wins: writing-design-docs (69→98), writing-end-user-docs (63→83).
- **Dynamic context injection** via `!`command`` syntax on curating-context (git state), capturing-decisions (existing ADR list), writing-changelogs (commits since tag).
- **`context: fork` + `agent: editorial-reviewer`** on editorial-review skill — isolated review without conversation influence.
- **`allowed-tools: Read, Bash(bito *)`** on all 8 skills, `license: MIT` on all 8.
- **Onboarding questions extracted** to `skills/onboarding/references/interview-questions.md` — halved SKILL.md line count, better progressive disclosure.

## What's next

1. **Commit the uncommitted changes** — descriptions, frontmatter, content trims, package.json, .gitignore, tessl tooling. Review the diff; it's substantial.
2. **Run tessl R4** after commit to confirm scores stabilized. `./tessl-review scratch/tessl04`
3. **Explore mcpb distribution** — read mcpb MANIFEST.md deeper, prototype a `manifest.json` for the plugin. Per-platform `.mcpb` from CI using `type: "binary"` is the likely path. Reference: `~/source/reference/modelcontextprotocol/mcpb/`
4. **Mine Claude Code skills docs further** — `~/source/claude/docs/skills.md` has more patterns to leverage (skill-scoped hooks, effort levels, subagent preloading).
5. **License cleanup** — drop Apache-2.0 from this repo, MIT only. Update LICENSE files and plugin.json.

## Landmines

- **Uncommitted work is large** (~30 files touched across rename + descriptions + frontmatter + content trims + new files). The prior commit on this branch was just the rename. Everything since is unstaged.
- **The loaded skill from the marketplace cache is stale** — it still references `bito-lint` and `BITO_LINT_DIALECT`. The marketplace install won't pick up changes until a new version is published.
- **`tessl-review` and `tessl-to-md` are in the repo root** — decide whether to keep them there, move to `tools/`, or gitignore them. They're dev convenience, not part of the plugin.
- **`scratch/` directory has three rounds of tessl results** — not gitignored. Decide whether to commit (useful history) or ignore.
- **The editorial-review skill now has `context: fork` + `agent: editorial-reviewer`** — this hasn't been tested in practice. The `agents/editorial-reviewer.md` template needs to be compatible with the subagent execution model.
