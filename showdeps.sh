#!/usr/bin/bash
# this is used inside sandboxed environment
cd /home
mksrcinfo -o /dev/stdout | sed 's/ = /=/' | grep arch=
mksrcinfo -o /dev/stdout | sed 's/ = /=/' | tr -d '\t' | grep -E '^depends=|^depends_x86_64' | awk -F= '{print $2}' | sed 's/[<>].*//' | sort -u
