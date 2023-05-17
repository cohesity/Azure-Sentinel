#!/bin/zsh

# Description: This script assigns Microsoft Sentinel Automation Contributor role
# permissions to the app display name and role name.
# It first retrieves the principal ID and role definition ID, then
# grants the necessary permissions for the playbook.

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

app_display_name="Azure Security Insights"
role_name="Microsoft Sentinel Automation Contributor"

# Call the Python script to get the principal ID
principal_id=$(python3 ./get_principal_id.py "$app_display_name")
error_handler "Failed to get the principal ID."

# Call the script to get the role definition ID
role_definition_id=$(./get_role_definition_id.sh "$role_name")
error_handler "Failed to get the role definition ID."

# Print resource_group and workspace_name for later debug
echo "During configure permissions, Resource Group: $resource_group"
echo "During configure permissions, Workspace Name: $workspace_name"

# If the principal ID and role definition ID were found, proceed with the rest of the script
if [[ ! "$principal_id" =~ "No service principal found" ]] && [[ ! "$role_definition_id" =~ "No role definition found" ]]; then
    echo "Principal ID: $principal_id"
    echo "Role Definition ID: $role_definition_id"
    role_definition_id="/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Authorization/roleDefinitions/$role_definition_id"

    # Set the subscription
    az account set --subscription "$subscription_id"
    error_handler "Failed to set the subscription."

    # Grant the necessary permissions for the playbook
    sentinel_resource_id=$(az monitor log-analytics workspace show --resource-group "$resource_group" --workspace-name "$workspace_name" --query 'id' -o tsv)
    error_handler "Failed to get the Sentinel resource ID."

    # Set role assignment ID
    role_assignment_id=$(uuidgen)
    api_version="2015-07-01"

    # Create the request body
    request_body=$(jq -n \
        --arg roleDefinitionId "$role_definition_id" \
        --arg principalId "$principal_id" \
        '{"properties": {"roleDefinitionId": $roleDefinitionId, "principalId": $principalId}}'
    )

    # Send a batch request
    # Generate a new UUID for the request name
    request_name=$(uuidgen)

    az rest --method POST \
        --url "https://management.azure.com/batch?api-version=2020-06-01" \
        --headers "Content-Type=application/json" \
        --body "{\"requests\":[{\"content\": $request_body, \"httpMethod\":\"PUT\", \"name\":\"$request_name\", \"url\":\"https://management.azure.com/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Authorization/roleAssignments/$role_assignment_id?api-version=$api_version\"}]}"
            error_handler "Failed to send the batch request."
            echo "Permissions configured for the playbook."
else
    echo "Error:"
    echo "$principal_id"
    echo "$role_definition_id"
    exit 1
fi

cd -
