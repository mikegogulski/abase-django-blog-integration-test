# Agent Mail and MCP: Learnings

Notes from getting Agent Mail and its MCP server running in this project.

## MCP (Cursor)

- **Project-local only:** All MCP config is in **`.cursor/mcp.json`** in this repo. Do not use account-level MCP for this project.
- **Multiple entries:** Cursor can show more than one entry for the same logical server (e.g. one broken, one disabled). **Disable the broken one and enable the working one.** The working server’s tool prefix in Cursor may differ from the key in `mcp.json` (e.g. `abase-mcp_agent_mail_http` vs `mcp_agent_mail_http`). Use the prefix that appears when the server is enabled.
- **Tools:** When the correct server is enabled, tools are callable with the prefix Cursor assigns (e.g. `health_check`, `ensure_project`, `create_agent_identity`). If you see “Tool not found”, check that (1) the server is enabled, (2) no duplicate/broken server is taking precedence, and (3) the Agent Mail HTTP server is running.

## Agent Mail server

- **Start before use:** Run **`./.abase/scripts/ensure_agent_mail.sh`** from the repo root before using any Agent Mail MCP tools. The server may not be running after a Cursor or machine restart.
- **Verify:** Run **`./.abase/scripts/test_agent_mail.sh`** after starting or when something fails. See **docs/abase/AGENT-MAIL-SCRIPTS.md**.
- **Venv:** The server runs with **Python 3.12** in `.abase/mcp_agent_mail/.abase-venv` (isolated from your project's `.venv`). After a fresh submodule clone or `git submodule update`, recreate: `cd .abase/mcp_agent_mail && uv venv --python 3.12 .abase-venv && UV_PROJECT_ENVIRONMENT=.abase-venv uv sync`. Python 3.14 caused pydantic errors. **Existing setups:** `.abase/scripts/ensure_agent_mail.sh` prefers `.abase-venv` but falls back to `.venv` if present.

## Mailbox (STORAGE_ROOT)

- **Use workspace path:** Set **`STORAGE_ROOT`** to a directory **inside the workspace** (e.g. **`/home/syadasti/abase/.agent_mail_mailbox`**) so the process that runs the MCP server can write to it. The default `~/.mcp_agent_mail_git_mailbox_repo` can hit permission or sandbox restrictions when Cursor (or its MCP layer) runs the server.
- **Config:** In **`.abase/mcp_agent_mail/.env`** set:
  - `HTTP_BEARER_TOKEN=...` (same token as in `.cursor/mcp.json` headers)
  - `STORAGE_ROOT=/home/syadasti/abase/.agent_mail_mailbox`
- **Git:** **`.agent_mail_mailbox/`** is in the repo **`.gitignore`**; do not commit mailbox data.
- **Bootstrap:** If the mailbox dir is new, run `git init` inside it once so the server can use it as a Git archive.

## Submodule

- **`.abase/mcp_agent_mail`** is a Git submodule. After `git clone --recurse-submodules` or `git submodule update --init`, run in `.abase/mcp_agent_mail`: `uv venv --python 3.12 .abase-venv && UV_PROJECT_ENVIRONMENT=.abase-venv uv sync`, and ensure `.env` exists with `HTTP_BEARER_TOKEN` and `STORAGE_ROOT` as above.

## Multi-agent (4 or 8 agents)

- **Ensure project:** Call **`ensure_project(human_key="/home/syadasti/abase")`** once so the project exists in Agent Mail.
- **Create agents:** Call **`create_agent_identity(project_key="/home/syadasti/abase", program="cursor", model="agent", task_description="...")`** once per agent; omit `name` to get auto-generated names. You can use **`register_agent`** to reuse/update an existing agent by name.
- **Beads:** Assign beads to agents by setting **`assignee`** in Beads (`bd update --id <id> --assignee <agent_name>`). Each agent (or a single session simulating several) can then claim and work beads.

## Quick checklist

1. Start server: `./.abase/scripts/ensure_agent_mail.sh`
2. Test: `./.abase/scripts/test_agent_mail.sh`
3. In Cursor: ensure the correct Agent Mail MCP server is enabled and the broken one (if any) is disabled.
4. Call `health_check` (or `ensure_project`) to confirm MCP works.
