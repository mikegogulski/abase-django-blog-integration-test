# Cursor: Permit All Edits in This Project by Default

To stop Cursor from asking for approval on every file edit (including files like `.cursor/mcp.json`), configure Agent so that edits within the project tree are applied without confirmation.

---

## 1. Via Cursor UI (recommended)

These toggles are in **Cursor Settings**, under **Agents → Auto-Run** (search for “auto-run” in Settings).

1. Open **Settings**: `Ctrl+,` (Windows/Linux) or `Cmd+,` (macOS).
2. Go to **Agents → Auto-Run** (or search for **“External-File”** / **“Dotfile”**).
3. **Turn OFF** both:
   - **External-File Protection**
   - **Dotfile Protection**
4. **Reload the window**: `Ctrl+Shift+P` (or `Cmd+Shift+P`) → **“Developer: Reload Window”**.

That makes the agent apply edits (including to config/dotfiles under the project) without asking each time. Cursor’s docs note that **configuration files** normally require approval; turning off these two protections removes that for this workspace.

**Optional:** Under **Features → Chat & Composer**, enable **“Auto-Apply to Files Outside Context”** if you want edits to files not currently in context to be applied automatically as well.

---

## 2. Via workspace settings (project-only)

If your Cursor version respects workspace settings for these options, you can override them **only for this repo** using `.vscode/settings.json` in this project.

This repo includes a **`.vscode/settings.json`** with keys that attempt to disable External-File and Dotfile protection for this workspace. If those keys are valid in your Cursor version, edits in this tree will be permitted by default here without changing your global Cursor settings.

- **If it works:** You get “permit all edits in tree” only when this project is open.
- **If it doesn’t:** Cursor may ignore unknown keys. Use the UI steps above (they apply globally unless Cursor adds workspace override for these later).

To find the exact keys for your version: open **User** `settings.json` (e.g. **Cursor Settings → open as JSON** or from Command Palette), search for “External” or “Dotfile”, and copy the key names. Then add them to this project’s **`.vscode/settings.json`** with the value that means “disabled” (e.g. `false` for protection enabled).

---

## 3. Security note

With these protections off, the agent can edit any file in the project (including `.cursor/mcp.json`, `.vscode/`, dotfiles) without asking. That matches the “YOLO mode” intent for this repo: **blowing up the repo is acceptable**; you can revert with git. Keep WSL/host safety boundaries as in **.cursor/rules/project-context.mdc** (no commands that risk the host).
