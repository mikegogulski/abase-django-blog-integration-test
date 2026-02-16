# abase Framework Tests

P0 and P1 tests for the abase framework. See `docs/abase/ABASE-TESTING-STRATEGY.md`.

## Structure

- `test_common.sh` — Library: REPO_ROOT, pass(), fail(), skip(); sourced by test scripts
- `mock_health_server.py` — HTTP server returning 200 on `/health/readiness` (for script tests)
- `test_test_agent_mail.sh` — Tests `.abase/scripts/test_agent_mail.sh` against mock server (A, C)
- `test_ensure_agent_mail.sh` — Tests `.abase/scripts/ensure_agent_mail.sh` (mocked dependencies) (A)
- `test_beads_cli.sh` — Tests br/bd create, list, ready (B)
- `test_rules_presence.sh` — Tests abase-*.mdc exist, handover ref (E)
- `test_skills_presence.sh` — Tests SKILL.md, symlinks (F)
- `test_handover_structure.sh` — Tests handover sections, archive format (G)
- `test_config.sh` — Tests no-daemon, mcp.json (H)
- `test_keyword_prompts.sh` — Tests keyword→prompt mapping (O)
- `run_tests.sh` — Run all tests

## Usage

From repo root:

```bash
./.abase/tests/run_tests.sh
```

Requires: `bash`, `curl`, `python3` (for mock server).

**Port conflicts:** Tests A and C start a mock HTTP server on ports 19876 and 19877. If Agent Mail or another service uses those ports, set `MOCK_PORT=29876` (or another free port) before running.

---

## Test Requirement Classes and Recommended Tools

Each class of testable requirement maps to a recommended tool. Full analysis: `docs/abase/TEST-REQUIREMENTS-VS-FRAMEWORKS.md`.

### Tools (links and summaries)

| Tool | Link | Summary |
|------|------|---------|
| **bats-core** | [github.com/bats-core/bats-core](https://github.com/bats-core/bats-core) | Bash Automated Testing System. TAP-compliant; `@test` syntax; `run` captures output; `setup`/`teardown`; native bash/CLI testing. |
| **mcp-eval** | [mcp-eval.ai](https://mcp-eval.ai/) | MCP server and agent testing. Connects agent to MCP server; asserts tool calls, sequences, params; pytest/decorator/dataset styles; OpenTelemetry. |
| **Scenario** | [langwatch.ai/scenario](https://langwatch.ai/scenario/) | Agent simulation framework. Multi-turn, policy-aware scenarios; user simulation; framework-agnostic; assert output at any turn. |

### Per-class recommendation

**Model** (Anthropic/OpenAI): Only for mcp-eval and Scenario tests (agent is SUT). **Claude 3.5 Sonnet** recommended for reliability (MCP tool use, instruction following, coding workflow). Fallback: GPT-4o.

| Class | Best tool | Model | What to test |
|-------|-----------|-------|--------------|
| **A. Scripts** | bats-core | — | test_agent_mail exit codes; ensure_agent_mail retry; env vars |
| **B. Beads CLI** | bats-core | — | br create, update, list, ready, link, close; JSONL schema |
| **C. Agent Mail HTTP** | bats-core | — | GET /health/readiness 200 (mock server) |
| **D. Agent Mail MCP** | mcp-eval | Claude 3.5 Sonnet | MCP tools: register, reserve, announce, inbox, release |
| **E. Rules presence** | bats-core | — | abase-*.mdc exist; cross-refs |
| **F. Skills presence** | bats-core | — | SKILL.md; symlinks |
| **G. Handover structure** | bats-core | — | Section headers; archive format |
| **H. Config** | bats-core | — | no-daemon; mcp.json |
| **I. Agent session** | Scenario | Claude 3.5 Sonnet | bd ready → claim → work → close |
| **J. Agent bounded** | Scenario | Claude 3.5 Sonnet | One bead default; stop unless "next" |
| **K. Keyword menu** | Scenario | Claude 3.5 Sonnet | Output contains "Next action? [start] [next] ..." |
| **L. Agent Mail behavior** | Scenario | Claude 3.5 Sonnet | Agent runs ensure/test when needed |
| **M. Multi-agent MCP** | mcp-eval | Claude 3.5 Sonnet | Reserve, announce, inbox tool usage |
| **N. Landing the plane** | Scenario | Claude 3.5 Sonnet | git pull, bd sync, git push; handover |
| **O. Keyword→prompt** | bats-core | — | Each keyword has prompt in mdc |

**P0 scope (current):** A, B, C, E, F, G, H, O. **Later:** D, M (mcp-eval); I, J, K, L, N (Scenario).
