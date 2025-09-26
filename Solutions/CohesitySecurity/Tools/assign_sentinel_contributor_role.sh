#!/bin/zsh
set -e

# Description: This script assigns the "Microsoft Sentinel Contributor" role to a client in the specified workspace.

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

ROLE="Microsoft Sentinel Contributor"

# Validate input variables
if [[ -z "$subscription_id" ]]; then
    echo "Error: Subscription ID is not set. Please set the 'subscription_id' variable."
    exit 1
fi

if [[ -z "$resource_group" ]]; then
    echo "Error: Resource Group is not set. Please set the 'resource_group' variable."
    exit 1
fi

if [[ -z "$workspace_name" ]]; then
    echo "Error: Workspace Name is not set. Please set the 'workspace_name' variable."
    exit 1
fi

# Get the object ID
object_id=$(. ./get_service_principal_id.sh)

# Set the subscription context
az account set --subscription "$subscription_id"

# Get the workspace scope
SCOPE=$(az monitor log-analytics workspace show --resource-group "$resource_group" --workspace-name "$workspace_name" --query 'id' -o tsv)

# Assign the role to the client
az role assignment create --assignee-object-id "$object_id" --role "$ROLE" --scope "$SCOPE"

# Print the result
echo "Role '$ROLE' has been granted to the client with object ID '$object_id' in the workspace '$workspace_name'"

cd -
