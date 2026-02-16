#!/usr/bin/env bash
# Class J: Agent bounded Scenario test.
. "$(dirname "$0")/test_common.sh"
cd "$REPO_ROOT"
python3 "$REPO_ROOT/.abase/tests/scenario/test_scenario_j.py"; rc=$?
[[ $rc -eq 77 ]] && skip "Class J: Scenario not installed or API key missing"
[[ $rc -eq 0 ]] && pass "Class J passed" || fail "Class J failed"
