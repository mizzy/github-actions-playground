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
    if [ ! -d $dir ]; then
        continue
    fi
    cd $dir
    terraform init
    if [ "$1" = "fmt" ]; then
        terraform fmt -check -diff | tfnotify --config ../../.tfnotify.github.yml fmt -t "## ${dir}"
    elif [ "$1" = "plan" ]; then
        terraform plan -refresh=false | tfnotify --config ../../.tfnotify.github.yml plan -t "## ${dir}"
    elif [ "$1" = "apply" ]; then
        terraform apply -auto-approve -no-color | tfnotify --config ../../.tfnotify.slack.yml apply -t "${GITHUB_REPOSITORY}/${dir}"
    fi
done
