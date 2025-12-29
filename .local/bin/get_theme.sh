#!/bin/bash
set -eu

# Get the value (e.g., 'prefer-dark', 'default', 'prefer-light')
theme=$(gsettings get org.gnome.desktop.interface color-scheme)

# Remove single quotes using bash parameter expansion
theme=${theme//\'}

# Check if the string ends in "-dark"
if [[ "$theme" == *"-dark" ]]; then
    echo "dark"
else
    echo "light"
fi