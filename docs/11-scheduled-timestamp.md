# 11 — Scheduled Sandbox Timestamp

> **Platform:** Windows 11 Enterprise | **Shell:** PowerShell
>
> This page explains how to take the script
> [`scripts/windows/sandbox-timestamp.ps1`](../scripts/windows/sandbox-timestamp.ps1),
> put it on any Windows 11 Enterprise computer, run it by hand once to confirm it
> works, and then let Windows run it **automatically on weekdays at 9:00 AM and
> 3:00 PM**. Each run writes the current date/time into `sandbox/last-run.txt` in
> your repo and pushes that change to the remote `main` branch.

---

## What the script does (plain English)

Every time it runs, the script:

1. Looks at the **local clone** of a Git repo on your computer (you tell it which
   one — see [Step 2](#step-2--set-your-local-repo-path-the-most-important-step)).
2. Writes one line like `updated on 2026-06-18 09:00:00 -0700` into
   `sandbox/last-run.txt` inside that repo.
3. Commits that file and **pushes it to the remote `main` branch** of whatever
   GitHub/Azure repo that local clone is connected to.

You do **not** edit the script's logic. You only:

- copy the file onto the machine,
- tell it **which local repo** to use,
- allow PowerShell to run it,
- run it once by hand to confirm,
- register the automatic schedule.

---

## The script can live in ANY folder

The `.ps1` file does **not** have to be inside the `git-ops-guide` repo, and the
folder it sits in has **nothing to do** with the repo name. You can copy it to,
for example, `C:\Tools\`, your Desktop, or `C:\Scripts\` — anywhere you like.

Why this works: the repo it acts on is chosen entirely by the **`-RepoPath`**
value (Step 2), which is completely separate from where the `.ps1` file is
stored.

> **One rule:** once you register the schedule (Step 5), **do not move or rename
> the `.ps1` file.** When you register, the script records its own current
> location (line 25, `$script = $MyInvocation.MyCommand.Path`) and Windows will
> look for it there every time. If you move it later, re-run Step 5 from the new
> location.

---

## Prerequisites (one-time, per computer)

- **Git for Windows** installed (`git --version` works in PowerShell).
- The repo you want to update is **already cloned** locally, and you can push to
  it normally (i.e. `git push` works for you from that clone). The scheduled run
  pushes silently, so your Git credentials must be cached — see
  [Step 3](#step-3--make-sure-git-can-push-without-asking).

---

## Step 1 — Copy the script onto the computer

Copy `sandbox-timestamp.ps1` to any folder you want. In the examples below it
lives in `C:\Tools`. Open **PowerShell** and go to that folder:

```powershell
cd C:\Tools
```

(Use your actual folder. The rest of the steps assume you are in the folder that
contains `sandbox-timestamp.ps1`.)

---

## Step 2 — Set your local repo path (the most important step)

This is the **one value you must get right.** It is the full path to the **local
clone** on this computer. That local clone is already connected to a remote
(GitHub or Azure) repo via its `origin` — and **that remote is where the push
goes.** So "the remote repo of your choosing" is simply: *whatever remote the
local clone you point to is connected to.* To target a different remote repo,
point `-RepoPath` at a local clone of that repo.

You have **two ways** to set it.

### Option A — Pass it each time with `-RepoPath` (recommended)

Nothing to edit in the file. You supply the path on the command line in Steps 4
and 5, for example:

```powershell
-RepoPath "C:\Users\you\Dev\github\git-ops-guide"
```

Replace `you` with your Windows username and the rest with your real clone path.

### Option B — Edit the default inside the script

Open `sandbox-timestamp.ps1` and look at **line 16**:

```powershell
[string]$RepoPath = "C:\Users\$env:USERNAME\Dev\github\git-ops-guide",
```

- If your clone really is at
  `C:\Users\<your-username>\Dev\github\git-ops-guide`, this default already works
  and you can omit `-RepoPath` everywhere.
- Otherwise, change the text in quotes to your real local clone path and save.

> **How to confirm the path is correct:** the folder you point to must contain a
> `.git` folder. The script checks this on **lines 41-44** and stops with a red
> `ERROR: '<path>' is not a Git repo` message if the path is wrong:
>
> ```powershell
> if (-not (Test-Path -LiteralPath (Join-Path $RepoPath ".git"))) {
>     Write-Host "ERROR: '$RepoPath' is not a Git repo. Edit -RepoPath." ...
> ```

The push target itself is **line 72** — it always pushes to `main` (set on
line 18, `$Branch = "main"`):

```powershell
git -C $wt push origin "HEAD:$Branch"
```

---

## Step 3 — Make sure git can push without asking

The scheduled run is **non-interactive** — nobody is there to type a password. So
your credentials must already be cached. Do one of these once:

```powershell
# If you use GitHub + GitHub CLI:
gh auth login

# Or enable the Windows credential manager for Git:
git config --global credential.helper manager
```

After this, run `git push` once by hand from your clone to confirm it does not
prompt you.

---

## Step 4 — Allow PowerShell to run the script, then run it once by hand

### 4a. Allow local scripts (one-time per user)

Windows blocks unsigned scripts by default. Allow them for your user account:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

(Answer `Y` if prompted. This is a one-time setting; you do not repeat it.)

### 4b. Run the script once to confirm it works

From the folder containing the script:

```powershell
.\sandbox-timestamp.ps1 -RepoPath "C:\Users\you\Dev\github\git-ops-guide"
```

(If you edited line 16 in Step 2 Option B, you can just run
`.\sandbox-timestamp.ps1` with no `-RepoPath`.)

**What success looks like:** a green message like

```text
Pushed to main: updated on 2026-06-18 09:00:00 -0700
```

(If nothing changed since the last run, it prints `No change.` instead — that is
also success.)

### 4c. Confirm `last-run.txt` was created/updated in the remote repo

1. Open your repo on GitHub (or Azure) in a browser.
2. Make sure you are on the **`main`** branch.
3. Open the **`sandbox/`** folder and open **`last-run.txt`**.
4. You should see the line with the timestamp from the run you just did, and the
   commit message `chore: update sandbox timestamp <date time>`.

If you see that, the script is working end-to-end.

---

## Step 5 — Register the automatic schedule (9:00 AM & 3:00 PM, weekdays)

This is the step that makes Windows run it automatically. Run the **same script**
with the **`-Register`** switch added:

```powershell
.\sandbox-timestamp.ps1 -Register -RepoPath "C:\Users\you\Dev\github\git-ops-guide"
```

**What success looks like:** a green message:

```text
Task 'GitOps-SandboxTimestamp' registered: Mon-Fri 9AM & 3PM.
```

That's it. Windows Task Scheduler will now run the script automatically.

### Is it every day, or Monday-Friday?

**Monday-Friday only** — *not* weekends. This is set on **line 28** of the
script, and the two daily times are **lines 30-31**:

```powershell
$days = @("Monday","Tuesday","Wednesday","Thursday","Friday")   # line 28
$triggers = @(
    (New-ScheduledTaskTrigger -Weekly -DaysOfWeek $days -At 9:00AM),   # line 30
    (New-ScheduledTaskTrigger -Weekly -DaysOfWeek $days -At 3:00PM)    # line 31
)
```

---

## Important: when does it actually run?

The task runs as **you**, and only **while you are logged into Windows** (set on
line 33, `-LogonType Interactive`). It does **not** run when you are logged off or
the computer is shut down.

Because the script is also registered with `-StartWhenAvailable` (line 34), a
**missed** 9 AM or 3 PM run (e.g. the laptop was closed) will fire **as soon as
you next log in**.

---

## Verifying and managing the scheduled task

The task is named `GitOps-SandboxTimestamp` (set on line 19). Useful commands:

```powershell
# Run it right now, on demand, to test the schedule wiring:
Start-ScheduledTask -TaskName "GitOps-SandboxTimestamp"

# See the task and its next scheduled run time:
Get-ScheduledTask     -TaskName "GitOps-SandboxTimestamp"
Get-ScheduledTaskInfo -TaskName "GitOps-SandboxTimestamp"

# Remove the schedule entirely:
Unregister-ScheduledTask -TaskName "GitOps-SandboxTimestamp" -Confirm:$false
```

You can also open the **Task Scheduler** app (Start → search "Task Scheduler")
and find `GitOps-SandboxTimestamp` in the Task Scheduler Library to see its
history and triggers in the GUI.

---

## Quick reference — the whole thing in order

```powershell
# 0. (once) allow scripts and cache git credentials
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
gh auth login                      # or: git config --global credential.helper manager

# 1. go to the folder where you copied the script
cd C:\Tools

# 2. run once by hand to confirm a push to main + last-run.txt update
.\sandbox-timestamp.ps1 -RepoPath "C:\Users\you\Dev\github\git-ops-guide"

# 3. register the Mon-Fri 9 AM & 3 PM schedule
.\sandbox-timestamp.ps1 -Register -RepoPath "C:\Users\you\Dev\github\git-ops-guide"

# 4. (optional) verify
Get-ScheduledTaskInfo -TaskName "GitOps-SandboxTimestamp"
```

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Red `ERROR: '<path>' is not a Git repo` | `-RepoPath` is wrong | Point it at the local clone that contains a `.git` folder (Step 2) |
| Red `ERROR: push failed` | Git credentials not cached | Do Step 3 (`gh auth login` or credential manager) |
| Script won't run, "running scripts is disabled" | Execution policy | Run Step 4a |
| Scheduled runs never happen | You were logged off / PC asleep | Task runs only while logged in; missed runs fire at next login (line 34) |
| Nothing changes in the repo | No content changed since last run | Expected — script prints `No change.` |
