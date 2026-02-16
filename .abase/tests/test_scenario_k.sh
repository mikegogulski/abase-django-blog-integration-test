#!/usr/bin/env bash
# Class K: Keyword menu Scenario test.
. "$(dirname "$0")/test_common.sh"
cd "$REPO_ROOT"
uv run --project "$REPO_ROOT/.abase" python "$REPO_ROOT/.abase/tests/scenario/test_scenario_k.py"; rc=$?
[[ $rc -eq 77 ]] && skip "Class K: Scenario not installed or API keys missing"
[[ $rc -eq 0 ]] && pass "Class K passed" || fail "Class K failed"
