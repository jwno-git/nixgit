#!/usr/bin/env bash

CHOICE=$(wofi --dmenu --prompt -y 5 -x 1220 < ~/.config/wofi/ssh_hosts)

if [ -n "$CHOICE" ]; then
    foot --app-id=ssh --title="SSH: $CHOICE" sh -c "$CHOICE" &
    disown
fi
