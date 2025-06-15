#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC1091
#|---/ /+--------------------------------+---/ /|#
#|--/ /-| Script to restore hyde configs |--/ /-|#
#|-/ /--| Prasanth Rangan                |-/ /--|#
#|/ /---+--------------------------------+/ /---|#

# Função para extrair perfil ativo do zen profiles.ini
get_zen_profile() {
  local ini_file="${HOME}/.zen/profiles.ini"
  if [[ -f "$ini_file" ]]; then
    # Extrai o ProfileX que tem Default=1
    local profile_section
    profile_section=$(awk '/\[Profile[0-9]+\]/ {section=$0} /Default=1/ {print section}' "$ini_file" | head -n1 | tr -d '[]')
    # Extrai Path dentro da seção encontrada
    if [[ -n "$profile_section" ]]; then
      local profile_path
      profile_path=$(awk -v section="$profile_section" '
        $0 == "[" section "]" {flag=1; next} 
        /^\[.*\]/ {flag=0} 
        flag && /^Path=/ {print substr($0,6)}' "$ini_file")
      echo "$profile_path"
    fi
  fi
}

ZEN_PROFILE=$(get_zen_profile)
export ZEN_PROFILE

deploy_list() {

    while read -r lst; do

        if [ "$(awk -F '|' '{print NF}' <<<"${lst}")" -ne 5 ]; then
            continue
        fi
        # Skip lines that start with '#' or any space followed by '#'
        if [[ "${lst}" =~ ^[[:space:]]*# ]]; then
            continue
        fi

        ovrWrte=$(awk -F '|' '{print $1}' <<<"${lst}")
        bkpFlag=$(awk -F '|' '{print $2}' <<<"${lst}")
        pth=$(awk -F '|' '{print $3}' <<<"${lst}")
        pth=$(eval echo "${pth}")
        cfg=$(awk -F '|' '{print $4}' <<<"${lst}")
        pkg=$(awk -F '|' '{print $5}' <<<"${lst}")

        while read -r pkg_chk; do
            if ! pkg_installed "${pkg_chk}"; then
                echo -e "\033[0;33m[skip]\033[0m ${pth}/${cfg} as dependency ${pkg_chk} is not installed..."
                continue 2
            fi
        done < <(echo "${pkg}" | xargs -n 1)

        echo "${cfg}" | xargs -n 1 | while read -r cfg_chk; do
            if [[ -z "${pth}" ]]; then continue; fi
            tgt="${pth/#$HOME/}"

            if { [ -d "${pth}/${cfg_chk}" ] || [ -f "${pth}/${cfg_chk}" ]; } && [ "${bkpFlag}" == "Y" ]; then

                if [ ! -d "${BkpDir}${tgt}" ]; then
                    [[ ${flg_DryRun} -ne 1 ]] && mkdir -p "${BkpDir}${tgt}"
                fi

                if [ "${ovrWrte}" == "Y" ]; then
                    [[ ${flg_DryRun} -ne 1 ]] && mv "${pth}/${cfg_chk}" "${BkpDir}${tgt}"
                else

                    [[ ${flg_DryRun} -ne 1 ]] && cp -r "${pth}/${cfg_chk}" "${BkpDir}${tgt}"
                fi
                echo -e "\033[0;34m[backup]\033[0m ${pth}/${cfg_chk} --> ${BkpDir}${tgt}..."
            fi

            if [ ! -d "${pth}" ]; then
                [[ ${flg_DryRun} -ne 1 ]] && mkdir -p "${pth}"
            fi

            if [ ! -f "${pth}/${cfg_chk}" ]; then
                [[ ${flg_DryRun} -ne 1 ]] && cp -r "${CfgDir}${tgt}/${cfg_chk}" "${pth}"
                echo -e "\033[0;32m[restore]\033[0m ${pth} <-- ${CfgDir}${tgt}/${cfg_chk}..."
            elif [ "${ovrWrte}" == "Y" ]; then
                [[ ${flg_DryRun} -ne 1 ]] && cp -r "${CfgDir}${tgt}/${cfg_chk}" "${pth}"
                echo -e "\033[0;33m[overwrite]\033[0m ${pth} <-- ${CfgDir}${tgt}/${cfg_chk}..."
            else
                echo -e "\033[0;33m[preserve]\033[0m Skipping ${pth}/${cfg_chk} to preserve user setting..."
            fi
        done

    done <<<"$(cat "${CfgLst}")"
}

deploy_psv() {

    while read -r lst; do

        # Skip lines that do not have exactly 4 columns
        if [ "$(awk -F '|' '{print NF}' <<<"${lst}")" -ne 4 ]; then
            continue
        fi
        # Skip lines that start with '#' or any space followed by '#'
        if [[ "${lst}" =~ ^[[:space:]]*# ]]; then
            continue
        fi

        ctlFlag=$(awk -F '|' '{print $1}' <<<"${lst}")
        pth=$(awk -F '|' '{print $2}' <<<"${lst}")
        pth=$(eval "echo ${pth}")
        cfg=$(awk -F '|' '{print $3}' <<<"${lst}")
        pkg=$(awk -F '|' '{print $4}' <<<"${lst}")

        # Ajusta caminho do ZenBrowser baseado no perfil ativo
        if [[ "${pth}" == *".zen/profiles"* ]]; then
            if [[ -n "${ZEN_PROFILE}" ]]; then
                pth="${HOME}/.zen/${ZEN_PROFILE}"
            fi
        fi

        # Ignora linha com flag 'I'
        if [[ "${ctlFlag}" = "I" ]]; then
            print_log -r "[ignore] //" "${pth}/${cfg}"
            continue 2
        fi

        while read -r pkg_chk; do
            if ! pkg_installed "${pkg_chk}"; then
                print_log -y "[skip] " -r "missing" -b " :: " -y "missing dependency" -g " '${pkg_chk}'" -r " --> " "${pth}/${cfg}"
                continue 2
            fi
        done < <(echo "${pkg}" | xargs -n 1)

        echo "${cfg}" | xargs -n 1 | while read -r cfg_chk; do

            if [[ -z "${pth}" ]]; then continue; fi

            tgt="${pth//${HOME}/}"
            crnt_cfg="${pth}/${cfg_chk}"

            if [ ! -e "${CfgDir}${tgt}/${cfg_chk}" ] && [ "${ctlFlag}" != "B" ]; then
                echo "Source: ${CfgDir}${tgt}/${cfg_chk} does not exist, skipping..."
                print_log -y "[skip]" -b "no source" "${CfgDir}${tgt}/${cfg_chk} does not exist"
                continue
            fi

            [[ ! -d "${pth}" ]] && [[ ${flg_DryRun} -ne 1 ]] && mkdir -p "${pth}"

            if [ -e "${crnt_cfg}" ]; then
                [[ ! -d "${BkpDir}${tgt}" ]] && [[ ${flg_DryRun} -ne 1 ]] && mkdir -p "${BkpDir}${tgt}"

                case "${ctlFlag}" in
                "B")
                    [ "${flg_DryRun}" -ne 1 ] && cp -r "${pth}/${cfg_chk}" "${BkpDir}${tgt}"
                    print_log -g "[copy backup]" -b " :: " "${pth}/${cfg_chk} --> ${BkpDir}${tgt}..."
                    ;;
                "O")
                    [ "${flg_DryRun}" -ne 1 ] && mv "${pth}/${cfg_chk}" "${BkpDir}${tgt}"
                    [ "${flg_DryRun}" -ne 1 ] && cp -r "${CfgDir}${tgt}/${cfg_chk}" "${pth}"
                    print_log -r "[move to backup]" " > " -r "[overwrite]" -b " :: " "${pth}" -r " <-- " "${CfgDir}${tgt}/${cfg_chk}"
                    ;;
                "S")
                    [ "${flg_DryRun}" -ne 1 ] && cp -r "${pth}/${cfg_chk}" "${BkpDir}${tgt}"
                    [ "${flg_DryRun}" -ne 1 ] && cp -rf "${CfgDir}${tgt}/${cfg_chk}" "${pth}"
                    print_log -g "[copy to backup]" " > " -y "[sync]" -b " :: " "${pth}" -r " <--  " "${CfgDir}${tgt}/${cfg_chk}"
                    ;;
                "P")
                    [ "${flg_DryRun}" -ne 1 ] && cp -r "${pth}/${cfg_chk}" "${BkpDir}${tgt}"
                    if ! [ "${flg_DryRun}" -ne 1 ] && cp -rn "${CfgDir}${tgt}/${cfg_chk}" "${pth}" 2>/dev/null; then
                        print_log -g "[copy to backup]" " > " -y "[populate]" -b " :: " "${pth}${tgt}/${cfg_chk}"
                    else
                        print_log -g "[copy to backup]" " > " -y "[preserved]" -b " :: " "${pth}" + 208 " <--  " "${CfgDir}${tgt}/${cfg_chk}"
                    fi
                    ;;
                esac
            else
                if [ "${ctlFlag}" != "B" ]; then
                    [ "${flg_DryRun}" -ne 1 ] && cp -r "${CfgDir}${tgt}/${cfg_chk}" "${pth}"
                    print_log -y "[*populate*]" -b " :: " "${pth}" -r " <--  " "${CfgDir}${tgt}/${cfg_chk}"
                fi
            fi

        done

    done <"${1}"
}

# shellcheck disable=SC2034
log_section="deploy"
flg_DryRun=${flg_DryRun:-0}

scrDir=$(dirname "$(realpath "$0")")
if ! source "${scrDir}/global_fn.sh"; then
    echo "Error: unable to source global_fn.sh..."
    exit 1
fi

# Zen profile já carregado na variável ZEN_PROFILE

[ -f "${scrDir}/restore_cfg.lst" ] && defaultLst="restore_cfg.lst"
[ -f "${scrDir}/restore_cfg.psv" ] && defaultLst="restore_cfg.psv"
[ -f "${scrDir}/restore_cfg.json" ] && defaultLst="restore_cfg.json"
[ -f "${scrDir}/${USER}-restore_cfg.psv" ] && defaultLst="$USER-restore_cfg.psv"

CfgLst="${1:-"${scrDir}/${defaultLst}"}"
CfgDir="${2:-${cloneDir}/Configs}"
ThemeOverride="${3:-}"

if [ ! -f "${CfgLst}" ] || [ ! -d "${CfgDir}" ]; then
    echo "ERROR: '${CfgLst}' or '${CfgDir}' does not exist..."
    exit 1
fi

BkpDir="${HOME}/.config/cfg_backups/$(date +'%y%m%d_%Hh%Mm%Ss')${ThemeOverride}"

if [ -d "${BkpDir}" ]; then
    echo "ERROR: ${BkpDir} exists!"
    exit 1
else
    [[ ${flg_DryRun} -ne 1 ]] && mkdir -p "${BkpDir}"
fi

file_extension="${CfgLst##*.}"
echo ""
print_log -g "[file extension]" -b " :: " "${file_extension}"
case "${file_extension}" in
"lst")
    deploy_list "${CfgLst}"
    ;;
"psv")
    deploy_psv "${CfgLst}"
    ;;
json)
    deploy_json "${CfgLst}"
    ;;
*)
    echo "Unsupported file extension: ${file_extension}"
    exit 1
    ;;
esac

