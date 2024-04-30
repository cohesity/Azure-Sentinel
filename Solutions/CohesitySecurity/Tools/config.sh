#!/bin/zsh
set -e

# Description: This script executes a series of sub-scripts to assign the Microsoft Sentinel Contributor
# role, configure permissions, and grant Key Vault permissions to a client in the specified workspace.

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

. ./assign_roles_and_permissions.sh
. ./assign_sentinel_automation_contributor_role.sh
. ./configure_servicenow_connection.sh
. ./update_azure_blob.sh

cd -
