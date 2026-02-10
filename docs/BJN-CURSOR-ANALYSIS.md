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

## 4. handover.mdc → handover-context.mdc

- **Classification:** **BJN-specific.** Project overview (Butlerian Jihad News, Django/Wagtail, bjn/, bjnconfig/, deploy/), key locations, URLs (butlerianjihad.now, ssh bjn-sabrina), tasks (Task 15, admin split), environment (PostgreSQL, qcluster, uv run).
- **Recommendation:** **No.** Content is entirely BJN project context. For workflow/Django blog, use a *template* handover (structure: overview, locations, last tasks, pending) and fill with this project’s data. In workflow we use `.cursor/rules/handover-context.mdc` (always applied) with a template handover structure.

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

---

## 9. rules/backend/admin-interface.mdc

- **Classification:** **Mostly generic** with **BJN-specific examples.** Standards for Django Admin UX: hyperlink model names/IDs to admin change/changelist pages, sortable columns (view + template pattern), multiple sortable tables with prefixed params, use `annotate()` to avoid N+1, color-coded status badges, action buttons in `object-tools-items`. The patterns are generic; examples use `admin:bjn_publication_change` and the status-badge section lists BJN article workflow statuses (scraped, processed, ready, used, duplicate, nonconformant, api_failure) and colors.
- **Recommendation:** **Yes (adapt).** Useful for any Django project with custom admin. Include a version that generalizes: keep the hyperlink/sortable/annotate/action-button patterns; replace BJN app/model names with placeholders (e.g. `<app>_<model>_change`); replace the status badge list with "define consistent colors for your model statuses" and an optional example. Complements workflow's `django-blog.mdc`.

---

## 10. rules/backend/article-types.mdc

- **Classification:** **BJN-specific.** Defines four Butlerian Jihad News article types (News, Intelligence, Action Report, Opinion), attribution (editorial_staff, nom_de_guerre), tone/slur/prompt structures, persona generation, bjn/config.py, BlogPostPage/Article models, links to jihad.mdc and manifesto. Entirely product-specific.
- **Recommendation:** **No.** Do not include. The pattern (content types with attribution and prompts) could inspire a generic "content types" rule elsewhere but the file is BJN-only.

---

## 11. rules/backend/config.mdc

- **Classification:** **Mostly generic** with BJN path. Centralized config module, naming convention (module prefix: SCRAPING_DUPLICATE_THRESHOLD), migration process, env vars vs config.py, documentation and testing.
- **Recommendation:** **Yes (adapt).** Use for any Python/Django project; replace `bjn/config.py` with "project config module" or your app name.

---

## 12. rules/backend/django-admin.mdc

- **Classification:** **Mostly generic** with BJN examples. format_html() limitation, @admin.display(), custom admin views (admin_view wrapper), admin actions, list_display optimization, error handling. Examples use Article.Status.SCRAPED, scrape_control, pipeline_dashboard.
- **Recommendation:** **Yes (adapt).** Generic Django admin patterns; replace BJN action names and model references with placeholders.

---

## 13. rules/backend/django-orm.mdc

- **Classification:** **Mostly generic** with BJN model names. select_related/prefetch_related, only/defer, annotate/aggregate, bulk ops, values_list/values, queryset evaluation, "Common Patterns in BJN" (Article, Publication, BlogPostPage). All patterns are standard Django ORM.
- **Recommendation:** **Yes (adapt).** Strong generic ORM guide; generalize model names (e.g. Article → YourModel) for workflow/Django blog.

---

## 14. rules/backend/django.mdc

- **Classification:** **Generic.** KISS/YAGNI/DRY, variable initialization, keyword-only optional params, data structures, imports, comprehensions, dict iteration, code style (quotes, line length, f-strings), testing (uv run manage.py test vs pytest). No BJN-specific content.
- **Recommendation:** **Yes.** Fits any Django backend; align with workflow's django-blog.mdc and code style.

