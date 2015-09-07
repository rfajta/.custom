#!/bin/bash

columns=$(tput cols)

# modified="$(git status | grep -o "modified: .*" | cut -d " " -f 4)"
# files=""
# for seq in "$@"
# do
#     files="$files""$(echo "$modified" | sed "$seq""q;d")
# "
# done
switch=$1
shift
files="$(~/bin/gitls.sh -1 $switch $@)"
allFilesNum="$(echo "$files" | wc -l | tr -d " ")"

counter=1
staged=0
for file in $files
do
    fileWithCounter="[$counter/$allFilesNum] $file"
    textLength=${#fileWithCounter}
    length=$(( $columns - $textLength - 10 ))
    printf -v line '%*s' "$length"
    echo "${line// /-} ${fileWithCounter} --------"
    if [[ "$switch" == "-s" ]]
    then
    	# compare the files in the staged area
    	git --no-pager diff --cached -- "$file"
    elif [[ "$switch" == "-a" ]]
    then
    	# keep comparing the files in the staged area, until there are no more diffs there
    	if [[ $staged == 0 ]]
    	then
			git diff --cached --exit-code --quiet "$file"
			exitcode=$?
    		if [[ $exitcode != 0 ]]
    		then
	    		git --no-pager diff --cached -- "$file"
	    	else
	    		staged=1
	    	fi
	    fi
	    # then compare the rest
    	if [[ $staged != 0 ]]
    	then
	    	git --no-pager diff -- "$file"
    	fi
    else
    	# compare the non-staged files
    	git --no-pager diff -- "$file"
    fi
    ((counter++))
done

printf -v line '%*s' "$columns"
echo "${line// /-}"
