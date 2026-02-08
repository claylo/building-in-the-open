---
name: writing-design-docs
description: Use when formalizing the output of a brainstorming session into a structured design document, before or during significant feature work, or when architectural decisions need narrative context beyond what individual ADRs provide.
---

# Writing Design Docs

## Overview

Shape exploratory thinking into a document that a newcomer can read months later and understand what we built, why, and what we considered but rejected. Design docs are the narrative companions to atomic ADRs — they provide the composed story, while ADRs capture individual decisions.

## When to Use

- After `brainstorming` produces an accepted approach
- Before significant feature work begins (the design doc is the "why and how" that the code doesn't capture)
- When multiple ADRs need narrative context connecting them
- When you want to document architectural evolution for future contributors

## When NOT to Use

- For a single decision — use `writing-adrs` instead
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

### Step 1: Gather source material

If coming from a `brainstorming` session, locate the brainstorming output (typically in `docs/plans/` or the conversation itself). Identify:
- The chosen approach
- Alternatives that were discussed and rejected
- Key decisions that emerged
- Constraints and trade-offs acknowledged

### Step 2: Load the persona and template

Load the **Technical Writer** persona from `personas/technical-writer.md` and the design doc template from `templates/design-doc.md`.

**Dialect:** Check for `BITO_LINT_DIALECT` environment variable or the project's bito-lint config for a dialect preference (en-us, en-gb, en-ca, en-au). If set, use that dialect's spelling conventions consistently throughout the draft. If not set, default to en-US.

### Step 3: Draft the document

Write to `docs/designs/YYYY-MM-DD-<short-kebab-topic>.md`.

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

Per ADR-0004, this is prompted, not automatic. The user/lead agent decides which decisions warrant individual ADRs. For each approved decision, invoke `writing-adrs` and then add the link to the design doc's Related Decisions section.

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

## Integration

- **Upstream:** `brainstorming` produces exploratory output that this skill formalizes
- **Downstream:** `writing-adrs` captures individual decisions extracted from the design doc
- **Referenced by:** Handoffs, changelogs, and end-user docs link to design docs for architectural context
- **Paired with:** `writing-adrs` — design docs and ADRs are complementary, not redundant. The design doc is the narrative; ADRs are the atomic decisions.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Empty Alternatives Considered section | Every non-trivial design has alternatives. If you can't name one, the design may be more constrained than you think — document the constraint instead. |
| Duplicating ADR rationale in the design doc | Link to ADRs. The design doc provides narrative; ADRs provide atomic decision records. Don't maintain the same reasoning in two places. |
| Status field stuck on "Draft" for months | Update it. "Accepted" when implementation begins. "Implemented" when done. If abandoned, say so. |
| Writing the approach section without the context | Context first. The reader needs to know *why* before they can evaluate *how*. |
| Over-designing in the document | The design doc captures decisions made, not a complete implementation specification. Leave implementation details to the code and implementation plans. |
