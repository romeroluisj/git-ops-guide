# PRD — Git Ops Guide

**Product Requirements Document**
Last updated: 2026-06-17
Author: Luis Romero

---

## 1. Purpose & Vision

Build a personal, shareable **Git/GitHub practice handbook** repository that Windows developers working with GitHub and Azure DevOps can use as a daily quick-reference and a safe hands-on learning environment.

The repo functions as **both** a documentation center and a sandbox practice environment.

---

## 2. Target Audience

| Audience | Context |
|---|---|
| Primary | Windows developers at the same organization (coworkers) |
| Secondary | Onboarding engineers new to Git/GitHub/Azure DevOps |
| Environment | Windows (PowerShell, Git Bash, batch scripts), GitHub, Azure DevOps |

---

## 3. Goals

1. Document the most practical, everyday Git and GitHub commands for Windows developers.
2. Cover the full lifecycle: setup → clone/init → daily loop → branching → PRs → merge → release.
3. Provide an "In Case of Emergency" section for the most common mistakes and how to fix them.
4. Include a sandbox folder so coworkers can safely practice the full remote-to-local-to-remote loop.
5. Demonstrate skills employers look for: Git, GitHub, Azure DevOps, Pull Requests, Branch Policies, CI/CD basics, and Release Management.
6. Be immediately useful as a reference — not just a one-time tutorial.

---

## 4. Non-Goals

- This repo does **not** clone or wholesale copy existing cheat sheets.
- This repo does **not** target macOS or Linux as a primary platform.
- This repo does **not** implement a live CI/CD system; it documents how to set one up.

---

## 5. Branch Naming Convention (Project-Wide Rule)

> **New repos:** always use `main` as the default branch.
> **Existing repos:** the default branch may be `main` or `master` — check before assuming.

All documentation and command examples in this repo reference both `main` and `master` where the distinction matters.

---

## 6. Platform Assumptions (IMPORTANT)

> **All commands in this repo assume Windows.**
> Shell targets (in order of preference):
> 1. **PowerShell** (modern, recommended for Azure/GitHub CLI usage)
> 2. **Git Bash** (bundled with Git for Windows — good for Unix-style commands)
> 3. **Command Prompt / Batch** (`.bat` / `.cmd` files; legacy but still common in enterprises)

When a command differs meaningfully across these shells, all variants are provided.

---

## 7. Repository Structure

```
git-ops-guide/
├── PRD.md                          ← this file (product requirements)
├── README.md                       ← entry point; quick-start overview
│
├── docs/
│   ├── 00-setup.md                 ← Git install, SSH vs HTTPS, global config
│   ├── 01-create-clone.md          ← git init, git clone, remote origin
│   ├── 02-daily-loop.md            ← the standard workday checklist
│   ├── 03-branching.md             ← branch strategies, naming conventions
│   ├── 04-syncing.md               ← pull, fetch, push, upstream sync
│   ├── 05-pull-requests.md         ← PR workflow, review checklist, branch policies
│   ├── 06-merge-conflicts.md       ← detecting, resolving, and preventing conflicts
│   ├── 07-emergency-fixes.md       ← undoing commits, wrong branch, reset/revert
│   ├── 08-azure-devops.md          ← Azure Repos, Pipelines, branch policies, releases
│   ├── 09-cicd-basics.md           ← GitHub Actions & Azure Pipelines fundamentals
│   └── 10-cheatsheet.md            ← consolidated one-page command reference
│
├── sandbox/
│   ├── README.md                   ← instructions for sandbox exercises
│   └── .gitkeep
│
├── scripts/
│   ├── windows/
│   │   ├── setup-git-config.ps1    ← PowerShell: configure global git identity
│   │   ├── new-feature-branch.ps1  ← PowerShell: create & push a feature branch
│   │   ├── sync-main.ps1           ← PowerShell: sync local main with remote
│   │   └── setup-git-config.bat    ← Batch equivalent of setup-git-config
│   ├── bash/
│   │   ├── git-commit-and-sync.sh  ← Git Bash: stage, commit, then sync branches
│   │   └── git-sync-branches.sh    ← Git Bash: fast-forward merge into main/master & push
│   └── README.md
│
└── .github/
    ├── PULL_REQUEST_TEMPLATE.md    ← standard PR checklist template
    └── workflows/
        └── validate-docs.yml       ← CI: lint markdown on push/PR
```

