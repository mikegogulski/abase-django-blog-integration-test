#!/usr/bin/env bash
# Class L: Agent Mail behavior Scenario test.
. "$(dirname "$0")/test_common.sh"
cd "$REPO_ROOT"
uv run --project "$REPO_ROOT/.abase" python "$REPO_ROOT/.abase/tests/scenario/test_scenario_l.py"; rc=$?
[[ $rc -eq 77 ]] && skip "Class L: Scenario not installed or API keys missing"
[[ $rc -eq 0 ]] && pass "Class L passed" || fail "Class L failed"
