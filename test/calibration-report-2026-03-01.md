# Token Calibration Report

Date: 2026-03-01
bito-lint: 0.1.7
Corpus: 14 files from building-in-the-open plugin

Ground truth: Anthropic `count_tokens` API (model: claude-sonnet-4-5-20250929)

Backends (all local, no external API calls):
- **claude**: ctoc greedy (38K verified vocab, aho-corasick longest-match, unmatched bytes = 1 token each)
- **openai**: bpe-openai cl100k_base (exact BPE encoding)

| File                                   |   claude |   openai |   actual | cl→act% | oai→act% |
| -------------------------------------- | -------- | -------- | -------- | -------- | -------- |
| personas/technical-writer.md           |      878 |      776 |      838 |     4.8% |    -7.4% |
| personas/context-curator.md            |     1130 |      973 |     1080 |     4.6% |    -9.9% |
| personas/doc-writer.md                 |      977 |      855 |      947 |     3.2% |    -9.7% |
| personas/marketing-copywriter.md       |      871 |      768 |      838 |     3.9% |    -8.4% |
| skills/curating-context/SKILL.md       |     1462 |     1262 |     1408 |     3.8% |   -10.4% |
| skills/writing-adrs/SKILL.md           |     1553 |     1373 |     1490 |     4.2% |    -7.9% |
| skills/writing-design-docs/SKILL.md    |     1535 |     1365 |     1486 |     3.3% |    -8.1% |
| skills/writing-end-user-docs/SKILL.md  |     1755 |     1562 |     1715 |     2.3% |    -8.9% |
| skills/writing-changelogs/SKILL.md     |     1907 |     1687 |     1838 |     3.8% |    -8.2% |
| skills/editorial-review/SKILL.md       |     2128 |     1778 |     2014 |     5.7% |   -11.7% |
| templates/adr.md                       |      692 |      599 |      684 |     1.2% |   -12.4% |
| templates/handoff.md                   |      545 |      474 |      539 |     1.1% |   -12.1% |
| templates/design-doc.md                |      608 |      532 |      583 |     4.3% |    -8.7% |
| agents/editorial-reviewer.md           |      879 |      756 |      843 |     4.3% |   -10.3% |

## Summary

| Metric | claude | openai |
| ------ | ------ | ------ |
| Total tokens | 16920 | 14760 |
| claude vs openai | +14.6% | — |
| Total actual (Anthropic API) | — | 16303 |

### vs Anthropic API Ground Truth (14 files)

| Metric | claude→actual | openai→actual |
| ------ | ------------- | ------------- |
| Mean delta | 3.6% | -9.6% |
| Max abs delta | 5.7% | 12.4% |
| Overall ratio (local/actual) | 1.0378 | 0.9054 |

### Framing-Adjusted (actual - 7 tokens)

Anthropic API counts include message framing overhead (~7 tokens per request).

| File                                   |   claude |  adj_act | cl_delta |   cl_pct |
| -------------------------------------- | -------- | -------- | -------- | -------- |
| personas/technical-writer.md           |      878 |      831 |       +47 |     5.7% |
| personas/context-curator.md            |     1130 |     1073 |       +57 |     5.3% |
| personas/doc-writer.md                 |      977 |      940 |       +37 |     3.9% |
| personas/marketing-copywriter.md       |      871 |      831 |       +40 |     4.8% |
| skills/curating-context/SKILL.md       |     1462 |     1401 |       +61 |     4.4% |
| skills/writing-adrs/SKILL.md           |     1553 |     1483 |       +70 |     4.7% |
| skills/writing-design-docs/SKILL.md    |     1535 |     1479 |       +56 |     3.8% |
| skills/writing-end-user-docs/SKILL.md  |     1755 |     1708 |       +47 |     2.8% |
| skills/writing-changelogs/SKILL.md     |     1907 |     1831 |       +76 |     4.2% |
| skills/editorial-review/SKILL.md       |     2128 |     2007 |       +121 |     6.0% |
| templates/adr.md                       |      692 |      677 |       +15 |     2.2% |
| templates/handoff.md                   |      545 |      532 |       +13 |     2.4% |
| templates/design-doc.md                |      608 |      576 |       +32 |     5.6% |
| agents/editorial-reviewer.md           |      879 |      836 |       +43 |     5.1% |

Framing-adjusted claude backend: mean 4.3%, max 6.0%

### Interpretation

The **claude** backend (ctoc greedy) intentionally overcounts — unmatched bytes
each cost 1 token. This is the safe direction for budget enforcement: you will
never exceed a budget silently.

The **openai** backend (bpe cl100k_base) is exact for GPT-4/GPT-3.5 but
undercounts vs Claude's tokenizer. Use it only when targeting OpenAI models.

## Raw JSON

```json
[
  {"file": "personas/technical-writer.md", "claude": 878, "openai": 776, "actual": 838},
  {"file": "personas/context-curator.md", "claude": 1130, "openai": 973, "actual": 1080},
  {"file": "personas/doc-writer.md", "claude": 977, "openai": 855, "actual": 947},
  {"file": "personas/marketing-copywriter.md", "claude": 871, "openai": 768, "actual": 838},
  {"file": "skills/curating-context/SKILL.md", "claude": 1462, "openai": 1262, "actual": 1408},
  {"file": "skills/writing-adrs/SKILL.md", "claude": 1553, "openai": 1373, "actual": 1490},
  {"file": "skills/writing-design-docs/SKILL.md", "claude": 1535, "openai": 1365, "actual": 1486},
  {"file": "skills/writing-end-user-docs/SKILL.md", "claude": 1755, "openai": 1562, "actual": 1715},
  {"file": "skills/writing-changelogs/SKILL.md", "claude": 1907, "openai": 1687, "actual": 1838},
  {"file": "skills/editorial-review/SKILL.md", "claude": 2128, "openai": 1778, "actual": 2014},
  {"file": "templates/adr.md", "claude": 692, "openai": 599, "actual": 684},
  {"file": "templates/handoff.md", "claude": 545, "openai": 474, "actual": 539},
  {"file": "templates/design-doc.md", "claude": 608, "openai": 532, "actual": 583},
  {"file": "agents/editorial-reviewer.md", "claude": 879, "openai": 756, "actual": 843}
]
```
