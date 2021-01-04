#!/bin/bash -u

# 
# first param: is a date in format of yyyy-mm-dd and must be a Tuesday
# second param: occasions

DATE="$1"
OCCASIONS="$2"
INCREMENT=3

for (( i = 0 ; i < $(( OCCASIONS * 7)) ; )) ; do
	date +%Y-%m-%d -d "$DATE + $i day" | tr -d "\n"
	echo -n "		"
	if [[ $((i % 7)) == 0 ]] ; then
		i=$((i + 3))
	else
		i=$((i + 4))
    fi		

done
echo ""
