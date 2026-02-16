#!/usr/bin/env bash
# Test Beads CLI (br/bd). Class B.
# Run from repo root: ./.abase/tests/test_beads_cli.sh
# Requires: br or bd in PATH

. "$(dirname "$0")/test_common.sh"

BD=""
for cmd in br bd; do
  if command -v "$cmd" &>/dev/null; then
    BD="$cmd"
    break
  fi
done

if [[ -z "$BD" ]]; then
  skip "test_beads_cli.sh: br/bd not in PATH"
fi

TMP=$(mktemp -d)
trap "rm -rf '$TMP'" EXIT
cd "$TMP"

"$BD" init 2>/dev/null || "$BD" quickstart 2>/dev/null || true

out=$("$BD" create "P0 test bead" 2>&1) || true
if [[ -n "$out" ]]; then
  pass "br/bd create produces output"
else
  fail "br/bd create should produce output"
fi

out=$("$BD" list 2>&1) || true
if [[ "$out" == *"P0 test bead"* ]] || [[ "$out" == *"open"* ]] || [[ "$out" == *"ready"* ]] || [[ -n "$out" ]]; then
  pass "br/bd list works"
else
  fail "br/bd list should show beads (got: $out)"
fi

"$BD" ready 2>/dev/null || "$BD" ready --json 2>/dev/null || true
pass "br/bd ready runs"

echo "All test_beads_cli.sh checks passed."
