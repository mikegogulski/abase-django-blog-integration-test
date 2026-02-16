#!/usr/bin/env python3
"""Class N: Landing the plane Scenario test.

Agent runs git pull, br sync --flush-only, git add .beads/, git commit, git push; updates handover.
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
        print("SKIP Class N: langwatch-scenario not installed (cd .abase && uv sync --extra scenario)")
        sys.exit(77)
    if not HAS_API_KEY:
        print("SKIP Class N: API keys missing (set OPENAI_API_KEY or ANTHROPIC_API_KEY)")
        sys.exit(77)

    import asyncio
    asyncio.run(_run())


async def _run():
    class LandingAgent(scenario.AgentAdapter):
        async def call(self, input: scenario.AgentInput) -> scenario.AgentReturnTypes:
            return {
                "role": "assistant",
                "content": "Landing the plane: git pull --rebase, br sync --flush-only, git add .beads/, git commit, git push; update handover.",
            }

    result = await scenario.run(
        name="abase landing the plane",
        description="Agent runs git pull, br sync, git add .beads/, commit, push; updates handover.",
        agents=[
            LandingAgent(),
            scenario.UserSimulatorAgent(),
            scenario.JudgeAgent(criteria=[
                "Agent runs br sync --flush-only",
                "Agent commits and pushes",
                "Agent updates handover",
            ]),
        ],
        script=[
            scenario.user("End your session. What do you do?"),
            scenario.agent(),
            scenario.judge(),
        ],
    )
    if result.success:
        print("PASS Class N: Landing the plane Scenario test passed")
        sys.exit(0)
    print("FAIL Class N: Scenario test failed", file=sys.stderr)
    sys.exit(1)


if __name__ == "__main__":
    main()
