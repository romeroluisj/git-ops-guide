# Git Ops Guide

A practical Git/GitHub handbook for Windows developers working with GitHub
and Azure DevOps.

> **All commands in this repo assume Windows** (PowerShell, Git Bash, or
> Command Prompt / Batch).
> Branch note: new repos use `main`; existing repos may use `main` or
> `master` — always check.

---

## What's Inside

| Section | File | Description |
|---|---|---|
| 00 | [Setup](docs/00-setup.md) | Install Git on Windows, SSH/HTTPS, global config, tools |
| 01 | [Create & Clone](docs/01-create-clone.md) | `git init`, `git clone`, remote origin, first push |
| 02 | [Daily Loop](docs/02-daily-loop.md) | Step-by-step workday checklist |
| 03 | [Branching](docs/03-branching.md) | Naming conventions, create/delete/rename branches |
| 04 | [Syncing](docs/04-syncing.md) | `pull`, `fetch`, `push`, keeping branches up to date |
| 05 | [Pull Requests](docs/05-pull-requests.md) | PR workflow, review checklist, branch policies |
| 06 | [Merge Conflicts](docs/06-merge-conflicts.md) | Detect, resolve, and prevent conflicts |
| 07 | [Emergency Fixes](docs/07-emergency-fixes.md) | Undo commits, fix mistakes, stash, reflog |
| 08 | [Azure DevOps](docs/08-azure-devops.md) | Azure Repos, branch policies, Azure CLI |
| 09 | [CI/CD Basics](docs/09-cicd-basics.md) | GitHub Actions, Azure Pipelines, environments |
| 10 | [Cheat Sheet](docs/10-cheatsheet.md) | Consolidated one-page command reference |

---

## Quick Start — The Daily Workflow

```powershell
# 1. Start from the latest main (or master)
git checkout main
git pull

# 2. Create your feature branch
git checkout -b feature/your-feature-name

# 3. Make changes, then stage and commit
git add .
git commit -m "feat: describe your change"

# 4. Push and open a Pull Request
git push -u origin feature/your-feature-name
gh pr create --web
```

---

## Practice Sandbox

New to Git? The [`/sandbox`](sandbox/README.md) folder is a safe place to
practice the full workflow — clone, branch, commit, push, and open a real
Pull Request.

---

## Scripts

Ready-to-run scripts for Windows in [`/scripts`](scripts/README.md):

**PowerShell / Batch** (`scripts/windows`):

- `setup-git-config.ps1` / `.bat` — configure Git identity on a new machine
- `new-feature-branch.ps1` — interactive branch creator
- `sync-main.ps1` — safely sync main/master at the start of the day

**Git Bash** (`scripts/bash`):

- `git-commit-and-sync.sh` — stage, commit (Conventional Commits), then sync branches
- `git-sync-branches.sh` — fast-forward an integration branch into
  main/master and push

---

## Contributing

1. Fork or clone this repo.
2. Create a branch: `docs/your-improvement`.
3. Make your change, commit, push, open a PR.
4. Use the PR template checklist before submitting.

---

## External References

- [GitHub Docs — Quickstart](https://docs.github.com/en/get-started/quickstart)
- [GitHub Git Cheat Sheet (PDF)](https://training.github.com/downloads/github-git-cheat-sheet.pdf)
- [Pro Git Book (free)](https://git-scm.com/book/en/v2)
- [Azure DevOps — Branching Guidance](https://learn.microsoft.com/en-us/azure/devops/repos/git/git-branching-guidance)
- [Azure Pipelines YAML Schema](https://learn.microsoft.com/en-us/azure/devops/pipelines/yaml-schema)
- [GitHub CLI Manual](https://cli.github.com/manual/)
- [Git for Windows](https://gitforwindows.org/)

---

## License

MIT
