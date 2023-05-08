#!/bin/zsh

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

. ./deploy_fuction_apps.sh
error_handler "Failed to deploy Function Apps."

. ./deploy_playbooks.sh
error_handler "Failed to deploy Playbooks."

cd -
