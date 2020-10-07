#!/bin/bash -e

commitMessage="$(git log -1 --pretty=%B)"

if [[ "$commitMessage" =~ "[skip ci]" ]]
then
  newCommitMessage="$(echo "${commitMessage//\[skip ci\]/}" | sed -e "s/^[[:space:]]*// ; s/[[:space:]]*$//")"
  git commit --amend -m "$newCommitMessage"
  # echo "[$newCommitMessage]"
else
  newCommitMessage="[skip ci] $commitMessage"
  git commit --amend -m "$newCommitMessage"
  # echo "[$newCommitMessage]"
fi
