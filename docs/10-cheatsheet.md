# 10 — Git Cheat Sheet

> One-page consolidated reference. All commands work on Windows (PowerShell / Git Bash).
> **Branch note:** Use `main` for new repos. Existing repos may use `main` or `master` — check with `git branch -r`.

---

## Setup

```powershell
git config --global user.name "Your Name"
git config --global user.email "you@company.com"
git config --global core.editor "code --wait"
git config --global core.autocrlf true
git config --global init.defaultBranch main
git config --global --list                         # View all settings
```

---

## Create & Clone

```powershell
git init                                           # New local repo
git clone <url>                                    # Clone remote repo
git clone <url> my-folder                          # Clone into specific folder
git remote add origin <url>                        # Link local to remote
git remote -v                                      # Verify remotes
git push -u origin main                            # First push + set upstream
```

---

## Daily Loop

```powershell
git checkout main                                  # Switch to main
git pull                                           # Get latest
git checkout -b feature/my-feature                 # New branch
git add .                                          # Stage all
git add <file>                                     # Stage specific file
git commit -m "feat: description"                  # Commit
git push -u origin feature/my-feature             # Push (first time)
git push                                           # Push (subsequent times)
gh pr create --web                                 # Open PR in browser
```

---

## Status & History

```powershell
git status                                         # What changed?
git status -s                                      # Compact view
git diff                                           # Unstaged changes
git diff --staged                                  # Staged changes
git log --oneline -10                              # Last 10 commits
git log --oneline --graph --all -20                # Visual branch graph
git show <hash>                                    # Show a specific commit
```

---

## Branching

```powershell
git branch                                         # List local branches
git branch -a                                      # List all (local + remote)
git checkout -b <branch>                           # Create + switch
git switch <branch>                                # Switch (modern)
git branch -d <branch>                             # Delete local (safe)
git branch -D <branch>                             # Delete local (force)
git push origin --delete <branch>                  # Delete remote
git branch -m <new-name>                           # Rename current branch
```

---

## Syncing

```powershell
git fetch                                          # Download, don't merge
git fetch --prune                                  # Fetch + clean stale refs
git pull                                           # Fetch + merge
git pull --rebase                                  # Fetch + rebase (cleaner)
git push                                           # Push current branch
git push -u origin <branch>                        # Push + set upstream
git push --force-with-lease                        # Safe force push (after rebase)
```

---

## Merging

```powershell
git merge <branch>                                 # Merge branch into current
git merge --no-ff <branch>                         # Merge with commit (no fast-forward)
git merge --abort                                  # Abort a conflicted merge
git rebase main                                    # Rebase current branch onto main
git rebase --abort                                 # Abort a conflicted rebase
git rebase --continue                              # Continue after resolving conflict
```

---

## Undo / Emergency

```powershell
git reset --soft HEAD~1                            # Undo commit, keep staged
git reset --mixed HEAD~1                           # Undo commit, keep unstaged
git reset --hard HEAD~1                            # Undo commit, discard changes
git revert <hash>                                  # Safe undo (already pushed)
git checkout HEAD -- <file>                        # Restore deleted file
git commit --amend -m "new message"                # Fix last commit message
git rebase -i HEAD~3                               # Interactive rebase (last 3)
git reflog                                         # See all recent HEAD moves
```

---

## Stash

```powershell
git stash                                          # Stash changes
git stash save "description"                       # Stash with label
git stash -u                                       # Stash including untracked
git stash list                                     # List stashes
git stash pop                                      # Apply + remove latest stash
git stash apply stash@{2}                          # Apply specific stash
git stash drop stash@{0}                           # Delete a stash
git stash clear                                    # Delete all stashes
```

---

## GitHub CLI (`gh`)

```powershell
gh auth login                                      # Authenticate
gh repo create <name> --public                     # Create repo
gh pr create --web                                 # Open PR in browser
gh pr list                                         # List open PRs
gh pr checkout <number>                            # Check out a PR locally
gh pr merge <number> --squash                      # Merge PR
gh pr review <number> --approve                    # Approve PR
gh run list                                        # List workflow runs
gh workflow run <workflow-file>                    # Trigger a workflow
```

---

## Azure CLI (`az`)

```powershell
az devops configure --defaults organization=https://dev.azure.com/<org> project=<proj>
az repos list --output table                       # List repos
az repos pr list --output table                    # List PRs
az repos pr create --source-branch <branch> --target-branch main --title "title"
az repos pr update --id <id> --vote approve
```

---

## Tags & Releases

```powershell
git tag                                            # List tags
git tag v1.0.0                                     # Create lightweight tag
git tag -a v1.0.0 -m "Release 1.0.0"              # Annotated tag
git push origin v1.0.0                             # Push a tag
git push origin --tags                             # Push all tags
git tag -d v1.0.0                                  # Delete local tag
git push origin --delete v1.0.0                    # Delete remote tag
```

---

## External Resources

| Resource | URL |
|---|---|
| GitHub Git Cheat Sheet (PDF) | https://training.github.com/downloads/github-git-cheat-sheet.pdf |
| Pro Git Book (free) | https://git-scm.com/book/en/v2 |
| GitHub Docs | https://docs.github.com |
| Azure DevOps Docs | https://learn.microsoft.com/en-us/azure/devops |
| GitHub CLI Manual | https://cli.github.com/manual |
