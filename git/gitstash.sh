#!/bin/bash

if [[ "$1" == "" ]]
then
  echo "Missing message"
  exit 1
fi

git stash save -u "$1"
