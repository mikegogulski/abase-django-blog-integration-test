# Test Requirements vs Framework Capabilities

**Created:** 2026-02-15  
**Purpose:** Extract testable requirements from rules, docs, AGENTS, and skills; map each class to testing framework capabilities.

---

## 1. Extracted Test Requirements by Source

### From AGENTS.md

| Class | Specific requirement |
|-------|----------------------|
| **Beads CLI** | `bd quickstart` initializes repo |
| **Beads CLI** | `bd ready --json` returns unblocked tasks |
| **Beads CLI** | `bd update <id> --status in_progress --assignee agent/cursor` claims task |
| **Beads CLI** | `bd new --title "..." --discovered-from <id>` creates discovered work |
| **Beads CLI** | `bd link --edge blocked_by --src <current> --dst <new-id>` links deps |
| **Beads CLI** | `bd update <id> --status done` closes bead |
| **Beads CLI** | `bd sync` (in landing-the-plane) |
| **Agent behavior** | Agent runs one bead by default, then stops |
| **Agent behavior** | Agent shows keyword menu when done |
| **Agent behavior** | Agent asks "One bead or multiple?" when goal vague |
| **Landing the plane** | `git pull --rebase`, `bd sync`, `git push` sequence |
| **Handover** | Agent creates/updates `abase-handover-context.mdc` when ending session |

### From abase-agent-behavior.mdc

| Class | Specific requirement |
|-------|----------------------|
| **Scripts** | Agent runs `./.abase/scripts/ensure_agent_mail.sh` when Agent Mail needed (does not tell user) |
| **Scripts** | Agent runs `./.abase/scripts/test_agent_mail.sh` to verify Agent Mail |
| **Scripts** | `test_agent_mail.sh` exits 0 when server healthy, non-zero otherwise |
| **Scripts** | `ensure_agent_mail.sh` starts server, polls until ready or 5 attempts |
| **Agent behavior** | Agent troubleshoots up to 5 times before involving user |
| **Agent behavior** | Agent stops after explore/explain/list/show when that's the last ask (no extra fixes) |

### From abase-agentic-workflow.mdc

| Class | Specific requirement |
|-------|----------------------|
| **Handover** | `abase-handover-context.mdc` exists and is always-applied |
| **Beads CLI** | Agent runs `bd ready --json` at session start |
| **Beads CLI** | Agent claims before coding |
| **Beads CLI** | Agent uses `discovered_from` and `bd link` for new work |
| **Agent behavior** | Agent stops after one bead unless user said "next" or multi-bead |
| **Agent behavior** | Agent shows keyword menu when done |

### From abase-agentic-safety-and-input.mdc

| Class | Specific requirement |
|-------|----------------------|
| **Agent behavior** | Keyword menu format: "Next action? [start] [next] [self-review] ..." |
| **Agent behavior** | Agent does not auto-continue without explicit user request |
| **Keywords** | Each keyword maps to correct prompt (from abase-agent-prompts-by-keyword.mdc) |

### From abase-conventions.mdc

| Class | Specific requirement |
|-------|----------------------|
| **Config** | MCP config only in `.cursor/mcp.json` (project-local) |
| **Config** | `.beads/config.yaml` has `no-daemon: true` |
| **Handover** | Handover in `abase-handover-context.mdc`; archive in `handover-archive/` |
| **Docs** | README-ABASE.md updated when framework changes (paths, setup, key paths) |

### From abase-handover-management.mdc

| Class | Specific requirement |
|-------|----------------------|
| **Handover structure** | New handover has: Project Overview, Key Locations, URLs, Work Completed, Environment, Last 3 Tasks, Pending Items |
| **Handover structure** | Frontmatter: `alwaysApply: true`, `description` |
| **Archive** | Archive format: `handover-YYYYMMDDTHHMMSS.mdc` |
| **Archive** | Max 30 archives; oldest deleted when exceeded |

### From abase-multi-agent-agent-mail.mdc

| Class | Specific requirement |
|-------|----------------------|
| **Agent Mail MCP** | Register, reserve, announce, inbox, release flow (when Agent Mail available) |
| **Beads CLI** | `assignee` set when claiming (Agent Mail identity) |
| **Agent behavior** | Agent reserves paths before editing (multi-agent) |

### From abase-project-context.mdc

| Class | Specific requirement |
|-------|----------------------|
| **Config** | MCP project-local only (reiterated) |

