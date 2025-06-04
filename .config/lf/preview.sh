#!/bin/bash

file="$1"
extension="${file##*.}"

case "$extension" in
    jpg|jpeg|png|gif)
        chafa --format=ansi --symbols=block --fill=solid "$file"
        ;;
    pdf)
        pdftotext "$file" -
        ;;
    *)
        # If it's not an image or pdf, just cat it
        if [ -f "$file" ]; then
            cat "$file"
        else
            file "$file"
        fi
        ;;
esac

