#!/usr/bin/env bash
# Test skills presence and structure. Class F.
# Run from repo root: ./.abase/tests/test_skills_presence.sh

. "$(dirname "$0")/test_common.sh"
cd "$REPO_ROOT"

SKILLS="$REPO_ROOT/.agents/skills"
[[ -d "$SKILLS" ]] || skip "test_skills_presence.sh: .agents/skills not found"

missing=0
for dir in "$SKILLS"/*/; do
  [[ -d "$dir" ]] || continue
  name=$(basename "$dir")
  if [[ -f "$dir/SKILL.md" ]]; then
    pass "$name has SKILL.md"
  else
    echo "FAIL $name missing SKILL.md" >&2
    missing=$((missing + 1))
  fi
done

[[ $missing -eq 0 ]] || fail "$missing skills missing SKILL.md"

# .cursor/skills symlinks (if any) should resolve
if [[ -d "$REPO_ROOT/.cursor/skills" ]]; then
  for link in "$REPO_ROOT/.cursor/skills"/*; do
    [[ -e "$link" ]] || continue
    if [[ -L "$link" ]]; then
      target=$(readlink -f "$link" 2>/dev/null || readlink "$link")
      if [[ -d "$target" ]] || [[ -f "$target" ]]; then
        pass "symlink $(basename "$link") resolves"
      else
        echo "FAIL symlink $(basename "$link") broken" >&2
        missing=$((missing + 1))
      fi
    fi
  done
fi

[[ $missing -eq 0 ]] || fail "$missing skills/symlink checks failed"

echo "All test_skills_presence.sh checks passed."
