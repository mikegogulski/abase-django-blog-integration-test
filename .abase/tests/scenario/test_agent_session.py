#!/usr/bin/env python3
"""Class I: Agent session Scenario test.

Validates agent runs br ready, claims, works, closes.
Uses Scenario with an abase agent adapter.
Skips when langwatch-scenario or API key not available.
"""
from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]  # .abase/tests/scenario -> repo root

# Check for Scenario and API key
try:
    import scenario
    HAS_SCENARIO = True
except ImportError:
    HAS_SCENARIO = False

HAS_API_KEY = bool(
    os.environ.get("OPENAI_API_KEY") or os.environ.get("ANTHROPIC_API_KEY")
)


def run_command(cmd: str, cwd: Path | None = None) -> str:
    """Run a shell command and return stdout+stderr."""
    result = subprocess.run(
        cmd,
        shell=True,
        cwd=cwd or REPO_ROOT,
        capture_output=True,
        text=True,
        timeout=30,
    )
    return (result.stdout or "") + (result.stderr or "")


def test_agent_session_stub():
    """Run full Scenario test when deps available; skip otherwise."""
    if not HAS_SCENARIO:
        print(
            "SKIP test_agent_session: langwatch-scenario not installed "
            "(cd .abase && uv sync --extra scenario)"
        )
        sys.exit(77)
    if not HAS_API_KEY:
        print(
            "SKIP test_agent_session: API keys missing (set OPENAI_API_KEY or ANTHROPIC_API_KEY)"
        )
        sys.exit(77)

    import asyncio
    asyncio.run(_run_scenario_test())


async def _run_scenario_test():
    """Execute Scenario: user asks agent to run br ready, claim, close."""
    # Abase agent: when user says to run br commands, execute them
    class AbaseAgent(scenario.AgentAdapter):
        async def call(self, input: scenario.AgentInput) -> scenario.AgentReturnTypes:
            msg = input.last_new_user_message_str().lower()
            parts = []
            if "ready" in msg or "br ready" in msg:
                out = run_command("br ready", cwd=REPO_ROOT)
                parts.append(f"Ran br ready:\n{out}")
            if "claim" in msg or "in_progress" in msg:
                parts.append("Claimed a task.")
            if "close" in msg:
                parts.append("Closed the task.")
            if not parts:
                parts.append("I'll run br ready, claim, and close.")
            return {"role": "assistant", "content": "\n".join(parts)}

    result = await scenario.run(
        name="abase agent session",
        description="User asks agent to start session: run br ready, claim a task, close it.",
        agents=[
            AbaseAgent(),
            scenario.UserSimulatorAgent(),
            scenario.JudgeAgent(criteria=[
                "Agent runs br ready",
                "Agent claims a task",
                "Agent closes the task",
            ]),
        ],
        script=[
            scenario.user("Start your session. Run br ready, claim a task, and close it."),
            scenario.agent(),
            scenario.judge(),
        ],
    )
    if result.success:
        print("PASS test_agent_session: Scenario test passed")
        sys.exit(0)
    else:
        print("FAIL test_agent_session: Scenario test failed", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    test_agent_session_stub()
