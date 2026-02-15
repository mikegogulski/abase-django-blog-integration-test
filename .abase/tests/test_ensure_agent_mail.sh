#!/usr/bin/env bash
# Test .abase/scripts/ensure_agent_mail.sh.
# When test_agent_mail already succeeds (mock server): ensure exits 0 immediately (no server start).
# Run from repo root: ./.abase/tests/test_ensure_agent_mail.sh

set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
ENSURE_SCRIPT="$REPO_ROOT/.abase/scripts/ensure_agent_mail.sh"
MOCK_SERVER="$REPO_ROOT/.abase/tests/mock_health_server.py"
MOCK_PORT="${MOCK_PORT:-19877}"

cd "$REPO_ROOT"

if [[ ! -x "$ENSURE_SCRIPT" ]]; then
  echo "FAIL ensure_agent_mail.sh not found or not executable" >&2
  exit 1
fi

# Server already running (mock) -> ensure exits 0 immediately (skips start, just runs test)
python3 "$MOCK_SERVER" "$MOCK_PORT" &
PID=$!
trap "kill $PID 2>/dev/null || true" EXIT
sleep 1

export AGENT_MAIL_PORT="$MOCK_PORT"
export AGENT_MAIL_BASE_URL="http://127.0.0.1:${MOCK_PORT}"
if "$ENSURE_SCRIPT"; then
  echo "PASS ensure_agent_mail exits 0 when server already healthy"
else
  echo "FAIL ensure_agent_mail should exit 0 when server already healthy" >&2
  exit 1
fi

echo "All test_ensure_agent_mail.sh checks passed."
