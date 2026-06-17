# Scripts

Automation scripts for Windows developers. All scripts require **Git for Windows** installed.

## `windows/`

| Script | Shell | Purpose |
|---|---|---|
| `setup-git-config.ps1` | PowerShell | Configure global Git identity and recommended settings |
| `setup-git-config.bat` | Batch (CMD) | Same as above — for environments where PowerShell is restricted |
| `new-feature-branch.ps1` | PowerShell | Prompt for branch type/name, pull latest main/master, create and push branch |
| `sync-main.ps1` | PowerShell | Safely sync local main/master with remote at the start of the day |

## `bash/`

For developers who prefer **Git Bash** (bundled with Git for Windows). These are a
personal fast-sync shortcut — for team work, use the Pull Request flow in
[`docs/05-pull-requests.md`](../docs/05-pull-requests.md).

| Script | Shell | Purpose |
|---|---|---|
| `git-commit-and-sync.sh` | Git Bash | Stage all changes, commit with a Conventional Commits message, then sync branches |
| `git-sync-branches.sh` | Git Bash | Fetch, fast-forward merge an integration branch into the default branch (main/master), and push |

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
