# Writing Design Docs — standalone

## When to Use

- Before significant feature work begins (the design doc is the "why and how" that the code doesn't capture)
- After a brainstorming session or informal design discussion converges on an approach
- When multiple ADRs need narrative context connecting them
- When you want to document architectural evolution for future contributors

## Step 1: Gather source material

Before drafting, collect the inputs that will feed the document:

- **Requirements and constraints:** What prompted this work? What are the non-negotiables?
- **The chosen approach:** What did the team decide to build, and why this approach over others?
- **Rejected alternatives:** What was considered but discarded? Even informal "we thought about X but..." counts.
- **Key decisions:** Places where one path was chosen over another. These may become ADRs (see Step 4 in the main skill).
- **Prior art:** Related systems, patterns, or existing code that informed the design.

If no formal brainstorming artifact exists, reconstruct the reasoning from conversations, PRs, issues, or your own understanding. The design doc should capture this context before it's lost.

## Integration

- **Downstream:** `capturing-decisions` captures individual decisions extracted from the design doc
- **Referenced by:** Handoffs, changelogs, and end-user docs link to design docs for architectural context
- **Paired with:** `capturing-decisions` — design docs and ADRs are complementary, not redundant. The design doc is the narrative; ADRs are the atomic decisions.
