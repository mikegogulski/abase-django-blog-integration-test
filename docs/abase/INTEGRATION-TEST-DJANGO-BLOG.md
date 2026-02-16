# Integration Test: Django Blog MVP

**Purpose:** Validate that the abase framework can deliver a real project. An agent (or automated workflow) uses abase (Beads, rules, handover) to produce a working Django blog from scratch.

**Epic:** abase-2cf

---

## 1. Test Harness

- **Work directory:** `.abase/integration-test-tmp/` (gitignored)
- **Setup:** Clone the abase repo into this directory. The clone is the workspace; agents work inside it.
- **Deliverable:** A Django blog project built in a subdirectory (e.g. `blog/`) of the clone. Use standard Django management tools: `django-admin startproject blog_project`, `startapp blog`, etc. All models in a single app (no separate apps per domain). Framework files (`.cursor/`, `.beads/`, `.abase/`, etc.) must not be modified by the blog build.
- **Terminology:** This is an **integration test**—it tests the full framework + agent workflow producing a deliverable.

---

## 2. Platform Support

| Platform | Status |
|----------|--------|
| **Win11Pro + WSL2** | Supported (primary; only platform with test coverage) |
| macOS | Not tested |
| Linux (native) | Not tested |
| Windows (without WSL) | Not tested |

---

## 3. Constraints

### 3.1 Isolation

- The integration test must **not disrupt** any files or directories belonging to the framework.
- **Source code, config files:** Go into the integration test temp directory base (the repo root). Blog project structure (e.g. `blog/`) lives within the clone.
- **Automated development output:** Goes into appropriate places in the repo (e.g. build artifacts where conventional).
- **Pure temporary files:** Go in a `tmp/` directory in the repo that is gitignored.
- Framework paths (`.cursor/`, `.beads/`, `.abase/`, `docs/`, etc.) are read-only for the blog build.

### 3.2 No JavaScript (public pages)

- **Zero JavaScript** on public-facing pages. Server-rendered HTML only.
- Django templates, forms, and static files (CSS only). No frontend frameworks, no `<script>` tags.
- Admin may use JS (e.g. rich editor).

### 3.3 Django Stack

- **Django:** Latest Django 6.x.
- **Templates:** Django template language only.
- **User model:** Custom user derived from `AbstractUser` (extensible for future fields).
- **Styling:** Minimal. Modern theme, system fonts, clean layout. CSS only.

### 3.4 Database

- **SQLite 3** only. No PostgreSQL, MySQL, or other external databases. Keeps the integration test self-contained and portable.

---

## 4. Blog Requirements

### 4.1 Core Features

| Feature | Description |
|---------|-------------|
| **Multiple users** | User registration (built-in forms), login, logout. Custom User model (AbstractUser). Login redirect to home. Disable email verification if possible; otherwise mock — no human-in-the-loop. |
| **Permissions** | New users: read-only (view posts, pages, categories, pagination) + submit comments. Superusers only: create/edit/delete posts, user management. |
| **Comments** | Authenticated users submit comments (plain text, no rich editor). Line breaks in comment text become HTML paragraphs when displayed on the post page. |
| **Posts** | Blog posts with author, title, content, created/updated timestamps. List and detail views. |
| **Categories** | Post categories (e.g. Tech, Life, News). One category per post. Filter posts by category. |
| **Pagination** | Post lists paginated (e.g. 10 per page). First/Previous/Next/Last links via `?page=N`. No JS. |
| **Pages** | Django flatpages. About at `/about/`, Contact at `/contact/`. |
| **RSS feed** | Django built-in syndication at `/feed/`. Posts only, most recent 10. |
| **Sitemap** | Django built-in sitemaps at `/sitemap.xml`. Posts and pages. |
| **robots.txt** | Serves `/robots.txt` pointing at sitemap. |
| **Seed data** | Create and publish 15 test posts via management command. Use Faker with cakeipsum-style prose. |
| **Post rich editor** | Admin post creation uses a modern rich editor (e.g. django-prose-editor). |
| **Front page** | Static "most recent posts" listing at `/`. Published posts only. No dynamic JS; server-rendered. |
| **Django admin** | Custom admin for User, Category, Post, Comment, Page. Use `fieldsets` to group related fields (avoid default column-order layout). `list_display`, `list_filter`, `search_fields`, `ordering` for list views. Human-friendly, not machine-friendly. |

