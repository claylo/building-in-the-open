---
name: curating-context
description: Captures session decisions, open items, landmines, and current state into a public handoff document (committed, tone-firewalled, token-budgeted) so the next agent or person can pick up quickly. Use when wrapping up a session, switching focus, handing off to another agent or person, saving progress before context is lost, or when someone says "let's write a handoff".
argument-hint: "[topic]"
allowed-tools: Read, Bash(bito *)
license: MIT
---

# Curating Context

**Announce at start:** "I'm using the curating-context skill with the Context Curator persona to capture session context."

## Overview

Produce a **public handoff**: a committed, tone-firewalled, token-budgeted document that makes the next agent or human effective as fast as possible. This skill focuses exclusively on the handoff artifact — private note-taking happens in whatever journaling tool the user already has configured.

## When to Use

- End of a work session (before closing the conversation)
- Switching focus to a different area of the codebase
- After a significant decision point that changes project direction
- When you realize accumulated context would be lost without capture
- Before handing off to another agent or team member

## When NOT to Use

- For a single technical decision — use `capturing-decisions` instead
- For project documentation aimed at end users — use `writing-end-user-docs`
- For release notes or changelogs — use `writing-changelogs`
- For formalizing a design — use `writing-design-docs`

## Quick Reference

| Output | Location | Committed? | Tone firewall? | Token target |
|--------|----------|-----------|----------------|-------------|
| Public handoff | `.handoffs/YYYY-MM-DD-HHMM-<topic>.md` | Yes | Yes | < 2,000 |

## Session Snapshot

The following is injected at skill load time — no tool calls needed.

**Branch:** !`git branch --show-current 2>/dev/null || echo "(not a git repo)"`

**Recent commits:**
!`git log --oneline -15 2>/dev/null || echo "(no git history)"`

**Working tree:**
!`git status --short 2>/dev/null || echo "(clean)"`

**Staged/unstaged diff summary:**
!`git diff --stat HEAD 2>/dev/null`

**Existing handoffs:**
!`ls -t .handoffs/*.md 2>/dev/null | head -5 || echo "(none)"`

## Process

<IMPORTANT>
**NOTE:** Do not generate the filename date-time stamp until immediately prior to writing the file. Do not guess the date or time.
</IMPORTANT>

### Step 1: Gather context

Use the session snapshot above as your starting point. Then review:
- What was accomplished this session?
- What decisions were made, and why?
- What's the current state of the codebase? (tests passing? broken? in-progress?)
- What should the next person do first?
- What will surprise or confuse someone who hasn't been staring at this code?

Before drafting, dump unfiltered observations (frustrations, hunches, things that surprised you) into whatever private-capture tool you already use. This skill writes the handoff, not your journal — but the polished version is easier to write once the raw stuff is out of your head.

### Step 2: Write the public handoff

Load the **Context Curator** persona from `${CLAUDE_PLUGIN_ROOT}/personas/context-curator.md` (public mode).

**Dialect:** Check for `BITO_DIALECT` environment variable or the project's bito config for a dialect preference (en-us, en-gb, en-ca, en-au). If set, use that dialect's spelling conventions consistently throughout the draft. If not set, default to en-US.

Use the handoff template from `${CLAUDE_PLUGIN_ROOT}/templates/handoff.md`. Fill every section:

1. **Where things stand** — Current state in 2-3 sentences. What works, what doesn't yet.
2. **Decisions made** — Bulleted, with brief rationale or link to ADR.
3. **What's next** — Prioritized, actionable, with `file:line` pointers where helpful.
4. **Landmines** — Specific things that will bite the next reader.

### Step 3: Check quality

Before saving the public handoff, verify:

- [ ] **Self-contained?** Could a stranger with repo access start working from this document alone?
- [ ] **Token budget?** Target under 2,000 tokens. If tooling is available, run the token counter. If not, keep it to roughly one screen of text.
- [ ] **No assumed context?** No "as discussed" or "per our conversation" without a link to where it's captured.
- [ ] **Landmines section populated?** If empty, think harder. What will confuse someone who wasn't here?
- [ ] **State color honest?** Green/Yellow/Red reflects reality, not optimism.

### Step 4: Tone firewall

If the `editorial-review` skill or agent is available, run the public handoff through it. If not, self-check against the conference-talk test: would every sentence in this document be comfortable to say aloud at a technical deep-dive conference?

Specifically check for:
- Negative mentions of people, projects, or products
- Frustration or sarcasm that leaked from private thinking
- Implied criticism ("unlike the *previous* approach...")
- Jargon or inside references that assume context

## Integration

- **Replaces and enhances** the standalone `handoff` skill
- **Pairs with** `capturing-decisions` — if decisions were made this session, capture them as ADRs and reference them from the handoff
- **Feeds into** the next session's onboarding — the handoff is the first thing the next agent reads
- **Used by** branch completion workflows as the final context capture before merge

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Vague next steps ("continue working on the feature") | Be specific: what file, what function, what's the first concrete action? |
| Empty landmines section | If you can't name a landmine, you haven't thought about what will surprise the next reader |
| Exceeding the token budget with narrative prose | Use the template structure. Bullets over paragraphs. Link to ADRs for rationale instead of inlining it. |
| Referencing context not in the document or repo | Every reference must resolve. "As discussed" is a broken link. |
