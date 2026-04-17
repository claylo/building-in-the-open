#!/usr/bin/env bash
# handoff-nudge.sh — UserPromptSubmit hook
#
# Emits the curating-context skill nudge only when the user's prompt contains
# "/handoff". UserPromptSubmit hooks have no matcher support — per the docs
# (hooks.md:228), matcher fields on these events are silently ignored and the
# hook fires on every prompt regardless. So we gate here in the script.

set -euo pipefail

prompt=$(jq -r '.prompt // ""')

if [[ "$prompt" == *"/handoff"* ]]; then
  echo 'The building-in-the-open plugin has a curating-context skill for writing handoff documents. Use the Skill tool to invoke it: skill: "curating-context"'
fi
