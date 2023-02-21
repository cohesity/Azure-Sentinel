#!/bin/zsh
SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

. ../../json_parser.sh

../../workspace_create.sh
./storage_account_delete.sh

az deployment group create \
    --name ExampleDeployment \
    --resource-group "$resourcegroup" \
    --template-file ./azuredeploy.json \
    --parameters ApiKey="$apiKey" \
    --parameters ClientId="$ClientId" \
    --parameters ClientKey="$ClientKey" \
    --parameters StartDaysAgo="$StartDaysAgo" \
    --parameters Workspace="$workspacename"
