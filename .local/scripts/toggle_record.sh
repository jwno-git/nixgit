#!/usr/bin/env bash

# Configuration
RECORDINGS_DIR="$HOME"
PIDFILE="/tmp/wf-recorder.pid"

# Check if wf-recorder is already running
if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    # Stop recording
    kill "$(cat "$PIDFILE")"
    rm -f "$PIDFILE"
    
    # Send notification
    dunstify "Recording Stopped"
    
else
    # Start recording
    # Use slurp to select area
    GEOMETRY=$(slurp)
    
    # Exit if user cancelled slurp (ESC key)
    if [[ -z "$GEOMETRY" ]]; then
        exit 0
    fi
    
    # Generate filename with timestamp
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    FILENAME="$RECORDINGS_DIR/recording_$TIMESTAMP.mp4"
    
    # Start wf-recorder in background and save PID
    wf-recorder -g "$GEOMETRY" -f "$FILENAME" &
    echo $! > "$PIDFILE"
fi
