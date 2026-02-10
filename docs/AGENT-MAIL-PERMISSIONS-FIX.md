# Agent Mail: Permission denied on `.git` (mailbox repo)

## What you see

When calling Agent Mail MCP tools such as `ensure_project` or `create_agent_identity`:

```text
Access denied: Cmd('git') failed due to: exit code(1)
  cmdline: git init
  stderr: '/home/syadasti/.mcp_agent_mail_git_mailbox_repo/.git: Permission denied'
```

## Root cause

1. **Storage root**  
   Agent Mail keeps its mailbox data (one Git repo for all projects) in **`STORAGE_ROOT`**, which defaults to **`~/.mcp_agent_mail_git_mailbox_repo`** (see `mcp_agent_mail` config: `config.py` → `StorageSettings.root`).

2. **Single repo at storage root**  
   The whole mailbox is one Git repo at that path. When the first project is ensured, the server calls `ensure_archive_root()` → `_ensure_repo(root, settings)`. If `root/.git` does not exist, it runs **`Repo.init(str(root))`** (i.e. `git init` in that directory) to create `.git` there (`storage.py` around 1117–1118).

3. **Directory owned by root**  
   On this machine, the directory exists but was created with the wrong owner:

   ```text
   $ ls -la /home/syadasti/.mcp_agent_mail_git_mailbox_repo
   drwx------  2 root root 4096 Feb 10 18:50 .
   ```

   So **`~/.mcp_agent_mail_git_mailbox_repo`** is **root:root**, mode **0700** (only root can read/write/execute). There is no `.git` yet inside it.

4. **Server runs as your user**  
   The Agent Mail HTTP server runs as the same user as Cursor (e.g. `syadasti`), not as root. When it runs `git init` in that directory, Git tries to create `.git` there. The process does not have write (or possibly execute) permission in a root-owned 0700 directory, so the OS returns **EACCES** and Git reports “Permission denied” for `.git`.

So the failure is **not** inside the workflow repo; it is the server (running as your user) trying to create or use `.git` inside a **root-owned** `~/.mcp_agent_mail_git_mailbox_repo`.

## Fix (choose one)

**Option A – Fix ownership (keep existing dir)**  
Give your user ownership of the mailbox directory so the server can create and use `.git`:

```bash
sudo chown -R "$USER:$USER" ~/.mcp_agent_mail_git_mailbox_repo
```

Then (re)start the Agent Mail server and retry `ensure_project` / agent creation.

**Option B – Recreate as your user (empty mailbox)**  
If you don’t need anything in the current mailbox:

```bash
sudo rm -rf ~/.mcp_agent_mail_git_mailbox_repo
```

Then (re)start the Agent Mail server. On first use (e.g. `ensure_project`), the server will create `~/.mcp_agent_mail_git_mailbox_repo` as your user and run `git init` there successfully.

## Why the dir was root-owned

Likely causes: an install or setup script was run with `sudo`, or a container/process ran as root and created `~/.mcp_agent_mail_git_mailbox_repo` under the host user’s home. To avoid it in future, run the Agent Mail server and any commands that create that path **as your normal user**, not root.

## Reference (code)

- **Storage root config:** `mcp_agent_mail/src/mcp_agent_mail/config.py` → `StorageSettings.root` (default `~/.mcp_agent_mail_git_mailbox_repo`).
- **Git init:** `mcp_agent_mail/src/mcp_agent_mail/storage.py` → `ensure_archive_root()` (mkdir), then `_ensure_repo()` → `Repo.init(str(root))` when `root/.git` does not exist.
