#!/bin/zsh
# assign_roles_and_permissions.sh

set -e

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"


# Define the playbook names
playbook_names=("Cohesity_Close_Helios_Incident" "Cohesity_CreateOrUpdate_ServiceNow_Incident" "Cohesity_Delete_Incident_Blobs" "Cohesity_Restore_From_Last_Snapshot")

# Get the Key Vault
keyvault_name=$(az keyvault list --resource-group $resource_group --query '[0].name' --output tsv)

# Function to assign roles
assign_role() {
    local ROLE=$1
    local SCOPE=$2
    local IDENTITY=$3

    echo "Assigning role $ROLE to identity $IDENTITY with scope $SCOPE"

    # Assign the role
    az role assignment create --role "$ROLE" --assignee "$IDENTITY" --scope "$SCOPE"
    echo "Role '$ROLE' has been granted to the client with object ID '$IDENTITY' in scope '$SCOPE'"
}

# Iterate over each playbook
for playbook_name in "${playbook_names[@]}"; do
    # Get the playbook's managed identity
    managed_identity=$(az logic workflow show \
        --name $playbook_name \
        --resource-group $resource_group \
        --query 'identity.principalId' \
        --output tsv)

    # Print the managed identity
    echo "Managed identity for playbook $playbook_name: $managed_identity"

    # Assign Microsoft Sentinel Responder role to the playbook's managed identity
    assign_role "Microsoft Sentinel Responder" "/subscriptions/$subscription_id/resourceGroups/$resource_group" $managed_identity

    # Assign secret permissions to the playbook's managed identity on the Key Vault
    az keyvault set-policy --name $keyvault_name \
        --object-id $managed_identity \
        --secret-permissions get
done

# Additional role assignments

if [[ ! -z "$resource_group" ]] && [[ ! -z "$workspace_name" ]]; then
    echo "Resource Group: $resource_group"
    echo "Workspace Name: $workspace_name"
    ROLE="Microsoft Sentinel Contributor"

    # Get the object ID
    object_id=$(. ./get_service_principal_id.sh)
    echo "Object ID obtained: $object_id"

    # Get the workspace scope
    SCOPE=$(az monitor log-analytics workspace show --resource-group "$resource_group" --workspace-name "$workspace_name" --query 'id' -o tsv)
    echo "Workspace Scope: $SCOPE"

    assign_role "$ROLE" "$SCOPE" "$object_id"
fi

if [[ ! -z "$client_id" ]]; then
    echo "Client ID: $client_id"
    ROLE="Microsoft Sentinel Playbook Operator"
    # Set the subscription scope
    SCOPE="/subscriptions/$subscription_id"
    echo "Subscription Scope: $SCOPE"

    assign_role "$ROLE" "$SCOPE" "$client_id"
fi

cd -
