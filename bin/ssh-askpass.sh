#!/bin/bash
if [[ "$1" == "Confirm user presence"* ]]; then
    echo
else
    PROMPT=$(echo "$1" | sed 's/"/\\"/g')
    PIN=$(osascript -e "text returned of (display dialog \"$PROMPT\" default answer \"\" with hidden answer with title \"SSH Key PIN\")" 2>/dev/null)
    echo "$PIN"
fi
