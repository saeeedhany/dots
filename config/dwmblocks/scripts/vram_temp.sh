#!/bin/sh

command -v nvidia-smi >/dev/null || { echo N/A; exit 0; }

temp=$(nvidia-smi \
  --query-gpu=temperature.gpu \
  --format=csv,noheader,nounits 2>/dev/null)

[ -n "$temp" ] && echo "${temp}°C" || echo "N/A"
