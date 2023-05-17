#!/bin/zsh
set -e

# Description: This script deploys Azure Sentinel resources to a specified resource group using a template file
# and provided parameters.

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

# Validate input variables
if [[ -z "$resource_group" ]]; then
    echo "Error: Resource Group is not set. Please set the 'resource_group' variable."
    exit 1
fi

if [[ -z "$api_key" ]]; then
    echo "Error: API Key is not set. Please set the 'api_key' variable."
    exit 1
fi

if [[ -z "$client_id" ]]; then
    echo "Error: Client ID is not set. Please set the 'client_id' variable."
    exit 1
fi

if [[ -z "$client_key" ]]; then
    echo "Error: Client Key is not set. Please set the 'client_key' variable."
    exit 1
fi

if [[ -z "$workspace_name" ]]; then
    echo "Error: Workspace Name is not set. Please set the 'workspace_name' variable."
    exit 1
fi

# Deploy the Azure Sentinel resources
az deployment group create \
    --name ExampleDeployment \
    --resource-group "$resource_group" \
    --template-file ../Data\ Connectors/Helios2Sentinel/azuredeploy.json \
    --parameters ApiKey="$api_key" \
    --parameters ClientId="$client_id" \
    --parameters ClientKey="$client_key" \
    --parameters StartDaysAgo="$start_days_ago" \
    --parameters Workspace="$workspace_name"

cd -