### From AGENT-MAIL-SCRIPTS.md

| Class | Specific requirement |
|-------|----------------------|
| **Scripts** | `test_agent_mail.sh`: GET `/health/readiness` 200 → exit 0 |
| **Scripts** | `test_agent_mail.sh`: non-200 or unreachable → exit non-zero |
| **Scripts** | `ensure_agent_mail.sh`: polls `test_agent_mail.sh` every 3s, 5 attempts |
| **Scripts** | `ensure_agent_mail.sh`: uses `mcp_agent_mail/scripts/run_server_with_token.sh` |
| **Scripts** | Env: `AGENT_MAIL_PORT`, `AGENT_MAIL_BASE_URL` |

### From abase-agent-prompts-by-keyword.mdc

| Class | Specific requirement |
|-------|----------------------|
| **Keywords** | start, next, self-review, commit, cross-review, explore, post-compact, test-coverage, ui-scrutiny, ui-deep exist |
| **Keywords** | Each keyword has full prompt text |

### From README-ABASE.md

| Class | Specific requirement |
|-------|----------------------|
| **Paths** | Key paths exist: `.abase/scripts/`, `.beads/`, `.cursor/rules/abase-*.mdc`, etc. |
| **Paths** | `./.abase/scripts/ensure_agent_mail.sh`, `test_agent_mail.sh` executable |

### From .agents/skills/README.md and skills

| Class | Specific requirement |
|-------|----------------------|
| **Skills** | Each skill has `SKILL.md` |
| **Skills** | `.cursor/skills/` symlinks resolve to `.agents/skills/` |
| **Skills** | Skills installable via `npx skills add` |

### From MULTI-AGENT-READINESS.md, AGENT-SWARM-EVALUATION.md

| Class | Specific requirement |
|-------|----------------------|
| **Agent Mail MCP** | Server starts, health endpoint responds |
| **Agent Mail MCP** | MCP tools: register, reserve, announce, inbox, release |
| **Agent behavior** | Multi-agent: pull before `bd ready`, commit code + Beads together |

---

## 2. Consolidated Test Requirement Classes

| Class | Description | Examples |
|-------|-------------|----------|
| **A. Scripts (bash)** | `.abase/scripts/*.sh` behavior | test_agent_mail exit codes; ensure_agent_mail retry; env vars |
| **B. Beads CLI** | `br`/`bd` commands and output | create, update, list, ready, link, close; JSONL schema |
| **C. Agent Mail HTTP** | Health endpoint, server startup | GET /health/readiness 200; ensure + test integration |
| **D. Agent Mail MCP** | MCP tool definitions and behavior | register, reserve, announce, inbox, release; tool params, errors |
| **E. Rules presence/structure** | Files exist, cross-refs, frontmatter | abase-*.mdc present; handover-context referenced; alwaysApply |
| **F. Skills presence/structure** | SKILL.md, symlinks | Each skill has SKILL.md; symlinks valid |
| **G. Handover structure** | Template sections, archive format | Sections present; archive naming; cleanup policy |
| **H. Config** | MCP location, Beads no-daemon | .cursor/mcp.json; .beads/config.yaml |
| **I. Agent behavior (session)** | Agent follows workflow at session level | Runs bd ready; claims; discovers; closes; stops after one |
| **J. Agent behavior (bounded)** | Safety: no unbounded run | One bead default; asks scope if vague; shows menu when done |
| **K. Agent behavior (keyword menu)** | Menu format and content | "Next action? [start] [next] ..." |
| **L. Agent behavior (Agent Mail)** | Agent starts/verifies Agent Mail | Runs ensure_agent_mail; runs test_agent_mail; troubleshoots |
| **M. Agent behavior (multi-agent)** | Reserve, announce, inbox | Reserve before edit; announce by bead ID; check inbox |
| **N. Landing the plane** | Session end workflow | git pull, bd sync, git push; handover update |
| **O. Keyword→prompt mapping** | Keywords invoke correct prompts | "next" → move to next bead prompt |

---

## 3. Framework Capabilities (Summary)

| Framework | Can test |
|-----------|----------|
| **bats-core** | Bash scripts (exit codes, output); CLI commands (br, bd); file presence; env vars; subprocess output |
| **mcp-eval** | MCP server tools (definitions, params, responses); agent tool usage; tool call sequences; error recovery; performance (latency, tokens) |
| **Scenario** | Agent simulations; multi-turn; policy adherence; user simulation; framework-agnostic agent adapter |
| **ATP** | YAML declarative agent tests; multi-level eval; JUnit/HTML |
| **Promptfoo** | Coding agents (Codex/Claude SDK); cost/latency; LLM-as-judge; sandboxed execution |
| **AgentCompass** | Production traces; error clustering; drift detection; root-cause |

