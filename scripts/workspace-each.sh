#!/usr/bin/env bash
# workspace-each.sh — Safely run a command across Shir0o workspace repositories.
#
# Usage:
#   ./scripts/workspace-each.sh [options] -- <command> [args...]
#   ./scripts/workspace-each.sh [options] "<command string>"
#
# Examples:
#   ./scripts/workspace-each.sh git status -s
#   ./scripts/workspace-each.sh --tier 1 git status -s
#   ./scripts/workspace-each.sh --framework flutter "git log -n 1 --oneline"
#   ./scripts/workspace-each.sh --tier 1 gh pr list --limit 2
#
# Options:
#   --tier <1|2>            Filter repositories by tier (Tier 1 = full standards, Tier 2 = lightweight)
#   --framework <type>      Filter by framework (flutter, node, godot, python, eleventy)
#   --repo <name>           Run on a specific repository only
#   --continue-on-error     Do not stop if a command exits with non-zero in a repository (default)
#   --fail-fast             Stop immediately on first error
#   --dry-run               Print target repositories and command without executing
#   -h, --help              Show this help message

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOME_DIR="$HOME"

# ─── Repo Registry (source of truth mirrors apply-standards.sh) ───────────────
# Format: "local_dir|tier|framework|has_functions|github_repo"
REPOS=(
  # Tier 1
  "attd|1|flutter|no|Shir0o/attd"
  "bible-read|1|flutter|yes|Shir0o/bible-read"
  "cisa-campus-work-tracker|1|node|yes|Shir0o/cisa-campus-work-tracker"
  "bnpb|1|flutter|no|Shir0o/bnpb"
  "auto-vol|1|flutter|no|Shir0o/auto-vol"
  "cleaning-tracker|1|flutter|no|Shir0o/cleaning-tracker"
  "diary|1|flutter|no|Shir0o/diary"
  "wave|1|flutter|no|Shir0o/wave"
  "road-song|1|flutter|no|Shir0o/road-song"
  "idle-flame|1|flutter|no|Shir0o/idle-flame"
  # Tier 2
  "sleep-journal|2|flutter|no|Shir0o/sleep-journal"
  "idle|2|godot|no|Shir0o/idle"
  "csa|2|node|no|Shir0o/csa"
  "package-maker|2|node|no|Shir0o/package-builder"
  "notes|2|eleventy|no|Shir0o/notes"
  "inventory|2|node|no|Shir0o/inventory"
  "circle|2|flutter|no|Shir0o/circle"
  "shared-calendar|2|node|no|Shir0o/shared-calendar"
  "helpful-scripts|2|python|no|Shir0o/helpful-scripts"
)

FILTER_TIER=""
FILTER_FRAMEWORK=""
FILTER_REPO=""
FAIL_FAST=false
DRY_RUN=false
COMMAND=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tier)
      FILTER_TIER="$2"
      shift 2
      ;;
    --framework)
      FILTER_FRAMEWORK="$2"
      shift 2
      ;;
    --repo)
      FILTER_REPO="$2"
      shift 2
      ;;
    --fail-fast)
      FAIL_FAST=true
      shift
      ;;
    --continue-on-error)
      FAIL_FAST=false
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      sed -n '2,20p' "$0" | sed 's/^# //'
      exit 0
      ;;
    --)
      shift
      COMMAND=("$@")
      break
      ;;
    *)
      COMMAND=("$@")
      break
      ;;
  esac
done

if [[ ${#COMMAND[@]} -eq 0 ]]; then
  echo "Error: No command specified."
  echo "Usage: ./scripts/workspace-each.sh [options] -- <command>"
  exit 1
fi

passed=0
failed=0
skipped=0

for entry in "${REPOS[@]}"; do
  IFS='|' read -r local_dir tier framework has_functions github_repo <<< "$entry"
  repo_dir="$HOME_DIR/$local_dir"

  # Apply filters
  if [[ -n "$FILTER_REPO" && "$local_dir" != "$FILTER_REPO" && "$github_repo" != "$FILTER_REPO" ]]; then
    continue
  fi
  if [[ -n "$FILTER_TIER" && "$tier" != "$FILTER_TIER" ]]; then
    continue
  fi
  if [[ -n "$FILTER_FRAMEWORK" && "$framework" != "$FILTER_FRAMEWORK" ]]; then
    continue
  fi

  if [[ ! -d "$repo_dir" ]]; then
    echo "⏭  Skipping $local_dir (directory not found at $repo_dir)"
    ((skipped++))
    continue
  fi

  echo "━━━ [$local_dir] ($github_repo, tier $tier, $framework) ━━━"

  if $DRY_RUN; then
    echo "  [dry-run] Would execute in $repo_dir: ${COMMAND[*]}"
    ((passed++))
    continue
  fi

  set +e
  (
    cd "$repo_dir"
    if [[ ${#COMMAND[@]} -eq 1 ]]; then
      eval "${COMMAND[0]}"
    else
      "${COMMAND[@]}"
    fi
  )
  exit_code=$?
  set -e

  if [[ $exit_code -eq 0 ]]; then
    ((passed++))
  else
    ((failed++))
    echo "  ⚠ Command exited with code $exit_code in $local_dir"
    if $FAIL_FAST; then
      echo "Stopping due to --fail-fast."
      exit "$exit_code"
    fi
  fi
done

echo ""
echo "Summary: $passed succeeded, $failed failed, $skipped skipped."
if [[ $failed -gt 0 ]]; then
  exit 1
fi
