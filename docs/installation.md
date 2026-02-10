# Installation

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed and configured
- [bito-lint](https://github.com/claylo/bito-lint) for quality gate checks:
  ```sh
  # with cargo-binstall (fast downloads, pre-built binary)
  cargo binstall bito-lint
  
  # Or build from source
  cargo install bito-lint
  ```
  Or via Homebrew: `brew install claylo/brew/bito-lint`

## Install the plugin

Clone into your Claude Code plugins directory:

```sh
git clone https://github.com/claylo/building-in-the-open ~/.claude/plugins/building-in-the-open
```

Claude Code discovers plugins automatically from `~/.claude/plugins/`. No additional configuration needed.

## Verify

Start a new Claude Code session and confirm the plugin loaded by checking that the skills are available. The plugin provides six skills: `curating-context`, `writing-adrs`, `writing-design-docs`, `writing-end-user-docs`, `writing-changelogs`, and `editorial-review`.

## Pre-commit hook

Copy the quality gate hook into your project:

```sh
cp ~/.claude/plugins/building-in-the-open/hooks/pre-commit-docs .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

This runs token budget checks on handoffs, completeness checks on ADRs and design docs, and readability scoring on design docs — automatically before every commit.

If you already have a pre-commit hook, source the quality checks from your existing hook:

```sh
# In your existing .git/hooks/pre-commit
source ~/.claude/plugins/building-in-the-open/hooks/pre-commit-docs
```

## MCP server (optional)

For AI-driven quality checks during writing sessions, configure bito-lint's MCP server in your project's `.mcp.json`:

```json
{
  "mcpServers": {
    "bito-lint": {
      "command": "bito-lint",
      "args": ["serve"]
    }
  }
}
```

This lets the editorial-review skill call quality gate tools directly during agent-based reviews. Claude Code's MCP Tool Search handles context management automatically — tool schemas are loaded on demand when total MCP context exceeds 10% of the window.

## Configuration

### Dialect

Set your preferred English dialect for spelling enforcement:

```sh
# Environment variable (per-session)
export BITO_LINT_DIALECT=en-us

# Or in your project's bito-lint config (.bito-lint.toml)
dialect = "en-us"
```

Supported dialects: `en-us`, `en-gb`, `en-ca`, `en-au`. When set, all skills check for dialect-consistent spelling in generated artifacts.

### Quality thresholds

Override default quality thresholds in your project's bito-lint config:

```toml
# .bito-lint.toml
token_budget = 2000
max_grade = 12.0
```

See the [bito-lint documentation](https://github.com/claylo/bito-lint) for all configuration options.
