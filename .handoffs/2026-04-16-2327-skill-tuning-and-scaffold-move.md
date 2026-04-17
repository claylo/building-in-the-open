# Handoff: Skill tuning pass + manual bito scaffold

**Date:** 2026-04-16
**Branch:** main
**State:** Green

> Green = tests pass, safe to continue. Yellow = tests pass but known issues exist. Red = broken state, read Landmines first.

## Where things stand

Shipped as v1.2.1. Two user-visible behavior fixes landed: the handoff-nudge hook now gates on `/handoff` instead of firing every prompt, and bito config scaffolding is no longer automatic at session start — it's a script the user (or Claude) runs deliberately. Five skills got descriptor and content polish based on the tessl05 / tessl06 review passes. Working tree is clean, branch merged to main.

## Decisions made

- **Scaffold via script, not hook.** Auto-writing `.bito.yaml` on every session start was too aggressive for a one-time setup action. The logic moved verbatim to `skills/building-in-the-open/scripts/scaffold-config.sh`, with a `--force` flag added for overwrite and template resolution via `${BASH_SOURCE[0]}` so it works outside a hook context.
- **Curating-context drops the private-journal prescription.** The skill now focuses exclusively on the public handoff artifact. Private note-taking is the user's own tooling's job, not this skill's. Description was widened to list concrete handoff contents (decisions, open items, landmines, current state) to keep specificity.
- **Editorial-review widens triggers.** Added natural-language verbs (proofread, review, edit, ready to ship) alongside the existing jargon-heavy triggers.
- **Tessl suggestions to split files into `references/` were rejected.** Single-file skills read better for humans; Tessl's token-budget framing doesn't override that.

## What's next

1. **Verify v1.2.1 reaches the plugin marketplace cache.** The skill load during this session pulled the cached v1.2.0 copy, which still had the pre-edit private-journal prompts. Should resolve on next marketplace sync.
2. **Consider whether `writing-end-user-docs` needs a concrete output template.** Tessl's review (62% content, lowest of the set) wanted a worked example of a completed doc section. We declined in favor of smaller trims this pass — revisit if the skill keeps scoring low.
3. **`damme`** (plugin testing framework) — design complete, zero implementation. See `MEMORY.md` remaining-work list.
4. **Output styles exploration** — still open (see MEMORY.md). Could personas compose with output styles rather than replace them?

## Landmines

- **The plugin cache lags the source tree.** Edits under `~/source/claylo/building-in-the-open/` don't take effect until a release ships AND the marketplace cache refreshes. If you edit a SKILL.md and test it in a session, you'll hit the cached version — check `~/.claude/plugins/cache/claylo-marketplace/building-in-the-open/<version>/` to confirm what's actually loaded.
- **`hooks/handoff-nudge.sh` must stay committed.** It's referenced by `hooks/hooks.json` as the `UserPromptSubmit` handler. It was untracked before this session — if anyone's tempted to `git clean` hook files, this one will silently break the `/handoff` nudge.
- **`CLAUDE_PLUGIN_OPTION_*` env vars are hook-only.** The scaffold script falls back to plain env var names (`DIALECT`, `DOC_OUTPUT_DIR`, etc.) so it works when invoked manually. Don't assume the `CLAUDE_PLUGIN_OPTION_*` namespace outside hook execution.
- **`allowed-tools` warnings from Tessl are noise.** Tessl's validator flags `Bash(bito *)`, `license:`, `argument-hint:`, and `context:` as unrecognized. They're all valid Claude Code fields; ignore the warnings.
- **The handoff filename guard wants minute-precision, not seconds.** Pattern is `YYYY-MM-DD-HHMM-<topic>.md`. The template and some tooling say HHMMSS; the guard hook is stricter. Trust the guard.
