#!/bin/zsh

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

# Description: This script creates a new resource group, Log Analytics workspace, and onboards the workspace to Azure Sentinel.

# Create a new resource group
echo "Creating a new resource group..."
echo "resource_group --> $resource_group"
echo "workspace_name --> $workspace_name"
echo "location --> $location"
az group create --name $resource_group \
    --location $location
error_handler "Failed to create the resource group."

# Create a Log Analytics workspace within the resource group
echo "Creating a new Log Analytics workspace..."
az monitor log-analytics workspace create --resource-group $resource_group \
    --workspace-name $workspace_name \
    --location $location
error_handler "Failed to create the Log Analytics workspace."

# Onboard the workspace to Azure Sentinel
echo "Onboarding the workspace to Azure Sentinel..."
az sentinel onboarding-state create \
    --n default \
    --customer-managed-key false \
    --resource-group $resource_group \
    --workspace-name $workspace_name
error_handler "Failed to onboard the workspace to Azure Sentinel."

echo "Azure Sentinel resource group created successfully!"

cd -
