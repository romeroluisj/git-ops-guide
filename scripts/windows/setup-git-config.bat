@echo off
REM setup-git-config.bat
REM Configures global Git settings for Windows.
REM Run once on a new machine after installing Git for Windows.
REM Usage: setup-git-config.bat

set /p GIT_NAME=Enter your full name (for Git commits): 
set /p GIT_EMAIL=Enter your work email (for Git commits): 

git config --global user.name "%GIT_NAME%"
git config --global user.email "%GIT_EMAIL%"

REM Set VS Code as default editor
git config --global core.editor "code --wait"

REM Normalize line endings for Windows
git config --global core.autocrlf true

REM Default branch name for new repos
git config --global init.defaultBranch main

REM Use Windows Credential Manager
git config --global credential.helper manager

REM Helpful defaults
git config --global status.showUntrackedFiles all
git config --global pull.rebase false

echo.
echo Git global config saved. Current settings:
git config --global --list
pause