---

## 15. rules/backend/image-generation.mdc

- **Classification:** **BJN-specific** with some generic image-prompt advice. Butlerian Jihad identity, manifesto, article types, action_report no images, DALL-E/gpt-image models, bjn/openai_client.py, content restrictions and quality checklist. Generic bits: no text in images, centered composition, avoid AI artifacts.
- **Recommendation:** **No.** Do not include verbatim. Optionally extract a short generic "AI image prompt best practices" (no text, centered composition, artifact avoidance) if workflow ever adds image generation.

---

## 16. rules/backend/scraping.mdc

- **Classification:** **BJN-specific.** Publication list (16 sources, rejected list), BBC-specific filtering, bjn/config.py, bjn/scraping.py, URL resolution/deduplication/skip patterns, newspaper4k. Patterns are reusable but the file is tied to BJN sources and code.
- **Recommendation:** **No.** Do not include. Use as a pattern reference for a "scraping strategy" doc if we add scraping later.

---

## 17. rules/code-quality.mdc

- **Classification:** **Generic.** Linting philosophy (fix all, when to suppress), suppression syntax (ruff, djlint), global suppression in pyproject.toml, workflow (pre-commit, tools/preen.sh). Only BJN refs: description "for BJN" and `bjn/templates` in djlint command.
- **Recommendation:** **Yes (adapt).** Replace paths with project paths; we may use different linters but the policy applies to any project.

---

---

## 18. rules/copy-writing.mdc

- **Classification:** **BJN-specific.** Butlerian Jihad naming, "news site not blog," sentence case, colon title rules, em dash avoidance, Oxford comma, abbreviations, content restrictions (slurs, state officials, manifesto quotes), supporter voice, AI "slips." Entirely product/editorial.
- **Recommendation:** **No.** Do not include. Optional: extract generic copy style (sentence case, Oxford comma, em dash avoidance) into a short rule if desired.

---

## 19. rules/cursor-agent-url-approval.mdc

- **Classification:** **Generic.** How to configure Cursor so the agent can open/fetch URLs without approval each time (Settings → Chat/Tools → Auto-run or allow-listed actions). No BJN content.
- **Recommendation:** **Yes.** Include as-is; useful for any project where the agent needs to fetch docs or open URLs.

---

## 20. rules/cursor-rules.mdc

- **Classification:** **Generic.** Where to put rules (PROJECT_ROOT/.cursor/rules/), naming (kebab-case, .mdc), directory structure, rule file structure (frontmatter + content), note on skills-config.mdc. No BJN-specific content.
- **Recommendation:** **Yes.** Include as-is; applies to any Cursor project.

---

## 21. rules/deployment.mdc

- **Classification:** **BJN-specific.** update.sh, sabrina.butlerianjihad.now, bjn-sabrina, /home/bjn/bjn, systemctl bjn/bjn-qcluster, deploy/nginx/bjn.conf, pull_remote_db.sh. Entirely BJN server and paths.
- **Recommendation:** **No.** Do not include. Use as pattern (SSH reuse, venv prefix, one-command update) when we add deployment docs.

---

## 22. rules/frontend/djlint.mdc

- **Classification:** **Mostly generic** with BJN paths. Running djlint, common errors (T003, H023, T002, H006, D018), Wagtail {% pageurl %}, pyproject.toml config, pre-commit. "BJN Named URL Patterns" table is BJN-specific; commands use bjn/templates.
- **Recommendation:** **Yes (adapt).** Replace bjn/templates with project path; drop or generalize the BJN URL patterns table.

---

## 23. rules/frontend/frontend-design.mdc

