# Agent Mail scripts

Scripts to **ensure** the Agent Mail server is running and to **test** that it is healthy. Agents should use these instead of asking the user to start or check Agent Mail.

## Scripts

| Script | Purpose |
|--------|--------|
| `.abase/scripts/test_agent_mail.sh` | Check that the Agent Mail HTTP server is up and ready. Exit 0 if `GET /health/readiness` returns 200, else non-zero. |
| `.abase/scripts/ensure_agent_mail.sh` | If the server is not ready, start it in the background, then run `test_agent_mail.sh` until ready or up to 5 attempts. Exit 0 when ready. |

**Run from repo root:** `./.abase/scripts/test_agent_mail.sh` and `./.abase/scripts/ensure_agent_mail.sh`.

## When to use

- **Before using Agent Mail MCP tools or multi-agent workflows:** run `./.abase/scripts/ensure_agent_mail.sh` so the server is running. Do not tell the user to start it.
- **After starting Agent Mail or when it has trouble:** run `./.abase/scripts/test_agent_mail.sh` to verify. If it fails, troubleshoot (e.g. restart, port, venv) and re-run. See `.cursor/rules/abase-agent-behavior.mdc` (iterate up to 5 times).

## Environment

- `AGENT_MAIL_PORT` — default `8765`.
- `AGENT_MAIL_BASE_URL` — default `http://127.0.0.1:8765` (used by test script for `$BASE_URL/health/readiness`).

## Implementation details

- Test hits `http://127.0.0.1:8765/health/readiness` (no auth). Server must be started from `.abase/mcp_agent_mail/` with the Agent Mail venv (Python 3.12 in `.abase-venv`, or `.venv` for backward compat).
- Ensure script starts the server via `.abase/mcp_agent_mail/scripts/run_server_with_token.sh` and then polls `.abase/scripts/test_agent_mail.sh` every 3 seconds, up to 5 times.
- **Agents:** When running the test or ensure script from a sandboxed environment, use `required_permissions: ["network"]` or `["full_network"]` so the script can reach 127.0.0.1.

## See also

- **docs/abase/AGENT-MAIL-AND-MCP-LEARNINGS.md** — MCP setup, STORAGE_ROOT in workspace, duplicate/broken servers, multi-agent.
