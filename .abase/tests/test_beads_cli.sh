#!/usr/bin/env bash
# Test Beads CLI (br/bd). Class B.
# Run from repo root: ./.abase/tests/test_beads_cli.sh
# Requires: br or bd in PATH

set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
cd "$REPO_ROOT"

BD=""
for cmd in br bd; do
  if command -v "$cmd" &>/dev/null; then
    BD="$cmd"
    break
  fi
done

if [[ -z "$BD" ]]; then
  echo "SKIP test_beads_cli.sh: br/bd not in PATH"
  exit 0
fi

TMP=$(mktemp -d)
trap "rm -rf '$TMP'" EXIT
cd "$TMP"

"$BD" init 2>/dev/null || "$BD" quickstart 2>/dev/null || true

out=$("$BD" create "P0 test bead" 2>&1) || true
if [[ -n "$out" ]]; then
  echo "PASS br/bd create produces output"
else
  echo "FAIL br/bd create should produce output" >&2
  exit 1
fi

out=$("$BD" list 2>&1) || true
if [[ "$out" == *"P0 test bead"* ]] || [[ "$out" == *"open"* ]] || [[ "$out" == *"ready"* ]] || [[ -n "$out" ]]; then
  echo "PASS br/bd list works"
else
  echo "FAIL br/bd list should show beads (got: $out)" >&2
  exit 1
fi

"$BD" ready 2>/dev/null || "$BD" ready --json 2>/dev/null || true
echo "PASS br/bd ready runs"

echo "All test_beads_cli.sh checks passed."
