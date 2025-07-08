#!/bin/bash

# Define os caminhos dos arquivos
GTK_CSS="$HOME/.cache/hyde/wallbash/gtk.css"
CODE_JSON="$HOME/.cache/hyde/wallbash/code.json"
OUTPUT_CSS="$HOME/.config/swaync/style.css"

# Função para extrair cores do gtk.css
resolve_color() {
  local color_key="$1"
  # Se a cor for um valor hexadecimal direto, retorna-o
  if [[ "$color_key" =~ ^#[0-9a-fA-F]{6,8}$ ]]; then
    echo "$color_key"
    return
  fi
  # Extrai o nome da variável Wallbash (ex.: wallbash_pry1 -> pry1)
  local var_name=$(echo "$color_key" | sed 's/#<wallbash_\(.*\)>/\1/')
  # Busca o valor no gtk.css
  local color_value=$(grep "@define-color wallbash_$var_name " "$GTK_CSS" | awk '{print $3}' | sed 's/;//')
  # Adiciona transparência, se presente (ex.: #<wallbash_1xa8>33 -> #AADAF033)
  if [[ "$color_key" =~ ([0-9a-fA-F]{2})$ ]]; then
    color_value="${color_value}${BASH_REMATCH[1]}"
  fi
  echo "$color_value"
}

# Extrai cores específicas do code.json
NOTIFICATIONS_BG=$(jq -r '.colors["notifications.background"]' "$CODE_JSON")
NOTIFICATIONS_FG=$(jq -r '.colors["notifications.foreground"]' "$CODE_JSON")
NOTIFICATIONS_BORDER=$(jq -r '.colors["notifications.border"]' "$CODE_JSON")
BUTTON_BG=$(jq -r '.colors["button.background"]' "$CODE_JSON")
BUTTON_FG=$(jq -r '.colors["button.foreground"]' "$CODE_JSON")
BUTTON_HOVER_BG=$(jq -r '.colors["button.hoverBackground"]' "$CODE_JSON")
TEXT_FG=$(jq -r '.colors["foreground"]' "$CODE_JSON")
ERROR_FG=$(jq -r '.colors["notificationsErrorIcon.foreground"]' "$CODE_JSON")
SECONDARY_TEXT=$(jq -r '.colors["textSeparator.foreground"]' "$CODE_JSON")
MPRIS_GRADIENT=$(resolve_color "#<wallbash_1xa9>") # Usando wallbash_1xa9 para o gradiente do mpris

# Resolve as cores
NOTIFICATIONS_BG=$(resolve_color "$NOTIFICATIONS_BG")
NOTIFICATIONS_FG=$(resolve_color "$NOTIFICATIONS_FG")
NOTIFICATIONS_BORDER=$(resolve_color "$NOTIFICATIONS_BORDER")
BUTTON_BG=$(resolve_color "$BUTTON_BG")
BUTTON_FG=$(resolve_color "$BUTTON_FG")
BUTTON_HOVER_BG=$(resolve_color "$BUTTON_HOVER_BG")
TEXT_FG=$(resolve_color "$TEXT_FG")
ERROR_FG=$(resolve_color "$ERROR_FG")
SECONDARY_TEXT=$(resolve_color "$SECONDARY_TEXT")

# Gera o arquivo CSS
cat > "$OUTPUT_CSS" << EOF
@define-color cc-bg $NOTIFICATIONS_BG;
@define-color noti-border-color $NOTIFICATIONS_BORDER;
@define-color noti-bg $NOTIFICATIONS_BG;
@define-color noti-bg-darker $NOTIFICATIONS_BG;
@define-color noti-bg-hover $BUTTON_HOVER_BG;
@define-color noti-bg-focus rgba(27, 27, 27, 0.6);
@define-color noti-close-bg rgba(255, 255, 255, 0.1);
@define-color noti-close-bg-hover rgba(255, 255, 255, 0.15);
@define-color text-color $TEXT_FG;

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
  color: $TEXT_FG;
  border: 2px solid $NOTIFICATIONS_BORDER;
  padding: 14px;
  max-height: 80vh; /* Limita a altura máxima a 80% da tela */
}

/* Estilo para o widget de notificações */
.notification-group {
  max-height: 400px; /* Altura máxima para o grupo de notificações */
  overflow-y: auto; /* Ativa rolagem vertical */
  padding: 5px;
}

/* Estilo para notificações individuais */
.control-center .notification-row .notification-background {
  border-radius: 7px;
  color: $TEXT_FG;
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
  color: $TEXT_FG;
}

.control-center .notification-row .notification-background .notification .notification-content .time {
  color: $SECONDARY_TEXT;
}

.control-center .notification-row .notification-background .notification .notification-content .body {
  color: $TEXT_FG;
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
  color: $TEXT_FG;
}

.control-center .notification-row .notification-background:active {
  box-shadow: inset 0 0 0 1px $NOTIFICATIONS_BORDER;
  background-color: $BUTTON_HOVER_BG;
  color: $TEXT_FG;
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
  color: $TEXT_FG;
}

.widget-mpris-subtitle {
  font-size: 1.1rem;
  color: $SECONDARY_TEXT;
}

/* Estilo para botões do centro de notificações */
.control-center .widget-title {
  color: $TEXT_FG;
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
  color: $TEXT_FG;
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
  color: $TEXT_FG;
}

.floating-notifications.background .notification-row .notification-background .notification .notification-content .time {
  color: $SECONDARY_TEXT;
}

.floating-notifications.background .notification-row .notification-background .notification .notification-content .body {
  color: $TEXT_FG;
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

# Recarrega o swaync para aplicar as mudanças
swaync-client -R
