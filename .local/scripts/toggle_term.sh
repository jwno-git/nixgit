#!/usr/bin/env bash

TERMINAL_BIN="foot"
SPECIAL="special:terminal"
CLASS_NAME="foot"

# Get all foot clients
CLIENTS=$(hyprctl clients -j | jq -r --arg class "$CLASS_NAME" '.[] | select(.initialClass == $class)')

# If not running, launch and wait
if [[ -z "$CLIENTS" ]]; then
    $TERMINAL_BIN &
    
    # Wait for window to appear
    for i in {1..30}; do
        sleep 0.1
        CLIENTS=$(hyprctl clients -j | jq -r --arg class "$CLASS_NAME" '.[] | select(.initialClass == $class)')
        [[ -n "$CLIENTS" ]] && break
    done
    exit 0
fi

# First, check if any terminal is in special workspace
while IFS= read -r client; do
    [[ -z "$client" ]] && continue
    
    ADDRESS=$(echo "$client" | jq -r '.address')
    WORKSPACE=$(echo "$client" | jq -r '.workspace.name')
    
    if [[ "$WORKSPACE" == "$SPECIAL" ]]; then
        # Found one in special workspace, bring it back
        ACTIVE_WS=$(hyprctl activeworkspace -j | jq -r '.name')
        hyprctl dispatch movetoworkspace "$ACTIVE_WS,address:$ADDRESS"
        hyprctl dispatch focuswindow "address:$ADDRESS"
        exit 0
    fi
done <<< "$(echo "$CLIENTS" | jq -c '.')"

# No terminals in special workspace, hide the first visible one
while IFS= read -r client; do
    [[ -z "$client" ]] && continue
    
    ADDRESS=$(echo "$client" | jq -r '.address')
    WORKSPACE=$(echo "$client" | jq -r '.workspace.name')
    
    # Skip if already in special workspace
    [[ "$WORKSPACE" == "$SPECIAL" ]] && continue
    
    # Hide this terminal
    hyprctl dispatch movetoworkspacesilent "$SPECIAL,address:$ADDRESS"
    exit 0
done <<< "$(echo "$CLIENTS" | jq -c '.')"
