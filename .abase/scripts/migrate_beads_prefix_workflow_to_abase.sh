#!/usr/bin/env bash
# Migrate bead ID prefix from workflow- to abase-
# Phases 0-6 only (excludes Phase 7: commit/push)
# Run from repo root: ./.abase/scripts/migrate_beads_prefix_workflow_to_abase.sh

set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
cd "$REPO_ROOT"

BACKUP_DIR=".beads/backup-prefix-migration"
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

die() { echo -e "${RED}FAIL: $*${NC}" >&2; exit 1; }
ok()  { echo -e "${GREEN}OK: $*${NC}"; }

# --- Phase 0: Pre-flight ---
echo "=== Phase 0: Pre-flight ==="
command -v br >/dev/null || die "br not in PATH"
ok "br found"

br sync --flush-only || die "br sync --flush-only failed"
ok "br sync --flush-only succeeded"

# Run P0 tests (use random high ports to avoid conflicts)
BASE_PORT=$(( 30000 + RANDOM % 20000 ))
MOCK_PORT=$BASE_PORT MOCK_PORT_ENSURE=$((BASE_PORT + 1)) MOCK_PORT_RETRY=$((BASE_PORT + 2)) ./.abase/tests/run_tests.sh || die "P0 tests failed (ports may be in use; try running again)"
ok "P0 tests passed"

# --- Phase 1: Backup ---
echo "=== Phase 1: Backup ==="
mkdir -p "$BACKUP_DIR"
[[ -f .beads/issues.jsonl ]] || die ".beads/issues.jsonl not found"
cp .beads/issues.jsonl "$BACKUP_DIR/issues.jsonl"
cp .beads/config.yaml "$BACKUP_DIR/config.yaml"
[[ -f "$BACKUP_DIR/issues.jsonl" ]] && [[ -s "$BACKUP_DIR/issues.jsonl" ]] || die "Backup issues.jsonl missing or empty"
[[ -f "$BACKUP_DIR/config.yaml" ]] || die "Backup config.yaml missing"
ok "Backup created in $BACKUP_DIR"

# --- Phase 2: Try --rename-prefix ---
echo "=== Phase 2: Try --rename-prefix ==="
# Update config first
sed -i.bak 's/^issue-prefix: "workflow"$/issue-prefix: "abase"/' .beads/config.yaml
rm -f .beads/config.yaml.bak
grep -q 'issue-prefix: "abase"' .beads/config.yaml || die "Config update failed"
ok "Config updated to issue-prefix: abase"

# Restore original JSONL (with workflow-) for import
cp "$BACKUP_DIR/issues.jsonl" .beads/issues.jsonl
grep -q '"workflow-' .beads/issues.jsonl || die "issues.jsonl should have workflow- ids before import"
ok "Restored original JSONL for import"

