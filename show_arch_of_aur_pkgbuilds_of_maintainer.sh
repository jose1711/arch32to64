#!/bin/bash
# is any of your (friend's) pkgbuild(s) in aur missing an x86_64 architecture field?
if [ -z "$1" ]
	then
	echo "specify maintainer (you?) as the only parameter"
	exit 1
	fi

cower -m "$1" -b --format "%n\n" | while read -r pkg
	do
	printf "%-20.19s %s\n" $pkg "$(curl -s https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=${pkg} | grep 'arch=(')"
	done
