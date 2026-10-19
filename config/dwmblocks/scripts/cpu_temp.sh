#!/bin/sh
sensors | awk '/Tctl:/ { print " " $2 }'
