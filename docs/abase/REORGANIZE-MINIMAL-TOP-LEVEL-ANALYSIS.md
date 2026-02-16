# Reorganize for Minimum Top-Level: Analysis and Feasibility

**Goal:** Reorganize the project tree so there are the **minimum number of directories and files at top level** while the setup still works when the tree is **copied into a new project** (new repo root).

**Scope:** Analysis and findings only. No moves or edits have been made.

---

## 1. Current top-level inventory

| Type   | Name            | Purpose |
|--------|-----------------|--------|
| Dir    | `.beads/`       | Beads DB, config, issues (JSONL), metadata; `bd` discovers from CWD |
| Dir    | `.cursor/`      | Project-local MCP config (`mcp.json`), Cursor rules (`rules/*.mdc`) |
| Dir    | `.downloads/`   | Beads release tarball, README, LICENSE (optional after extract) |
| Dir    | `.vscode/`      | Workspace settings (e.g. agent edit permissions) |
| Dir    | `bin/`          | `bd` binary (Beads CLI) |
| Dir    | `docs/`         | 13 markdown docs (workflow, Agent Mail, safety, conventions, etc.) |
| Dir    | `mcp_agent_mail/`| Agent Mail MCP server (submodule); venv, run script, .env |
| Dir    | `scripts/`      | `ensure_agent_mail.sh`, `test_agent_mail.sh` (invoked from repo root) |
| File   | `.gitignore`    | Git; must be at repo root |
| File   | `.gitmodules`   | Git submodule config; must be at repo root if using submodule |
| File   | `AGENTS.md`     | Primary agent instructions; often expected at repo root |
| File   | `TODO.md`       | Task list / follow-ups |

**Total: 8 directories + 4 files = 12 top-level entries.**

---

## 2. What “copy into new project” implies

- The **new project** is a new repo root (e.g. `~/projects/myblog`).
- You copy (or clone) **this tree** so that the **contents** of this repo become (or sit under) that root.
- After copy, opening the new project in Cursor must give:
  - Working Beads (`bd` and `.beads` discoverable)
  - Working Agent Mail (server startable, MCP config loadable)
  - Rules and docs still referenced correctly
  - Scripts runnable from the new root

So paths that are **relative to repo root** (e.g. `scripts/`, `docs/`, `.cursor/`) must either stay at root or be moved consistently and all references updated. Paths that are **absolute** (e.g. in `mcp_agent_mail/.env`: `STORAGE_ROOT=/home/syadasti/abase/.agent_mail_mailbox`) must become project-agnostic (e.g. relative or “current project root”) when used as a template.

---

## 3. Hard constraints (must stay or cannot move)

| Item | Constraint | Reason |
|------|------------|--------|
| **`.cursor/`** | Must be at **workspace/repo root** | Cursor loads project-local MCP and rules from `.cursor` at the opened folder root. If you open `~/myblog`, Cursor looks for `~/myblog/.cursor/mcp.json` and `~/myblog/.cursor/rules/`. |
| **`.beads/`** | Must be where **`bd` is run** (always repo root in current usage) | Beads discovers `.beads/` from the current working directory. If `.beads` were moved to e.g. `meta/.beads`, you’d have to `cd meta` to run `bd`, or set `BD_DB`/`--db` everywhere. Keeping `.beads` at repo root is the only zero-config pattern. |
| **`.gitignore`** | Must be at **repo root** | Git only reads `.gitignore` at root (or in subdirs for that subtree). |
| **`.gitmodules`** | Must be at **repo root** | Git requires `.gitmodules` at root when using submodules. |
| **`.vscode/`** | Must be at **workspace root** | VS Code and Cursor load **workspace** settings only from a `.vscode` folder at the **root of the opened workspace**. When you "Open Folder" on the project root (e.g. `~/myblog`), the editor looks for `~/myblog/.vscode/settings.json`. It does **not** look for `~/myblog/meta/.vscode/settings.json` or any other subfolder. If you move `.vscode` into e.g. `meta/`, those settings will not be applied when the user opens the project root. So for "open project root and have workspace settings apply", `.vscode` must stay at top level. |
| **`AGENTS.md`** | Must be at **project root** for Cursor | Cursor treats **only** the AGENTS.md at the **project root** as the project-level agent instructions and appends it automatically. Nested or subdirectory AGENTS.md files are **not** automatically loaded (per Cursor docs and community reports). Moving AGENTS.md to e.g. `docs/` would break Cursor's automatic discovery of project instructions. |
| **`mcp_agent_mail/`** | **Path assumed by scripts and .gitmodules** (soft in principle) | `scripts/ensure_agent_mail.sh` sets `SERVER_DIR="$REPO_ROOT/mcp_agent_mail"`. Could be moved to e.g. `meta/mcp_agent_mail` if scripts, `.gitmodules`, and docs are updated. Not mandated by a tool that "only looks at root"; moving is feasible with reference updates. |

