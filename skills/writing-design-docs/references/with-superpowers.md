# Writing Design Docs — with superpowers

**Announce at start:** "I'm using the writing-design-docs skill with the Technical Writer persona to formalize the design (bito-flavored)."

## When to Use

- After `superpowers:brainstorming` produces an accepted approach
- Before significant feature work begins (the design doc is the "why and how" that the code doesn't capture)
- When multiple ADRs need narrative context connecting them
- When you want to document architectural evolution for future contributors

## Step 1: Gather source material

Locate the brainstorming output from the `superpowers:brainstorming` session (typically in `docs/plans/` or the conversation itself). Identify:

- The chosen approach
- Alternatives that were discussed and rejected
- Key decisions that emerged
- Constraints and trade-offs acknowledged

The brainstorming output is raw exploratory thinking. This skill reshapes it into a document that stands alone — a newcomer months from now won't have the brainstorming conversation for context.

## Integration

- **Upstream:** `superpowers:brainstorming` produces exploratory output that this skill formalizes
- **Downstream:** `capturing-decisions` captures individual decisions extracted from the design doc
- **Referenced by:** Handoffs, changelogs, and end-user docs link to design docs for architectural context
- **Paired with:** `capturing-decisions` — design docs and ADRs are complementary, not redundant. The design doc is the narrative; ADRs are the atomic decisions.
