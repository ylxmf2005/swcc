#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      ;;
    -h|--help)
      cat <<'USAGE'
Usage: .codex/skills/swcc/scripts/uninstall.sh [--dry-run]

Options:
  --dry-run   Print planned actions without changing the filesystem
USAGE
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
  shift
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
SOURCE_ROOT="$REPO_ROOT/.codex/skills"

TARGET_ROOT="$REPO_ROOT/.agents/skills"

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[dry-run] %s\n' "$*"
  else
    eval "$@"
  fi
}

done_msg() {
  printf '\nDone. Restart Codex or reopen the repository if the old skills are still cached.\n'
}

if [[ -L "$TARGET_ROOT" ]]; then
  current_target="$(readlink "$TARGET_ROOT")"
  if [[ "$current_target" == "$SOURCE_ROOT" ]]; then
    run "rm -f \"$TARGET_ROOT\""
    printf 'Removed: %s\n' "$TARGET_ROOT"
    done_msg
    exit 0
  fi
fi

printf 'No SWCC repo-local skill root symlink found at %s\n' "$TARGET_ROOT"
exit 0
