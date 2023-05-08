#!/bin/zsh

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

. ./assign_sentinel_role.sh
error_handler "Failed to execute assign_sentinel_role.sh."

. ./configure_permissions.sh
error_handler "Failed to execute configure_permissions.sh."

. ./grant_keyvault_permission.sh
error_handler "Failed to execute grant_keyvault_permission.sh."

cd -
