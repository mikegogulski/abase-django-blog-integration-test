"""mcp-eval pytest configuration for Agent Mail MCP tests."""
from __future__ import annotations

import os

import pytest

# Skip entire module if mcpevals not installed
try:
    import mcp_eval  # noqa: F401  # from mcpevals package
    HAS_MCPEVALS = True
except ImportError:
    HAS_MCPEVALS = False

pytestmark = pytest.mark.skipif(
    not HAS_MCPEVALS,
    reason="mcpevals not installed (cd .abase && uv sync --extra mcp-eval)",
)
