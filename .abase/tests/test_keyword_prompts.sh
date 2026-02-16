#!/usr/bin/env bash
# Test keyword→prompt mapping in abase-agent-prompts-by-keyword.mdc. Class O.
# Run from repo root: ./.abase/tests/test_keyword_prompts.sh

. "$(dirname "$0")/test_common.sh"
cd "$REPO_ROOT"

PROMPTS="$REPO_ROOT/.cursor/rules/abase-agent-prompts-by-keyword.mdc"
[[ -f "$PROMPTS" ]] || fail "abase-agent-prompts-by-keyword.mdc not found"

REQUIRED_KEYWORDS=(start next self-review commit cross-review explore post-compact test-coverage ui-scrutiny ui-deep)

missing=0
for kw in "${REQUIRED_KEYWORDS[@]}"; do
  # Each keyword should have ## keyword section
  if grep -q "## $kw" "$PROMPTS" 2>/dev/null; then
    # Section should have non-empty content (code block or text)
    if awk "/^## $kw/,/^## /" "$PROMPTS" | grep -q '```\|[a-zA-Z]'; then
      pass "keyword $kw has prompt"
    else
      echo "FAIL keyword $kw section empty" >&2
      missing=$((missing + 1))
    fi
  else
    echo "FAIL keyword $kw missing" >&2
    missing=$((missing + 1))
  fi
done

[[ $missing -eq 0 ]] || fail "$missing keyword checks failed"

echo "All test_keyword_prompts.sh checks passed."
