<!-- markdownlint-disable MD013 -->
# Installer Plan — One-Click Setup for sandbox-timestamp

> **Goal:** Make it as easy as possible for the team (Windows 11
> Enterprise only) to install, configure, run, and schedule the
> sandbox-timestamp automation with minimal manual steps.

## Source files this wraps

- Script that does the work:
  [`scripts/windows/AutoPushTask/sandbox-timestamp.ps1`](../scripts/windows/AutoPushTask/sandbox-timestamp.ps1)
- Manual instructions it automates:
  [`scripts/windows/AutoPushTask/README.md`](../scripts/windows/AutoPushTask/README.md)

## What the user wants (captured)

A single downloadable artifact (currently imagined as
`folder_name/file.exe`) that the team downloads to `C:\Tools` and runs.
Running it should do everything automatically:

1. Create `C:\Tools` if it does not exist.
2. Place itself / its payload into `C:\Tools`.
3. Write out `sandbox-timestamp.ps1` (and optionally the doc) into a
   known folder.
4. Run all steps from `AutoPushTask/README.md` automatically.
5. For step 2 (repo path), prompt the user to either:
   - paste the local repo path in the console, OR
   - browse/select the local repo folder via Windows Explorer dialog.
6. Update the `$RepoPath` value in the script to the selected path:
   - from: `[string]$RepoPath = "C:\Users\$env:USERNAME\Dev\github\git-ops-guide"`
   - to:   the real path the user entered/selected.
7. Run the script once manually, then print: "go to the remote repo and
   confirm it worked".
8. Ask the user to confirm success (y/n).
9. On `y`, register the scheduled task (Mon-Fri, 9 AM & 3 PM).

## My recommended corrections (to discuss)

- **Prefer a single PowerShell bootstrap (`install.ps1`) over `.exe`.**
  - A `.ps1` is transparent, easy to review, and needs no build step.
  - A standalone `.exe` (e.g. built with `ps2exe`) triggers Windows
    SmartScreen and antivirus warnings unless code-signed, which is
    extra friction for an Enterprise environment.
  - We can still ship an `.exe` later if required; logic stays the same.
- **The existing script already does the run + register work.** The
  installer mainly needs to: place the script, capture the repo path,
  patch `$RepoPath`, then call the script with `-RepoPath` once, and
  again with `-Register`.
- **Folder picker is feasible** via .NET WinForms
  (`System.Windows.Forms.FolderBrowserDialog`) from PowerShell.
- **Decide whether to patch the file or just pass `-RepoPath`.** Passing
  `-RepoPath` each time avoids editing the script at all and is simpler
  and safer. Patching the default is only needed if they want to run the
  bare script later with no arguments.

## Decisions (locked for now)

- **Artifact:** `AutoPushTask/Install-AutoPushTask.ps1`.
- **Distribution:** placed on a shared job/work page; team downloads the
  folder/file to their personal Windows 11 Enterprise computers.
- **Doc location:** the guide is the canonical `AutoPushTask/README.md`,
  shipped inside the folder so the bundle is self-contained. The old
  `docs/11-scheduled-timestamp.md` is now a thin pointer to it (single
  source of truth, no duplicated content).
- **Format:** PowerShell `.ps1` (no `.exe`). Simplest and guaranteed to
  run on Windows 11 Enterprise.

## Decisions (final — Option 2)

- **Persistence = config file (single source of truth).** The repo path
  is saved once to a JSON config file. Both manual and scheduled runs
  read it, so the path is configured exactly once.
  - Config location: `%LOCALAPPDATA%\sandbox-timestamp\config.json`
  - Shape: `{ "RepoPath": "C:\\Users\\...\\your-repo" }`
- **Prompt only once.** The installer prompts for the repo path only if
  the config file does not already have a valid path. On re-runs it
  reuses the saved value (no prompt).
- **Path resolution precedence in `sandbox-timestamp.ps1`:**
  1. `-RepoPath` argument (explicit override) — highest priority
  2. saved config file value — normal case
  3. built-in default constant — last resort
- **Scheduled task runs the worker "bare"** (no `-RepoPath` embedded), so
  it reads the config at run time. Changing the config updates every
  future run — no need to re-register the task.
- **Packaging:** `AutoPushTask/` contains BOTH `Install-AutoPushTask.ps1`
  (installer) and `sandbox-timestamp.ps1` (worker), so the folder is fully
  self-contained. The installer copies the worker to `C:\Tools`. No
  embedded/duplicated script body — the canonical worker lives at
  `scripts/windows/AutoPushTask/sandbox-timestamp.ps1`.
  - Installer locates the worker: same folder first, then parent folder
    (so it works both in the repo layout and the distributed folder).

## Final flow (installer = Install-AutoPushTask.ps1)

1. Ensure `C:\Tools` exists (create if missing).
2. Locate `sandbox-timestamp.ps1` (same dir, else parent dir).
3. Copy the worker into `C:\Tools`.
4. Set execution policy for current user (RemoteSigned).
5. Resolve repo path:
   - if config file already has a valid `.git` path, reuse it (no prompt)
   - else prompt: folder-browse dialog, falling back to console paste
   - validate the chosen folder contains a `.git` directory
6. Save the repo path to the config file (first time only).
7. Run once: `sandbox-timestamp.ps1 -RepoPath "<chosen>"`.
8. Print confirmation instructions; read y/n from user.
9. On `y`: `sandbox-timestamp.ps1 -Register` (reads config).
10. Print task name and schedule summary.

## Follow-up (not in this change)

- `AutoPushTask/README.md` (canonical guide) documents both the installer
  and the manual path with the config file. `docs/11-scheduled-timestamp.md`
  is now a thin pointer to it.
