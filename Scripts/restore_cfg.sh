#!/usr/bin/env bash
# shellcheck disable=SC2154,SC1091,SC2034

#|---/ /+--------------------------------+---/ /|#
#|--/ /-| Script to restore hyde configs |--/ /-|#
#|-/ /--| Prasanth Rangan                |-/ /--|#
#|/ /---+--------------------------------+/ /---|#

get_zen_profile() {
  local ini_file="${HOME}/.zen/profiles.ini"
  local profile_path=""

  if [[ ! -f "$ini_file" ]]; then
    return
  fi

  profile_path=$(awk '
    /^\[Install.*\]/ {install=1; next}
    /^\[.*\]/ {install=0}
    install && /^Default=/ {
      print substr($0, 9)
      exit
    }' "$ini_file")

  if [[ -z "$profile_path" ]]; then
    local profile_section
    profile_section=$(awk '/\[Profile[0-9]+\]/ {section=$0} /Default=1/ {print section}' "$ini_file" | head -n1 | tr -d '[]')
    if [[ -n "$profile_section" ]]; then
      profile_path=$(awk -v section="$profile_section" '
        $0 == "[" section "]" {flag=1; next}
        /^\[.*\]/ {flag=0}
        flag && /^Path=/ {print substr($0,6)}' "$ini_file")
    fi
  fi

  echo "$profile_path"
}

pkg_installed() {
  command -v "$1" >/dev/null 2>&1
}

print_log() {
  local clr_green="\033[0;32m"
  local clr_yellow="\033[0;33m"
  local clr_red="\033[0;31m"
  local clr_blue="\033[0;34m"
  local clr_reset="\033[0m"
  local type=$1
  shift
  case "$type" in
    g) echo -e "${clr_green}$*${clr_reset}" ;;
    y) echo -e "${clr_yellow}$*${clr_reset}" ;;
    r) echo -e "${clr_red}$*${clr_reset}" ;;
    b) echo -e "${clr_blue}$*${clr_reset}" ;;
    *) echo "$*" ;;
  esac
}

deploy_psv() {
  local psv_file="$1"
  local zen_profile="$2"

  if [[ ! -f "$psv_file" ]]; then
    print_log r "[ERROR] Arquivo PSV não encontrado: $psv_file"
    exit 1
  fi

  while IFS= read -r line || [[ -n "$line" ]]; do

    if [[ "$line" =~ ^[[:space:]]*# ]] || [[ "$(awk -F'|' '{print NF}' <<< "$line")" -lt 4 ]]; then
      continue
    fi

    ctlFlag=$(awk -F'|' '{print $1}' <<< "$line")
    pth=$(awk -F'|' '{print $2}' <<< "$line")
    pth=$(eval echo "$pth")  # expande variáveis

    cfg=$(awk -F'|' '{print $3}' <<< "$line")
    pkg=$(awk -F'|' '{print $4}' <<< "$line")

    if [[ "$pth" == *".zen/Profiles"* ]]; then
      if [[ -n "$zen_profile" ]]; then
        pth="${HOME}/.zen/${zen_profile}"
      fi
    fi

    if [[ "$ctlFlag" == "I" ]]; then
      print_log r "[ignore] // $pth/$cfg"
      continue
    fi

    for dep in $pkg; do
      if ! pkg_installed "$dep"; then
        print_log y "[skip] missing dependency '$dep' --> $pth/$cfg"
        continue 2
      fi
    done

    tgt="${pth//${HOME}/}"

    [[ ! -d "$pth" ]] && mkdir -p "$pth"

    for cfg_file in $cfg; do
      src="${CfgDir}${tgt}/${cfg_file}"
      dst="${pth}/${cfg_file}"

      if [[ ! -e "$src" ]] && [[ "$ctlFlag" != "B" ]]; then
        print_log y "[skip] no source $src"
        continue
      fi

      if [[ -e "$dst" ]]; then
        [[ ! -d "${BkpDir}${tgt}" ]] && mkdir -p "${BkpDir}${tgt}"
        case "$ctlFlag" in
          B)
            cp -r "$dst" "${BkpDir}${tgt}"
            print_log g "[copy backup] $dst --> ${BkpDir}${tgt}"
            ;;
          O)
            mv "$dst" "${BkpDir}${tgt}"
            cp -r "$src" "$pth"
            print_log r "[move backup + overwrite] $pth <-- $src"
            ;;
          S)
            cp -r "$dst" "${BkpDir}${tgt}"
            cp -rf "$src" "$pth"
            print_log g "[copy backup + sync] $pth <-- $src"
            ;;
          P)
            cp -r "$dst" "${BkpDir}${tgt}"
            cp -rn "$src" "$pth" 2>/dev/null && print_log g "[copy backup + populate] $pth <-- $src" || print_log y "[preserved] $dst"
            ;;
          *)
            print_log y "[preserved] $dst"
            ;;
        esac
      else
        # Caso não exista, só copia
        if [[ "$ctlFlag" != "B" ]]; then
          cp -r "$src" "$pth"
          print_log g "[populate] $pth <-- $src"
        fi
      fi
    done

  done < "$psv_file"
}

scrDir=$(dirname "$(realpath "$0")")
CfgDir="${HOME}/HyDE/Configs" 

ZEN_PROFILE=$(get_zen_profile)
export ZEN_PROFILE

# -------------------------------
# [AutoSync] Zen Browser files
# -------------------------------

zen_src_base="${HOME}/.config/zen"
zen_repo_base="${CfgDir}/.zen/${ZEN_PROFILE}" 

for subdir in chrome userjs; do
  mkdir -p "${zen_repo_base}/${subdir}"
  for file in "${zen_src_base}/${subdir}/"*; do
    [ -f "$file" ] || continue
    cp -u "$file" "${zen_repo_base}/${subdir}/"
  done
done

CfgLst="${scrDir}/restore_cfg.psv"
if [[ ! -f "$CfgLst" ]]; then
  print_log r "Arquivo $CfgLst não encontrado!"
  exit 1
fi

# Backups directory
BkpDir="${HOME}/.config/cfg_backups/$(date +'%y%m%d_%H%M%S')"
mkdir -p "$BkpDir"

deploy_psv "$CfgLst" "$ZEN_PROFILE"

