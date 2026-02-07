# Handoff: bito-lint Extraction Planning

**Date:** 2026-02-07
**Branch:** main
**State:** Green

> building-in-the-open is complete through Phase 5. All quality gates pass. The focus has shifted to extracting bito-lint into its own repo at `~/source/claylo/bito-lint`, scaffolded from the claylo-rs template.

## Where things stand

A plan exists at `~/.claude/plans/crispy-beaming-toast.md` for extracting bito-lint into a standalone repo and integrating writing analysis features from `~/source/reference/rust_grammar`. The plan was written BEFORE the claylo-rs template was applied and needs updating.

The new repo at `~/source/claylo/bito-lint` is scaffolded from claylo-rs and already has significant infrastructure that the plan doesn't account for:
- **MCP server** (`crates/bito-lint/src/server.rs`) — `rmcp` 0.14 with `#[tool_router]` macros, stub `get_info` tool. bito-lint's analysis functions should be exposed as MCP tools.
- **Config system** (`figment` with TOML/YAML/JSON support, config examples at `config/`)
- **npm distribution** (`npm/` with platform-specific wrappers for cross-platform install)
- **Observability** (`tracing` + `tracing-subscriber` + `tracing-appender`)
- **CLI scaffolding** (`crates/bito-lint/src/commands/`, `lib.rs`, `main.rs`, `observability.rs`)
- **Quality infrastructure** (`deny.toml`, `xtask/`, `cliff.toml`, `dist/` for completions/manpages)
- **Colored output + progress** (`owo-colors`, `indicatif`)
- **Typed paths** (`camino`)

## Decisions made

- bito-lint moves to its own repo (plugins are git checkouts, no cargo build)
- Scope: broad writing analysis (all 19 rust_grammar features), not just editorial quality
- Used for both development artifacts AND end-user documentation websites
- Name stays `bito-lint` (BITO = Building In The Open)
- New repo scaffolded from claylo-rs template (Edition 2024, MSRV 1.88.0, resolver 3)

## What's next

1. **Update the crispy-beaming-toast plan** — factor in the MCP server (expose analysis as tools), config system (figment replaces "no config"), npm distribution, observability, xtask, and the existing crate structure. The plan's dependency list and "no config system" decision need revision.
2. **Execute the updated plan** — port existing bito-lint code, then rust_grammar extraction, then MCP tools
3. **After bito-lint is functional in its own repo** — strip `crates/bito-lint/` from building-in-the-open and update references

## Landmines

- **The plan at `crispy-beaming-toast.md` is STALE.** It was written before the claylo-rs template was applied. It says "no config system" and lists minimal dependencies. The scaffolded repo already has figment, rmcp, tokio, tracing, owo-colors, indicatif, camino, schemars, directories. The plan's dependency and structure sections need rewriting.
- **`~/source/reference/rust_grammar` is Edition 2021.** All `lazy_static!` blocks need conversion to `std::sync::LazyLock`. ~30 blocks across the codebase.
- **rust_grammar has known issues:** commented-out validation, duplicate regex definitions, unused dependencies, unimplemented grammar rule variants. See plan for full list.
- **MCP server pattern from claylo-rs** uses `#[tool_router]` and `#[tool_handler]` macros from `rmcp`. Read `docs/mcp-development.md` in the bito-lint repo for the pattern.
