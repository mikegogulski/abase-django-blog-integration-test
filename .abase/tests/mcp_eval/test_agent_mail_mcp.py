"""Class D: Agent Mail MCP tests (mcp-eval).

Tests register, reserve, announce, inbox, release tools.
Requires Agent Mail server running and mcpevals + API key.
"""
from __future__ import annotations

import os

import pytest

try:
    from mcp_eval import Expect
    HAS_MCPEVALS = True
except ImportError:
    HAS_MCPEVALS = False

pytestmark = [
    pytest.mark.skipif(not HAS_MCPEVALS, reason="mcpevals not installed"),
    pytest.mark.skipif(
        not (os.environ.get("ANTHROPIC_API_KEY") or os.environ.get("OPENAI_API_KEY")),
        reason="API keys missing (set ANTHROPIC_API_KEY or OPENAI_API_KEY)",
    ),
    pytest.mark.asyncio,
    pytest.mark.network,
]


@pytest.mark.mcp_agent  # Uses default agent from mcpeval.yaml or mcp-agent.config.yaml
async def test_register_agent(mcp_agent):
    """Verify agent can register with Agent Mail."""
    if mcp_agent is None:
        pytest.skip("mcp_agent fixture not available (Agent Mail not configured)")
    response = await mcp_agent.generate_str(
        "Register an agent named TestAgent for this project. Use the project path."
    )
    await mcp_agent.session.assert_that(
        Expect.tools.was_called("register_agent"),
        name="register_called",
        response=response,
    )
