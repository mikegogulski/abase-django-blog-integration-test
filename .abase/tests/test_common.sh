# Common setup and helpers for abase P0 tests.
# Source from test scripts: . "$(dirname "$0")/test_common.sh"

set -euo pipefail

# Repo root (two levels up from .abase/tests/)
_common_dir="${BASH_SOURCE[0]:-$0}"
_common_dir="$(cd "$(dirname "$_common_dir")" && pwd)"
REPO_ROOT="${REPO_ROOT:-$(cd "$_common_dir/../.." && pwd)}"

pass()  { echo "PASS $*"; }
fail()  { echo "FAIL $*" >&2; exit 1; }
skip()  { echo "SKIP $*"; exit 0; }
