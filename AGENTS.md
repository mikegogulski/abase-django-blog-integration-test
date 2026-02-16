# Agent Instructions

> **Template:** When copying this repo, replace the project description and deliverable below with your project's values. See `docs/abase-templates/AGENTS-PROJECT-EXAMPLES.md`.

This repo is an **agentic workflow template** run with an **agentic workflow** so that AI agents (and humans) can plan, execute, and hand off work across sessions without losing context.

**Critical:** MCP config is **project-local only**. All MCP servers are configured in **`.cursor/mcp.json`** in this repo. Do not use or change account-level MCP config for this project. See **.cursor/rules/abase-conventions.mdc**.

## Beads: external working memory

We use [Beads](https://debugg.ai/resources/beads-memory-ai-coding-agents-automated-pm-developer-workflows) as a repo-local, git-backed issue/memory store. Agents must use it for continuity and coordination.

**Note:** `br` is non-invasive and never executes git commands. After `br sync --flush-only`, run `git add .beads/ && git commit -m "sync beads"`.

### One-time setup

- Run **`br init`** once per repo if Beads is not yet initialized.

### Every session

1. **Handover context**  
   Session continuity is in `.cursor/rules/abase-handover-context.mdc` (loaded automatically). See `.cursor/rules/abase-handover-management.mdc` for when to create or update it.
2. **Get ready work**  
   Run `br ready --json` (or `br ready`) and pick the next unblocked task.
3. **Claim before coding**  
   `br update <id> --status in_progress --assignee agent/cursor` (or `br update <id> --claim`)
4. **Record discovered work**  
   When you find new tasks while working:  
   `br create "Title" -t task`  
   Link dependencies with `br dep add <new-id> <current-id>`.
5. **Close when done**  
   `br close <id>` (or `br update <id> --status done`)

6. **Bounded runs (safety)**  
   **Default: one bead per run.** After closing a bead, stop and report unless the user explicitly asked for more (e.g. "work through the backlog," "do 3 beads," or the **next** keyword). Do not run forever. If the goal is vague, ask: "One bead or multiple? How many?" then stay within that.

7. **When you need input: show the keyword menu**  
   When you need the user to choose the next action, output: "Next action? [start] [next] [self-review] [commit] [cross-review] [explore] [post-compact] [test-coverage] [ui-scrutiny] [ui-deep] — reply with a keyword." If the user replies with only a keyword, treat it as the prompt in .cursor/rules/abase-agent-prompts-by-keyword.mdc. If using BV, always use `--robot-*` flags; never run `bv` alone (TUI blocks).

You may invoke `br` (and BV when available) and interpret their JSON output. Prefer querying the plan (Beads) over carrying long markdown plans in chat.

## Project goal

- **Deliverable**: the project you build with this template (e.g. a simple Django blog, API, static site); or use as-is for workflow coordination and agent handoffs.
- **Process**: work is tracked in Beads; epics and tasks can be created up front or discovered as we build. Use the rules in `.cursor/rules/` (especially `abase-agentic-workflow.mdc` and any project-specific rules, e.g. `django-blog.mdc` for Django projects).

## Swarms and handoffs

If multiple agents or Cursor sessions work in this repo, they share the same Beads store. Each session: pull latest, run `br ready --json`, claim a task, work, then commit code + Beads changes. No need to paste plans between sessions—the graph is the plan.

For more on the workflow model and concepts, see **.cursor/rules/abase-workflow.mdc**. For safety (bounded runs, default one bead) and the keyword menu, see **.cursor/rules/abase-agentic-safety-and-input.mdc** and **.cursor/rules/abase-agent-prompts-by-keyword.mdc**. For swarm evaluation and minimal copy-pasting, see **docs/abase/AGENT-SWARM-EVALUATION.md**. For what is in place vs missing to use **multiple agents, Agent Mail, Beads, and BV**, see **docs/abase/MULTI-AGENT-READINESS.md**.

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   br sync --flush-only
   git add .beads/
   git commit -m "sync beads"
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session: create or update `.cursor/rules/abase-handover-context.mdc` (see `.cursor/rules/abase-handover-management.mdc`) so the next session has continuity. Optionally say "Create handover" or "Prepare session handover" to trigger the handover flow.

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
