#!/usr/bin/env bash
# Test .abase/scripts/test_agent_mail.sh against a mock health server.
# Run from repo root: ./.abase/tests/test_test_agent_mail.sh

. "$(dirname "$0")/test_common.sh"
cd "$REPO_ROOT"

TEST_SCRIPT="$REPO_ROOT/.abase/scripts/test_agent_mail.sh"
MOCK_SERVER="$REPO_ROOT/.abase/tests/mock_health_server.py"
MOCK_PORT="${MOCK_PORT:-19876}"

[[ -x "$TEST_SCRIPT" ]] || fail "test_agent_mail.sh not found or not executable: $TEST_SCRIPT"
[[ -f "$MOCK_SERVER" ]] || fail "mock_health_server.py not found: $MOCK_SERVER"

# Start mock server in background
python3 "$MOCK_SERVER" "$MOCK_PORT" &
PID=$!
trap "kill $PID 2>/dev/null || true" EXIT

# Wait for server to bind (or fail if port in use)
sleep 1
if ! curl -s -o /dev/null -w "%{http_code}" --connect-timeout 2 "http://127.0.0.1:${MOCK_PORT}/health/readiness" 2>/dev/null | grep -q 200; then
  fail "Mock server did not start on port $MOCK_PORT (port in use?). Set MOCK_PORT to a free port (e.g. 29876) to avoid conflicts."
fi

# Test: server up -> exit 0
export AGENT_MAIL_PORT="$MOCK_PORT"
export AGENT_MAIL_BASE_URL="http://127.0.0.1:${MOCK_PORT}"
if "$TEST_SCRIPT"; then
  pass "test_agent_mail.sh returns 0 when server is healthy"
else
  fail "test_agent_mail.sh should return 0 when server is healthy"
fi

# Test: server down -> exit 1
kill $PID 2>/dev/null || true
wait $PID 2>/dev/null || true
trap - EXIT
sleep 1

if "$TEST_SCRIPT" 2>/dev/null; then
  fail "test_agent_mail.sh should return non-zero when server is down"
else
  pass "test_agent_mail.sh returns non-zero when server is down"
fi

echo "All test_test_agent_mail.sh checks passed."
