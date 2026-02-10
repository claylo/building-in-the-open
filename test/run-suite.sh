#!/usr/bin/env bash
# run-suite.sh — Run all skill test scenarios and produce a summary report.
#
# Usage:
#   bash test/run-suite.sh                    # Smoke: 1 run per scenario
#   bash test/run-suite.sh --runs=5           # Calibration: 5 runs per scenario
#   bash test/run-suite.sh --editorial        # Include editorial review
#   bash test/run-suite.sh --scenario=adr     # Run only ADR scenarios
#
# Modes:
#   Smoke (N=1):       Single run per scenario. Binary pass/fail. Pre-release validation.
#   Calibration (N>1): Multiple runs per scenario. Reports variation statistics.
#
# Output:
#   test/scorecards/suite-<timestamp>.json    Machine-readable results
#   test/scorecards/suite-<timestamp>.md      Human-readable summary
#
# Environment:
#   ANTHROPIC_API_KEY  — required
#   BITO_LINT          — path to bito-lint binary (default: bito-lint)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNS=1
MODEL="haiku"
EDITORIAL=""
SCENARIO_FILTER=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --runs=*) RUNS="${1#*=}"; shift ;;
    --model=*) MODEL="${1#*=}"; shift ;;
    --editorial) EDITORIAL="--editorial"; shift ;;
    --scenario=*) SCENARIO_FILTER="${1#*=}"; shift ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

# Collect scenarios
SCENARIOS=()
for scenario in "$SCRIPT_DIR"/scenarios/**/*.md; do
  [[ -f "$scenario" ]] || continue
  if [[ -n "$SCENARIO_FILTER" ]]; then
    echo "$scenario" | grep -q "$SCENARIO_FILTER" || continue
  fi
  SCENARIOS+=("$scenario")
done