---

## 4. Mapping: Requirement Class → Framework

| Class | bats-core | mcp-eval | Scenario | ATP | Promptfoo |
|-------|-----------|----------|----------|-----|-----------|
| **A. Scripts** | ✅ Primary | ❌ | ❌ | ❌ | ❌ |
| **B. Beads CLI** | ✅ Primary | ❌ | ❌ | ❌ | ❌ |
| **C. Agent Mail HTTP** | ✅ (with mock) | ⚠️ Indirect | ❌ | ❌ | ❌ |
| **D. Agent Mail MCP** | ❌ | ✅ Primary | ⚠️ Via adapter | ⚠️ | ❌ |
| **E. Rules presence** | ✅ | ❌ | ❌ | ❌ | ❌ |
| **F. Skills presence** | ✅ | ❌ | ❌ | ❌ | ❌ |
| **G. Handover structure** | ✅ (parse/grep) | ❌ | ❌ | ❌ | ❌ |
| **H. Config** | ✅ (file checks) | ❌ | ❌ | ❌ | ❌ |
| **I. Agent behavior (session)** | ❌ | ⚠️ If agent uses MCP | ✅ Primary | ✅ | ✅ |
| **J. Agent behavior (bounded)** | ❌ | ⚠️ | ✅ Primary | ✅ | ✅ |
| **K. Agent behavior (menu)** | ❌ | ❌ | ✅ (output assert) | ✅ | ✅ |
| **L. Agent behavior (Agent Mail)** | ❌ | ⚠️ Tool usage | ✅ (simulate) | ✅ | ✅ |
| **M. Agent behavior (multi-agent)** | ❌ | ✅ (MCP tools) | ⚠️ Complex | ✅ | ❌ |
| **N. Landing the plane** | ⚠️ (git/cmd only) | ❌ | ✅ (E2E) | ✅ | ✅ |
| **O. Keyword→prompt** | ❌ | ❌ | ⚠️ | ⚠️ | ❌ |

**Legend:** ✅ = well-suited; ⚠️ = partial or indirect; ❌ = not applicable

---

## 5. Gap Analysis

| Gap | Requirement class | bats-core | mcp-eval | Scenario |
|-----|-------------------|-----------|----------|----------|
| **1** | Agent runs `bd ready` at session start | No | No (bd not MCP) | Yes (simulate user, assert agent runs bd) |
| **2** | Agent shows keyword menu when done | No | No | Yes (assert output contains menu) |
| **3** | Agent does not auto-continue | No | No | Yes (policy: stop after one bead) |
| **4** | Agent Mail MCP tools (register, reserve, etc.) | No | Yes | Partial (if agent uses MCP) |
| **5** | Handover structure validation | Yes (grep/sed) | No | No |
| **6** | Keyword→prompt mapping | No | No | Partial (would need to invoke agent with keyword) |

**bats-core** covers A, B, C, E, F, G, H fully.  
**mcp-eval** covers D (Agent Mail MCP) and M (multi-agent MCP usage).  
**Scenario** (or Promptfoo/ATP) covers I, J, K, L, N (agent behavior) but requires running an actual agent.

---

## 6. Recommended Test Allocation

| Class | Framework | Notes |
|-------|-----------|-------|
| A, B, C, E, F, G, H | **bats-core** | Deterministic; no LLM |
| D, M | **mcp-eval** | MCP server + agent MCP usage |
| I, J, K, L, N | **Scenario** or **Promptfoo** | Agent behavior; higher cost, non-deterministic |
| O | Manual / doc test | Keyword→prompt is documentation; could add smoke test that script exists |

**Fallback:** If mcp-eval and Scenario are not adopted, **bats-core** handles A–H. Classes I–O remain untested or require custom tooling.

---

## 7. Per-Class Analysis and Best Tool Recommendation

**Model recommendations** (Anthropic/OpenAI): Classes A, B, C, E, F, G, H, O use bats-core (no LLM). For mcp-eval (D, M) and Scenario (I, J, K, L, N), **Claude 3.5 Sonnet** is recommended for most reliable results: stronger MCP tool use (MCP-Bench), better instruction following and coding workflow (HumanEval, METR autonomy evals). Fallback: GPT-4o for cost/speed.

