#!/usr/bin/env bash
# Test .abase/scripts/ensure_agent_mail.sh.
# When test_agent_mail already succeeds (mock server): ensure exits 0 immediately (no server start).
# Run from repo root: ./.abase/tests/test_ensure_agent_mail.sh

. "$(dirname "$0")/test_common.sh"
cd "$REPO_ROOT"

ENSURE_SCRIPT="$REPO_ROOT/.abase/scripts/ensure_agent_mail.sh"
MOCK_SERVER="$REPO_ROOT/.abase/tests/mock_health_server.py"
MOCK_PORT="${MOCK_PORT:-19877}"

[[ -x "$ENSURE_SCRIPT" ]] || fail "ensure_agent_mail.sh not found or not executable"
[[ -f "$MOCK_SERVER" ]] || fail "mock_health_server.py not found: $MOCK_SERVER"

# Server already running (mock) -> ensure exits 0 immediately (skips start, just runs test)
python3 "$MOCK_SERVER" "$MOCK_PORT" &
PID=$!
trap "kill $PID 2>/dev/null || true" EXIT
sleep 1
if ! curl -s -o /dev/null -w "%{http_code}" --connect-timeout 2 "http://127.0.0.1:${MOCK_PORT}/health/readiness" 2>/dev/null | grep -q 200; then
  fail "Mock server did not start on port $MOCK_PORT (port in use?). Set MOCK_PORT to a free port (e.g. 29877) to avoid conflicts."
fi

export AGENT_MAIL_PORT="$MOCK_PORT"
export AGENT_MAIL_BASE_URL="http://127.0.0.1:${MOCK_PORT}"
if "$ENSURE_SCRIPT"; then
  pass "ensure_agent_mail exits 0 when server already healthy"
else
  fail "ensure_agent_mail should exit 0 when server already healthy"
fi

echo "All test_ensure_agent_mail.sh checks passed."
