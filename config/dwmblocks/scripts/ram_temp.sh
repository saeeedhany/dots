#!/bin/sh

temps=$(sensors | awk '
/spd5118/ {f=1}
f && /temp1:/ {gsub(/\+/,"",$2); print $2}
')

if [ -n "$temps" ]; then
    echo "$temps" | awk '
    {sum+=$1; n++}
    END {printf "%.1f°C\n", sum/n}
    '
else
    echo "N/A"
fi
