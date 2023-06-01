#!/bin/zsh
set -e
# Name: azure_api_put_request.sh

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

echo "DEBUG: Current script path: ${SCRIPTPATH}"

# Description: This script makes a PUT request to the Azure REST API.
# It takes inputs from a sourced script which extracts configuration from a JSON file.


# Call the get_storage_account_key.sh script and parse its output
echo "DEBUG: Calling get_storage_account_key.sh"
storage_account_info=$(. ./get_storage_account_key.sh)
accountName=$(echo $storage_account_info | cut -d' ' -f1)
accessKey=$(echo $storage_account_info | cut -d' ' -f2)

echo "DEBUG: Storage Account Name: ${accountName}"
echo "DEBUG: Storage Account Key: ${accessKey}"

# Define the JSON body with the sourced variables and the obtained accountName and accessKey
json_body=$(cat <<EOF
{
  "location": "${location}",
  "properties": {
    "displayName": "Azureblob-Cohesity_Delete_Incident_Blobs",
    "api": {
      "id": "/subscriptions/${subscription_id}/providers/Microsoft.Web/locations/${location}/managedApis/azureblob"
    },
    "connectionState": "Enabled",
    "parameterValues": {
      "accountName": "${accountName}",
      "accessKey": "${accessKey}"
    }
  }
}
EOF
)

echo "DEBUG: JSON body: ${json_body}"

# Send the PUT request to Azure REST API
echo "DEBUG: Sending PUT request to Azure REST API"
az rest --method PUT \
  --uri "https://management.azure.com/subscriptions/${subscription_id}/resourceGroups/${resource_group}/providers/Microsoft.Web/connections/Azureblob-Cohesity_Delete_Incident_Blobs?api-version=2018-07-01-preview" \
  --body "$json_body" \
  --headers "Content-Type=application/json"

cd -
