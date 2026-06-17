# setup-git-config.ps1
# Configures global Git settings for Windows.
# Run once on a new machine after installing Git for Windows.
# Usage: .\setup-git-config.ps1

$name  = Read-Host "Enter your full name (for Git commits)"
$email = Read-Host "Enter your work email (for Git commits)"

git config --global user.name  $name
git config --global user.email $email

# Set VS Code as default editor (requires VS Code in PATH)
git config --global core.editor "code --wait"

# Normalize line endings: CRLF on Windows checkout, LF on commit
git config --global core.autocrlf true

# Default branch name for new repos
git config --global init.defaultBranch main

# Use Windows Credential Manager (handles HTTPS auth automatically)
git config --global credential.helper manager

# Helpful default options
git config --global status.showUntrackedFiles all
git config --global pull.rebase false

Write-Host ""
Write-Host "Git global config saved. Current settings:" -ForegroundColor Green
git config --global --list
