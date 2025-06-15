#!/usr/bin/env bash

echo "Starting restore_cfg.sh"

# Get script directory
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Path to the .psv file
psv_file="${script_dir}/restore_cfg.psv"

# Detect Zen profile automatically
zen_profile=$(find ~/.zen -maxdepth 1 -type d -name "*Default*" | sort -r | head -n 1)
echo "Zen profile path: $zen_profile"

# Export for use in eval
export zen_profile

# Create backup folder with timestamp
backup_enabled=true
backup_dir="${HOME}/backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"

echo "Backup enabled? $backup_enabled"
echo "Backup directory: $backup_dir"

# Read .psv file line by line
while IFS='|' read -r flag path target deps; do
  # Skip empty lines or comments
  [[ -z "$flag" || "$flag" =~ ^# ]] && continue

  # Support variables like ${HOME} and ${zen_profile}
  eval "path=\"$path\""
  eval "deps=\"$deps\""

  # Convert strings to arrays
  IFS=' ' read -r -a targets <<< "$target"
  IFS=' ' read -r -a dependencies <<< "$deps"

  for file in "${targets[@]}"; do
    # Full target path (on the system)
    dst="$path/$file"

    # Source file path (from ./Configs)
    src="$script_dir/../Configs/$dst"

    # Warn if source does not exist
    if [[ ! -e "$src" ]]; then
      echo "[Warning] Source file does not exist: $src"
      continue
    fi

    # Backup existing file if required
    if [[ "$flag" =~ [BSO] && -e "$dst" ]]; then
      echo "[Backup] $dst -> $backup_dir/$dst"
      mkdir -p "$(dirname "$backup_dir/$dst")"
      cp -r "$dst" "$backup_dir/$dst"
    fi

    # Perform action based on the flag
    case "$flag" in
      P)
        if [[ ! -e "$dst" ]]; then
          echo "[P] Copying $src -> $dst"
          mkdir -p "$(dirname "$dst")"
          cp -r "$src" "$dst"
        else
          echo "[P] Skipped (already exists) $dst"
        fi
        ;;
      S)
        echo "[S] Syncing $src -> $dst"
        mkdir -p "$(dirname "$dst")"
        cp -r "$src" "$dst"
        ;;
      O)
        echo "[O] Overwriting $dst with $src"
        mkdir -p "$(dirname "$dst")"
        rm -rf "$dst"
        cp -r "$src" "$dst"
        ;;
      *)
        echo "[Error] Unknown flag: $flag"
        ;;
    esac
  done

done < "$psv_file"