### 4.2 Model Structure

- **Database:** SQLite 3 (see §3.4).
- **Single app:** All models (User, Category, Post, Page) live in one Django app. No separate apps per domain.
- **Settings:** Env-based overrides (e.g. `DJANGO_SETTINGS_MODULE` or env vars for dev/prod). At project start, generate a short random blog title with cakeipsum; store in settings (e.g. `BLOG_TITLE`) and include in templates by reference.
- **User:** `AbstractUser` subclass (e.g. `blog.users.models.CustomUser`).
- **Category:** name, slug. One-to-many with Post (ForeignKey from Post).
- **Post:** `ForeignKey` to User (author), `ForeignKey` to Category (nullable, default=Uncategorized), title, slug (globally unique; duplicates get `slug-2`, `slug-3`, etc.), content, created_at, updated_at, published_at, status (draft/published). Use `auto_now_add=True` for both `created_at` and `published_at`. Create/edit/delete: Django admin only (superuser).
- **Comment:** `ForeignKey` to Post, `ForeignKey` to User (author), content, created_at. Plain text only (no rich editor). Submit: authenticated users via form below post content. Display: line breaks → HTML paragraphs. Shown immediately; admins can delete at will.
- **Page:** Django flatpages. About at `/about/`, Contact at `/contact/`.

### 4.3 Categories (typical pattern)

- **Category model:** `name`, `slug` (unique). Used for grouping posts.
- **Post → Category:** `ForeignKey(Category, on_delete=..., null=True, default=...)`. Nullable; default to "Uncategorized" category (created in migrations).
- **Views:** Category list (all categories with post counts); filter posts by category via URL (e.g. `/category/tech/`).
- **Post URL scheme:** `/post/YYYY-MM-DD/slug` (e.g. `/post/2026-02-16/my-first-post`). Date from `published_at`; for SEO/human convenience only — URL resolution uses slug alone.
- **Templates:** Show category name on post list/detail; link to category filter. Optional: category sidebar or nav.
- **Post list:** Front page at `/` only. No separate `/posts/` list.

### 4.4 Pagination (typical pattern)

