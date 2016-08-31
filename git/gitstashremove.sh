#!/bin/bash

if [[ "$1" == "" ]]
then
  echo "Missing stash number"
  exit 1
fi

git stash save -u "stash@{$1}"
