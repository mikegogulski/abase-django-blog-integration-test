#!/usr/bin/env bash
# Output CalVer: YYYY.MM.DD.N
# N = commit count (git rev-list --count HEAD)
# Run from repo root: ./.abase/scripts/version.sh
set -euo pipefail
REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
cd "$REPO_ROOT"
DATE=$(date +%Y.%m.%d)
COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "0")
echo "${DATE}.${COUNT}"
