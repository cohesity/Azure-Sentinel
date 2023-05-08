#!/bin/zsh

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

#
# Description: This script retrieves the role definition ID for a given role name.

role_name="$1"

# Get role definitions
role_definitions=$(az role definition list --output json)

# Filter role definition by roleName and extract the id
filtered_role_definition_id=$(echo $role_definitions | jq -r ".[] | select(.roleName == \"$role_name\") | .name")

# Output the role definition ID if found, otherwise print an error message and call error_handler
if [ -n "$filtered_role_definition_id" ]; then
    echo "$filtered_role_definition_id"
else
    error_message="No role definition found with roleName \"$role_name\"."
    echo "$error_message"
    error_handler "$error_message"
fi

cd -
