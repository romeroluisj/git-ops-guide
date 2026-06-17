# 06 — Merge Conflicts

> **Platform:** Windows | VS Code merge editor (recommended)

---

## What Causes a Merge Conflict?

A merge conflict happens when two branches modify the **same lines** in the same file, and Git cannot automatically decide which version to keep.

Common triggers:
- Two people edit the same file on different branches.
- One person edits a file while another deletes it.
- Long-lived branches that diverge too far from `main`.

---

## Detect a Conflict

```powershell
# During a merge
git merge feature/other-branch
# Auto-merging src/app.cs
# CONFLICT (content): Merge conflict in src/app.cs
# Automatic merge failed; fix conflicts and then commit the result.

# Check which files are conflicted
git status
# Both modified: src/app.cs
```

---

## What a Conflict Looks Like in a File

```
<<<<<<< HEAD
string greeting = "Hello";
=======
string greeting = "Hi there";
>>>>>>> feature/other-branch
```

| Marker | Meaning |
|---|---|
| `<<<<<<< HEAD` | Start of YOUR changes (current branch) |
| `=======` | Separator |
| `>>>>>>> feature/other-branch` | Start of THEIR changes (incoming branch) |

---

## Resolve in VS Code (Recommended on Windows)

1. Open the conflicted file in VS Code.
2. VS Code displays inline options:
   - **Accept Current Change** — keep your version
   - **Accept Incoming Change** — keep their version
   - **Accept Both Changes** — keep both
   - **Compare Changes** — side-by-side diff
3. Choose the option or manually edit the file to the correct result.
4. Delete all conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`).
5. Save the file.

```powershell
# After resolving all conflicts, stage the resolved files
git add src/app.cs

# Complete the merge
git commit
# (Git pre-fills the merge commit message — you can accept it)
```

---

## Resolve via Command Line

```powershell
# See all conflicted files
git diff --name-only --diff-filter=U

# After manually editing the file to resolve it
git add <resolved-file>

# Once all conflicts are resolved
git commit
```

---

## Abort a Merge or Rebase

```powershell
# Abort an in-progress merge (go back to pre-merge state)
git merge --abort

# Abort an in-progress rebase
git rebase --abort
```

---

## Set Up a Merge Tool on Windows

```powershell
# Use VS Code as the merge tool
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd 'code --wait $MERGED'

# Launch the merge tool for all conflicted files
git mergetool
```

---

## Prevent Conflicts — Best Practices

1. **Keep branches short-lived.** Merge feature branches within a few days.
2. **Pull before you branch.** Always `git pull` on `main` before creating a branch.
3. **Sync frequently.** Rebase or merge `main` into your branch regularly.
4. **Communicate.** If two people need to work on the same file, coordinate to avoid overlap.
5. **Keep PRs small.** Smaller PRs = fewer conflicts and faster reviews.

---

## References
- [GitHub Docs — Resolving a merge conflict using the command line](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/addressing-merge-conflicts/resolving-a-merge-conflict-using-the-command-line)
- [VS Code Docs — Using Git source control](https://code.visualstudio.com/docs/sourcecontrol/overview)
