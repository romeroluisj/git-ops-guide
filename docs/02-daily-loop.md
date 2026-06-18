# 02 — The Daily Loop

> The standard workday checklist for a Windows developer using GitHub or Azure DevOps.

---

## The 8-Step Daily Workflow

```text
1. Switch to the default branch
2. Pull latest changes
3. Create your feature branch
4. Make your changes
5. Stage your changes
6. Commit your changes
7. Push your branch to remote
8. Open a Pull Request
```

### Full commands

```powershell
# 1. Switch to the default branch (use main OR master depending on the repo)
git checkout main
# -- or --
git checkout master

# 2. Pull the latest changes from remote
git pull

# 3. Create and switch to a new feature branch
git checkout -b feature/your-feature-name

# 4. Make your changes in your editor / VS Code...

# 5. Stage all changes (or stage specific files)
git add .
# -- or --
git add src/specific-file.cs

# 6. Commit with a meaningful message
git commit -m "feat: describe what this commit does"

# 7. Push your branch to the remote
git push origin feature/your-feature-name
# (First push on a new branch — set upstream tracking)
git push -u origin feature/your-feature-name

# 8. Open a Pull Request
gh pr create --base main --title "feat: your feature" --body "Describe the change"
# -- or open it in the GitHub UI --
gh pr create --web
```

---

## Commit Message Convention (Recommended)

Following [Conventional Commits](https://www.conventionalcommits.org/):

| Prefix | Use for |
|---|---|
| `feat:` | A new feature |
| `fix:` | A bug fix |
| `docs:` | Documentation only |
| `chore:` | Maintenance, dependencies, config |
| `refactor:` | Code change that neither fixes a bug nor adds a feature |
| `test:` | Adding or fixing tests |
| `ci:` | CI/CD pipeline changes |

Examples:

```text
feat: add user login endpoint
fix: correct null check in order processor
docs: update branching guide
chore: upgrade NuGet packages
```

---

## Check Your Status at Any Time

```powershell
# See staged, unstaged, and untracked files
git status

# See a compact one-line version
git status -s

# See what you've changed but not yet staged
git diff

# See what is staged and ready to commit
git diff --staged
```

---

## See Recent Commit History

```powershell
# Last 10 commits, one line each
git log --oneline -10

# Visual branch graph
git log --oneline --graph --all -20
```

---

## End-of-Day Tip

If you are mid-feature and need to stop:

```powershell
# Option 1: commit your work-in-progress
git add .
git commit -m "wip: saving progress on <feature>"
git push origin feature/your-feature-name

# Option 2: stash it (no commit, local only)
git stash save "wip: my feature description"
# Restore next day:
git stash pop
```

---

## References

- [GitHub Docs — GitHub flow](https://docs.github.com/en/get-started/using-github/github-flow)
- [Conventional Commits spec](https://www.conventionalcommits.org/)
