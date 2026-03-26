---
name: writing-end-user-docs
description: Generates tutorials, how-to guides, getting-started content, and API references using the Doc Writer persona — example-first, progressive disclosure, copy-paste ready. Use when writing docs for end users, creating a guide or tutorial, documenting a stable feature, writing API references, or for docs-driven development.
argument-hint: "[feature-or-topic]"
allowed-tools: Read, Bash(bito *)
license: MIT
---

# Writing End-User Docs

**Announce at start:** "I'm using the writing-end-user-docs skill with the Doc Writer persona."

## Quick Reference

| Aspect | Guidance |
|--------|----------|
| **Persona** | Doc Writer (`../../personas/doc-writer.md`) |
| **Output location** | Project-specific — typically `docs/` or a documentation site directory |
| **Structure** | Progressive disclosure: getting started → common tasks → advanced → internals |
| **Readability target** | Flesch-Kincaid grade ≤ 8 (initial estimate — calibrate against real docs) |
| **Core principle** | Show a working example first, explain after |

## Process

### Step 1: Identify the user's goal

Frame the document around a task: "How do I check a handoff's token count?" — not "The tokens subcommand of bito."

### Step 2: Load the persona

Load the **Doc Writer** persona from `../../personas/doc-writer.md`.

**Dialect:** Check for `BITO_DIALECT` environment variable or the project's bito config for a dialect preference (en-us, en-gb, en-ca, en-au). If set, use that dialect's spelling conventions consistently throughout the draft. If not set, default to en-US.

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

Each level should feel complete on its own:

1. **Getting started** — Install + first command. Under 5 minutes to "hello world."
2. **Common tasks** — 80/20 recipes. Copy-pasteable.
3. **Advanced usage** — Configuration, customization, integration.
4. **Internals** — How it works. Only for the curious.

### Step 5: Write concrete examples

Every claim about what the tool does must include a runnable example. The examples are the documentation — the prose around them is connective tissue.

For CLI tools:
```sh
bito tokens .handoffs/2026-02-08-my-handoff.md --budget 2000
# PASS — 1,847 tokens (budget: 2,000)
```

For config-driven checks:
```sh
bito lint record/decisions/0001-my-adr.md
# Runs completeness + readability checks from .bito.yaml rules
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

- **Upstream:** `writing-design-docs` provides the architectural context that informs what to document. Brainstorming sessions may identify user-facing features that need docs.
- **Downstream:** `editorial-review` validates the finished document. `writing-changelogs` (release announcements) may link to these docs.
- **Triggered by:** New features landing on main — should produce or update end-user docs.
- **Complementary to:** README sections use the Marketing Copywriter persona to *attract* users; end-user docs use the Doc Writer persona to *onboard* them. They link to each other but have different jobs.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Leading with architecture or history | First code block within 10 lines. Lead with what the user can *do*. |
| "Simply" or "just" before multi-step process | Drop the word. If it's more than one action, it isn't simple. |
| API docs without usage examples | Every function/command needs a runnable example, not just parameter descriptions. |
| Front-loading caveats | Happy path first. Caveats after the reader succeeds. |
| Assuming reader has read other docs | Stand alone or link explicitly. No "as described elsewhere." |
