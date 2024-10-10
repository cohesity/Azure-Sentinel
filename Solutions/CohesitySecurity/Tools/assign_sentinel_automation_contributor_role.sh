#!/bin/zsh
set -e

# Description: This script assigns Microsoft Sentinel Automation Contributor role
# permissions to the app display name and role name.
# It first retrieves the principal ID and role definition ID, then
# grants the necessary permissions for the playbook.

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

app_display_name="Azure Security Insights"
role_name="Microsoft Sentinel Automation Contributor"

# Validate input variables
if [[ -z "$subscription_id" ]]; then
    echo "Error: Subscription ID is not set. Please set the 'subscription_id' variable."
    exit 1
fi

if [[ -z "$resource_group" ]]; then
    echo "Error: Resource Group is not set. Please set the 'resource_group' variable."
    exit 1
fi

if [[ -z "$workspace_name" ]]; then
    echo "Error: Workspace Name is not set. Please set the 'workspace_name' variable."
    exit 1
fi

# Call the Python script to get the principal ID
principal_id=$(python3 ./get_principal_id.py "$app_display_name")

# Call the script to get the role definition ID
role_definition_id=$(./get_role_definition_id.sh "$role_name")

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

    # Grant the necessary permissions for the playbook
    sentinel_resource_id=$(az monitor log-analytics workspace show --resource-group "$resource_group" --workspace-name "$workspace_name" --query 'id' -o tsv)

    # Set role assignment ID
    role_assignment_id=$(uuidgen)
    api_version="2015-07-01"

    # Create the request body
    request_body=$(jq -n \
        --arg roleDefinitionId "$role_definition_id" \
        --arg principalId "$principal_id" \
        '{"properties": {"roleDefinitionId": $roleDefinitionId, "principalId": $principalId}}'
    )

    az rest --method PUT \
        --url "https://management.azure.com/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.Authorization/roleAssignments/$role_assignment_id?api-version=$api_version" \
        --headers "Content-Type=application/json" \
        --body "$request_body"
            echo "Permissions configured for the playbook."
else
    echo "Error:"
    echo "$principal_id"
    echo "$role_definition_id"
    exit 1
fi

cd -
