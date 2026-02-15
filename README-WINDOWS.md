# Windows Users: Symlinks and Skills

This project uses symlinks so that skills installed in `.agents/skills/` are available to your AI IDE. On WSL, macOS, and Linux, these symlinks work normally. On Windows, Git and the filesystem can cause problems.

## The Problem

When you clone this repository on Windows, Git may not create real symlinks. Instead, it can store them as small text files that contain the target path. As a result:

- Skills under `.cursor/skills/` (or your IDE's equivalent) may appear broken or empty
- Your IDE may not discover the skills correctly

*Note: Paths like `.cursor/skills/` are examples for Cursor. If you use a different AI IDE (e.g. Codex, Claude Code), use the path that IDE expects—such as `.codex/skills/` or `.claude/skills/`—and apply the same logic below.*

## Mitigation Options

### Option A: Enable Git symlinks (recommended if you can)

1. Enable **Developer Mode** in Windows (Settings → Privacy & security → For developers → Developer Mode), or run Git as Administrator.
2. Configure Git to create symlinks:
   ```bash
   git config core.symlinks true
   ```
3. Re-clone the repository (or remove and re-add the affected files) so Git creates real symlinks.

### Option B: Recreate symlinks after clone

If you cannot enable symlinks in Git, run a script after cloning to recreate the symlinks. From the repository root:

**PowerShell (run as Administrator or with Developer Mode enabled):**

```powershell
$agentsPath = Join-Path $PSScriptRoot ".agents\skills"
$cursorPath = Join-Path $PSScriptRoot ".cursor\skills"
if (Test-Path $agentsPath) {
    New-Item -ItemType Directory -Force -Path $cursorPath | Out-Null
    Get-ChildItem $agentsPath -Directory | ForEach-Object {
        $link = Join-Path $cursorPath $_.Name
        if (-not (Test-Path $link)) {
            New-Item -ItemType SymbolicLink -Path $link -Target $_.FullName
        }
    }
}
```

**Git Bash or WSL:**

```bash
#!/bin/bash
AGENTS=".agents/skills"
CURSOR=".cursor/skills"
mkdir -p "$CURSOR"
for dir in "$AGENTS"/*/; do
  name=$(basename "$dir")
  if [ ! -e "$CURSOR/$name" ]; then
    ln -s "$(realpath "$dir")" "$CURSOR/$name"
  fi
done
```

Replace `.cursor/skills` with your IDE's skills path (e.g. `.codex/skills`, `.claude/skills`) if needed.

### Option C: Copy instead of symlink

If symlinks are not an option, copy the skill directories instead of linking them:

```powershell
# PowerShell
Copy-Item -Path ".agents\skills\*" -Destination ".cursor\skills\" -Recurse -Force
```

```bash
# Bash
cp -r .agents/skills/* .cursor/skills/
```

Replace `.cursor/skills` with your IDE's skills directory if you use a different AI IDE.

**Caveat:** Copies will not update when you run `npx skills update`. You must re-copy after updating skills.

## Verifying

After applying one of the options above:

1. Open your AI IDE in this project.
2. Check that skills appear (e.g. in Settings → Rules, or by typing `/` in agent chat).
3. If skills are missing, confirm the target path matches what your IDE expects (`.cursor/skills`, `.codex/skills`, `.claude/skills`, etc.).
