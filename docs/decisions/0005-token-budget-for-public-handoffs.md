---
status: accepted
date: 2026-02-07
decision-makers: Clay Loveless
consulted: []
informed: []
---

# 0005: Token budget for public handoffs

## Context and Problem Statement

Public handoff documents in `.handoffs/` serve as the primary onboarding artifact for the next agent or human picking up a project. These documents are consumed by AI agents that have finite context windows, and by humans who have finite patience. How long should a handoff be?

## Decision Drivers

- Every token an agent reads before starting productive work is latency and cost
- Handoffs that are too short omit critical context and create confusion
- Handoffs that are too long bury important information in narrative
- The target must be enforceable by tooling, not left to author judgment
- AI agents are the most constrained readers — optimizing for them benefits human readers too

## Considered Options

- Hard budget of 2,000 tokens, enforced by tooling
- Soft guideline with no enforcement
- Tiered budgets based on project complexity

## Decision Outcome

Chosen option: "Hard budget of 2,000 tokens, enforced by tooling," because a concrete, measurable target creates the right compression pressure. When tooling is available (Phase 3), the token counter provides an exact count and fails the check if exceeded. Until then, the target is self-enforced using the handoff template structure.

### Consequences

- Good, because a hard target forces authors to compress ruthlessly — every sentence must earn its place
- Good, because tooling enforcement provides exact counts, not estimates
- Good, because 2,000 tokens is roughly one screen of dense text — scannable in under two minutes
- Good, because optimizing for agent context windows also improves human readability
- Bad, because complex projects may struggle to fit critical context into 2,000 tokens
- Bad, because the budget may need adjustment once we have real data (addressed: Phase 3 calibrates against actual artifacts)

### Confirmation

Phase 3 runs the token counter against all handoffs produced in Phases 0-2. If handoffs consistently land under 2,000 tokens while remaining self-contained and actionable, the budget holds. If they consistently exceed it and cutting further would lose critical information, we adjust the target with real data.

## Pros and Cons of the Options

### Hard budget of 2,000 tokens

Handoffs must be under 2,000 tokens. Enforced by tooling (pre-commit hook) when available.

- Good, because the constraint is measurable and enforceable
- Good, because it creates healthy compression pressure
- Good, because agents can consume the handoff in a small fraction of their context window
- Bad, because some handoffs may genuinely need more space for complex projects
- Bad, because the number (2,000) is an initial estimate, not empirically validated yet

### Soft guideline

"Keep handoffs concise" without a specific number or enforcement.

- Good, because no tooling needed
- Good, because flexible for complex situations
- Bad, because "concise" means different things to different authors and agents
- Bad, because without a target, handoffs tend to grow over time
- Bad, because there's no feedback mechanism telling the author they've written too much

### Tiered budgets

Different token targets for different project sizes or handoff types (e.g., 1,000 for simple, 3,000 for complex).

- Good, because acknowledges that not all handoffs are equal
- Bad, because determining which tier applies adds a decision to the workflow
- Bad, because the "complex" tier becomes the default, undermining the compression goal
- Bad, because tooling must support multiple thresholds per document type

## More Information

- Design doc: `docs/designs/2026-02-07-building-in-the-open-plugin-design.md` (Tooling section)
- Related: ADR-0003 (token counting uses deterministic tools, not agent estimation)
- Calibration: Phase 3 adjusts this target based on real artifact data
