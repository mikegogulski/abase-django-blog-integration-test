# Multi-Agent + Agent Mail + Beads + BV: What’s in Place vs Missing

Use this to refine the workflow and start using **multiple agents**, **Agent Mail**, **Beads**, and **BV**.

**Critical:** MCP configuration is **project-local only**. All MCP server config lives in **`.cursor/mcp.json`** in this repo. Do not use account-level (`~/.cursor` or global) MCP config for this project. See `.cursor/rules/project-context.mdc`.

---

## What we have in place

### Beads (installed and initialized)

- **CLI:** `./bin/bd` (or put `workflow/bin` on PATH). **Data:** `workflow/.beads/` (SQLite, prefix `workflow-`).
- **Docs and rules** assume Beads: `bd ready --json`, `bd new`, `bd update`, `bd link`, `discovered_from`, `assignee`.
- **AGENTS.md** and **.cursor/rules/agentic-workflow.mdc** describe the loop: get ready work → claim → work → discover → close; bounded runs (default one bead); keyword menu when input is needed.
- **.cursor/rules/workflow.mdc** explains the model; **docs/AGENT-SWARM-EVALUATION.md** explains Beads + BV + Agent Mail + NTM and when to add them.
- Seed issues created (e.g. “Django blog MVP”, “Project setup: Django, venv, settings”).

### BV (Beads Viewer) — installed

- **Installed** at `~/.local/bin/bv` (on PATH). Use: `bv --robot-next`, `bv --robot-triage`; never run bare `bv`.
- BV reads this repo’s `.beads/` and works with the steveyegge beads setup.

### Multi-agent (concept + rules)

- **AGENTS.md** says: “If multiple agents or Cursor sessions work in this repo, they share the same Beads store. Each session: pull latest, run `bd ready --json`, claim a task, work, commit code + Beads.”
- **.cursor/rules/multi-agent-agent-mail.mdc** describes when Agent Mail is available: register, reserve paths, announce by bead ID, check inbox, release.

### Agent Mail (MCP) — installed and configured

- **Server:** `workflow/mcp_agent_mail/`. Run with **Python 3.12** (venv is 3.12; 3.14 had pydantic errors).
- **Start:** `cd mcp_agent_mail && ./scripts/run_server_with_token.sh` or `uv run python -m mcp_agent_mail.cli serve-http` (default: http://127.0.0.1:8765/api/).
- **Cursor:** project-local `.cursor/mcp.json` points at `http://127.0.0.1:8765/api/` with bearer token. Start the server before using Agent Mail in Cursor.
- **Rules:** `.cursor/rules/multi-agent-agent-mail.mdc` tells agents to register, reserve files, announce work by bead ID, check inbox, release.

### Safety and input

- **Bounded runs**: default one bead; continue only if user said “multiple” or used **next**.
- **Keyword menu**: when input is needed, agent shows keywords; user replies with keyword (or uses Cursor Command/script). Full prompts in **.cursor/rules/agent-prompts-by-keyword.mdc**.
- **Project constraints**: Hetzner, no Docker unless necessary, YOLO (project-tree + limited sudo; no WSL-breaking).

### Other

- **Django blog** rule (`.cursor/rules/django-blog.mdc`) for when we write code.
- **TODO.md** with follow-ups (bjn/.cursor analysis, Ultimate MCP, jeffreysprompts.com, top 30 skills — last already evaluated).

---

## What’s done vs optional

| Piece | Status | Notes |
|-------|--------|------|
| **Beads (`bd`)** | Done | `./bin/bd`, `.beads/` initialized, seed issues created. |
| **BV** | Done | `~/.local/bin/bv`; use `bv --robot-next` / `bv --robot-triage`. |
| **Agent Mail (MCP)** | Done | `mcp_agent_mail/` in repo; venv Python 3.12; start with `./scripts/run_server_with_token.sh`. |
| **Cursor MCP config** | Project-local | `.cursor/mcp.json` has Agent Mail URL and bearer token. Enable the working MCP server; disable any broken duplicate. See **docs/AGENT-MAIL-AND-MCP-LEARNINGS.md**. |
| **Multi-agent rules** | Done | `.cursor/rules/multi-agent-agent-mail.mdc` (register, reserve, announce, inbox, release). |
| **NTM (optional)** | Deferred | Only for scripted prompt injection into tmux; optional for multiple Cursor windows + Beads + Agent Mail. |
| **More seed beads** | Optional | Add more tasks (e.g. “posts app”, “listing/detail pages”) as needed. |

---

## Quick reference

- **Beads:** `./bin/bd` (or `workflow/bin` on PATH); data in `.beads/`.
- **BV:** `bv --robot-next` / `bv --robot-triage` (from `~/.local/bin`).
- **Agent Mail:** Run `./scripts/ensure_agent_mail.sh` to start the server if needed; run `./scripts/test_agent_mail.sh` after starting or when there is trouble. See **docs/AGENT-MAIL-SCRIPTS.md**.
- **4 subagents:** Use **`STORAGE_ROOT`** in the workspace (e.g. `.agent_mail_mailbox`) so the server can write; see **docs/AGENT-MAIL-AND-MCP-LEARNINGS.md**. Then: `ensure_project(human_key="/home/syadasti/workflow")`, then `create_agent_identity(project_key="...", program="cursor", model="agent")` per agent (omit `name` for auto-generated names). If MCP tools are unavailable, ensure the correct Agent Mail MCP server is enabled and any broken duplicate is disabled (see learnings doc).

---

## Summary

- **In place:** Beads CLI + init, BV, Agent Mail MCP (install + project-local Cursor config), multi-agent + Agent Mail rules, seed beads, safety (bounded runs, keyword menu), project constraints (Hetzner, no Docker, YOLO), Django blog conventions.
- **Optional:** More seed beads, NTM for scripted multi-session prompting.
