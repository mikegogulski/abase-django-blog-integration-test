#!/usr/bin/env bash
# Starts mock_delayed_health_server in background. Used by test_ensure_agent_mail retry test.
# Invoked by ensure_agent_mail when AGENT_MAIL_RUN_SCRIPT points here.
exec python3 "$(dirname "$0")/mock_delayed_health_server.py" "${AGENT_MAIL_PORT:-19878}" 2 &
