#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_VERSION=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$SCRIPT_DIR/.cursor-plugin/plugin.json" | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
VERSION_FILE=".cursoreception-version"

usage() {
  echo "Usage: $0 [--project <path>] [--user] [--uninstall] [--update]"
  echo ""
  echo "  --project <path>  Install to a specific project (components go into <path>/.cursor/)"
  echo "  --user            Install user-level (skill → ~/.cursor/skills/, hooks → ~/.cursor/)"
  echo "  --uninstall       Remove installed components"
  echo "  --update          Update an existing installation to the latest version"
  echo ""
  echo "Examples:"
  echo "  $0 --user                     # Global install"
  echo "  $0 --project ~/my-project     # Project-level install"
  echo "  $0 --user --update            # Update global install"
  echo "  $0 --project ~/my-project --update   # Update project install"
  echo "  $0 --user --uninstall         # Remove global install"
  exit 1
}

# --- Version helpers ---

get_installed_version() {
  local target_dir="$1"
  local vfile="$target_dir/$VERSION_FILE"
  if [ -f "$vfile" ]; then
    cat "$vfile"
  else
    echo ""
  fi
}

write_version() {
  local target_dir="$1"
  mkdir -p "$target_dir"
  echo "$SOURCE_VERSION" > "$target_dir/$VERSION_FILE"
}

# --- File diff helper ---

file_changed() {
  local src="$1" dst="$2"
  [ ! -f "$dst" ] && return 0
  ! diff -q "$src" "$dst" > /dev/null 2>&1
}

# --- Backup helper ---

backup_file() {
  local file="$1" backup_dir="$2"
  if [ -f "$file" ]; then
    local rel
    rel=$(basename "$file")
    cp "$file" "$backup_dir/$rel"
  fi
}

# --- Core install (shared by install & update) ---

UPDATE_COUNT=0

do_install_files_project() {
  local root="$1"
  UPDATE_COUNT=0

  mkdir -p "$root/.cursor/rules"
  if file_changed "$SCRIPT_DIR/rules/cursoreception-evaluate.mdc" "$root/.cursor/rules/cursoreception-evaluate.mdc"; then
    cp "$SCRIPT_DIR/rules/cursoreception-evaluate.mdc" "$root/.cursor/rules/"
    echo "  ✓ Rule → .cursor/rules/cursoreception-evaluate.mdc"
    UPDATE_COUNT=$((UPDATE_COUNT + 1))
  fi

  mkdir -p "$root/.cursor/skills/cursoreception"
  if file_changed "$SCRIPT_DIR/skills/cursoreception/SKILL.md" "$root/.cursor/skills/cursoreception/SKILL.md"; then
    cp "$SCRIPT_DIR/skills/cursoreception/SKILL.md" "$root/.cursor/skills/cursoreception/"
    echo "  ✓ Skill → .cursor/skills/cursoreception/SKILL.md"
    UPDATE_COUNT=$((UPDATE_COUNT + 1))
  fi

  mkdir -p "$root/.cursor/scripts/cursoreception"
  if file_changed "$SCRIPT_DIR/scripts/stop-evaluate.sh" "$root/.cursor/scripts/cursoreception/stop-evaluate.sh"; then
    cp "$SCRIPT_DIR/scripts/stop-evaluate.sh" "$root/.cursor/scripts/cursoreception/"
    chmod +x "$root/.cursor/scripts/cursoreception/stop-evaluate.sh"
    echo "  ✓ Script → .cursor/scripts/cursoreception/stop-evaluate.sh"
    UPDATE_COUNT=$((UPDATE_COUNT + 1))
  fi

  [ $UPDATE_COUNT -eq 0 ] && echo "  (all files already up to date)"
  write_version "$root/.cursor"
}

do_install_files_user() {
  local cursor_home="$1"
  UPDATE_COUNT=0

  mkdir -p "$cursor_home/skills/cursoreception"
  if file_changed "$SCRIPT_DIR/skills/cursoreception/SKILL.md" "$cursor_home/skills/cursoreception/SKILL.md"; then
    cp "$SCRIPT_DIR/skills/cursoreception/SKILL.md" "$cursor_home/skills/cursoreception/"
    echo "  ✓ Skill → ~/.cursor/skills/cursoreception/SKILL.md"
    UPDATE_COUNT=$((UPDATE_COUNT + 1))
  fi

  mkdir -p "$cursor_home/scripts/cursoreception"
  if file_changed "$SCRIPT_DIR/scripts/stop-evaluate.sh" "$cursor_home/scripts/cursoreception/stop-evaluate.sh"; then
    cp "$SCRIPT_DIR/scripts/stop-evaluate.sh" "$cursor_home/scripts/cursoreception/"
    chmod +x "$cursor_home/scripts/cursoreception/stop-evaluate.sh"
    echo "  ✓ Script → ~/.cursor/scripts/cursoreception/stop-evaluate.sh"
    UPDATE_COUNT=$((UPDATE_COUNT + 1))
  fi

  [ $UPDATE_COUNT -eq 0 ] && echo "  (all files already up to date)"
  write_version "$cursor_home"
}

