# register-timestamp-task.ps1
# Registers a Windows Task Scheduler job that runs update-sandbox-timestamp.ps1
# every weekday (Mon-Fri) at 9:00 AM and 3:00 PM.
#
# Run this ONCE (in a normal, non-admin PowerShell window is fine since the task
# runs as the current user). Re-running updates the existing task.
#
# Usage:
#   .\register-timestamp-task.ps1
#   .\register-timestamp-task.ps1 -RepoPath "C:\path\to\git-ops-guide"
#   .\register-timestamp-task.ps1 -TaskName "GitOps-SandboxTimestamp"

param(
    [string]$RepoPath = "C:\Users\$env:USERNAME\Dev\github\git-ops-guide",
    [string]$TaskName = "GitOps-SandboxTimestamp"
)

$ErrorActionPreference = "Stop"

# The worker script lives next to this one.
$scriptPath = Join-Path $PSScriptRoot "update-sandbox-timestamp.ps1"
if (-not (Test-Path -LiteralPath $scriptPath)) {
    Write-Host "ERROR: Cannot find update-sandbox-timestamp.ps1 next to this script." -ForegroundColor Red
    exit 1
}

# Action: run PowerShell, bypassing execution policy, calling the worker script.
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -RepoPath `"$RepoPath`""

# Two weekday triggers: 9:00 AM and 3:00 PM.
$days = @("Monday","Tuesday","Wednesday","Thursday","Friday")
$trigger9  = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $days -At 9:00AM
$trigger15 = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $days -At 3:00PM

# Run as the current user, only when logged on (so cached git credentials are available).
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive

# Be resilient: if the machine was off at trigger time, run as soon as possible.
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd

Register-ScheduledTask -TaskName $TaskName `
    -Action $action `
    -Trigger @($trigger9, $trigger15) `
    -Principal $principal `
    -Settings $settings `
    -Description "Writes a timestamp into sandbox/last-run.txt and pushes it. Runs weekdays 9AM and 3PM." `
    -Force | Out-Null

Write-Host "Scheduled task '$TaskName' registered." -ForegroundColor Green
Write-Host "Triggers: Mon-Fri at 9:00 AM and 3:00 PM." -ForegroundColor Cyan
Write-Host ""
Write-Host "Verify:        Get-ScheduledTask -TaskName '$TaskName'" -ForegroundColor Yellow
Write-Host "Run it now:    Start-ScheduledTask -TaskName '$TaskName'" -ForegroundColor Yellow
Write-Host "Remove it:     Unregister-ScheduledTask -TaskName '$TaskName' -Confirm:`$false" -ForegroundColor Yellow
