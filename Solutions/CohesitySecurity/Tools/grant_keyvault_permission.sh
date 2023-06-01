#!/bin/zsh
set -e

# Description: This script grants "Get" permissions to the specified user and playbooks on the Key Vault.

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

# Validate input variables
if [[ -z "$producer_fun_prefix" ]]; then
    echo "Error: producer_fun_prefix is not set. Please set the 'producer_fun_prefix' variable."
    exit 1
fi

if [[ -z "$resource_group" ]]; then
    echo "Error: Resource Group is not set. Please set the 'resource_group' variable."
    exit 1
fi


# Set variables
keyvault_prefix="$producer_fun_prefix"
playbook_names=("Cohesity_Close_Helios_Incident" "Cohesity_Restore_From_Last_Snapshot")

# Get the Key Vault
keyvault_name=$(az keyvault list --query "[?starts_with(name, '$keyvault_prefix')].{Name:name}" --output tsv | head -n 1)

# Print resource_group and workspace_name for later debug
echo "During grant keyvault permission, Resource Group: $resource_group"
echo "During grant keyvault permission, Workspace Name: $workspace_name"

# Iterate through the playbooks
for playbook_name in "${playbook_names[@]}"; do
    # Get the Playbook's Managed Identity object ID
    playbook_object_id=$(az resource list --resource-group $resource_group --resource-type "Microsoft.Logic/workflows" --name "$playbook_name" --query "[].identity.principalId" -o tsv)

    if [ -z "$playbook_object_id" ]; then
        echo "Playbook not found with the specified name: $playbook_name"
        continue
    fi

    # Grant the "Get" permission to the playbook
    az keyvault set-policy --name "$keyvault_name" --object-id "$playbook_object_id" --secret-permissions get

    echo "Permissions granted for playbook: $playbook_name"
done

cd -
