#!/usr/bin/env bash
# git-sync-branches.sh
# Safely syncs an integration branch into the default branch (main/master) and
# pushes both to the remote. Intended for a personal fast-sync workflow in
# Git Bash on Windows — for team work, use the Pull Request flow in docs/05.
#
# Usage:
#   ./git-sync-branches.sh                 # auto-detect default; integration branch = current
#   ./git-sync-branches.sh dev             # merge 'dev' into the auto-detected default branch
#   ./git-sync-branches.sh dev main        # merge 'dev' into 'main' explicitly
#
# Environment overrides:
#   SOURCE_BRANCH   integration branch to merge from (default: current branch)
#   TARGET_BRANCH   branch to merge into            (default: auto-detected main/master)

set -euo pipefail

# --- Detect the default branch (main or master) --------------------------------
detect_default_branch() {
  local ref
  if ref=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null); then
    printf '%s\n' "${ref#refs/remotes/origin/}"
    return
  fi
  if git show-ref --verify --quiet refs/remotes/origin/main; then
    echo "main"
  elif git show-ref --verify --quiet refs/remotes/origin/master; then
    echo "master"
  else
    echo "main"
  fi
}

current_branch=$(git rev-parse --abbrev-ref HEAD)

SOURCE_BRANCH="${1:-${SOURCE_BRANCH:-$current_branch}}"
TARGET_BRANCH="${2:-${TARGET_BRANCH:-$(detect_default_branch)}}"

echo "Source (merge from): $SOURCE_BRANCH"
echo "Target (merge into): $TARGET_BRANCH"

if [[ "$SOURCE_BRANCH" == "$TARGET_BRANCH" ]]; then
  echo "Source and target are the same branch ('$SOURCE_BRANCH'); nothing to merge."
  echo "Pass a different integration branch, e.g. ./git-sync-branches.sh dev main"
  exit 1
fi

# --- Update remote refs ---------------------------------------------------------
git fetch --all --prune

# --- Ensure a clean working tree before switching branches ----------------------
if ! git diff-index --quiet HEAD --; then
  echo "Error: Working tree is dirty. Commit or stash your changes first."
  git status -s
  exit 1
fi

# --- Sync the source/integration branch -----------------------------------------
git checkout "$SOURCE_BRANCH"
git pull origin "$SOURCE_BRANCH"
git push origin "$SOURCE_BRANCH"

# --- Sync the target branch, then fast-forward merge the source into it ----------
git checkout "$TARGET_BRANCH"
git pull origin "$TARGET_BRANCH"

# --ff-only keeps history linear; if it fails, the branches have diverged and you
# should reconcile them (rebase or a real merge) — see docs/04-syncing.md.
if ! git merge --ff-only "$SOURCE_BRANCH"; then
  echo ""
  echo "Error: Cannot fast-forward '$TARGET_BRANCH' from '$SOURCE_BRANCH'."
  echo "The branches have diverged. Reconcile them first (see docs/04-syncing.md),"
  echo "then re-run this script."
  git checkout "$current_branch"
  exit 1
fi

git push origin "$TARGET_BRANCH"

# --- Return to the branch you started on -----------------------------------------
git checkout "$current_branch"

echo ""
echo "Done. '$SOURCE_BRANCH' merged into '$TARGET_BRANCH' and both pushed to origin."
