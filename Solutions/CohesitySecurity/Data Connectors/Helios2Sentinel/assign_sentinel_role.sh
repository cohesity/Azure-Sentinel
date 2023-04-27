#!/bin/zsh
#
# Description: This script assigns the "Microsoft Sentinel Playbook Operator" role
# to a user, group, or service principal at the specified subscription scope.

# Set variables
ROLE="Microsoft Sentinel Playbook Operator"
SCOPE="/subscriptions/$subscription_id"

# Set the subscription
az account set --subscription "$subscription_id"

# Assign the role
az role assignment create --role "$ROLE" --assignee "$client_id" --scope "$SCOPE"
