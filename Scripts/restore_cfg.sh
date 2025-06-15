#!/usr/bin/env bash
set -euo pipefail

# Root directory of your repository/configs
scrDir="${HOME}/HyDE"

# PSV file location
PSVFILE="${scrDir}/Scripts/restore_cfg.psv"

# Define your Zen Browser profile path here (quoted to handle spaces)
zen_profile="${HOME}/.zen/7zna1f07.Default (release)"

# Backup enabled flag (set to false if you want to disable backup)
DO_BACKUP=true
BACKUP_DIR="${HOME}/backup_$(date +%Y%m%d_%H%M%S)"

# Function to backup files/directories before overwriting
backup_file() {
    local file="$1"
    if [[ -e "$file" ]]; then
        # Create backup directory, preserving relative path
        mkdir -p "${BACKUP_DIR}/$(dirname "${file/#$HOME\/}")"
        cp -a "$file" "${BACKUP_DIR}/${file/#$HOME\/}"
        echo "[Backup] $file -> ${BACKUP_DIR}/${file/#$HOME\/}"
    fi
}

echo "Starting restore_cfg.sh"
echo "Backup enabled? $DO_BACKUP"
echo "Backup directory: $BACKUP_DIR"
echo "Zen profile path: $zen_profile"

while IFS='|' read -r flags path target deps || [[ -n "$flags" ]]; do
    # Skip comments and empty lines
    [[ "${flags}" =~ ^#.*$ || -z "${flags}" ]] && continue

    # Expand environment variables like ${HOME} and ${zen_profile}
    path=$(eval echo "${path}")
    # Replace literal ${zen_profile} with its value
    path="${path//\$\{zen_profile\}/${zen_profile}}"

    # Multiple target files can be space separated, so split them
    IFS=' ' read -ra targets <<<"${target}"

    for tgt in "${targets[@]}"; do
        src="${scrDir}/Configs/${deps}/${tgt}"
        dst="${path}/${tgt}"

        # Create destination directory if it does not exist
        mkdir -p "$(dirname "$dst")"

        # Backup destination file/directory if backup is enabled
        if $DO_BACKUP; then
            backup_file "$dst"
        fi

        # Perform actions according to the flag
        case "$flags" in
            P)
                # Preserve: copy only if destination does not exist
                if [[ ! -e "$dst" ]]; then
                    cp -a "$src" "$dst"
                    echo "[P] Copied $src to $dst"
                else
                    echo "[P] Skipped (already exists) $dst"
                fi
                ;;
            S)
                # Sync: overwrite target files only
                cp -a "$src" "$dst"
                echo "[S] Synced $src to $dst"
                ;;
            O)
                # Overwrite: if directory, remove and copy entire dir; else overwrite file
                if [[ -d "$src" ]]; then
                    rm -rf "$dst"
                    cp -a "$src" "$dst"
                    echo "[O] Overwritten directory $dst"
                else
                    cp -a "$src" "$dst"
                    echo "[O] Overwritten file $dst"
                fi
                ;;
            B)
                # Backup only (backup already done)
                echo "[B] Backup completed for $dst"
                ;;
            *)
                echo "[!] Unknown flag: $flags"
                ;;
        esac
    done
done < "$PSVFILE"

echo "restore_cfg.sh finished."
