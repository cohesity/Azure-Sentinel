#!/bin/zsh
set -e

# Name: get_storage_account_key.sh
# Description: This script retrieves the access key of an Azure Storage Account in a specific resource group.

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"


# Validate input variables
if [[ -z "$resource_group" ]]; then
    echo "Error: Resource Group is not set. Please set the 'resource_group' variable."
    exit 1
fi

# Get the storage account name by resource group
storage_account_name=$(az storage account list --resource-group "$resource_group" --query "[0].name" -o tsv)

# Validate storage account name
if [[ -z "$storage_account_name" ]]; then
    echo "Error: No storage account found in the resource group $resource_group."
    exit 1
fi

# Get the storage account access key
access_key=$(az storage account keys list --resource-group "$resource_group" --account-name "$storage_account_name" --query "[0].value" -o tsv)

# Print the storage account access key
# Changed the print format to suit the parsing operation in azure_api_put_request.sh script.
echo "$storage_account_name $access_key"

cd -
