# Agentic Workflow & Documentation

This doc describes how this project uses **agentic workflows**, **Beads** as shared memory, and **swarm-style handoffs** so that building the Django blog stays consistent across sessions and agents.

## Why agentic (and why not only “vibe coding”)

- **Vibe coding**: Human-in-the-loop, prompt-driven. Great for exploration and learning; plans often live in prose and rot; agents “forget” between sessions.
- **Agentic coding**: Goal-driven agents that plan, execute, test, and iterate with less babysitting. Needs **durable, queryable state** so the next run knows what’s done and what’s next.

We aim for **sustainable flow**: short prompts, stable behavior, and work that survives context resets and handoffs. Beads is the substrate for that.

## Beads in one paragraph

**Beads** is a minimal, repo-local “issue tracker” for agents: a git-backed JSONL store plus a CLI (`bd`). Work items have IDs, status, priority, labels, and **edges**: `blocks` / `blocked_by`, `parent_id` (epics), and **`discovered_from`** (causal “this work was found while doing that”). Agents don’t hold the whole plan in context; they **query** it (`bd ready --json`), **claim** a task, **work** it, **file discovered work** with `discovered_from`, and **close** the bead. That gives:

- Explicit, queryable dependencies  
- A **ready set**: unblocked, actionable tasks  
- Session continuity without re-prompting the whole plan  
- An audit trail that lives next to the code in git  

So: **plans as data, not as long markdown**.

## Core loop (single agent)

1. **Session start** → `bd ready --json` → choose a task (e.g. by priority/epic).
2. **Claim** → `bd update --id <id> --status in_progress --assignee agent/cursor`.
3. **Work** → Implement, test, refactor.
4. **Discover** → If new work appears: `bd new ... --discovered-from <id>`, and `bd link` if there are dependencies.
5. **Close** → `bd update --id <id> --status done`.

Repeat. Prompts stay small because the plan is in Beads.

## Swarms and inter-agent communication

- **Swarms** here mean: multiple agents (or Cursor sessions / modes) working in the same repo, sharing the same Beads store.
- **Communication** is through the graph: no separate message bus. One agent marks a bead `done`; the next runs `bd ready --json` and gets follow-on work. `assignee` and `discovered_from` give identity and causality.
- **Handoffs**: Each agent/session works on a branch; commits include both code and Beads file changes. Merge as usual. Optionally use a TTL for `in_progress` so stale claims revert to `open`.

Cross-repo is possible (e.g. `repo://org/name#bd-123`) but not required for this single-repo blog.

## What’s in this repo

| Asset | Purpose |
|-------|--------|
| **`.cursor/rules/agentic-workflow.mdc`** | Always-applied rule: Beads session discipline, claim/discover/close, handoffs. |
| **`.cursor/rules/django-blog.mdc`** | Django conventions (app structure, URLs, views, templates, tests); applied when editing `**/*.py`. |
| **`AGENTS.md`** | Top-level agent instructions: Beads one-time setup, four-step session protocol, project goal, swarms. |
| **`docs/WORKFLOW.md`** (this file) | Human- and agent-readable narrative: vibe vs agentic, Beads, loop, swarms. |

## Next steps for the Django blog

1. **Install Beads** (if you haven’t): get the `bd` CLI and run `bd quickstart` in this repo.
2. **Seed work** (optional): create an epic and a few tasks in Beads for “Django blog MVP” (e.g. project setup, posts app, listing/detail, auth).
3. **Build** with the loop above: every session starts with `bd ready`, claim → work → discover → done.
4. **Optionally** add CI that blocks merge when an epic has open `discovered_from` work (see Beads docs for the exact check).

Once this is in place, you can start the Django blog work with agents (or a swarm) that remember, hand off, and stay aligned with the same plan—without pasting it back into chat each time.

For an evaluation of the [agent-swarm-workflow](https://skills.sh/dicklesworthstone/agent_flywheel_clawdbot_skills_and_integrations/agent-swarm-workflow) style (Beads, BV, Agent Mail, NTM) and alternatives that reduce human-in-the-loop copy-pasting, see **AGENT-SWARM-EVALUATION.md**.
