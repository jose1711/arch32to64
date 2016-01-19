#!/usr/bin/bash
# traverse whole fs tree looking for any 32bit binary that is not tracked by pacman.
# this may help to reveal software installed using its own install method that may
# be subject to backup prior to migration to 64bit version of arch 
#
# this tends to locate:
#  * old kernel modules
#  * binaries installed as an addons through application interface
#  * core files
#  * games installed via steam

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
find / -regextype posix-extended -regex "${regex}" -prune -o -type f -print0 | xargs -0 file '{}' | awk -F: '/32-bit/{print $1}' | sort >${all_files}

join -v 2 ${pacman_files} ${all_files}
