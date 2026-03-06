# Installation

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed and configured
- [bito-lint](https://github.com/claylo/bito-lint) for quality gate checks (install via any of):
  ```sh
  cargo binstall bito-lint          # pre-built binary, fastest
  brew install claylo/brew/bito-lint # macOS / Linux
  npm install -g @claylo/bito-lint   # wraps the native binary
  ```

## Install the plugin

```sh
claude plugin add claylo-marketplace/building-in-the-open
```

Or install manually by cloning into your Claude Code plugins directory:

```sh
git clone https://github.com/claylo/building-in-the-open ~/.claude/plugins/building-in-the-open
```

Claude Code discovers plugins automatically from `~/.claude/plugins/`. No additional configuration needed.

## Verify

Start a new Claude Code session and confirm the plugin loaded by checking that the skills are available. The plugin provides eight skills: `building-in-the-open` (routing and setup), `onboarding` (guided config interview), `curating-context`, `capturing-decisions`, `writing-design-docs`, `writing-end-user-docs`, `writing-changelogs`, and `editorial-review`.

## Configure quality gates

The fastest way to configure quality gates is to run the `onboarding` skill — it interviews you about your writing standards and generates a `.bito.yaml` config. Alternatively, configure manually as described below.

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

## Manual configuration

### Dialect

Set your preferred English dialect for spelling enforcement:

```yaml
# .bito.yaml
dialect: en-us  # en-us | en-gb | en-ca | en-au
```

Or via environment variable: `export BITO_LINT_DIALECT=en-us`

When set, all skills check for dialect-consistent spelling in generated artifacts.

### Quality thresholds and rules

```yaml
# .bito.yaml
max_grade: 12.0
passive_max_percent: 15.0
tokenizer: claude

rules:
  - paths: [".handoffs/*.md"]
    checks:
      tokens: { budget: 2000 }
      completeness: { template: handoff }

  - paths: ["docs/decisions/*.md"]
    checks:
      completeness: { template: adr }
```

See the [bito-lint documentation](https://github.com/claylo/bito-lint) for all configuration options.
