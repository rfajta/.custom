#!/bin/bash -u

git config --global color.ui always
allLines="$(git status)"
git config --global color.ui true

oldIfs="$IFS"
IFS="
"
globalCounter=1
localCounter=1
for line in $allLines
do
	if [[ "$line" =~ \	 ]]
	then
	# echo "XXX $line XXX"
		paddedGlobalCounter="$(printf "%3d" $globalCounter)"
		paddedLocalCounter="$(printf "%3d" $localCounter)"
		# echo "$paddedLocalCounter $paddedGlobalCounter"
		echo "$line" | sed -e "{s/^	/ $paddedGlobalCounter $paddedLocalCounter / ; s/.*/& $localCounter/ ;}"
		(( globalCounter++ ))
		(( localCounter++ ))
	else
		localCounter=1
		echo "$line"
	fi
done
IFS="$oldIfs"

