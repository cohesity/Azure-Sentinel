#!/bin/zsh

#
# Description: This script retrieves the role definition ID for a given role name.

role_name="$1"

# Get role definitions
role_definitions=$(az role definition list --output json)

# Filter role definition by roleName and extract the id
filtered_role_definition_id=$(echo $role_definitions | jq -r ".[] | select(.roleName == \"$role_name\") | .name")

# Output the role definition ID if found, otherwise print an error message
if [ -n "$filtered_role_definition_id" ]; then
    echo "$filtered_role_definition_id"
else
    echo "No role definition found with roleName \"$role_name\"."
fi
