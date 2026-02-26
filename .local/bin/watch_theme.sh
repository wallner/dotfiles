#!/bin/bash
set -euo pipefail

# Paths
BASE_DIR="$HOME/.local/bin"
THEMES_DEF="$BASE_DIR/themes.sh"
GET_THEME_SCRIPT="$BASE_DIR/get_theme.sh"
GEMINI_CONFIG="$HOME/.gemini/settings.json"
ZSH_THEME_FILE="$HOME/.local/state/zsh/theme_colors.zsh"
DELTA_THEME_FILE="$HOME/.local/state/git/delta_theme"
TMUX_THEME_FILE="$HOME/.local/state/tmux/theme.conf"
STARSHIP_THEME_FILE="$HOME/.local/state/starship/config.toml"
STARSHIP_BASE_CONFIG="$HOME/.config/starship.toml"

log() {
    logger -t watch_theme "$1"
    echo "$1" >&2
}

log "Starting watch_theme.sh..."

# Load theme definitions
if [[ -f "$THEMES_DEF" ]]; then
    # shellcheck source=/dev/null
    source "$THEMES_DEF"
    log "Loaded theme definitions."
else
    log "Error: Theme definitions not found at $THEMES_DEF"
    exit 1
fi

# Ensure all state directories exist (Self-healing)
log "Ensuring state directories exist..."
mkdir -p "$(dirname "$ZSH_THEME_FILE")"
mkdir -p "$(dirname "$DELTA_THEME_FILE")"
mkdir -p "$(dirname "$TMUX_THEME_FILE")"
mkdir -p "$(dirname "$STARSHIP_THEME_FILE")"
mkdir -p "$HOME/.config/fzf"

check_dependencies() {
    local deps=("jq" "busctl" "gsettings" "vivid")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            log "Error: Dependency '$dep' not found in PATH ($PATH). Exiting."
            exit 1
        fi
    done
    log "All dependencies found."
}

get_current_mode() {
    local mode
    mode=$("$GET_THEME_SCRIPT" 2>/dev/null || echo "unknown")
    if [[ "$mode" == "unknown" ]]; then
        log "Current mode unknown, defaulting to dark."
        echo "${LAST_THEME:-dark}" 
    else
        log "Current mode detected: $mode"
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

    log "Updating Gemini config..."
    # Robust update: only apply if jq succeeds and output is not empty
    if jq --arg theme "$gemini_theme" '.ui.theme = $theme' "$GEMINI_CONFIG" > "$tmp_file" && [ -s "$tmp_file" ]; then
        # Use cat to preserve the Stow symlink!
        cat "$tmp_file" > "$GEMINI_CONFIG"
    else
        log "Error: Failed to update Gemini config (invalid JSON or empty result). Preserving old config."
    fi
    rm -f "$tmp_file"
}

update_delta_theme() {
    local theme_mode="$1"
    local delta_theme
    [[ "$theme_mode" == "light" ]] && delta_theme="$DELTA_THEME_LIGHT" || delta_theme="$DELTA_THEME_DARK"

    log "Updating Delta theme..."
    mkdir -p "$(dirname "$DELTA_THEME_FILE")"
    cat << EOF > "$DELTA_THEME_FILE"
[delta]
	features = $delta_theme
EOF
}

update_tmux_theme() {
    local theme_mode="$1"
    local tmux_flavor
    [[ "$theme_mode" == "light" ]] && tmux_flavor="$TMUX_FLAVOR_LIGHT" || tmux_flavor="$TMUX_FLAVOR_DARK"

    log "Updating Tmux theme to $tmux_flavor..."
    mkdir -p "$(dirname "$TMUX_THEME_FILE")"
    echo "set -g @catppuccin_flavor '$tmux_flavor'" > "$TMUX_THEME_FILE"

    # Apply to any running tmux server
    if command -v tmux &>/dev/null && tmux list-sessions &>/dev/null 2>&1; then
        # 1. Update the flavor option
        tmux set-option -g @catppuccin_flavor "$tmux_flavor"
        # 2. Unset all options holding cached hex color values so the new theme
        #    can re-set them.
        tmux show-options -g | awk '/#[0-9a-fA-F]{6}/{print $1}' | while read -r var; do
            tmux set-option -gu "$var"
        done
        # 3. Re-source only the catppuccin theme config to apply the new palette
        tmux source-file ~/.tmux/plugins/tmux/catppuccin_tmux.conf \
            || log "Warning: Failed to source catppuccin theme."
    fi
}

