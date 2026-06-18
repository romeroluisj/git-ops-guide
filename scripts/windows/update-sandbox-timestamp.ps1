# update-sandbox-timestamp.ps1
# Writes the current date/time as a single line into a sandbox file, then
# commits and pushes the change to the remote. Designed to be run on a
# schedule (see register-timestamp-task.ps1).
#
# Behaviour:
#   - Targets the repo at $RepoPath (edit the default below, or pass -RepoPath).
#   - Creates the 'sandbox' folder inside the repo if it does not exist.
#   - Overwrites the target file so it always holds exactly ONE line:
#       updated on <yyyy-MM-dd HH:mm:ss -0700>
#   - Stages, commits (chore: ...), and pushes to the tracked remote branch.
#
# Usage:
#   .\update-sandbox-timestamp.ps1
#   .\update-sandbox-timestamp.ps1 -RepoPath "C:\path\to\git-ops-guide"
#   .\update-sandbox-timestamp.ps1 -RepoPath "C:\repo" -FileName "last-run.txt"

param(
    # ---- EDIT THIS DEFAULT to your local repo path (you can also pass -RepoPath) ----
    [string]$RepoPath = "C:\Users\$env:USERNAME\Dev\github\git-ops-guide",
    [string]$FileName = "last-run.txt"
)

$ErrorActionPreference = "Stop"

# --- Validate the repo path -----------------------------------------------------
if (-not (Test-Path -LiteralPath $RepoPath)) {
    Write-Host "ERROR: Repo path not found: $RepoPath" -ForegroundColor Red
    Write-Host "Edit the -RepoPath default in this script, or pass -RepoPath." -ForegroundColor Yellow
    exit 1
}
if (-not (Test-Path -LiteralPath (Join-Path $RepoPath ".git"))) {
    Write-Host "ERROR: '$RepoPath' is not a Git repository (no .git folder)." -ForegroundColor Red
    exit 1
}

Set-Location -LiteralPath $RepoPath

# --- Ensure the sandbox folder exists -------------------------------------------
$sandboxDir = Join-Path $RepoPath "sandbox"
if (-not (Test-Path -LiteralPath $sandboxDir)) {
    New-Item -ItemType Directory -Path $sandboxDir | Out-Null
    Write-Host "Created sandbox folder: $sandboxDir" -ForegroundColor Yellow
}

# --- Build the single timestamp line (with timezone, e.g. -0700) ----------------
$offset = (Get-Date -Format "zzz") -replace ":", ""
$line   = "updated on " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " $offset"

$targetFile     = Join-Path $sandboxDir $FileName
$relativeTarget = "sandbox/$FileName"

# Overwrite the file so it contains exactly one line.
Set-Content -LiteralPath $targetFile -Value $line -Encoding UTF8
Write-Host "Wrote: $relativeTarget -> $line" -ForegroundColor Cyan

# --- Stage, commit, and push ----------------------------------------------------
git add -- $relativeTarget

git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "No changes to commit (file content unchanged)." -ForegroundColor Green
    exit 0
}

$commitMsg = "chore: update sandbox timestamp " + (Get-Date -Format "yyyy-MM-dd HH:mm")
git commit -m $commitMsg

# Push to the upstream the current branch tracks.
git push
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: git push failed. Ensure credentials are cached (run 'gh auth login' or use Git Credential Manager)." -ForegroundColor Red
    exit 1
}

Write-Host "Pushed: $commitMsg" -ForegroundColor Green
