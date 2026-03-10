#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
FORCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      ;;
    --force)
      FORCE=1
      ;;
    -h|--help)
      cat <<'USAGE'
Usage: .codex/skills/swcc/scripts/install.sh [--force] [--dry-run]

Options:
  --force     Replace existing destinations that are not the expected symlink
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

if [[ ! -d "$SOURCE_ROOT" ]]; then
  echo "Skill source directory not found: $SOURCE_ROOT" >&2
  exit 1
fi

TARGET_ROOT="$REPO_ROOT/.agents/skills"

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[dry-run] %s\n' "$*"
  else
    eval "$@"
  fi
}

done_msg() {
  printf '\nDone. Restart Codex or reopen the repository so it can discover the linked skills.\n'
}

parent_dir="$(dirname "$TARGET_ROOT")"
run "mkdir -p \"$parent_dir\""
if [[ -L "$TARGET_ROOT" ]]; then
  current_target="$(readlink "$TARGET_ROOT")"
  if [[ "$current_target" == "$SOURCE_ROOT" ]]; then
    printf 'Already installed: %s -> %s\n' "$TARGET_ROOT" "$current_target"
    done_msg
    exit 0
  fi
  if [[ "$FORCE" -ne 1 ]]; then
    echo "Destination exists with different symlink target: $TARGET_ROOT -> $current_target" >&2
    echo "Re-run with --force to replace it." >&2
    exit 1
  fi
  run "rm -f \"$TARGET_ROOT\""
elif [[ -e "$TARGET_ROOT" ]]; then
  if [[ -d "$TARGET_ROOT" && -z "$(find "$TARGET_ROOT" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]]; then
    run "rmdir \"$TARGET_ROOT\""
    run "ln -s \"$SOURCE_ROOT\" \"$TARGET_ROOT\""
    printf 'Installed: %s -> %s\n' "$TARGET_ROOT" "$SOURCE_ROOT"
    done_msg
    exit 0
  fi
  if [[ "$FORCE" -ne 1 ]]; then
    echo "Destination already exists and is not a symlink: $TARGET_ROOT" >&2
    echo "Re-run with --force to replace it." >&2
    exit 1
  fi
  run "rm -rf \"$TARGET_ROOT\""
fi
run "ln -s \"$SOURCE_ROOT\" \"$TARGET_ROOT\""
printf 'Installed: %s -> %s\n' "$TARGET_ROOT" "$SOURCE_ROOT"
done_msg
