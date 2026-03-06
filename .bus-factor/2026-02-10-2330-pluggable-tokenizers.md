# Handoff: Pluggable Tokenizer Backends in bito-lint

## Current State

**Branch:** `feat/pluggable-tokenizers-phase1` in `~/source/claylo/bito-lint`

The pluggable tokenizer implementation (ADR-0007) is **code-complete and tested**. `just check` passes (199/199 tests, clippy clean, cargo deny clean, fmt clean, doc-tests pass). A `commit.txt` is written and ready for Clay's commit.

### What's Done

- Extracted ctoc's 36,495 verified Claude 3+ tokens into `claude_vocab.json` (370KB, embedded at compile time)
- Implemented `Backend` enum (Claude default, OpenAI) mirroring the `Dialect` pattern
- Claude backend: `AhoCorasick` with `LeftmostLongest` behind `LazyLock`, unmatched bytes = 1 token each
- OpenAI backend: `bpe_openai::cl100k_base().count(text)` — exact BPE
- `TokenReport` gains `tokenizer: String` field
- CLI: `--tokenizer claude|openai` flag on `tokens` subcommand
- Config: `tokenizer: Option<Backend>` with `BITO_LINT_TOKENIZER` env var
- MCP: optional `tokenizer` field on `CountTokensParams`
- Doctor command updated (health check label, env var listing)
- Dropped `tiktoken-rs`, added `aho-corasick = "1"` + `bpe-openai = "0.3"`

### What's NOT Done

- Commit not yet created (commit.txt at repo root, Clay commits manually)
- PR not yet created
- Not merged to main
- Not released (will need version bump for breaking `TokenReport` change)

## Next Steps

1. **Clay commits** using `commit.txt` at `~/source/claylo/bito-lint/commit.txt`
2. **Create PR** from `feat/pluggable-tokenizers-phase1` → `main`
3. **Merge and release** — the `TokenReport.tokenizer` field is a breaking change for JSON consumers (new required field). Consider whether this warrants a minor version bump (0.2.0) or if 0.1.6 suffices given pre-1.0 semver
4. **Update `cargo deny`** — there's a stale skip for `base64` (from removed tiktoken-rs) that now warns as unnecessary

## Key Files

| File | Why |
|------|-----|
| `~/source/claylo/bito-lint/crates/bito-lint-core/src/tokens.rs` | Core implementation — Backend enum, count_claude(), count_openai(), tests |
| `~/source/claylo/bito-lint/crates/bito-lint-core/src/claude_vocab.json` | 36,495 verified tokens (370KB, new file) |
| `~/source/claylo/bito-lint/crates/bito-lint-core/Cargo.toml` | Dep changes (tiktoken-rs removed, aho-corasick + bpe-openai added) |
| `~/source/claylo/bito-lint/crates/bito-lint/src/server.rs` | MCP integration — CountTokensParams gains tokenizer field |
| `~/source/claylo/bito-lint/crates/bito-lint/src/commands/tokens.rs` | CLI --tokenizer flag |
| `~/source/claylo/bito-lint/deny.toml` | Has stale `base64` skip that should be cleaned up |

## Gotchas

- **Overcounting varies by content type.** ~4% on English prose, ~20% on technical content with URLs/code. The gap is unmatched bytes (each byte = 1 token). This is the intended conservative behavior for budget enforcement.
- **`bpe-openai` API:** The `count()` method takes `impl Normalizable<'a>` not just `&str`, but `&str` satisfies the trait. Source at `~/source/reference/rust-gems/crates/bpe-openai/`.
- **`schemars::JsonSchema` must be on `Backend`** — the MCP server's `CountTokensParams` derives `rmcp::schemars::JsonSchema`, which requires all fields to implement it. Same underlying schemars v1.2.1 crate, but the derive must be on the enum.
- **`cargo deny` warning:** Removing tiktoken-rs leaves a stale skip for `base64` in `deny.toml:73`. Not a blocker but should be cleaned up.

## What Worked

- **Following the `Dialect` enum pattern exactly** — `as_str()`, `Display`, `serde(rename_all)`, `clap::ValueEnum` behind feature gate. Made integration seamless across config, CLI, and MCP.
- **`include_str!` for vocab embedding** — zero filesystem deps at runtime, one-time parse behind `LazyLock`.
- **`aho-corasick` LeftmostLongest** — O(n) greedy tokenization with no custom algorithm needed.

## What Didn't Work

- **Streaming delta extraction for vocabulary:** Investigated `claude --output-format stream-json --include-partial-messages`. The Anthropic API batches ~3-7 tokens per `content_block_delta` SSE event at the server level. Delta boundaries cut mid-word. Claude Code is a clean passthrough (no rebatching). Streaming is NOT viable for vocabulary extraction. The `count_tokens` API probing approach remains the only path for extending beyond ctoc's 36K tokens.

## Commands

```bash
cd ~/source/claylo/bito-lint
git checkout feat/pluggable-tokenizers-phase1

# Verify everything passes
just check

# Test CLI
cargo run -- tokens --tokenizer claude README.md   # ~2561
cargo run -- tokens --tokenizer openai README.md   # ~2139
cargo run -- tokens README.md                      # default=claude, ~2561
BITO_LINT_TOKENIZER=openai cargo run -- tokens README.md  # env override, ~2139

# JSON output shows tokenizer field
cargo run -- tokens --json --tokenizer claude README.md
```
