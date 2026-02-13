#!/bin/bash
set -euo pipefail

# Try to get the theme via XDG Desktop Portal (busctl)
# 1 = prefer-dark, 2 = prefer-light, 0 = no-preference
get_theme_portal() {
    local val
    val=$(busctl --user call org.freedesktop.portal.Desktop \
                   /org/freedesktop/portal/desktop \
                   org.freedesktop.portal.Settings \
                   Read ss "org.freedesktop.appearance" "color-scheme" 2>/dev/null | awk '{print $NF}' || echo "0")

    if [[ "$val" == "1" ]]; then
        echo "dark"
    elif [[ "$val" == "2" ]]; then
        echo "light"
    else
        return 1
    fi
}

# Fallback to gsettings (GNOME specific)
get_theme_gsettings() {
    local theme
    theme=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || echo "'default'")
    theme=${theme//\'}

    if [[ "$theme" == *"-dark" ]] || [[ "$theme" == "dark" ]]; then
        echo "dark"
    else
        echo "light"
    fi
}

# Main logic
if ! theme=$(get_theme_portal); then
    theme=$(get_theme_gsettings)
fi

echo "$theme"
