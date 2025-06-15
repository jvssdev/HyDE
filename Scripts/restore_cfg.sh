#!/usr/bin/env bash

# === Determine script directory and config source directory ===
scrDir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
cfgDir="${scrDir}/Configs"

# === Dry run mode: if set to 1, no files will be copied ===
flg_DryRun=0

# === Detect ZenBrowser default profile safely ===
zen_profile=""
zen_profiles_ini="${HOME}/.zen/profiles.ini"

if [ -f "${zen_profiles_ini}" ]; then
    # Extract the path of the profile marked as Default=1
    zen_profile_path=$(awk -F '=' '
        /^\[.*\]/ { section=$0 }
        $1 ~ /^Path/ { path[section]=$2 }
        $1 ~ /^Default/ && $2==1 { def=section }
        END {
            gsub(/[\[\]]/, "", def);
            print path["["def"]"]
        }
    ' "${zen_profiles_ini}")

    if [ -n "${zen_profile_path}" ]; then
        zen_profile="${HOME}/.zen/${zen_profile_path}"
        echo "[zenbrowser] Default profile detected: ${zen_profile}"
    else
        echo "[zenbrowser] No default profile found in profiles.ini"
    fi
else
    echo "[zenbrowser] profiles.ini not found at ~/.zen"
fi

# === Expand variables like ${zen_profile} and ${HOME} in paths ===
expand_path() {
    local input="$1"
    local expanded="${input//\$\{zen_profile\}/${zen_profile}}"
    eval echo "${expanded}"
}

# === Restore dotfiles based on a .psv (pipe-separated value) file ===
deploy_psv() {
    local psv="$1"
    while IFS= read -r line; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^# ]] && continue

        # Split line into flag | path | target | dependency
        IFS='|' read -r flag path target dep <<<"$line"

        # Expand paths with variables
        path=$(expand_path "$path")
        target=$(expand_path "$target")

        # Define source and destination
        src="${cfgDir}/${target}"
        dst="${path}"

        # Show operation summary
        [[ "$flag" =~ B|P|S|O ]] && echo "[*] ${flag} ${src} -> ${dst}"

        # Ensure destination directory exists
        [[ ${flg_DryRun} -ne 1 ]] && mkdir -p "$dst"

        # === Handle Backup flag (B) ===
        if [[ "$flag" == *"B"* && -e "${dst}" ]]; then
            bak="${dst}.bak.$(date +%s)"
            echo "[bkp] Backing up ${dst} to ${bak}"
            [[ ${flg_DryRun} -ne 1 ]] && cp -a "${dst}" "${bak}"
        fi

        # === Handle main flags ===
        case "$flag" in
            # Populate (only if destination doesn't exist)
            P)
                if [[ ! -e "$dst" && ${flg_DryRun} -ne 1 ]]; then
                    cp -a "$src" "$dst"
                fi
                ;;
            # Sync (copy and overwrite only listed contents)
            S)
                [[ ${flg_DryRun} -ne 1 ]] && rsync -a --delete "$src/" "$dst/"
                ;;
            # Overwrite everything
            O)
                [[ ${flg_DryRun} -ne 1 ]] && cp -a "$src" "$dst"
                ;;
        esac

    done < "$psv"
}

# === Main execution ===

echo "🛠️ Restoring configuration using restore_cfg.psv..."
deploy_psv "${scrDir}/restore_cfg.psv"
echo "✅ Done."
