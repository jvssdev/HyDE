#!/usr/bin/env bash

set -euo pipefail

echo "Starting restore_cfg.sh"

# Define the path to the base repo and config file
REPO="$(dirname "$(realpath "$0")")/.."
CONFIG_FILE="${REPO}/Scripts/restore_cfg.psv"


# Define the backup directory
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="${HOME}/backup_${TIMESTAMP}"

# Define zen profile path if available
zen_profile="$(grep Path= ~/.zen/profiles.ini | cut -d= -f2)"
zen_profile="${HOME}/.zen/${zen_profile}"
echo "Zen profile path: ${zen_profile}"

# Parse arguments
enable_backup=true

# Read the config file line by line
while IFS='|' read -r flag path target deps; do
  # Skip comments and empty lines
  [[ -z "$flag" || "$flag" =~ ^# ]] && continue

  # Expand variables like ${HOME} and ${zen_profile}
  eval path="$path"
  target_parts=($target)
  dep_parts=($deps)

  for target_part in "${target_parts[@]}"; do
    src="${REPO}/Configs/${dep_parts[0]}/${target_part}"
    dst="${path}/${target_part}"

    # Create backup if enabled and file exists
    if [[ "$enable_backup" == true && -e "$dst" ]]; then
      backup_path="${BACKUP_DIR}${dst}"
      mkdir -p "$(dirname "$backup_path")"
      echo "[Backup] $dst -> $backup_path"
      cp -a "$dst" "$backup_path"
    fi

    # Skip if flag is P (preserve) and file already exists
    if [[ "$flag" == *P* && -e "$dst" ]]; then
      echo "[P] Skipped (already exists) $dst"
      continue
    fi

    # Check if the source exists before trying to copy
    if [[ ! -e "$src" ]]; then
      echo "[Warning] Source file does not exist: $src"
      continue
    fi

    # Create destination directory
    mkdir -p "$(dirname "$dst")"

    # Perform the copy based on the flag
    if [[ "$flag" == *S* || "$flag" == *O* ]]; then
      cp -a "$src" "$dst"
      echo "[$flag] Restored $src -> $dst"
    elif [[ "$flag" == *P* ]]; then
      cp -an "$src" "$dst"
      echo "[$flag] Preserved $src -> $dst"
    fi
  done
done < "$CONFIG_FILE"

