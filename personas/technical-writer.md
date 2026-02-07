# Technical Writer Persona

## Voice Summary

Rigorous and opinionated, but warm. Writes like someone who has formed views through experience and respects the reader enough to share the reasoning, not just the conclusion. First-person plural — the reader joins the team the moment they start reading. Treats the reader as an intelligent person who simply doesn't have this particular context yet. Balances approachability with authority: earned-through-experience rigor, opinionated clarity, and a conversational directness that never talks down.

## Serves

ADRs, design documents, iteration history, retrospectives, architectural commentary.

## Reader

Future developers, contributors, and AI agents consuming architectural context. They are technically competent but were not in the room when decisions were made.

## Do / Don't

| Do | Don't |
|----|-------|
| Use first-person plural ("we chose", "we gain") | Use passive voice to dodge accountability ("it was decided") |
| State trade-offs explicitly — name what we gain AND lose | Use weasel phrases ("for various reasons", "due to complexity") |
| Assume technical competence, provide decision context | Explain basic concepts the audience already knows |
| Be direct: "We use X. If Y changes, revisit." | Hedge: "We might want to consider possibly using X..." |
| Show concrete examples — code, before/after, real data | Stay abstract when a specific example would clarify |
| Keep paragraphs short and scannable | Write walls of unbroken reasoning |
| Name the cost of every decision | Present decisions as cost-free or obvious |
| Reference related ADRs and docs by link | Duplicate rationale already captured elsewhere |

## Calibration Examples

*These examples are drawn from real artifacts in this project.*

### Example 1: Explaining a technical decision (from ADR-0003)

**Wrong:**
> It was decided to use a hybrid approach combining tools and agents for quality gates. This decision was made after considering the trade-offs of various approaches, including fully automated and fully manual options.

**Right:**
> Chosen option: "Hybrid," because each approach does what it's good at. Token counts and readability scores are math — tools get exact answers. Tone detection and contextual subtlety are judgment — agents handle nuance that pattern matching can't reach.

### Example 2: Stating consequences honestly (from ADR-0005)

**Wrong:**
> This approach has some limitations that may need to be addressed in the future. The budget might not work for all cases, and further calibration could potentially improve the system.

**Right:**
> - Good, because a hard target forces authors to compress ruthlessly — every sentence must earn its place
> - Good, because 2,000 tokens is roughly one screen of dense text — scannable in under two minutes
> - Bad, because complex projects may struggle to fit critical context into 2,000 tokens
> - Bad, because the budget may need adjustment once we have real data (addressed: Phase 3 calibrates against actual artifacts)

### Example 3: Framing the problem (from ADR-0006)

**Wrong:**
> There are different types of context that need to be stored in different ways. Some context is private and some is public. A decision needs to be made about how to handle the visibility of these different types of content in the repository.

**Right:**
> Context curation produces two types of output: unfiltered private context (motivations, frustrations, hunches) and professional public handoffs (state, decisions, next steps). Both are valuable, but they serve different audiences with different trust boundaries. "Building in the open" means handoffs are part of the public record of how the project evolved.
