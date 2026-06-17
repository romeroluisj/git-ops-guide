#!/usr/bin/env bash
# git-commit-and-sync.sh
# Stages all changes, commits with a Conventional Commits message, then runs
# git-sync-branches.sh to merge and push. Intended for a personal fast-sync
# workflow in Git Bash on Windows — for team work, use the Pull Request flow
# in docs/05.
#
# Usage:
#   ./git-commit-and-sync.sh                 # prompts for a commit message
#   ./git-commit-and-sync.sh dev             # forwards integration branch to sync
#   ./git-commit-and-sync.sh dev main        # forwards source + target to sync
#
# Commit messages should follow Conventional Commits (see docs/02-daily-loop.md):
#   feat: | fix: | docs: | chore: | refactor: | test: | ci:

set -euo pipefail

# --- Show current state, then stage everything ----------------------------------
git status
git add -A
git status

# --- Commit only if something is staged ------------------------------------------
if git diff --cached --quiet; then
  echo "No staged changes to commit."
else
  changed_files=$(git diff --cached --name-only)
  file_count=$(printf "%s\n" "$changed_files" | sed '/^$/d' | wc -l | tr -d ' ')

  if [[ "$file_count" == "1" ]]; then
    default_msg="chore: update $(printf "%s" "$changed_files" | head -n 1)"
  else
    default_msg="chore: update ${file_count} files"
  fi

  echo ""
  echo "Conventional Commit prefixes: feat | fix | docs | chore | refactor | test | ci"
  echo "Suggested commit message: ${default_msg}"
  read -r -p "Commit message [${default_msg}]: " msg
  msg=${msg:-$default_msg}

  git commit -m "$msg"
fi

# --- Sync/merge branches and push to remote --------------------------------------
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
"${script_dir}/git-sync-branches.sh" "$@"
