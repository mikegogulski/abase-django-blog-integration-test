# Agent Instructions

This repo is a **Django blog** project run with an **agentic workflow** so that AI agents (and humans) can plan, execute, and hand off work across sessions without losing context.

**Critical:** MCP config is **project-local only**. All MCP servers are configured in **`.cursor/mcp.json`** in this repo. Do not use or change account-level MCP config for this project. See **docs/CONVENTIONS.md**.

## Beads: external working memory

We use [Beads](https://debugg.ai/resources/beads-memory-ai-coding-agents-automated-pm-developer-workflows) as a repo-local, git-backed issue/memory store. Agents must use it for continuity and coordination.

### One-time setup

- Run **`bd quickstart`** once per repo if Beads is not yet initialized.

### Every session

1. **Get ready work**  
   Run `bd ready --json` (or `bd ready`) and pick the next unblocked task.
2. **Claim before coding**  
   `bd update --id <id> --status in_progress --assignee agent/cursor`
3. **Record discovered work**  
   When you find new tasks while working:  
   `bd new --title "..." --discovered-from <current-id>`  
   Link dependencies with `bd link --edge blocked_by --src <current> --dst <new-id>`.
4. **Close when done**  
   `bd update --id <id> --status done`

5. **Bounded runs (safety)**  
   **Default: one bead per run.** After closing a bead, stop and report unless the user explicitly asked for more (e.g. "work through the backlog," "do 3 beads," or the **next** keyword). Do not run forever. If the goal is vague, ask: "One bead or multiple? How many?" then stay within that.

6. **When you need input: show the keyword menu**  
   When you need the user to choose the next action, output: "Next action? [start] [next] [self-review] [commit] [cross-review] [explore] [post-compact] [test-coverage] [ui-scrutiny] [ui-deep] — reply with a keyword." If the user replies with only a keyword, treat it as the prompt in docs/AGENT-PROMPTS-BY-KEYWORD.md. If using BV, always use `--robot-*` flags; never run `bv` alone (TUI blocks).

You may invoke `bd` (and BV when available) and interpret their JSON output. Prefer querying the plan (Beads) over carrying long markdown plans in chat.

## Project goal

- **Deliverable**: a simple Django blog (posts, optional auth, listing/detail pages, clean structure).
- **Process**: work is tracked in Beads; epics and tasks can be created up front or discovered as we build. Use the rules in `.cursor/rules/` (especially `agentic-workflow.mdc` and `django-blog.mdc`) for workflow and Django conventions.

## Swarms and handoffs

If multiple agents or Cursor sessions work in this repo, they share the same Beads store. Each session: pull latest, run `bd ready --json`, claim a task, work, then commit code + Beads changes. No need to paste plans between sessions—the graph is the plan.

For more on the workflow model and concepts, see **docs/WORKFLOW.md**. For safety (bounded runs, default one bead) and the keyword menu for input, see **docs/AGENTIC-SAFETY-AND-INPUT.md** and **docs/AGENT-PROMPTS-BY-KEYWORD.md**. For swarm evaluation and minimal copy-pasting, see **docs/AGENT-SWARM-EVALUATION.md**. For what is in place vs missing to use **multiple agents, Agent Mail, Beads, and BV**, see **docs/MULTI-AGENT-READINESS.md**.

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
