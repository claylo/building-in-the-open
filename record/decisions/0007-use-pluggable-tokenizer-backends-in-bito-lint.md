---
status: accepted
date: 2026-02-10
decision-makers: Clay Loveless
consulted: []
informed: []
---

# 0007: Use pluggable tokenizer backends in bito-lint

## Context and Problem Statement

bito-lint currently uses [`tiktoken-rs`](https://crates.io/crates/tiktoken-rs) (cl100k_base) to count tokens for budget enforcement. cl100k_base is OpenAI's GPT-4 tokenizer — it has ~100K vocabulary optimized for a different model family. Calibration against the Anthropic [`count_tokens` API](https://platform.claude.com/docs/en/api/messages/count_tokens) showed tiktoken undercounts Claude tokens by -10.2% mean / -12.9% max across our 14-file plugin corpus. This undercount is dangerous: content silently exceeds budgets.

The problem is wider than Claude. bito-lint's plugin architecture is platform-agnostic — it should work with Claude Code, Codex, OpenCode, and future coding agents. Each platform uses its own tokenizer. A single hardcoded tokenizer backend can't serve this.

## Decision Drivers

- Token budgets (e.g., ADR-0005's 2,000-token handoff limit) must reflect what the target model actually consumes
- For budget enforcement, overcounting (conservative) is safe; undercounting is dangerous
- The architecture should support multiple model families, not just Claude
- Any implementation must work in Rust, be fast, and be deterministic
- No official Anthropic tokenizer exists for Claude 3+ (only a [`count_tokens` API endpoint](https://platform.claude.com/docs/en/api/messages/count_tokens))

## Considered Options

1. Keep tiktoken-rs with a calibrated multiplier
2. Switch to [`claude-tokenizer`](https://crates.io/crates/claude-tokenizer) crate (embeds a Claude BPE vocab via HuggingFace `tokenizers`)
3. Vendor [`claude-v3-tokenizer.json`](https://huggingface.co/Xenova/claude-tokenizer/blob/main/tokenizer.json) directly with the `tokenizers` crate
4. Embed ctoc's verified Claude 3+ vocabulary with greedy longest-match (single-backend)
5. Build a `bpe-anthropic` crate using a verified Claude 3+ vocabulary with proper BPE encoding
6. Pluggable tokenizer backends with greedy longest-match as the default strategy

## Decision Outcome

Chosen option: "Pluggable tokenizer backends with greedy longest-match as the default strategy."

The tokenizer becomes a trait with backend selection based on the target model. The first backend uses [ctoc](https://github.com/rohangpta/ctoc)'s 36,495 API-verified Claude 3+ tokens with greedy longest-match. [`bpe-openai`](https://github.com/github/rust-gems/tree/cd18f1c5c6366f154a0e974e975e13938d4ef102/crates/bpe-openai) provides the OpenAI backend using the same [`bpe`](https://github.com/github/rust-gems/tree/cd18f1c5c6366f154a0e974e975e13938d4ef102/crates/bpe) engine, with exact counts for cl100k/o200k models. This architecture generalizes: any model where a verified vocabulary exists can use the same greedy strategy.

### Why greedy longest-match with verified vocabulary

Calibration and provenance analysis showed that accuracy without the correct vocabulary is unreliable regardless of algorithm sophistication. The `claude-tokenizer` crate's -1.2% accuracy on English markdown is coincidental — it embeds the Claude 1/2 vocabulary (see provenance findings below), and its error direction (undercounting) is the dangerous one for budget enforcement.

ctoc's greedy longest-match with API-verified tokens:

| Corpus type | Greedy efficiency | Direction |
|---|---|---|
| Python source code (9 files) | 96.1% | Overcounts (conservative) |
| Mixed code + docs (9 files) | 95.1% | Overcounts (conservative) |
| English prose (5 samples) | 99.2% | Overcounts (conservative) |

"Efficiency" = API_count / greedy_count x 100%. Below 100% means more tokens than the real tokenizer — the safe direction for budget enforcement. DP-optimal tokenization improves by only 0.3-0.4% over greedy, proving the remaining gap is **missing vocabulary**, not a suboptimal algorithm.

For budget enforcement, ~4% overcounting means a 2,000-token budget effectively becomes ~1,920 tokens. This is a small, predictable, and safe reduction — versus the -1.2% mean undercount from `claude-tokenizer` which lets content silently exceed limits.

### Vocabulary provenance findings

Investigation of the `claude-tokenizer` crate's embedded vocabulary revealed it is **not** the Claude 3+ tokenizer. The [`claude-v3-tokenizer.json`](https://github.com/Jellyfishboy/claude-tokenizer/tree/69312f0a433088f13111bf9f8297894d6c5e7ec6/src) traces back to Anthropic's deprecated [`@anthropic-ai/tokenizer`](https://github.com/anthropics/anthropic-tokenizer-typescript) TypeScript package (whose README explicitly states it is "no longer accurate" for Claude 3+), via the [`Xenova/claude-tokenizer`](https://huggingface.co/Xenova/claude-tokenizer) HuggingFace repo.

Cross-referencing against ctoc's API-verified vocabulary:

| Metric | Count |
|---|---|
| claude-tokenizer vocab (HF, Claude 1/2) | 65,000 |
| ctoc verified tokens (Claude 3+) | 36,495 |
| Overlap (in both) | 25,975 |
| In ctoc but NOT in HF vocab | 10,520 |
| In HF vocab but API-rejected (NOT in Claude 3+) | 37,807 |

The two vocabularies are **different tokenizers** with ~40% overlap. The `claude-tokenizer` crate's -1.2% accuracy on English technical markdown is coincidental — two BPE vocabs trained on similar internet text produce similar compression ratios.

### Consequences

- Good, because **accuracy is principled**: every token in the Claude vocabulary has been verified against the actual API, with known provenance
- Good, because **failure mode is conservative**: missing tokens cause over-segmentation (overcounting), which is safe for budget enforcement
- Good, because **multi-model**: trait-based architecture supports Claude, OpenAI, and future model families without architectural changes
- Good, because **minimal per-backend dependencies**: Claude backend is ~50 lines + compile-time embedded vocab — no `tokenizers` crate
- Good, because **any model with a published or extracted vocabulary** can be added as a new backend using the same greedy strategy
- Neutral, because ~4% overcounting reduces effective Claude budget by ~4% (2,000 -> ~1,920 tokens)
- Bad, because only 56% of Claude 3+'s vocabulary is verified — accuracy degrades on content heavy in rare tokens, CJK text, or ALL-CAPS words
- Bad, because no merge order means the greedy tokenizer cannot produce exact BPE encodings, only approximate counts
- Bad, because the vocabulary was extracted at a point in time and could become stale if Anthropic changes their tokenizer

### Confirmation

After implementing:
1. Define a `Tokenizer` trait with `count_tokens(&self, text: &str) -> usize` and `name(&self) -> &str`
2. Implement Claude backend: embed ctoc's 36,495 verified tokens, greedy longest-match via trie
3. Implement OpenAI backend: use `bpe-openai` (exact counts for cl100k/o200k, same `bpe` engine as future `bpe-anthropic`)
4. Run Claude backend against calibration corpus — all files should overcount vs API (positive delta). If any file undercounts, investigate: greedy longest-match over a subset vocabulary should never produce fewer tokens than the full tokenizer. An undercount signals a bug in the implementation or a corrupted vocab, not missing tokens.
5. Mean overcounting should be <=5% on English technical markdown
6. If a model provider publishes an official tokenizer, swap it in as a backend — the pluggable architecture means no structural changes

### Roadmap: toward exact Claude 3+ token counts

The greedy approach is the right interim because it ships today with verified data and a safe failure mode. The endgame for exact counts:

The OpenAI backend already uses the `bpe` engine (via `bpe-openai`). The Claude backend starts with greedy longest-match over ctoc's verified vocab, then upgrades to exact BPE when the vocabulary is complete:

- **`bpe-anthropic`**: follows the `bpe-openai` pattern — same engine, different vocabulary data. Requires a complete, ordered Claude 3+ vocabulary.
- **ctoc** has 36,495 verified tokens (56% of ~65K) but no merge order. Extending the probing could recover more tokens (~400K additional API calls). Merge order could be partially reconstructed using the API's boundary property (described in ctoc's REPORT.md).
- **Anthropic could publish** an official tokenizer (as they did for Claude 1/2) — monitor for this.
- **The pluggable architecture means any of these improvements slot in as a Claude backend swap** — no structural changes needed.

## Pros and Cons of the Options

### Keep tiktoken-rs with a calibrated multiplier

Apply a fixed 1.10x multiplier to tiktoken counts to approximate Claude token counts.

- Good, because no dependency change — minimal diff
- Good, because tiktoken-rs is mature and well-maintained
- Bad, because the multiplier is content-dependent (observed range: 1.07x to 1.14x on our corpus)
- Bad, because it's a hack that compounds: any future tokenizer changes require re-calibration
- Bad, because it only addresses Claude — doesn't generalize to other models

### Switch to claude-tokenizer crate

Replace `tiktoken-rs` with `claude-tokenizer` v0.3.0, which embeds a Claude BPE vocabulary via the HuggingFace `tokenizers` crate.

- Good, because calibration shows -1.2% mean delta vs API after framing adjustment
- Good, because same API shape — `count_tokens(&str) -> Result<usize>`
- Bad, because the embedded vocab is the Claude 1/2 tokenizer, not Claude 3+ (see provenance findings)
- Bad, because it **undercounts** — the dangerous direction for budget enforcement
- Bad, because accuracy is empirical on English markdown and may not generalize
- Bad, because community-maintained with no awareness of the provenance issue
- Bad, because heavy dependency chain (`tokenizers` crate includes C/C++ bindings)

### Vendor [`claude-v3-tokenizer.json`](https://huggingface.co/Xenova/claude-tokenizer/blob/main/tokenizer.json) directly

Embed the HuggingFace-hosted vocabulary directly in bito-lint using the `tokenizers` crate, without the `claude-tokenizer` wrapper.

- Good, because no third-party wrapper dependency
- Bad, because it's the same wrong vocabulary regardless of how it's packaged
- Bad, because functionally identical to `claude-tokenizer` with more maintenance burden

### Embed ctoc's verified vocab with greedy longest-match

Single-backend approach using ctoc's 36,495 API-verified Claude 3+ tokens.

- Good, because every token is verified against the actual Claude 3+ API
- Good, because overcounting failure mode is safe for budget enforcement
- Good, because simple: ~50 lines of core logic, no `tokenizers` crate dependency
- Good, because DP-optimal only improves 0.3% — algorithm is effectively optimal for the vocabulary
- Bad, because single-model — doesn't address the multi-model requirement

### Build a bpe-anthropic crate with verified Claude 3+ vocabulary

Use the `bpe` crate engine (from `github/rust-gems`) with a Claude 3+ vocabulary derived from API probing.

- Good, because `bpe`'s BPE engine produces correct encodings (not greedy approximation)
- Good, because vocabulary-agnostic: `BytePairEncoding::from_dictionary()` takes any ordered token list
- Good, because the `bpe-openai` crate demonstrates the pattern — well-tested architecture
- Bad, because ctoc's vocabulary is only 56% complete (36,495 of ~65K tokens)
- Bad, because recovering the remaining tokens and merge order requires significant API probing effort
- Bad, because the API vocabulary could change at any time, invalidating the work
- Bad, because proper BPE encoding requires merge order, which ctoc does not have

### Pluggable tokenizer backends with greedy longest-match

Trait-based tokenizer architecture where backends are selected by target model. Greedy longest-match is the default strategy for vocab-based backends.

- Good, because combines verified-vocab accuracy with multi-model support
- Good, because one BPE engine (`bpe` crate) across all backends — OpenAI via `bpe-openai` today, Claude via `bpe-anthropic` when vocab is complete
- Good, because adding a new model backend doesn't require architectural changes
- Good, because official tokenizers can be swapped in per-backend as they become available
- Good, because drops `tiktoken-rs` dependency entirely — `bpe-openai` provides exact OpenAI counts with the same engine
- Neutral, because slightly more code than a single-backend approach (trait + dispatch)

## More Information

- Calibration data: `test/calibration-report-2026-02-10.md` (14-file three-way comparison)
- Calibration tooling: `tools/token-compare/` (dual-tokenizer CLI), `test/calibrate-tokens.sh`
- ctoc project: [github.com/rohangpta/ctoc](https://github.com/rohangpta/ctoc) — 36,495 API-verified Claude 3+ tokens extracted via ~276K API probes
- ctoc accuracy: 96.1% on code, 99.2% on English prose; overcounting direction is consistent
- ctoc methodology: REPORT.md documents the extraction approach including the section-sign sandwich technique for normalizing API framing overhead
- Vocabulary comparison: 25,975 token overlap between Claude 1/2 (HF) and Claude 3+ (ctoc); 37,807 HF tokens confirmed absent from Claude 3+
- Provenance chain: Anthropic TypeScript SDK -> Xenova/claude-tokenizer (HuggingFace) -> Jellyfishboy/claude-tokenizer (Rust) — all trace to the Claude 1/2 tokenizer
- Related: ADR-0005 (2,000-token handoff budget — now more accurately enforced)
- Related: ADR-0003 (real tools for measurement — this decision improves the measurement tool)
