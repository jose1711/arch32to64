#!/usr/bin/bash
# not a real script - only compares the current hash of all installed 
# packages with the hash at install time.
# can detect changed config files, fixed scripts etc worth backing up.

which check-pacman-mtree.lua &>/dev/null || {
	echo "install check-pacman-mtree.lua from aur"
	exit 1
	}

sudo check-pacman-mtree.lua -a | grep DIFF
