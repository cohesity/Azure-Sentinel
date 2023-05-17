#!/bin/zsh

# Description: This script deploys Azure Sentinel resources to a specified resource group using a template file
# and provided parameters.

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

#. ./json_parser.sh

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
error_handler "Failed to deploy the Azure Sentinel resources."

cd -
