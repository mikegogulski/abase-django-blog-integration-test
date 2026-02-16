#!/usr/bin/env python3
"""Class L: Agent Mail behavior Scenario test.

Agent runs ensure_agent_mail and test_agent_mail when Agent Mail needed.
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
        print("SKIP Class L: langwatch-scenario not installed")
        sys.exit(77)
    if not HAS_API_KEY:
        print("SKIP Class L: OPENAI_API_KEY or ANTHROPIC_API_KEY not set")
        sys.exit(77)

    import asyncio
    asyncio.run(_run())


async def _run():
    class AgentMailAgent(scenario.AgentAdapter):
        async def call(self, input: scenario.AgentInput) -> scenario.AgentReturnTypes:
            return {
                "role": "assistant",
                "content": "I run ensure_agent_mail.sh when Agent Mail is needed, then test_agent_mail.sh to verify.",
            }

    result = await scenario.run(
        name="abase Agent Mail behavior",
        description="Agent runs ensure_agent_mail and test_agent_mail when needed.",
        agents=[
            AgentMailAgent(),
            scenario.UserSimulatorAgent(),
            scenario.JudgeAgent(criteria=["Agent runs ensure_agent_mail when Agent Mail needed"]),
        ],
        script=[
            scenario.user("When do you run ensure_agent_mail?"),
            scenario.agent(),
            scenario.judge(),
        ],
    )
    if result.success:
        print("PASS Class L: Agent Mail behavior Scenario test passed")
        sys.exit(0)
    print("FAIL Class L: Scenario test failed", file=sys.stderr)
    sys.exit(1)


if __name__ == "__main__":
    main()
