#!/usr/bin/env bash

LOW=15
CRITICAL=7
STATE="$HOME/.cache/battery-monitor.state"

BATTERY=$(acpi -b | grep -P -o '[0-9]+(?=%)')
STATUS=$(acpi -b | grep -o "Discharging")

[[ -f "$STATE" ]] || echo "ok" > "$STATE"
LAST=$(cat "$STATE")

if [[ -n "$STATUS" ]]; then
    if (( BATTERY <= CRITICAL )) && [[ "$LAST" != "critical" ]]; then
        notify-send -u critical "Battery Critical" "Battery at ${BATTERY}%"
        echo "critical" > "$STATE"

    elif (( BATTERY <= LOW )) && [[ "$LAST" != "low" ]]; then
        notify-send -u normal "Battery Low" "Battery at ${BATTERY}%"
        echo "low" > "$STATE"

    elif (( BATTERY > LOW )) && [[ "$LAST" != "ok" ]]; then
        echo "ok" > "$STATE"
    fi
fi