So the things that **cannot** move for standard tool behavior are: **`.cursor/`**, **`.beads/`**, **`.vscode/`** (all at root), **`.gitignore`**, **`.gitmodules`**, and **`AGENTS.md`** (at root). The **`mcp_agent_mail/`** path is a chosen convention; everything else (docs, scripts, bin, TODO.md, .downloads) can be moved if references are updated and the “run from repo root” contract is preserved or adapted.

### 3.1 Other root-mandatory locations (if you add them later)

| Item | Reason |
|------|--------|
| **`.github/`** | GitHub Actions only discovers workflows under `.github/workflows/` at the **repo root**. If the template ever includes CI, `.github` must stay at root. |
| **`README.md`** | Git hosts (GitHub, GitLab, etc.) display the repo's main README from the **root**. If the template adds a README, keeping it at root is expected. |
| **`.editorconfig`** | Many editors look for `.editorconfig` at the **workspace root** when opening files; subfolder-only discovery is not standard. |
| **`.cursorrules`** | Legacy (deprecated) Cursor rule file; still supported **at project root only**. This repo uses `.cursor/rules` and `AGENTS.md` instead. |

### 3.2 How each hard constraint was checked

- **`.cursor/`**: Cursor docs state project rules and MCP live in `.cursor` at the opened folder; no option to point to a subpath.
- **`.vscode/`**: VS Code/Cursor docs: workspace settings are loaded from `.vscode` at the **root of the opened workspace**; no config to use a different path.
- **`.beads/`**: Beads discovers DB from CWD; standard usage is "run `bd` from repo root" → `.beads` must be at root for zero-config.
- **`.gitignore` / `.gitmodules`**: Git behavior; both are read from repo root (or subtree for .gitignore).
- **`AGENTS.md`**: Cursor docs and community: only the **root** AGENTS.md is automatically loaded as project instructions; nested AGENTS.md are not loaded.

---

## 4. Soft constraints (convention or many references)

| Item | Notes |
|------|--------|
| **`TODO.md`** | Convention is root; no hard tool requirement. |
| **(.vscode is hard — see above)** | — |
| **`docs/`** | Referenced from `.cursor/rules/*.mdc`, `AGENTS.md`, and cross-doc links. WORKFLOW, CONVENTIONS, AGENTIC-SAFETY, and AGENT-PROMPTS-BY-KEYWORD now live in `.cursor/rules/`; remaining docs (e.g. MULTI-AGENT-READINESS, AGENT-SWARM-EVALUATION) stay in docs/. Moving docs/ is feasible but requires a global path update. |
| **`scripts/`** | Invoked as `./scripts/ensure_agent_mail.sh` and `./scripts/test_agent_mail.sh` from repo root. Rules say “run `scripts/ensure_agent_mail.sh` from the repo root”. If moved, all invocations and docs must use the new path. |
| **`bin/`** | Referenced as `./bin/bd` or “put workflow/bin on PATH”. Docs and rules mention it. Could live under a single meta dir (e.g. `meta/bin/bd`) with updated references. |
| **`.downloads/`** | Only holds the Beads tarball and readme; `bin/bd` is already extracted. Could be removed from the “live” tree (document “download bd from release”) or merged into a meta dir. |

---

## 5. Options for reducing top-level count

### Option A: Single “meta” or “.workflow” directory (recommended if you consolidate)

- **Idea:** One top-level directory (e.g. `meta` or `.workflow`) contains: `docs/`, `scripts/`, `bin/`, and optionally `.downloads/`. Leave at root: `.beads/`, `.cursor/`, `.gitignore`, `.gitmodules`, `.vscode/`, `mcp_agent_mail/`, `AGENTS.md`, `TODO.md`.
- **Top-level after change:** 6 dirs + 4 files → **10** (save 2: `docs`, `scripts`, `bin` become one). (.vscode stays at root.)
- **Required updates:**
  - **Scripts:** `ensure_agent_mail.sh` and `test_agent_mail.sh` use `REPO_ROOT`; keep `REPO_ROOT` as repo root, but `TEST_SCRIPT` becomes `$REPO_ROOT/meta/scripts/test_agent_mail.sh`, and scripts must be invoked as `./meta/scripts/ensure_agent_mail.sh` (or you add a tiny shim at `scripts/ensure_agent_mail.sh` that calls `meta/scripts/ensure_agent_mail.sh`).
  - **Beads:** Invoke as `./meta/bin/bd` (or add `meta/bin` to PATH); update all docs and rules that say `./bin/bd`.
  - **Docs:** Every reference to `docs/...` becomes `meta/docs/...` (in `.cursor/rules`, `AGENTS.md`, and inside docs).
  - **mcp_agent_mail:** No move; still `$REPO_ROOT/mcp_agent_mail`. No change to `.gitmodules`.
- **STORAGE_ROOT:** In `mcp_agent_mail/.env`, use a path relative to “project root”, e.g. `.agent_mail_mailbox` (already workspace-relative in practice) or document that the user sets it to `<repo_root>/.agent_mail_mailbox` when copying to a new project.
- **Feasibility:** High. Mechanical search-and-replace and a few script path tweaks.

### Option B: Put docs + scripts + bin under `.cursor/`

