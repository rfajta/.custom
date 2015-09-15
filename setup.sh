#!/bin/bash -u -e -p

usage() {
	cat >&2 <<- EOF
Usage:
  $(basename ${0}) [-f]

  -f   force linking with confirmation if the target file already exists
EOF
exit $1
}

######## put your functions here

setup_profile() {
echo ". ${HOME}/.custom/environment/prompt.sh
. ${HOME}/.custom/environment/aliases.sh
. ${HOME}/.custom/environment/commands.sh
. ${HOME}/.custom/bin/mvncolor.sh" >> ~/.bash_profile 
}

safe_link() {
	existingFile="$1"
	linkName="$2"

	if [[ ! -e "${linkName}" ]]
	then
		echo "Linking ${linkName} -> ${existingFile}"
		# ln -s "${existingFile}" "${linkName}"
	else
		if [[ "${FORCE_LINKING}" == "true" ]]
		then
			read -p "${linkName} already exists, are you sure to remove and link it to ${existingFile} [y/n]?" -n 1 -r
			echo
			if [[ $REPLY =~ ^[y]$ ]]
			then
				echo "Removing ${linkName} and linking to ${existingFile}"
				# rm -rf "${linkName}"
				# ln -s "${existingFile}" "${linkName}"
			fi
		else
			echo "${linkName} already exists, not touching it"
		fi
	fi
}

setup_bin() {
	fromDir="$1"
	for f in ${fromDir}
	do
		fileName="${HOME}/bin/$(basename "${f}")"
		safe_link "${f}" "${fileName}"
	done
}

main() {
	checkParams "$@"
	# trap 'cleanup "${SOME_PARAM}"' EXIT SIGINT SIGKILL SIGTERM SIGSTOP SIGABRT

	# setup_profile
	setup_bin "${HOME}/.custom/bin/*"
	setup_bin "${HOME}/.custom/git/*"

	safe_link "${HOME}/.custom/.gitconfig" "${HOME}/.gitconfig"
	safe_link "${HOME}/.custom/.emacs" "${HOME}/.emacs"

}

# cleanup() {
# ######## do cleanup here	
# }


log() {
	echo "{$@}"
}

error() {
	echo "$@" >&2
}

FORCE_LINKING="false"
checkParams() {
	# :x expects a value for -x
	# h expects no value for -h
	while getopts "fh" optname
  	do
    	case "$optname" in
    		"h")
				usage
			;;
			"f")
				FORCE_LINKING="true"
			;;
			*)
				error "Unknown argument ${OPTARG}"
				usage 1
			;;
		esac
	done
}

main "$@"