#!/usr/bin/env bash
# Test handover document structure. Class G.
# Run from repo root: ./.abase/tests/test_handover_structure.sh

set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
HANDOVER="$REPO_ROOT/.cursor/rules/abase-handover-context.mdc"
cd "$REPO_ROOT"

if [[ ! -f "$HANDOVER" ]]; then
  echo "FAIL abase-handover-context.mdc not found" >&2
  exit 1
fi

REQUIRED_SECTIONS=(
  "## Project Overview"
  "## Key Locations"
  "## Work Completed"
  "## Environment"
  "## Last"
  "## Pending"
)

missing=0
for section in "${REQUIRED_SECTIONS[@]}"; do
  if grep -q "$section" "$HANDOVER" 2>/dev/null; then
    echo "PASS section $section present"
  else
    echo "FAIL section $section missing" >&2
    missing=$((missing + 1))
  fi
done

# Frontmatter
if grep -q "alwaysApply: true" "$HANDOVER" 2>/dev/null; then
  echo "PASS alwaysApply in frontmatter"
else
  echo "FAIL alwaysApply should be true" >&2
  ((missing++)) || true
fi

# Archive dir format (handover-management says handover-YYYYMMDDTHHMMSS.mdc)
if [[ -d "$REPO_ROOT/.cursor/handover-archive" ]]; then
  for f in "$REPO_ROOT/.cursor/handover-archive"/handover-*.mdc; do
    [[ -f "$f" ]] || continue
    base=$(basename "$f" .mdc)
    if [[ "$base" =~ ^handover-[0-9]{8}T[0-9]{6}$ ]]; then
      echo "PASS archive format: $base"
      break
    fi
  done
fi

if [[ $missing -gt 0 ]]; then
  echo "FAIL $missing structure checks failed" >&2
  exit 1
fi

echo "All test_handover_structure.sh checks passed."
