# Scenario Tests (Classes I, J, K, L, N)

Agent behavior tests using [Scenario](https://langwatch.ai/scenario/). Require:
- `uv add langwatch-scenario pytest`
- `OPENAI_API_KEY` or `ANTHROPIC_API_KEY`

Run: `uv run pytest -s .abase/tests/scenario/` from repo root.

These tests are **stubs** that skip when dependencies are missing. To implement fully:
- Create an AgentAdapter that wraps Cursor or a CLI agent
- Use Scenario's UserSimulatorAgent and JudgeAgent
- See docs/abase/ABASE-TESTING-STRATEGY.md
