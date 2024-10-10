#!/bin/zsh
set -e

# Description: This script assigns the "Microsoft Sentinel Playbook Operator" role
# to a user, group, or service principal at the specified subscription scope.

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

# Set variables
ROLE="Microsoft Sentinel Playbook Operator"

# Validate input variables
if [[ -z "$subscription_id" ]]; then
    echo "Error: Subscription ID is not set. Please set the 'subscription_id' variable."
    exit 1
fi

if [[ -z "$client_id" ]]; then
    echo "Error: Client ID is not set. Please set the 'client_id' variable."
    exit 1
fi

# Set the subscription scope
SCOPE="/subscriptions/$subscription_id"

# Set the subscription
az account set --subscription "$subscription_id"

# Assign the role
az role assignment create --role "$ROLE" --assignee "$client_id" --scope "$SCOPE"

cd -
