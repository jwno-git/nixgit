#!/usr/bin/env bash

# Change the volume
wpctl set-volume @DEFAULT_AUDIO_SINK@ "$1"

# Get the new volume
VOLUME=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%.0f%%", $2 * 100}')

# Send a notification
dunstify -r 91190 -u low "Volume: $VOLUME"

