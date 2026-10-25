#!/bin/sh
for h in "${HWMON:-/sys/class/hwmon}"/hwmon*; do
	read -r name 2>/dev/null < "$h/name" || continue
	case "$name" in
	k10temp|coretemp)
		read -r t < "$h/temp1_input" && echo "$((t / 1000))°C"
		exit 0
		;;
	esac
done
