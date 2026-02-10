#!/usr/bin/env bash
# run-skill-test.sh — Run a single skill test scenario and produce a scorecard.
#
# Usage: bash test/run-skill-test.sh <scenario.md> [--model haiku] [--editorial]
#
# Parses the scenario's front matter, invokes the skill via Claude Code,
# runs bito-lint quality checks on the output, and writes a JSON scorecard.
#
# Environment:
#   ANTHROPIC_API_KEY  — required
#   BITO_LINT          — path to bito-lint binary (default: bito-lint)
#   PLUGIN_DIR         — path to the plugin (default: repo root)

set -euo pipefail

# --- Configuration -----------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PLUGIN_DIR="${PLUGIN_DIR:-$REPO_ROOT}"
BITO_LINT="${BITO_LINT:-bito-lint}"
MODEL="haiku"
EDITORIAL=false
SCENARIO_FILE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --model) MODEL="$2"; shift 2 ;;
    --editorial) EDITORIAL=true; shift ;;
    -*) echo "Unknown flag: $1" >&2; exit 1 ;;
    *) SCENARIO_FILE="$1"; shift ;;
  esac
done

if [[ -z "$SCENARIO_FILE" ]]; then
  echo "Usage: $0 <scenario.md> [--model haiku] [--editorial]" >&2
  exit 1
fi

if [[ ! -f "$SCENARIO_FILE" ]]; then
  echo "Error: Scenario file not found: $SCENARIO_FILE" >&2
  exit 1
fi

if ! command -v "$BITO_LINT" &>/dev/null; then
  echo "Error: bito-lint not found. Install with: cargo install bito-lint" >&2
  exit 1
fi

if ! command -v claude &>/dev/null; then
  echo "Error: claude CLI not found." >&2
  exit 1
fi

# --- Parse scenario front matter ---------------------------------------------

# Extract YAML front matter between --- delimiters
frontmatter=$(sed -n '/^---$/,/^---$/p' "$SCENARIO_FILE" | sed '1d;$d')

get_field() {
  echo "$frontmatter" | grep "^$1:" | sed "s/^$1: *//" | tr -d '"'
}

SKILL=$(get_field "skill")
PERSONA=$(get_field "persona")
EXPECTED_TYPE=$(get_field "expected_type")
EXPECTED_PATH_PATTERN=$(get_field "expected_path_pattern")
SCENARIO_DESC=$(get_field "description")

# Derive scenario ID from file path: "adr/01-simple-decision"
SCENARIO_ID=$(echo "$SCENARIO_FILE" | sed 's|.*/scenarios/||; s|\.md$||')
RUN_ID=$(date +%Y%m%d-%H%M%S)-$$

echo "=== Skill Test: $SCENARIO_ID ==="
echo "  Skill: $SKILL"
echo "  Persona: $PERSONA"
echo "  Model: $MODEL"
echo "  Run ID: $RUN_ID"
echo ""

# --- Load thresholds ---------------------------------------------------------

THRESHOLDS_FILE="$SCRIPT_DIR/thresholds.toml"

get_threshold() {
  local section="$1" key="$2"
  # Simple TOML parser — works for flat key = value within [section]
  sed -n "/^\[$section\]/,/^\[/p" "$THRESHOLDS_FILE" | grep "^$key " | sed 's/.*= *//' | tr -d '"'
}

COMPLETENESS_TEMPLATE=$(get_threshold "$EXPECTED_TYPE" "completeness_template")
TOKEN_BUDGET=$(get_threshold "$EXPECTED_TYPE" "token_budget")
READABILITY_MAX=$(get_threshold "$EXPECTED_TYPE" "readability_max_grade")

# --- Set up temp workspace ---------------------------------------------------

WORKDIR=$(mktemp -d -t "skill-test-XXXXXX")
trap 'rm -rf "$WORKDIR"' EXIT

# Create minimal project structure in temp dir
mkdir -p "$WORKDIR"/{.handoffs,docs/decisions,docs/designs,docs}

# Symlink plugin components so the skill can find templates/personas
ln -s "$PLUGIN_DIR/personas" "$WORKDIR/personas"
ln -s "$PLUGIN_DIR/templates" "$WORKDIR/templates"
ln -s "$PLUGIN_DIR/agents" "$WORKDIR/agents"
ln -s "$PLUGIN_DIR/skills" "$WORKDIR/skills"

# Initialize git repo (some skills check for git context)
git -C "$WORKDIR" init -q
git -C "$WORKDIR" add -A
git -C "$WORKDIR" commit -q -m "init" --allow-empty

# Telemetry file
TELEMETRY_FILE="$WORKDIR/telemetry.jsonl"
export BITO_TELEMETRY_FILE="$TELEMETRY_FILE"

# --- Extract scenario body (everything after front matter) -------------------

SCENARIO_BODY=$(sed '1{/^---$/!q;};1,/^---$/d' "$SCENARIO_FILE")

