#!/bin/bash
usage() {
	cat >&2 <<- EOF
		Lists the git files in change.

		Usage:
		  $(basename $0) [-s <number_or_range_list> ] [-m <number_or_range_list> ] [-u <number_or_range_list> ] [-a <number_or_range_list> ] [-1]

		Arguments:
		  -s - "Changes to be committed"
		  -m - "Changes not staged for commit"
		  -u - "Unmerged path"
		  -a - all changes in the above order combined
		  -1 - one file per line, otherwise all files are quoted and separated with a space
		  <number_or_range_list> - number of file to show from the given category
		                           may be a range as a..b, a.. or ..b

		Examples:
		  $(basename $0) -s 1..2 4 7 -m 1 2 -u
		  $(basename $0) -1 -a 1..2 4..
	EOF
	exit $1
}


getGitDir() {
local dir="${PWD}"

while [ "${dir}" != "/" ]
do
  if [ -d "${dir}/.git" ]
  then
    echo "${dir}"
    break
  fi
  dir=`dirname "${dir}"`
done
}

filesToBeCommitted() {
	gitDir="$1"
	# list files to be	 committed - s
	git diff HEAD --name-only --cached -- "$gitDir"
}

filesModified() {
	gitDir="$1"
	# list modified files - m
	git ls-files --modified --exclude-standard -- "$gitDir"
}

filesUnmerged() {
	gitDir="$1"
	# list unmerged files - u
	git ls-files --unmerged --exclude-standard -- "$gitDir"
}

filesAll() {
	gitDir="$1"
	filesToBeCommitted "$gitDir"
	filesModified "$gitDir"
	filesUnmerged "$gitDir"
}

invokeCommandAndFilter() {
	local command="$1"
	local params="$2"
	if [[ -n "$command" ]]
	then
		local allFiles="$(eval "$command $gitDir")"
		# log "$allFiles"
		if [[ -n "$params" ]]
		then
			for s in $params
			do
				echo "$allFiles" | sed -n "$s""p"
			done
		else
			echo "$allFiles" | grep -v "^$"
		fi
	fi
}

log() {
	echo "{$@}"
}

main() {
	gitDir="$(getGitDir)"
	local command=""
	local params="$gitDir"
	local onePerLine=""
	if [ "$#" == "0" ]
	then
		usage 1
	fi

	local fileList=""
	local maxFileNum=$(invokeCommandAndFilter "filesAll" "$gitDir" | wc -l)

	while (( "$#" ))
	do
		case "$1" in
			-a)
				fileList="$fileList""$(invokeCommandAndFilter "$command" "$params")
"
				command="filesAll"
				params=""
			;;
			-s)
				fileList="$fileList""$(invokeCommandAndFilter "$command" "$params")
"
				command="filesToBeCommitted"
				params=""
			;;
			-m)
				fileList="$fileList""$(invokeCommandAndFilter "$command" "$params")
"
				command="filesModified"
				params=""
			;;
			-u)
				fileList="$fileList""$(invokeCommandAndFilter "$command" "$params")
"
				command="filesUnmerged"
				params=""
			;;
			-1)
				onePerLine="yes"
			;;
			*)
				if [[ "$1" =~ ^[0-9][0-9]*$ ]]
				then
					# it is a number
					params="$params ""$1"
				elif [[ "$1" =~ ^([0-9][0-9]*)\.\.([0-9][0-9]*)$ ]]
				then
					# it is a..b
					params="$params ""$(seq ${BASH_REMATCH[1]} ${BASH_REMATCH[2]})"
				elif [[ "$1" =~ ^([0-9][0-9]*)\.\.$ ]]
				then
					# it is a..
					params="$params ""$(seq ${BASH_REMATCH[1]} $maxFileNum)"
				elif [[ "$1" =~ ^\.\.([0-9][0-9]*)$ ]]
				then
					# it is ..b
					params="$params ""$(seq 1 ${BASH_REMATCH[1]})"
				else
					usage 1
				fi
			;;
		esac
		shift
	done
	fileList="$fileList""$(invokeCommandAndFilter "$command" "$params")
"

	# log "$fileList"
	# print files one per line unquoted, or single line quoted separated with a space
	if [[ $onePerLine ]]
	then
		echo "$fileList" | grep -v "^$" | uniq
	else
		# log "$fileList"
		fileList="$(echo -n "$fileList" | grep -v "^$" | uniq | sed -e "s/^.*$/ \"&\"/" | tr -d "\n")"
		echo "${fileList:1}" | grep -v "^$"
	fi
}

main "$@"
