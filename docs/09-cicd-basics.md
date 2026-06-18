# 09 — CI/CD Basics

> **Platform:** Windows | Covers GitHub Actions and Azure Pipelines

---

## What Is CI/CD?

- **CI — Continuous Integration** — automatically build and test every code
  change.
- **CD — Continuous Delivery** — automatically deploy tested code to an
  environment.
- **Pipeline** — the automated sequence of steps (build → test → deploy).

---

## GitHub Actions — Key Concepts

| Concept | Description |
|---|---|
| **Workflow** | A YAML file in `.github/workflows/` |
| **Trigger** | The event that starts a workflow (`push`, `pull_request`, etc.) |
| **Job** | A group of steps that run on the same runner |
| **Step** | A single task inside a job (run a command or use an Action) |
| **Runner** | The machine that executes the job (GitHub-hosted or self-hosted) |
| **Action** | A reusable step from the GitHub Marketplace |

### Minimal workflow — run on every PR to `main`

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

jobs:
  build:
    runs-on: windows-latest        # Windows runner

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '8.x'

      - name: Restore dependencies
        run: dotnet restore

      - name: Build
        run: dotnet build --no-restore

      - name: Run tests
        run: dotnet test --no-build --verbosity normal
```

---

## Azure Pipelines — Key Concepts

| Concept | Azure Pipelines | GitHub Actions equivalent |
|---|---|---|
| Pipeline file | `azure-pipelines.yml` (repo root) | `.github/workflows/*.yml` |
| Trigger | `trigger:` block | `on:` block |
| Stage | Group of jobs | No direct equivalent (use `needs:`) |
| Job | `job:` block | `jobs.<job-id>:` block |
| Step | `- task:` or `- script:` | `- uses:` or `- run:` |
| Agent | `pool: vmImage: 'windows-latest'` | `runs-on: windows-latest` |

### Minimal Azure Pipeline

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
      - main
      - master

pr:
  branches:
    include:
      - main
      - master

pool:
  vmImage: 'windows-latest'

steps:
  - task: UseDotNet@2
    displayName: 'Install .NET SDK'
    inputs:
      packageType: sdk
      version: '8.x'

  - script: dotnet restore
    displayName: 'Restore dependencies'

  - script: dotnet build --no-restore
    displayName: 'Build'

  - script: dotnet test --no-build --verbosity normal
    displayName: 'Run tests'
```

---

## Protecting `main` With Required Status Checks

### GitHub

1. **Settings → Branches → Add rule** on `main`.
2. Enable **"Require status checks to pass before merging"**.
3. Search for and select your workflow job name (e.g., `build`).
4. Enable **"Require branches to be up to date"**.

### Azure DevOps

1. **Repos → Branches → `main` → Branch policies**.
2. Under **Build validation**, add your pipeline.
3. Set **Trigger** to automatic and **Policy requirement** to required.

---

## Environments and Approvals (CD)

### GitHub — Environments

```yaml
jobs:
  deploy:
    runs-on: windows-latest
    environment:
      name: production  # Manual approval (see Settings → Environments)
      url: https://myapp.azurewebsites.net

    steps:
      - name: Deploy to Azure
        run: echo "Deploy step here"
```

Configure approval gates: **Settings → Environments → production → Required reviewers**.

### Azure Pipelines — Stage Approvals

```yaml
stages:
  - stage: Deploy
    displayName: 'Deploy to Production'
    jobs:
      - deployment: DeployWeb
        environment: 'production'   # Approvals set in Azure DevOps UI
        strategy:
          runOnce:
            deploy:
              steps:
                - script: echo "Deploy step here"
```

Configure in **Pipelines → Environments → production → Approvals and checks**.

---

## Release Branches Strategy

```text
main            ← always deployable, protected
 └─ release/1.2.0  ← cut from main when ready to release
     └─ hotfix/1.2.1  ← emergency fixes applied to the release branch
```

1. When a sprint ends, cut `release/1.2.0` from `main`.
2. Deploy `release/1.2.0` to staging → QA → production.
3. After release, merge `release/1.2.0` back into `main`.
4. Tag the release: `git tag v1.2.0 && git push origin v1.2.0`

---

## Useful GitHub Actions CLI Commands

```powershell
# List workflows
gh workflow list

# Trigger a workflow manually
gh workflow run ci.yml

# View recent runs
gh run list

# Watch a run in progress
gh run watch

# View logs for a run
gh run view <run-id> --log
```

---

## References

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [GitHub Actions — Starter Workflows](https://github.com/actions/starter-workflows)
- [Azure Pipelines YAML Schema](https://learn.microsoft.com/en-us/azure/devops/pipelines/yaml-schema)
- [Azure DevOps Environments](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/environments)
- [GitHub Docs — Environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