# --- Build the prompt --------------------------------------------------------

PROMPT="You are running in a test environment. Use the $SKILL skill with the $PERSONA persona.

Here is the scenario context:

$SCENARIO_BODY

Important instructions:
- Write the artifact to the appropriate location in this project
- Follow the skill's workflow exactly as documented in skills/$SKILL/SKILL.md
- Use the persona voice from personas/$PERSONA.md
- Run bito-lint quality checks as the skill requires
- Do NOT ask for confirmation — complete the full workflow autonomously"

# --- Invoke Claude -----------------------------------------------------------

echo "Invoking Claude ($MODEL)..."
START_TIME=$(date +%s)

# Run Claude in non-interactive mode
CLAUDE_OUTPUT=$(cd "$WORKDIR" && claude \
  --model "$MODEL" \
  --print \
  --dangerously-skip-permissions \
  -p "$PROMPT" 2>&1) || true

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "Claude finished in ${DURATION}s"
echo ""

# --- Find the generated artifact ---------------------------------------------

ARTIFACT_FOUND=false
ARTIFACT_PATH=""

# Search for files matching the expected path pattern
for f in "$WORKDIR"/$EXPECTED_PATH_PATTERN; do
  if [[ -f "$f" && "$f" != *"init"* ]]; then
    ARTIFACT_FOUND=true
    ARTIFACT_PATH="$f"
    break
  fi
done

