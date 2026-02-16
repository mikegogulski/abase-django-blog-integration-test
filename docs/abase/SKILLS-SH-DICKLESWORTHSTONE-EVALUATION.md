# Dicklesworthstone Skills — Evaluation for This Project

Evaluation of all skills published by [Dicklesworthstone](https://skills.sh/dicklesworthstone) on skills.sh. Criteria: **include only if useful for this abase (agentic workflow + Django) project**; **exclude** skills that require paid services or that are tied to a specific provider unless clearly beneficial and provider-agnostic.

---

## Summary: Dicklesworthstone on skills.sh

- **7 repos, 38 skills, 1.1K total installs**
- **agent_flywheel_clawdbot_skills_and_integrations**: 30 skills
- **meta_skill**: 1 skill (building-glamorous-tuis)
- **beads_rust**: 1 skill (bd-to-br-migration)

---

## agent_flywheel_clawdbot_skills_and_integrations (30 skills)

| Skill | Installs | Generic? | Include? | Reason |
|-------|----------|----------|----------|--------|
| ssh | 86 | Yes | **Yes** | Generic SSH patterns; useful for deployment, servers. |
| ui-ux-polish | 82 | Yes | **Yes** | Stripe-level polish workflow; generic web UI. |
| gcloud | 51 | Yes | **No** | GCP CLI. We're not deploying to GCP. |
| planning-workflow | 49 | Yes | **Rule** | Adapted as abase-planning-workflow.mdc (phases 1–3). |
| beads-workflow | 48 | Yes | **Rule** | Adapted as abase-beads-workflow.mdc (plan→beads, br/bv). |
| de-slopify | 42 | Yes | **Yes** | See [de-slopify](#de-slopify) below. |
| agent-swarm-workflow | 41 | Yes | **—** | We already use this stack (Agent Mail, Beads, BV, rules). Not a separate skill to add. |
| cass | 39 | Yes | **Maybe** | See [cass](#cass) below. |
| claude-chrome | 37 | Yes | **Maybe** | See [claude-chrome](#claude-chrome) below. |
| cm | 34 | Yes | **Maybe** | CASS Memory; cognitive memory. Defer until needed. |
| cursor | 33 | Yes | **Yes** | See [cursor](#cursor) below. |
| ubs | 33 | Yes | **Yes** | See [ubs](#ubs) below. |
| supabase | 33 | No | **No** | Supabase-specific. We're not on Supabase. |
| ghostty | 32 | Yes | **Maybe** | Ghostty terminal control; defer unless we use Ghostty. |
| bv | 32 | Yes | **Yes** | See [bv](#bv) below. |
| tanstack-integration | 31 | Yes | **Maybe** | TanStack for web. Include if we add React/frontend. |
| github | 30 | Yes | **Yes** | See [github](#github) below. |
| dcg | 29 | Yes | **Yes** | See [dcg](#dcg) below. |
| ntm | 28 | Yes | **Yes** | Named Tmux Manager; multi-agent orchestration. |
| vercel | 28 | No | **No** | Vercel-specific. We're Django/Hetzner. |
| wezterm | 27 | Yes | **Maybe** | WezTerm control; defer unless we use WezTerm. |
| caam | 26 | Yes | **Maybe** | Account switching for AI CLIs; defer. |
| agent-mail | 26 | Yes | **Yes** | MCP Agent Mail; we use it. |
| slb | 25 | Yes | **Maybe** | Simultaneous Launch Button; two-person rule for destructive commands. Defer. |
| ru | 25 | Yes | **Maybe** | Repo Updater; multi-repo sync. Defer. |
| csctf | 24 | Yes | **Maybe** | Chat share links → Markdown; defer. |
| flywheel-discord | 24 | No | **No** | Discord community rules; project-specific. |
| giil | 23 | Yes | **Maybe** | Image download from share links; defer. |
| agent-fungibility | 22 | Yes | **Yes** | See [agent-fungibility](#agent-fungibility) below. |
| wrangler | 21 | No | **No** | Cloudflare Workers; not our stack. |

---

## meta_skill (1 skill)

| Skill | Installs | Generic? | Include? | Reason |
|-------|----------|----------|----------|--------|
| building-glamorous-tuis | 8 | Yes | **Maybe** | TUI building; defer until we need TUIs. |

---

## beads_rust (1 skill)

| Skill | Installs | Generic? | Include? | Reason |
|-------|----------|----------|----------|--------|
| bd-to-br-migration | 8 | Yes | **Yes** | See [bd-to-br-migration](#bd-to-br-migration) below. |

---

## Detailed Explanations

### planning-workflow

**Adapted as:** `.cursor/rules/abase-planning-workflow.mdc` (phases 1–3 only; no beads). Attribution: `<!-- Adapted from https://skills.sh/dicklesworthstone/agent_flywheel_clawdbot_skills_and_integrations/planning-workflow (Jeffrey Emanuel / Dicklesworthstone) -->`

**Eliminated overlap:** Phases 4–5 (convert to beads, polish beads) moved to abase-beads-workflow. This rule ends at "when plan is ready, pass to beads-workflow."

---

### beads-workflow

**Adapted as:** `.cursor/rules/abase-beads-workflow.mdc` (plan→beads, polishing, br/bv, Agent Mail). Attribution: `<!-- Adapted from https://skills.sh/dicklesworthstone/agent_flywheel_clawdbot_skills_and_integrations/beads-workflow (Dicklesworthstone) -->`

**Eliminated overlap:** No planning phases (those are in abase-planning-workflow). Uses `br` not `bd`. Best of both: conversion prompts, polish prompts, bead quality checklist, Agent Mail conventions.

---

### de-slopify

**What it is:** A methodology and prompts to remove "AI slop" from documentation—patterns that make text sound LLM-generated (excessive emdashes, "Here's why," "It's not X, it's Y," "Let's dive in," etc.). Requires manual, line-by-line review; not automatable with regex.

**Why include:** Our docs (README, AGENTS.md, rules) are often AI-assisted. De-slopify gives a systematic way to make them sound human before release. Useful for README, CONTRIBUTING, API docs, and any public-facing text.

**Recommendation:** Include. Low cost, high value for doc quality.

---

### cass

**What it is:** Coding Agent Session Search—CLI/TUI that indexes and searches local coding agent history from Codex, Claude Code, Gemini CLI, Cursor, Aider, etc. Robot mode (`cass search "query" --robot`) returns JSON for agents. Use case: "I solved this before…" or cross-agent handoff.

**Why maybe/defer:** Valuable when we have many sessions and need to recall past solutions. Adds a dependency (CASS install, index maintenance). Include when we routinely need to search across Cursor/Codex/Claude history.

**Recommendation:** Defer until we have enough session volume to justify indexing and search.

---

### claude-chrome

**What it is:** Browser automation via the official Anthropic Claude Chrome extension. Control a logged-in Chrome browser, automate workflows, fill forms, extract data.

**Why maybe/defer:** Useful for E2E tests or scraping when we need a real browser. We have cursor-ide-browser MCP for in-IDE browsing. Claude Chrome is a different integration (extension-based). Include if we need automation outside Cursor.

**Recommendation:** Defer until we have a concrete browser-automation need.

---

### cursor

**What it is:** Control Cursor IDE via CLI—open files, folders, diffs, manage extensions. Enables scripts and agents to drive Cursor programmatically.

**Why include:** We use Cursor. The skill documents CLI patterns for opening projects, files, and diffs. Useful for handover scripts, automation, and multi-window workflows.

**Recommendation:** Include.

---

### ubs

**What it is:** Ultimate Bug Scanner—pre-commit static analysis for AI coding workflows. 18 detection categories, 8 languages, 4-layer analysis. Acts as a quality gate before commits.

**Why include:** Catches AI-generated bugs, slop, and anti-patterns before they land. Complements our terminal error-handling rule and testing strategy. Generic, no provider lock-in.

**Recommendation:** Include.

---

### bv

**What it is:** Beads Viewer—graph-aware triage for Beads projects. Computes PageRank, betweenness, critical path, cycles. `--robot-*` flags (e.g. `bv --robot-next`, `bv --robot-triage`) provide JSON output for agents. Never run bare `bv` (launches TUI).

**Why include:** We use Beads. BV helps agents pick the right bead, understand the graph, and avoid cycles. Our rules reference `bv --robot-next` as an alternative to `br ready`.

**Recommendation:** Include.

---

### github

**What it is:** GitHub CLI patterns—manage repos, issues, PRs, actions, releases from the command line.

**Why include:** Generic. We use GitHub (mikegogulski/abase). Useful for PR creation, issue management, and automation. No provider lock-in beyond GitHub itself.

**Recommendation:** Include.

---

### dcg

**What it is:** Destructive Command Guard—Rust hook that blocks dangerous commands before execution. SIMD-accelerated, whitelist-first. Safety layer for agent workflows (e.g. blocks `rm -rf /` unless explicitly allowed).

**Why include:** Agents run terminal commands. DCG adds a defense-in-depth layer against accidental destructive commands. Complements our terminal error-handling rule.

**Recommendation:** Include.

---

### agent-fungibility

**What it is:** Philosophy and rationale for agent fungibility—homogeneous, interchangeable agents outperform specialized role-based systems at scale. Explains why "any agent can pick up any bead" works.

**Why include:** Aligns with our multi-agent approach (Agent Mail, Beads, handover). Reinforces the design choice that we don't need specialized "frontend agent" vs "backend agent"—any agent can work any bead with the right context.

**Recommendation:** Include.

---

### bd-to-br-migration

**What it is:** Migration guide from `bd` (Go beads) to `br` (beads_rust). Core rule: `bd sync` → `br sync --flush-only` plus explicit `git add .beads/` and `git commit`. Everything else is find-replace (`bd` → `br`). Includes verification greps and a decision tree for single vs batch migration.

**Why include:** We use `br`. Docs, rules, and skills may still reference `bd`. This skill ensures consistent migration when we encounter `bd` references (e.g. in adopted skills, AGENTS.md, or handover content).

**Recommendation:** Include.

---

## Summary

### Include (confirmed)

- **Skills added (abase-prefixed):** abase-de-slopify, abase-cursor, abase-ubs, abase-bv, abase-github, abase-dcg, abase-agent-fungibility, abase-bd-to-br-migration.
- **Rules adapted (no overlap):** abase-planning-workflow (phases 1–3 only), abase-beads-workflow (plan→beads, polishing, br/bv, Agent Mail). Each has invisible attribution comment.
- **Also include:** ssh, ui-ux-polish, ntm, agent-mail (add via npx when needed).

### Defer (confirmed)

cass, claude-chrome, cm, ghostty, tanstack-integration, wezterm, caam, slb, ru, csctf, giil, building-glamorous-tuis. Add when we have React, browser automation, or session search needs.

### Excluded

See [Excluded Skills](#excluded-skills) section below.

---

## Excluded Skills

Skills we do **not** include. Provider- or project-specific; not useful for abase (Django, Hetzner, agentic workflow).

| Skill | Reason |
|-------|--------|
| gcloud | We're not deploying to GCP. |
| supabase | Supabase-specific. We're not on Supabase. |
| vercel | Vercel-specific. We're Django/Hetzner. |
| wrangler | Cloudflare Workers. Not our stack. |
| flywheel-discord | Discord community rules; project-specific. |

---

## Implementation Status

- **Installed:** abase-de-slopify, abase-cursor, abase-ubs, abase-bv, abase-github, abase-dcg, abase-agent-fungibility, abase-bd-to-br-migration (`.agents/skills/abase-*`, symlinked in `.cursor/skills/`).
- **Rules:** abase-planning-workflow.mdc, abase-beads-workflow.mdc (adapted from Dicklesworthstone; attribution in HTML comments).
