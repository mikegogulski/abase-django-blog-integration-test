# bjn/.cursor analysis (TODO #1)

Per-file classification: **generic** (applicable to any project) vs **BJN-specific**, and **recommendation** for including in this (workflow / Django blog) project.

---

## 1. agents/code-quality.md

- **Classification:** **Generic.** Describes how to run a code-quality agent: run `tools/preen.sh` for format/lint/type-check; report pass/fail and suggest fixes. No BJN-specific paths or product names.
- **Recommendation:** **No.** This project (workflow) does not use `tools/preen.sh`, isort/ruff/djlint/djhtml/pyright in the same way. Adopt the *pattern* (run a single quality script, report errors) in a rule if desired; do not copy the file verbatim.

---

## 2. agents/pull-request.md

- **Classification:** **Generic.** PR creation: use project PR template, summary/testing/pre-flight checklist, gh CLI for reviewers, git workflow (no force push, pull merge). No BJN-specific content.
- **Recommendation:** **Yes (adapt).** Useful for any repo that uses GitHub and a PR template. Copy and adapt: replace `.github/pull_request_template.md` reference if different; keep the guidelines. Add to workflow if/when you use GitHub PRs.

---

## 3. agents/session-review.md

- **Classification:** **Generic.** How to review AI sessions: extract with claude-conversation-extractor, analyze for mistakes/inefficiencies/pattern violations, suggest improvements. Tools and framework apply to any Claude Code usage.
- **Recommendation:** **Yes (optional).** Valuable for improving agent behavior across sessions. Include if you use Claude Code and want session-review workflows; otherwise defer.

---

## 4. handover.mdc

- **Classification:** **BJN-specific.** Project overview (Butlerian Jihad News, Django/Wagtail, bjn/, bjnconfig/, deploy/), key locations, URLs (butlerianjihad.now, ssh bjn-sabrina), tasks (Task 15, admin split), environment (PostgreSQL, qcluster, uv run).
- **Recommendation:** **No.** Content is entirely BJN project context. For workflow/Django blog, use a *template* handover (structure: overview, locations, last tasks, pending) and fill with this project’s data; do not include BJN handover text.

---

## 5. handover-archive/handover-20260209T141825.mdc

- **Classification:** **BJN-specific.** Snapshot handover from a past session: BJN overview, key locations, URLs (butlerianjihad.news, bjn@sabrina), model relationships, tasks/commits. Archive artifact.
- **Recommendation:** **No.** Historical BJN context only. Do not include. Use handover *structure* only if you add archive snapshots to workflow.

---

## 6. handover-archive/handover-20260209T212223.mdc

- **Classification:** **BJN-specific.** Same as above: session handover snapshot, BJN tasks (18, 22, 24), commits, project overview. Archive artifact.
- **Recommendation:** **No.** Same as 5; do not include.

---

## 7. plans/remote-e2e-testing.plan.md

- **Classification:** **BJN-specific.** Plan for running unit tests on remote server and E2E tests against remote (SSH bjn@butlerianjihad.now, Django/Playwright, conftest, e2e_admin user). Todos reference BJN test files.
- **Recommendation:** **No.** Plan is tied to BJN infra and test suite. For workflow/Django blog, if you add remote E2E later, use this as a *pattern* (plan doc with todos, remote unit + E2E architecture) but not the file itself.

---

## 8. rules/agent-behavior.mdc

- **Classification:** **Generic.** Core agent behavior: do it yourself, troubleshoot on failure, use sudo when needed, tell user only when stuck; shell/network permissions; autonomous resolution. No BJN references.
- **Recommendation:** **Yes.** Already incorporated into workflow’s `.cursor/rules/agent-behavior.mdc`. Keep this as the canonical “hands-off, self-troubleshoot” rule; no further copy needed (workflow already has it).

---

**Beads:** workflow-989.1 through workflow-989.8 were claimed by Worker1–Worker8 and closed after this analysis. Remaining files (workflow-989.9 through workflow-989.33) to be analyzed in a later batch.
