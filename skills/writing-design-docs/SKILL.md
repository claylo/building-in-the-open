---
name: writing-design-docs
description: Creates structured design documents covering problem context, chosen approach, alternatives considered, and trade-off consequences — the narrative companion to atomic ADRs. Use when formalizing a brainstorming session, writing a design doc or technical spec, before significant feature work, or when architectural decisions need narrative context beyond individual ADRs.
argument-hint: "[topic]"
allowed-tools: Read, Bash(bito *)
license: MIT
---

# Writing Design Docs

**Announce at start:** "I'm using the writing-design-docs skill with the Technical Writer persona to formalize the design."

## Overview

Shape exploratory thinking into a document that a newcomer can read months later and understand what we built, why, and what we considered but rejected. Design docs are the narrative companions to atomic ADRs — they provide the composed story, while ADRs capture individual decisions.

## Context-dependent workflow

Check whether `superpowers:brainstorming` is in your available skills list.

- **If yes** — read `references/with-superpowers.md` for When to Use, Step 1, and Integration details.
- **If no** — read `references/without-superpowers.md` instead.

Then return here and continue with the Quick Reference and Process (Step 2 onward).

## When NOT to Use

- For a single decision — use `capturing-decisions` instead
- For user-facing documentation — use `writing-end-user-docs`
- For session context capture — use `curating-context` (handoff)
- For trivial changes that don't involve architectural choices

## Quick Reference

| Section | Purpose | Mandatory? |
|---------|---------|-----------|
| Overview | What and why in 2-3 sentences | Yes |
| Context | What prompted the work, constraints | Yes |
| Approach | What we decided to build, and how | Yes |
| Alternatives considered | What we rejected and why | Yes |
| Consequences | Gains, costs, deferred work | Yes |
| Related decisions | Links to ADRs | Yes |

## Process

### Step 2: Load the persona and template

Load the **Technical Writer** persona from `../../personas/technical-writer.md` and the design doc template from `../../templates/design-doc.md`.

**Dialect:** Check for `BITO_DIALECT` environment variable or the project's bito config for a dialect preference (en-us, en-gb, en-ca, en-au). If set, use that dialect's spelling conventions consistently throughout the draft. If not set, default to en-US.

### Step 3: Draft the document

Write to `{PROJECT_ROOT}/record/designs/YYYY-MM-DD-<short-kebab-topic>.md`.

Work through each section:

1. **Overview:** What we're building and why, in 2-3 sentences. A reader should know whether this document is relevant to them after reading this section alone.

2. **Context:** What prompted this work. What constraints exist. What prior art or related systems the reader should know about. Write for the newcomer — don't assume they've read other project docs unless you link to them.

3. **Approach:** The core of the document. Architecture, components, data flow, key interfaces. Use diagrams where they clarify. This section answers "what did we decide to build, and how does it work?"

4. **Alternatives considered:** What we evaluated but rejected. This is critical for future readers who will ask "why didn't we just...?" Even one sentence per rejected alternative is valuable if the reasoning is clear.

5. **Consequences:** What we gain, what we lose, what we defer. Honest trade-off accounting builds trust and helps future decision-makers.

6. **Related decisions:** Links to ADRs for individual decisions within this design. If no ADRs exist yet, note that they should be created (see Step 4).

### Step 4: Extract ADRs (prompted)

Scan the finished design doc for discrete technical decisions — places where we chose one approach over another. Present them to the user:

> "I identified N discrete decisions in this document:
> 1. [Decision summary]
> 2. [Decision summary]
> ...
> Which of these should get their own ADRs?"

Per ADR-0004, this is prompted, not automatic. The user/lead agent decides which decisions warrant individual ADRs. For each approved decision, invoke `capturing-decisions` and then add the link to the design doc's Related Decisions section.

### Step 5: Quality check

Before saving, verify:

- [ ] The Overview section tells a reader whether this document is relevant to them
- [ ] Alternatives Considered is populated (not optional, not "none")
- [ ] Consequences include both what we gain and what we lose
- [ ] No assumed context — document stands alone for a newcomer
- [ ] Related ADRs are linked, not duplicated
- [ ] Status field is set accurately (Draft → In Review → Accepted → Implemented)

### Step 6: Tone firewall

Run through editorial review. The Technical Writer persona voice should be consistent: first-person plural, opinionated but grounded, trade-offs explicit, no hedge words.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Empty Alternatives Considered section | Every non-trivial design has alternatives. If you can't name one, the design may be more constrained than you think — document the constraint instead. |
| Duplicating ADR rationale in the design doc | Link to ADRs. The design doc provides narrative; ADRs provide atomic decision records. Don't maintain the same reasoning in two places. |
| Status field stuck on "Draft" for months | Update it. "Accepted" when implementation begins. "Implemented" when done. If abandoned, say so. |
| Writing the approach section without the context | Context first. The reader needs to know *why* before they can evaluate *how*. |
| Over-designing in the document | The design doc captures decisions made, not a complete implementation specification. Leave implementation details to the code and implementation plans. |
