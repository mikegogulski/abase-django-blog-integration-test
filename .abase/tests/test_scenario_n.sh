#!/usr/bin/env bash
# Class N: Landing the plane Scenario test.
. "$(dirname "$0")/test_common.sh"
cd "$REPO_ROOT"
uv run --project "$REPO_ROOT/.abase" python "$REPO_ROOT/.abase/tests/scenario/test_scenario_n.py"; rc=$?
[[ $rc -eq 77 ]] && skip "Class N: Scenario not installed or API keys missing"
[[ $rc -eq 0 ]] && pass "Class N passed" || fail "Class N failed"
