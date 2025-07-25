#!/usr/bin/env bash

# read control file and initialize variables

scrDir="$(dirname "$(realpath "$0")")"
# shellcheck disable=SC1091
source "${scrDir}/globalcontrol.sh"
# shellcheck disable=SC2154
waybar_dir="${confDir}/waybar"
modules_dir="$waybar_dir/modules"
conf_file="$waybar_dir/config.jsonc"
conf_ctl="$waybar_dir/config.ctl"
swaync_dir="${confDir}/swaync"
swaync_css="$swaync_dir/style.css"
export scrDir

readarray -t read_ctl <"${conf_ctl}"
num_files="${#read_ctl[@]}"
switch=0

# update control file to set next/prev mode

if [ "${num_files}" -gt 1 ]; then
    for ((i = 0; i < "${num_files}"; i++)); do
        flag=$(cut -d '|' -f 1 <<<"${read_ctl[i]}")
        if [ "${flag}" -eq 1 ] && [ "$1" == "n" ]; then
            nextIndex=$(((i + 1) % "${num_files}"))
            switch=1
            break
        elif [ "${flag}" -eq 1 ] && [ "$1" == "p" ]; then
            nextIndex=$((i - 1))
            switch=1
            break
        fi
    done
fi

if [ $switch -eq 1 ]; then
    update_ctl="${read_ctl[nextIndex]}"
    reload_flag=1
    sed -i "s/^1/0/g" "$conf_ctl"
    awk -F '|' -v cmp="$update_ctl" '{OFS=FS} {if($0==cmp) $1=1; print$0}' "${conf_ctl}" >"${waybar_dir}/tmp" && mv "${waybar_dir}/tmp" "${conf_ctl}"
fi

# overwrite config from header module

# shellcheck disable=SC2155
export set_sysname=$(hostnamectl hostname)
# shellcheck disable=SC2155
export w_position=$(grep '^1|' "${conf_ctl}" | cut -d '|' -f 3)

# setting explicit waybar output

if [ ${#WAYBAR_OUTPUT[@]} -gt 0 ]; then
    w_output=$(printf '"%s", ' "${WAYBAR_OUTPUT[@]}")
    w_output=${w_output%, } # Remove the trailing comma and space
    print_log -sec "waybar" -stat "monitor output" "$w_output"
fi
export w_output="${w_output:-\"*\"}"

# setting waybar position

case ${w_position} in
left)
    export hv_pos="width"
    export r_deg=90
    ;;
right)
    export hv_pos="width"
    export r_deg=270
    ;;
*)
    export hv_pos="height"
    export r_deg=0
    ;;
esac

w_height=$(grep '^1|' "${conf_ctl}" | cut -d '|' -f 2)
if [ -z "${w_height}" ]; then
    y_monres=$(hyprctl -j monitors | jq '.[] | select(.focused == true) | (.height / .scale)')
    w_height=$((y_monres * 2 / 100))
fi
export w_height

export i_size=$((w_height * 6 / 10))
if [ $i_size -lt 12 ]; then
    export i_size="12"
fi

i_theme="$(get_hyprConf ICON_THEME)"
export i_theme

export i_task=$((w_height * 6 / 10))
if [ $i_task -lt 16 ]; then
    export i_task="16"
fi
export i_priv=$((w_height * 6 / 13))
if [ $i_priv -lt 12 ]; then
    export i_priv="12"
fi

envsubst <"${modules_dir}/header.jsonc" >"${conf_file}"

# module generator function

gen_mod() {
    local pos=$1
    local col=$2
    local mod=""

    list_mods() {
        mod="$(grep '^1|' "${conf_ctl}" | cut -d '|' -f "${col}")"
        if [[ $1 == "clean" ]]; then
            mod=$(echo "$mod" | awk '{for(i=1;i<=NF;i++){sub(/##.*/,"",$i); printf "%s ", $i}}')
            mod="${mod% }" # Remove trailing space
        fi
        mod="${mod//(/"custom/l_end"}"
        mod="${mod//)/"custom/r_end"}"
        mod="${mod//[/"custom/sl_end"}"
        mod="${mod//]/"custom/sr_end"}"
        mod="${mod//\{/"custom/rl_end"}"
        mod="${mod//\}/"custom/rr_end"}"
        mod="${mod// /"\",\""}"
        echo -e "${mod}"
    }

    write_mod="$write_mod $(list_mods)"
    echo -e "\t\"modules-${pos}\": [\"custom/padd\",\"$(list_mods clean)\",\"custom/padd\"]," >>"${conf_file}"
}

# write positions for modules

echo -e "\n\n// positions generated based on config.ctl //\n" >>"${conf_file}"
gen_mod left 4
gen_mod center 5
gen_mod right 6

# copy modules/*.jsonc to the config

