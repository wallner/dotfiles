#!/bin/bash
set -euo pipefail

# Paths
BASE_DIR="$HOME/.local/bin"
THEMES_DEF="$BASE_DIR/themes.sh"
GET_THEME_SCRIPT="$BASE_DIR/get_theme.sh"
GEMINI_CONFIG="$HOME/.gemini/settings.json"
BAT_CONFIG="$HOME/.config/bat/config"
ZSH_THEME_FILE="$HOME/.zsh/theme_colors.zsh"
VIVID_BIN="$HOME/.local/bin/vivid"

# Load theme definitions
if [[ -f "$THEMES_DEF" ]]; then
    # shellcheck source=/dev/null
    source "$THEMES_DEF"
else
    logger -t watch_theme "Error: Theme definitions not found at $THEMES_DEF"
    exit 1
fi

log() {
    logger -t watch_theme "$1"
}

check_dependencies() {
    local deps=("jq" "dbus-monitor" "gsettings" "cat")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            log "Error: Dependency '$dep' not found. Exiting."
            exit 1
        fi
    done
}

get_current_mode() {
    local mode
    mode=$("$GET_THEME_SCRIPT" 2>/dev/null || echo "unknown")
    if [[ "$mode" == "unknown" ]]; then
        echo "${LAST_THEME:-dark}" 
    else
        echo "$mode"
    fi
}

update_gemini_config() {
    local theme_mode="$1"
    local gemini_theme
    [[ ! -f "$GEMINI_CONFIG" ]] && return 0
    [[ "$theme_mode" == "light" ]] && gemini_theme="$GEMINI_THEME_LIGHT" || gemini_theme="$GEMINI_THEME_DARK"

    local tmp_file
    tmp_file=$(mktemp)

    if jq --arg theme "$gemini_theme" '.ui.theme = $theme' "$GEMINI_CONFIG" > "$tmp_file"; then
        cat "$tmp_file" > "$GEMINI_CONFIG"
    fi
    rm -f "$tmp_file"
}

update_bat_config() {
    local theme_mode="$1"
    local bat_theme
    mkdir -p "$(dirname "$BAT_CONFIG")"
    [[ "$theme_mode" == "light" ]] && bat_theme="$BAT_THEME_LIGHT" || bat_theme="$BAT_THEME_DARK"
    echo "--theme=\"$bat_theme\"" > "$BAT_CONFIG"
}

update_zsh_theme() {
    local theme_mode="$1"
    local fzf_colors autosuggest ls_colors vivid_theme
    mkdir -p "$(dirname "$ZSH_THEME_FILE")"

    if [[ "$theme_mode" == "light" ]]; then
        fzf_colors="$ZSH_FZF_COLORS_LIGHT"
        autosuggest="$ZSH_AUTOSUGGEST_LIGHT"
        vivid_theme="$VIVID_THEME_LIGHT"
    else
        fzf_colors="$ZSH_FZF_COLORS_DARK"
        autosuggest="$ZSH_AUTOSUGGEST_DARK"
        vivid_theme="$VIVID_THEME_DARK"
    fi

    # Generate LS_COLORS using vivid if available
    ls_colors=""
    if [[ -x "$VIVID_BIN" ]]; then
        ls_colors=$("$VIVID_BIN" generate "$vivid_theme")
    fi

    cat << EOF > "$ZSH_THEME_FILE"
export LS_COLORS="$ls_colors"
export FZF_DEFAULT_OPTS="\${FZF_BASE_OPTS} $fzf_colors"
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="$autosuggest"
export FZF_CTRL_T_OPTS="\${FZF_DEFAULT_OPTS} --preview 'pistol {}' --header 'E to edit' --bind 'E:execute(vim {})'"
zstyle ':fzf-tab:*' fzf-flags $fzf_colors
EOF
}

sync_themes() {
    local mode="$1"
    update_gemini_config "$mode"
    update_bat_config "$mode"
    update_zsh_theme "$mode"
    log "Synced all themes to $mode mode"
}

# --- Main ---
check_dependencies
LAST_THEME=$(get_current_mode)
sync_themes "$LAST_THEME"

log "Listening for theme changes..."
dbus-monitor "type='signal',interface='org.freedesktop.portal.Settings',member='SettingChanged'" | while read -r line; do
    if echo "$line" | grep -q "color-scheme"; then
        sleep 0.2
        CURRENT_THEME=$(get_current_mode)
        if [[ "$CURRENT_THEME" != "$LAST_THEME" ]]; then
            log "Theme change detected: $LAST_THEME -> $CURRENT_THEME"
            LAST_THEME="$CURRENT_THEME"
            sync_themes "$CURRENT_THEME"
        fi
    fi
done
