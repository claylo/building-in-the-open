
# Token Calibration Report

Date: 2026-02-11
Corpus: 14 files from building-in-the-open plugin
API model: claude-sonnet-4-5-20250929

| File                                   | tiktoken |   claude |      API | tk→API% | cl→API% |
| -------------------------------------- | -------- | -------- | -------- | -------- | -------- |
| personas/technical-writer.md           |      776 |      821 |      838 |    -7.4% |    -2.0% |
| personas/context-curator.md            |      973 |     1040 |     1080 |    -9.9% |    -3.7% |
| personas/doc-writer.md                 |      855 |      917 |      947 |    -9.7% |    -3.2% |
| personas/marketing-copywriter.md       |      768 |      826 |      838 |    -8.4% |    -1.4% |
| skills/curating-context/SKILL.md       |     1262 |     1363 |     1408 |   -10.4% |    -3.2% |
| skills/writing-adrs/SKILL.md           |     1370 |     1469 |     1486 |    -7.8% |    -1.1% |
| skills/writing-design-docs/SKILL.md    |     1365 |     1483 |     1486 |    -8.1% |    -0.2% |
| skills/writing-end-user-docs/SKILL.md  |     1562 |     1685 |     1715 |    -8.9% |    -1.7% |
| skills/writing-changelogs/SKILL.md     |     1687 |     1818 |     1838 |    -8.2% |    -1.1% |
| skills/editorial-review/SKILL.md       |     1778 |     1941 |     2014 |   -11.7% |    -3.6% |
| templates/adr.md                       |      599 |      676 |      684 |   -12.4% |    -1.2% |
| templates/handoff.md                   |      474 |      519 |      539 |   -12.1% |    -3.7% |
| templates/design-doc.md                |      532 |      582 |      583 |    -8.7% |    -0.2% |
| agents/editorial-reviewer.md           |      756 |      846 |      843 |   -10.3% |     0.4% |

## Summary

| Metric | tiktoken | claude-local |
| ------ | -------- | ------------ |
| Total tokens | 14757 | 15986 |
| claude-local vs tiktoken | — | +8.3% |
| Total API tokens | — | 16299 |

### vs API Ground Truth (14 files)

| Metric | tiktoken→API | claude-local→API |
| ------ | ------------ | ---------------- |
| Mean delta | -9.6% | -1.8% |
| Max abs delta | 12.4% | 3.7% |
| Overall ratio (local/API) | 0.9054 | 0.9808 |

### Message Framing Overhead

API counts include message framing (role tokens, structural markup). Measured
framing overhead: **7 tokens** (via single-token input: API returns 8 for "x").

### Framing-Adjusted Accuracy (claude-tokenizer vs API - 7)

| Metric | tiktoken→API | claude-local→API |
| ------ | ------------ | ---------------- |
| Mean delta | -10.2% | -1.2% |
| Max abs delta | 12.9% | 3.3% |

Per-file framing-adjusted deltas (claude-local):

| File | cl_local | api_raw | delta | pct |
| ---- | -------: | ------: | ----: | --: |
| personas/technical-writer.md | 821 | 831 | -10 | -1.2% |
| personas/context-curator.md | 1040 | 1073 | -33 | -3.1% |
| personas/doc-writer.md | 917 | 940 | -23 | -2.4% |
| personas/marketing-copywriter.md | 826 | 831 | -5 | -0.6% |
| skills/curating-context/SKILL.md | 1363 | 1401 | -38 | -2.7% |
| skills/writing-adrs/SKILL.md | 1469 | 1479 | -10 | -0.7% |
| skills/writing-design-docs/SKILL.md | 1483 | 1479 | +4 | +0.3% |
| skills/writing-end-user-docs/SKILL.md | 1685 | 1708 | -23 | -1.3% |
| skills/writing-changelogs/SKILL.md | 1818 | 1831 | -13 | -0.7% |
| skills/editorial-review/SKILL.md | 1941 | 2007 | -66 | -3.3% |
| templates/adr.md | 676 | 677 | -1 | -0.1% |
| templates/handoff.md | 519 | 532 | -13 | -2.4% |
| templates/design-doc.md | 582 | 576 | +6 | +1.0% |
| agents/editorial-reviewer.md | 846 | 836 | +10 | +1.2% |

### Interpretation

**claude-tokenizer has real but small divergence** from the API tokenizer — -1.2% mean,
3.3% max after removing framing overhead. The embedded `claude-v3-tokenizer.json`
is not byte-identical to the API's current tokenizer, but it's a **5x improvement**
over tiktoken's -10.2% mean.

Recommendation: Switch bito-lint from tiktoken-rs to claude-tokenizer crate.
For budget enforcement at 2,000 tokens, worst-case error is ~66 tokens (3.3%)
vs ~240 tokens (12%) with tiktoken.

## Raw JSON

```json
[
  {"file": "personas/technical-writer.md", "tiktoken": 776, "claude_local": 821, "api": 838},
  {"file": "personas/context-curator.md", "tiktoken": 973, "claude_local": 1040, "api": 1080},
  {"file": "personas/doc-writer.md", "tiktoken": 855, "claude_local": 917, "api": 947},
  {"file": "personas/marketing-copywriter.md", "tiktoken": 768, "claude_local": 826, "api": 838},
  {"file": "skills/curating-context/SKILL.md", "tiktoken": 1262, "claude_local": 1363, "api": 1408},
  {"file": "skills/writing-adrs/SKILL.md", "tiktoken": 1370, "claude_local": 1469, "api": 1486},
  {"file": "skills/writing-design-docs/SKILL.md", "tiktoken": 1365, "claude_local": 1483, "api": 1486},
  {"file": "skills/writing-end-user-docs/SKILL.md", "tiktoken": 1562, "claude_local": 1685, "api": 1715},
  {"file": "skills/writing-changelogs/SKILL.md", "tiktoken": 1687, "claude_local": 1818, "api": 1838},
  {"file": "skills/editorial-review/SKILL.md", "tiktoken": 1778, "claude_local": 1941, "api": 2014},
  {"file": "templates/adr.md", "tiktoken": 599, "claude_local": 676, "api": 684},
  {"file": "templates/handoff.md", "tiktoken": 474, "claude_local": 519, "api": 539},
  {"file": "templates/design-doc.md", "tiktoken": 532, "claude_local": 582, "api": 583},
  {"file": "agents/editorial-reviewer.md", "tiktoken": 756, "claude_local": 846, "api": 843}
]
```
