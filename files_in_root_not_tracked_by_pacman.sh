#!/usr/bin/bash
# lists files not tracked by pacman in common system directories. this assumes:
#  * /home will going to be backed up and restored or left intact (if on a separate fs) - therefore we are skipping it
#  * user inspect contents of any of the skipped directories ($regex in common_funcs.sh) manually
export LC_ALL=C
pacman_files=$(mktemp)
all_files=$(mktemp)

scriptdir=$(dirname $(readlink -f $0))
echo "scriptdir is ${scriptdir}"
. ${scriptdir}/common_funcs.sh
root_needed

detect_steampath

pacman -Ql `pacman -Qq` | grep -v '/$' | cut -d' ' -f 2- >${pacman_files}
sort -o ${pacman_files} ${pacman_files}

echo "searching.. (the following dirs are skipped: ${regex}"
find / -regextype posix-extended -regex "${regex}" -prune -o -type f | sort >${all_files}

join -v 2 ${pacman_files} ${all_files}
