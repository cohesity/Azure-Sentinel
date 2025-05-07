#!/bin/zsh
# This script configures the ServiceNow connection for the 'Cohesity_CreateOrUpdate_ServiceNow_Incident' Azure Logic Apps playbook.
# It reads the connection parameters (ServiceNow instance URL and login credentials) from the 'cohesity.json' configuration file.

set -e
SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

# Source the script to get the necessary variables

# Debug: Print the variables
echo "ServiceNow instance URL: $service_now_instance_url"
echo "ServiceNow username: $service_now_username"
echo "ServiceNow password: ******"
echo "Subscription ID: $subscription_id"
echo "Resource Group: $resource_group"

# Create the JSON body
json_body=$(jq -n \
  --arg instance "$service_now_instance_url" \
  --arg username "$service_now_username" \
  --arg password "$service_now_password" \
  '{
    "location": "eastus",
    "kind": "V1",
    "properties": {
      "api": {
        "id": "/subscriptions/'"$subscription_id"'/providers/Microsoft.Web/locations/eastus/managedApis/service-now"
      },
      "displayName": "Service-Now-Cohesity_CreateOrUpdate_ServiceNow_Incident",
      "parameterValues": {
        "instance": $instance,
        "username": $username,
        "password": $password
      }
    }
  }')

# Debug: Print the JSON body
echo "JSON Body: $json_body"

# Send the PUT request to Azure REST API
az rest --method PUT \
  --uri "https://management.azure.com/subscriptions/"$subscription_id"/resourceGroups/"$resource_group"/providers/Microsoft.Web/connections/Service-Now-Cohesity_CreateOrUpdate_ServiceNow_Incident?api-version=2018-07-01-preview" \
  --body "$json_body" \
  --headers "Content-Type=application/json"

cd -
