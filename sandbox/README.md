# Sandbox — Practice Area

This folder is a **safe, dedicated practice space**. Nothing here affects real work. You are encouraged to experiment freely.

---

## Exercise: Full Remote-to-Local-to-Remote Loop

Follow these steps to practice the complete Git/GitHub workflow.

### Prerequisites

- Git for Windows installed ([gitforwindows.org](https://gitforwindows.org/))
- A GitHub account with access to this repo
- Completed `docs/00-setup.md` (global config + SSH or HTTPS authentication)

---

### Step 1 — Clone the repo (if you haven't already)

**PowerShell / Git Bash:**
```powershell
git clone git@github.com:<org>/git-ops-guide.git
cd git-ops-guide
```

Or with HTTPS:
```powershell
git clone https://github.com/<org>/git-ops-guide.git
cd git-ops-guide
```

---

### Step 2 — Create your practice branch

Replace `your-name` with your actual name or username.

```powershell
git checkout main
git pull
git checkout -b practice/your-name
```

---

### Step 3 — Add your file to this folder

Create a new markdown file inside `/sandbox/`:

```powershell
# PowerShell
New-Item -Path "sandbox\your-name-notes.md" -ItemType File
```

Or just create the file in VS Code / File Explorer.

Add any content you like — your name, today's date, a note to yourself.

---

### Step 4 — Stage, commit, and push

```powershell
git add sandbox/your-name-notes.md
git commit -m "practice: add notes file for your-name"
git push origin practice/your-name
```

---

### Step 5 — Open a Pull Request

1. Go to the repo on GitHub.
2. GitHub will show a banner: **"Compare & pull request"** — click it.
3. Set base branch to `main`, compare branch to `practice/your-name`.
4. Fill in the PR template.
5. Submit the PR and tag a coworker for review.

---

### Bonus Exercise — Intentional Merge Conflict

1. Ask a coworker to edit the same line in `sandbox/conflict-test.md` on their own branch.
2. Both of you push and open PRs.
3. The second PR to merge will have a conflict.
4. Practice resolving the conflict in VS Code, then push the resolution.

---

### Cleanup After Practice

Once your PR is merged, delete your practice branch:

```powershell
# Delete remote branch
git push origin --delete practice/your-name

# Delete local branch
git branch -d practice/your-name
```
