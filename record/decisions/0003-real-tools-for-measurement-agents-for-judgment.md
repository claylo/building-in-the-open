---
status: accepted
date: 2026-02-07
decision-makers: Clay Loveless
consulted: []
informed: []
---

# 0003: Real tools for measurement, agents for judgment

## Context and Problem Statement

The quality gate layer needs to check both quantitative properties (token counts, readability scores, section completeness) and qualitative ones (tone, sarcasm, assumed context). Should we use AI agents for all checks, deterministic tools for all checks, or a hybrid?

## Decision Drivers

- Agents are unreliable at counting tokens and computing numerical scores
- Deterministic tools cannot detect sarcasm, implied criticism, or tone mismatches
- Quality gate results must be reproducible for quantitative checks
- The system should provide exact numbers ("3,847 tokens") not estimates ("approximately 4,000 tokens")

## Considered Options

- Hybrid: deterministic tools for measurement, agents for judgment
- Agent-only: use AI agents for all quality checks
- Tool-only: use deterministic tools and pattern matching for all checks

## Decision Outcome

Chosen option: "Hybrid," because each approach does what it's good at. Token counts and readability scores are math — tools get exact answers. Tone detection and contextual subtlety are judgment — agents handle nuance that pattern matching can't reach.

### Consequences

- Good, because quantitative checks produce exact, reproducible numbers
- Good, because qualitative checks leverage agent strengths (nuance, context, judgment)
- Good, because the deterministic layer runs fast and cheap; the agent layer only runs when needed
- Bad, because the system depends on external CLI tools (`tiktoken-rs` or equivalent, readability scorer) that must be installed and maintained
- Bad, because two different execution models (tool invocation vs. agent dispatch) increase implementation complexity

### Confirmation

Phase 3 validates this by running both tool-based and agent-based checks against all artifacts from Phases 0-2. If the tools produce exact counts that match manual verification, and the agent catches tone issues that the tools miss, the hybrid model is confirmed.

## Pros and Cons of the Options

### Hybrid: tools for measurement, agents for judgment

Quantitative checks (token count, readability score, section completeness) run as deterministic CLI tools. Qualitative checks (tone, sarcasm, assumed context) run as agent-assisted review.

- Good, because each check type uses the right tool for the job
- Good, because deterministic checks are fast, cheap, and reproducible
- Good, because agent checks handle subtlety that patterns can't
- Bad, because two execution models to implement and maintain
- Bad, because external tool dependencies must be managed

### Agent-only

All quality checks, including token counting and readability scoring, run through AI agents.

- Good, because one execution model — simpler implementation
- Good, because no external tool dependencies
- Bad, because agents hallucinate numbers — "approximately 2,000 tokens" when the actual count is 3,800
- Bad, because results are non-deterministic — the same document might pass or fail on different runs
- Bad, because agent invocations are expensive for checks that a simple CLI tool handles better

### Tool-only

All quality checks run as deterministic tools and pattern matchers. No agent involvement.

- Good, because all results are deterministic and reproducible
- Good, because no agent invocation cost for quality checks
- Bad, because pattern matching cannot detect sarcasm, damning-with-faint-praise, or implied criticism
- Bad, because tone matching against personas requires understanding context that regex can't provide
- Bad, because the "conference-talk test" is fundamentally a judgment call, not a pattern match

## More Information

- Design doc: `docs/designs/2026-02-07-building-in-the-open-plugin-design.md` (Tooling section)
- Implementation: Phase 3 builds the deterministic tools; Phase 1 builds the agent-based tone firewall
- Tool candidates: `tiktoken-rs` for token counting, Flesch-Kincaid CLI for readability
