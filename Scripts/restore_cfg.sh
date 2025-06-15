#!/bin/bash
set -euo pipefail

# Diretórios base
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="$HOME/HyDE/Configs"
BACKUP_ENABLED=true
BACKUP_DIR="$HOME/backup_$(date +%Y%m%d_%H%M%S)"
PSV_FILE="$SCRIPT_DIR/restore_cfg.psv"

echo "Starting restore_cfg.sh"
echo "Backup enabled? $BACKUP_ENABLED"
echo "Backup directory: $BACKUP_DIR"

# Função para remover prefixo "${HOME}/" de PATH do PSV para ter caminho relativo dentro de $CONFIGS_DIR
rel_path_from_home() {
    local p="$1"
    echo "${p/#\$\{HOME\}\//}"
}

# Função para expandir variáveis, apenas ${HOME}
expand_vars() {
    local str="$1"
    str="${str//\$\{HOME\}/$HOME}"
    echo "$str"
}

backup_target() {
    local target=$1
    if [ "$BACKUP_ENABLED" = true ] && [ -e "$target" ]; then
        echo "[Backup] $target -> $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        cp -r "$target" "$BACKUP_DIR/"
    fi
}

copy_file() {
    local src=$1
    local dest=$2
    mkdir -p "$(dirname "$dest")"
    cp -r "$src" "$dest"
}

while IFS= read -r line || [ -n "$line" ]; do
    # Ignora comentários e linhas vazias
    [[ "$line" =~ ^# ]] && continue
    [[ -z "$line" ]] && continue

    # Só processa linhas que começam com P|, S|, O|, B|
    if [[ "$line" =~ ^([PSOB])\| ]]; then
        IFS='|' read -r FLAG PATH TARGET DEP <<< "$line"
        
        # Expande variáveis na PATH (só ${HOME})
        EXP_PATH=$(expand_vars "$PATH")
        
        # Transforma PATH em caminho relativo removendo $HOME/
        REL_PATH=$(rel_path_from_home "$PATH")
        
        # O destino no sistema é a variável PATH expandida (ex: ~/.config/hypr)
        DEST_PATH="$EXP_PATH"
        
        # TARGET pode ter múltiplos arquivos separados por espaço
        for tgtfile in $TARGET; do
            SRC_PATH="$CONFIGS_DIR/$REL_PATH/$tgtfile"
            DEST_FILE="$DEST_PATH/$tgtfile"

            if [ ! -e "$SRC_PATH" ]; then
                echo "[Warning] Source file does not exist: $SRC_PATH"
                continue
            fi

            # Backup do destino se existir
            backup_target "$DEST_FILE"

            case "$FLAG" in
                P)
                    if [ ! -e "$DEST_FILE" ]; then
                        echo "[Populate] Copy $SRC_PATH to $DEST_FILE"
                        copy_file "$SRC_PATH" "$DEST_FILE"
                    else
                        echo "[Populate] Target exists, skipping: $DEST_FILE"
                    fi
                    ;;
                S)
                    echo "[Sync] Copy $SRC_PATH to $DEST_FILE"
                    copy_file "$SRC_PATH" "$DEST_FILE"
                    ;;
                O)
                    echo "[Overwrite] Copy $SRC_PATH to $DEST_FILE"
                    copy_file "$SRC_PATH" "$DEST_FILE"
                    ;;
                B)
                    echo "[Backup only] Backed up $DEST_FILE"
                    # backup já feito, sem cópia
                    ;;
            esac
        done
    else
        echo "[Skipping] Invalid line or comment: $line"
    fi
done < "$PSV_FILE"

