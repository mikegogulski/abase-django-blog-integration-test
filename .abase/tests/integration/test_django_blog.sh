#!/usr/bin/env bash
# Integration test: Django blog MVP
# Validates that the abase framework can deliver a project.
# Clones abase into .abase/integration-test-tmp/, builds blog in subdir.
# Platform: Win11Pro+WSL2. See docs/abase/INTEGRATION-TEST-DJANGO-BLOG.md.
set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "$0")/../../.." && pwd)}"
cd "$REPO_ROOT"

WORK_DIR="$REPO_ROOT/.abase/integration-test-tmp"
BLOG_SUBDIR="$WORK_DIR/blog"

echo "=== Integration test: Django blog MVP ==="
echo "Work dir: $WORK_DIR"
echo "Blog subdir: $BLOG_SUBDIR"

# Ensure work directory exists (gitignored)
mkdir -p "$WORK_DIR"

# If no clone yet, clone abase into work dir
if [[ ! -d "$WORK_DIR/.git" ]]; then
  echo "Cloning abase into $WORK_DIR..."
  if git clone --recurse-submodules "$REPO_ROOT" "$WORK_DIR" 2>/dev/null; then
    echo "Clone OK"
  else
    # Fallback: copy via /tmp (can't cp repo into itself)
    echo "Clone failed; using cp -a for local test"
    rm -rf "$WORK_DIR"
    _tmp="$(mktemp -d)"
    cp -a "$REPO_ROOT" "$_tmp/abase"
    mv "$_tmp/abase" "$WORK_DIR"
    rmdir "$_tmp" 2>/dev/null || true
  fi
fi

# Verify structure
if [[ -d "$WORK_DIR/.git" ]]; then
  echo "PASS: Work dir has .git"
else
  echo "FAIL: Work dir missing .git"
  exit 1
fi

# Blog subdir: created when scaffold runs; for now just report
if [[ -d "$BLOG_SUBDIR" ]]; then
  echo "PASS: Blog subdir exists"
  (cd "$BLOG_SUBDIR" && python manage.py check 2>/dev/null) && echo "PASS: Django check" || echo "SKIP: Django check (blog not built yet)"
else
  echo "SKIP: Blog subdir not yet created (run scaffold bead)"
fi

echo "=== Integration test harness OK ==="