if [[ ${#SCENARIOS[@]} -eq 0 ]]; then
  echo "No scenarios found." >&2
  exit 1
fi

SUITE_TS=$(date +%Y%m%d-%H%M%S)
SUITE_SCORECARDS=()

echo "====================================="
echo "  Skill Test Suite"
echo "====================================="
echo "  Scenarios: ${#SCENARIOS[@]}"
echo "  Runs per scenario: $RUNS"
echo "  Model: $MODEL"
echo "  Mode: $([ "$RUNS" -gt 1 ] && echo "Calibration" || echo "Smoke")"
echo "====================================="
echo ""

TOTAL_PASS=0
TOTAL_FAIL=0
TOTAL_RUNS=0

for scenario in "${SCENARIOS[@]}"; do
  SCENARIO_ID=$(echo "$scenario" | sed 's|.*/scenarios/||; s|\.md$||')
  echo "--- $SCENARIO_ID ---"

  for ((run=1; run<=RUNS; run++)); do
    if [[ $RUNS -gt 1 ]]; then
      echo "  Run $run/$RUNS..."
    fi

    # Run the scenario
    if bash "$SCRIPT_DIR/run-skill-test.sh" "$scenario" --model "$MODEL" $EDITORIAL 2>&1; then
      TOTAL_PASS=$((TOTAL_PASS + 1))
    else
      TOTAL_FAIL=$((TOTAL_FAIL + 1))
    fi
    TOTAL_RUNS=$((TOTAL_RUNS + 1))
  done
  echo ""
done

# --- Collect all scorecards from this suite run ------------------------------

SCORECARDS_DIR="$SCRIPT_DIR/scorecards"
ALL_SCORECARDS=$(find "$SCORECARDS_DIR" -name "*.json" -newer "$0" -not -name "suite-*" 2>/dev/null | sort)

# --- Generate machine-readable suite report ----------------------------------

SUITE_JSON="$SCORECARDS_DIR/suite-${SUITE_TS}.json"

jq -n \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg model "$MODEL" \
  --argjson runs "$RUNS" \
  --argjson total_scenarios "${#SCENARIOS[@]}" \
  --argjson total_runs "$TOTAL_RUNS" \
  --argjson total_pass "$TOTAL_PASS" \
  --argjson total_fail "$TOTAL_FAIL" \
  '{
    timestamp: $ts,
    model: $model,
    runs_per_scenario: $runs,
    total_scenarios: $total_scenarios,
    total_runs: $total_runs,
    passed: $total_pass,
    failed: $total_fail,
    pass_rate: (if $total_runs > 0 then ($total_pass / $total_runs * 100) else 0 end)
  }' > "$SUITE_JSON"

# If we have individual scorecards, compute per-scenario statistics
if [[ -n "$ALL_SCORECARDS" ]]; then
  # Add individual scorecards to the suite report
  CARDS_JSON=$(echo "$ALL_SCORECARDS" | while read -r f; do cat "$f"; done | jq -s '.')
  jq --argjson cards "$CARDS_JSON" '. + {scorecards: $cards}' "$SUITE_JSON" > "${SUITE_JSON}.tmp"
  mv "${SUITE_JSON}.tmp" "$SUITE_JSON"
fi

# --- Generate human-readable summary ----------------------------------------

SUITE_MD="$SCORECARDS_DIR/suite-${SUITE_TS}.md"

cat > "$SUITE_MD" << EOF
# Skill Test Suite Report

**Date:** $(date -u +%Y-%m-%dT%H:%M:%SZ)
**Model:** $MODEL
**Mode:** $([ "$RUNS" -gt 1 ] && echo "Calibration (N=$RUNS)" || echo "Smoke (N=1)")

## Summary

| Metric | Value |
|--------|-------|
| Scenarios | ${#SCENARIOS[@]} |
| Total runs | $TOTAL_RUNS |
| Passed | $TOTAL_PASS |
| Failed | $TOTAL_FAIL |
| Pass rate | $(( TOTAL_RUNS > 0 ? TOTAL_PASS * 100 / TOTAL_RUNS : 0 ))% |

EOF

# Add per-scenario details if we have scorecards
if [[ -n "$ALL_SCORECARDS" ]]; then
  echo "## Per-Scenario Results" >> "$SUITE_MD"
  echo "" >> "$SUITE_MD"
  echo "| Scenario | Artifact | Completeness | Readability | Tokens | Duration |" >> "$SUITE_MD"
  echo "|----------|----------|-------------|-------------|--------|----------|" >> "$SUITE_MD"

  echo "$ALL_SCORECARDS" | while read -r f; do
    SCENARIO=$(jq -r '.scenario' "$f")
    CREATED=$(jq -r '.artifact_created' "$f")
    COMP=$(jq -r '.checks.completeness.pass // "n/a"' "$f")
    READ_GRADE=$(jq -r 'if .checks.readability then "\(.checks.readability.grade)/\(.checks.readability.max)" else "n/a" end' "$f")
    READ_PASS=$(jq -r '.checks.readability.pass // "n/a"' "$f")
    TOKS=$(jq -r 'if .checks.tokens then "\(.checks.tokens.count)/\(.checks.tokens.budget)" else "n/a" end' "$f")
    DUR=$(jq -r '.duration_seconds' "$f")

    echo "| $SCENARIO | $CREATED | $COMP | $READ_GRADE | $TOKS | ${DUR}s |" >> "$SUITE_MD"
  done

  # Calibration mode: compute variation statistics
  if [[ $RUNS -gt 1 ]]; then
    echo "" >> "$SUITE_MD"
    echo "## Variation Analysis (N=$RUNS)" >> "$SUITE_MD"
    echo "" >> "$SUITE_MD"
    echo "Per-scenario statistics across $RUNS runs:" >> "$SUITE_MD"
    echo "" >> "$SUITE_MD"

    # Group scorecards by scenario and compute stats
    for scenario in "${SCENARIOS[@]}"; do
      SID=$(echo "$scenario" | sed 's|.*/scenarios/||; s|\.md$||')
      SID_PATTERN=$(echo "$SID" | tr '/' '-')

      # Find scorecards for this scenario
      SCENARIO_CARDS=$(find "$SCORECARDS_DIR" -name "${SID_PATTERN}-*.json" -newer "$0" -not -name "suite-*" 2>/dev/null | sort)
      [[ -z "$SCENARIO_CARDS" ]] && continue

      echo "### $SID" >> "$SUITE_MD"
      echo "" >> "$SUITE_MD"

      # Pass rate
      PASS_COUNT=$(echo "$SCENARIO_CARDS" | while read -r f; do
        jq -r '[.checks[].pass // true] | all | if . then "1" else "0" end' "$f"
      done | awk '{s+=$1} END {print s}')
      echo "- **Pass rate:** ${PASS_COUNT}/${RUNS}" >> "$SUITE_MD"

      # Duration stats
      DURATIONS=$(echo "$SCENARIO_CARDS" | while read -r f; do jq -r '.duration_seconds' "$f"; done)
      if [[ -n "$DURATIONS" ]]; then
        MEAN_DUR=$(echo "$DURATIONS" | awk '{s+=$1; n++} END {printf "%.1f", s/n}')
        echo "- **Duration:** mean ${MEAN_DUR}s" >> "$SUITE_MD"
      fi

      echo "" >> "$SUITE_MD"
    done
  fi
fi

echo ""
echo "====================================="
echo "  Suite Complete"
echo "====================================="
echo "  Pass: $TOTAL_PASS / $TOTAL_RUNS"
echo "  Reports:"
echo "    $SUITE_JSON"
echo "    $SUITE_MD"
echo "====================================="
