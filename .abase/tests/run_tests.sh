#!/usr/bin/env bash
# Run all abase P0 tests. Invoke from repo root: ./.abase/tests/run_tests.sh

set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
cd "$REPO_ROOT"

PASSED=0
FAILED=0

run_one() {
  if "$@"; then
    ((PASSED++)) || true
    return 0
  else
    ((FAILED++)) || true
    return 1
  fi
}

echo "=== abase P0 tests ==="
run_one "$REPO_ROOT/.abase/tests/test_test_agent_mail.sh" || true
run_one "$REPO_ROOT/.abase/tests/test_ensure_agent_mail.sh" || true

echo ""
echo "=== Summary: $PASSED passed, $FAILED failed ==="
[[ $FAILED -eq 0 ]]
