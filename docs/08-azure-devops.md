# 08 — Azure DevOps

> **Platform:** Windows | Azure DevOps (Azure Repos, Azure Pipelines, Azure Boards)

---

## Azure Repos vs GitHub

| Feature | Azure Repos | GitHub |
|---|---|---|
| Hosting | Microsoft Azure | GitHub (Microsoft-owned) |
| Integration | Deep Azure DevOps integration | GitHub Actions, Marketplace |
| Work items | Azure Boards (linked natively) | GitHub Issues / Projects |
| Access control | Azure Active Directory | GitHub org/teams |
| Private repos | Unlimited (free tier) | Unlimited (free tier) |
| Git commands | Identical — same Git | Identical — same Git |

> **The Git commands are the same.** The difference is in the web UI, CI/CD
> tooling, and access management.

---

## Clone from Azure Repos

### HTTPS with Personal Access Token (PAT)

1. In Azure DevOps, go to **User Settings → Personal Access Tokens → New Token**.
2. Scope: **Code → Read & write**.
3. Copy the generated token.

```powershell
git clone https://<username>:<PAT>@dev.azure.com/<org>/<project>/_git/<repo>
```

Or let Windows Credential Manager handle it:

```powershell
git clone https://dev.azure.com/<org>/<project>/_git/<repo>
# A browser window opens for Azure AD authentication — credentials are saved.
```

### SSH

1. In Azure DevOps, go to **User Settings → SSH public keys → Add**.
2. Paste your public key (`~/.ssh/id_ed25519.pub`).

```powershell
git clone git@ssh.dev.azure.com:v3/<org>/<project>/<repo>
```

---

## The Daily Loop on Azure Repos

Exactly the same as GitHub — the remote URL is the only difference.

```powershell
# Check your remote
git remote -v
# origin  https://dev.azure.com/<org>/<project>/_git/<repo> (fetch)

# Pull, branch, commit, push — identical commands
git checkout main
git pull
git checkout -b feature/my-feature
# ... make changes ...
git add .
git commit -m "feat: my change"
git push -u origin feature/my-feature
```

Then open a PR in the Azure DevOps web UI (Repos → Pull requests).

---

## Branch Policies in Azure DevOps

Branch policies protect `main` (or `master`) from direct pushes.

**Setup:**

1. **Repos → Branches → `main` → `...` menu → Branch policies**.

| Policy | Description | Recommended |
|---|---|---|
| Require a minimum number of reviewers | At least 1 required approver | ✅ |
| Check for linked work items | Must reference an Azure Board item | Optional |
| Check for comment resolution | Comments must be resolved before merge | ✅ |
| Build validation | Runs a pipeline on every PR | ✅ |
| Limit merge types | Enforce squash or merge commit | ✅ |
| Require approval from code owners | CODEOWNERS file support | Optional |

---

## Azure CLI — Useful Commands

```powershell
# Install Azure CLI
winget install --id Microsoft.AzureCLI

# Log in
az login

# Install Azure DevOps extension
az extension add --name azure-devops

# Set default org and project (one-time)
az devops configure --defaults organization=https://dev.azure.com/<org> project=<project>

# List repos
az repos list --output table

# Create a repo
az repos create --name my-new-repo

# List PRs
az repos pr list --output table

# Create a PR
az repos pr create --source-branch feature/my-feature `
  --target-branch main --title "feat: my feature"

# Approve a PR
az repos pr update --id <pr-id> --vote approve
```

---

## Linking PRs to Azure Boards Work Items

In your PR title or description, use:

```text
Fixes AB#1234
Relates to AB#5678
```

Or from the CLI:

```powershell
az repos pr create \
  --source-branch feature/my-feature \
  --target-branch main \
  --title "feat: my feature" \
  --work-items 1234
```

---

## Azure DevOps vs GitHub — Quick Comparison for Daily Use

- **Open a PR** — Azure DevOps: Repos → Pull requests; GitHub: Pull requests
  tab (or `gh pr create`).
- **See branch policies** — Azure DevOps: Repos → Branches → Policy; GitHub:
  Settings → Branches → Protection.
- **Run a pipeline** — Azure DevOps: Pipelines → Run; GitHub: Actions → Run
  workflow.
| Link to a ticket | `AB#1234` in description | `Fixes #42` in description |
| Code search | Overview → Search | GitHub search bar |

---

## References

- [Azure DevOps Docs](https://learn.microsoft.com/en-us/azure/devops/)
- [Azure Repos — Get started with Git](https://learn.microsoft.com/en-us/azure/devops/repos/git/gitquickstart)
- [Azure DevOps Branching Guidance](https://learn.microsoft.com/en-us/azure/devops/repos/git/git-branching-guidance)
- [Azure CLI for DevOps](https://learn.microsoft.com/en-us/cli/azure/devops)