---

## 8. Content Requirements by Section

### 8.1 `docs/00-setup.md` — Setup
- Installing Git on Windows (winget, manual installer).
- Configuring global identity (`user.name`, `user.email`).
- SSH key generation on Windows (PowerShell + `ssh-keygen`), adding to GitHub.
- HTTPS vs SSH: when to use each.
- Recommended tools: VS Code, GitHub CLI (`gh`), Azure CLI.

### 8.2 `docs/01-create-clone.md` — Creating & Cloning Repos
- `git init` a new local repo and push it to GitHub.
- `git clone` an existing GitHub/Azure Repo.
- `git remote add origin` / `git remote -v`.
- Cloning with SSH vs HTTPS on Windows.
- First push: `git push -u origin main`.

### 8.3 `docs/02-daily-loop.md` — The Daily Loop
Step-by-step checklist for a standard workday:
```
1. git checkout main  (or master)
2. git pull
3. git checkout -b feature/your-feature
4. <make your changes>
5. git add .
6. git commit -m "feat: describe your change"
7. git push origin feature/your-feature
8. Open Pull Request on GitHub / Azure DevOps
```

### 8.4 `docs/03-branching.md` — Branching
- Branch naming conventions: `feature/`, `bugfix/`, `hotfix/`, `release/`, `chore/`.
- `git branch`, `git checkout -b`, `git switch -c` (modern syntax).
- Deleting local and remote branches.
- Viewing all branches (local + remote).
- Azure DevOps branch policies overview.

### 8.5 `docs/04-syncing.md` — Syncing Local ↔ Remote
- `git fetch` vs `git pull`.
- `git pull --rebase` to keep a clean history.
- Pushing to remote: `git push`, `git push -u origin <branch>`.
- Syncing a fork with upstream.
- Handling diverged branches.

### 8.6 `docs/05-pull-requests.md` — Pull Requests
- PR workflow end-to-end (GitHub and Azure DevOps).
- PR review checklist template.
- Branch protection / branch policies in GitHub and Azure DevOps.
- Squash vs merge vs rebase merge strategies.
- Linking PRs to work items (Azure DevOps).

### 8.7 `docs/06-merge-conflicts.md` — Merge Conflicts
- What causes a merge conflict.
- Detecting conflicts: `git status`, VS Code merge editor.
- Resolving conflicts manually and via VS Code on Windows.
- `git mergetool` setup on Windows.
- Preventing conflicts with good branching habits.

### 8.8 `docs/07-emergency-fixes.md` — In Case of Emergency
| Problem | Solution |
|---|---|
| Committed to the wrong branch | `git cherry-pick` + `git reset` |
| Need to undo last commit, keep changes | `git reset --soft HEAD~1` |
| Need to undo last commit, discard changes | `git reset --hard HEAD~1` |
| Accidentally deleted a file | `git checkout HEAD -- <file>` |
| Pushed something that should not be on remote | `git revert` + force push (with care) |
| Need to stash work in progress | `git stash` / `git stash pop` |
| Merge went wrong | `git merge --abort` |
| Rebase went wrong | `git rebase --abort` |

### 8.9 `docs/08-azure-devops.md` — Azure DevOps
- Azure Repos vs GitHub (differences, when your org uses each).
- Cloning from Azure Repos (SSH and HTTPS with PAT).
- Branch policies in Azure DevOps: required reviewers, build validation, work item linking.
- Connecting GitHub Actions to Azure.
- Azure CLI basics for repo and pipeline management.

