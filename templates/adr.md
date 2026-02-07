# ADR Template (MADR 4.0.0)

Based on [Markdown Any Decision Records](https://github.com/adr/madr/blob/4.0.0/template/adr-template.md).

**Persona:** Technical Writer

**Location:** `docs/decisions/NNNN-<short-kebab-title>.md`

**Numbering:** Sequential four-digit, zero-padded (0001, 0002, ...).

---

## Template

```markdown
---
status: {proposed | accepted | deprecated | superseded by NNNN}
date: YYYY-MM-DD
decision-makers: [who was involved in the decision]
consulted: [subject-matter experts consulted, if any]
informed: [who is kept up-to-date, if any]
---

# NNNN: [Short title of solved problem and solution]

## Context and Problem Statement

[Describe the context and problem in 2-3 sentences. Articulate the problem as a question where possible.]

## Decision Drivers

- [Force, concern, or constraint driving this decision]
- [Another driver]

## Considered Options

- [Option 1]
- [Option 2]
- [Option 3]

## Decision Outcome

Chosen option: "[Option N]", because [justification].

### Consequences

- Good, because [positive consequence]
- Bad, because [negative consequence]

### Confirmation

[How we will verify the decision was implemented correctly — review, test, metric, etc.]

## Pros and Cons of the Options

### [Option 1]

[Brief description or pointer to more information]

- Good, because [argument]
- Bad, because [argument]

### [Option 2]

[Brief description or pointer to more information]

- Good, because [argument]
- Bad, because [argument]

## More Information

[Links to related ADRs, design docs, or resources. When/how to revisit this decision.]
```

---

## Guidance

- **The "why" is the whole point.** The decision itself is usually obvious from the code. The rationale is what disappears when people leave. Write as if explaining to a competent newcomer who wasn't in the room.
- **Trade-offs are mandatory.** Every decision has a cost. The Consequences section must include at least one "Bad, because..." entry. If you can't name a downside, you haven't thought hard enough.
- **Keep it atomic.** One decision per ADR. If a design involves five decisions, write five ADRs and one design doc that references them.
- **Link, don't duplicate.** If the rationale lives in a design doc, link to it. Don't copy paragraphs between documents.
- **Supersede, don't delete.** When a decision is reversed, mark the original as `superseded by NNNN` and write a new ADR explaining what changed.
