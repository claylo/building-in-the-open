---
status: accepted
date: 2026-02-07
decision-makers: Clay Loveless
consulted: []
informed: []
---

# 0002: Tone firewall on the commit path, not the writing path

## Context and Problem Statement

Agents need to draft freely — exploring ideas, capturing raw context, recording unfiltered observations — without worrying about public appearance. But everything committed to the repository must be professional and pass the "conference-talk test." Where in the workflow should we apply the tone filter?

## Decision Drivers

- Filtering during drafting constrains creative and exploratory writing
- Private context capture (`PRIVATE_MEMORY.md`) must remain completely unfiltered
- Public artifacts must consistently meet professional standards
- The filter must catch both obvious issues (profanity, named individuals) and subtle ones (sarcasm, implied criticism)

## Considered Options

- Filter on the commit path (gate before repository)
- Filter during writing (inline filtering as content is generated)
- Filter on read (post-hoc review of committed content)

## Decision Outcome

Chosen option: "Filter on the commit path," because it preserves full creative freedom during drafting while guaranteeing that everything reaching the repository meets standards. Private artifacts bypass the gate entirely by design.

### Consequences

- Good, because agents draft without self-censoring, producing richer private context
- Good, because `PRIVATE_MEMORY.md` stays completely unfiltered — the private channel is genuinely private
- Good, because the gate is a single enforcement point, easier to audit and improve
- Bad, because an artifact could be drafted in one session and committed in another, requiring the filter to run at commit time regardless of when content was written
- Bad, because the filter adds a step to the commit workflow (acceptable trade-off for the guarantee it provides)

### Confirmation

Validated by the `curating-context` skill: it produces two outputs from the same session — one filtered (`.handoffs/`), one unfiltered (`PRIVATE_MEMORY.md`). If both outputs exist and the public one passes editorial review while the private one contains candid content, the model works.

## Pros and Cons of the Options

### Filter on the commit path

A quality gate runs before any artifact reaches the repository. All committed content passes through it; private content bypasses it.

- Good, because one enforcement point covers all artifact types
- Good, because private context is genuinely unfiltered
- Good, because the gate can improve over time without changing how agents write
- Bad, because it adds latency to the commit workflow
- Bad, because content written in one session may not be filtered until a later commit

### Filter during writing

Agents apply tone guidelines inline as they generate content. No separate gate.

- Good, because no post-processing step needed
- Bad, because agents self-censoring during drafting produces blander, less useful private context
- Bad, because filtering quality depends on each agent's adherence to guidelines — no structural guarantee
- Bad, because private memory files would need an explicit "skip filtering" flag, adding complexity

### Filter on read

Content is committed as-written and reviewed post-hoc by a periodic review process.

- Good, because no friction in the writing or commit workflow
- Bad, because embarrassing content is public (even briefly) before review catches it
- Bad, because the damage window between commit and review is unpredictable
- Bad, because "building in the open" means external eyes may see content before review runs

## More Information

- Design doc: `docs/designs/2026-02-07-building-in-the-open-plugin-design.md` (Tooling section)
- Related: ADR-0001 (persona layer enables the firewall to know which voice to check against)
