#!/bin/zsh

# Description: This script deploys Azure Function Apps and Playbooks to a specified resource group.

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

. ./deploy_fuction_apps.sh
error_handler "Failed to deploy Function Apps."

. ./deploy_playbooks.sh
error_handler "Failed to deploy Playbooks."

cd -
