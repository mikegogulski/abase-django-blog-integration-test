#!/usr/bin/env bash
# Test keyword→prompt mapping in abase-agent-prompts-by-keyword.mdc. Class O.
# Run from repo root: ./.abase/tests/test_keyword_prompts.sh

set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
PROMPTS="$REPO_ROOT/.cursor/rules/abase-agent-prompts-by-keyword.mdc"
cd "$REPO_ROOT"

REQUIRED_KEYWORDS=(start next self-review commit cross-review explore post-compact test-coverage ui-scrutiny ui-deep)

if [[ ! -f "$PROMPTS" ]]; then
  echo "FAIL abase-agent-prompts-by-keyword.mdc not found" >&2
  exit 1
fi

missing=0
for kw in "${REQUIRED_KEYWORDS[@]}"; do
  # Each keyword should have ## keyword section
  if grep -q "## $kw" "$PROMPTS" 2>/dev/null; then
    # Section should have non-empty content (code block or text)
    if awk "/^## $kw/,/^## /" "$PROMPTS" | grep -q '```\|[a-zA-Z]'; then
      echo "PASS keyword $kw has prompt"
    else
      echo "FAIL keyword $kw section empty" >&2
      missing=$((missing + 1))
    fi
  else
    echo "FAIL keyword $kw missing" >&2
    missing=$((missing + 1))
  fi
done

if [[ $missing -gt 0 ]]; then
  echo "FAIL $missing keyword checks failed" >&2
  exit 1
fi

echo "All test_keyword_prompts.sh checks passed."
