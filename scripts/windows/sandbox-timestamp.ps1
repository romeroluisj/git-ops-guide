# sandbox-timestamp.ps1
# Writes current date/time to sandbox/last-run.txt, commits & pushes.
# Run with -Register to schedule it (weekdays 9AM & 3PM); without it to do the work.
# Usage: .\sandbox-timestamp.ps1 [-Register] -RepoPath "C:\path\to\git-ops-guide"

param(
    [switch]$Register,
    [string]$RepoPath = "C:\Users\$env:USERNAME\Dev\github\git-ops-guide",
    [string]$FileName = "last-run.txt",
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
Set-Location -LiteralPath $RepoPath

$sandbox = Join-Path $RepoPath "sandbox"
if (-not (Test-Path -LiteralPath $sandbox)) { New-Item -ItemType Directory -Path $sandbox | Out-Null }

$offset = (Get-Date -Format "zzz") -replace ":", ""
$line   = "updated on " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " $offset"
$rel    = "sandbox/$FileName"
Set-Content -LiteralPath (Join-Path $sandbox $FileName) -Value $line -Encoding UTF8

git add -- $rel
git diff --cached --quiet
if ($LASTEXITCODE -eq 0) { Write-Host "No change." -ForegroundColor Green; exit 0 }

git commit -m ("chore: update sandbox timestamp " + (Get-Date -Format "yyyy-MM-dd HH:mm"))
git push
if ($LASTEXITCODE -ne 0) { Write-Host "ERROR: push failed (check cached credentials)." -ForegroundColor Red; exit 1 }
Write-Host "Pushed: $line" -ForegroundColor Green
