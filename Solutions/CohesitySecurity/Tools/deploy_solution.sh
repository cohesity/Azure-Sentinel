#!/bin/zsh
set -e

# Description: This script deploys Azure Function Apps and Playbooks to a specified resource group.

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

. ./deploy_fuction_apps.sh

. ./deploy_playbooks.sh

cd -
