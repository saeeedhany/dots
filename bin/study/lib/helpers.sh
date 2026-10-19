#!/usr/bin/env bash

# Notification functions with fallback
notify() {
    local title="$1"
    local message="$2"
    
    # Check if notifications are globally enabled
    if [ "${ENABLE_NOTIFICATIONS:-true}" != true ]; then
        return 0
    fi
    
    # Try to send notification via notify-send
    if command -v "$NOTIFY_CMD" >/dev/null 2>&1; then
        "$NOTIFY_CMD" -u "$NOTIFY_LEVEL_INFO" "$title" "$message" 2>/dev/null || {
            # Fallback to echo if notification fails
            echo "[INFO] $title: $message"
        }
    else
        # No notification command available
        echo "[INFO] $title: $message"
    fi
}

notify_warn() {
    local title="$1"
    local message="$2"
    
    if [ "${ENABLE_NOTIFICATIONS:-true}" != true ]; then
        return 0
    fi
    
    if command -v "$NOTIFY_CMD" >/dev/null 2>&1; then
        "$NOTIFY_CMD" -u "$NOTIFY_LEVEL_WARN" "$title" "$message" 2>/dev/null || {
            echo "[WARNING] $title: $message"
        }
    else
        echo "[WARNING] $title: $message"
    fi
}

# Converts a duration string (e.g., "1h30m5s") into total seconds.
# Returns the number of seconds or empty string if invalid
parse_duration() {
    local s="$1"
    
    # Remove any whitespace
    s="${s// /}"
    
    # Validate input is not empty
    if [ -z "$s" ]; then
        return 1
    fi

    # h + m + s
    if [[ "$s" =~ ^([0-9]+)h([0-9]+)m([0-9]+)s$ ]]; then
        echo $(( ${BASH_REMATCH[1]}*3600 + ${BASH_REMATCH[2]}*60 + ${BASH_REMATCH[3]} ))
        return 0
    fi

    # h + m
    if [[ "$s" =~ ^([0-9]+)h([0-9]+)m$ ]]; then
        echo $(( ${BASH_REMATCH[1]}*3600 + ${BASH_REMATCH[2]}*60 ))
        return 0
    fi

    # h + s
    if [[ "$s" =~ ^([0-9]+)h([0-9]+)s$ ]]; then
        echo $(( ${BASH_REMATCH[1]}*3600 + ${BASH_REMATCH[2]} ))
        return 0
    fi

    # h only
    if [[ "$s" =~ ^([0-9]+)h$ ]]; then
        echo $(( ${BASH_REMATCH[1]}*3600 ))
        return 0
    fi

    # m + s
    if [[ "$s" =~ ^([0-9]+)m([0-9]+)s$ ]]; then
        echo $(( ${BASH_REMATCH[1]}*60 + ${BASH_REMATCH[2]} ))
        return 0
    fi

    # m only
    if [[ "$s" =~ ^([0-9]+)m$ ]]; then
        echo $(( ${BASH_REMATCH[1]}*60 ))
        return 0
    fi

    # s only
    if [[ "$s" =~ ^([0-9]+)s$ ]]; then
        echo "${BASH_REMATCH[1]}"
        return 0
    fi
    
    # No match - invalid format
    return 1
}

# Formats seconds back into a human-readable string (e.g., 1h30m5s).
format_duration() {
    local seconds="$1"
    local h=$((seconds / 3600))
    local m=$(((seconds % 3600) / 60))
    local s=$((seconds % 60))

    if [ "$h" -gt 0 ]; then
        if [ "$s" -gt 0 ]; then
            printf "%dh%dm%ds" "$h" "$m" "$s"
        else
            printf "%dh%dm" "$h" "$m"
        fi
    elif [ "$m" -gt 0 ]; then
        if [ "$s" -gt 0 ]; then
            printf "%dm%ds" "$m" "$s"
        else
            printf "%dm" "$m"
        fi
    else
        printf "%ds" "$s"
    fi
}

# Validate that focus mode commands are available
check_focus_mode() {
    if [ "${ENABLE_FOCUS_MODE:-false}" = true ]; then
        # Extract the actual command (first word) from the focus command strings
        local pause_cmd resume_cmd
        pause_cmd=$(echo "$FOCUS_CMD_PAUSE" | awk '{print $1}')
        resume_cmd=$(echo "$FOCUS_CMD_RESUME" | awk '{print $1}')
        
        if ! command -v "$pause_cmd" >/dev/null 2>&1; then
            echo "Warning: Focus mode enabled but '$pause_cmd' not found" >&2
            return 1
        fi
        
        if ! command -v "$resume_cmd" >/dev/null 2>&1; then
            echo "Warning: Focus mode enabled but '$resume_cmd' not found" >&2
            return 1
        fi
    fi
    return 0
}