| Class | Best tool | Model | Rationale | Alternatives |
|-------|-----------|-------|-----------|---------------|
| **A. Scripts (bash)** | **bats-core** | — | Native bash testing; `run` captures exit code and output; `setup`/`teardown` for mock server; TAP for CI. No other tool targets bash scripts as directly. | Plain bash (ad-hoc; no structure) |
| **B. Beads CLI** | **bats-core** | — | `run br create "title"` etc.; assert `$status`, `$output`; fixture `.beads/` in temp dir. CLI testing is bats' strength. | Plain bash |
| **C. Agent Mail HTTP** | **bats-core** | — | Health endpoint is plain HTTP, not MCP. Use existing Python mock server + bats to run `test_agent_mail.sh` against it. mcp-eval targets MCP protocol, not raw HTTP. | — |
| **D. Agent Mail MCP** | **mcp-eval** | Claude 3.5 Sonnet | Purpose-built for MCP servers: tool definitions, params, responses, edge cases. Connects agent to MCP server and asserts tool calls. No other tool specializes in MCP. | Scenario (indirect; via agent) |
| **E. Rules presence** | **bats-core** | — | `[ -f .cursor/rules/abase-agent-behavior.mdc ]`; grep for cross-refs. Simple file/pattern checks. | Custom script |
| **F. Skills presence** | **bats-core** | — | `[ -f .agents/skills/*/SKILL.md ]`; `readlink` for symlinks. File-system assertions. | Custom script |
| **G. Handover structure** | **bats-core** | — | Grep for section headers (`## Project Overview`, etc.); validate archive filename regex. Parsing markdown structure. | Custom script, yq/jq if YAML frontmatter |
| **H. Config** | **bats-core** | — | `grep -q "no-daemon: true" .beads/config.yaml`; check `.cursor/mcp.json` exists or is gitignored. Config validation. | Custom script |
| **I. Agent behavior (session)** | **Scenario** | Claude 3.5 Sonnet | Multi-turn simulation: user says "start", agent runs bd ready, claims, works, closes. Scenario's policy-aware scenarios and output assertions fit. Promptfoo targets coding agents but Scenario is more flexible for workflow behavior. | Promptfoo, ATP |
| **J. Agent behavior (bounded)** | **Scenario** | Claude 3.5 Sonnet | Policy: "agent must stop after one bead unless user said next." Scenario generates scenarios that test policy adherence; critique agent reviews traces. | ATP (YAML policies) |
| **K. Agent behavior (menu)** | **Scenario** | Claude 3.5 Sonnet | Assert agent output contains "Next action?" and keyword list. Scenario evaluates at any point in conversation. | Promptfoo (output assert) |
| **L. Agent behavior (Agent Mail)** | **Scenario** | Claude 3.5 Sonnet | Simulate "need Agent Mail" (e.g. before MCP call); assert agent runs ensure_agent_mail, then test_agent_mail. Scenario can simulate user + verify agent actions. | Promptfoo (if agent has file/run access) |
| **M. Agent behavior (multi-agent)** | **mcp-eval** | Claude 3.5 Sonnet | Reserve, announce, inbox are MCP tool calls. mcp-eval asserts `Expect.tools.was_called("reserve")`, sequence, params. Direct fit for MCP tool usage. | Scenario (complex; multi-agent sim) |
| **N. Landing the plane** | **Scenario** | Claude 3.5 Sonnet | E2E: user says "create handover" or "end session"; assert agent runs git pull, bd sync, git push, updates handover. Scenario's full conversation simulation. | Promptfoo, ATP |
| **O. Keyword→prompt mapping** | **bats-core** | — | Parse `abase-agent-prompts-by-keyword.mdc`; for each keyword (start, next, …), assert corresponding `## keyword` section exists with non-empty prompt block. No agent needed—pure doc validation. | Custom script, grep |

---

## 8. Summary: Best Tool per Class

| Class | Best tool |
|-------|-----------|
| A, B, C, E, F, G, H, O | **bats-core** |
| D, M | **mcp-eval** |
| I, J, K, L, N | **Scenario** |

**Tool count:** 3 (bats-core, mcp-eval, Scenario). bats-core covers 8 classes; mcp-eval covers 2; Scenario covers 5.
