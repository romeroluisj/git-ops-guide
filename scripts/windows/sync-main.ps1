# sync-main.ps1
# Syncs your local main (or master) branch with the remote.
# Safe to run at the start of any workday.
# Usage: .\sync-main.ps1

# Detect default branch (main or master)
$defaultBranch = git symbolic-ref refs/remotes/origin/HEAD 2>$null
if ($defaultBranch) {
    $defaultBranch = $defaultBranch -replace "refs/remotes/origin/", ""
} else {
    $remoteBranches = git branch -r
    if ($remoteBranches -match "origin/main") {
        $defaultBranch = "main"
    } elseif ($remoteBranches -match "origin/master") {
        $defaultBranch = "master"
    } else {
        $defaultBranch = "main"
    }
}

Write-Host "Default branch detected: $defaultBranch" -ForegroundColor Cyan

# Check for uncommitted changes
$status = git status --porcelain
if ($status) {
    Write-Host ""
    Write-Host "WARNING: You have uncommitted changes. Stash or commit them before syncing." -ForegroundColor Red
    git status -s
    exit 1
}

Write-Host "Switching to $defaultBranch..." -ForegroundColor Yellow
git checkout $defaultBranch

Write-Host "Fetching from remote (pruning stale branches)..." -ForegroundColor Yellow
git fetch --prune

$localHash  = git rev-parse $defaultBranch
$remoteHash = git rev-parse "origin/$defaultBranch"

if ($localHash -eq $remoteHash) {
    Write-Host ""
    Write-Host "Already up to date with origin/$defaultBranch" -ForegroundColor Green
} else {
    Write-Host "Pulling latest changes..." -ForegroundColor Yellow
    git pull

    Write-Host ""
    Write-Host "Synced successfully. Latest commits:" -ForegroundColor Green
    git log --oneline -5
}
