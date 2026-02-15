#!/usr/bin/env bash
# Test skills presence and structure. Class F.
# Run from repo root: ./.abase/tests/test_skills_presence.sh

set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
SKILLS="$REPO_ROOT/.agents/skills"
cd "$REPO_ROOT"

if [[ ! -d "$SKILLS" ]]; then
  echo "SKIP test_skills_presence.sh: .agents/skills not found"
  exit 0
fi

missing=0
for dir in "$SKILLS"/*/; do
  [[ -d "$dir" ]] || continue
  name=$(basename "$dir")
  if [[ -f "$dir/SKILL.md" ]]; then
    echo "PASS $name has SKILL.md"
  else
    echo "FAIL $name missing SKILL.md" >&2
    missing=$((missing + 1))
  fi
done

if [[ $missing -gt 0 ]]; then
  echo "FAIL $missing skills missing SKILL.md" >&2
  exit 1
fi

# .cursor/skills symlinks (if any) should resolve
if [[ -d "$REPO_ROOT/.cursor/skills" ]]; then
  for link in "$REPO_ROOT/.cursor/skills"/*; do
    [[ -e "$link" ]] || continue
    if [[ -L "$link" ]]; then
      target=$(readlink -f "$link" 2>/dev/null || readlink "$link")
      if [[ -d "$target" ]] || [[ -f "$target" ]]; then
        echo "PASS symlink $(basename "$link") resolves"
      else
        echo "FAIL symlink $(basename "$link") broken" >&2
        missing=$((missing + 1))
      fi
    fi
  done
fi

echo "All test_skills_presence.sh checks passed."