echo -e "\n\n// sourced from modules based on config.ctl //\n" >>"${conf_file}"
echo "$write_mod" | sed 's/","/\n/g ; s/ /\n/g' | awk -F '/' '{print $NF}' | awk -F '#' '{print}' | awk '!x[$0]++' | while read -r mod_cpy; do
    if [ -f "${modules_dir}/${mod_cpy}.jsonc" ]; then
        envsubst <"${modules_dir}/${mod_cpy}.jsonc" >>"${conf_file}"
    fi
done

cat "${modules_dir}/footer.jsonc" >>"${conf_file}"

# generate waybar style
"$scrDir/wbarstylegen.sh"

# generate swaync style
mkdir -p "$swaync_dir"
cat > "$swaync_css" << EOF
@import "${waybar_dir}/theme.css";

* {
    all: unset;
    font-size: 14px;
    font-family: "JetBrainsMono Nerd Font";
    transition: 200ms;
}

/* Estilo para o centro de notificações */
.control-center {
    box-shadow: 0 0 8px 0 rgba(0, 0, 0, 0.8), inset 0 0 0 1px @main-fg;
    border-radius: 10px;
    margin: 18px;
    background-color: @bar-bg;
    color: @main-fg;
    border: 2px solid @main-fg;
    padding: 14px;
}

/* Estilo para o widget de notificações */
.notification-group {
    padding: 5px;
}

/* Estilo para notificações individuais */
.control-center .notification-row .notification-background {
    border-radius: 7px;
    color: @main-fg;
    background-color: @main-bg;
    box-shadow: inset 0 0 0 1px @main-fg;
    margin-top: 10px;
}

.control-center .notification-row .notification-background .notification {
    padding: 7px;
    border-radius: 7px;
}

.control-center .notification-row .notification-background .notification.critical {
    box-shadow: inset 0 0 7px 0 @wb-act-fg;
}

.control-center .notification-row .notification-background .notification .notification-content {
    margin: 7px;
}

.control-center .notification-row .notification-background .notification .notification-content .summary {
    color: @main-fg;
}

.control-center .notification-row .notification-background .notification .notification-content .time {
    color: @wb-hvr-fg;
}

.control-center .notification-row .notification-background .notification .notification-content .body {
    color: @main-fg;
}

.control-center .notification-row .notification-background .notification > *:last-child > * {
    min-height: 3.4em;
}

.control-center .notification-row .notification-background .notification > *:last-child > * .notification-action {
    border-radius: 7px;
    color: @wb-hvr-fg;
    background-color: @wb-hvr-bg;
    box-shadow: inset 0 0 0 1px @main-fg;
    margin: 7px;
}

.control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
    box-shadow: inset 0 0 0 1px @main-fg;
    background-color: @wb-act-bg;
    color: @wb-hvr-fg;
}

.control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
    box-shadow: inset 0 0 0 1px @main-fg;
    background-color: @wb-act-bg;
    color: @wb-hvr-fg;
}

.control-center .notification-row .notification-background .close-button {
    margin: 7px;
    padding: 2px;
    border-radius: 6.3px;
    color: @bar-bg;
    background-color: @wb-act-fg;
}

.control-center .notification-row .notification-background .close-button:hover {
    background-color: @wb-act-bg;
    color: @bar-bg;
}

.control-center .notification-row .notification-background .close-button:active {
    background-color: @wb-act-bg;
    color: @bar-bg;
}

.control-center .notification-row .notification-background:hover {
    box-shadow: inset 0 0 0 1px @main-fg;
    background-color: @wb-hvr-bg;
    color: @main-fg;
}

.control-center .notification-row .notification-background:active {
    box-shadow: inset 0 0 0 1px @main-fg;
    background-color: @wb-hvr-bg;
    color: @main-fg;
}

/* Estilo para o widget mpris */
.widget-mpris {
    background: linear-gradient(to right, @bar-bg, @wb-act-bg);
    border-radius: 10px;
    display: flex;
    justify-content: center; /* Centraliza horizontalmente */
    align-items: center; /* Centraliza verticalmente */
}

/* Estilo para o container do player */
.widget-mpris-player {
    margin: 0px;
    border-radius: 10px;
    display: flex;
    flex-direction: column; /* Organiza o conteúdo em coluna */
    align-items: center; /* Centraliza os elementos filhos horizontalmente */
    justify-content: center; /* Centraliza os elementos filhos verticalmente */
    width: 100%; /* Ocupa toda a largura do widget MPRIS */
    height: 100%; /* Ocupa toda a altura do widget MPRIS */
    padding: 10px; /* Espaço interno para evitar que o conteúdo toque as bordas */
    box-sizing: border-box; /* Garante que padding não aumente o tamanho total */
}
/* Estilo para o título do player */
.widget-mpris-title {
    font-weight: 700;
    font-size: 1.25rem;
    color: @wb-hvr-bg;
    border-radius: 10px;
    text-align: center; /* Garante que o texto do título esteja centralizado */
}