- **Classification:** **BJN-specific.** Satirical news site, Butlerian Jihad, target audience, "Serious but Slightly Off," color palette (#7A3F21, etc.), Pure CSS, htmx, footer disclaimer, Cold Resistance palette. Some generic principles (accessibility, responsive, semantic HTML).
- **Recommendation:** **No.** Do not include. Optional: extract generic frontend checklist (accessibility, mobile-first) if needed.

---

## 24. rules/handover-management.mdc

- **Classification:** **Mostly generic** with BJN template. Handover flow: handover-context.mdc is in rules (always applied); archive to handover-archive/, generate new with structure. Key Locations table and Environment notes use bjn/, bjnconfig/, qcluster.
- **Recommendation:** **Yes (adapt).** Keep handover process; replace Key Locations and env notes with project-agnostic template.

---

## 25. rules/infrastructure.mdc

- **Classification:** **BJN-specific.** sabrina.butlerianjihad.now, bjn-sabrina, /home/bjn/bjn, Gunicorn bjn, bjn-qcluster, PostgreSQL bjn. Entirely BJN infra.
- **Recommendation:** **No.** Do not include.

---

## 26. rules/jihad.mdc

- **Classification:** **BJN-specific.** Butlerian Jihad manifesto, editorial injection, EDITORIAL_INJECTION_KEYWORDS, AI identity prompt, content restrictions, anti-AI slurs list. Product/editorial only.
- **Recommendation:** **No.** Do not include.

---

## 27. rules/prd-evolution.mdc

- **Classification:** **Generic.** PRD as living doc (implementation supersedes PRD), when to update, status indicators (✅🔶🔲), process, docs/MAYBE.md for deferred. Path scripts/prd.md is conventional.
- **Recommendation:** **Yes (adapt).** Use for any project with a PRD; adjust path if different.

---

## 28. rules/project-structure.mdc

- **Classification:** **BJN-specific.** Full directory tree (bjn/, bjnconfig/, deploy/, scripts, tools, etc.) and conventions. Maintenance rule is generic; content is BJN.
- **Recommendation:** **No.** Do not copy. Use as pattern: "maintain a project-structure doc and update when dirs change."

---

## 29. rules/secrets.mdc

- **Classification:** **Generic.** Where secrets live (.cursor/mcp.json, .env), never commit, example GH_TOKEN from mcp.json. MCP/server names are examples; pattern is universal.
- **Recommendation:** **Yes (adapt).** Replace example keys/servers with project's; keep structure and security notes.

---

## 30. rules/self-improvement.mdc

- **Classification:** **Generic.** When to add/update/deprecate rules, analysis process, pattern recognition, quality checks. Example references another project (shipixen, prisma); otherwise tool-agnostic.
- **Recommendation:** **Yes.** Include as-is; useful for any Cursor rule set.

---

## 31. rules/skills-config.mdc

- **Classification:** **Generic** with BJN example. How to enable/disable globally-installed Cursor skills per project, template for new projects. "For This Project (BJN)" is one configuration; instructions apply to any project.
- **Recommendation:** **Yes (adapt).** Replace BJN section with "For this project (workflow/Django blog)" and mark skills as needed.

---

## 32. rules/technology-stack.mdc

- **Classification:** **BJN-specific.** bjn-start/bjn-stop, ~/bjn/logs, qcluster, Wagtail, OpenAI/DALL-E, django-q2, PostgreSQL-only, stack overview. Entirely BJN stack and tooling.
- **Recommendation:** **No.** Do not include. Use as pattern for "technology stack doc with versions" when we document our stack.

---

## 33. rules/visual-testing.mdc

- **Classification:** **Mostly generic** with BJN paths. Playwright Chromium, screenshot script (scripts/screenshot_pages.py), dev/prod base URL, screenshot-and-fix workflow (capture → analyze → iterate, 5-attempt cap). bjn-start, butlerianjihad.now are BJN-specific.
- **Recommendation:** **Yes (adapt).** Generalize script path and base URL; keep Playwright and the 5-attempt fix workflow.

---

**Beads:** All workflow-989.x tasks (989.10–989.33) analyzed above. Close each bead with: bd update ID --status closed (e.g. workflow-989.11 through workflow-989.33).
