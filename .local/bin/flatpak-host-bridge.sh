#!/bin/bash
# Universal Flatpak to Host Bridge
# This script executes the command it was called as on the host system.

# Get the name of the command (e.g., 'python', 'uv', 'podman')
COMMAND=$(basename "$0")

# Use host-spawn to execute on the host
# fallback to flatpak-spawn --host if host-spawn is not found
if [ -x "/var/run/host/bin/host-spawn" ]; then
    exec /var/run/host/bin/host-spawn "$COMMAND" "$@"
else
    exec flatpak-spawn --host "$COMMAND" "$@"
fi
