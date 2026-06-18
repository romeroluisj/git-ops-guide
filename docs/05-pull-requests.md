# 05 — Pull Requests

> **Platform:** Windows | Covers both GitHub PRs and Azure DevOps PRs

---

## What Is a Pull Request?

A Pull Request (PR) is a request to merge your branch into another branch
(usually `main` or `master`). It is the primary code review mechanism in
GitHub and Azure DevOps.

---

## Create a PR — GitHub CLI (Fastest)

```powershell
# Interactive — fills in a form
gh pr create

# With all options inline
gh pr create --base main --title "feat: add user auth" --body "Closes #42"

# Open the browser to fill in the PR form
gh pr create --web
```

---

## Create a PR — GitHub UI

1. Push your branch: `git push -u origin feature/my-feature`
2. Open the repo on GitHub.
3. GitHub shows a yellow banner: **"Compare & pull request"** — click it.
4. Set **base** to `main` (or `master`), **compare** to your branch.
5. Fill in the title and description using the PR template.
6. Assign reviewers, labels, and linked issues.
7. Click **Create pull request**.

---

## Create a PR — Azure DevOps UI

1. Go to **Repos → Pull requests → New pull request**.
2. Set source branch (your feature branch) and target branch (`main`/`master`).
3. Add title, description, reviewers, and linked work items.
4. Click **Create**.

---

## PR Review Checklist

Use this as your personal checklist before submitting a PR:

```text
[ ] Branch is up to date with main/master (no conflicts)
[ ] Code compiles and all tests pass locally
[ ] Commit messages are clear and follow convention
[ ] No debug code, commented-out code, or console logs left behind
[ ] No secrets, passwords, or keys committed
[ ] PR description explains WHAT changed and WHY
[ ] Screenshots included if there are UI changes
[ ] Relevant tests added or updated
[ ] Linked to the work item / ticket (Azure Boards or GitHub Issue)
```

---

## Branch Protection / Branch Policies

### GitHub — Branch Protection Rules

Go to **Settings → Branches → Add rule** on `main`:

| Setting | Recommended value |
|---|---|
| Require a pull request before merging | ✅ Enabled |
| Required approvals | 1 (or 2 for critical repos) |
| Dismiss stale reviews when new commits are pushed | ✅ Enabled |
| Require status checks to pass before merging | ✅ Enabled |
| Require branches to be up to date | ✅ Enabled |
| Restrict who can push to matching branches | ✅ Enabled (admins only) |

### Azure DevOps — Branch Policies

Go to **Repos → Branches → `main` → Branch policies**:

| Policy | Recommended value |
|---|---|
| Require a minimum number of reviewers | 1–2 |
| Check for linked work items | ✅ Enabled |
| Check for comment resolution | ✅ Enabled |
| Limit merge types | Squash merge or Merge commit |
| Build validation | ✅ Add your pipeline |

---

## Merge Strategies

| Strategy | Creates merge commit? | Preserves branch history? | Best for |
|---|---|---|---|
| **Merge commit** | Yes | Yes | Full traceability |
| **Squash and merge** | No (single commit) | No | Clean main history |
| **Rebase and merge** | No | Yes (replayed) | Linear history |

> **Team tip:** Pick one strategy and enforce it through branch policies to
> keep history consistent.

---

## Common PR CLI Commands

```powershell
# List open PRs
gh pr list

# View a specific PR
gh pr view 42

# Check out a PR locally
gh pr checkout 42

# Review a PR (approve, request changes, comment)
gh pr review 42 --approve
gh pr review 42 --request-changes --body "Please add tests"

# Merge a PR
gh pr merge 42 --squash

# Close a PR without merging
gh pr close 42
```

---

## Linking a PR to an Azure Work Item

In the PR description or commit message, use:

```text
Fixes AB#1234
Relates to AB#5678
```

Replace `1234` with the Azure Boards work item ID. Azure DevOps will
automatically link them.

---

## References

- [GitHub Docs — About pull requests](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests)
- [Azure DevOps — Review code with pull requests](https://learn.microsoft.com/en-us/azure/devops/repos/git/pull-requests)
- [Azure DevOps — Branch policies](https://learn.microsoft.com/en-us/azure/devops/repos/git/branch-policies)
