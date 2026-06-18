# 01 — Creating & Cloning Repos

> **Platform:** Windows | **Shells covered:** PowerShell, Git Bash

---

## Option A — Create a Brand New Repo (local → GitHub)

### 1. Initialize locally

```powershell
mkdir my-project
cd my-project
git init
# New repos always use 'main' as the default branch
```

### 2. Add your first file and commit

```powershell
New-Item README.md -ItemType File
git add README.md
git commit -m "initial commit"
```

### 3. Create the repo on GitHub and link it

**Via GitHub CLI (recommended):**

```powershell
gh repo create my-project --public --source=. --remote=origin --push
```

**Via GitHub UI:**

1. Go to github.com → **New repository**.
2. Name it, leave "Initialize" unchecked (you already have local commits).
3. Copy the remote URL shown.

```powershell
git remote add origin https://github.com/<username>/my-project.git
# OR with SSH:
git remote add origin git@github.com:<username>/my-project.git

git push -u origin main
```

The `-u` flag sets `origin/main` as the upstream tracking branch so future
`git push` and `git pull` need no arguments.

---

## Option B — Clone an Existing Repo

### Clone with HTTPS

```powershell
git clone https://github.com/<org>/<repo>.git
```

### Clone with SSH

```powershell
git clone git@github.com:<org>/<repo>.git
```

### Clone from Azure Repos (HTTPS + PAT)

```powershell
# Replace <PAT> with your Personal Access Token from Azure DevOps
git clone https://<username>:<PAT>@dev.azure.com/<org>/<project>/_git/<repo>
```

### Clone to a specific folder name

```powershell
git clone https://github.com/<org>/<repo>.git my-local-folder-name
```

---

## Verify Your Remotes

```powershell
git remote -v
# Expected output:
# origin  https://github.com/<org>/<repo>.git (fetch)
# origin  https://github.com/<org>/<repo>.git (push)
```

---

## Common Remote Operations

```powershell
# Add a remote
git remote add origin <url>

# Change the remote URL (e.g., switch from HTTPS to SSH)
git remote set-url origin git@github.com:<org>/<repo>.git

# Remove a remote
git remote remove origin

# Rename a remote
git remote rename origin upstream
```

---

## Important: `main` vs `master`

- **New repo you create** — default branch is `main` (configured in setup).
- **Existing company repo** — check with `git branch -r`; could be `main` or
  `master`.

```powershell
# See all remote branches (shows what the default branch is)
git branch -r
```

---

## References

- [GitHub Docs — Creating a repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-new-repository)
- [GitHub Docs — Cloning a repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository)
- [Azure Repos — Clone a repo](https://learn.microsoft.com/en-us/azure/devops/repos/git/clone)
