#!/usr/bin/env bash
# Class D: Agent Mail MCP tests (mcp-eval).
# Runs pytest tests when mcpevals and Agent Mail available; skips otherwise.
. "$(dirname "$0")/test_common.sh"
cd "$REPO_ROOT"

if ! python3 -c "import mcpevals" 2>/dev/null; then
  skip "Class D: mcpevals not installed (uv add 'abase[mcp-eval]')"
fi

if [[ -z "${ANTHROPIC_API_KEY:-}" && -z "${OPENAI_API_KEY:-}" ]]; then
  skip "Class D: ANTHROPIC_API_KEY or OPENAI_API_KEY required"
fi

# Ensure Agent Mail is running
if ! ./.abase/scripts/ensure_agent_mail.sh 2>/dev/null; then
  skip "Class D: Agent Mail not running (start with ensure_agent_mail.sh)"
fi

# Run mcp-eval pytest tests
if uv run pytest "$REPO_ROOT/.abase/tests/mcp_eval/test_agent_mail_mcp.py" -q -v 2>/dev/null; then
  pass "Class D: Agent Mail MCP tests passed"
else
  fail "Class D: Agent Mail MCP tests failed"
fi
