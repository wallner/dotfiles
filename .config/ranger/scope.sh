#!/bin/bash
# Wrapper script to use pistol within ranger

FILE_PATH="$1"
PV_WIDTH="$2"
PV_HEIGHT="$3"
IMAGE_CACHE_PATH="$4"
PV_COMMAND_LINE="$5"

# Export dimensions for pistol
export PistolWidth="$PV_WIDTH"
export PistolHeight="$PV_HEIGHT"

# Call pistol
pistol "$FILE_PATH"
