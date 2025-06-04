# toggle_notes.sh - Updated for NixOS standardnotes package
#!/usr/bin/env bash

TERMINAL_BIN="standardnotes"
SPECIAL="special:standardnotes"
CLASS_NAME="Standard Notes"

# Get client info
CLIENT=$(hyprctl clients -j | jq -r --arg class "$CLASS_NAME" '.[] | select(.initialClass == $class)')

# If not running, launch and wait
if [[ -z "$CLIENT" ]]; then
    $TERMINAL_BIN &
    
    # Wait for window to appear
    for i in {1..30}; do
        sleep 0.1
        CLIENT=$(hyprctl clients -j | jq -r --arg class "$CLASS_NAME" '.[] | select(.initialClass == $class)')
        [[ -n "$CLIENT" ]] && break
    done

    # Exit here so it stays on screen after launching
    exit 0
fi

# Get details
ADDRESS=$(echo "$CLIENT" | jq -r '.address')
WORKSPACE=$(echo "$CLIENT" | jq -r '.workspace.name')
ACTIVE_WS=$(hyprctl activeworkspace -j | jq -r '.name')

# Move to or from special workspace
if [[ "$WORKSPACE" == "$SPECIAL" ]]; then
    hyprctl dispatch movetoworkspace "$ACTIVE_WS,address:$ADDRESS"
    hyprctl dispatch focuswindow "address:$ADDRESS"
else
    hyprctl dispatch movetoworkspacesilent "$SPECIAL,address:$ADDRESS"
fi
