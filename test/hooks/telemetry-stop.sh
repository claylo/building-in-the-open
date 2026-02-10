#!/usr/bin/env bash
# Stop telemetry hook for skill testing.
# Logs session summary to the JSONL telemetry file.
#
# Claude Code hook type: Stop
# Input: JSON on stdin with session summary fields
# Output: none (writes to BITO_TELEMETRY_FILE)
#
# Environment:
#   BITO_TELEMETRY_FILE - path to the JSONL telemetry file (required)

set -euo pipefail

# Skip if telemetry not configured
[[ -z "${BITO_TELEMETRY_FILE:-}" ]] && exit 0

# Read hook input from stdin
input=$(cat)

# Extract available fields (structure depends on Claude Code version)
total_input=$(echo "$input" | jq -r '.input_tokens // .total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.output_tokens // .total_output_tokens // 0')
total_cache=$(echo "$input" | jq -r '.cache_read_tokens // .total_cache_read_tokens // 0')
num_turns=$(echo "$input" | jq -r '.num_turns // 0')

# Write session summary
jq -n \
  --arg event "session_end" \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --argjson input_tokens "$total_input" \
  --argjson output_tokens "$total_output" \
  --argjson cache_read_tokens "$total_cache" \
  --argjson turns "$num_turns" \
  '{event: $event, timestamp: $ts, input_tokens: $input_tokens, output_tokens: $output_tokens, cache_read_tokens: $cache_read_tokens, turns: $turns}' \
  >> "$BITO_TELEMETRY_FILE"
