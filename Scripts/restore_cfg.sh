#!/bin/bash
set -euo pipefail

# ---------------------------------------------
# restore_cfg.sh
# Script to restore dotfiles/configs from a pipe-separated .psv file
# Supports backup, conditional copy, absolute and relative paths,
# and skips invalid lines and comments.
# ---------------------------------------------

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
BASE_CONFIG_DIR="$(realpath "$SCRIPT_DIR/../Configs")"
PSV_FILE="$SCRIPT_DIR/restore_cfg.psv"

BACKUP_ENABLED=true
BACKUP_DIR="${HOME}/backup_$(date +%Y%m%d_%H%M%S)"

ZEN_PROFILE=""
ZEN_PROFILES_INI="${HOME}/.zen/profiles.ini"
if [[ -f "$ZEN_PROFILES_INI" ]]; then
  ZEN_PROFILE_PATH=$(grep '^Path=' "$ZEN_PROFILES_INI" | head -n1 | cut -d= -f2)
  ZEN_PROFILE="${HOME}/.zen/${ZEN_PROFILE_PATH}"
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

# Trim function (removes leading/trailing whitespace)
trim() {
  local var="$*"
  var="${var#"${var%%[![:space:]]*}"}"   # leading
  var="${var%"${var##*[![:space:]]}"}"   # trailing
  echo -n "$var"
}

backup_target() {
  local target_path="$1"
  if [[ -e "$target_path" ]]; then
    local backup_path="${BACKUP_DIR}${target_path#$HOME}"
    mkdir -p "$(dirname "$backup_path")"
    echo "[Backup] $target_path -> $backup_path"
    cp -r --preserve=all "$target_path" "$backup_path"
  fi
}

while IFS= read -r line || [[ -n "$line" ]]; do
  # Skip empty lines and comments
  [[ -z "$line" ]] && continue
  [[ "$line" =~ ^# ]] && continue

  # Parse line into 4 fields separated by '|'
  IFS='|' read -r flag path target dependency <<< "$line"

  # If not 4 fields, skip line
  if [[ -z "$dependency" ]]; then
    echo "[Skipping] Invalid line (not 4 fields): $line"
    continue
  fi

  flag=$(trim "$flag")
  path=$(trim "$path")
  target=$(trim "$target")
  dependency=$(trim "$dependency")

  # Expand variables ${HOME} and ${zen_profile}
  expanded_path=$(eval echo "$path")
  expanded_target=$(eval echo "$target")

  # Replace ${zen_profile} if set
  if [[ -n "$ZEN_PROFILE" ]]; then
    expanded_path="${expanded_path//\$\{zen_profile\}/$ZEN_PROFILE}"
    expanded_target="${expanded_target//\$\{zen_profile\}/$ZEN_PROFILE}"
  fi

  # Determine source (src)
  # If expanded_target is absolute path, src=expanded_target
  # Else src = BASE_CONFIG_DIR/expanded_target
  if [[ "$expanded_target" == /* ]]; then
    src="$expanded_target"
  else
    src="${BASE_CONFIG_DIR}/${expanded_target}"
  fi

  dest="$expanded_path"

  if [[ ! -e "$src" ]]; then
    echo "[Warning] Source file does not exist: $src"
    continue
  fi

  # Backup destination before copying
  if $BACKUP_ENABLED; then
    backup_target "$dest"
  fi

  case "$flag" in
    P)
      if [[ -e "$dest" ]]; then
        echo "[P] Skipped (exists) $dest"
      else
        mkdir -p "$(dirname "$dest")"
        echo "[P] Copying $src to $dest"
        cp -r "$src" "$dest"
      fi
      ;;
    S)
      mkdir -p "$(dirname "$dest")"
      echo "[S] Copying $src to $dest (overwrite)"
      cp -r "$src" "$dest"
      ;;
    O)
      if [[ -d "$dest" ]]; then
        echo "[O] Removing directory $dest before overwrite"
        rm -rf "$dest"
      fi
      mkdir -p "$(dirname "$dest")"
      echo "[O] Copying $src to $dest (overwrite)"
      cp -r "$src" "$dest"
      ;;
    B)
      echo "[B] Backup only for $dest"
      ;;
    *)
      echo "[Warning] Unknown flag: $flag"
      ;;
  esac

done < "$PSV_FILE"

echo "Restore complete."

