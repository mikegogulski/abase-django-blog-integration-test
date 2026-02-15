#!/usr/bin/env bash
# Test abase config. Class H.
# Run from repo root: ./.abase/tests/test_config.sh

set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
cd "$REPO_ROOT"

# Beads: no-daemon true
if [[ -f "$REPO_ROOT/.beads/config.yaml" ]]; then
  if grep -q "no-daemon: true" "$REPO_ROOT/.beads/config.yaml" 2>/dev/null; then
    echo "PASS .beads/config.yaml has no-daemon: true"
  else
    echo "FAIL .beads/config.yaml should have no-daemon: true" >&2
    exit 1
  fi
else
  echo "SKIP .beads/config.yaml not found"
fi

# MCP: project-local .cursor/mcp.json or template
if [[ -f "$REPO_ROOT/.cursor/mcp.json" ]]; then
  echo "PASS .cursor/mcp.json exists (project-local)"
elif [[ -f "$REPO_ROOT/.cursor/mcp.json.template" ]]; then
  echo "PASS .cursor/mcp.json.template exists (copy to mcp.json for MCP)"
else
  echo "FAIL .cursor/mcp.json or mcp.json.template should exist" >&2
  exit 1
fi

echo "All test_config.sh checks passed."
