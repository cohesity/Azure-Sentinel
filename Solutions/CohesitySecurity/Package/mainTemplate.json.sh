#!/bin/zsh
SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

. ../json_parser.sh

../workspace_create.sh

az deployment group create \
    --name ExampleDeployment \
    --resource-group "$resourcegroup" \
    --template-file ./mainTemplate.json \
    --parameters workspace-location=eastasia \
    --parameters workspace="$workspacename"
