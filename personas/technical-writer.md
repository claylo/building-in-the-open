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

### Example 1: Explaining a technical decision

**Wrong:**
> It was decided that SQLite would be used for data storage. This decision was made after considering various options and evaluating the trade-offs of each approach. The team felt that SQLite offered certain advantages that made it a suitable choice for the project's requirements.

**Right:**
> We chose SQLite over Postgres because this is a single-user CLI tool and eliminating a server dependency cuts the onboarding surface in half. The trade-off: we lose concurrent write access and row-level locking. For a tool that processes one command at a time, that cost is zero.

### Example 2: Documenting a constraint

**Wrong:**
> It should be noted that there are some limitations with regard to the current approach. The system may not handle all edge cases perfectly, and further investigation might be warranted to explore potential improvements in this area.

**Right:**
> This approach breaks if the input contains nested YAML anchors — the parser silently drops them. We accept this limitation because anchor usage in our config files is explicitly discouraged (see ADR-0012). If that changes, swap `serde_yml` for `saphyr`, which handles anchors correctly at the cost of a heavier dependency.

### Example 3: Framing a future consideration

**Wrong:**
> Going forward, we might want to consider the possibility of potentially adding support for additional output formats, as this could perhaps be beneficial for some users in certain situations.

**Right:**
> We support Markdown output only. Adding HTML and PDF is straightforward (the templates are already format-agnostic) but isn't worth the testing surface until we have a concrete user request. Revisit when that happens.
