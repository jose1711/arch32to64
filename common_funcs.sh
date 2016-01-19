#!/usr/bin/bash
function root_needed {
	if [ $(id -u) -ne 0 ]
		then
		echo "rerun as root, or as sudo $0"
		exit 1
		fi
}

function detect_steampath {
	steam_base_path=$(awk '/BaseInstallFolder/ {print $NF}' /home/*/.local/share/Steam/config/config.vdf 2>/dev/null | tr -d '"' | head -1)
	if [ ! -z "${steam_base_path}" ]
		then
		echo "detected the following steam path: ${steam_base_path}."
		echo "should it be added to the list of skipped folders? [y/n]"
		read answer
		if echo "${answer}" | grep -qi y
			then
			export regex=${regex}"|${steam_base_path}"
			fi
		fi
}

# directories excluded from scan
export regex="/(sys|home|media|mnt|run|srv|proc|var/cache|var/log|var/lib/pacman|var/lib/NetworkManager|opt/desura)|.*/\.ccache/.*"
