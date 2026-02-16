# Integration Tests

End-to-end tests that validate the abase framework delivers a real project.

## Django Blog MVP

**Script:** `test_django_blog.sh`  
**Doc:** `docs/abase/INTEGRATION-TEST-DJANGO-BLOG.md`

**Work dir:** `.abase/integration-test-tmp/` (gitignored)

**Flow:**
1. Clone abase into work dir (or copy for local dev)
2. Build Django blog in `blog/` subdir (scaffold + posts + pages + auth + styling)
3. Run `manage.py check` and tests
4. Report pass/fail

**Platform:** Win11Pro+WSL2 (only tested platform)

**Run:** `./.abase/tests/integration/test_django_blog.sh` from repo root
