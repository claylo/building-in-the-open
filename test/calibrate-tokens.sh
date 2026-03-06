#!/usr/bin/env bash
set -euo pipefail

# Token Calibration Study (bito-lint native)
# Compares bito-lint --tokenizer claude (ctoc greedy) vs --tokenizer openai (bpe cl100k_base)
# vs Anthropic count_tokens API (ground truth) across the full plugin corpus.
#
# Requires: bito-lint >= 0.1.7, jq, curl
# Optional: ANTHROPIC_API_KEY for three-way comparison

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
API_URL="https://api.anthropic.com/v1/messages/count_tokens"
API_MODEL="claude-sonnet-4-5-20250929"

# Corpus: all plugin content files
CORPUS=(
    personas/technical-writer.md
    personas/context-curator.md
    personas/doc-writer.md
    personas/marketing-copywriter.md
    skills/curating-context/SKILL.md
    skills/capturing-decisions/SKILL.md
    skills/writing-design-docs/SKILL.md
    skills/writing-end-user-docs/SKILL.md
    skills/writing-changelogs/SKILL.md
    skills/editorial-review/SKILL.md
    templates/adr.md
    templates/handoff.md
    templates/design-doc.md
    agents/editorial-reviewer.md
)

# ── Check dependencies ───────────────────────────────────────────────
if ! command -v bito-lint &>/dev/null; then
    echo "ERROR: bito-lint not found on PATH" >&2
    exit 1
fi

BITO_VERSION=$(bito-lint --version | awk '{print $2}')
echo "bito-lint version: $BITO_VERSION" >&2

if ! command -v jq &>/dev/null; then
    echo "ERROR: jq not found on PATH" >&2
    exit 1
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
declare -a FILES CLAUDE_COUNTS OPENAI_COUNTS API_COUNTS

for relpath in "${CORPUS[@]}"; do
    filepath="$REPO_ROOT/$relpath"
    if [[ ! -f "$filepath" ]]; then
        echo "SKIP: $relpath (not found)" >&2
        continue
    fi

    # bito-lint claude backend (ctoc greedy, 38K verified vocab)
    cl=$(bito-lint tokens --json --tokenizer claude "$filepath" | jq -r '.count')

    # bito-lint openai backend (bpe cl100k_base, exact)
    oai=$(bito-lint tokens --json --tokenizer openai "$filepath" | jq -r '.count')

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
        sleep 0.5
    fi

    FILES+=("$relpath")
    CLAUDE_COUNTS+=("$cl")
    OPENAI_COUNTS+=("$oai")
    API_COUNTS+=("$api_count")
done

# ── Output report ──────────────────────────────────────────────────────
echo ""
echo "# Token Calibration Report"
echo ""
echo "Date: $(date -u +%Y-%m-%d)"
echo "bito-lint: $BITO_VERSION"
echo "Corpus: ${#FILES[@]} files from building-in-the-open plugin"
echo ""
echo "Ground truth: Anthropic \`count_tokens\` API (model: $API_MODEL)"
echo ""
echo "Backends (all local, no external API calls):"
echo "- **claude**: ctoc greedy (38K verified vocab, aho-corasick longest-match, unmatched bytes = 1 token each)"
echo "- **openai**: bpe-openai cl100k_base (exact BPE encoding)"
echo ""

# Table header
if $HAS_API; then
    printf "| %-38s | %8s | %8s | %8s | %8s | %8s |\n" \
        "File" "claude" "openai" "actual" "cl→act%" "oai→act%"
    printf "| %-38s | %8s | %8s | %8s | %8s | %8s |\n" \
        "--------------------------------------" "--------" "--------" "--------" "--------" "--------"
else
    printf "| %-38s | %8s | %8s | %8s |\n" \
        "File" "claude" "openai" "cl/oai%"
    printf "| %-38s | %8s | %8s | %8s |\n" \
        "--------------------------------------" "--------" "--------" "--------"
fi

# Accumulators
sum_cl=0; sum_oai=0; sum_api=0
count_api=0
sum_cl_api_pct=0; sum_oai_api_pct=0
max_cl_api_pct=0; max_oai_api_pct=0

for i in "${!FILES[@]}"; do
    cl="${CLAUDE_COUNTS[$i]}"
    oai="${OPENAI_COUNTS[$i]}"
    api="${API_COUNTS[$i]}"

    sum_cl=$((sum_cl + cl))
    sum_oai=$((sum_oai + oai))

    if $HAS_API && [[ "$api" != "-" && "$api" != "ERR" ]]; then
        sum_api=$((sum_api + api))
        count_api=$((count_api + 1))

        cl_api_pct=$(awk "BEGIN { printf \"%.1f\", ($cl - $api) / $api * 100 }")
        oai_api_pct=$(awk "BEGIN { printf \"%.1f\", ($oai - $api) / $api * 100 }")

        cl_api_abs=$(awk "BEGIN { v = ($cl - $api) / $api * 100; printf \"%.1f\", (v < 0 ? -v : v) }")
        oai_api_abs=$(awk "BEGIN { v = ($oai - $api) / $api * 100; printf \"%.1f\", (v < 0 ? -v : v) }")
        max_cl_api_pct=$(awk "BEGIN { printf \"%.1f\", ($cl_api_abs > $max_cl_api_pct ? $cl_api_abs : $max_cl_api_pct) }")
        max_oai_api_pct=$(awk "BEGIN { printf \"%.1f\", ($oai_api_abs > $max_oai_api_pct ? $oai_api_abs : $max_oai_api_pct) }")

        sum_cl_api_pct=$(awk "BEGIN { printf \"%.1f\", $sum_cl_api_pct + $cl_api_pct }")
        sum_oai_api_pct=$(awk "BEGIN { printf \"%.1f\", $sum_oai_api_pct + $oai_api_pct }")

        printf "| %-38s | %8d | %8d | %8d | %7s%% | %7s%% |\n" \
            "${FILES[$i]}" "$cl" "$oai" "$api" "$cl_api_pct" "$oai_api_pct"
    else
        cl_oai_pct=$(awk "BEGIN { printf \"%.1f\", ($cl - $oai) / $oai * 100 }")
        printf "| %-38s | %8d | %8d | %7s%% |\n" \
            "${FILES[$i]}" "$cl" "$oai" "$cl_oai_pct"
    fi
