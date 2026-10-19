#!/bin/sh
sensors | awk '/edge:/ { print $2 }'
