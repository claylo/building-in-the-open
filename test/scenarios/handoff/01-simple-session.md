---
skill: curating-context
persona: context-curator
expected_type: handoff
expected_path_pattern: ".handoffs/*.md"
description: Simple coding session with one key decision and one dead end.
---

# Scenario: Simple coding session

## Session context

You are working on a Rust CLI tool called `tidy-conf` that normalizes configuration files. During this session you:

1. **Decided** to use `figment` for configuration loading instead of `config-rs`, because figment supports layered configuration with clear merge semantics and the provider pattern maps well to your sources (file, env, CLI args).

2. **Implemented** the `ConfigLoader` struct with three providers: `Toml` for file-based config, `Env` with a `TIDY_` prefix for environment variables, and `Serialized` for CLI argument overrides. The merge order is file < env < cli.

3. **Hit a dead end** trying to use figment's `Profile` feature for environment-specific configs (dev/staging/prod). The profile switching worked but figment's profile merging is additive, not replacing — a prod profile with `log_level = "error"` still inherits dev's `debug_endpoints = true`. Decided to handle environments at the file level instead (separate `config.prod.toml`).

4. **Left open**: whether to support YAML configs alongside TOML. The figment `Yaml` provider exists but adds a `serde_yaml` dependency. Deferring until there's a user request.

## Expected behavior

The curating-context skill should produce a handoff document that:
- Is under 2,000 tokens
- Has all required handoff template sections
- Captures the figment decision, the dead end, and the open question
- Uses Context Curator voice (dense, scannable, no narrative flair)
