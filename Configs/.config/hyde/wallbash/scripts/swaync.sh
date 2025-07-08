#!/bin/bash

# Define paths
: "${XDG_CONFIG_HOME:=$HOME/.config}"
GTK_CSS="$HOME/.cache/hyde/wallbash/gtk.css"
SWAYNC_DCOL="$XDG_CONFIG_HOME/hyde/wallbash/always/swaync.dcol"
OUTPUT_CSS="$XDG_CONFIG_HOME/swaync/style.css"
DEBUG_LOG="$HOME/.cache/hyde/wallbash/swaync_debug.log"

# Create debug log directory
mkdir -p "$(dirname "$DEBUG_LOG")"
echo "Starting swaync.sh at $(date)" > "$DEBUG_LOG"

# Check if required files exist
if [[ ! -f "$GTK_CSS" ]]; then
  echo "Error: $GTK_CSS not found" >&2
  echo "Error: $GTK_CSS not found" >> "$DEBUG_LOG"
  exit 1
fi
if [[ ! -f "$SWAYNC_DCOL" ]]; then
  echo "Error: $SWAYNC_DCOL not found" >&2
  echo "Error: $SWAYNC_DCOL not found" >> "$DEBUG_LOG"
  exit 1
fi

# Read output path from swaync.dcol
OUTPUT_CSS=$(head -n 1 "$SWAYNC_DCOL" | sed "s|\${XDG_CONFIG_HOME}|$XDG_CONFIG_HOME|")
echo "Output CSS path: $OUTPUT_CSS" >> "$DEBUG_LOG"

