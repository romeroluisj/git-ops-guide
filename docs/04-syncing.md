# 04 — Syncing Local ↔ Remote

> **Platform:** Windows | **Shells covered:** PowerShell, Git Bash

---

## Core Concepts

- **`git fetch`** — downloads changes from the remote; does NOT modify your
  working files.
- **`git pull`** — `fetch` + `merge`; updates your current branch.
- **`git pull --rebase`** — `fetch` + `rebase`; cleaner history, no extra
  merge commits.
- **`git push`** — uploads your local commits to the remote.

---

## Pull — Get the Latest from Remote

```powershell
# Pull into current branch (merge strategy)
git pull

# Pull with rebase (recommended for cleaner history)
git pull --rebase

# Pull a specific remote branch into current branch
git pull origin main
```

---

## Fetch — Download Without Merging

```powershell
# Fetch all remotes and branches
git fetch

# Fetch a specific remote
git fetch origin

# Fetch and prune deleted remote branches
git fetch --prune
```

After fetching, check what's new:

```powershell
git log HEAD..origin/main --oneline
```

---

## Push — Upload Your Commits

```powershell
# Push current branch (upstream must already be set)
git push

# Push and set upstream tracking at the same time
git push -u origin feature/my-feature

# Push to a specific remote branch
git push origin feature/my-feature

# Push all local branches
git push --all origin
```

---

## Keep Your Feature Branch Up to Date With `main`

When `main` has moved forward while you were working on your branch:

### Option 1 — Merge main into your branch

```powershell
git checkout feature/my-feature
git fetch origin
git merge origin/main
# Resolve any conflicts, then:
git commit
```

### Option 2 — Rebase your branch onto main (cleaner history)

```powershell
git checkout feature/my-feature
git fetch origin
git rebase origin/main
# If conflicts arise, resolve each one, then:
git rebase --continue
# Or bail out completely:
git rebase --abort
```

> **Tip:** After a rebase, if you've already pushed your branch, you'll need to force-push:
>
> ```powershell
> git push --force-with-lease origin feature/my-feature
> ```
>
> Use `--force-with-lease` (not `--force`) — it's safer and won't overwrite
> others' work.

---

## Syncing a Forked Repo With the Upstream

If you forked a repo and need to keep your fork up to date:

```powershell
# Add the original repo as 'upstream' (one-time setup)
git remote add upstream https://github.com/<original-org>/<repo>.git

# Fetch all upstream changes
git fetch upstream

# Merge upstream/main into your local main
git checkout main
git merge upstream/main

# Push your updated main to your fork
git push origin main
```

---

## Handle a Diverged Branch

If your local branch and the remote have diverged (both have unique commits):

```powershell
# See the divergence
git status
# or
git log --oneline --graph HEAD origin/main

# Option 1: Merge (creates a merge commit)
git pull

# Option 2: Rebase (rewrites your commits on top of remote)
git pull --rebase
```

---

## Prune Stale Remote-Tracking References

After remote branches are deleted (e.g., after a merged PR), clean up local references:

```powershell
git fetch --prune
# or
git remote prune origin
```

---

## Automate It (Git Bash)

For a quick personal sync, this repo ships two Git Bash scripts in
[`scripts/bash`](../scripts/README.md):

```bash
# Fetch, fast-forward an integration branch into main/master, and push both
./scripts/bash/git-sync-branches.sh dev main

# Stage + commit (Conventional Commits) and then run the sync above
./scripts/bash/git-commit-and-sync.sh
```

> These are a personal shortcut. For team work, prefer the Pull Request flow in
> [`docs/05-pull-requests.md`](05-pull-requests.md).

---

## References

- [Git Docs — git fetch](https://git-scm.com/docs/git-fetch)
- [Git Docs — git pull](https://git-scm.com/docs/git-pull)
- [Pro Git — Remote Branches](https://git-scm.com/book/en/v2/Git-Branching-Remote-Branches)
