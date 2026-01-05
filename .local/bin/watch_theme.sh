#!/bin/bash
set -u

# Configuration
GEMINI_CONFIG="$HOME/.gemini/settings.json"
GEMINI_THEME_DARK="Default"
GEMINI_THEME_LIGHT="Default Light"
GET_THEME_SCRIPT="$HOME/.local/bin/get_theme.sh"

# Function to update Gemini CLI configuration
update_gemini_config() {
    local theme_mode="$1"
    local gemini_theme

    if [ ! -f "$GEMINI_CONFIG" ]; then
        logger -t watch_theme "Config file not found: $GEMINI_CONFIG"
        return
    fi

    if [ "$theme_mode" = "light" ]; then
        gemini_theme="$GEMINI_THEME_LIGHT"
    else
        gemini_theme="$GEMINI_THEME_DARK"
    fi

    local tmp_file
    tmp_file=$(mktemp)

    if jq --arg theme "$gemini_theme" '.ui.theme = $theme' "$GEMINI_CONFIG" > "$tmp_file"; then
        cat "$tmp_file" > "$GEMINI_CONFIG"
        rm "$tmp_file"
        logger -t watch_theme "Updated Gemini config to $gemini_theme"
    else
        rm -f "$tmp_file"
        logger -t watch_theme "Error: Failed to update Gemini config with jq."
    fi
}

# Initial sync
LAST_THEME=$($GET_THEME_SCRIPT)
logger -t watch_theme "Startup. Current system theme: $LAST_THEME"
update_gemini_config "$LAST_THEME"

# Listen for the SettingChanged signal on the XDG Desktop Portal interface.
# Use process substitution to avoid subshell issues with variable persistence.
while read -r line; do
    if echo "$line" | grep -q "color-scheme"; then
        CURRENT_THEME=$($GET_THEME_SCRIPT)

        if [ "$CURRENT_THEME" = "$LAST_THEME" ]; then
            # logger -t watch_theme "Signal received, but theme is still $CURRENT_THEME. Skipping."
            continue
        fi

        logger -t watch_theme "Theme changed: $LAST_THEME -> $CURRENT_THEME"
        LAST_THEME="$CURRENT_THEME"
        update_gemini_config "$CURRENT_THEME"
    fi
done < <(dbus-monitor "type='signal',interface='org.freedesktop.portal.Settings',member='SettingChanged'")
