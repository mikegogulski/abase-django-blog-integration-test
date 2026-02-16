# abase Skills

Skills are installed via `npx skills add`. The CLI installs to `.agents/skills/` and creates symlinks in `.cursor/skills/` for Cursor.

To reinstall after cloning:

```bash
npx skills add github/awesome-copilot --skill prd -y
npx skills add 404kidwiz/claude-supercode-skills --skill embedded-systems -y
npx skills add mindrally/skills --skill computer-vision-opencv -y
npx skills add anthropics/skills --skill frontend-design --skill skill-creator --skill webapp-testing --skill mcp-builder -y
npx skills add obra/superpowers --skill brainstorming --skill systematic-debugging --skill writing-plans --skill test-driven-development -y
npx skills add https://github.com/dicklesworthstone/agent_flywheel_clawdbot_skills_and_integrations --skill de-slopify --skill cursor --skill ubs --skill bv --skill github --skill dcg --skill agent-fungibility -y
npx skills add https://github.com/dicklesworthstone/beads_rust --skill bd-to-br-migration -y
```

After install, rename to abase-* and add attribution (see docs/abase/SKILLS-SH-DICKLESWORTHSTONE-EVALUATION.md).

On Windows, symlinks may fail; see README-WINDOWS.md for mitigation.