# Function to resolve Wallbash colors from gtk.css
resolve_color() {
  local color_key="$1"
  echo "Resolving color: $color_key" >> "$DEBUG_LOG"
  if [[ "$color_key" =~ ^#[0-9a-fA-F]{6,8}$ ]]; then
    echo "$color_key"
    return
  fi
  local var_name
  var_name=$(echo "$color_key" | sed 's/#<wallbash_\(.*\)>/\1/')
  local color_value
  color_value=$(grep "@define-color wallbash_$var_name " "$GTK_CSS" | awk '{print $3}' | sed 's/;//')
  if [[ "$color_key" =~ ([0-9a-fA-F]{2})$ ]]; then
    color_value="${color_value}${BASH_REMATCH[1]}"
  fi
  if [[ -z "$color_value" || ! "$color_value" =~ ^#[0-9a-fA-F]{6,8}$ ]]; then
    echo "Error: Could not resolve color for $color_key in $GTK_CSS" >&2
    echo "Error: Could not resolve color for $color_key in $GTK_CSS" >> "$DEBUG_LOG"
    exit 1
  fi
  echo "$color_value"
}

# Extract and resolve colors
declare -A colors
while IFS='=' read -r key value; do
  if [[ "$key" != "${XDG_CONFIG_HOME}/swaync/style.css" && -n "$key" ]]; then
    colors["$key"]=$(resolve_color "$value")
    echo "Extracted $key=${colors[$key]}" >> "$DEBUG_LOG"
  fi
done < <(tail -n +2 "$SWAYNC_DCOL")

# Validate required colors
required_colors=(
  background foreground border button-background button-foreground
  button-hover-background critical-foreground secondary-text mpris-gradient
)
for key in "${required_colors[@]}"; do
  if [[ -z "${colors[$key]}" ]]; then
    echo "Error: Missing color definition for $key in $SWAYNC_DCOL" >&2
    echo "Error: Missing color definition for $key in $SWAYNC_DCOL" >> "$DEBUG_LOG"
    exit 1
  fi
done

# Assign resolved colors
NOTIFICATIONS_BG=${colors[background]}
NOTIFICATIONS_FG=${colors[foreground]}
NOTIFICATIONS_BORDER=${colors[border]}
BUTTON_BG=${colors[button-background]}
BUTTON_FG=${colors[button-foreground]}
BUTTON_HOVER_BG=${colors[button-hover-background]}
ERROR_FG=${colors[critical-foreground]}
SECONDARY_TEXT=${colors[secondary-text]}
MPRIS_GRADIENT=${colors[mpris-gradient]}

# Log resolved colors
echo "Resolved colors:" >> "$DEBUG_LOG"
for key in "${!colors[@]}"; do
  echo "$key=${colors[$key]}" >> "$DEBUG_LOG"
done

# Ensure output directory exists
mkdir -p "$(dirname "$OUTPUT_CSS")"

# Generate CSS file
echo "Generating CSS at $OUTPUT_CSS" >> "$DEBUG_LOG"
cat > "$OUTPUT_CSS" << EOF
@define-color cc-bg $NOTIFICATIONS_BG;
@define-color noti-border-color $NOTIFICATIONS_BORDER;
@define-color noti-bg $NOTIFICATIONS_BG;
@define-color noti-bg-darker $NOTIFICATIONS_BG;
@define-color noti-bg-hover $BUTTON_HOVER_BG;
@define-color noti-bg-focus rgba(27, 27, 27, 0.6);
@define-color noti-close-bg rgba(255, 255, 255, 0.1);
@define-color noti-close-bg-hover rgba(255, 255, 255, 0.15);
@define-color text-color $NOTIFICATIONS_FG;

* {
  all: unset;
  font-size: 14px;
  font-family: "Maple Mono NF";
  transition: 200ms;
}

/* Estilo para o centro de notificações */
.control-center {
  box-shadow: 0 0 8px 0 rgba(0, 0, 0, 0.8), inset 0 0 0 1px $NOTIFICATIONS_BORDER;
  border-radius: 10px;
  margin: 18px;
  background-color: $NOTIFICATIONS_BG;
  color: $NOTIFICATIONS_FG;
  border: 2px solid $NOTIFICATIONS_BORDER;
  padding: 14px;
  max-height: 80vh;
}

/* Estilo para o widget de notificações */
.notification-group {
  max-height: 400px;
  overflow-y: auto;
  padding: 5px;
}

/* Estilo para notificações individuais */
.control-center .notification-row .notification-background {
  border-radius: 7px;
  color: $NOTIFICATIONS_FG;
  background-color: $NOTIFICATIONS_BG;
  box-shadow: inset 0 0 0 1px $NOTIFICATIONS_BORDER;
  margin-top: 10px;
}

.control-center .notification-row .notification-background .notification {
  padding: 7px;
  border-radius: 7px;
}

.control-center .notification-row .notification-background .notification.critical {
  box-shadow: inset 0 0 7px 0 $ERROR_FG;
}

.control-center .notification-row .notification-background .notification .notification-content {
  margin: 7px;
}

.control-center .notification-row .notification-background .notification .notification-content .summary {
  color: $NOTIFICATIONS_FG;
}

.control-center .notification-row .notification-background .notification .notification-content .time {
  color: $SECONDARY_TEXT;
}

.control-center .notification-row .notification-background .notification .notification-content .body {
  color: $NOTIFICATIONS_FG;
}

.control-center .notification-row .notification-background .notification > *:last-child > * {
  min-height: 3.4em;
}

.control-center .notification-row .notification-background .notification > *:last-child > * .notification-action {
  border-radius: 7px;
  color: $BUTTON_FG;
  background-color: $BUTTON_BG;
  box-shadow: inset 0 0 0 1px $NOTIFICATIONS_BORDER;
  margin: 7px;
}

.control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
  box-shadow: inset 0 0 0 1px $NOTIFICATIONS_BORDER;
  background-color: $BUTTON_HOVER_BG;
  color: $BUTTON_FG;
}

.control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
  box-shadow: inset 0 0 0 1px $NOTIFICATIONS_BORDER;
  background-color: $BUTTON_HOVER_BG;
  color: $BUTTON_FG;
}

.control-center .notification-row .notification-background .close-button {
  margin: 7px;
  padding: 2px;
  border-radius: 6.3px;
  color: $NOTIFICATIONS_BG;
  background-color: $ERROR_FG;
}

.control-center .notification-row .notification-background .close-button:hover {
  background-color: $ERROR_FG;
  color: $NOTIFICATIONS_BG;
}

.control-center .notification-row .notification-background .close-button:active {
  background-color: $ERROR_FG;
  color: $NOTIFICATIONS_BG;
}

.control-center .notification-row .notification-background:hover {
  box-shadow: inset 0 0 0 1px $NOTIFICATIONS_BORDER;
  background-color: $BUTTON_HOVER_BG;
  color: $NOTIFICATIONS_FG;
}

.control-center .notification-row .notification-background:active {
  box-shadow: inset 0 0 0 1px $NOTIFICATIONS_BORDER;
  background-color: $BUTTON_HOVER_BG;
  color: $NOTIFICATIONS_FG;
}

/* Estilo para o widget mpris */
.widget-mpris {
  background: linear-gradient(to right, $NOTIFICATIONS_BG, $MPRIS_GRADIENT);
  padding: 10px;
  border-radius: 10px;
}

.widget-mpris-player {
  padding: 8px;
  margin: 8px;
}

.widget-mpris-title {
  font-weight: 700;
  font-size: 1.25rem;
  color: $NOTIFICATIONS_FG;
}

.widget-mpris-subtitle {
  font-size: 1.1rem;
  color: $SECONDARY_TEXT;
}

/* Estilo para botões do centro de notificações */
.control-center .widget-title {
  color: $NOTIFICATIONS_FG;
  font-size: 1.3em;
}

.control-center .widget-title button {
  border-radius: 7px;
  color: $BUTTON_FG;
  background-color: $BUTTON_BG;
  box-shadow: inset 0 0 0 1px $NOTIFICATIONS_BORDER;
  padding: 8px;
}

.control-center .widget-title button:hover {
  box-shadow: inset 0 0 0 1px $NOTIFICATIONS_BORDER;
  background-color: $BUTTON_HOVER_BG;
  color: $BUTTON_FG;
}

.control-center .widget-title button:active {
  box-shadow: inset 0 0 0 1px $NOTIFICATIONS_BORDER;
  background-color: $BUTTON_HOVER_BG;
  color: $BUTTON_FG;
}

/* Estilo para notificações flutuantes */
.floating-notifications.background .notification-row .notification-background {
  box-shadow: 0 0 8px 0 rgba(0, 0, 0, 0.8), inset 0 0 0 1px $NOTIFICATIONS_BORDER;
  border-radius: 10px;
  margin: 18px;
  background-color: $NOTIFICATIONS_BG;
  color: $NOTIFICATIONS_FG;
  border: 2px solid $NOTIFICATIONS_BORDER;
  padding: 0;
}

.floating-notifications.background .notification-row .notification-background .notification {
  padding: 7px;
  border-radius: 10px;
}

.floating-notifications.background .notification-row .notification-background .notification.critical {
  box-shadow: inset 0 0 7px 0 $ERROR_FG;
}

.floating-notifications.background .notification-row .notification-background .notification .notification-content {
  margin: 7px;
}

.floating-notifications.background .notification-row .notification-background .notification .notification-content .summary {
  color: $NOTIFICATIONS_FG;
}

.floating-notifications.background .notification-row .notification-background .notification .notification-content .time {
  color: $SECONDARY_TEXT;
}

.floating-notifications.background .notification-row .notification-background .notification .notification-content .body {
  color: $NOTIFICATIONS_FG;
}

.floating-notifications.background .notification-row .notification-background .notification > *:last-child > * {
  min-height: 3.4em;
}

.floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action {
  border-radius: 7px;
  color: $BUTTON_FG;
  background-color: $BUTTON_BG;
  box-shadow: inset 0 0 0 1px $NOTIFICATIONS_BORDER;
  margin: 7px;
}

.floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
  box-shadow: inset 0 0 0 1px $NOTIFICATIONS_BORDER;
  background-color: $BUTTON_HOVER_BG;
  color: $BUTTON_FG;
}

.floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
  box-shadow: inset 0 0 0 1px $NOTIFICATIONS_BORDER;
  background-color: $BUTTON_HOVER_BG;
  color: $BUTTON_FG;
}

.floating-notifications.background .notification-row .notification-background .close-button {
  margin: 7px;
  padding: 2px;
  border-radius: 6.3px;
  color: $NOTIFICATIONS_BG;
  background-color: $ERROR_FG;
}

.floating-notifications.background .notification-row .notification-background .close-button:hover {
  background-color: $ERROR_FG;
  color: $NOTIFICATIONS_BG;
}

.floating-notifications.background .notification-row .notification-background .close-button:active {
  background-color: $ERROR_FG;
  color: $NOTIFICATIONS_BG;
}
EOF

echo "CSS generated at $OUTPUT_CSS" >> "$DEBUG_LOG"

# Reload swaync
if command -v swaync-client >/dev/null 2>&1; then
  swaync-client -R
  echo "swaync-client reloaded" >> "$DEBUG_LOG"
else
  echo "Warning: swaync-client not found" >&2
  echo "Warning: swaync-client not found" >> "$DEBUG_LOG"
fi
