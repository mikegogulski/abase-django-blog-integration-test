# Move workflow → abase: Steps

**Goal:** Move project from `/home/syadasti/workflow` to `/home/syadasti/abase`.

---

## Agent has done (already applied)

- [x] **mcp_agent_mail/.env** — `STORAGE_ROOT` set to `/home/syadasti/abase/.agent_mail_mailbox`
- [x] **docs/abase/AGENT-MAIL-AND-MCP-LEARNINGS.md** — All `/home/syadasti/workflow` → `/home/syadasti/abase`; MCP prefix `workflow-` → `abase-`
- [x] **docs/abase/MULTI-AGENT-READINESS.md** — All paths `/home/syadasti/workflow` → `/home/syadasti/abase`; `workflow/bin`, `workflow/.beads/`, `workflow/mcp_agent_mail/` → `abase/...`
- [x] **docs/abase/REORGANIZE-MINIMAL-TOP-LEVEL-ANALYSIS.md** — All paths updated
- [x] **.beads/config.yaml** — `issue-prefix: "workflow"` added so bead IDs stay `workflow-xxx` after move
- [x] **Agent Mail** — Stopped (agent ran `pkill -f "mcp_agent_mail.cli serve-http"`)

---

## You must do (steps 1–4)

### 1. Close Cursor

- Close Cursor (or any editor) with this workspace open.

### 2. Commit and push (optional but recommended)

```bash
cd /home/syadasti/workflow
git status
git add -A && git commit -m "Prepare move: update paths workflow → abase"
git push
```

### 3. Move the directory

```bash
mv /home/syadasti/workflow /home/syadasti/abase
```

### 4. Reopen workspace

- Open `/home/syadasti/abase` in Cursor.

---

## Agent does (after you complete 1–4)

### 5. Agent Mail project key (if you use multi-agent)

- [x] Call `ensure_project(human_key="/home/syadasti/abase")` once via MCP. *(User: call manually if using multi-agent; agent has no MCP access.)*

### 6. Verify

- [x] `./.abase/tests/run_tests.sh` — **8 passed, 0 failed**
- [x] `br list` — works (workflow-xxx beads)
- [ ] `./.abase/scripts/ensure_agent_mail.sh` — run manually if needed (venv/sandbox may block auto-start)

### 7. Commit and push

```bash
git add -A
git commit -m "Complete move: workflow → abase"
git push
```

---

## Summary

| Who | Steps |
|-----|-------|
| **Agent (already done)** | Update .env, docs, Beads config |
| **You** | 1–4: Close Cursor, move directory, reopen Cursor |
| **Agent (after you reopen)** | 5–7: ensure_project, verify, commit & push |
