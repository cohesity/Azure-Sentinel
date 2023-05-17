#!/bin/zsh

# Description: This script first creates a Sentinel resource group using create_sentinel_resource_group.sh,
# then assigns the Sentinel Contributor role to the resource group using assign_sentinel_contributor_role.sh.

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

. ./create_sentinel_resource_group.sh
error_handler "Failed to create Sentinel resource group."

. ./assign_sentinel_contributor_role.sh
error_handler "Failed to grant role."

cd -
