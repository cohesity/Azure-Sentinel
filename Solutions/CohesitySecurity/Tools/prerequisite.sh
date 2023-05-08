#!/bin/zsh

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

. ./create_sentinel_resource_group.sh
error_handler "Failed to create Sentinel resource group."

. ./grant_role.sh
error_handler "Failed to grant role."

cd -
