#!/usr/bin/env bash
# Test abase config. Class H.
# Run from repo root: ./.abase/tests/test_config.sh

. "$(dirname "$0")/test_common.sh"
cd "$REPO_ROOT"

# Beads: no-daemon true
if [[ -f "$REPO_ROOT/.beads/config.yaml" ]]; then
  grep -q "no-daemon: true" "$REPO_ROOT/.beads/config.yaml" 2>/dev/null || fail ".beads/config.yaml should have no-daemon: true"
  pass ".beads/config.yaml has no-daemon: true"
else
  echo "SKIP .beads/config.yaml not found"
fi

# MCP: project-local .cursor/mcp.json or template
if [[ -f "$REPO_ROOT/.cursor/mcp.json" ]]; then
  pass ".cursor/mcp.json exists (project-local)"
elif [[ -f "$REPO_ROOT/.cursor/mcp.json.template" ]]; then
  pass ".cursor/mcp.json.template exists (copy to mcp.json for MCP)"
else
  fail ".cursor/mcp.json or mcp.json.template should exist"
fi

echo "All test_config.sh checks passed."
