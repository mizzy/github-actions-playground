#!/bin/bash

set -eux

run_terraform() {
    echo $1
}

git fetch origin master

CURRENT_BRANCH=`git rev-parse --abbrev-ref @`
TF_LOG='INFO'

if [ $CURRENT_BRANCH = "master" ]; then
  TARGET="HEAD^"
else
  TARGET="origin/master"
fi

dirs=`git diff $TARGET --name-only | grep teams | xargs dirname | sort | uniq`

for dir in $dirs; do
    cd $dir
    terraform init
    if [ "$1" = "fmt" ]; then
        terraform fmt -check -diff | tfnotify --config ../../.tfnotify.yml fmt
    elif [ "$1" = "plan" ]; then
        terraform plan -refresh=false | tfnotify --config ../../.tfnotify.yml plan
    elif [ "$1" = "apply" ]; then
        terraform apply -auto-approve
    fi
done
