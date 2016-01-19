#!/usr/bin/bash
# this is a quick check for packages installed from aur and missing x86_64 (or any) field
# while also searching for possible replacements with a slightly changed name
findstr='64$|^lib32|^bin32'
pacman -Qq | while read -r pkg
	do
	curl -s "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=${pkg}" | grep 'arch=(' | sed 's/any/x86_64/' | grep -qv 'x86_64'
	if [ $? -eq 0 ]
		then
		echo -n "$pkg is missing x86_64 in arch field on aur (possible candidates: $(cower -s $pkg --format "%n\n" | grep -E "${findstr}"| tr '\n' ' ')"
		# maybe there is pkgname64 instead of pkgname32
		echo "${pkg}" | grep -q 32
		if [ $? -eq 0 ]
			then
			cower -s "${pkg/32/64}" --format "%n)\n"
			else
			echo ")"
			fi
		fi
	done
