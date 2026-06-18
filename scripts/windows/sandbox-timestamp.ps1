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
    [switch]$Register,                              # register task?
    # Set this to your local repo path (or pass -RepoPath).
    [string]$RepoPath = "C:\Users\$env:USERNAME\Dev\github\git-ops-guide",
    [string]$FileName = "last-run.txt",             # output file
    [string]$Branch   = "main",                     # target branch
    [string]$TaskName = "GitOps-SandboxTimestamp"   # task name
)

$ErrorActionPreference = "Stop"                     # stop on errors

if ($Register) {
    $script = $MyInvocation.MyCommand.Path         # get script path
    $action = New-ScheduledTaskAction -Execute "powershell.exe" `
        -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$script`" -RepoPath `"$RepoPath`""  # task action
    $days = @("Monday","Tuesday","Wednesday","Thursday","Friday")  # weekdays
    $triggers = @(
        (New-ScheduledTaskTrigger -Weekly -DaysOfWeek $days -At 9:00AM),  # 9AM trigger
        (New-ScheduledTaskTrigger -Weekly -DaysOfWeek $days -At 3:00PM)   # 3PM trigger
    )
    $principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive  # run as user
    $settings  = New-ScheduledTaskSettingsSet -StartWhenAvailable  # start when available
    Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $triggers `
        -Principal $principal -Settings $settings -Force | Out-Null  # register task
    Write-Host "Task '$TaskName' registered: Mon-Fri 9AM & 3PM." -ForegroundColor Green
    return                                            # exit
}

if (-not (Test-Path -LiteralPath (Join-Path $RepoPath ".git"))) {  # validate repo
    Write-Host "ERROR: '$RepoPath' is not a Git repo. Edit -RepoPath." -ForegroundColor Red
    exit 1
}

# Dedicated worktree detached at origin/main: a separate checkout isolated from
# your normal repo, so the current branch and any uncommitted work are untouched.
# Created on first run, reused after, at:
#   C:\Users\<you>\AppData\Local\<repo-name>-timestamp-wt
# It lives OUTSIDE your repo; the script never modifies your normal checkout.
$wt = Join-Path $env:LOCALAPPDATA ((Split-Path $RepoPath -Leaf) + "-timestamp-wt")  # worktree path
git -C $RepoPath fetch origin $Branch               # fetch remote
git -C $RepoPath worktree prune                      # clean stale worktrees
if (-not (Test-Path -LiteralPath $wt)) {             # worktree exists?
    git -C $RepoPath worktree add --detach $wt "origin/$Branch" | Out-Null  # create worktree
}
git -C $wt fetch origin $Branch                      # fetch worktree
git -C $wt reset --hard "origin/$Branch"            # reset to origin/main

$sandbox = Join-Path $wt "sandbox"                   # sandbox dir
if (-not (Test-Path -LiteralPath $sandbox)) { New-Item -ItemType Directory -Path $sandbox | Out-Null }  # create sandbox

$offset = (Get-Date -Format "zzz") -replace ":", ""  # timezone offset
$line   = "updated on " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " $offset"  # timestamp line
Set-Content -LiteralPath (Join-Path $sandbox $FileName) -Value $line -Encoding UTF8  # write file

git -C $wt add -- "sandbox/$FileName"                # stage file
git -C $wt diff --cached --quiet                     # check for changes
if ($LASTEXITCODE -eq 0) { Write-Host "No change." -ForegroundColor Green; exit 0 }  # no change? exit

git -C $wt commit -m ("chore: update sandbox timestamp " + (Get-Date -Format "yyyy-MM-dd HH:mm")) | Out-Null  # commit
git -C $wt push origin "HEAD:$Branch"               # push to remote
if ($LASTEXITCODE -ne 0) { Write-Host "ERROR: push failed (check cached credentials)." -ForegroundColor Red; exit 1 }  # push failed?
Write-Host "Pushed to ${Branch}: $line" -ForegroundColor Green  # success
