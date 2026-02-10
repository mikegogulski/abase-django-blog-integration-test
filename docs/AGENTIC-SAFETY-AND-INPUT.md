# Agentic Safety and Input (Keyword Menu)

This doc defines **safety boundaries** for autonomous continuation and a **keyword→prompt** scheme so you don’t have to copy-paste long prompts.

---

## 1. Safety: No Unbounded “Run Forever”

**Principle:** The agent must not start an unbounded run (e.g. “build the Django blog” and then run until stop or “done”) unless you explicitly request it.

### Rules the agent follows

- **Default: one bead per run.** Unless you say otherwise at the start, work on **one** ready bead, then stop and report. Do not auto-continue to the next bead.
- **Explicit continuation.** Only continue to more beads if you have said something like: “work through the backlog,” “do up to 3 beads,” “keep going until no ready work,” or used the **next** keyword (see below).
- **Clarify at session start.** If the goal is vague (e.g. “build the blog”), the agent should ask: “Work on one bead, or multiple? If multiple, how many?” and then proceed within that bound.
- **Stop and report.** After completing the allowed number of beads (or when there are no ready beads), stop and give a short summary. When input is needed, show the **keyword menu** (see below).

These rules are reflected in `.cursor/rules/agentic-workflow.mdc` and AGENTS.md.

---

## 2. Keyword Menu: Less Onerous Than Copy-Paste

**Idea:** Map each “stock” prompt to a short **keyword**. When the agent needs your input, it shows the list of valid keywords; you type the keyword (or run the matching Cursor Command), and the agent receives the corresponding full prompt.

### Keyword → prompt mapping

| Keyword | Purpose | When to use |
|--------|----------|-------------|
| **next** | Move to next bead | After completing a bead; continue with next ready task. |
| **self-review** | Self-review after bead completion | Review your own code for bugs/issues before moving on. |
| **commit** | Commit changes | Commit in logical groups with detailed messages; don’t edit code. |
| **cross-review** | Cross-agent review | Review other agents’/prior code for issues, root causes, fixes. |
| **explore** | Random code exploration | Deep dive into random files, trace flows, find bugs. |
| **post-compact** | Post-compaction | After context compaction; re-anchor on AGENTS.md. |
| **test-coverage** | Add test coverage | Create beads/tasks for unit and e2e test coverage. |
| **ui-scrutiny** | UI/UX scrutiny | Scrutinize workflows for UX improvements, Stripe-level polish. |
| **ui-deep** | Deep UI/UX enhancement | Desktop vs mobile, world-class visual polish. |
| **start** | Initial marching orders | Full session start: read AGENTS.md + README, understand codebase, then proceed with next bead. |

### How to use the menu

When the agent needs your input, it will output something like:

```
Next action? Use one of:
  [start]  [next]  [self-review]  [commit]  [cross-review]  [explore]
  [post-compact]  [test-coverage]  [ui-scrutiny]  [ui-deep]
Reply with the keyword or run the matching command.
```

You then:

- **Option A:** Type the keyword in chat (e.g. `next`). The agent treats it as the corresponding prompt.
- **Option B:** Use a **Cursor Command** that sends the full prompt for that keyword (if you’ve defined commands; see below).
- **Option C:** Run a small **local script** (e.g. `./scripts/agent-prompt next`) that pastes or prints the prompt for you to send.

So the “menu” is: the agent lists valid keywords; you choose one and either type it or trigger the matching command/script.

---

## 3. Feasibility: Cursor Commands vs Script

**Cursor Commands:** Cursor supports custom commands (e.g. in Settings → Rules, Commands). You can define a command per keyword whose “content” is the exact prompt text. Then, when the agent shows the menu, you run that command (e.g. via command palette or a shortcut) and it injects the prompt. So **yes, mapping keywords to prompts via Cursor Commands is feasible.**

**Fallback: script.** If you prefer not to rely on Cursor command setup, a small script in the repo (e.g. `scripts/agent-prompt.sh` or `scripts/agent-prompt.py`) can take a keyword and output the full prompt to stdout (or copy to clipboard). You run `./scripts/agent-prompt next` and paste the result into chat. The agent is instructed to treat a message that is *only* a keyword (e.g. `next`) as a request to execute the corresponding prompt.

**Recommendation:** The keyword list and full prompt text for each keyword are in **docs/AGENT-PROMPTS-BY-KEYWORD.md**. Then either (1) create one Cursor Command per keyword pointing to that text, or (2) add `scripts/agent-prompt` that prints the prompt for a given keyword. Both are feasible and reduce copy-paste to “choose keyword → one action.”

---

## 4. Summary

- **Safety:** One bead by default; multi-bead only when you explicitly say so; agent asks for scope when the goal is vague.
- **Input:** When the agent needs a next step, it shows the **keyword menu**; you reply with a keyword (or run the matching command/script) instead of pasting a long prompt.
- **Feasibility:** Keyword→prompt mapping works via Cursor Commands or a small repo script; both are feasible and recommended.
