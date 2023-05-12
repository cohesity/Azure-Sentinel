#!/bin/zsh

# Description: This script executes a series of sub-scripts to assign the Microsoft Sentinel Contributor
# role, configure permissions, and grant Key Vault permissions to a client in the specified workspace.

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

. ./assign_sentinel_playbook_operator_role.sh
error_handler "Failed to execute assign_sentinel_playbook_operator_role.sh."

. ./configure_permissions.sh
error_handler "Failed to execute configure_permissions.sh."

. ./grant_keyvault_permission.sh
error_handler "Failed to execute grant_keyvault_permission.sh."

cd -
