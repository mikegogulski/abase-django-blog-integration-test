# Task Complexity Analysis and Subtask Breakdown

**Created:** 2026-02-15  
**Purpose:** Analyze TODO tasks for complexity and break into dependent subtasks.

---

## Task 5: Make AGENTS.md generic — CLOSED

**Complexity:** N/A (already done)  
**Status:** AGENTS.md is generic. Template language, examples in `docs/abase-templates/AGENTS-PROJECT-EXAMPLES.md`. No work needed.

---

## Task 2: Evaluate Ultimate MCP Server

**Complexity:** Medium (2–4 hours)  
**Dependencies:** None  
**Subtasks:**

| ID | Subtask | Complexity | Deps |
|----|---------|------------|------|
| abase-2rd.1 | Fetch repo, list tools and capabilities | Low | — |
| abase-2rd.2 | Compare to Agent Mail, write recommendation (implement/defer/ignore) | Medium | 2rd.1 |

**Epic:** abase-2rd

---

## Task 6: Evaluate all Dicklesworthstone skills on skills.sh

**Complexity:** Medium–High (depends on skill count; ~5–15 min per skill)  
**Dependencies:** None  
**Subtasks:**

| ID | Subtask | Complexity | Deps |
|----|---------|------------|------|
| abase-126.1 | List all Dicklesworthstone skills on skills.sh | Low | — |
| abase-126.2 | Evaluate each skill; write report (classify, recommend, note deps) | Medium–High | 126.1 |

**Epic:** abase-126 (deferred)

---

## Task 7: Testing strategy implementation (P0–P2)

**Complexity:** Medium (P0 low, P1 low, P2 medium)  
**Dependencies:** P2 depends on P0 (script tests validate ensure/test scripts)  
**Subtasks:**

| ID | Subtask | Complexity | Deps |
|----|---------|------------|------|
| abase-vho.1 | P0: Script tests (test_agent_mail, ensure_agent_mail) | Low | — |
| abase-vho.2 | P0: Beads CLI tests | Low | — |
| abase-vho.3 | P2: Agent Mail integration test | Medium | vho.1 |
| abase-vho.4 | P1: Rules/skills presence and lint | Low | — |

**Epic:** abase-vho  
**Note:** P0 tests can run in parallel; P2 should run after P0 script tests pass.

---

## Task 8: Clarifications (optional)

**Complexity:** Low  
**Subtasks:** Not broken into beads (optional, ad-hoc)
- Allowed sudo commands: define allow-list, document in project-context
- Keyword→Cursor Command: doc or checklist; no code beyond existing prompts

---

## Summary

| Task | Epic | Subtasks | Est. effort |
|------|------|----------|-------------|
| 2. Ultimate MCP | abase-2rd | 2 | 2–4 h |
| 6. Dicklesworthstone skills | abase-126 | 2 | 3–8 h |
| 7. Testing P0–P2 | abase-vho | 4 | 2–4 h |
| 8. Clarifications | — | — | <1 h |
