# 00 — Setup

> **Platform:** Windows | **Shells covered:** PowerShell, Git Bash, Command Prompt

---

## 1. Install Git on Windows

### Option A — winget (recommended, Windows 10/11)

```powershell
winget install --id Git.Git -e --source winget
```

Restart your terminal after installation.

### Option B — Manual installer

Download from [gitforwindows.org](https://gitforwindows.org/). During setup:

- Choose **"Git from the command line and also from 3rd-party software"**
- Choose **"Use Visual Studio Code as Git's default editor"** (if you use VS Code)
- Choose **"Checkout Windows-style, commit Unix-style line endings"**
  (recommended for teams)

### Verify installation

```powershell
git --version
```

---

## 2. Configure Global Identity

These settings are attached to every commit you make.

```powershell
git config --global user.name "Your Full Name"
git config --global user.email "you@company.com"
```

### Recommended additional settings

```powershell
# Set VS Code as default editor
git config --global core.editor "code --wait"

# Normalize line endings (Windows → LF on commit, LF → CRLF on checkout)
git config --global core.autocrlf true

# Set default branch name for new repos
git config --global init.defaultBranch main

# Better diff output
git config --global core.pager "less -FRX"

# Show helpful branch status on git status
git config --global status.showUntrackedFiles all
```

### Verify your config

```powershell
git config --global --list
```

Config is stored at `C:\Users\<YourName>\.gitconfig`.

---

## 3. Authentication: SSH vs HTTPS

- **SSH** — best for daily use, no password prompts. Requires one-time key
  setup.
- **HTTPS** — best for quick one-off clones and CI/CD. Requires a username
  and PAT each time (or a credential manager).

### Recommended: Windows Credential Manager (HTTPS, zero config)

Git for Windows includes a credential helper that stores tokens in Windows
Credential Manager.

```powershell
git config --global credential.helper manager
```

The first time you `git push` or `git pull`, a browser window opens to
authenticate with GitHub. Credentials are saved automatically.

---

## 4. Generate an SSH Key (Optional but Recommended)

```powershell
# Generate key (accept defaults, optionally add a passphrase)
ssh-keygen -t ed25519 -C "you@company.com"

# Copy public key to clipboard
Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub" | Set-Clipboard
```

Go to **GitHub → Settings → SSH and GPG keys → New SSH key** and paste it.

### Test the connection

```powershell
ssh -T git@github.com
# Expected: Hi <username>! You've successfully authenticated...
```

---

## 5. Install Recommended Tools

- **[GitHub CLI (`gh`)](https://cli.github.com/)** — create PRs and manage
  repos from the terminal. Install: `winget install --id GitHub.cli`.
- **[Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows)**
  — manage Azure resources and pipelines.
  Install: `winget install --id Microsoft.AzureCLI`.
- **[VS Code](https://code.visualstudio.com/)** — editor with built-in Git
  UI. Install: `winget install --id Microsoft.VisualStudioCode`.

### Authenticate GitHub CLI

```powershell
gh auth login
# Follow the prompts — choose GitHub.com → HTTPS or SSH → browser auth
```

---

## References

- [Git for Windows](https://gitforwindows.org/)
- [GitHub Docs — Generating SSH keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
- [GitHub CLI Manual](https://cli.github.com/manual/)
