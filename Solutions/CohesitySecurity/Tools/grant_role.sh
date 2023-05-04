#!/bin/zsh

# Description: This script assigns the "Microsoft Sentinel Contributor" role to a client in the specified workspace.

ROLE="Microsoft Sentinel Contributor"

# Set the subscription context
az account set --subscription "$subscription_id"

# Get the workspace scope
SCOPE=$(az monitor log-analytics workspace show --resource-group "$resource_group" --workspace-name "$workspace_name" --query 'id' -o tsv)

# Assign the role to the client
az role assignment create --assignee-object-id "$object_id" --role "$ROLE" --scope "$SCOPE"

# Print the result
echo "Role '$ROLE' has been granted to the client with object ID '$object_id' in the workspace '$workspace_name'"
