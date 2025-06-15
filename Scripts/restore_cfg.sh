#!/bin/bash
set -euo pipefail

# ---------------------------------------------
# restore_cfg.sh
# Script to restore dotfiles/configs from a list (.psv file)
# Supports backup, conditional copy, and paths with absolute or relative targets.
# ---------------------------------------------

# Configuration
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
BASE_CONFIG_DIR="$(realpath "$SCRIPT_DIR/../Configs")"
PSV_FILE="$SCRIPT_DIR/restore_cfg.psv"

# Backup configuration
BACKUP_ENABLED=true
BACKUP_DIR="${HOME}/backup_$(date +%Y%m%d_%H%M%S)"

# Detect Zen profile from ~/.zen/profiles.ini (optional)
ZEN_PROFILE=""
ZEN_PROFILES_INI="${HOME}/.zen/profiles.ini"
if [[ -f "$ZEN_PROFILES_INI" ]]; then
  # Extract path of default profile (first profile path)
  ZEN_PROFILE=$(grep '^Path=' "$ZEN_PROFILES_INI" | head -n1 | cut -d= -f2)
  ZEN_PROFILE="${HOME}/.zen/${ZEN_PROFILE}"
fi

echo "Starting restore_cfg.sh"
echo "Backup enabled? $BACKUP_ENABLED"
if $BACKUP_ENABLED; then
  echo "Backup directory: $BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"
fi
if [[ -n "$ZEN_PROFILE" ]]; then
  echo "Zen profile path: $ZEN_PROFILE"
fi

# Function to backup files or directories
backup_target() {
  local target_path="$1"
  if [[ -e "$target_path" ]]; then
    local backup_path="${BACKUP_DIR}${target_path#$HOME}"
    mkdir -p "$(dirname "$backup_path")"
    echo "[Backup] $target_path -> $backup_path"
    cp -r --preserve=all "$target_path" "$backup_path"
  fi
}

# Read the .psv file line by line
while IFS='|' read -r flag path target dependency || [[ -n "$flag" ]]; do
  # Skip comments and empty lines
  [[ "$flag" =~ ^# ]] && continue
  [[ -z "$flag" ]] && continue

  # Trim whitespace
  flag=$(echo "$flag" | xargs)
  path=$(echo "$path" | xargs)
  target=$(echo "$target" | xargs)
  dependency=$(echo "$dependency" | xargs)

  # Expand ${HOME} in path and target
  expanded_path=$(eval echo "$path")
  expanded_target=$(eval echo "$target")

  # Special handling for zen profile variable in target or path
  if [[ -n "$ZEN_PROFILE" ]]; then
    expanded_path="${expanded_path//\$\{zen_profile\}/$ZEN_PROFILE}"
    expanded_target="${expanded_target//\$\{zen_profile\}/$ZEN_PROFILE}"
  fi

  # Determine source path:
  # If target is absolute path, use it directly.
  # Else join with BASE_CONFIG_DIR.
  if [[ "$expanded_target" == /* ]]; then
    src="$expanded_target"
  else
    src="${BASE_CONFIG_DIR}/${expanded_target}"
  fi

  dest="$expanded_path"

  # Check if source exists
  if [[ ! -e "$src" ]]; then
    echo "[Warning] Source file does not exist: $src"
    continue
  fi

  # Backup destination if enabled
  if $BACKUP_ENABLED; then
    backup_target "$dest"
  fi

  # Handle according to flag
  case "$flag" in
    P)  # Populate: only copy if destination doesn't exist
      if [[ -e "$dest" ]]; then
        echo "[P] Skipped (already exists) $dest"
      else
        mkdir -p "$(dirname "$dest")"
        echo "[P] Copying $src to $dest"
        cp -r "$src" "$dest"
      fi
      ;;
    S)  # Sync: overwrite destination
      mkdir -p "$(dirname "$dest")"
      echo "[S] Copying $src to $dest (overwrite)"
      cp -r "$src" "$dest"
      ;;
    O)  # Overwrite everything, if directory remove first
      if [[ -d "$dest" ]]; then
        echo "[O] Removing directory $dest before overwrite"
        rm -rf "$dest"
      fi
      mkdir -p "$(dirname "$dest")"
      echo "[O] Copying $src to $dest (overwrite)"
      cp -r "$src" "$dest"
      ;;
    B)  # Backup only, nothing else
      echo "[B] Backup only flag for $dest"
      ;;
    *)
      echo "[Warning] Unknown flag: $flag"
      ;;
  esac

done < "$PSV_FILE"

echo "Done restoring configs."

