#!/bin/zsh
set -e

# Description: This script creates a new resource group, Log Analytics workspace, and onboards the workspace to Azure Sentinel.

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

# Validate input variables
if [[ -z "$resource_group" ]]; then
    echo "Error: Resource Group is not set. Please set the 'resource_group' variable."
    exit 1
fi

if [[ -z "$workspace_name" ]]; then
    echo "Error: Workspace Name is not set. Please set the 'workspace_name' variable."
    exit 1
fi

if [[ -z "$location" ]]; then
    echo "Error: Location is not set. Please set the 'location' variable."
    exit 1
fi

# Create a new resource group
echo "Creating a new resource group..."
echo "resource_group --> $resource_group"
echo "workspace_name --> $workspace_name"
echo "location --> $location"
az group create --name $resource_group \
    --location $location

# Create a Log Analytics workspace within the resource group
echo "Creating a new Log Analytics workspace..."
az monitor log-analytics workspace create --resource-group $resource_group \
    --workspace-name $workspace_name \
    --location $location

# Onboard the workspace to Azure Sentinel
echo "Onboarding the workspace to Azure Sentinel..."
az sentinel onboarding-state create \
    --n default \
    --customer-managed-key false \
    --resource-group $resource_group \
    --workspace-name $workspace_name

echo "Azure Sentinel resource group created successfully!"

cd -
