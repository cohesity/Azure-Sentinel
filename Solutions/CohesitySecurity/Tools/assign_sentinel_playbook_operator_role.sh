#!/bin/zsh

# Description: This script assigns the "Microsoft Sentinel Playbook Operator" role
# to a user, group, or service principal at the specified subscription scope.

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

# Set variables
ROLE="Microsoft Sentinel Playbook Operator"
SCOPE="/subscriptions/$subscription_id"

# Set the subscription
az account set --subscription "$subscription_id"
error_handler "Failed to set the subscription."

# Assign the role
az role assignment create --role "$ROLE" --assignee "$client_id" --scope "$SCOPE"
error_handler "Failed to assign the role."

cd -
