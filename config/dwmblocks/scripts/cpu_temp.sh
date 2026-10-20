#!/bin/sh
sensors | awk '/Tctl:/ { gsub(/\+/, "", $2); sub(/\.[0-9]+/, "", $2); print $2 }'
