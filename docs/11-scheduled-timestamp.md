# 11 — Scheduled Sandbox Timestamp

> **Platform:** Windows 11 Enterprise | **Shell:** PowerShell
>
> Runs [`sandbox-timestamp.ps1`](../scripts/windows/sandbox-timestamp.ps1)
> on a schedule. Each run writes the date/time to `sandbox/last-run.txt`
> in your local repo and pushes it to the remote `main` branch.
> Only affects remote main; local untouched. Uses git worktree for isolation.

## Easy path: run the installer

For most users, use the one-time installer
[`AutoPushTask/Install-AutoPushTask.ps1`](../scripts/windows/AutoPushTask/Install-AutoPushTask.ps1).
It does everything below automatically.

In PowerShell, from the folder that contains the installer:

```powershell
.\Install-AutoPushTask.ps1
```

It will:

- copy `sandbox-timestamp.ps1` into `C:\Tools`
- allow local scripts (RemoteSigned, current user)
- ask for your local repo folder **once** (picker or paste), then save it
- run once so you can confirm the push to remote `main`
- on your `y`/`n`, register the weekday 9 AM & 3 PM task

The repo path is saved to a config file
(`%LOCALAPPDATA%\sandbox-timestamp\config.json`). Every later run — manual
or scheduled — reads it, so you are never prompted again. You still need
cached git credentials (see step 3 below) so pushes work unattended.

---

The manual steps below do the same thing by hand.

## 1. Copy the script

Copy `sandbox-timestamp.ps1` to any folder. Recommended: `C:\Tools`.

## 2. Set the local repo path

The script resolves the repo path in this order:

1. `-RepoPath` argument (explicit override)
2. saved config file (`%LOCALAPPDATA%\sandbox-timestamp\config.json`)
3. built-in default

To save it once, write the config file:

```powershell
$cfg = "$env:LOCALAPPDATA\sandbox-timestamp\config.json"
New-Item -ItemType Directory -Force -Path (Split-Path $cfg) | Out-Null
'{ "RepoPath": "C:\\Users\\you\\path\\to\\your\\repo" }' |
  Set-Content -LiteralPath $cfg -Encoding UTF8
```

## 3. One-time setup (PowerShell)

```powershell
# allow local scripts
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

# cache git credentials (pick one)
gh auth login
git config --global credential.helper manager
```

## 4. Run once to confirm (PowerShell)

Using the saved config (step 2):

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

## 5. Make it run automatically (PowerShell)

Registers a Task Scheduler task (weekdays 9:00 AM & 3:00 PM). The task
reads the saved config at run time:

```powershell
.\sandbox-timestamp.ps1 -Register
```

Manage it (PowerShell):

```powershell
Start-ScheduledTask      -TaskName "GitOps-SandboxTimestamp"   # run task now
Get-ScheduledTaskInfo    -TaskName "GitOps-SandboxTimestamp"   # next task run
Unregister-ScheduledTask -TaskName "GitOps-SandboxTimestamp" `
  -Confirm:$false   # delete task
```

Done.
