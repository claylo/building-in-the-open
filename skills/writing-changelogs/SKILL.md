---
name: writing-changelogs
description: Use at release time or incrementally as features land, when writing CHANGELOG.md entries for existing users or release announcements for the broader audience. Dual-persona — Technical Writer for changelogs, Marketing Copywriter for announcements.
---

# Writing Changelogs

## Overview

Same changes, two audiences. Existing users upgrading need a scannable changelog that tells them what broke, what's new, and what to do about it. Potential users discovering the project need a release announcement that shows why these changes matter. This skill produces both from the same set of changes, using different personas for each.

## When to Use

- At release time — before tagging a version
- Incrementally, as significant features land on main
- When preparing release announcements for social posts, blog entries, or GitHub Releases
- When `finishing-a-development-branch` identifies user-facing changes

## When NOT to Use

- For internal architectural changes with no user-visible impact — these belong in design docs or ADRs, not changelogs
- For session context — use `curating-context`
- For capturing the decision behind a change — use `writing-adrs`

## Quick Reference

| Output | Persona | Location | Audience |
|--------|---------|----------|----------|
| CHANGELOG.md entry | Technical Writer | `CHANGELOG.md` (project root) | Existing users upgrading |
| Release announcement | Marketing Copywriter | GitHub Release, blog, social | Potential and existing users |

## Process

### Step 1: Gather the changes

Review what changed since the last release or changelog entry. Sources:

- `git log` since the last tag or changelog entry
- Closed PRs and issues
- ADRs written during the period
- Design docs marked as "Implemented"

For each change, note:
- **What** changed (the fact)
- **Why** it matters to users (the benefit)
- **What users need to do** (migration steps, if any)

### Step 2: Write the CHANGELOG.md entry

Load the **Technical Writer** persona from `personas/technical-writer.md`.

**Dialect:** Check for `BITO_LINT_DIALECT` environment variable or the project's bito-lint config for a dialect preference (en-us, en-gb, en-ca, en-au). If set, use that dialect's spelling conventions consistently throughout both the changelog entry and the release announcement. If not set, default to en-US.

Follow [Keep a Changelog](https://keepachangelog.com/) conventions:

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- [Feature description with concrete detail]

### Changed
- [What changed and why it's different from before]

### Fixed
- [What was broken and how it manifests — not just "fixed bug in X"]

### Removed
- [What's gone and what replaces it, if anything]

### Migration
- [Concrete steps users must take to upgrade]
```

Guidelines for the changelog entry:

1. **Group by impact, not by code.** "Added readability scoring for all doc types" — not "Added readability.rs module."
2. **Name the user-visible behavior.** "Fixed: handoff token count now excludes YAML frontmatter" — not "Fixed token counting bug."
3. **Migration steps are mandatory if behavior changes.** Even "No migration needed" is informative — it tells the user they can upgrade without worry.
4. **Link to ADRs for rationale.** The changelog says *what*; the ADR explains *why*.
5. **One line per change.** Scannable. The reader is looking for the one thing that affects them.

### Step 3: Write the release announcement

Load the **Marketing Copywriter** persona from `personas/marketing-copywriter.md`.

Structure:

1. **Headline.** What's the one thing that makes this release worth attention? Lead with it. Format: `vX.Y.Z: [One-sentence summary of the headline change]`.
2. **2-3 key changes, framed as benefits.** Not "added readability scoring" but "catch jargon-heavy prose before it ships." Each with a concrete example or metric.
3. **Install/upgrade command.** Copy-pasteable. The reader should be able to try it in under a minute.
4. **Link to the full changelog.** For users who want the complete list.

Guidelines for the announcement:

1. **Benefits before features.** Reframe every technical change as a user outcome.
2. **One core message.** Pick the headline change. Everything else is supporting detail.
3. **Be specific.** "Enforces a 2,000-token budget with exact counts" beats "improved handoff quality."
4. **Be honest about scope.** If this is a patch release fixing one thing, don't inflate it. A one-line announcement for a one-line fix is fine.

### Step 4: Cross-reference

- Ensure CHANGELOG.md entries link to relevant ADRs
- Ensure the release announcement links to the full changelog
- If new features have end-user docs, link from the announcement

### Step 5: Quality check

For the **CHANGELOG.md entry**, verify:

- [ ] Changes are grouped by user impact (Added/Changed/Fixed/Removed), not by file or module
- [ ] Each entry describes user-visible behavior, not implementation detail
- [ ] Migration steps are present for any behavior change (even "No migration needed")
- [ ] Links to ADRs are included where decisions drove the change

For the **release announcement**, verify:

- [ ] Leads with the headline benefit, not a feature list
- [ ] Includes a copy-pasteable install/upgrade command
- [ ] Every claim is specific — no "various improvements" or "better performance"
- [ ] Scope is honest — doesn't oversell a minor release

### Step 6: Tone firewall

Run both outputs through `editorial-review` if available. Watch for:

- **Changelog:** Technical Writer voice should be factual and direct, not marketing-adjacent. No "exciting new feature" in a changelog.
- **Announcement:** Marketing Copywriter voice should be enthusiastic but credible. No superlatives without evidence. No disparaging prior versions ("unlike the old, broken approach...").

## Integration

- **Upstream:** `finishing-a-development-branch` identifies changes to document. ADRs and design docs provide rationale context.
- **Downstream:** Release announcements may link to `writing-end-user-docs` for new features. The changelog becomes a reference for future `curating-context` handoffs.
- **Paired with:** `writing-end-user-docs` — if a feature is significant enough for a changelog entry, it may also need updated user docs.
- **Triggered by:** Version tagging, PR merge to main with user-visible changes, or explicit invocation at release time.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Changelog entries describe code, not behavior | "Added `readability.rs`" tells users nothing. "Added readability scoring for documentation files" tells them what they gained. |
| Missing migration steps | Even trivial upgrades benefit from "No migration needed — drop-in replacement." Users scanning for migration steps deserve an explicit answer. |
| Announcement oversells a patch release | Match the energy to the scope. A bugfix gets two sentences. A major feature gets a paragraph. Don't inflate. |
| Same voice for both outputs | The changelog and announcement have different audiences and different personas. If they read the same, one of them is wrong. |
| Vague changelog entries ("various improvements", "bug fixes") | Name every change specifically. If a change isn't worth naming, it isn't worth listing. |
| Announcement without a try-it command | The reader decided to try it. Don't make them hunt for how. Include the install or upgrade command. |
