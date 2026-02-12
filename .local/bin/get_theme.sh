#!/bin/bash
set -euo pipefail

# Get the value (e.g., 'prefer-dark', 'default', 'prefer-light')
# Fallback to empty string if gsettings fails
theme=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || echo "'default'")

# Remove single quotes using bash parameter expansion
theme=${theme//\'}

# Check if the string ends in "-dark" or is specifically "prefer-dark"
if [[ "$theme" == *"-dark" ]] || [[ "$theme" == "dark" ]]; then
    echo "dark"
else
    echo "light"
fi
