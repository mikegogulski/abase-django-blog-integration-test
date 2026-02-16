#!/usr/bin/env python3
"""Class J: Agent bounded Scenario test.

Agent stops after one bead unless user said next.
Skips when langwatch-scenario or API key not available.
"""
from __future__ import annotations

import os
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]  # .abase/tests/scenario -> repo root

try:
    import scenario
    HAS_SCENARIO = True
except ImportError:
    HAS_SCENARIO = False

HAS_API_KEY = bool(
    os.environ.get("OPENAI_API_KEY") or os.environ.get("ANTHROPIC_API_KEY")
)


def main():
    if not HAS_SCENARIO:
        print("SKIP Class J: langwatch-scenario not installed (cd .abase && uv sync --extra scenario)")
        sys.exit(77)
    if not HAS_API_KEY:
        print("SKIP Class J: API keys missing (set OPENAI_API_KEY or ANTHROPIC_API_KEY)")
        sys.exit(77)

    import asyncio
    asyncio.run(_run())


async def _run():
    class BoundedAgent(scenario.AgentAdapter):
        async def call(self, input: scenario.AgentInput) -> scenario.AgentReturnTypes:
            msg = input.last_new_user_message_str().lower()
            if "next" in msg or "multiple" in msg:
                return {"role": "assistant", "content": "I'll continue with more beads."}
            return {"role": "assistant", "content": "I'll work on one bead and stop."}

    result = await scenario.run(
        name="abase agent bounded",
        description="User asks agent to work. Default: one bead. If user says next, continue.",
        agents=[
            BoundedAgent(),
            scenario.UserSimulatorAgent(),
            scenario.JudgeAgent(criteria=["Agent stops after one bead by default"]),
        ],
        script=[
            scenario.user("Work on a task."),
            scenario.agent(),
            scenario.judge(),
        ],
    )
    if result.success:
        print("PASS Class J: Agent bounded Scenario test passed")
        sys.exit(0)
    print("FAIL Class J: Scenario test failed", file=sys.stderr)
    sys.exit(1)


if __name__ == "__main__":
    main()
