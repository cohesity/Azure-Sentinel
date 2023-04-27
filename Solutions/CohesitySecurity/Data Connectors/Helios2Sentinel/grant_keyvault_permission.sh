#!/bin/zsh

# Description: This script grants "Get" permissions to the specified user and playbooks on the Key Vault.

# Set variables
keyvault_prefix="cohesitypro"
playbook_names=("Cohesity_Close_Helios_Incident" "Cohesity_CreateOrUpdate_ServiceNow_Incident" "Cohesity_Delete_Incident_Blobs" "Cohesity_Restore_From_Last_Snapshot" "Cohesity_Send_Incident_Email")
user_object_id="142355ec-a29b-40b7-81c3-e769c76b1756"

# Get the Key Vault
keyvault_name=$(az keyvault list --query "[?starts_with(name, '$keyvault_prefix')].{Name:name}" --output tsv | head -n 1)

if [ -z "$keyvault_name" ]; then
    echo "No Key Vault found with the specified prefix"
    exit 1
fi

# Grant the "Get" permission to the user
az keyvault set-policy --name "$keyvault_name" --object-id "$user_object_id" --secret-permissions get

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