# --- Install ---

install_project() {
  local root="$1"
  [ -d "$root" ] || { echo "Error: $root does not exist"; exit 1; }

  if $UNINSTALL; then
    echo "Removing project-level cursoreception from $root ..."
    rm -f "$root/.cursor/rules/cursoreception-evaluate.mdc"
    rm -rf "$root/.cursor/skills/cursoreception"
    rm -rf "$root/.cursor/scripts/cursoreception"
    rm -f "$root/.cursor/$VERSION_FILE"
    echo "Note: hooks.json not removed (may contain other hooks). Manually remove the 'stop' entry if needed."
    echo "Done."
    return
  fi

  echo "Installing cursoreception v$SOURCE_VERSION to project: $root"

  do_install_files_project "$root" > /dev/null

  echo "  ✓ Rule → .cursor/rules/cursoreception-evaluate.mdc"
  echo "  ✓ Skill → .cursor/skills/cursoreception/SKILL.md"
  echo "  ✓ Script → .cursor/scripts/cursoreception/stop-evaluate.sh"

  # Hooks config
  HOOKS_FILE="$root/.cursor/hooks.json"
  if [ -f "$HOOKS_FILE" ]; then
    echo "  ⚠ $HOOKS_FILE already exists. Add this entry manually:"
    echo '    "stop": [{ "command": ".cursor/scripts/cursoreception/stop-evaluate.sh", "loop_limit": 1 }]'
  else
    cat > "$HOOKS_FILE" << 'HOOKEOF'
{
  "version": 1,
  "hooks": {
    "stop": [
      {
        "command": ".cursor/scripts/cursoreception/stop-evaluate.sh",
        "loop_limit": 1
      }
    ]
  }
}
HOOKEOF
    echo "  ✓ Hooks → .cursor/hooks.json"
  fi

  write_version "$root/.cursor"
  echo "Done. Restart Cursor to activate."
}

install_user() {
  local cursor_home="$HOME/.cursor"

  if $UNINSTALL; then
    echo "Removing user-level cursoreception ..."
    rm -rf "$cursor_home/skills/cursoreception"
    rm -rf "$cursor_home/scripts/cursoreception"
    rm -f "$cursor_home/$VERSION_FILE"
    echo "Note: hooks.json not removed (may contain other hooks). Manually remove the 'stop' entry if needed."
    echo "Note: Rules are project-only — nothing to remove at user level."
    echo "Done."
    return
  fi

  echo "Installing cursoreception v$SOURCE_VERSION (user-level) to $cursor_home"

  do_install_files_user "$cursor_home" > /dev/null

  echo "  ✓ Skill → ~/.cursor/skills/cursoreception/SKILL.md"
  echo "  ✓ Script → ~/.cursor/scripts/cursoreception/stop-evaluate.sh"

  # Hooks config
  HOOKS_FILE="$cursor_home/hooks.json"
  if [ -f "$HOOKS_FILE" ]; then
    echo "  ⚠ $HOOKS_FILE already exists. Add this entry manually:"
    echo '    "stop": [{ "command": "./scripts/cursoreception/stop-evaluate.sh", "loop_limit": 1 }]'
  else
    cat > "$HOOKS_FILE" << 'HOOKEOF'
{
  "version": 1,
  "hooks": {
    "stop": [
      {
        "command": "./scripts/cursoreception/stop-evaluate.sh",
        "loop_limit": 1
      }
    ]
  }
}
HOOKEOF
    echo "  ✓ Hooks → ~/.cursor/hooks.json"
  fi

  echo ""
  echo "Note: Rules (.mdc) are project-only. To use the alwaysApply rule,"
  echo "copy it into each project:"
  echo "  cp $SCRIPT_DIR/rules/cursoreception-evaluate.mdc <project>/.cursor/rules/"
  echo ""
  write_version "$cursor_home"
  echo "Done. Restart Cursor to activate."
}

# --- Update ---

