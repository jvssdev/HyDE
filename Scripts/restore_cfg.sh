#!/usr/bin/env bash
set -euo pipefail

# Path to the .psv file
PSV_FILE="$(dirname "$0")/../restore_cfg.psv"

# Base path for configs folder relative to this script
CONFIGS_BASE="$(dirname "$0")/../Configs"

# Backup enabled? (true/false)
BACKUP_ENABLED=true

# Backup destination directory
BACKUP_DIR="$HOME/backup_$(date +%Y%m%d_%H%M%S)"

# Find zen profile path from ~/.zen/profiles.ini (example logic)
ZEN_PROFILE=""
if [[ -f "$HOME/.zen/profiles.ini" ]]; then
  ZEN_PROFILE=$(grep '^Path=' "$HOME/.zen/profiles.ini" | head -n1 | cut -d'=' -f2)
  ZEN_PROFILE="$HOME/.zen/$ZEN_PROFILE"
fi

echo "Starting restore_cfg.sh"
echo "Backup enabled? $BACKUP_ENABLED"
if $BACKUP_ENABLED; then
  echo "Backup directory: $BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"
fi
echo "Zen profile path: $ZEN_PROFILE"

while IFS= read -r line || [[ -n "$line" ]]; do
  # Skip empty lines and comments
  [[ -z "$line" || "$line" =~ ^# ]] && continue

  # Process only lines starting with P|, S|, O| or B|
  if [[ "$line" =~ ^(P|S|O|B)\| ]]; then
    IFS='|' read -r flag target sources package <<< "$line"

    # Trim spaces (optional)
    flag="${flag// /}"
    target="${target// /}"
    sources="${sources// /}"

    # Resolve source files list (space-separated)
    read -ra src_files <<< "$sources"

    # Resolve full target path
    # If target path starts with "/", treat as absolute, else relative to home
    if [[ "$target" = /* ]]; then
      target_path="$target"
    else
      # Special case for zen-profile placeholders
      if [[ "$target" == \$zen_profile* ]]; then
        # Remove $zen_profile and prepend $ZEN_PROFILE
        relative_path="${target#\$zen_profile/}"
        target_path="$ZEN_PROFILE/$relative_path"
      else
        target_path="$HOME/$target"
      fi
    fi

    # Backup target if enabled and exists
    if $BACKUP_ENABLED && [[ -e "$target_path" ]]; then
      backup_target_path="$BACKUP_DIR/$target"
      echo "[Backup] $target_path -> $backup_target_path"
      mkdir -p "$(dirname "$backup_target_path")"
      cp -a "$target_path" "$backup_target_path"
    fi

    # Copy each source file to target path
    for src_file in "${src_files[@]}"; do
      # Resolve full source path relative to CONFIGS_BASE if not absolute
      if [[ "$src_file" = /* ]]; then
        src="$src_file"
      else
        src="$CONFIGS_BASE/$src_file"
      fi

      # Check source existence
      if [[ ! -e "$src" ]]; then
        echo "[Warning] Source file does not exist: $src"
        continue
      fi

      # Decide copy behavior based on flag
      case "$flag" in
        P)
          # Populate: copy only if target does NOT exist
          if [[ ! -e "$target_path" ]]; then
            echo "[Populate] Copy $src -> $target_path"
            mkdir -p "$(dirname "$target_path")"
            cp -a "$src" "$target_path"
          else
            echo "[Populate] Skipped (exists) $target_path"
          fi
          ;;
        S)
          # Sync: copy and overwrite target file
          echo "[Sync] Copy $src -> $target_path"
          mkdir -p "$(dirname "$target_path")"
          cp -a "$src" "$target_path"
          ;;
        O)
          # Overwrite: if directory overwrite all, else overwrite file
          echo "[Overwrite] Copy $src -> $target_path"
          if [[ -d "$src" ]]; then
            rm -rf "$target_path"
            mkdir -p "$(dirname "$target_path")"
            cp -a "$src" "$target_path"
          else
            mkdir -p "$(dirname "$target_path")"
            cp -a "$src" "$target_path"
          fi
          ;;
        B)
          # Backup only (nothing to restore)
          echo "[Backup-only] Skipping copy for $target_path"
          ;;
        *)
          echo "[Warning] Unknown flag $flag in line: $line"
          ;;
      esac
    done
  else
    echo "[Skipping] Invalid line (not a valid flag): $line"
  fi
done < "$PSV_FILE"

echo "restore_cfg.sh finished."

