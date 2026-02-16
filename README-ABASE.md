# abase — Installation and Overview

abase is a workflow framework for AI-assisted development. It provides Beads (task tracking), optional Agent Mail (multi-agent coordination), optional BV (Beads Viewer), rules, skills, and docs that keep sessions continuous and handoffs clean.

## How the Framework Works

1. **Beads** — Repo-local task graph (`.beads/`). Agents run `bd ready`, claim tasks, work, and close. Dependencies and `discovered_from` edges keep the plan queryable.
2. **Rules** — `.cursor/rules/abase-*.mdc` define workflow, conventions, handover, and safety. Project-specific rules (e.g. `django-blog.mdc`) live alongside.
3. **Skills** — `.agents/skills/abase-*` (symlinked to `.cursor/skills/` for Cursor). Skills add PRD, embedded systems, computer vision, etc.
4. **Handover** — `.cursor/rules/abase-handover-context.mdc` (gitignored) gives new sessions continuity. Archives go to `.cursor/handover-archive/`.
5. **Agent Mail** (optional) — MCP server for multi-agent coordination: identities, inbox, file reservations. Used when running multiple agents.
6. **BV** (optional) — Beads Viewer TUI; use `bv --robot-next` / `bv --robot-triage` for machine-readable triage. Never run bare `bv` (TUI blocks).

## Installation Steps

### 1. Clone the repository

```bash
git clone --recurse-submodules <repo-url>
cd <repo>
```

### 2. Beads (bd)

**Option A — Use bundled binary (if present):**

```bash
./bin/bd quickstart   # One-time init per repo
```

**Option B — Install via Agent Mail installer (Linux/WSL/macOS only; requires bash):**

```bash
curl -fsSL "https://raw.githubusercontent.com/Dicklesworthstone/mcp_agent_mail/main/scripts/install.sh?$(date +%s)" | bash -s -- --yes
```

Add `--skip-beads` if you already have `bd` or `br`. **Windows (without WSL):** use Option A with a bundled binary, or install Beads/br manually from [beads_rust](https://github.com/Dicklesworthstone/beads_rust).

### 3. Agent Mail (optional, for multi-agent)

**Linux/WSL/macOS:**

1. **Submodule and venv** (uses `.abase-venv` so it does not clash with your project's `.venv`):

   ```bash
   git submodule update --init
   cd mcp_agent_mail
   uv venv --python 3.12 .abase-venv
   UV_PROJECT_ENVIRONMENT=.abase-venv uv sync
   ```

2. **Create `.env`** in `mcp_agent_mail/`:

   ```
   HTTP_BEARER_TOKEN=<hex-token>
   STORAGE_ROOT=<absolute-path-to-repo>/.agent_mail_mailbox
   ```

   Generate a hex token (POSIX `dd` and `od`, no openssl required):

   ```bash
   dd if=/dev/urandom bs=1 count=32 2>/dev/null | od -A n -t x1 | tr -d ' \n'
   ```

3. **Add MCP config** — MCP-enabled tools use this to connect to the Agent Mail server. Add the following to your tool's MCP config (merge the `mcp_agent_mail_http` entry into existing `mcpServers` if the file already has entries):

   ```json
   {
     "mcpServers": {
       "mcp_agent_mail_http": {
         "url": "http://127.0.0.1:8765/api/",
         "headers": {
           "Authorization": "Bearer <YOUR_HEX_TOKEN>"
         }
       }
     }
   }
   ```

   Replace `<YOUR_HEX_TOKEN>` with the same value as `HTTP_BEARER_TOKEN` in your `.env`. The server authenticates requests using this token.

   **Config location by tool:** Cursor uses `.cursor/mcp.json` in the project root. Other MCP-enabled tools (Claude Desktop, Windsurf, etc.) use their own config paths—consult your tool's docs.

4. **Start server:** From repo root, `./.abase/scripts/ensure_agent_mail.sh`. Test with `./.abase/scripts/test_agent_mail.sh`.

**Windows (PowerShell, without WSL):** The curl-based installer and `.abase/scripts/*.sh` require bash. Use manual setup:

1. **Install uv** (PowerShell or WinGet): `powershell -ExecutionPolicy Bypass -c "irm https://astral.sh/uv/install.ps1 | iex"` — or `winget install -e --id astral-sh.uv`
2. **Submodule and venv:** `git submodule update --init`, then `cd mcp_agent_mail`, `uv venv --python 3.12 .abase-venv`, `$env:UV_PROJECT_ENVIRONMENT=".abase-venv"; uv sync`
3. **Create `.env`** with `HTTP_BEARER_TOKEN` and `STORAGE_ROOT` (same format as above). Generate hex token: `-join ((1..32) | ForEach-Object { '{0:x2}' -f (Get-Random -Maximum 256) })`
4. **Add MCP config** (same JSON as above)
5. **Start server manually:** `$env:UV_PROJECT_ENVIRONMENT=".abase-venv"; uv run python -m mcp_agent_mail.cli serve-http --host 127.0.0.1 --port 8765` — keep terminal open. Verify: `Invoke-WebRequest -Uri http://127.0.0.1:8765/health/readiness -UseBasicParsing` returns 200

See **docs/abase/AGENT-MAIL-SCRIPTS.md** and **docs/abase/AGENT-MAIL-AND-MCP-LEARNINGS.md** for details.

### 4. BV (Beads Viewer, optional)

**Option A — Via Agent Mail installer (Linux/WSL/macOS only):**

```bash
curl -fsSL "https://raw.githubusercontent.com/Dicklesworthstone/mcp_agent_mail/main/scripts/install.sh?$(date +%s)" | bash -s -- --yes
```

Add `--skip-bv` if you don't want BV.

**Option B — Manual:** Install from [beads_rust](https://github.com/Dicklesworthstone/beads_rust) or the BV distribution; ensure `bv` is on PATH. Use `bv --robot-next` and `bv --robot-triage` for agents; never run `bv` interactively. **Windows:** no native BV installer; use WSL or install manually if a Windows build exists.

### 5. Windows users

- **Symlinks:** Skills symlinks can fail on Windows. See **README-WINDOWS.md** for mitigation.
- **Bash-based installs:** The curl \| bash installer and `.abase/scripts/*.sh` require bash (use WSL, Git Bash, or the Windows manual steps in §3).

## Key Paths

| Path | Purpose |
|------|---------|
| `./bin/bd` | Beads CLI (run from repo root) |
| `.beads/` | Beads DB and config |
| `.cursor/rules/abase-*.mdc` | Framework rules |
| `.cursor/rules/abase-handover-context.mdc` | Session handover (gitignored) |
| `.agents/skills/abase-*` | Framework skills |
| `.cursor/skills/` | Symlinks to `.agents/skills/` (Cursor) |
| `docs/abase/` | Framework docs |
| `docs/abase-templates/` | Template examples |
| `mcp_agent_mail/` | Agent Mail submodule (venv: `.abase-venv`) |
| `.abase/scripts/` | Framework scripts (ensure/test Agent Mail) |
| `.abase/scripts/ensure_agent_mail.sh` | Start Agent Mail server |
| `.abase/scripts/test_agent_mail.sh` | Verify Agent Mail |
| `.abase/scripts/setup_worktree.sh` | Create git worktree for parallel branches |
| `.abase/tests/` | P0 tests (run `./.abase/tests/run_tests.sh`) |

## Updating This Document

When you change the framework (new software, new paths, new setup steps), update **README-ABASE.md** so it stays accurate. See **.cursor/rules/abase-conventions.mdc** (README-ABASE maintenance).
