#!/bin/bash

echo ""
echo -e "Status"
git status

echo "-----------------------------------------------------------------------------------"
read -p "Press enter to git add and git commit with the supplied message or ctrl-c to cancel"

echo ""
echo -e "Adding changes"
git ls-files --others --exclude-standard | xargs git add
git add -p

echo
echo -e "Creating commit - ($JENKINS_MESSAGE)"

git commit --allow-empty -m "$1"

echo "---------------------------------------"
read -p "Press enter to push or ctrl-c to cancel"

echo ""
echo -e "Pushing"
git push
