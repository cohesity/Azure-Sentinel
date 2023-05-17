#!/bin/zsh

# Description: This script assigns the "Microsoft Sentinel Contributor" role to a client in the specified workspace.

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

ROLE="Microsoft Sentinel Contributor"

# Set the subscription context
az account set --subscription "$subscription_id"
error_handler "Failed to set the subscription context."

# Get the workspace scope
SCOPE=$(az monitor log-analytics workspace show --resource-group "$resource_group" --workspace-name "$workspace_name" --query 'id' -o tsv)
error_handler "Failed to get the workspace scope."

# Assign the role to the client
az role assignment create --assignee-object-id "$object_id" --role "$ROLE" --scope "$SCOPE"
error_handler "Failed to assign the role to the client."

# Print the result
echo "Role '$ROLE' has been granted to the client with object ID '$object_id' in the workspace '$workspace_name'"

cd -
