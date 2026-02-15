#!/usr/bin/env bash
# Test .abase/scripts/test_agent_mail.sh against a mock health server.
# Run from repo root: ./.abase/tests/test_test_agent_mail.sh

set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
TEST_SCRIPT="$REPO_ROOT/.abase/scripts/test_agent_mail.sh"
MOCK_SERVER="$REPO_ROOT/.abase/tests/mock_health_server.py"
MOCK_PORT="${MOCK_PORT:-19876}"

cd "$REPO_ROOT"

# Ensure test script exists
if [[ ! -x "$TEST_SCRIPT" ]]; then
  echo "FAIL test_agent_mail.sh not found or not executable: $TEST_SCRIPT" >&2
  exit 1
fi

# Start mock server in background
python3 "$MOCK_SERVER" "$MOCK_PORT" &
PID=$!
trap "kill $PID 2>/dev/null || true" EXIT

# Wait for server to bind
sleep 1

# Test: server up -> exit 0
export AGENT_MAIL_PORT="$MOCK_PORT"
export AGENT_MAIL_BASE_URL="http://127.0.0.1:${MOCK_PORT}"
if "$TEST_SCRIPT"; then
  echo "PASS test_agent_mail.sh returns 0 when server is healthy"
else
  echo "FAIL test_agent_mail.sh should return 0 when server is healthy" >&2
  exit 1
fi

# Test: server down -> exit 1
kill $PID 2>/dev/null || true
wait $PID 2>/dev/null || true
trap - EXIT
sleep 1

if "$TEST_SCRIPT" 2>/dev/null; then
  echo "FAIL test_agent_mail.sh should return non-zero when server is down" >&2
  exit 1
else
  echo "PASS test_agent_mail.sh returns non-zero when server is down"
fi

echo "All test_test_agent_mail.sh checks passed."
