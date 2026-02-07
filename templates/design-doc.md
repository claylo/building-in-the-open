# Design Document Template

**Persona:** Technical Writer

**Location:** `docs/designs/YYYY-MM-DD-<short-kebab-topic>.md`

---

## Template

```markdown
# [Feature/System Name]

**Date:** YYYY-MM-DD
**Status:** [Draft | In Review | Accepted | Implemented]

## Overview

[What we're building and why, in 2-3 sentences. A reader should know whether this document is relevant to them after this section.]

## Context

[What prompted this work? What constraints exist? What prior art or related systems should the reader know about?]

## Approach

[What we decided to build, and how. This is the core of the document — architecture, components, data flow, key interfaces. Use diagrams where they clarify.]

## Alternatives considered

[What we evaluated but rejected, and why. This section is critical for future readers who will inevitably ask "why didn't we just...?" Answer them here.]

## Consequences

[What this approach gains, what it costs, what it defers to later. Be honest about trade-offs — they build trust and help future decision-makers.]

## Related decisions

[Links to ADRs for individual decisions within this design. Each discrete, reversible decision should have its own ADR; the design doc is the composed narrative.]
```

---

## Guidance

- **This is the "why and how" companion to the code.** Code shows *what* was built. The design doc explains *why this way and not another way*. If the code is self-explanatory, the design doc can be brief. If the architecture is non-obvious, the design doc earns its length.
- **Write for the newcomer six months from now.** They're competent but weren't in the room. Don't assume context from conversations — if it matters, it's in this document.
- **Alternatives considered is not optional.** Every non-trivial design has alternatives. Documenting them prevents future teams from re-exploring paths you've already ruled out. One sentence per rejected alternative is enough if the reasoning is clear.
- **Reference ADRs, don't embed them.** A design doc that contains five decisions should link to five ADRs. The design doc provides narrative flow; the ADRs provide atomic, searchable decision records.
- **Update the status.** A design doc stuck in "Draft" for months is noise. Move it to "Accepted" when implementation begins, "Implemented" when it's done. If it's abandoned, say so — don't leave it ambiguous.
