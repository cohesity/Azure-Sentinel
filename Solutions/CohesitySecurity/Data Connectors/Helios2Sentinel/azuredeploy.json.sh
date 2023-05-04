#!/bin/zsh
#
# Deploy the Azure Sentinel resources
az deployment group create \
    --name ExampleDeployment \
    --resource-group "$resource_group" \
    --template-file ./azuredeploy.json \
    --parameters ApiKey="$api_key" \
    --parameters ClientId="$client_id" \
    --parameters ClientKey="$client_key" \
    --parameters StartDaysAgo="$start_days_ago" \
    --parameters Workspace="$workspace_name"
