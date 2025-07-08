#!/usr/bin/env bash

# Set directory paths and file locations
scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalcontrol.sh"
sunsetConf="${confDir}/hypr/hyprsunset.json"

# Default temperature settings
default=6500
step=500
min=1000
max=20000

notify="${waybar_temperature_notification:-true}"

# Ensure the configuration file exists
if [ ! -f "$sunsetConf" ]; then
    echo "{\"temp\": $default, \"user\": 1}" >"$sunsetConf"
fi

# Read current temperature and mode
currentTemp=$(jq '.temp' "$sunsetConf")
toggle_mode=$(jq '.user' "$sunsetConf")
[ -z "$currentTemp" ] && currentTemp=$default
[ -z "$toggle_mode" ] && toggle_mode=1

# Notification function
send_notification() {
    message="Temperature: $newTemp"
    notify-send -a "t2" -r 91192 -t 800 "$message"
}

# Keep temp in range
clamp_temp() {
    newTemp=$1
    [ "$newTemp" -lt "$min" ] && newTemp=$min
    [ "$newTemp" -gt "$max" ] && newTemp=$max
    echo "$newTemp"
}

print_error() {
    cat <<EOF
$(basename "$0") <action> [mode]
...valid actions are...
    i -- <i>ncrease screen temperature [+500]
    d -- <d>ecrease screen temperature [-500]
    r -- <r>ead screen temperature
    t -- <t>oggle temperature mode (on/off)
Example:
    $(basename "$0") r       # Read the temperature value
    $(basename "$0") i       # Increase temperature by 500
    $(basename "$0") d       # Decrease temperature by 500
    $(basename "$0") t -q    # Toggle mode quietly
EOF
}

if [ $# -ge 1 ]; then
    if [[ "$2" == *q* ]] || [[ "$3" == *q* ]]; then
        notify=false
    fi
    if [[ "$2" =~ ^[0-9]+$ ]]; then
        step=$2
    elif [[ "$3" =~ ^[0-9]+$ ]]; then
        step=$3
    fi
fi

case "$1" in
i) action="increase" ;;
d) action="decrease" ;;
r) action="read" ;;
t) action="toggle" ;;
*)
    print_error
    exit 1
    ;;
esac

# Apply action
case $action in
increase)
    echo "DEBUG: Increasing temp from $currentTemp by $step" >> /tmp/hyprsunset.log
    newTemp=$(clamp_temp "$(($currentTemp + $step))") && echo "{\"temp\": $newTemp, \"user\": $toggle_mode}" >"$sunsetConf"
    echo "DEBUG: New temp $newTemp written to $sunsetConf" >> /tmp/hyprsunset.log
    ;;
decrease)
    echo "DEBUG: Decreasing temp from $currentTemp by $step" >> /tmp/hyprsunset.log
    newTemp=$(clamp_temp "$(($currentTemp - $step))") && echo "{\"temp\": $newTemp, \"user\": $toggle_mode}" >"$sunsetConf"
    echo "DEBUG: New temp $newTemp written to $sunsetConf" >> /tmp/hyprsunset.log
    ;;
read)
    newTemp=$currentTemp
    ;;
toggle)
    toggle_mode=$((1 - $toggle_mode))
    [ "$toggle_mode" -eq 1 ] && newTemp=$currentTemp || newTemp=$default
    jq --argjson toggle_mode "$toggle_mode" '.user = $toggle_mode' "$sunsetConf" >"${sunsetConf}.tmp" && mv "${sunsetConf}.tmp" "$sunsetConf"
    echo "DEBUG: Toggled mode to $toggle_mode" >> /tmp/hyprsunset.log
    ;;
esac

# Send notification if enabled
[ "$notify" = true ] && send_notification

# Ensure hyprsunset process is running
if ! pgrep -x "hyprsunset" > /dev/null; then
    hyprsunset > /dev/null &
fi

if [ "$action" = "read" ]; then
    if [ "$toggle_mode" -eq 1 ]; then
        current_running_temp=$(hyprctl hyprsunset temperature)
        if [ "$current_running_temp" != "$currentTemp" ]; then
            hyprctl --quiet hyprsunset temperature "$currentTemp"
        fi
        echo "{\"alt\":\"active\", \"tooltip\":\"Sunset mode active\"}"
    else
        echo "{\"alt\":\"inactive\", \"tooltip\":\"Sunset mode inactive\"}"
    fi
else
    if [ "$toggle_mode" -eq 0 ]; then
        hyprctl --quiet hyprsunset identity
    else
        hyprctl --quiet hyprsunset temperature "$newTemp"
    fi
fi
