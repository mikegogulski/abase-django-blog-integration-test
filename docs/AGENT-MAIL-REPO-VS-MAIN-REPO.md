# Agent Mail repo vs main (workflow) repo

## Layout

- **Main repo:** `workflow/` (project root). You ran `git init .` here.
- **Agent Mail code:** `workflow/mcp_agent_mail/` — currently its own Git repo (it has its own `.git` from the clone).
- **Agent Mail mailbox (storage):** `~/.mcp_agent_mail_git_mailbox_repo` — one directory above the workflow tree (in your home). It is a separate Git repo used by the Agent Mail server for messages/agents/file reservations. It does **not** live inside the main repo, so it cannot conflict with it.

So the only “two repos” that could conflict are: **workflow** (main) and **workflow/mcp_agent_mail** (nested).

## Ways to avoid conflict

Pick one.

### Option A: Submodule (recommended if you want to track Agent Mail version)

Make `mcp_agent_mail` a Git submodule of the main repo. The main repo then stores only a reference (commit) to the Agent Mail repo; no duplicate tracking of the same files.

```bash
# From workflow root, after removing the existing nested clone from the index if needed:
git rm -r --cached mcp_agent_mail 2>/dev/null || true
git submodule add <mcp_agent_mail_clone_url> mcp_agent_mail
# Or if you want to keep the current clone and register it as submodule:
# Remove mcp_agent_mail's .git, then: git submodule add <url> mcp_agent_mail
# (or use git submodule absorbgitdirs if you already have the content)
```

Then the main repo’s `.gitmodules` and `mcp_agent_mail` entry point at one commit of the Agent Mail repo; updates are done with `git submodule update --remote` (or by entering `mcp_agent_mail` and pulling).

### Option B: Ignore the nested repo in the main repo

If you do not need to version Agent Mail inside the workflow repo (e.g. you manage it elsewhere or don’t care to commit it):

Add to **workflow/.gitignore**:

```
mcp_agent_mail/
```

The main repo will ignore the whole directory. No conflict; the main repo simply doesn’t track Agent Mail. The directory stays on disk for running the server.

### Option C: Single repo (absorb Agent Mail into main)

Make Agent Mail “just part of” the workflow repo with no nested `.git`:

1. Delete the nested `.git`:  
   `rm -rf workflow/mcp_agent_mail/.git`
2. Add and commit in the main repo:  
   `git add mcp_agent_mail && git commit -m "Add mcp_agent_mail (no longer a separate repo)"`

Then there is only one repo; no nested repo to conflict. Updating Agent Mail upstream later means copying or merging from a fresh clone (no clean `git pull` inside a submodule).

## Summary

- **Mailbox** (`~/.mcp_agent_mail_git_mailbox_repo`): outside the workflow tree → no conflict with the main repo.
- **Agent Mail code** (`workflow/mcp_agent_mail/`): avoid conflict by either (A) submodule, (B) ignore, or (C) absorb into the main repo as above.
