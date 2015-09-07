#!/bin/bash


comp() {
  ceFile="$(echo "common/coreengine/$1" | sed -e "s/\/\.\//\//g ; s/\/\//\//g")" 
  coreFile=
}

cd common/coreengine
allFiles=$(find . -tye f)
cd -
for ceFile in $allFiles
do
  comp "$ceFile" "common/core"
  comp "$ceFile" "common/render"
done