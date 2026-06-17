# 03 — Branching

> **Platform:** Windows | **Shells covered:** PowerShell, Git Bash

---

## Branch Naming Conventions

| Prefix | Purpose | Example |
|---|---|---|
| `feature/` | New feature or enhancement | `feature/user-auth` |
| `bugfix/` | Non-critical bug fix | `bugfix/null-ref-login` |
| `hotfix/` | Urgent fix applied directly from main | `hotfix/payment-crash` |
| `release/` | Release preparation branch | `release/2.1.0` |
| `chore/` | Maintenance, config, dependency updates | `chore/update-nuget` |
| `docs/` | Documentation-only changes | `docs/update-readme` |
| `practice/` | Sandbox practice (this repo only) | `practice/your-name` |

> **Rule:** Use lowercase with hyphens. No spaces. Keep it short but descriptive.

---

## Create a Branch

```powershell
# Classic syntax
git checkout -b feature/my-feature

# Modern syntax (Git 2.23+)
git switch -c feature/my-feature
```

---

## List Branches

```powershell
# Local branches only
git branch

# Remote branches only
git branch -r

# All branches (local + remote)
git branch -a

# Show last commit on each branch
git branch -v
```

---

## Switch Between Branches

```powershell
# Classic
git checkout main

# Modern
git switch main
```

---

## Delete a Branch

```powershell
# Delete local branch (safe — only works if fully merged)
git branch -d feature/my-feature

# Force delete local branch (even if unmerged)
git branch -D feature/my-feature

# Delete remote branch
git push origin --delete feature/my-feature
```

---

## Rename a Branch

```powershell
# Rename the current branch
git branch -m new-name

# Rename a specific branch
git branch -m old-name new-name
```

---

## Push a New Branch to Remote

```powershell
# Push and set upstream tracking in one step
git push -u origin feature/my-feature

# Future pushes on the same branch — no arguments needed
git push
```

---

## Track a Remote Branch Locally

```powershell
# After fetching, create a local branch that tracks a remote one
git checkout -b feature/their-feature origin/feature/their-feature

# Shorthand
git checkout --track origin/feature/their-feature
```

---

## Branching Strategy — Recommended for Azure/GitHub Teams

```
main (or master)          ← protected, always deployable
 └─ release/1.2.0         ← release candidate branches
 └─ feature/user-auth     ← feature branches (from main)
 └─ bugfix/login-error    ← bug fix branches (from main)
 └─ hotfix/critical-fix   ← emergency fixes (from main, merged back fast)
```

**Rules:**
- Never commit directly to `main` or `master`.
- All changes go through Pull Requests.
- Feature branches live short — merge them within a few days to avoid drift.
- Use Azure DevOps **Branch Policies** or GitHub **Branch Protection Rules** to enforce this.

---

## Azure DevOps Branch Policies (Quick Reference)

To configure in Azure DevOps:
1. Go to **Repos → Branches**.
2. Click the `...` menu next to `main` → **Branch policies**.
3. Enable:
   - **Require a minimum number of reviewers** (recommended: 1–2)
   - **Check for linked work items**
   - **Check for comment resolution**
   - **Build validation** (runs your pipeline on every PR)

---

## References
- [Microsoft — Azure DevOps Branching Guidance](https://learn.microsoft.com/en-us/azure/devops/repos/git/git-branching-guidance)
- [GitHub Docs — Branch protection rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
