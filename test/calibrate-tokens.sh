#!/usr/bin/env bash
set -euo pipefail

# Token Calibration Study
# Compares tiktoken (cl100k_base) vs claude-tokenizer (local) vs Anthropic API (ground truth)
# across the full building-in-the-open plugin corpus.

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
COMPARE_BIN="$REPO_ROOT/tools/token-compare/target/release/token-compare"
API_URL="https://api.anthropic.com/v1/messages/count_tokens"
API_MODEL="claude-sonnet-4-5-20250929"

# Corpus: all plugin content files
CORPUS=(
    personas/technical-writer.md
    personas/context-curator.md
    personas/doc-writer.md
    personas/marketing-copywriter.md
    skills/curating-context/SKILL.md
    skills/writing-adrs/SKILL.md
    skills/writing-design-docs/SKILL.md
    skills/writing-end-user-docs/SKILL.md
    skills/writing-changelogs/SKILL.md
    skills/editorial-review/SKILL.md
    templates/adr.md
    templates/handoff.md
    templates/design-doc.md
    agents/editorial-reviewer.md
)

# ── Build token-compare if needed ──────────────────────────────────────
if [[ ! -x "$COMPARE_BIN" ]]; then
    echo "Building token-compare..." >&2
    (cd "$REPO_ROOT/tools/token-compare" && cargo build --release --quiet)
fi

# ── Check for API key ──────────────────────────────────────────────────
HAS_API=false
if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
    HAS_API=true
else
    echo "⚠  ANTHROPIC_API_KEY not set — skipping API ground truth" >&2
    echo "   Set it to get three-way comparison" >&2
    echo "" >&2
fi

# ── Collect data ───────────────────────────────────────────────────────
# Arrays for summary stats
declare -a FILES TIKTOKEN CLAUDE_LOCAL API_COUNTS

for relpath in "${CORPUS[@]}"; do
    filepath="$REPO_ROOT/$relpath"
    if [[ ! -f "$filepath" ]]; then
        echo "SKIP: $relpath (not found)" >&2
        continue
    fi

    # Local tokenizers
    json=$("$COMPARE_BIN" "$filepath")
    tk=$(echo "$json" | jq -r '.tiktoken')
    cl=$(echo "$json" | jq -r '.claude_local')

    # API ground truth
    api_count="-"
    if $HAS_API; then
        text=$(jq -Rs '.' < "$filepath")
        body=$(cat <<APIJSON
{
  "model": "$API_MODEL",
  "messages": [{"role": "user", "content": $text}]
}
APIJSON
        )
        resp=$(curl -s -w "\n%{http_code}" "$API_URL" \
            -H "Content-Type: application/json" \
            -H "anthropic-version: 2023-06-01" \
            -H "X-Api-Key: $ANTHROPIC_API_KEY" \
            -d "$body")
        http_code=$(echo "$resp" | tail -1)
        resp_body=$(echo "$resp" | sed '$d')

        if [[ "$http_code" == "200" ]]; then
            api_count=$(echo "$resp_body" | jq -r '.input_tokens')
        else
            echo "API error for $relpath (HTTP $http_code): $resp_body" >&2
            api_count="ERR"
        fi
        # Rate limit: be polite
        sleep 0.5
    fi

    FILES+=("$relpath")
    TIKTOKEN+=("$tk")
    CLAUDE_LOCAL+=("$cl")
    API_COUNTS+=("$api_count")
done

# ── Output report ──────────────────────────────────────────────────────
echo ""
echo "# Token Calibration Report"
echo ""
echo "Date: $(date -u +%Y-%m-%d)"
echo "Corpus: ${#FILES[@]} files from building-in-the-open plugin"
echo "API model: $API_MODEL"
echo ""

# Table header
if $HAS_API; then
    printf "| %-38s | %8s | %8s | %8s | %8s | %8s |\n" \
        "File" "tiktoken" "claude" "API" "tk→API%" "cl→API%"
    printf "| %-38s | %8s | %8s | %8s | %8s | %8s |\n" \
        "--------------------------------------" "--------" "--------" "--------" "--------" "--------"
else
    printf "| %-38s | %8s | %8s | %8s |\n" \
        "File" "tiktoken" "claude" "cl-tk%"
    printf "| %-38s | %8s | %8s | %8s |\n" \
        "--------------------------------------" "--------" "--------" "--------"
fi

# Accumulators for summary
sum_tk=0; sum_cl=0; sum_api=0
count_api=0
sum_tk_api_pct=0; sum_cl_api_pct=0
max_tk_api_pct=0; max_cl_api_pct=0

