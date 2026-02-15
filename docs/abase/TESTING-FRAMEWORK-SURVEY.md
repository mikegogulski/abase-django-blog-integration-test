# Testing Framework Survey for abase

**Created:** 2026-02-15  
**Purpose:** Survey testing frameworks appropriate for a project mixing bash scripts, CLI tools (br/bd), MCP servers (Agent Mail), and agent workflows. Recommend an approach before adding more tests.

---

## 1. Do Agent-Specific Testing Tools Exist?

**Yes.** Several frameworks target AI agents and agentic workflows:

| Framework | Focus | Key features |
|-----------|-------|--------------|
| **[mcp-eval](https://mcp-eval.ai/)** | MCP servers + agents | Tests MCP tool usage, tool call sequences, agent reasoning, error recovery; pytest/decorator/dataset styles; OpenTelemetry; CI/CD |
| **[Scenario](https://langwatch.ai/scenario/)** (LangWatch) | Agent simulations | Unit tests, evaluations, E2E agent simulations; policy-aware scenario generation; Python/TypeScript/Go; framework-agnostic |
| **[Agent Test Platform](https://pypi.org/project/atp-platform/)** (ATP) | Framework-agnostic agents | YAML declarative tests; multi-level eval; JUnit/HTML reports; CI/CD |
| **[MAESTRO](https://arxiv.org/abs/2601.00481)** | Multi-agent systems | Testing, reliability, observability; 12 framework support; system-level metrics |
| **[AgentCompass](https://arxiv.org/abs/2509.14647)** | Production monitoring | Post-deployment; error clustering; root-cause analysis; drift detection |
| **[AgentBeats / AAA](https://docs.agentbeats.org/)** | Agent assessment | A2A + MCP; assessor agents; real-time observability |
| **[Promptfoo](https://www.promptfoo.dev/docs/guides/evaluate-coding-agents/)** | Coding agents | Codex/Claude SDK; cost/latency; LLM-as-judge; sandboxed execution |

**Most relevant for abase:**

- **mcp-eval** — Agent Mail is an MCP server. mcp-eval tests MCP servers and agents that use them: tool definitions, edge cases, agent tool usage, performance. Language-agnostic (tests any MCP server). Pytest integration.
- **Scenario** — For future E2E agent behavior (e.g. Cursor following abase rules). Simulation-based; multi-turn; framework-agnostic.

---

## 2. Shell/CLI Testing: bats-core

For **deterministic** components (bash scripts, `br` CLI), use **bats-core**:

| Criterion | bats-core |
|-----------|-----------|
| **Dependencies** | bats (npm/pkg/brew) |
| **Bash script testing** | Native |
| **Mock HTTP** | External (Python mock server, as in P0) |
| **CLI (br) testing** | `run br list` |
| **CI integration** | TAP output |
| **Community** | Large (~5.8k stars) |

**bats-core** — TAP-compliant, `run` helper, `setup`/`teardown`, bats-assert/bats-support libs. Syntax: `@test "desc" { ... }`.

---

## 3. Project Profile

abase components and test approach:

| Component | Type | Recommended framework |
|-----------|------|------------------------|
| `.abase/scripts/*.sh` | Bash | bats-core |
| `br` / `bd` | CLI | bats-core |
| Agent Mail MCP | MCP server | **mcp-eval** (agent-specific) |
| Agent behavior (future) | Cursor + rules | Scenario or mcp-eval |
| Rules, skills | Markdown | bats-core or simple scripts |

---

## 4. Recommendation

**Two-tier approach:**

1. **Agent/MCP layer:** Use **mcp-eval** for Agent Mail and any agent workflows that use MCP tools. Covers tool usage, sequences, error recovery, performance.
2. **Deterministic layer:** Use **bats-core** for `.abase/scripts/*.sh` and `br` CLI. Covers scripts, health checks, CLI output.

**If mcp-eval (or other agent tools) are not adopted:** Use **bats-core** for all deterministic tests. Current P0 tests (plain bash + Python mock server) can be migrated to bats.

---

## 5. Suggested Structure

```
.abase/
  scripts/              # SUT
  tests/
    mock_health_server.py    # HTTP mock (keep)
    test_agent_mail.bats     # bats: test_agent_mail.sh
    test_ensure_agent_mail.bats
    test_br_cli.bats         # bats: br create, list, ready
    mcp/                     # Optional: mcp-eval tests for Agent Mail
      test_agent_mail_server.py
```

---

## 6. bats-core Installation

- **Linux:** `sudo apt install bats` or `npm install -g bats`
- **macOS:** `brew install bats-core`
- **From source:** https://github.com/bats-core/bats-core

**Optional:** bats-assert, bats-support for richer assertions.

---

## 7. References

**Agent-specific:**
- [mcp-eval](https://mcp-eval.ai/)
- [Scenario (LangWatch)](https://langwatch.ai/scenario/)
- [Agent Test Platform](https://pypi.org/project/atp-platform/)
- [Promptfoo: Evaluate Coding Agents](https://www.promptfoo.dev/docs/guides/evaluate-coding-agents/)

**Shell:**
- [bats-core](https://github.com/bats-core/bats-core)
- [bats-core docs](https://bats-core.readthedocs.io/)
