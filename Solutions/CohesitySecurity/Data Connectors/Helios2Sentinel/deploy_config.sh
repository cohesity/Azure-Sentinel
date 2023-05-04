#!/bin/zsh
#
# Description: This script deploys and configures Azure Sentinel resources
# and permissions for the specified resource group, workspace, and other parameters.

# Source error handling script
. ./error_handling.sh

# Source necessary scripts
. ../../create_sentinel_resource_group.sh || error_handler
. ../../grant_role.sh || error_handler
./storage_account_delete.sh || error_handler

# Deploy the Azure Sentinel resources
az deployment group create \
    --name ExampleDeployment \
    --resource-group "$resource_group" \
    --template-file ./azuredeploy.json \
    --parameters ApiKey="$api_key" \
    --parameters ClientId="$client_id" \
    --parameters ClientKey="$client_key" \
    --parameters StartDaysAgo="$start_days_ago" \
    --parameters Workspace="$workspace_name" || error_handler

# Deploy playbooks, assign Sentinel role, and configure permissions
. ./deploy_playbooks.sh || error_handler
. ./assign_sentinel_role.sh || error_handler
. ./configure_permissions.sh || error_handler

# Grant Key Vault permissions
. ./grant_keyvault_permission.sh || error_handler
