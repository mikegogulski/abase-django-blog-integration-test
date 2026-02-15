# abase Skills

Skills are installed via `npx skills add`. The CLI installs to `.agents/skills/` and creates symlinks in `.cursor/skills/` for Cursor.

To reinstall after cloning:

```bash
npx skills add github/awesome-copilot --skill prd -y
npx skills add 404kidwiz/claude-supercode-skills --skill embedded-systems -y
npx skills add mindrally/skills --skill computer-vision-opencv -y
npx skills add anthropics/skills --skill frontend-design --skill skill-creator --skill webapp-testing --skill mcp-builder -y
npx skills add obra/superpowers --skill brainstorming --skill systematic-debugging --skill writing-plans --skill test-driven-development -y
```

On Windows, symlinks may fail; see README-WINDOWS.md for mitigation.
