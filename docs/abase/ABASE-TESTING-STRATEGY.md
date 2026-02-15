# Testing Strategy for the abase Framework

**Created:** 2026-02-15  
**Bead:** workflow-3l8  
**Purpose:** Research prior work and propose a testing strategy for the abase agentic workflow framework.

---

## 1. Prior Work Summary

### 1.1 Empirical Study: Testing Practices in AI Agent Frameworks

**Source:** [An Empirical Study of Testing Practices in Open Source AI Agent Frameworks and Agentic Applications](https://arxiv.org/html/2509.19185v2) (Hasan et al., 2025)

- **Scope:** 39 agent frameworks, 439 agentic applications
- **Findings:**
  - **10 testing patterns** identified; novel methods (e.g. DeepEval) used in ~1% of tests
  - **Adapted traditional patterns** dominate: Membership Testing, Mock Assertion, Negative Testing to handle FM non-determinism
  - **Testing effort inversion:** >70% on deterministic components (Resource Artifacts/tools, Coordination Artifacts/workflows); <5% on Plan Body; ~1% on Trigger (prompts)
  - **Blind spot:** Prompts/triggers are dangerously under-tested; silent degradation when models change
- **Recommendation:** Framework devs should support novel testing methods; app devs should adopt prompt regression testing

### 1.2 AgentCompass: Production Monitoring

**Source:** [AgentCompass: Towards Reliable Evaluation of Agentic Workflows in Production](https://arxiv.org/abs/2509.14647)

- **Focus:** Post-deployment monitoring and debugging
- **Approach:** Multi-stage pipeline—error identification, categorization, thematic clustering, scoring, summarization
- **Features:** Dual memory (episodic + semantic), pattern-first debugging, root-cause analysis, fix recipes
- **Use case:** Production traces → actionable failure patterns (prompt drift, API latency, retrieval gaps, model version drift)

### 1.3 SWE-bench: Task-Level Benchmarks

**Source:** [SWE-bench](https://github.com/SWE-bench/SWE-bench)

- **Focus:** Can LLMs resolve real-world GitHub issues?
- **Design:** 2,294 problems from 12 Python repos; given codebase + issue, edit code to fix
- **Limitation:** Task success only; does not test robustness, safety, or internal correctness
- **SWE-Bench Pro (2025):** 1,865 harder problems, long-horizon tasks

### 1.4 Promptfoo: Coding Agent Evaluation

**Source:** [Evaluate Coding Agents | Promptfoo](https://www.promptfoo.dev/docs/guides/evaluate-coding-agents/)

- **Focus:** CLI-based coding agents (OpenAI Codex SDK, Claude Agent SDK)
- **Key insight:** Agent evals differ from LLM evals—non-determinism compounds, intermediate steps matter, capability gated by architecture
- **Techniques:** Structured output validation, cost/latency thresholds, `--repeat` for variance, LLM-as-judge rubrics, sandboxed execution
- **Principle:** Test the system, not the model; measure objectively; include baselines

### 1.5 DeepEval: Component-Level Agent Evaluation

**Source:** [AI Agent Evaluation | DeepEval](https://deepeval.com/guides/guides-ai-agent-evaluation)

- **Two-layer model:** Reasoning (LLM plans, tool selection) vs Action (tools, APIs)
- **Evaluates:** Plan quality, scope, dependencies, adherence; 50+ metrics; integrates with LangChain, Pydantic AI, LlamaIndex, LangGraph

### 1.6 LangChain / Scenario

- **LangChain:** Unit tests (deterministic, mocked) + integration tests (real network, credentials)
- **Scenario (langwatch.ai):** Unit, component, and E2E agent simulations; agent-framework agnostic; user simulation

---

## 2. abase Framework Components (Testability)

| Component | Type | Testable? | Notes |
|-----------|------|-----------|-------|
| **Beads (br/bd)** | CLI + JSONL + SQLite | Yes | Deterministic; CLI commands, JSONL schema, sync |
| **Rules (.cursor/rules/abase-*.mdc)** | Markdown files | Partially | Structure, presence, cross-refs; semantics need agent runs |
| **Scripts (ensure_agent_mail, test_agent_mail)** | Bash | Yes | Deterministic; mock or real Agent Mail |
| **Agent Mail MCP** | HTTP server | Yes | Health endpoint, API contract; integration with real server |
| **Skills** | Markdown (SKILL.md) | Partially | Structure, presence; behavior needs agent |
| **Handover** | Markdown (gitignored) | Partially | Template structure; content is per-session |
| **Agent behavior** | Cursor + rules + model | Hard | Non-deterministic; needs scenario-based or E2E evals |

---

## 3. Proposed Testing Strategy

### Tier 1: Deterministic (Unit / Script Tests)

**Goal:** Verify scripts, CLI, and file structure without LLM or network.

1. **Scripts**
   - `.abase/scripts/test_agent_mail.sh`: Mock HTTP (e.g. `nc` or `socat` stub) returning 200 on `/health/readiness`; assert exit 0
   - `.abase/scripts/ensure_agent_mail.sh`: Unit test logic (retry loop, env vars) with mocked `test_agent_mail.sh`

2. **Beads**
   - `br create`, `br update`, `br list`, `br ready` with fixture `.beads/`; assert JSONL and CLI output
   - Schema validation for `issues.jsonl` (required fields, valid statuses)

3. **Rules**
   - Presence check: all `abase-*.mdc` exist
   - Cross-reference lint: `abase-handover-context.mdc` referenced consistently
   - Optional: frontmatter validation (alwaysApply, description)

4. **Skills**
   - Presence of `SKILL.md` in each skill dir
   - Symlinks resolve correctly (`.cursor/skills/` → `.agents/skills/`)

### Tier 2: Integration (Real Services)

**Goal:** Verify Agent Mail and Beads in real environments.

1. **Agent Mail**
   - Start server via `ensure_agent_mail.sh`; run `test_agent_mail.sh`; assert success
   - Optional: MCP tool invocation (if MCP client available in CI)

2. **Beads**
   - Full workflow: `br create` → `br update` → `br close`; verify JSONL and DB consistency

### Tier 3: Scenario / E2E (Agent Behavior)

**Goal:** Verify that an agent following abase rules behaves correctly. Highest effort, most valuable for regression.

**Approach (from prior work):**
- **Promptfoo + Claude Agent SDK:** Run Cursor-like agent in sandbox; give it tasks (e.g. "run br ready, claim a task, close it"); assert on final state and traces
- **Scenario / custom harness:** Simulate user prompts; check that agent runs `br ready`, claims, works, closes; measure cost/latency
- **Membership / Negative testing:** Assert output contains expected patterns (e.g. "claimed", "done"); assert no dangerous commands

**Scenarios to cover:**
- Session start: agent reads handover, runs `br ready`, picks task
- Task lifecycle: claim → work → discover → close
- Bounded continuation: agent stops after one bead unless "next" or multi-bead requested
- Keyword menu: agent outputs menu when done

**Challenges:**
- Non-determinism: run multiple times; use flexible assertions
- Cost: each run can be $0.10–0.50; use sparingly, gate on release

### Tier 4: Production Monitoring (Future)

**Goal:** Detect drift and failures in real usage.

- **AgentCompass-style:** If abase is used in production, collect traces (agent decisions, tool calls, outcomes); cluster failures; detect prompt/model drift
- **Lightweight:** Log `br` commands, Agent Mail usage; alert on anomalies

---

## 4. Implementation Priorities

| Priority | Item | Effort | Impact |
|----------|------|--------|--------|
| P0 | Script tests (test_agent_mail, ensure_agent_mail) with mocked HTTP | Low | High—catches script regressions |
| P0 | Beads CLI tests with fixture repo | Low | High—core workflow |
| P1 | Rules/skills presence and lint | Low | Medium—catches broken refs |
| P2 | Agent Mail integration test (real server) | Medium | High—validates MCP setup |
| P3 | Scenario E2E (Promptfoo or custom) | High | High—validates agent behavior |
| P4 | Production monitoring | Future | Depends on deployment |

---

## 5. Recommended First Steps

1. ~~**Add `scripts/` or `.abase/scripts/test/`**~~ **Done.** P0 script tests in **`.abase/tests/`** (see `.abase/tests/README.md` for per-class tool recommendations and links):
   - `mock_health_server.py` — HTTP server returning 200 on `/health/readiness`
   - `test_test_agent_mail.sh` — Tests `test_agent_mail.sh` (server up → 0, down → 1)
   - `test_ensure_agent_mail.sh` — Tests `ensure_agent_mail.sh` (server already healthy → 0)
   - `run_tests.sh` — Run all P0 script tests
   - Usage: `./.abase/tests/run_tests.sh` from repo root

2. **Add CI job** (e.g. GitHub Actions) that runs `.abase/tests/run_tests.sh` on push.

3. **Document** — See `.abase/tests/README.md`.

4. **Defer** Tier 3 (scenario E2E) until Tier 1–2 are stable; then prototype with Promptfoo or a minimal harness.

---

## 6. References

- [Empirical Study: Testing Practices in AI Agent Frameworks](https://arxiv.org/html/2509.19185v2)
- [AgentCompass: Production Evaluation](https://arxiv.org/abs/2509.14647)
- [SWE-bench](https://github.com/SWE-bench/SWE-bench)
- [Promptfoo: Evaluate Coding Agents](https://www.promptfoo.dev/docs/guides/evaluate-coding-agents/)
- [DeepEval: AI Agent Evaluation](https://deepeval.com/guides/guides-ai-agent-evaluation)
- [Scenario: Agent Testing Framework](https://langwatch.ai/scenario/)
