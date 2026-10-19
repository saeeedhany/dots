#!/bin/sh

command -v nvidia-smi >/dev/null || { echo N/A; exit 0; }

nvidia-smi \
  --query-gpu=memory.used,memory.total \
  --format=csv,noheader,nounits 2>/dev/null \
| awk -F',' '{printf "%d/%dMB\n",$1,$2}'
