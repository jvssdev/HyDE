#!/usr/bin/env bash

set -euo pipefail

# Diretório onde o script está
scrDir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# Detectar arquivo padrão de lista
defaultLst=""
[ -f "${scrDir}/restore_cfg.lst" ] && defaultLst="restore_cfg.lst"
[ -f "${scrDir}/restore_cfg.psv" ] && defaultLst="restore_cfg.psv"
[ -f "${scrDir}/restore_cfg.json" ] && defaultLst="restore_cfg.json"
[ -f "${scrDir}/${USER}-restore_cfg.psv" ] && defaultLst="${USER}-restore_cfg.psv"

# Detectar perfil do ZenBrowser
zen_profile=""
if [ -f "${HOME}/.zen/profiles.ini" ]; then
    zen_profile=$(awk -F= '/^\[Profile[0-9]+\]/{section=$0} $1=="Default" && $2==1{found=1} $1=="Path"{if(found){print $2; found=0}}' "${HOME}/.zen/profiles.ini")
fi

# Função para restaurar a partir de .psv
deploy_psv() {
    local psv="$1"

    while IFS= read -r line; do
        [[ -z "$line" || "$line" == \#* ]] && continue
        [[ "$line" != S\|* ]] && continue

        IFS='|' read -r _ src files label <<< "$line"
        src="${src/#\~/$HOME}"  # expandir ~ para $HOME

        # Substituir caminho se for do ZenBrowser
        if [[ "$src" == *".zen/profiles"* && -n "$zen_profile" ]]; then
            src="${HOME}/.zen/${zen_profile}/$(basename "$src")"
        fi

        # Criação do destino final (se necessário)
        mkdir -p "$src"

        # Copiar arquivos listados
        for f in $files; do
            cfg_file="${scrDir}/Configs/${src#${HOME}/}"
            if [ -f "${cfg_file}/${f}" ]; then
                cp -v "${cfg_file}/${f}" "${src}/${f}"
            else
                echo "⚠️ Arquivo não encontrado: ${cfg_file}/${f}"
            fi
        done
    done < "$psv"
}

# Executar se tiver arquivo
if [ -n "$defaultLst" ]; then
    echo "🔁 Restaurando com base em ${defaultLst}"
    deploy_psv "${scrDir}/${defaultLst}"
else
    echo "❌ Nenhuma lista de restauração encontrada."
    exit 1
fi
