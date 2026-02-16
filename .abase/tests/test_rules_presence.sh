#!/usr/bin/env bash
# Test abase rules presence and structure. Class E.
# Run from repo root: ./.abase/tests/test_rules_presence.sh

. "$(dirname "$0")/test_common.sh"
cd "$REPO_ROOT"

RULES="$REPO_ROOT/.cursor/rules"

REQUIRED=(
  abase-agent-behavior.mdc
  abase-agentic-safety-and-input.mdc
  abase-agentic-workflow.mdc
  abase-agent-prompts-by-keyword.mdc
  abase-beads-workflow.mdc
  abase-conventions.mdc
  abase-handover-context.mdc
  abase-handover-management.mdc
  abase-multi-agent-agent-mail.mdc
  abase-planning-workflow.mdc
  abase-project-context.mdc
  abase-terminal-command-error-handling.mdc
  abase-workflow.mdc
)

missing=0
for f in "${REQUIRED[@]}"; do
  if [[ -f "$RULES/$f" ]]; then
    pass "$f exists"
  else
    echo "FAIL $f missing" >&2
    missing=$((missing + 1))
  fi
done

[[ $missing -eq 0 ]] || fail "$missing required rules missing"

if grep -rq "abase-handover-context" "$RULES" 2>/dev/null; then
  pass "handover-context referenced"
else
  fail "handover-context should be referenced"
fi

echo "All test_rules_presence.sh checks passed."
