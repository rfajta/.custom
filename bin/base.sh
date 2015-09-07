#!/bin/bash -u -e -p

usage() {
	cat >&2 <<- EOF
######## change the usage description here
Usage:
  $(basename ${0}) ...
EOF
exit $1
}

######## put your functions here

main() {
	checkParams "$@"
	trap 'cleanup "${SOME_PARAM}"' EXIT SIGINT SIGKILL SIGTERM SIGSTOP SIGABRT
######## call your functions from here 
}

cleanup() {
######## do cleanup here	
}


log() {
	echo "{$@}"
}

error() {
	echo "$@" >&2
}

checkParams() {
	# :x expects a value for -x
	# h expects no value for -h
	while getopts ":xh" optname
  	do
    	case "$optname" in
    		"h")
				usage
			;;
			"x")
				X_ARG="${OPTARG}"
			;;
			*)
				error "Unknown argument ${OPTARG}"
				usage 1
			;;
		esac
	done
}

main "$@"