#!/bin/bash

targetBranchBase=$1
cherryPickTargetBranch=$2

git show-branch $targetBranchBase $cherryPickTargetBranch
git show-branch $targetBranchBase $cherryPickTargetBranch &> /dev/null
if [[ $? -eq 128 ]]; then
  echo "Usage: $0 [base branch name] [target branch name] [skips from bottom] [number of target commits]"
  exit 1
fi

commits=($(git show-branch $targetBranchBase $cherryPickTargetBranch | awk '/ \+/' | cut -d '[' -f2 | cut -d ']' -f1))
reversed=()

index=(${#commits[@]}-1) # bash
# index=(${#commits[@]}) # zsh
while [[ index -gt -1 ]]; do # bash
# while [[ index -gt 0 ]]; do # zsh
  reversed+=(${commits[$index]})
  (( index-- ))
done

if [ $# -ne 4 ]; then
  echo "Usage: $0 [base branch name] [target branch name] [skips from bottom] [number of target commits]"
  exit 1
fi

commitIndex=0; # bash
# commitIndex=1; # zsh
skip=$3
commitIndex=$(($commitIndex+$skip))
countToAdd=$4

if [ $countToAdd -gt ${#reversed[@]} ]; then
  echo "asdf"
  exit 1
fi

red='\033[0;36m'
noColor='\033[0m'
proceed=1
total=$countToAdd
while [[ $countToAdd -ne 0 ]]; do
  echo -e "Running ${red}\"git cherry-pick ${reversed[$commitIndex]} -X theirs\"${noColor}... ($proceed/$total)"
  git cherry-pick ${reversed[$commitIndex]} -X theirs
  (( countToAdd--, commitIndex++, proceed++ ))
done
