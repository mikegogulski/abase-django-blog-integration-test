# skills.sh Top 30 Skills — Evaluation for This Project

Evaluation of the most popular 30 skills at [skills.sh](https://skills.sh/) (All Time installs). Criteria: **include only if useful for this Django blog + agentic workflow project**; **exclude** skills that require paid services or that are tied to a specific provider (e.g. Vercel) unless they are clearly beneficial and provider-agnostic.

---

| # | Skill | Repo | Include? | Reason |
|---|-------|------|----------|--------|
| 1 | find-skills | vercel-labs/skills | **No** | Vercel-oriented; helps find skills in their ecosystem. Not needed for our stack. |
| 2 | vercel-react-best-practices | vercel-labs/agent-skills | **No** | Vercel + React specific. We're Django (backend + templates or small frontend). |
| 3 | web-design-guidelines | vercel-labs/agent-skills | **No** | Vercel. Prefer provider-agnostic design guidance if we add one later. |
| 4 | remotion-best-practices | remotion-dev/skills | **No** | Video (Remotion). Not relevant to a simple Django blog. |
| 5 | frontend-design | anthropics/skills | **Yes** | Generic frontend/UI design. Useful for blog UI and forms. |
| 6 | vercel-composition-patterns | vercel-labs/agent-skills | **No** | Vercel + React composition. Not our stack. |
| 7 | agent-browser | vercel-labs/agent-browser | **No** | Vercel. We can use Cursor's built-in browser or a generic MCP browser later. |
| 8 | skill-creator | anthropics/skills | **Yes** | Meta: how to create skills. Helps add Cursor skills/rules; no provider lock-in. |
| 9 | browser-use | browser-use/browser-use | **Maybe** | Generic browser automation. Consider if we need E2E or scraping; defer until needed. |
| 10 | vercel-react-native-skills | vercel-labs/agent-skills | **No** | Vercel + React Native. We're not doing mobile. |
| 11 | ui-ux-pro-max | nextlevelbuilder/ui-ux-pro-max-skill | **No** | Third-party “pro” product; may be paid or product-specific. Skip to avoid paid/gated. |
| 12 | audit-website | squirrelscan/skills | **Maybe** | Generic website auditing. Could help with blog quality/accessibility; defer until blog exists. |
| 13 | seo-audit | coreyhaines31/marketingskills | **Maybe** | SEO for marketing. Relevant for blog discoverability; check if it requires paid tools. |
| 14 | brainstorming | obra/superpowers | **Yes** | Generic ideation. Fits planning and improvement ideas; no provider lock-in. |
| 15 | supabase-postgres-best-practices | supabase/agent-skills | **No** | Supabase-specific. We're on Hetzner; using PostgreSQL is fine but we don't need Supabase skills. |
| 16 | pdf | anthropics/skills | **Maybe** | PDF handling. Include if we add PDF export or uploads to the blog. |
| 17 | copywriting | coreyhaines31/marketingskills | **Maybe** | Copywriting. Optional for blog content quality; check for paid requirements. |
| 18 | pptx | anthropics/skills | **No** | PowerPoint. Not needed for a Django blog. |
| 19 | better-auth-best-practices | better-auth/skills | **No** | Tied to Better Auth library. Only include if we choose that stack; not now. |
| 20 | docx | anthropics/skills | **Maybe** | Word docs. Include only if we need doc import/export. |
| 21 | xlsx | anthropics/skills | **Maybe** | Excel. Include only if we need spreadsheets (e.g. data import). |
| 22 | next-best-practices | vercel-labs/next-skills | **No** | Next.js + Vercel. We're Django. |
| 23 | building-native-ui | expo/skills | **No** | React Native / Expo. We're not building native mobile. |
| 24 | marketing-psychology | coreyhaines31/marketingskills | **No** | Marketing-focused. Optional later; skip for now. |
| 25 | systematic-debugging | obra/superpowers | **Yes** | Generic debugging. Useful for any codebase; no provider lock-in. |
| 26 | webapp-testing | anthropics/skills | **Yes** | Generic web app testing. Fits Django blog testing. |
| 27 | mcp-builder | anthropics/skills | **Yes** | Building MCP servers/tools. Useful if we add MCP (e.g. Beads/BV, tools). |
| 28 | programmatic-seo | coreyhaines31/marketingskills | **Maybe** | SEO automation. Check for paid services; defer until we care about SEO tooling. |
| 29 | writing-plans | obra/superpowers | **Yes** | Planning and writing plans. Aligns with Beads/planning workflow. |
| 30 | test-driven-development | obra/superpowers | **Yes** | Generic TDD. Fits Django and our testing conventions. |

---

## Summary

- **Include (yes):** frontend-design, skill-creator, brainstorming, systematic-debugging, webapp-testing, mcp-builder, writing-plans, test-driven-development.  
- **Maybe / defer:** browser-use, audit-website, seo-audit, pdf, copywriting, docx, xlsx, programmatic-seo (check paid/scope before adding).  
- **Exclude (no):** All Vercel skills (1–3, 6, 7, 10, 22), Remotion, Supabase, Better Auth, Next/Expo, ui-ux-pro-max, marketing-psychology, pptx.

Recommendation: Add the **Yes** skills (via Cursor rules or skills.sh install where applicable). Revisit **Maybe** once the blog exists or we add PDF/SEO/doc features.
