#!/bin/bash -e

branchName="$(git rev-parse --abbrev-ref HEAD)"; 
if [[ "$branchName" != "master" ]] 
then
  echo "${FG_GREEN}  Updating ${FG_LIGHT_GREEN}master${NO_COLOR}"
  git fetch origin master:master
  echo "${FG_GREEN}  Rebasing ${FG_LIGHT_GREEN}$branchName${FG_GREEN} to ${FG_LIGHT_GREEN}master${NO_COLOR}"
  git rebase master
  echo "${FG_GREEN}  Rebasing done${NO_COLOR}"
fi