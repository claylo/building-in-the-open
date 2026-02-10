#!/usr/bin/env bash
# PostToolUse telemetry hook for skill testing.
# Logs tool invocations to a JSONL telemetry file.
#
# Claude Code hook type: PostToolUse
# Input: JSON on stdin with tool_name, tool_input, tool_output fields
# Output: none (writes to BITO_TELEMETRY_FILE)
#
# Environment:
#   BITO_TELEMETRY_FILE - path to the JSONL telemetry file (required)

set -euo pipefail

# Skip if telemetry not configured
[[ -z "${BITO_TELEMETRY_FILE:-}" ]] && exit 0

# Read hook input from stdin
input=$(cat)

# Extract fields
tool_name=$(echo "$input" | jq -r '.tool_name // "unknown"')
# Approximate token usage from input/output sizes
input_size=$(echo "$input" | jq -r '.tool_input // "" | length')
output_size=$(echo "$input" | jq -r '.tool_output // "" | length')

# Write telemetry entry
jq -n \
  --arg event "tool_use" \
  --arg tool "$tool_name" \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --argjson input_chars "$input_size" \
  --argjson output_chars "$output_size" \
  '{event: $event, tool: $tool, timestamp: $ts, input_chars: $input_chars, output_chars: $output_chars}' \
  >> "$BITO_TELEMETRY_FILE"
