# Project Conventions (Critical)

Conventions that must be followed for this project. Agents and humans should treat these as non-negotiable.

---

## MCP config is project-local only

**All MCP configuration (e.g. `mcp.json`) must live in this repository**, inside the project source tree.

- **Location:** **`.cursor/mcp.json`** at the project root (i.e. this repo’s `.cursor/` directory).
- **Do not** use or modify MCP config under your user account (e.g. `~/.cursor/` or any global Cursor config) for this project.
- Other projects have their own `.cursor/mcp.json` with different MCP server setups. This project’s MCP setup is defined only in this repo.
- When adding or documenting an MCP server (e.g. Agent Mail), always add it to **`.cursor/mcp.json`** here and document that in this project’s docs.

This is also enforced in **`.cursor/rules/project-context.mdc`** (always-applied rule).

---

## Agent edit approval (permit all edits in tree)

To have the agent apply edits inside this project **without asking for approval** each time (e.g. for `.cursor/mcp.json`), see **docs/CURSOR-EDIT-PERMISSIONS.md**. You can use Cursor Settings (Agents → Auto-Run: turn OFF External-File Protection and Dotfile Protection) or rely on this project’s **`.vscode/settings.json`** if your Cursor version supports those workspace overrides.
