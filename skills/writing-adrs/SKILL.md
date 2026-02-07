---
name: writing-adrs
description: Use when a technical decision has been made and needs to be recorded, after brainstorming converges on an approach, or when you realize a decision was made implicitly during implementation and should be captured explicitly.
---

# Writing ADRs

## Overview

Capture technical decisions as Architecture Decision Records using the MADR 4.0.0 format. The decision itself is usually obvious from the code — the rationale is what disappears when people leave. This skill exists to capture the *why* before it's lost.

## When to Use

- After `brainstorming` converges on an approach
- When you catch yourself saying "we decided to..." without a document to point to
- When an implicit decision during implementation should be made explicit
- When reversing or superseding a previous decision
- When the `writing-design-docs` skill prompts you with extracted decisions

## When NOT to Use

- For implementation details that don't represent a meaningful choice between alternatives
- For decisions that are trivially reversible and low-impact (e.g., variable naming)
- When the decision is already captured in an existing ADR — update that one instead

## Quick Reference

| Field | Purpose |
|-------|---------|
| **Status** | proposed, accepted, deprecated, superseded by NNNN |
| **Context and Problem Statement** | The "why are we even talking about this?" — 2-3 sentences |
| **Decision Drivers** | Forces, constraints, concerns pushing toward a choice |
| **Considered Options** | What we evaluated (minimum 2, ideally 3) |
| **Decision Outcome** | What we chose and the one-line justification |
| **Consequences** | Good AND bad — trade-offs are mandatory |
| **Confirmation** | How we'll know the decision was implemented correctly |
| **Pros and Cons** | Detailed breakdown per option |

## Process

### Step 1: Identify the decision

State the decision as a problem and a chosen solution. If you can't articulate the problem, the decision may not warrant an ADR — or you need to think harder about what problem you're actually solving.

### Step 2: Load the persona and template

Load the **Technical Writer** persona from `personas/technical-writer.md` and the ADR template from `templates/adr.md`.

### Step 3: Determine the ADR number

Check `docs/decisions/` for the highest existing number. Increment by one. Zero-pad to four digits.

### Step 4: Fill the template

Work through each section of the MADR 4.0.0 template:

1. **Frontmatter:** Set status (usually `accepted` if the decision is already implemented, `proposed` if it's under review). List decision-makers.

2. **Title:** Short, descriptive. Format: `NNNN: [Problem solved and solution chosen]`. Good: "0007: Token counting via tiktoken-rs for handoff budget enforcement." Bad: "0007: Token counting decision."

3. **Context and Problem Statement:** Frame the problem as a question where possible. "How should we count tokens in handoff documents?" is better than "We need to count tokens."

4. **Decision Drivers:** List the forces making this a non-trivial decision. If there's only one driver and one obvious answer, this probably doesn't need an ADR.

5. **Considered Options:** Minimum two options. Three is ideal. Include the option you rejected — future readers will ask "why didn't we just...?" and this section answers them.

6. **Decision Outcome:** State the chosen option and the core justification in one sentence.

7. **Consequences:** At least one "Good, because..." and at least one "Bad, because..." entry. If you can't name a downside, you haven't thought hard enough about the trade-off.

8. **Confirmation:** How will you know this was implemented correctly? A test? A code review checklist item? A metric?

9. **Pros and Cons of the Options:** Detailed breakdown for each option. This is where future readers spend the most time — it's the evidence behind the verdict.

10. **More Information:** Link to the design doc, related ADRs, external resources. This section turns the ADR from an isolated document into a node in the decision graph.

### Step 5: Quality check

Before saving, verify:

- [ ] Trade-offs are explicit — at least one "Bad, because..." consequence
- [ ] At least two options were considered
- [ ] The title describes both the problem and the solution
- [ ] Links to related ADRs and design docs are included
- [ ] The document stands alone — no assumed context from conversations

### Step 6: Tone firewall

Run the ADR through the editorial review process (agent or self-check). Ensure it passes the conference-talk test and matches the Technical Writer persona voice.

## Integration

- **Upstream:** `brainstorming` and `writing-design-docs` produce decisions that this skill captures
- **Downstream:** ADRs are referenced by design docs, handoffs, and changelogs
- **Paired with:** `writing-design-docs` — if a design doc contains discrete decisions, they should be extracted into ADRs and referenced from the design doc (see ADR-0004 on prompted extraction)

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| No "Bad, because..." consequences | Every decision has a cost. Name it, even if it's minor. |
| Only one option considered | If there's only one option, it's not a decision — it's a requirement. Find the alternative you rejected. |
| Title describes only the solution, not the problem | Include both: "Token counting via tiktoken-rs" tells you what; "for handoff budget enforcement" tells you why. |
| Duplicating rationale from a design doc | Link to the design doc. The ADR captures the atomic decision; the design doc provides narrative context. |
| Status stuck on "proposed" forever | If it's implemented, it's "accepted." If it's abandoned, note why and mark "deprecated." Don't leave ambiguity. |