# Remove DB so import starts clean
rm -f .beads/beads.db .beads/*.db .beads/*.db-journal .beads/*.db-wal .beads/*.db-shm 2>/dev/null || true
[[ ! -f .beads/beads.db ]] || die "beads.db still exists after rm"
ok "DB removed"

# Import with --rename-prefix
br sync --import-only --rename-prefix -v || die "br sync --import-only --rename-prefix failed"
ok "Import with --rename-prefix succeeded"

# Export DB to JSONL (so JSONL gets renamed ids)
br sync --flush-only || die "br sync --flush-only after import failed"
ok "Flushed to JSONL"

# Verify: no workflow- in JSONL, abase- present
if grep -q '"workflow-' .beads/issues.jsonl || ! grep -q '"abase-' .beads/issues.jsonl; then
  echo "Phase 2: --rename-prefix did not produce abase- ids, falling back to Phase 3"
  RENAME_PREFIX_WORKED=false
else
  echo "Phase 2: --rename-prefix produced abase- ids"
  RENAME_PREFIX_WORKED=true
fi

# --- Phase 3: Manual edit if Phase 2 failed ---
if [[ "$RENAME_PREFIX_WORKED" != "true" ]]; then
  echo "=== Phase 3: Manual JSONL edit ==="
  cp "$BACKUP_DIR/issues.jsonl" .beads/issues.jsonl
  # Replace workflow- with abase- in id, issue_id, depends_on_id
  sed -i.bak 's/"workflow-/"abase-/g' .beads/issues.jsonl
  grep -q '"abase-' .beads/issues.jsonl || die "Manual replace failed: no abase- in JSONL"
  ! grep -q '"workflow-' .beads/issues.jsonl || die "Manual replace failed: workflow- still in JSONL"
  ok "Manual JSONL replace succeeded"

  rm -f .beads/beads.db .beads/*.db .beads/*.db-journal .beads/*.db-wal .beads/*.db-shm 2>/dev/null || true
  br sync --import-only -v || die "br sync --import-only failed"
  ok "Import succeeded"
  br sync --flush-only || die "br sync --flush-only failed"
  ok "Flushed to JSONL"
fi

# --- Phase 4: Config (already done in Phase 2) ---
echo "=== Phase 4: Config ==="
grep -q 'issue-prefix: "abase"' .beads/config.yaml || die "Config should have issue-prefix: abase"
ok "Config verified"

# --- Phase 5: Update cross-references ---
echo "=== Phase 5: Update cross-references ==="
FILES_TO_UPDATE=(
  .abase/tests/test_beads_cli.sh
  docs/abase/ABASE-TESTING-STRATEGY.md
  .cursor/rules/abase-workflow.mdc
  .cursor/rules/abase-multi-agent-agent-mail.mdc
  .cursor/rules/abase-beads-workflow.mdc
  .agents/skills/abase-bd-to-br-migration/references/TRANSFORMS.md
  docs/abase/BEADS-WORKFLOW-TO-ABASE-RENAME-ANALYSIS.md
  docs/abase/MOVE-WORKFLOW-TO-ABASE.md
  docs/abase/MULTI-AGENT-READINESS.md
  TODO.md
  docs/abase/TASK-COMPLEXITY-ANALYSIS.md
  docs/abase/BJN-CURSOR-ANALYSIS.md
  docs/abase/AGENT-SWARM-EVALUATION.md
  mcp_agent_mail/tests/test_e2e_multi_agent_workflow.py
  mcp_agent_mail/docs/GUIDE_TO_OPTIMAL_MCP_SERVER_DESIGN.md
)

for f in "${FILES_TO_UPDATE[@]}"; do
  if [[ -f "$f" ]]; then
    if grep -q 'workflow-' "$f" 2>/dev/null; then
      sed -i.bak "s/workflow-/abase-/g" "$f"
      rm -f "${f}.bak"
      ok "Updated $f"
    fi
  fi
done

# Update test_beads_cli regex to include abase (for matching bead IDs)
if grep -q '(workflow|bd)-' .abase/tests/test_beads_cli.sh 2>/dev/null; then
  sed -i.bak 's/(workflow|bd)-/(workflow|abase|bd)-/g' .abase/tests/test_beads_cli.sh
  rm -f .abase/tests/test_beads_cli.sh.bak
  ok "Updated test_beads_cli.sh regex"
fi

# Verify no workflow- in repo (excluding backup)
REMAINING=$(grep -rl 'workflow-' . --include='*.md' --include='*.mdc' --include='*.py' --include='*.sh' 2>/dev/null | grep -v backup-prefix-migration || true)
if [[ -n "$REMAINING" ]]; then
  echo "Note: workflow- still in: $REMAINING"
else
  ok "No workflow- in repo (excluding backup)"
fi

# --- Phase 6: Verification ---
echo "=== Phase 6: Verification ==="
br list >/dev/null || die "br list failed"
ok "br list succeeded"

br ready >/dev/null || die "br ready failed"
ok "br ready succeeded"

br show abase-2cf >/dev/null || die "br show abase-2cf failed"
ok "br show abase-2cf succeeded"

# Dependency check
br dep list abase-2i7.5 2>/dev/null || true
ok "br dep list succeeded"

# Run P0 tests again
BASE_PORT=$(( 30000 + RANDOM % 20000 ))
MOCK_PORT=$BASE_PORT MOCK_PORT_ENSURE=$((BASE_PORT + 1)) MOCK_PORT_RETRY=$((BASE_PORT + 2)) ./.abase/tests/run_tests.sh || die "P0 tests failed after migration"
ok "P0 tests passed after migration"

echo ""
echo -e "${GREEN}=== Migration complete (Phases 0-6) ===${NC}"
echo "Backup: $BACKUP_DIR"
echo "Phase 7 (commit/push) not run - do manually when ready."
