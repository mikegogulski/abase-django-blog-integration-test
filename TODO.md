# TODO and Follow-up Tasks

This file tracks analysis and evaluation tasks for the workflow project. Each item is a discrete task to be done later.

---

## 1. Analyze bjn/.cursor for generic vs project-specific rules

**Task:** Look in `/home/syadasti/bjn/.cursor` and directories under it. There are rules and doc files there; some apply to coding projects in general, others are specific to the Butlerian Jihad News Django website project.

**Deliverable:**  
- Classify each rule/document as **generic** (applicable to any project) or **specific to BJN**.  
- For each, give a **yes/no recommendation** on whether it should be included in this (workflow / Django blog) project, with brief reason.

**Status:** Split into Beads. Epic **workflow-989** "Analyze bjn/.cursor: generic vs project-specific (TODO #1)" with 33 child tasks (one per file), e.g. **workflow-989.1** … **workflow-989.33**. Work on one file per bead; report classify + recommend per file. Django beads (workflow-2cf, workflow-rjh) are **deferred** until user explicitly requests Django work—see `bd undefer workflow-2cf workflow-rjh` when ready.

---

## 2. Evaluate Ultimate MCP Server

**Task:** Evaluate [https://github.com/Dicklesworthstone/ultimate_mcp_server](https://github.com/Dicklesworthstone/ultimate_mcp_server) (Ultimate Model Context Protocol server: unified access to many tools for AI agents).

**Deliverable:** A recommendation in one of three categories:  
- **Implement soon** — add/integrate in the near term.  
- **Defer** — revisit later (e.g. after Django blog MVP or when adding multi-agent).  
- **Ignore** — not relevant or not worth the cost for this project.

**Status:** Not started.

---

## 3. Evaluate JeffreysPrompts.com

**Task:** Evaluate [https://github.com/Dicklesworthstone/jeffreysprompts.com](https://github.com/Dicklesworthstone/jeffreysprompts.com) (curated prompts + jfp CLI for agentic coding).

**Deliverable:** Same as above: **implement soon**, **defer**, or **ignore**, with focus on whether it can **improve automation continuation** (e.g. fewer copy-pastes, better prompt discipline).

**Status:** Not started.

---

## 4. Evaluate top 30 skills at skills.sh

**Task:** Evaluate the most popular 30 skills at [https://skills.sh/](https://skills.sh/) (All Time leaderboard).

**Deliverable:** For each of the 30 skills:  
- **Include in this project (yes/no)** and short **reason**.  
- **Avoid** skills that require paid services or that are tied to specific providers (e.g. Vercel) unless they are clearly beneficial and provider-agnostic or easy to adapt.

**Status:** Done — see **docs/SKILLS-SH-TOP30-EVALUATION.md**.

---

## 5. Clarifications (optional)

- **Allowed sudo commands:** The project-context rule allows “a few” sudo commands (e.g. `sudo mysql -e '...'`). If you want a strict allow-list, we can add a todo to define and document the full list.
- **Keyword→Cursor Command setup:** If you want Cursor Commands created for each keyword (start, next, self-review, etc.), that can be a short doc or checklist in the repo; no code change required beyond the prompt text already in `docs/AGENT-PROMPTS-BY-KEYWORD.md`.

---

*Last updated when TODO.md was created or last edited.*
