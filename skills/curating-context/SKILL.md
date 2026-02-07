---
name: handoff
description: Use when ending a work session, switching focus areas, reaching a decision point, or when context needs to be preserved for the next agent or human. Produces both a public handoff document and private memory capture.
---

# Curating Context

## Overview

Capture session context into two outputs: a **public handoff** (committed to the repo, tone-firewalled, token-budgeted) and a **private memory file** (gitignored, unfiltered, full candor). The public handoff makes the next agent or human effective as fast as possible. The private memory preserves the full picture for future-you.

## When to Use

- End of a work session (before closing the conversation)
- Switching focus to a different area of the codebase
- After a significant decision point that changes project direction
- When you realize accumulated context would be lost without capture
- Before handing off to another agent or team member

## When NOT to Use

- For a single technical decision — use `writing-adrs` instead
- For project documentation aimed at end users — use `writing-end-user-docs`
- For release notes or changelogs — use `writing-changelogs`
- For formalizing a design — use `writing-design-docs`

## Quick Reference

| Output | Location | Committed? | Tone firewall? | Token target |
|--------|----------|-----------|----------------|-------------|
| Public handoff | `.handoffs/YYYY-MM-DD-HHMMSS-<topic>.md` | Yes | Yes | < 2,000 |
| Private memory | `PRIVATE_MEMORY.md` (project root) | No (gitignored) | No | No limit |

## Process

### Step 1: Gather context

Before writing, review:
- What was accomplished this session?
- What decisions were made, and why?
- What's the current state of the codebase? (tests passing? broken? in-progress?)
- What should the next person do first?
- What will surprise or confuse someone who hasn't been staring at this code?

### Step 2: Write the private memory

Write `PRIVATE_MEMORY.md` first. This is the unfiltered capture — motivations, frustrations, hunches, half-formed ideas, people dynamics. Don't self-censor. This file is gitignored and never reaches the repository.

If a `PRIVATE_MEMORY.md` already exists, append to it with a dated section header:

```markdown
## 2026-02-07 — [brief topic]

[New private context here]
```

### Step 3: Write the public handoff

Load the **Context Curator** persona from `personas/context-curator.md` (public mode).

Use the handoff template from `templates/handoff.md`. Fill every section:

1. **Where things stand** — Current state in 2-3 sentences. What works, what doesn't yet.
2. **Decisions made** — Bulleted, with brief rationale or link to ADR.
3. **What's next** — Prioritized, actionable, with `file:line` pointers where helpful.
4. **Landmines** — Specific things that will bite the next reader.

### Step 4: Check quality

Before saving the public handoff, verify:

- [ ] **Self-contained?** Could a stranger with repo access start working from this document alone?
- [ ] **Token budget?** Target under 2,000 tokens. If tooling is available, run the token counter. If not, keep it to roughly one screen of text.
- [ ] **No assumed context?** No "as discussed" or "per our conversation" without a link to where it's captured.
- [ ] **Landmines section populated?** If empty, think harder. What will confuse someone who wasn't here?
- [ ] **State color honest?** Green/Yellow/Red reflects reality, not optimism.

### Step 5: Tone firewall (public handoff only)

If the `editorial-review` skill or agent is available, run the public handoff through it. If not, self-check against the conference-talk test: would every sentence in this document be comfortable to say aloud at a technical deep-dive conference?

Specifically check for:
- Negative mentions of people, projects, or products
- Frustration or sarcasm that leaked from private thinking
- Implied criticism ("unlike the *previous* approach...")
- Jargon or inside references that assume context

## Integration

- **Replaces and enhances** the standalone `handoff` skill
- **Pairs with** `writing-adrs` — if decisions were made this session, capture them as ADRs and reference them from the handoff
- **Feeds into** the next session's onboarding — the handoff is the first thing the next agent reads
- **Used by** `finishing-a-development-branch` as the final context capture before merge

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Writing the public handoff first and forgetting the private capture | Always write private first — it takes 2 minutes and preserves context you can't get back |
| Vague next steps ("continue working on the feature") | Be specific: what file, what function, what's the first concrete action? |
| Empty landmines section | If you can't name a landmine, you haven't thought about what will surprise the next reader |
| Exceeding the token budget with narrative prose | Use the template structure. Bullets over paragraphs. Link to ADRs for rationale instead of inlining it. |
| Referencing context not in the document or repo | Every reference must resolve. "As discussed" is a broken link. |
