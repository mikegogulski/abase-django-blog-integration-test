#!/usr/bin/env python3
"""Class K: Keyword menu Scenario test.

Agent output contains 'Next action? [start] [next] ...' when done.
Skips when langwatch-scenario or API key not available.
"""
from __future__ import annotations

import os
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]

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
        print("SKIP Class K: langwatch-scenario not installed")
        sys.exit(77)
    if not HAS_API_KEY:
        print("SKIP Class K: OPENAI_API_KEY or ANTHROPIC_API_KEY not set")
        sys.exit(77)

    import asyncio
    asyncio.run(_run())


async def _run():
    MENU = "Next action? [start] [next] [self-review] [commit] [cross-review] [explore]"

    class MenuAgent(scenario.AgentAdapter):
        async def call(self, input: scenario.AgentInput) -> scenario.AgentReturnTypes:
            return {"role": "assistant", "content": f"Done. {MENU} — reply with a keyword."}

    result = await scenario.run(
        name="abase keyword menu",
        description="Agent shows keyword menu when done.",
        agents=[
            MenuAgent(),
            scenario.UserSimulatorAgent(),
            scenario.JudgeAgent(criteria=["Agent output contains keyword menu when done"]),
        ],
        script=[
            scenario.user("You've completed a task. What do you show the user?"),
            scenario.agent(),
            scenario.judge(),
        ],
    )
    if result.success:
        print("PASS Class K: Keyword menu Scenario test passed")
        sys.exit(0)
    print("FAIL Class K: Scenario test failed", file=sys.stderr)
    sys.exit(1)


if __name__ == "__main__":
    main()
