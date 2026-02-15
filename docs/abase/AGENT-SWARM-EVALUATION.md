# Agent Swarm Workflow: Evaluation & Alternatives

This doc evaluates the [agent-swarm-workflow](https://skills.sh/dicklesworthstone/agent_flywheel_clawdbot_skills_and_integrations/agent-swarm-workflow) style architecture, why it leans human-in-the-loop, and what alternatives exist for **less copy-pasting** and more autonomous operation.

---

## 1. What That Architecture Is

The skills.sh agent-swarm-workflow stacks:

| Layer | Role | Human-in-the-loop? |
|-------|------|---------------------|
| **Beads** | Task graph in repo (`.beads/` JSONL); dependencies, status, `discovered_from`. | No — agents read/write via `bd` (and optionally **BV**). |
| **BV (Beads Viewer)** | Graph-aware triage: PageRank, betweenness, cycles, `--robot-next` / `--robot-triage` for machine-readable “what to do next.” | No — agents call CLI; never run bare `bv` (TUI blocks). |
| **Agent Mail (MCP)** | File reservations + messaging between agents; thread by bead ID. | Optional — human can view UI; coordination is agent-to-agent. |
| **NTM (Named Tmux Manager)** | Spawns multiple tmux sessions/panes (one per agent), **sends prompts** into each. | **Yes — this is where paste lives.** Human runs `ntm send myproject --cc "$(cat next_bead_prompt.txt)"` (and similar) to advance each agent. |
| **Prompt library** | “Initial marching orders,” “Move to next bead,” “Self-review,” “Commit,” “Cross-agent review,” etc. | **Yes — human picks and pastes the next prompt** (or NTM sends from a file). |

So: **Beads + BV + Agent Mail** are agent-facing and automatable. The **paste burden** comes from **NTM + the prompt library**: the loop is “agent finishes → stops → human (or script) sends next prompt → agent continues.” Without that send step, agents would sit idle after each bead.

---

## 2. Why It Feels Heavy on Human-in-the-Loop

- **Explicit prompt phases**: The workflow assumes you’ll paste distinct prompts for: start → next bead → self-review → commit → cross-review → UI/UX pass, etc. That’s by design for control and quality, but it means you’re constantly choosing and sending the “next” prompt.
- **NTM as driver**: NTM doesn’t run the agent logic; it runs tmux and injects text. Something (you or a script) must decide *when* to send *which* prompt. There’s no built-in “when agent finishes bead, auto-send ‘move to next bead’.”
- **Cursor iteration limits**: In Cursor, agent runs can stop after a limited number of steps. So even if you encode “then do the next bead,” the session may end before the agent gets there, and you’re back to pasting a “continue” prompt.

So the architecture is **not** low human-in-the-loop by default; it’s a **powerful but prompt-driven** workflow.

---

## 3. Reducing Paste: What You Can Do Inside Cursor

**A. Encode continuation in rules (single agent)**  
Make the agent **automatically** proceed to the next bead instead of stopping and waiting for a prompt:

- In **AGENTS.md** and **`.cursor/rules/agentic-workflow.mdc`**: add an explicit instruction: *“When you complete a bead (status → done), immediately run `bv --robot-next` (or `bd ready --json` if BV is not installed), claim the next task, and continue working. Do not stop to ask for the next task. Only stop when there are no ready beads or the user tells you to stop.”*
- Effect: You give **one** initial prompt (e.g. “Work through the ready beads for the Django blog”). The agent does bead → done → get next → claim → bead → … until the ready set is empty or you interrupt. No pasting “move to next bead” between beads.
- Limitation: Cursor may still hit step or context limits and end the run; then you’d paste a single “continue from where we left off” prompt (still better than pasting after every bead).

**B. Use BV for “what’s next” (no paste for triage)**  
If you adopt [BV](https://agent-skills.md/skills/Dicklesworthstone/agent_flywheel_clawdbot_skills_and_integrations/bv), the agent doesn’t need you to tell it *which* bead to pick:

- `bv --robot-next` → one top pick + claim command  
- `bv --robot-triage` → recommendations, quick wins, blockers  
- Rule: “Use `bv --robot-next` (or `bv --robot-triage`) to choose work; never run bare `bv` (interactive TUI).”

So **task selection** is already automated; the remaining paste is **phase selection** (next bead vs self-review vs commit), which you can collapse into one “loop” instruction as in (A).

**C. Skip NTM and Agent Mail for a single agent**  
If you run **one** Cursor agent (or one at a time), you don’t need:

- NTM (no multi-session orchestration)
- Agent Mail (no inter-agent file reservations or messaging)

Beads (+ optional BV) is enough for “what’s next” and continuity across sessions. Add Agent Mail when you actually run **multiple concurrent** agents and want reservations/messaging.

---

## 4. Well-Developed Alternatives (Outside the “tmux + paste” Model)

These are established options that avoid “human pastes next prompt after every step.”

| Approach | How it works | Pros | Cons |
|----------|--------------|-----|-----|
| **Rule-driven single agent (Cursor)** | One agent; rules + AGENTS.md say “after each bead, get next and continue.” One initial prompt. | Stays in Cursor, uses your Beads/BV setup, minimal paste. | Step/context limits may cut runs short; no true multi-agent parallelism. |
| **LangGraph / CrewAI / AutoGen** | Programmatic orchestration: state machine or role-based team; LLMs called via API; loop controlled in code (e.g. “complete task → fetch next → call agent again”). | Fully autonomous loop, no pasting; multi-agent and custom tooling. | You’re not in Cursor; you’re in a script/process. Different toolchain (API keys, env, file access). |
| **Cursor’s planner–worker research** | [Scaling long-running autonomous coding](https://cursor.com/blog/scaling-agents): planners create tasks, workers complete them; “weeks-long” runs, many concurrent agents. | Matches Cursor’s own direction; planner/worker split reduces coordination chaos. | Not a product you can install today; “will eventually inform Cursor’s agent capabilities.” |
| **Ralph loop (cursor-ralph)** | Community workaround: when Cursor hits iteration limit, a hook “restarts” the loop so the agent continues. | Extends single-session autonomy inside Cursor. | macOS-only, depends on accessibility/keyboard simulation; brittle. |
| **Aider, Bolt.new, Devin-style tools** | Different UIs or APIs; some have “continue” or background modes. | May offer different autonomy/loop semantics. | Different product and workflow; not the same as Cursor + Beads/BV. |

**Summary**: For **Cursor + this repo**, the main lever is **(A) + (B)**: rule-driven “after bead, get next and continue” plus BV (or `bd ready`) for task choice. That gives you swarm-workflow-style behavior with minimal paste. For **fully autonomous, no-Cursor** pipelines, **LangGraph/CrewAI/AutoGen** are the well-known, programmatic alternatives.

---

## 5. Recommendation for This Repo

- **Keep**: Beads (canonical `bd` from [steveyegge/beads](https://github.com/steveyegge/beads) or compatible), and optionally add **BV** for better triage and `--robot-next` (if you use the flywheel ecosystem’s `.beads/beads.jsonl` and BV).
- **Adopt in rules**: “Autonomous continuation” — after completing a bead, agent runs `bv --robot-next` (or `bd ready --json`), claims the next bead, and continues until no ready work or user says stop. That removes the need to paste “move to next bead” repeatedly.
- **Defer until multi-agent**: Agent Mail and NTM. Add them when you run **multiple concurrent** Cursor (or other) agents and need file reservations and explicit messaging.
- **Optional later**: If you need long, fully autonomous runs outside Cursor, consider a small LangGraph (or similar) harness that uses Beads/BV as the task store and calls an API-based coding agent in a loop; that’s a separate architecture from “Cursor + rules.”

The project’s **AGENTS.md** and **`.cursor/rules/agentic-workflow.mdc`** are updated to include the autonomous-continuation behavior so you can run with minimal copy-pasting from day one.
