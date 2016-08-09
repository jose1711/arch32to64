#!/usr/bin/bash
# set -x
# gives hints when migrating from a 32bit to a 64bit flavour of arch linux.
# useful when you'd like to change arch (after memory upgrade?) but want
# to keep as much packages (preferably all) as possible.
# runs dependency checks for all packages, including those in aur. to provide
# some level of protection a playpen sandbox is leveraged when inspecting
# pkgbuilds.
#
# at the end a storage estimation is calculated (guesstimated or omitted for
# aur packages)
#
# requirements:
#  packages installed:
#  - playpen (community)
#  - package-query (aur)
#  - 700 mb of free space (for sandbox)
#
#  sudo allowed to run:
#  - playpen
#  - pacman
#
# example session:
#  review prepare_sandbox.sh and change sandboxdir if desirable
#  run prepare_sandbox.sh
#  if you changed sandboxdir also reflect it in this file (sandboxdir var below)
#  save and run giving no parameters
#  pkgbuilds from aur will be processed (or more exactly interpreted by
#   shell) in a sandbox provided by playpen. this is safer then simply
#   trusting them all but not a 100% protection)
#  review all 3 output files
#  use package list (combined with aur-aware package manager) when going
#   from your once-32bit arch linux to 64-bit one
#
# tips:
#  i had to remove *mesa* packages before feeding the list to yaourt
#  what to do with ..
#   .. package not found:
#       investigate why it has disappeared from aur (maybe it's still in aur3?)
#       will you miss it? also, it may be a good idea to back them up using bacman
#       willing to recreate pkgbuild?
#   .. no matching architecture:
#       contact maintainer and ask if support for x86_64 can be added
#       find an equivalent with a different name (codecs vs codes64)
#  (before you actually switch to 64-bit) make a test in virtualbox/vmware
#
# caveats:
#  checks are not done in parallel thus runtime can be quite lengthy
#   (otoh we really do not want to be mean to a server hosting aur)
#  wasn't really tested much (only on my 2k installed packages) hence may contain some bugs
#  parsing may break on some exotic pkgbuilds
#  code is hard to read at times
#
# ideas/rants: jose1711 gmail com

sandboxdir=~/tmp.sandboxxx
reposconf=64bitrepos.conf

which playpen || {
	echo "please install playpen"
	exit 1
	}

if [ ! -d "${sandboxdir}" ]
then
	echo "sandbox directory ${sandboxdir} does not exist"
	exit 1
fi

pacmanddb=$(mktemp -d)
pkgmissing=$(mktemp)
archmissing=$(mktemp)
sudo pacman --config ${reposconf} -b ${pacmanddb} --arch x86_64 -Sy
export CARCH=x86_64

function report {
echo "$@" 1>&2
}

function resolve_pkglist {
local pkglist=$(mktemp)
for pkg
 do
 report -n "* checking $pkg.."
 pactree --config ${reposconf} -u -b ${pacmanddb} -s ${pkg} &>/dev/null
 if [ $? -ne 0 ]
        then
	report -n "NOT found in repos, searching in AUR.."
	unset arch pkgname depends url
	url=$(package-query -1Aif "%u" "${pkg}")
	if [ -z "${url}" ]
		then
			report "package $pkg not found"
			echo $pkg >>${pkgmissing}
			continue
		else
			curl -s "${url}" | bsdtar --strip-components 1 -Oxvf - './*/PKGBUILD' >${sandboxdir}/home/PKGBUILD
			unset depsfound
			depsfound=$(sudo playpen --devices /dev/null:w -u root -DpS whitelist -l -- ${sandboxdir} /home/showdeps.sh)
			echo -e "${depsfound}" | grep arch= | sed 's/any/x86_64/' | grep -q x86_64
			if [ $? -eq 0 ]
			then
				report "found in aur, storing dependencies"
				echo "$pkg" >>${pkglist}
				echo "$depsfound" | grep -v arch= >>${pkglist}
			else
				report "package found but no matching architecture"
				echo "$pkg" >>${archmissing}
				continue
			fi
	fi
	else
	report "found in repos"
	echo "$pkg" >>${pkglist}
 	pactree --config ${reposconf} -u -b ${pacmanddb} -s ${pkg} >>${pkglist}
 	fi
 done

pkglisttemp=$(mktemp)
sort -u ${pkglist} | sed 's/[<>=].*//' >${pkglisttemp}
mv ${pkglisttemp} ${pkglist}

echo ${pkglist}
}

# main()
pacman -Qq >/tmp/pkginput
pkgsinput="/dev/null"
pkgsoutput="/tmp/pkginput"

packages2download=$(mktemp)
>${packages2download}
until diff "$pkgsinput" "$pkgsoutput" &>/dev/null
	do
	echo "input is: ${pkgsinput}, output is ${pkgsoutput} (output will be ${packages2download})"
	pkgsinput=${pkgsoutput}
	tp=$(join -v 2 "${packages2download}" "${pkgsinput}")
	( cat ${packages2download}; sort -u "${pkgsoutput}"; ) >>${packages2download}
	echo "these packages will be processed now: "${tp}
	pkgsoutput=$(resolve_pkglist ${tp})
	sort -u -o ${packages2download} ${packages2download}
	sort -u -o ${pkgsoutput} ${pkgsoutput}
	done

echo "---------------------------------------------------------------------"
echo "list of packages to download is stored in $packages2download ($(cat ${packages2download} | wc -l))"
echo "packages to review:"
echo " - package not found ($(cat ${pkgmissing} | wc -l)): ${pkgmissing}"
echo " - no matching architecture ($(cat ${archmissing} | wc -l)): $archmissing"

echo "calculating minimum storage requirements.."
while read -r pkg
	do
	sudo pacman --print-format '%s' --config ${reposconf} -b ${pacmanddb} --arch x86_64 -Sddp ${pkg} 2>/dev/null
	if [ $? -ne 0 ]
		then
		# ok, so this is an aur package then - let's assume 64bit version will be same size as the currently installed
		# 32bit one
		sudo pacman --config /dev/null --print-format '%s' -Rddp ${pkg} 2>/dev/null
		fi
	done < ${packages2download} | awk '{a+=$0}END{printf "at least %d MB required for installed packages\n", a/1024/1024}'

unset CARCH
