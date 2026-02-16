#!/usr/bin/env bash
# Class I: Agent session Scenario test stub.
# Runs test_agent_session.py; skips when Scenario/API key not available.
. "$(dirname "$0")/test_common.sh"
cd "$REPO_ROOT"
python3 "$REPO_ROOT/.abase/tests/scenario/test_agent_session.py"; rc=$?
[[ $rc -eq 77 ]] && skip "Class I: Scenario not installed or API key missing"
[[ $rc -eq 0 ]] && pass "Class I passed" || fail "Class I failed"
