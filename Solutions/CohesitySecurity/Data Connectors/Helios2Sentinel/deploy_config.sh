#!/bin/zsh
#
# Description: This script deploys and configures Azure Sentinel resources
# and permissions for the specified resource group, workspace, and other parameters.

# Source necessary scripts
. ../../create_sentinel_resource_group.sh
. ../../grant_role.sh
./storage_account_delete.sh

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

# Deploy playbooks, assign Sentinel role, and configure permissions
. ./deploy_playbooks.sh
. ./assign_sentinel_role.sh
. ./configure_permissions.sh

# Grant Key Vault permissions
. ./grant_keyvault_permission.sh