- **ListView:** Set `paginate_by = 10` (or similar). Django adds `page_obj` and `paginator` to context.
- **URL:** Query string `?page=2` (1-based). No path changes needed.
- **Template:** `{% for post in page_obj %}`. Navigation: `page_obj.has_previous`, `has_next`, `previous_page_number`, `next_page_number`. Links: First, Previous, page numbers, Next, Last. All plain `<a href="?page=N">`—no JavaScript.
- **Reference:** [Django Pagination](https://docs.djangoproject.com/en/stable/topics/pagination/)

### 4.5 Seed Data

- **Management command:** Create 15 published test posts. Use **Faker** for prose generation with **cakeipsum-style** placeholder text (cake-themed words instead of Lorem Ipsum).

### 4.6 References

- [Django Cookbook: Custom User Model](https://www.djangocookbook.com/recipes/creating-a-custom-user-model/)
- [Real Python: Build a Blog with Django](https://realpython.com/build-a-blog-from-scratch-django/)
- [LearnDjango: Django Blog Tutorial](https://learndjango.com/tutorials/django-blog-tutorial)

---

## 5. Styling

- **Base template:** Shared layout (nav, footer, `{% block content %}`). Created as part of styling. Use FOSS template or guide; customize layout and styling.
- **Scope:** All pages (front, posts, pages, auth).
- Modern, minimal theme. System fonts (e.g. `system-ui`, `-apple-system`, `Segoe UI`). Readable line length, clear hierarchy, responsive basics.
- No JavaScript for styling or interaction.

---

## 6. Test-Driven Development

- **Generate and run tests** for everything the integration test builds: models, views, forms, URLs, templates (via Django test client).
- **Exclusions:** Skip or mark as optional any e2e tests that require a non-headless browser (e.g. real Chrome/Firefox with JS). Headless-capable tests (e.g. Django test client, static checks) are required.
- **Iterate until green:** Use tests to drive development. Run tests after each change; fix failures; repeat until all tests pass. The integration test is not complete until the test suite is green.
- **Coverage:** Exercise as many code paths as possible. Measure coverage periodically; iterate until at least 90%, preferably 95%.
- **Test runner:** Django `manage.py test` or pytest-django. Use parallel execution (see §8).

---

## 7. Agentic Development Process

Requirements specific to how abase functions with agentic development:

- **Beads:** Each task bead (abase-2cf.1, 2cf.2, …) corresponds to a unit of work. Agents claim beads, implement, run tests, close when done. Dependencies between beads define the order; parallel beads (no mutual dependency) may be worked in parallel.
- **Rules:** Agents follow `.cursor/rules/` (e.g. django-blog.mdc, abase conventions). The blog build must conform to documented conventions.
- **Handover:** For multi-session work, handover context (`.cursor/rules/abase-handover-context.mdc`) provides continuity. Agents should update handover when pausing or handing off.
- **Tests as gate:** Before closing a bead, run the relevant tests. Do not close with failing tests.
- **Incremental verification:** After each bead (or logical step), run the test suite. Catch regressions early.

---

## 8. Parallel Execution

- **Use parallel execution wherever possible.**
- **Django tests:** `manage.py test --parallel` or pytest-django with `-n auto` (pytest-xdist).
- **Beads:** Tasks with no dependency between them (e.g. 2cf.3, 2cf.4, 2cf.8) may be implemented in parallel by separate agents or sessions.
- **Integration test runner:** When verifying multiple components, run checks in parallel where safe (e.g. lint + tests in parallel).

---

## 9. Run Server

- **Command:** `uv run manage.py runserver 127.0.0.1:8765`
- **URL:** http://127.0.0.1:8765/ (front page at root)

---

## 10. Integration Test Runner

**Goal:** Completely hands-off integration test. No human intervention.

**Two-phase implementation:**

| Phase | Approach | Purpose |
|-------|----------|---------|
| **MVP** | Scripted steps per bead | Deterministic, CI-friendly. Each bead has a script (e.g. `build_2cf_2.sh`). Runner executes in dependency order, runs tests, iterates until green. |
| **Production** | Full agentic workflow | Agent invokes per bead; derived from scripted solution. Validates framework + agent loop. |

A script (e.g. `./.abase/tests/integration/test_django_blog.sh`) **drives the entire build**:

1. Create `.abase/integration-test-tmp/` if missing.
2. Clone abase into it (or `git clone` into a subdir).
3. **For each bead (2cf.2 through 2cf.10):** MVP: run scripted step. Production: invoke agent. Generate tests, run tests (with `--parallel`), iterate until green. Skip e2e tests requiring a non-headless browser.
4. Final verification: `manage.py check`, full test suite, report pass/fail.

The runner orchestrates the build; it does not assume a pre-built blog. Fully automated.

---

## 11. Bead Structure

See epic **abase-2cf** and child tasks for granular implementation beads. Includes **abase-2cf.9**: Django admin; **abase-2cf.10**: RSS, sitemap, robots.txt.

---

## 12. Meta-Concerns (Process & Metrics)

### 12.1 Repository & Version Control

- **GitHub repo:** Create a new repo (via API/CLI) at the start; push integration test work from the clone root (`.abase/integration-test-tmp/`).
- **Commits:** Commit after each substantial chunk of work (agent judgment).
- **Push:** Push only when a bead is fully done (tests passing).
- **CI:** Add a separate GitHub Actions workflow in the integration test repo. Trigger on push to `main`. At the end of each bead, check the last CI run for errors and fix them before considering the bead complete.

### 12.2 Blog Title

- At the beginning of the project, generate a short random blog title with cakeipsum. Store in `settings.py` (e.g. `BLOG_TITLE`) and include in templates by reference.

### 12.3 Timing & Metrics

- **Time and report** the following intervals:
  - Per commit: time to author
  - Per test round: duration
  - Per fix: duration
  - Per bead: total time to complete
  - Full epic: total time
- **Output:** Both JSON and Markdown (e.g. `integration-test-metrics.json`, `integration-test-metrics.md`).
- **Token counting:** If any way to count tokens is available (best available source), record at the same granularity (per commit, per test round, per fix, per bead, full epic).
