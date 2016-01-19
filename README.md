# arch32to64
A set of scripts to help users of i686 (32bit) Arch Linux to migrate to x86_64 (64bit) architecture

## arch32to64.sh
Gives hints when migrating from a 32bit to a 64bit flavour of Arch Linux. Makes a list of packages with their dependencies and provides estimated storage requirements.

## files_in_root_not_tracked_by_pacman.sh
Lists files in non-home directories unknown to pacman (missing from /var/lib/pacman/local).

## list_files_installed_using_pacman_with_changed_hash.sh
Compares the current hash of all installed packages with their hash at install time.

## list_possible_replacement_for_aur_pkgbuild_without_an_64bit_arch_field.sh
Runs a quick check for packages installed from AUR listing PKGBUILDs with x86_64 field missing and showing possible replacement with similar name (e. g. bin32-${origpkgname}).

## show_arch_of_aur_pkgbuilds_of_maintainer.sh
Is any of your (friend's) pkgbuild(s) in aur missing an x86_64 architecture field?

## 32bit_binaries_not_tracked_by_pacman.sh
Same as files_in_root_not_tracked_by_pacman.sh but only checking 32bit binaries and libs.
