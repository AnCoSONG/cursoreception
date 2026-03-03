#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

usage() {
  echo "Usage: $0 [--project <path>] [--user] [--uninstall]"
  echo ""
  echo "  --project <path>  Install to a specific project (components go into <path>/.cursor/)"
  echo "  --user            Install user-level (skill → ~/.cursor/skills/, hooks → ~/.cursor/)"
  echo "  --uninstall       Remove installed components"
  echo ""
  echo "Examples:"
  echo "  $0 --user                     # Global install"
  echo "  $0 --project ~/my-project     # Project-level install"
  echo "  $0 --user --uninstall         # Remove global install"
  exit 1
}

MODE=""
TARGET=""
UNINSTALL=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --project) MODE="project"; TARGET="$2"; shift 2 ;;
    --user)    MODE="user"; shift ;;
    --uninstall) UNINSTALL=true; shift ;;
    *) usage ;;
  esac
done

[ -z "$MODE" ] && usage

install_project() {
  local root="$1"
  [ -d "$root" ] || { echo "Error: $root does not exist"; exit 1; }

  if $UNINSTALL; then
    echo "Removing project-level cursoreception from $root ..."
    rm -f "$root/.cursor/rules/cursoreception-evaluate.mdc"
    rm -rf "$root/.cursor/skills/cursoreception"
    rm -rf "$root/.cursor/scripts/cursoreception"
    echo "Note: hooks.json not removed (may contain other hooks). Manually remove the 'stop' entry if needed."
    echo "Done."
    return
  fi

  echo "Installing cursoreception to project: $root"

  # Rules
  mkdir -p "$root/.cursor/rules"
  cp "$SCRIPT_DIR/rules/cursoreception-evaluate.mdc" "$root/.cursor/rules/"
  echo "  ✓ Rule → .cursor/rules/cursoreception-evaluate.mdc"

  # Skills
  mkdir -p "$root/.cursor/skills/cursoreception"
  cp "$SCRIPT_DIR/skills/cursoreception/SKILL.md" "$root/.cursor/skills/cursoreception/"
  echo "  ✓ Skill → .cursor/skills/cursoreception/SKILL.md"

  # Hook scripts
  mkdir -p "$root/.cursor/scripts/cursoreception"
  cp "$SCRIPT_DIR/scripts/stop-evaluate.sh" "$root/.cursor/scripts/cursoreception/"
  chmod +x "$root/.cursor/scripts/cursoreception/stop-evaluate.sh"
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

  echo "Done. Restart Cursor to activate."
}

install_user() {
  local cursor_home="$HOME/.cursor"

  if $UNINSTALL; then
    echo "Removing user-level cursoreception ..."
    rm -rf "$cursor_home/skills/cursoreception"
    rm -rf "$cursor_home/scripts/cursoreception"
    echo "Note: hooks.json not removed (may contain other hooks). Manually remove the 'stop' entry if needed."
    echo "Note: Rules are project-only — nothing to remove at user level."
    echo "Done."
    return
  fi

  echo "Installing cursoreception (user-level) to $cursor_home"

  # Skills
  mkdir -p "$cursor_home/skills/cursoreception"
  cp "$SCRIPT_DIR/skills/cursoreception/SKILL.md" "$cursor_home/skills/cursoreception/"
  echo "  ✓ Skill → ~/.cursor/skills/cursoreception/SKILL.md"

  # Hook scripts
  mkdir -p "$cursor_home/scripts/cursoreception"
  cp "$SCRIPT_DIR/scripts/stop-evaluate.sh" "$cursor_home/scripts/cursoreception/"
  chmod +x "$cursor_home/scripts/cursoreception/stop-evaluate.sh"
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
  echo "Done. Restart Cursor to activate."
}

case $MODE in
  project) install_project "$TARGET" ;;
  user)    install_user ;;
esac
