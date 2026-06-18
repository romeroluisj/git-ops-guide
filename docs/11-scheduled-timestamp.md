# 11 — Scheduled Sandbox Timestamp

> **Platform:** Windows 11 Enterprise | **Shell:** PowerShell
>
> Runs [`sandbox-timestamp.ps1`](../scripts/windows/sandbox-timestamp.ps1)
> on a schedule. Each run writes the date/time to `sandbox/last-run.txt`
> in your local repo and pushes it to the remote `main` branch.
> Only affects remote main; local untouched. Uses git worktree for isolation.

## 1. Copy the script

Copy `sandbox-timestamp.ps1` to any folder. Recommended: `C:\Tools`.

## 2. Set the local repo path

Open the script and set `$RepoPath` (line 16) to your local clone. Its
`origin` is the remote that receives the push.

```powershell
[string]$RepoPath = "C:\Users\$env:USERNAME\path\to\your\local_repo_name"
```

## 3. One-time setup (PowerShell)

```powershell
# allow local scripts
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

# cache git credentials (pick one)
gh auth login
git config --global credential.helper manager
```

## 4. Run once to confirm

If you edited `$RepoPath` in the script (step 2):

```powershell
cd C:\Tools
.\sandbox-timestamp.ps1
```

Or override via command line:

```powershell
cd C:\Tools
.\sandbox-timestamp.ps1 -RepoPath "C:\Users\$env:USERNAME\path\to\your\local_repo_name"
```

Success prints `Pushed to main: ...` (or `No change.`). Verify
`sandbox/last-run.txt` on `main` in GitHub.

## 5. Make it run automatically

Registers a Task Scheduler task (weekdays 9:00 AM & 3:00 PM) for the repo
configured in the script (step 2):

```powershell
.\sandbox-timestamp.ps1 -Register
```

Manage it:

```powershell
Start-ScheduledTask      -TaskName "GitOps-SandboxTimestamp"   # run now
Get-ScheduledTaskInfo    -TaskName "GitOps-SandboxTimestamp"   # next run
Unregister-ScheduledTask -TaskName "GitOps-SandboxTimestamp" `
  -Confirm:$false   # delete
```

Done.
