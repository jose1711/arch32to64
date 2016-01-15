#!/usr/bin/bash
# prepares a sandbox environment
# either run this as root or make sure your sudo
# is configured to allow running the commands below
#
sandboxdir=~/tmp.sandboxxx
mkdir "${sandboxdir}"
sudo pacstrap -cd "${sandboxdir}"
sudo pacstrap -cd "${sandboxdir}" pkgbuild-introspection
sudo chmod 777 "${sandboxdir}/home"
cp showdeps.sh "${sandboxdir}/home"
chmod a+rx "${sandboxdir}/home/showdeps.sh"
