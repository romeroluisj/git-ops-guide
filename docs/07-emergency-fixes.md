# 07 — In Case of Emergency

> Quick fixes for the most common Git mistakes. Save this page.

---

## Quick Reference Table

| Problem | Command |
|---|---|
| Undo last commit, keep changes staged | `git reset --soft HEAD~1` |
| Undo last commit, keep changes unstaged | `git reset --mixed HEAD~1` |
| Undo last commit, discard all changes | `git reset --hard HEAD~1` |
| Committed to the wrong branch | See Section 3 |
| Accidentally deleted a file | `git checkout HEAD -- path/to/file` |
| Need to save work-in-progress | `git stash` |
| Restore stashed work | `git stash pop` |
| Merge went wrong | `git merge --abort` |
| Rebase went wrong | `git rebase --abort` |
| Pushed bad code to remote | `git revert <hash>` + `git push` |
| Need to see what I just deleted | `git reflog` |

---

## 1. Undo a Commit (Not Yet Pushed)

### Keep my changes (staged)

```powershell
git reset --soft HEAD~1
# Your changes are back in the staging area, ready to re-commit
```

### Keep my changes (unstaged)

```powershell
git reset --mixed HEAD~1
# Your changes are back in your working directory (not staged)
```

### Discard everything from the last commit

```powershell
git reset --hard HEAD~1
# WARNING: changes are gone permanently
```

---

## 2. Undo Multiple Commits

```powershell
# Undo the last 3 commits, keep changes staged
git reset --soft HEAD~3

# Undo back to a specific commit hash
git reset --soft <commit-hash>
```

Find the hash with:

```powershell
git log --oneline -10
```

---

## 3. Committed to the Wrong Branch

### Scenario: you committed to `main` instead of your feature branch

```powershell
# Step 1: Note the commit hash
git log --oneline -3
# abc1234 feat: my great change   ← this is what you want to move

# Step 2: Create the correct branch (it will include the commit)
git checkout -b feature/correct-branch

# Step 3: Go back to main and remove the commit from it
git checkout main
git reset --hard HEAD~1

# Step 4: Push the correct branch
git push origin feature/correct-branch
```

---

## 4. Accidentally Deleted a File

```powershell
# Restore a deleted file from the last commit
git checkout HEAD -- path/to/deleted-file.cs

# Restore from a specific commit
git checkout <commit-hash> -- path/to/file.cs
```

---

## 5. Stash — Save Work in Progress

```powershell
# Stash all changes (tracked files only)
git stash

# Stash with a description
git stash save "wip: half-done login feature"

# Stash including untracked (new) files
git stash -u

# List all stashes
git stash list

# Apply the most recent stash (keeps the stash)
git stash apply

# Apply and remove the stash
git stash pop

# Apply a specific stash
git stash apply stash@{2}

# Drop a specific stash
git stash drop stash@{0}

# Clear all stashes
git stash clear
```

---

## 6. Undo a Commit That Has Already Been Pushed

> **Do NOT use `git reset` on pushed commits shared with others** — it
> rewrites history and breaks everyone else's local copy.
> Use `git revert` instead — it creates a new commit that undoes the change safely.

```powershell
# Create a revert commit for a specific commit
git revert <commit-hash>

# Revert without immediately opening the editor
git revert <commit-hash> --no-edit

# Push the revert
git push origin main
```

---

## 7. Recover a Deleted Branch or Lost Commit (Reflog)

Git keeps a local log of every HEAD movement for ~90 days.

```powershell
# See the reflog
git reflog

# Sample output:
# abc1234 HEAD@{0}: checkout: moving from feature/old to main
# def5678 HEAD@{1}: commit: feat: my lost commit
# ...

# Restore a deleted branch using its last commit hash
git checkout -b feature/recovered def5678
```

---

## 8. Interactive Rebase — Edit/Squash/Reorder Commits

> Only do this on commits **not yet pushed** to a shared branch.

```powershell
# Interactively rebase the last 3 commits
git rebase -i HEAD~3
```

In the editor, change `pick` to:

- `squash` (or `s`) — combine with previous commit
- `reword` (or `r`) — edit the commit message
- `drop` (or `d`) — delete the commit entirely
- `edit` (or `e`) — pause to amend the commit

---

## 9. Fix the Last Commit Message

```powershell
# Change the message of the very last commit (not yet pushed)
git commit --amend -m "corrected commit message"
```

---

## 10. Restore a Single File to a Previous Version

```powershell
# Restore a file to the version from 2 commits ago
git checkout HEAD~2 -- path/to/file.cs

# Restore a file from a specific branch
git checkout main -- path/to/file.cs
```

---

## References

- [Pro Git — Reset Demystified](https://git-scm.com/book/en/v2/Git-Tools-Reset-Demystified)
- [GitHub Docs — Reverting a pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/incorporating-changes-from-a-pull-request/reverting-a-pull-request)