update_project() {
  local root="$1"
  [ -d "$root" ] || { echo "Error: $root does not exist"; exit 1; }

  local installed
  installed=$(get_installed_version "$root/.cursor")
  if [ -z "$installed" ]; then
    if [ -f "$root/.cursor/skills/cursoreception/SKILL.md" ] || \
       [ -f "$root/.cursor/scripts/cursoreception/stop-evaluate.sh" ]; then
      installed="unknown"
    else
      echo "Error: cursoreception is not installed in $root"
      echo "Run '$0 --project $root' to install first."
      exit 1
    fi
  fi

  if [ "$installed" = "$SOURCE_VERSION" ]; then
    echo "cursoreception v$SOURCE_VERSION is already installed in $root — checking for file changes..."
  else
    echo "Updating cursoreception in $root: v${installed} → v${SOURCE_VERSION}"
  fi

  # Backup
  local backup_dir="$root/.cursor/.cursoreception-backup-$(date +%Y%m%d%H%M%S)"
  mkdir -p "$backup_dir"
  backup_file "$root/.cursor/rules/cursoreception-evaluate.mdc" "$backup_dir"
  backup_file "$root/.cursor/skills/cursoreception/SKILL.md" "$backup_dir"
  backup_file "$root/.cursor/scripts/cursoreception/stop-evaluate.sh" "$backup_dir"

  if [ -z "$(ls -A "$backup_dir" 2>/dev/null)" ]; then
    rmdir "$backup_dir"
  else
    echo "  ✓ Backup → $backup_dir"
  fi

  do_install_files_project "$root"

  if [ $UPDATE_COUNT -eq 0 ] && [ "$installed" = "$SOURCE_VERSION" ]; then
    echo "Already up to date (v$SOURCE_VERSION)."
    rm -rf "$backup_dir" 2>/dev/null || true
  else
    echo "Updated to v$SOURCE_VERSION. Restart Cursor to activate."
  fi
}

update_user() {
  local cursor_home="$HOME/.cursor"

  local installed
  installed=$(get_installed_version "$cursor_home")
  if [ -z "$installed" ]; then
    if [ -f "$cursor_home/skills/cursoreception/SKILL.md" ] || \
       [ -f "$cursor_home/scripts/cursoreception/stop-evaluate.sh" ]; then
      installed="unknown"
    else
      echo "Error: cursoreception is not installed at user level."
      echo "Run '$0 --user' to install first."
      exit 1
    fi
  fi

  if [ "$installed" = "$SOURCE_VERSION" ]; then
    echo "cursoreception v$SOURCE_VERSION is already installed — checking for file changes..."
  else
    echo "Updating cursoreception (user-level): v${installed} → v${SOURCE_VERSION}"
  fi

  # Backup
  local backup_dir="$cursor_home/.cursoreception-backup-$(date +%Y%m%d%H%M%S)"
  mkdir -p "$backup_dir"
  backup_file "$cursor_home/skills/cursoreception/SKILL.md" "$backup_dir"
  backup_file "$cursor_home/scripts/cursoreception/stop-evaluate.sh" "$backup_dir"

  if [ -z "$(ls -A "$backup_dir" 2>/dev/null)" ]; then
    rmdir "$backup_dir"
  else
    echo "  ✓ Backup → $backup_dir"
  fi

  do_install_files_user "$cursor_home"

  if [ $UPDATE_COUNT -eq 0 ] && [ "$installed" = "$SOURCE_VERSION" ]; then
    echo "Already up to date (v$SOURCE_VERSION)."
    rm -rf "$backup_dir" 2>/dev/null || true
  else
    echo ""
    echo "Note: Rules (.mdc) are project-only. To update the rule in each project:"
    echo "  cp $SCRIPT_DIR/rules/cursoreception-evaluate.mdc <project>/.cursor/rules/"
    echo ""
    echo "Updated to v$SOURCE_VERSION. Restart Cursor to activate."
  fi
}

# --- Main ---

MODE=""
TARGET=""
UNINSTALL=false
UPDATE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --project) MODE="project"; TARGET="$2"; shift 2 ;;
    --user)    MODE="user"; shift ;;
    --uninstall) UNINSTALL=true; shift ;;
    --update) UPDATE=true; shift ;;
    *) usage ;;
  esac
done

[ -z "$MODE" ] && usage

if $UNINSTALL && $UPDATE; then
  echo "Error: --uninstall and --update cannot be used together."
  exit 1
fi

if $UPDATE; then
  case $MODE in
    project) update_project "$TARGET" ;;
    user)    update_user ;;
  esac
elif $UNINSTALL; then
  case $MODE in
    project) install_project "$TARGET" ;;
    user)    install_user ;;
  esac
else
  case $MODE in
    project) install_project "$TARGET" ;;
    user)    install_user ;;
  esac
fi
