# Beads: Renaming workflow → abase — Analysis

**Purpose:** Analyze what would be required to rename Beads issue IDs from `workflow-*` to `abase-*`. No changes are made; this is analysis only.

---

## Current State

- **Config:** `.beads/config.yaml` has `issue-prefix: "workflow"` (kept for continuity after moving workflow → abase; see MOVE-WORKFLOW-TO-ABASE.md).
- **Issues:** All existing issues in `.beads/issues.jsonl` have IDs like `workflow-126`, `workflow-2cf`, `workflow-989.1`, etc.
- **References:** `workflow-` appears in ~51 lines of `issues.jsonl`, plus docs (TODO.md, BJN-CURSOR-ANALYSIS, etc.), MCP Agent Mail tests, and handover content.

---

## What Would Need to Change

### 1. Config

- **File:** `.beads/config.yaml`
- **Change:** `issue-prefix: "workflow"` → `issue-prefix: "abase"`
- **Effect:** New issues would get `abase-*` IDs. Existing issues would keep `workflow-*` unless migrated.

### 2. Existing Issues (`.beads/issues.jsonl`)

Beads/br does not provide a built-in "rename prefix" or "migrate IDs" command. To change existing IDs:

- **Option A — In-place edit:** Manually or via script, replace `workflow-` with `abase-` in every `id` field and in every `depends_on_id` / `issue_id` reference in `dependencies` arrays. Must preserve referential integrity (e.g. `workflow-126.1` depends on `workflow-126` → both become `abase-126.1` and `abase-126`).
- **Option B — Fresh init:** Run `br init` (or equivalent) with `--prefix abase`, then re-create or import issues. Would lose history/audit trail unless a migration script rewrites the JSONL.
- **Option C — Keep both:** Leave existing issues as `workflow-*`; only new issues use `abase-*`. Creates mixed prefixes.

**Risks of Option A:**

- JSONL is the source of truth. Any typo or missed reference breaks dependency resolution.
- SQLite DB (if used) may cache IDs; may need `br sync` or DB refresh after JSONL edit.
- Git history would show the rename; `discovered_from` and other cross-references in commit messages or external tools might still mention `workflow-*`.

### 3. Cross-References in Repo

| Location | What to update |
|----------|----------------|
| `TODO.md` | `workflow-989`, `workflow-126`, etc. |
| `docs/abase/BJN-CURSOR-ANALYSIS.md` | `workflow-989.x` references |
| `docs/abase/MOVE-WORKFLOW-TO-ABASE.md` | Notes about `workflow-` prefix |
| `docs/abase/MULTI-AGENT-READINESS.md` | Any `workflow-` examples |
| `docs/abase/AGENT-SWARM-EVALUATION.md` | `bd-123` style examples (may not use workflow) |
| `mcp_agent_mail/tests/test_e2e_multi_agent_workflow.py` | Test fixtures or assertions |
| `mcp_agent_mail/docs/GUIDE_TO_OPTIMAL_MCP_SERVER_DESIGN.md` | Examples |
| `.cursor/rules/abase-handover-context.mdc` | Last tasks, pending items (gitignored; session-specific) |
| Commit messages, PR descriptions | Any `workflow-xxx` mentions |

### 4. External Systems

- **Agent Mail:** If project keys, reservations, or thread IDs reference `workflow-*` bead IDs, those would need to be updated or allowed to coexist.
- **BV (Beads Viewer):** If it caches or displays issue IDs, may need refresh.
- **CI/CD or scripts:** Any automation that parses `br list` or `bd ready --json` and matches `workflow-` would need updates.

---

## Recommended Approach (If Renaming)

1. **Create a migration script** that:
   - Reads `.beads/issues.jsonl`
   - Builds a map `workflow-xxx` → `abase-xxx`
   - Rewrites every `id`, `depends_on_id`, `issue_id` in dependencies
   - Writes the updated JSONL (with backup)
2. **Update config:** `issue-prefix: "abase"` in `.beads/config.yaml`
3. **Run `br sync`** (or equivalent) to refresh DB from JSONL
4. **Grep and replace** `workflow-` → `abase-` in docs, TODO, tests, handover (with care for false positives)
5. **Verify:** `br list`, `br ready`, dependency graph; run `.abase/tests/run_tests.sh`

---

## Why Keep `workflow-` (Current Choice)

Per MOVE-WORKFLOW-TO-ABASE.md: *"Keep workflow- prefix for continuity after moving workflow → abase"*. Benefits:

- No migration risk
- Existing references (docs, commits, Agent Mail) remain valid
- Bead IDs are stable identifiers; changing them breaks traceability unless carefully migrated

---

## Summary

| Item | Effort | Risk |
|------|--------|------|
| Config change only (new issues = abase) | Low | Mixed prefixes |
| Full migration (JSONL + config + docs) | Medium | Referential integrity, missed refs |
| No change (keep workflow-) | None | N/A |