if [[ "$ARTIFACT_FOUND" == "false" ]]; then
  echo "WARNING: No artifact found matching pattern: $EXPECTED_PATH_PATTERN"
  # Check common alternate locations
  for f in "$WORKDIR"/*.md "$WORKDIR"/docs/**/*.md "$WORKDIR"/.handoffs/*.md; do
    if [[ -f "$f" && "$(basename "$f")" != "README.md" ]]; then
      echo "  Found alternate: $f"
      ARTIFACT_PATH="$f"
      ARTIFACT_FOUND=true
      break
    fi
  done
fi

echo "Artifact found: $ARTIFACT_FOUND"
[[ -n "$ARTIFACT_PATH" ]] && echo "  Path: $ARTIFACT_PATH"
echo ""

# --- Run quality checks ------------------------------------------------------

CHECKS='{}'

if [[ "$ARTIFACT_FOUND" == "true" && -n "$ARTIFACT_PATH" ]]; then

  # Completeness check
  if [[ -n "$COMPLETENESS_TEMPLATE" ]]; then
    echo "Checking completeness (template: $COMPLETENESS_TEMPLATE)..."
    if COMP_OUTPUT=$("$BITO_LINT" completeness "$ARTIFACT_PATH" --template "$COMPLETENESS_TEMPLATE" --json 2>&1); then
      COMP_PASS=true
    else
      COMP_PASS=false
    fi
    CHECKS=$(echo "$CHECKS" | jq --arg pass "$COMP_PASS" \
      '. + {completeness: {pass: ($pass == "true")}}')
  fi

  # Readability check
  if [[ -n "$READABILITY_MAX" ]]; then
    echo "Checking readability (max grade: $READABILITY_MAX)..."
    if READ_OUTPUT=$("$BITO_LINT" readability "$ARTIFACT_PATH" --max-grade "$READABILITY_MAX" --json 2>&1); then
      READ_PASS=true
      READ_GRADE=$(echo "$READ_OUTPUT" | jq -r '.grade // 0' 2>/dev/null || echo "0")
    else
      READ_PASS=false
      READ_GRADE=$(echo "$READ_OUTPUT" | jq -r '.grade // 0' 2>/dev/null || echo "0")
    fi
    CHECKS=$(echo "$CHECKS" | jq --arg pass "$READ_PASS" --arg grade "$READ_GRADE" --arg max "$READABILITY_MAX" \
      '. + {readability: {pass: ($pass == "true"), grade: ($grade | tonumber), max: ($max | tonumber)}}')
  fi

  # Token budget check
  if [[ -n "$TOKEN_BUDGET" ]]; then
    echo "Checking token budget ($TOKEN_BUDGET)..."
    if TOK_OUTPUT=$("$BITO_LINT" tokens "$ARTIFACT_PATH" --budget "$TOKEN_BUDGET" --json 2>&1); then
      TOK_PASS=true
      TOK_COUNT=$(echo "$TOK_OUTPUT" | jq -r '.count // .tokens // 0' 2>/dev/null || echo "0")
    else
      TOK_PASS=false
      TOK_COUNT=$(echo "$TOK_OUTPUT" | jq -r '.count // .tokens // 0' 2>/dev/null || echo "0")
    fi
    CHECKS=$(echo "$CHECKS" | jq --arg pass "$TOK_PASS" --arg count "$TOK_COUNT" --arg budget "$TOKEN_BUDGET" \
      '. + {tokens: {pass: ($pass == "true"), count: ($count | tonumber), budget: ($budget | tonumber)}}')
  fi

  # Consistency check (dialect)
  echo "Checking consistency..."
  if CONS_OUTPUT=$("$BITO_LINT" analyze "$ARTIFACT_PATH" --checks consistency --json 2>&1); then
    CONS_ISSUES=$(echo "$CONS_OUTPUT" | jq -r '.consistency.total_issues // 0' 2>/dev/null || echo "0")
  else
    CONS_ISSUES=0
  fi
  DIALECT="${BITO_LINT_DIALECT:-en-us}"
  CHECKS=$(echo "$CHECKS" | jq --arg issues "$CONS_ISSUES" --arg dialect "$DIALECT" \
    '. + {consistency: {issues: ($issues | tonumber), dialect: $dialect}}')

fi

echo ""

# --- Parse telemetry ---------------------------------------------------------

TOKEN_USAGE='{}'
if [[ -f "$TELEMETRY_FILE" ]]; then
  echo "Parsing telemetry..."

  # Count tool uses per type
  TOOL_SUMMARY=$(jq -rs '[.[] | select(.event == "tool_use")] | group_by(.tool) | map({tool: .[0].tool, count: length})' "$TELEMETRY_FILE" 2>/dev/null || echo "[]")

  # Get session summary if available
  SESSION_END=$(jq -rs '[.[] | select(.event == "session_end")] | last // {}' "$TELEMETRY_FILE" 2>/dev/null || echo "{}")

  TOTAL_INPUT=$(echo "$SESSION_END" | jq -r '.input_tokens // 0')
  TOTAL_OUTPUT=$(echo "$SESSION_END" | jq -r '.output_tokens // 0')
  TOTAL_CACHE=$(echo "$SESSION_END" | jq -r '.cache_read_tokens // 0')
  NUM_TURNS=$(echo "$SESSION_END" | jq -r '.turns // 0')

  TOKEN_USAGE=$(jq -n \
    --argjson input "$TOTAL_INPUT" \
    --argjson output "$TOTAL_OUTPUT" \
    --argjson cache "$TOTAL_CACHE" \
    --argjson turns "$NUM_TURNS" \
    --argjson tools "$TOOL_SUMMARY" \
    '{total_input: $input, total_output: $output, total_cache_read: $cache, turns: $turns, tool_summary: $tools}')
fi

# --- Build scorecard ---------------------------------------------------------

SCORECARDS_DIR="$SCRIPT_DIR/scorecards"
mkdir -p "$SCORECARDS_DIR"
SCORECARD_FILE="$SCORECARDS_DIR/$(echo "$SCENARIO_ID" | tr '/' '-')-${RUN_ID}.json"

jq -n \
  --arg scenario "$SCENARIO_ID" \
  --arg skill "$SKILL" \
  --arg model "$MODEL" \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --argjson artifact_created "$ARTIFACT_FOUND" \
  --argjson checks "$CHECKS" \
  --argjson token_usage "$TOKEN_USAGE" \
  --argjson duration "$DURATION" \
  '{
    scenario: $scenario,
    skill: $skill,
    model: $model,
    timestamp: $ts,
    artifact_created: $artifact_created,
    checks: $checks,
    token_usage: $token_usage,
    duration_seconds: $duration
  }' > "$SCORECARD_FILE"

echo "=== Scorecard ==="
jq '.' "$SCORECARD_FILE"
echo ""
echo "Scorecard written to: $SCORECARD_FILE"

# --- Editorial review (optional) --------------------------------------------

if [[ "$EDITORIAL" == "true" && "$ARTIFACT_FOUND" == "true" ]]; then
  echo ""
  echo "=== Editorial Review ==="
  echo "Running editorial review on generated artifact..."

  EDITORIAL_PROMPT="Run the editorial-review skill on this artifact:
File: $ARTIFACT_PATH
Artifact type: $EXPECTED_TYPE
Persona: $PERSONA

Complete the full editorial review workflow. Report PASS or FAIL with issue count."

  EDITORIAL_OUTPUT=$(cd "$WORKDIR" && claude \
    --model "$MODEL" \
    --print \
    --dangerously-skip-permissions \
    -p "$EDITORIAL_PROMPT" 2>&1) || true

  # Append editorial result to scorecard
  if echo "$EDITORIAL_OUTPUT" | grep -qi "pass"; then
    EDITORIAL_RESULT="pass"
  else
    EDITORIAL_RESULT="fail"
  fi

  # Update scorecard with editorial result
  jq --arg result "$EDITORIAL_RESULT" \
    '. + {editorial_review: $result}' \
    "$SCORECARD_FILE" > "${SCORECARD_FILE}.tmp" && mv "${SCORECARD_FILE}.tmp" "$SCORECARD_FILE"

  echo "Editorial review: $EDITORIAL_RESULT"
fi
