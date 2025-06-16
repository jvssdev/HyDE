#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC1091
#|---/ /+--------------------------------+---/ /|#
#|--/ /-| Script to restore hyde configs |--/ /-|#
#|-/ /--| Prasanth Rangan                |-/ /--|#
#|/ /---+--------------------------------+/ /---|#

# Função para extrair o zen_profile do profiles.ini
get_zen_profile() {
    local ini="${HOME}/.zen/profiles.ini"
    if [[ -f "$ini" ]]; then
        # Extrai a linha Default= e pega o valor (sem espaços)
        zen_profile=$(awk -F '=' '/^Default=/{print $2}' "$ini" | tr -d '[:space:]')
    else
        zen_profile=""
    fi
}

# Função para deploy a partir do .psv
deploy_psv() {
    local psv_file="$1"
    local line pth files tag

    while IFS='|' read -r line; do
        # Ignora linhas em branco ou comentários
        [[ -z "$line" || "$line" =~ ^# ]] && continue

        # Quebra a linha no formato: Tipo|Caminho|Arquivos|Tag
        IFS='|' read -r type pth files tag <<< "$line"

        # Substitui variável $HOME no path (expansão)
        pth="${pth//\$\{HOME\}/$HOME}"

        # Substitui o path genérico do zen_profile se aplicável
        if [[ "$pth" == *".zen/profiles"* ]]; then
            if [[ -n "$zen_profile" ]]; then
                echo "[DEBUG] Substituindo caminho genérico '$pth' pelo perfil real '${HOME}/.zen/${zen_profile}'"
                pth="${HOME}/.zen/${zen_profile}"
            else
                echo "[WARN] zen_profile vazio, não substituindo caminho para $pth"
            fi
        fi

        echo "[INFO] Deploy $type -> $pth com arquivos: $files (tag: $tag)"

        # Aqui entra sua lógica para copiar arquivos/diretorios
        # Exemplo (adaptar para seu código real):
        # cp -v "$scrDir/$(basename $pth)/"$files "$pth"/
        # (ou outra lógica para sincronizar conforme o tipo S, D etc)
    done < "$psv_file"
}

# MAIN

get_zen_profile
echo "Zen Profile detectado: '$zen_profile'"

deploy_psv "${scrDir}/restore_cfg.psv"
