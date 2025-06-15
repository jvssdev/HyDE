#!/bin/bash
# restore_cfg.sh
# Restore dotfiles and config files from ~/HyDE/Configs based on restore_cfg.psv
# Supports flags: P (Preserve), S (Sync), O (Overwrite), B (Backup)

set -euo pipefail
IFS=$'\n\t'

# Base directory where configs are stored relatively (used if target path is relative)
BASE_CONFIG_DIR="${HOME}/HyDE/Configs"

# Backup directory (timestamped)
BACKUP_ENABLED=true
BACKUP_DIR="${HOME}/backup_$(date +%Y%m%d_%H%M%S)"

# Path to the restore config list file (pipe separated values)
PSV_FILE="${HOME}/HyDE/Scripts/restore_cfg.psv"

# Extract Zen profile path (example logic, adjust as you have it)
ZEN_PROFILE=$(grep -E '^\[Profile' ~/.zen/profiles.ini -A 1 | grep Path | cut -d '=' -f2 | head -1)
ZEN_PROFILE="${HOME}/.zen/${ZEN_PROFILE}"

echo "Starting restore_cfg.sh"
echo "Backup enabled? $BACKUP_ENABLED"
echo "Backup directory: $BACKUP_DIR"
echo "Zen profile path: $ZEN_PROFILE"

# Create backup directory if backup is enabled
if $BACKUP_ENABLED; then
  mkdir -p "$BACKUP_DIR"
fi

# Function to backup target file or directory
backup_target() {
  local target_path="$1"

  # Avoid backing up home or root directory to prevent huge/recursive copies
  if [[ "$target_path" == "$HOME" || "$target_path" == "/" ]]; then
    echo "[Warning] Skipping backup of root or home directory: $target_path"
    return
  fi

  if [[ -e "$target_path" ]]; then
    # Construct backup path preserving directory structure after $HOME
    local backup_path="${BACKUP_DIR}${target_path#$HOME}"
    mkdir -p "$(dirname "$backup_path")"
    echo "[Backup] $target_path -> $backup_path"
    cp -r --preserve=all "$target_path" "$backup_path"
  fi
}

# Read the .psv file line by line
while IFS='|' read -r flag target source pkg; do
  # Skip comments or invalid lines
  [[ "$flag" =~ ^#.*$ ]] && continue
  [[ -z "$flag" || -z "$target" || -z "$source" || -z "$pkg" ]] && {
    echo "[Skipping] Invalid line (not 4 fields): $flag|$target|$source|$pkg"
    continue
  }

  # Determine actual source file path in BASE_CONFIG_DIR or absolute
  if [[ "$target" = /* ]]; then
    src="$target"
  else
    src="${BASE_CONFIG_DIR}/${target}"
  fi

  # Check if source exists
  if [[ ! -e "$src" ]]; then
    echo "[Warning] Source file does not exist: $src"
    continue
  fi

  # Prepare target destination path (expand ~ if any)
  dest="$target"
  if [[ "$dest" == "~"* ]]; then
    dest="${HOME}${dest:1}"
  fi

  # Backup target if needed
  if $BACKUP_ENABLED && [[ -e "$dest" ]]; then
    backup_target "$dest"
  fi

  # Handle flags
  case "$flag" in
    P) # Populate: copy only if target does not exist
      if [[ ! -e "$dest" ]]; then
        mkdir -p "$(dirname "$dest")"
        cp -r "$src" "$dest"
        echo "[Populate] Copied $src -> $dest"
      else
        echo "[P] Skipped (already exists) $dest"
      fi
      ;;
    S) # Sync: overwrite target with source
      mkdir -p "$(dirname "$dest")"
      cp -r "$src" "$dest"
      echo "[Sync] Overwrote $dest with $src"
      ;;
    O) # Overwrite: same as sync but intended for directories/files fully overwritten
      mkdir -p "$(dirname "$dest")"
      cp -r "$src" "$dest"
      echo "[Overwrite] Overwrote $dest with $src"
      ;;
    B) # Backup only - maybe just backup target, no copy
      echo "[Backup only] Skipping copy for $dest"
      ;;
    *)
      echo "[Warning] Unknown flag '$flag' for target $target"
      ;;
  esac

done < "$PSV_FILE"

echo "restore_cfg.sh finished."

