#!/bin/zsh

# Description: This script creates a new resource group, Log Analytics workspace, and onboards the workspace to Azure Sentinel.

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

# Check if the Azure Sentinel resource group was created successfully
if [ $? -eq 0 ]; then
    echo "Azure Sentinel resource group created successfully!"
else
    echo "Error occurred while creating Azure Sentinel resource group. Please check the error messages above."
    exit 1
fi
