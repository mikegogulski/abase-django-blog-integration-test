#!/usr/bin/env bash
# Test abase rules presence and structure. Class E.
# Run from repo root: ./.abase/tests/test_rules_presence.sh

set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
RULES="$REPO_ROOT/.cursor/rules"
cd "$REPO_ROOT"

REQUIRED=(
  abase-agent-behavior.mdc
  abase-agentic-safety-and-input.mdc
  abase-agentic-workflow.mdc
  abase-agent-prompts-by-keyword.mdc
  abase-conventions.mdc
  abase-handover-context.mdc
  abase-handover-management.mdc
  abase-project-context.mdc
  abase-workflow.mdc
)

missing=0
for f in "${REQUIRED[@]}"; do
  if [[ -f "$RULES/$f" ]]; then
    echo "PASS $f exists"
  else
    echo "FAIL $f missing" >&2
    missing=$((missing + 1))
  fi
done

if [[ $missing -gt 0 ]]; then
  echo "FAIL $missing required rules missing" >&2
  exit 1
fi

if grep -rq "abase-handover-context" "$RULES" 2>/dev/null; then
  echo "PASS handover-context referenced"
else
  echo "FAIL handover-context should be referenced" >&2
  exit 1
fi

echo "All test_rules_presence.sh checks passed."