update_starship_theme() {
    local theme_mode="$1"
    local starship_palette
    [[ "$theme_mode" == "light" ]] && starship_palette="$STARSHIP_PALETTE_LIGHT" || starship_palette="$STARSHIP_PALETTE_DARK"

    log "Updating Starship theme..."
    mkdir -p "$(dirname "$STARSHIP_THEME_FILE")"
    local tmp_file
    tmp_file=$(mktemp)
    echo "palette = \"$starship_palette\"" > "$tmp_file"
    [[ -f "$STARSHIP_BASE_CONFIG" ]] && cat "$STARSHIP_BASE_CONFIG" >> "$tmp_file"
    # Use cat to preserve potential symlinks if needed
    cat "$tmp_file" > "$STARSHIP_THEME_FILE"
    rm -f "$tmp_file"
}

update_zsh_theme() {
    local theme_mode="$1"
    local fzf_colors autosuggest ls_colors vivid_theme bat_theme
    mkdir -p "$(dirname "$ZSH_THEME_FILE")"

    if [[ "$theme_mode" == "light" ]]; then
        fzf_colors="$ZSH_FZF_COLORS_LIGHT"
        autosuggest="$ZSH_AUTOSUGGEST_LIGHT"
        vivid_theme="$VIVID_THEME_LIGHT"
        bat_theme="$BAT_THEME_LIGHT"
    else
        fzf_colors="$ZSH_FZF_COLORS_DARK"
        autosuggest="$ZSH_AUTOSUGGEST_DARK"
        vivid_theme="$VIVID_THEME_DARK"
        bat_theme="$BAT_THEME_DARK"
    fi

    log "Updating Zsh theme..."
    # Write fzf colors to XDG compliant location
    mkdir -p "$HOME/.config/fzf"
    echo "$fzf_colors" > "$HOME/.config/fzf/colors"

    # Generate LS_COLORS using vivid
    ls_colors=$(vivid generate "$vivid_theme")

    cat << EOF > "$ZSH_THEME_FILE"
# Clear existing fzf-tab flags to prevent caching issues
zstyle -d ':fzf-tab:*' fzf-flags
# Set new theme variables
export LS_COLORS="$ls_colors"
export FZF_DEFAULT_OPTS="\${FZF_BASE_OPTS}"
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="$autosuggest"
export BAT_THEME="$bat_theme"
export FZF_CTRL_T_OPTS="\${FZF_DEFAULT_OPTS} --preview 'pistol {}' --header 'E to edit' --bind 'E:execute(vim {})'"
zstyle ':fzf-tab:*' fzf-flags $fzf_colors
EOF
}

sync_themes() {
    local mode="$1"
    log "Synchronizing themes to $mode mode..."
    check_dependencies
    update_gemini_config "$mode"
    update_delta_theme "$mode"
    update_tmux_theme "$mode"
    update_starship_theme "$mode"
    update_zsh_theme "$mode"
    # Signal running zsh instances to reload theme
    log "Signaling Zsh instances..."
    pkill -USR1 -u "$(id -u)" zsh || true
    log "Sync complete."
}

# --- Main ---
LAST_THEME=$(get_current_mode)
sync_themes "$LAST_THEME"

log "Listening for theme changes via busctl..."
busctl --user monitor --match "type='signal',interface='org.freedesktop.portal.Settings',member='SettingChanged'" | while read -r line; do
    if [[ "$line" == *"color-scheme"* ]]; then
        log "Theme change detected via D-Bus."
        sleep 0.2
        CURRENT_THEME=$(get_current_mode)
        if [[ "$CURRENT_THEME" != "$LAST_THEME" ]]; then
            log "Switching theme: $LAST_THEME -> $CURRENT_THEME"
            LAST_THEME="$CURRENT_THEME"
            sync_themes "$CURRENT_THEME"
        fi
    fi
done