for i in "${!FILES[@]}"; do
    tk="${TIKTOKEN[$i]}"
    cl="${CLAUDE_LOCAL[$i]}"
    api="${API_COUNTS[$i]}"

    sum_tk=$((sum_tk + tk))
    sum_cl=$((sum_cl + cl))

    if $HAS_API && [[ "$api" != "-" && "$api" != "ERR" ]]; then
        sum_api=$((sum_api + api))
        count_api=$((count_api + 1))

        # Percentage difference: (local - api) / api * 100
        tk_api_pct=$(awk "BEGIN { printf \"%.1f\", ($tk - $api) / $api * 100 }")
        cl_api_pct=$(awk "BEGIN { printf \"%.1f\", ($cl - $api) / $api * 100 }")

        # Track max absolute deltas
        tk_api_abs=$(awk "BEGIN { v = ($tk - $api) / $api * 100; printf \"%.1f\", (v < 0 ? -v : v) }")
        cl_api_abs=$(awk "BEGIN { v = ($cl - $api) / $api * 100; printf \"%.1f\", (v < 0 ? -v : v) }")
        max_tk_api_pct=$(awk "BEGIN { printf \"%.1f\", ($tk_api_abs > $max_tk_api_pct ? $tk_api_abs : $max_tk_api_pct) }")
        max_cl_api_pct=$(awk "BEGIN { printf \"%.1f\", ($cl_api_abs > $max_cl_api_pct ? $cl_api_abs : $max_cl_api_pct) }")

        sum_tk_api_pct=$(awk "BEGIN { printf \"%.1f\", $sum_tk_api_pct + $tk_api_pct }")
        sum_cl_api_pct=$(awk "BEGIN { printf \"%.1f\", $sum_cl_api_pct + $cl_api_pct }")

        printf "| %-38s | %8d | %8d | %8d | %7s%% | %7s%% |\n" \
            "${FILES[$i]}" "$tk" "$cl" "$api" "$tk_api_pct" "$cl_api_pct"
    else
        cl_tk_pct=$(awk "BEGIN { printf \"%.1f\", ($cl - $tk) / $tk * 100 }")
        printf "| %-38s | %8d | %8d | %7s%% |\n" \
            "${FILES[$i]}" "$tk" "$cl" "$cl_tk_pct"
    fi
done

echo ""
echo "## Summary"
echo ""
echo "| Metric | tiktoken | claude-local |"
echo "| ------ | -------- | ------------ |"
echo "| Total tokens | $sum_tk | $sum_cl |"

cl_over_tk=$(awk "BEGIN { printf \"%.1f\", ($sum_cl - $sum_tk) / $sum_tk * 100 }")
echo "| claude-local vs tiktoken | — | +${cl_over_tk}% |"

if $HAS_API && [[ $count_api -gt 0 ]]; then
    echo "| Total API tokens | — | $sum_api |"

    mean_tk_api=$(awk "BEGIN { printf \"%.1f\", $sum_tk_api_pct / $count_api }")
    mean_cl_api=$(awk "BEGIN { printf \"%.1f\", $sum_cl_api_pct / $count_api }")

    echo ""
    echo "### vs API Ground Truth ($count_api files)"
    echo ""
    echo "| Metric | tiktoken→API | claude-local→API |"
    echo "| ------ | ------------ | ---------------- |"
    echo "| Mean delta | ${mean_tk_api}% | ${mean_cl_api}% |"
    echo "| Max abs delta | ${max_tk_api_pct}% | ${max_cl_api_pct}% |"

    # Overall ratio
    tk_api_overall=$(awk "BEGIN { printf \"%.4f\", $sum_tk / $sum_api }")
    cl_api_overall=$(awk "BEGIN { printf \"%.4f\", $sum_cl / $sum_api }")
    echo "| Overall ratio (local/API) | ${tk_api_overall} | ${cl_api_overall} |"

    echo ""
    echo "### Interpretation"
    echo ""
    if (( $(awk "BEGIN { print ($max_cl_api_pct < 3.0) }") )); then
        echo "**claude-tokenizer is accurate** (max delta < 3%)."
        echo "Recommendation: Switch bito-lint from tiktoken-rs to claude-tokenizer crate."
    elif (( $(awk "BEGIN { print ($max_cl_api_pct < 5.0) }") )); then
        echo "**claude-tokenizer is close** (max delta < 5%)."
        echo "Recommendation: Switch bito-lint to claude-tokenizer with a small safety margin."
    else
        echo "**claude-tokenizer has significant deviation** (max delta ≥ 5%)."
        echo "Recommendation: Consider vendoring the actual tokenizer or applying a calibrated multiplier."
    fi

    echo ""
    echo "Note: API counts include message framing overhead (role tokens, etc.)."
    echo "The raw-text delta will be slightly smaller than shown."
fi

echo ""
echo "## Raw JSON"
echo ""
echo '```json'
echo "["
for i in "${!FILES[@]}"; do
    comma=","
    [[ $i -eq $((${#FILES[@]} - 1)) ]] && comma=""
    if $HAS_API; then
        echo "  {\"file\": \"${FILES[$i]}\", \"tiktoken\": ${TIKTOKEN[$i]}, \"claude_local\": ${CLAUDE_LOCAL[$i]}, \"api\": ${API_COUNTS[$i]}}$comma"
    else
        echo "  {\"file\": \"${FILES[$i]}\", \"tiktoken\": ${TIKTOKEN[$i]}, \"claude_local\": ${CLAUDE_LOCAL[$i]}}$comma"
    fi
done
echo "]"
echo '```'
