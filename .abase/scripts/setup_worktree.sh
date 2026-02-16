#!/usr/bin/env bash
# Create a git worktree for abase. Use for parallel branches (e.g. feature work).
# Run from main repo root: ./.abase/scripts/setup_worktree.sh <branch> [path]
#
# Examples:
#   ./.abase/scripts/setup_worktree.sh feature/auth
#   ./.abase/scripts/setup_worktree.sh fix/beads .cursor/worktrees/abase-fix
#
# After creation: cd into the worktree, run git submodule update --init if needed,
# then open in Cursor. MCP and rules are shared via the worktree's .cursor/.

set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
cd "$REPO_ROOT"

BRANCH="${1:?Usage: $0 <branch> [worktree-path]}"
WT_PATH="${2:-}"

if [[ -z "$WT_PATH" ]]; then
  # Default: .cursor/worktrees/abase-<branch-sanitized>
  SANITIZED=$(echo "$BRANCH" | sed 's/[^a-zA-Z0-9_-]/-/g')
  WT_PATH="$REPO_ROOT/.cursor/worktrees/abase-$SANITIZED"
fi

# Resolve to absolute path if relative
if [[ "$WT_PATH" != /* ]]; then
  WT_PATH="$REPO_ROOT/$WT_PATH"
fi

if [[ -d "$WT_PATH" ]]; then
  echo "ERROR worktree path already exists: $WT_PATH" >&2
  exit 1
fi

mkdir -p "$(dirname "$WT_PATH")"
if git show-ref --verify --quiet "refs/heads/$BRANCH" 2>/dev/null; then
  git worktree add "$WT_PATH" "$BRANCH"
else
  git worktree add "$WT_PATH" -b "$BRANCH"
fi

echo "Worktree created: $WT_PATH (branch: $BRANCH)"
echo ""
echo "Next steps:"
echo "  cd $WT_PATH"
echo "  git submodule update --init   # if .abase/mcp_agent_mail needed"
echo "  # Open $WT_PATH in Cursor"
echo ""
echo "To remove later: git worktree remove $WT_PATH"
