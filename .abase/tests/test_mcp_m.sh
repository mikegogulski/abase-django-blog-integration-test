#!/usr/bin/env bash
# Class M: Multi-agent MCP tests (mcp-eval).
# Runs pytest tests when mcpevals and Agent Mail available; skips otherwise.
# Blocks on Class D (Agent Mail MCP).
. "$(dirname "$0")/test_common.sh"
cd "$REPO_ROOT"

if ! python3 -c "import mcpevals" 2>/dev/null; then
  skip "Class M: mcpevals not installed (uv add 'abase[mcp-eval]')"
fi

if [[ -z "${ANTHROPIC_API_KEY:-}" && -z "${OPENAI_API_KEY:-}" ]]; then
  skip "Class M: ANTHROPIC_API_KEY or OPENAI_API_KEY required"
fi

# Ensure Agent Mail is running
if ! ./.abase/scripts/ensure_agent_mail.sh 2>/dev/null; then
  skip "Class M: Agent Mail not running (start with ensure_agent_mail.sh)"
fi

# Run multi-agent MCP tests (reuse D tests for now; extend with reserve/announce/inbox)
if uv run pytest "$REPO_ROOT/.abase/tests/mcp_eval/test_agent_mail_mcp.py" -q -v 2>/dev/null; then
  pass "Class M: Multi-agent MCP tests passed"
else
  fail "Class M: Multi-agent MCP tests failed"
fi
