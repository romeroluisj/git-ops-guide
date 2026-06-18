# sandbox-timestamp.ps1
# Writes current date/time to sandbox/last-run.txt on main, then commits & pushes.
# Always targets main via an isolated, detached worktree, so it works no matter
# which branch your repo is on and never touches your uncommitted work.
# Run with -Register to schedule it (weekdays 9AM & 3PM); without it to do the work.
# Usage: .\sandbox-timestamp.ps1 [-Register] -RepoPath "C:\path\to\git-ops-guide"
#
# Test now (PowerShell, from this folder):
#   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned   # one-time, if needed
#   .\sandbox-timestamp.ps1                               # runs now; expect green "Pushed: ..."
#   git push fails? run 'gh auth login' once, then retry.

param(
    [switch]$Register,
    # Set this to your local repo path (or pass -RepoPath).
    [string]$RepoPath = "C:\Users\$env:USERNAME\Dev\github\git-ops-guide",
    [string]$FileName = "last-run.txt",
    [string]$Branch   = "main",
    [string]$TaskName = "GitOps-SandboxTimestamp"
)

$ErrorActionPreference = "Stop"

if ($Register) {
    $script = $MyInvocation.MyCommand.Path
    $action = New-ScheduledTaskAction -Execute "powershell.exe" `
        -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$script`" -RepoPath `"$RepoPath`""
    $days = @("Monday","Tuesday","Wednesday","Thursday","Friday")
    $triggers = @(
        (New-ScheduledTaskTrigger -Weekly -DaysOfWeek $days -At 9:00AM),
        (New-ScheduledTaskTrigger -Weekly -DaysOfWeek $days -At 3:00PM)
    )
    $principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive
    $settings  = New-ScheduledTaskSettingsSet -StartWhenAvailable
    Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $triggers `
        -Principal $principal -Settings $settings -Force | Out-Null
    Write-Host "Task '$TaskName' registered: Mon-Fri 9AM & 3PM." -ForegroundColor Green
    return
}

if (-not (Test-Path -LiteralPath (Join-Path $RepoPath ".git"))) {
    Write-Host "ERROR: '$RepoPath' is not a Git repo. Edit -RepoPath." -ForegroundColor Red
    exit 1
}

# Dedicated worktree (in AppData) detached at origin/main: isolated from your
# normal checkout, so the current branch and any uncommitted work are untouched.
$wt = Join-Path $env:LOCALAPPDATA ((Split-Path $RepoPath -Leaf) + "-timestamp-wt")
git -C $RepoPath fetch origin $Branch
git -C $RepoPath worktree prune
if (-not (Test-Path -LiteralPath $wt)) {
    git -C $RepoPath worktree add --detach $wt "origin/$Branch" | Out-Null
}
git -C $wt fetch origin $Branch
git -C $wt reset --hard "origin/$Branch"

$sandbox = Join-Path $wt "sandbox"
if (-not (Test-Path -LiteralPath $sandbox)) { New-Item -ItemType Directory -Path $sandbox | Out-Null }

$offset = (Get-Date -Format "zzz") -replace ":", ""
$line   = "updated on " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " $offset"
Set-Content -LiteralPath (Join-Path $sandbox $FileName) -Value $line -Encoding UTF8

git -C $wt add -- "sandbox/$FileName"
git -C $wt diff --cached --quiet
if ($LASTEXITCODE -eq 0) { Write-Host "No change." -ForegroundColor Green; exit 0 }

git -C $wt commit -m ("chore: update sandbox timestamp " + (Get-Date -Format "yyyy-MM-dd HH:mm")) | Out-Null
git -C $wt push origin "HEAD:$Branch"
if ($LASTEXITCODE -ne 0) { Write-Host "ERROR: push failed (check cached credentials)." -ForegroundColor Red; exit 1 }
Write-Host "Pushed to ${Branch}: $line" -ForegroundColor Green
