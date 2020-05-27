#!/bin/bash

set -u

run_terraform() {
    echo $1
}

CURRENT_BRANCH=`git rev-parse --abbrev-ref @`
TF_LOG='INFO'

if [ $CURRENT_BRANCH = "master" ]; then
  TARGET="HEAD^ HEAD"
else
  TARGET="origin/master"
fi

dirs=`git diff $TARGET --name-only | grep teams | xargs dirname | sort | uniq`

for dir in $dirs; do
    cd $dir
    if [ "$1" = "fmt" ]; then
        terraform fmt -check
    elif [ "$1" = "plan" ]; then
        terraform plan | tfnotify plan -t "## ${dir}"
    elif [ "$1" = "apply" ]; then
        terraform apply -auto-approve
    fi
done