- **Idea:** `.cursor/docs/`, `.cursor/scripts/`, `.cursor/bin/`. Cursor still sees `.cursor` at root; rules stay in `.cursor/rules/`.
- **Top-level after change:** 5 dirs + 4 files → **9** (save 3). (.vscode stays at root; only docs, scripts, bin move under .cursor.)
- **Required updates:** Same as A for all references to `docs/`, `scripts/`, `bin/`. Plus: some Cursor setups or docs assume `.cursor` is “config only”; putting large doc/script trees there is unusual but valid.
- **Feasibility:** High. Slightly more surprising for people who expect `.cursor` to be small.

### Option C: Move only `.downloads` and merge `bin` into `scripts`

- **Idea:** Remove or archive `.downloads` (document “get bd from release”). Put `bin/bd` inside `scripts/` (e.g. `scripts/bd`) or keep `bin/` but document that it can be a symlink. Then top-level: drop `.downloads` (saving 1), and optionally merge `bin` into `scripts` (saving 1 more).
- **Top-level after change:** 6 or 7 dirs + 4 files.
- **Required updates:** Update every `./bin/bd` → `./scripts/bd` (or keep `bin` and only remove `.downloads`). Beads config and docs that mention “workflow/bin” or “bin/bd”.
- **Feasibility:** High for removing `.downloads`; merging `bin` into `scripts` is a small path change.

### Option D: Minimal change (no structural move)

- **Idea:** Only remove or hide `.downloads` from the “template” (e.g. add to `.gitignore` in template or document “not copied”). Keep all other dirs and files at root.
- **Top-level after change:** 7 dirs + 4 files = **11** (save 1).
- **Feasibility:** Trivial.

---

## 6. Absolute paths and “new project” portability

- **`mcp_agent_mail/.env`:** Contains `STORAGE_ROOT=/home/syadasti/abase/.agent_mail_mailbox`. When copied to a new project, this must not point at the old path. **Options:** (1) Use a relative path if the server supports it (e.g. `.agent_mail_mailbox` relative to CWD when starting the server from repo root). (2) Document that after copy, the user must set `STORAGE_ROOT=<new_repo_root>/.agent_mail_mailbox` or run a one-time setup script that writes `.env` from a template. (3) Add `.env.example` with `STORAGE_ROOT=.agent_mail_mailbox` and document “copy to .env and adjust if needed”.
- **Docs that mention “workflow” or “/home/syadasti/abase”:** e.g. MULTI-AGENT-READINESS, AGENT-MAIL-AND-MCP-LEARNINGS. For a template, these should either be generic (“the project root”, “this repo”) or a placeholder (e.g. `PROJECT_ROOT`) that the user replaces. Already partially done; a pass to replace remaining absolute paths would improve copy-paste portability.

---

## 7. Summary table

| Option | Top-level count (dirs + files) | Saves | Main change |
|--------|--------------------------------|-------|-------------|
| Current | 8 + 4 = **12** | — | — |
| D (drop .downloads) | 7 + 4 = **11** | 1 | Remove or ignore `.downloads` in template |
| C (drop .downloads + merge bin→scripts) | 6 + 4 = **10** | 2 | + merge `bin/` into `scripts/` |
| A (meta dir) | 6 + 4 = **10** | 2 | docs, scripts, bin → `meta/` |
| B (under .cursor) | 5 + 4 = **9** | 3 | docs, scripts, bin → `.cursor/` |

**Theoretical minimum** if we keep current tool semantics: **`.beads`**, **`.cursor`**, **`.vscode`**, **`mcp_agent_mail`**, **`.gitignore`**, **`.gitmodules`**, **AGENTS.md**, **TODO.md** = 6 dirs + 2 files = **8**. Of these, **`.vscode`** and **`AGENTS.md`** cannot be merged elsewhere: the editor only loads workspace settings from `.vscode` at the workspace root, and Cursor only auto-loads AGENTS.md from the project root. So we cannot reduce the number of top-level entries by moving `.vscode` into `.cursor` or `meta`, or by moving AGENTS.md into `docs/`, and still have those apply when the user opens the project root. Everything else (docs, scripts, bin) can be moved; Option B gets to 9 by moving only docs/scripts/bin under `.cursor`.

---

## 8. Recommendation (for when you do move)

- **Safest and clearest:** **Option A** — one top-level `meta/` (or `.workflow/`) with `docs/`, `scripts/`, `bin/`, and optionally `.downloads/`. Keeps `.cursor` as pure config/rules, keeps a single place for “workflow assets” that aren’t Cursor or Beads core. Update all path references in rules, AGENTS.md, and docs; set `REPO_ROOT` in scripts to the repo root and point at `meta/scripts`, `meta/bin`, `meta/docs`.
- **Maximum reduction with one container:** **Option B** — put docs, scripts, and bin under `.cursor/`. You get to 9 top-level entries; only reference updates and possibly a short note in CONVENTIONS that “workflow docs and scripts live under .cursor”.
- **Portability:** Regardless of option, add a one-time or template step so that `mcp_agent_mail/.env` (or `.env.example`) uses a project-root-relative or placeholder `STORAGE_ROOT` when the tree is copied to a new project.

No moves have been performed; this document is analysis only.
