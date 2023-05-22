#!/bin/zsh
set -e

# Script Name: get_service_principal_id.sh
# Description: This script retrieves the object ID of a service principal with a specified display name
#              in all tenants associated with the logged-in Azure account.

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

# Get the list of tenant IDs
tenant_ids=$(az account tenant list --query "[].tenantId" -o tsv)

# Define the target service principal properties
target_app_display_name="Automation_App"

# Initialize variable to store service principal details
sp_details=""
found_match=false

# Loop through all tenants and find the service principals
for tenant_id in $tenant_ids; do

    # Find the service principal related to the tenant ID with the specified properties
    sp_details=$(az ad sp list --all --query "[?appOwnerOrganizationId=='$tenant_id' && appDisplayName=='$target_app_display_name']" -o json)

    # Check if the service principal is found
    if [[ -z "$sp_details" || "$sp_details" == "[]" ]]; then
        echo "Service Principal not found in Tenant ID: $tenant_id" >&2
    else
        sp_id=$(echo "$sp_details" | jq -r '.[0].id')
        found_match=true
        break
    fi
done

# Check if no matching service principal was found in any tenant
if [[ $found_match == false ]]; then
    echo "Error: Failed to find a service principal with the specified properties in any tenant." >&2
    exit 1
fi

# Return the object ID
echo $sp_id

cd -
