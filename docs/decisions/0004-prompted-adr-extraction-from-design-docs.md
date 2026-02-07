---
status: accepted
date: 2026-02-07
decision-makers: Clay Loveless
consulted: []
informed: []
---

# 0004: Prompted ADR extraction from design docs

## Context and Problem Statement

Design documents often contain multiple discrete technical decisions embedded in the narrative. These decisions should be captured as individual ADRs for searchability and atomic reference. How should we identify and extract these decisions — automatically, manually, or with prompting?

## Decision Drivers

- Decisions embedded in prose are easy to miss and hard to reference individually
- Automatic extraction risks creating noisy, low-value ADRs for every implementation detail
- Manual extraction depends on the author remembering to do it, and decisions get lost
- The extraction process should feel helpful, not bureaucratic

## Considered Options

- Prompted extraction (skill identifies decisions, asks whether to create ADRs)
- Automatic extraction (every decision-shaped paragraph becomes an ADR)
- Manual extraction (author explicitly invokes `writing-adrs` for each decision)

## Decision Outcome

Chosen option: "Prompted extraction," because it balances completeness with signal quality. The skill does the recognition work; the human or lead agent makes the judgment call on which decisions warrant their own ADR.

### Consequences

- Good, because decisions are surfaced that the author might have overlooked
- Good, because the human/agent filters out noise — not every implementation detail needs an ADR
- Good, because the prompt creates a natural checkpoint for reflection on what was actually decided
- Bad, because the prompting interaction adds a step to the design doc workflow
- Bad, because the quality of identified decisions depends on the skill's ability to recognize decision patterns in prose

### Confirmation

Validated in Phase 2 when the `writing-design-docs` skill processes this plugin's design document. If it correctly identifies the design decisions listed in the Design Decisions section and prompts for ADR creation, the prompted model works. If it misses obvious decisions or flags non-decisions, the recognition logic needs tuning.

## Pros and Cons of the Options

### Prompted extraction

The `writing-design-docs` skill scans the document for decision patterns, presents them to the user/agent, and asks which ones warrant ADRs.

- Good, because it catches decisions the author didn't explicitly flag
- Good, because human judgment filters out noise
- Good, because the interaction doubles as a decision review checkpoint
- Bad, because it adds an interactive step to the workflow
- Bad, because recognition quality depends on the skill's pattern detection

### Automatic extraction

Every passage that looks like a decision gets an ADR automatically.

- Good, because nothing is missed
- Bad, because the ADR directory fills with trivial implementation details
- Bad, because low-value ADRs dilute the signal of important architectural decisions
- Bad, because cleaning up over-generated ADRs is more work than creating them would have been

### Manual extraction

The author explicitly invokes `writing-adrs` whenever they recognize a decision worth capturing.

- Good, because only intentional, high-value decisions become ADRs
- Good, because no automation complexity
- Bad, because decisions made implicitly during implementation rarely get captured
- Bad, because capture depends on the author's discipline, and context amnesia is the problem we're solving

## More Information

- Design doc: `docs/designs/2026-02-07-building-in-the-open-plugin-design.md` (Skills section, `writing-design-docs`)
- Related: ADR-0001 (persona layer — the Technical Writer persona guides both the design doc and the extracted ADRs)