done

echo ""
echo "## Summary"
echo ""
echo "| Metric | claude | openai |"
echo "| ------ | ------ | ------ |"
echo "| Total tokens | $sum_cl | $sum_oai |"

cl_over_oai=$(awk "BEGIN { printf \"%.1f\", ($sum_cl - $sum_oai) / $sum_oai * 100 }")
echo "| claude vs openai | +${cl_over_oai}% | — |"

if $HAS_API && [[ $count_api -gt 0 ]]; then
    echo "| Total actual (Anthropic API) | — | $sum_api |"

    mean_cl_api=$(awk "BEGIN { printf \"%.1f\", $sum_cl_api_pct / $count_api }")
    mean_oai_api=$(awk "BEGIN { printf \"%.1f\", $sum_oai_api_pct / $count_api }")

    echo ""
    echo "### vs Anthropic API Ground Truth ($count_api files)"
    echo ""
    echo "| Metric | claude→actual | openai→actual |"
    echo "| ------ | ------------- | ------------- |"
    echo "| Mean delta | ${mean_cl_api}% | ${mean_oai_api}% |"
    echo "| Max abs delta | ${max_cl_api_pct}% | ${max_oai_api_pct}% |"

    cl_api_overall=$(awk "BEGIN { printf \"%.4f\", $sum_cl / $sum_api }")
    oai_api_overall=$(awk "BEGIN { printf \"%.4f\", $sum_oai / $sum_api }")
    echo "| Overall ratio (local/actual) | ${cl_api_overall} | ${oai_api_overall} |"

    echo ""
    echo "### Framing-Adjusted (actual - 7 tokens)"
    echo ""
    echo "Anthropic API counts include message framing overhead (~7 tokens per request)."
    echo ""

    adj_sum_cl_pct=0; adj_sum_oai_pct=0
    adj_max_cl=0; adj_max_oai=0
    printf "| %-38s | %8s | %8s | %8s | %8s |\n" \
        "File" "claude" "adj_act" "cl_delta" "cl_pct"
    printf "| %-38s | %8s | %8s | %8s | %8s |\n" \
        "--------------------------------------" "--------" "--------" "--------" "--------"
    for i in "${!FILES[@]}"; do
        cl="${CLAUDE_COUNTS[$i]}"
        api="${API_COUNTS[$i]}"
        if [[ "$api" != "-" && "$api" != "ERR" ]]; then
            api_adj=$((api - 7))
            delta=$((cl - api_adj))
            pct=$(awk "BEGIN { printf \"%.1f\", $delta / $api_adj * 100 }")
            pct_abs=$(awk "BEGIN { v = $delta / $api_adj * 100; printf \"%.1f\", (v < 0 ? -v : v) }")
            adj_max_cl=$(awk "BEGIN { printf \"%.1f\", ($pct_abs > $adj_max_cl ? $pct_abs : $adj_max_cl) }")
            adj_sum_cl_pct=$(awk "BEGIN { printf \"%.1f\", $adj_sum_cl_pct + $pct }")
            sign=""; [[ $delta -gt 0 ]] && sign="+"
            printf "| %-38s | %8d | %8d | %7s%d | %7s%% |\n" \
                "${FILES[$i]}" "$cl" "$api_adj" "$sign" "$delta" "$pct"
        fi
    done
    adj_mean_cl=$(awk "BEGIN { printf \"%.1f\", $adj_sum_cl_pct / $count_api }")
    echo ""
    echo "Framing-adjusted claude backend: mean ${adj_mean_cl}%, max ${adj_max_cl}%"

    echo ""
    echo "### Interpretation"
    echo ""
    echo "The **claude** backend (ctoc greedy) intentionally overcounts — unmatched bytes"
    echo "each cost 1 token. This is the safe direction for budget enforcement: you will"
    echo "never exceed a budget silently."
    echo ""
    echo "The **openai** backend (bpe cl100k_base) is exact for GPT-4/GPT-3.5 but"
    echo "undercounts vs Claude's tokenizer. Use it only when targeting OpenAI models."
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
        echo "  {\"file\": \"${FILES[$i]}\", \"claude\": ${CLAUDE_COUNTS[$i]}, \"openai\": ${OPENAI_COUNTS[$i]}, \"actual\": ${API_COUNTS[$i]}}$comma"
    else
        echo "  {\"file\": \"${FILES[$i]}\", \"claude\": ${CLAUDE_COUNTS[$i]}, \"openai\": ${OPENAI_COUNTS[$i]}}$comma"
    fi
done
echo "]"
echo '```'
