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
        mv "$tmp_file" "$GEMINI_CONFIG"
    else
        rm -f "$tmp_file"
        logger -t watch_theme "Error: Failed to update Gemini config with jq."
    fi
}

# Initial check to prevent logging if the state hasn't actually changed from startup
LAST_THEME=$($GET_THEME_SCRIPT)

# Listen for the SettingChanged signal on the XDG Desktop Portal interface.
dbus-monitor "type='signal',interface='org.freedesktop.portal.Settings',member='SettingChanged'" | \
while read -r line; do
    # Check if the line contains the color-scheme key
    if echo "$line" | grep -q "color-scheme"; then

        CURRENT_THEME=$($GET_THEME_SCRIPT)

        # Skip if the theme hasn't actually changed
        if [ "$CURRENT_THEME" = "$LAST_THEME" ]; then
            continue
        fi

        # Update state
        LAST_THEME="$CURRENT_THEME"

        # Log the event
        logger -t watch_theme "System theme changed. New state: $CURRENT_THEME"

        # Trigger updates
        update_gemini_config "$CURRENT_THEME"
    fi
done
