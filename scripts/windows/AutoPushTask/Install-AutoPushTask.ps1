# Install-AutoPushTask.ps1 - one-time installer for the sandbox-timestamp automation.
# Platform: Windows 11 Enterprise | Shell: PowerShell
#
# What it does (run once, by hand):
#   1. Ensures C:\Tools exists.
#   2. Copies sandbox-timestamp.ps1 into C:\Tools.
#   3. Allows local scripts (Set-ExecutionPolicy RemoteSigned, current user).
#   4. Resolves your local repo path: reuses the saved config if present,
#      otherwise prompts once (folder picker, or paste in the console).
#   5. Saves the repo path to a config file (single source of truth).
#   6. Runs the worker once so you can confirm it pushed to remote main.
#   7. On your y/n confirmation, registers the scheduled task
#      (weekdays 9:00 AM & 3:00 PM). The task reads the saved config.
#
# Usage (PowerShell, from the folder that contains this file):
#   .\Install-AutoPushTask.ps1

[CmdletBinding()]
param(
    [string]$InstallDir = "C:\Tools",                                      # where the worker lives
    [string]$WorkerName = "sandbox-timestamp.ps1",                         # worker file name
    [string]$ConfigPath = "$env:LOCALAPPDATA\sandbox-timestamp\config.json" # saved repo path
)

$ErrorActionPreference = "Stop"

function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }

# --- locate this installer's folder and the worker script ---------------
$ScriptDir = Split-Path -Parent $PSCommandPath
$workerSource = $null
foreach ($candidate in @(
    (Join-Path $ScriptDir $WorkerName),            # same folder (distributed layout)
    (Join-Path (Split-Path -Parent $ScriptDir) $WorkerName)  # parent (repo layout)
)) {
    if (Test-Path -LiteralPath $candidate) { $workerSource = $candidate; break }
}
if (-not $workerSource) {
    Write-Host "ERROR: could not find $WorkerName next to this installer." -ForegroundColor Red
    exit 1
}

# --- 1. ensure install dir ----------------------------------------------
Write-Step "Ensuring $InstallDir exists"
if (-not (Test-Path -LiteralPath $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir | Out-Null
}

# --- 2. copy the worker --------------------------------------------------
Write-Step "Copying $WorkerName to $InstallDir"
$workerDest = Join-Path $InstallDir $WorkerName
Copy-Item -LiteralPath $workerSource -Destination $workerDest -Force

# --- 3. allow local scripts ---------------------------------------------
Write-Step "Allowing local scripts for current user (RemoteSigned)"
try {
    Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
} catch {
    Write-Host "WARN: could not set execution policy automatically." -ForegroundColor Yellow
}

# --- 4. resolve the repo path (prompt only the first time) --------------
function Test-RepoPath($path) {
    return ($path -and (Test-Path -LiteralPath (Join-Path $path ".git")))
}

function Get-RepoFromDialog {
    try {
        Add-Type -AssemblyName System.Windows.Forms
        $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
        $dlg.Description = "Select your local git repo folder"
        $dlg.ShowNewFolderButton = $false
        if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            return $dlg.SelectedPath
        }
    } catch {
        return $null   # no GUI available; caller falls back to console
    }
    return $null
}

$repo = $null
if (Test-Path -LiteralPath $ConfigPath) {
    try {
        $saved = (Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json).RepoPath
        if (Test-RepoPath $saved) {
            $repo = $saved
            Write-Step "Reusing saved repo path: $repo"
        }
    } catch { }
}

if (-not $repo) {
    Write-Step "Select your local git repo folder"
    while (-not (Test-RepoPath $repo)) {
        $repo = Get-RepoFromDialog
        if (-not $repo) {
            $repo = Read-Host "Paste the full path to your local repo (or blank to cancel)"
        }
        if (-not $repo) { Write-Host "Cancelled." -ForegroundColor Yellow; exit 1 }
        if (-not (Test-RepoPath $repo)) {
            Write-Host "Not a git repo (no .git found): $repo" -ForegroundColor Red
            $repo = $null
        }
    }

    # --- 5. save config (single source of truth) ------------------------
    Write-Step "Saving repo path to $ConfigPath"
    $cfgDir = Split-Path -Parent $ConfigPath
    if (-not (Test-Path -LiteralPath $cfgDir)) {
        New-Item -ItemType Directory -Path $cfgDir | Out-Null
    }
    [pscustomobject]@{ RepoPath = $repo } |
        ConvertTo-Json | Set-Content -LiteralPath $ConfigPath -Encoding UTF8
}

# --- 6. run once to confirm ---------------------------------------------
Write-Step "Running the worker once"
& $workerDest -RepoPath $repo -ConfigPath $ConfigPath
Write-Host ""
Write-Host "Now open your repo on GitHub, switch to 'main', and confirm" -ForegroundColor Yellow
Write-Host "that sandbox/last-run.txt was updated." -ForegroundColor Yellow

# --- 7. confirm, then register the scheduled task -----------------------
$answer = Read-Host "Did it work? Register the automatic schedule? (y/n)"
if ($answer -match '^(y|yes)$') {
    Write-Step "Registering scheduled task (weekdays 9 AM & 3 PM)"
    & $workerDest -Register -ConfigPath $ConfigPath
    Write-Host "Done. The task will run automatically." -ForegroundColor Green
} else {
    Write-Host "Skipped scheduling. You can re-run this installer later." -ForegroundColor Yellow
}