/* Estilo para o subtítulo */
.widget-mpris-subtitle {
    font-size: 1.1rem;
    color: @wb-hvr-fg;
    text-align: center; /* Garante que o subtítulo esteja centralizado */
}

/* Estilo para os botões do MPRIS (play/pause, previous, next) */
.widget-mpris button {
    padding: 12px; /* Aumenta o espaço interno dos botões */
    margin: 5px; /* Espaço entre os botões */
    min-width: 12px; /* Largura mínima maior para os botões */
    min-height: 12px; /* Altura mínima maior para os botões */
    border-radius: 8px; /* Bordas arredondadas para os botões */
    background: @wb-act-fg; /* Usa a cor de fundo ativa */
    color: @wb-act-bg; /* Cor do ícone/texto */
}

/* Estilo para os botões específicos (opcional, para personalização extra) */
.widget-mpris button.play,
.widget-mpris button.previous,
.widget-mpris button.next {
    transition: all 0.2s ease; /* Animação suave ao interagir */
}

/* Efeito ao passar o mouse sobre os botões */
.widget-mpris button:hover {
    background: @wb-hvr-bg; /* Cor de fundo ao passar o mouse */
    color: @wb-hvr-fg; /* Cor do ícone/texto ao passar o mouse */
}}



/* Estilo para botões do centro de notificações */
.control-center .widget-title {
    color: @main-fg;
    font-size: 1.3em;
}

.control-center .widget-title button {
    border-radius: 7px;
    color: @wb-hvr-fg;
    background-color: @wb-hvr-bg;
    box-shadow: inset 0 0 0 1px @main-fg;
    padding: 8px;
}

.control-center .widget-title button:hover {
    box-shadow: inset 0 0 0 1px @main-fg;
    background-color: @wb-act-bg;
    color: @wb-hvr-fg;
}

.control-center .widget-title button:active {
    box-shadow: inset 0 0 0 1px @main-fg;
    background-color: @wb-act-bg;
    color: @wb-hvr-fg;
}

/* Estilo para notificações flutuantes */
.floating-notifications.background .notification-row .notification-background {
    box-shadow: 0 0 8px 0 rgba(0, 0, 0, 0.8), inset 0 0 0 1px @main-fg;
    border-radius: 10px;
    margin: 18px;
    background-color: @bar-bg;
    color: @main-fg;
    border: 2px solid @main-fg;
    padding: 0;
}

.floating-notifications.background .notification-row .notification-background .notification {
    padding: 7px;
    border-radius: 10px;
}

.floating-notifications.background .notification-row .notification-background .notification.critical {
    box-shadow: inset 0 0 7px 0 @wb-act-fg;
}

.floating-notifications.background .notification-row .notification-background .notification .notification-content {
    margin: 7px;
}

.floating-notifications.background .notification-row .notification-background .notification .notification-content .summary {
    color: @main-fg;
}

.floating-notifications.background .notification-row .notification-background .notification .notification-content .time {
    color: @wb-hvr-fg;
}

.floating-notifications.background .notification-row .notification-background .notification .notification-content .body {
    color: @main-fg;
}

.floating-notifications.background .notification-row .notification-background .notification > *:last-child > * {
    min-height: 3.4em;
}

.floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action {
    border-radius: 7px;
    color: @wb-hvr-fg;
    background-color: @wb-hvr-bg;
    box-shadow: inset 0 0 0 1px @main-fg;
    margin: 7px;
}

.floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
    box-shadow: inset 0 0 0 1px @main-fg;
    background-color: @wb-act-bg;
    color: @wb-hvr-fg;
}

.floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
    box-shadow: inset 0 0 0 1px @main-fg;
    background-color: @wb-act-bg;
    color: @wb-hvr-fg;
}

.floating-notifications.background .notification-row .notification-background .close-button {
    margin: 7px;
    padding: 2px;
    border-radius: 6.3px;
    color: @bar-bg;
    background-color: @wb-act-fg;
}

.floating-notifications.background .notification-row .notification-background .close-button:hover {
    background-color: @wb-act-bg;
    color: @bar-bg;
}

.floating-notifications.background .notification-row .notification-background .close-button:active {
    background-color: @wb-act-bg;
    color: @bar-bg;
}
EOF

# restart waybar
if [ "$reload_flag" == "1" ]; then
    killall waybar
    if [ -f "${waybar_dir}/config" ] && [ -s "${waybar_dir}/config" ]; then
        waybar &
        disown
    else
        waybar --config "${waybar_dir}/config.jsonc" --style "${waybar_dir}/style.css" 2>&1 &
        disown
    fi
fi

# reload swaync
if command -v swaync >/dev/null 2>&1; then
    killall swaync
    swaync &
    disown
fi
