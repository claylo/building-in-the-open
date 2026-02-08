---
name: writing-end-user-docs
description: Use when a feature is stable enough to document for end users, when creating tutorials or guides, when writing API references, or for docs-driven development where the documentation is written before or alongside implementation.
---

# Writing End-User Docs

## Overview

Produce documentation that makes someone want to keep reading. End-user docs answer "how do I...?" — not "what does this module do?" They start from the user's goal, not the codebase's structure. This skill uses the Doc Writer persona to produce tutorials, guides, API references, and getting-started content.

## When to Use

- After a feature is stable enough that users can try it
- For docs-driven development — writing the docs first clarifies what the feature should feel like
- When creating a getting-started guide for the project
- When an API reference needs examples showing real usage, not just signatures
- When user feedback reveals that existing docs aren't answering the right questions

## When NOT to Use

- For internal architectural documentation — use `writing-design-docs`
- For capturing session context — use `curating-context`
- For recording decisions — use `writing-adrs`
- For README introductions or release announcements — use `writing-changelogs` (Marketing Copywriter persona)

## Quick Reference

| Aspect | Guidance |
|--------|----------|
| **Persona** | Doc Writer (`personas/doc-writer.md`) |
| **Output location** | Project-specific — typically `docs/` or a documentation site directory |
| **Structure** | Progressive disclosure: getting started → common tasks → advanced → internals |
| **Readability target** | Flesch-Kincaid grade ≤ 8 (initial estimate — calibrate against real docs) |
| **Core principle** | Show a working example first, explain after |

## Process

### Step 1: Identify the user's goal

Before writing anything, answer: "What is the user trying to accomplish?" Not "what did we build?" — that's the internal perspective. Frame the document around a task the user wants to complete.

Good framing: "How do I check a handoff document's token count?"
Bad framing: "The tokens subcommand of bito-lint."

### Step 2: Load the persona

Load the **Doc Writer** persona from `personas/doc-writer.md`.

**Dialect:** Check for `BITO_LINT_DIALECT` environment variable or the project's bito-lint config for a dialect preference (en-us, en-gb, en-ca, en-au). If set, use that dialect's spelling conventions consistently throughout the draft. If not set, default to en-US.

Key reminders:

- Example first, explanation second
- No "simply," "just," or "obviously"
- Short paragraphs, scannable headers, generous whitespace
- Define jargon on first use
- Progressive disclosure — don't front-load edge cases

### Step 3: Choose the document type

| Type | When | Structure |
|------|------|-----------|
| **Getting started** | First-time users | Install → first command → expected output → what just happened |
| **Tutorial** | Learning a workflow | Goal → prerequisites → step-by-step with expected output at each step → next steps |
| **Guide** | Common tasks | Brief context → recipe → variations → gotchas |
| **API reference** | Looking up specifics | Signature → one-sentence description → example → parameters → return value → errors |

### Step 4: Draft with progressive disclosure

Structure content so the reader can stop at any level and have something useful:

1. **Level 1 — Getting started.** Install and run the first command. Under 5 minutes to "hello world."
2. **Level 2 — Common tasks.** The things 80% of users do 80% of the time. Recipes they can copy-paste.
3. **Level 3 — Advanced usage.** Configuration, customization, integration with other tools.
4. **Level 4 — Internals.** How it works under the hood. Only for the curious or the contributing.

Each level should feel complete on its own. A user who reads only Level 1 should walk away with a working setup. A user who reads through Level 3 should feel like a power user.

### Step 5: Write concrete examples

Every claim about what the tool does must include a runnable example or copy-pasteable command. The examples are the documentation — the prose around them is connective tissue.

For CLI tools:
```
command with real arguments
expected output
```

For libraries:
```
minimal working code
what it produces
```

### Step 6: Quality check

Before saving, verify:

- [ ] Can a new user go from zero to working in under 5 minutes using only this document?
- [ ] Does every section start with an example or concrete command?
- [ ] Is jargon defined on first use?
- [ ] Are paragraphs short (≤ 4 sentences)?
- [ ] Headers are descriptive, not clever — the reader scanning the table of contents can find what they need?
- [ ] No "simply," "just," "obviously," or "easy"?
- [ ] Progressive disclosure ordering: basics before edge cases, common before advanced?

### Step 7: Tone firewall

Run through `editorial-review` if available. The Doc Writer voice should be consistent: accessible, example-first, respectful of the reader's time. Check specifically that the document doesn't slip into the Technical Writer voice (too opinionated, too many trade-offs) or the Marketing Copywriter voice (too benefit-forward, not enough substance).

## Integration

- **Upstream:** `writing-design-docs` provides the architectural context that informs what to document. `brainstorming` may identify user-facing features that need docs.
- **Downstream:** `editorial-review` validates the finished document. `writing-changelogs` (release announcements) may link to these docs.
- **Triggered by:** `finishing-a-development-branch` — new features landing should produce or update end-user docs.
- **Complementary to:** README sections use the Marketing Copywriter persona to *attract* users; end-user docs use the Doc Writer persona to *onboard* them. They link to each other but have different jobs.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Starting with architecture or history instead of a working example | Lead with what the user can *do*, not what you *built*. The first code block should appear within the first 10 lines. |
| Using "simply" or "just" before a multi-step process | If it requires more than one action, it isn't simple. Drop the word and let the steps speak for themselves. |
| Documenting the API surface without showing usage | Every function/command/endpoint needs at least one example showing a real use case, not just parameter descriptions. |
| Front-loading caveats and edge cases | Put caveats after the happy path. The reader needs to succeed before they need to handle failure. |
| Writing for the developer who built it, not the user who found it | Read the document as if you've never seen this codebase. Would you know what to do first? |
| Assuming the reader has read other project docs | Each document should stand alone or explicitly link to prerequisites. "See the getting started guide" with a link — not "as described elsewhere." |
