#!/bin/zsh

# Description: This script retrieves the role definition ID for a given role name and calls error_handler if not found.

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

role_name="$1"

# Get role definitions and filter role definition by roleName, then extract the id
filtered_role_definition_id=$(az role definition list --query "[?roleName=='$role_name'].name | [0]" -o tsv)


# Output the role definition ID if found, otherwise print an error message and call error_handler
if [ -n "$filtered_role_definition_id" ]; then
    echo "$filtered_role_definition_id"
else
    error_message="No role definition found with roleName \"$role_name\"."
    echo "$error_message"
    error_handler "$error_message"
fi

cd -
