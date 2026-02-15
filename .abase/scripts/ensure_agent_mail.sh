#!/usr/bin/env bash
# Ensure the Agent Mail server is running. If not, start it in the background.
# Then run the test script to verify. Exits 0 if server is ready, non-zero after attempts.
# Use: from repo root, ./.abase/scripts/ensure_agent_mail.sh
# See docs/abase/AGENT-MAIL-SCRIPTS.md.

set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
TEST_SCRIPT="$REPO_ROOT/.abase/scripts/test_agent_mail.sh"
SERVER_DIR="$REPO_ROOT/mcp_agent_mail"
RUN_SCRIPT="$SERVER_DIR/scripts/run_server_with_token.sh"
MAX_ATTEMPTS=5

export AGENT_MAIL_PORT="${AGENT_MAIL_PORT:-8765}"

# Already running?
if "$TEST_SCRIPT"; then
  exit 0
fi

# Start server (from repo root so paths are correct)
if [[ ! -x "$RUN_SCRIPT" ]]; then
  echo "ERROR run script not found or not executable: $RUN_SCRIPT" >&2
  exit 1
fi

# Use .abase-venv to avoid clashing with project .venv; fallback to .venv for backward compat
if [[ -d "$SERVER_DIR/.abase-venv" ]]; then
  export UV_PROJECT_ENVIRONMENT="$SERVER_DIR/.abase-venv"
elif [[ -d "$SERVER_DIR/.venv" ]]; then
  export UV_PROJECT_ENVIRONMENT="$SERVER_DIR/.venv"
fi

cd "$SERVER_DIR"
"$RUN_SCRIPT" --host 127.0.0.1 --port "$AGENT_MAIL_PORT" &
pid=$!
cd "$REPO_ROOT"

# Wait and retry test
for i in $(seq 1 "$MAX_ATTEMPTS"); do
  sleep 3
  if "$TEST_SCRIPT"; then
    echo "Agent Mail started (PID $pid)."
    exit 0
  fi
done

echo "ERROR Agent Mail did not become ready after $MAX_ATTEMPTS attempts." >&2
exit 1
