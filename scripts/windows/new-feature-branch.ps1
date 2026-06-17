# new-feature-branch.ps1
# Creates and pushes a new feature branch from the latest main/master.
# Usage: .\new-feature-branch.ps1

# Detect default branch (main or master)
$defaultBranch = git symbolic-ref refs/remotes/origin/HEAD 2>$null
if ($defaultBranch) {
    $defaultBranch = $defaultBranch -replace "refs/remotes/origin/", ""
} else {
    # Fallback: check if 'main' or 'master' exists on remote
    $remoteBranches = git branch -r
    if ($remoteBranches -match "origin/main") {
        $defaultBranch = "main"
    } elseif ($remoteBranches -match "origin/master") {
        $defaultBranch = "master"
    } else {
        $defaultBranch = "main"
    }
}

Write-Host "Detected default branch: $defaultBranch" -ForegroundColor Cyan

$prefix      = Read-Host "Branch type? (feature / bugfix / hotfix / chore / docs)"
$description = Read-Host "Short description (use-hyphens-not-spaces)"

if (-not $prefix)      { $prefix = "feature" }
if (-not $description) { Write-Host "Description cannot be empty." -ForegroundColor Red; exit 1 }

$branchName = "$prefix/$description"

Write-Host ""
Write-Host "Switching to $defaultBranch and pulling latest..." -ForegroundColor Yellow
git checkout $defaultBranch
git pull

Write-Host "Creating branch: $branchName" -ForegroundColor Yellow
git checkout -b $branchName

Write-Host "Pushing branch to remote..." -ForegroundColor Yellow
git push -u origin $branchName

Write-Host ""
Write-Host "Branch '$branchName' is ready. Happy coding!" -ForegroundColor Green
