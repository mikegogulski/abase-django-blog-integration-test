#!/usr/bin/env bash
# Test that the Agent Mail HTTP server is running and ready.
# Exit 0 if healthy, non-zero otherwise.
# Use: from repo root, ./abase-scripts/test_agent_mail.sh
# See docs/abase/AGENT-MAIL-SCRIPTS.md.

set -euo pipefail

PORT="${AGENT_MAIL_PORT:-8765}"
BASE_URL="${AGENT_MAIL_BASE_URL:-http://127.0.0.1:${PORT}}"
READINESS_URL="${BASE_URL}/health/readiness"

code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 3 --max-time 10 "$READINESS_URL" 2>/dev/null || echo "000")

if [[ "$code" == "200" ]]; then
  echo "OK Agent Mail readiness: $READINESS_URL -> $code"
  exit 0
fi

echo "FAIL Agent Mail not ready: $READINESS_URL -> $code" >&2
exit 1
