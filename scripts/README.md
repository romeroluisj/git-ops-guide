# Scripts

Automation scripts for Windows developers. All scripts require
**Git for Windows** installed.

## `windows/`

- **`setup-git-config.ps1`** (PowerShell) — configure global Git identity
  and recommended settings.
- **`setup-git-config.bat`** (Batch/CMD) — same as above, for environments
  where PowerShell is restricted.
- **`new-feature-branch.ps1`** (PowerShell) — prompt for branch type/name,
  pull latest main/master, create and push the branch.
- **`sync-main.ps1`** (PowerShell) — safely sync local main/master with the
  remote at the start of the day.
- **`sandbox-timestamp.ps1`** (PowerShell) — overwrite `sandbox/last-run.txt`
  with the current timestamp, commit & push. Use `-Register` to schedule it
  (weekdays 9 AM & 3 PM).
- **`AutoPushTask/Install-AutoPushTask.ps1`** (PowerShell) — one-time
  installer that copies `sandbox-timestamp.ps1` to `C:\Tools`, asks for your
  repo path once (saved to a config file), runs it once, then registers the
  schedule. Easiest way to set up `sandbox-timestamp.ps1`.

## `bash/`

For developers who prefer **Git Bash** (bundled with Git for Windows).
These are a personal fast-sync shortcut — for team work, use the Pull
Request flow in [`docs/05-pull-requests.md`](../docs/05-pull-requests.md).

- **`git-commit-and-sync.sh`** (Git Bash) — stage all changes, commit with a
  Conventional Commits message, then sync branches.
- **`git-sync-branches.sh`** (Git Bash) — fetch, fast-forward merge an
  integration branch into the default branch (main/master), and push.

Both scripts auto-detect `main` vs `master` and accept optional branch arguments:

```bash
# Auto-detect default branch; integration branch = current branch
./git-sync-branches.sh

# Merge 'dev' into the auto-detected default branch
./git-sync-branches.sh dev

# Merge 'dev' into 'main' explicitly
./git-sync-branches.sh dev main
```

## How to Run PowerShell Scripts

If you see an error about execution policy:

```powershell
# Allow scripts for the current user (one-time setup)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Then run a script:

```powershell
cd scripts\windows
.\setup-git-config.ps1
```

## How to Run Batch Scripts

Double-click the `.bat` file, or run from Command Prompt:

```cmd
cd scripts\windows
setup-git-config.bat
```

## How to Run Bash Scripts

Open **Git Bash** (right-click in a folder → "Git Bash Here"), then:

```bash
cd scripts/bash

# Run directly (scripts are already marked executable)
./git-commit-and-sync.sh

# Or invoke with bash explicitly if the executable bit was lost on Windows
bash git-commit-and-sync.sh
```

If you get a `Permission denied` error, restore the executable bit:

```bash
chmod +x scripts/bash/*.sh
```

## Scheduled Timestamp (Windows Task Scheduler)

`sandbox-timestamp.ps1` writes a single line (`updated on <date time -0700>`)
into `sandbox/last-run.txt`, then commits and pushes it. It creates the `sandbox`
folder if missing and targets the repo given by `-RepoPath`. One script does both
jobs: the timestamp work by default, and the scheduling with `-Register`.

It always commits to **main** via an isolated, detached worktree (kept in
`%LOCALAPPDATA%`), so it works no matter which branch your repo is currently on
and never disturbs your uncommitted work.

**Easiest: run the installer.** `AutoPushTask\Install-AutoPushTask.ps1` does all
the steps below for you (prompts for the repo path once, saves it, runs once,
registers the schedule):

```powershell
cd scripts\windows\AutoPushTask
.\Install-AutoPushTask.ps1
```

To do it manually instead:

**1. Set your repo path.** The script resolves it by precedence: `-RepoPath`
argument, then the saved config file
(`%LOCALAPPDATA%\sandbox-timestamp\config.json`), then a built-in default. Pass
it explicitly:

```powershell
cd scripts\windows
.\sandbox-timestamp.ps1 -RepoPath "C:\Users\you\Dev\github\git-ops-guide"
```

**2. Make sure git can push without prompting.** The scheduled run is
non-interactive, so credentials must be cached first — run `gh auth login` once,
or `git config --global credential.helper manager` (see `setup-git-config.ps1`).

**3. Register the schedule (weekdays at 9:00 AM and 3:00 PM).** The task reads
the saved config at run time:

```powershell
.\sandbox-timestamp.ps1 -Register
```

Manage the task:

```powershell
Start-ScheduledTask     -TaskName "GitOps-SandboxTimestamp"   # run now to test
Get-ScheduledTask       -TaskName "GitOps-SandboxTimestamp"   # view it
Unregister-ScheduledTask -TaskName "GitOps-SandboxTimestamp" -Confirm:$false  # remove
```
