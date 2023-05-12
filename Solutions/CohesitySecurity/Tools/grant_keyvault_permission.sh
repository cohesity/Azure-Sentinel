#!/bin/zsh

# Description: This script grants "Get" permissions to the specified user and playbooks on the Key Vault.

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

# Set variables
keyvault_prefix="$producer_fun_prefix"
playbook_names=("Cohesity_Close_Helios_Incident" "Cohesity_Restore_From_Last_Snapshot")

# Get the Key Vault
keyvault_name=$(az keyvault list --query "[?starts_with(name, '$keyvault_prefix')].{Name:name}" --output tsv | head -n 1)
error_handler "No Key Vault found with the specified prefix"

# Grant the "Get" permission to the user
az keyvault set-policy --name "$keyvault_name" --object-id "$user_object_id" --secret-permissions get


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
    error_handler "Failed to grant permissions for playbook: $playbook_name"

    echo "Permissions granted for playbook: $playbook_name"
done

cd -
