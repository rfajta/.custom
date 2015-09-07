#!/bin/bash

switch=$1
shift
files="$(~/bin/gitls.sh -1 $switch $@)"
#echo "FILES: [$files]"

git add $files