### 8.10 `docs/09-cicd-basics.md` — CI/CD Basics
- GitHub Actions: what triggers a workflow, key concepts (workflow, job, step, runner).
- Azure Pipelines: YAML pipeline basics, triggering on branch pushes and PRs.
- Protecting `main`/`master` with required status checks.
- Release management: environments, approvals, release branches.
- Example: a minimal pipeline that runs on every PR to `main`.

### 8.11 `docs/10-cheatsheet.md` — Cheat Sheet
A single-page consolidated reference covering:
- Setup, init/clone, staging, committing, branching, merging, remotes, log/diff, stash, undo, and GitHub CLI commands.
- Organized by task, not by command name.
- Windows shell variants noted where they differ.

---

## 9. Sandbox Exercise Design

The `/sandbox` folder is a safe practice area. Exercise flow for coworkers:

1. Clone this repo (`git clone <url>`).
2. Create a branch: `git checkout -b practice/your-name`.
3. Add a markdown file inside `/sandbox/` (e.g., `your-name-notes.md`).
4. Commit and push: `git push origin practice/your-name`.
5. Open a Pull Request targeting `main`.
6. Practice the PR review + merge flow.
7. Optionally: intentionally create a merge conflict and resolve it.

---

## 10. Scripts Requirements

All scripts live in `scripts/windows/` and must work on Windows with no additional dependencies beyond Git for Windows, PowerShell 5.1+, and optionally GitHub CLI.

| Script | Shell | Purpose |
|---|---|---|
| `setup-git-config.ps1` | PowerShell | Set `user.name`, `user.email`, default editor, line endings |
| `new-feature-branch.ps1` | PowerShell | Prompt for branch name, checkout main, pull, create branch, push |
| `sync-main.ps1` | PowerShell | Checkout main/master, pull latest, report divergence |
| `setup-git-config.bat` | Batch | Same as `.ps1` version for environments where PowerShell is restricted |

---

## 11. GitHub Repository Settings (When Published)

| Setting | Value |
|---|---|
| Default branch | `main` |
| Branch protection on `main` | Require PR, require 1 reviewer, require status checks |
| PR template | `.github/PULL_REQUEST_TEMPLATE.md` |
| Issues | Enabled (for coworkers to suggest additions) |
| Wiki | Disabled (docs live in `/docs`) |
| License | MIT |

---

## 12. External References

- [GitHub Docs — Quickstart](https://docs.github.com/en/get-started/quickstart)
- [GitHub Docs — Hello World](https://docs.github.com/en/get-started/start-your-journey/hello-world)
- [GitHub Git Cheat Sheet (PDF)](https://training.github.com/downloads/github-git-cheat-sheet.pdf)
- [Microsoft — Azure DevOps Branching Guidance](https://learn.microsoft.com/en-us/azure/devops/repos/git/git-branching-guidance)
- [Microsoft — Azure Pipelines YAML Schema](https://learn.microsoft.com/en-us/azure/devops/pipelines/yaml-schema)
- [GitHub CLI Docs](https://cli.github.com/manual/)
- [Git for Windows](https://gitforwindows.org/)
- [Pro Git Book (free)](https://git-scm.com/book/en/v2)

---

## 13. Success Criteria

- [ ] A coworker with zero Git experience can follow `docs/00-setup.md` through `docs/02-daily-loop.md` and make their first commit and PR.
- [ ] A developer can find and apply any "emergency fix" in under 2 minutes using `docs/07-emergency-fixes.md`.
- [ ] All PowerShell scripts run without modification on a stock Windows 10/11 machine with Git for Windows installed.
- [ ] The repo itself demonstrates good Git hygiene: meaningful commits, feature branches, PR template in use.
- [ ] CI workflow passes on every PR to `main`.

---

## 14. Out of Scope (v1)

- macOS / Linux command variants (may be added in v2 as a secondary reference).
- GitLab or Bitbucket workflows.
- Advanced topics: git bisect, submodules, worktrees, signed commits (may be added in v2).
- A live deployed site (GitHub Pages) — possible v2 enhancement.
