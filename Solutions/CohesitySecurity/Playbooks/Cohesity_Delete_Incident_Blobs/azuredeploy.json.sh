#!/bin/zsh

# Description: This script deploys a single Azure Logic App playbook named "Cohesity_Delete_Incident_Blobs" using an ARM template.
SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

# Deploy the "Cohesity_Delete_Incident_Blobs" playbook using an ARM template
az deployment group create \
    --name ExampleDeployment \
    --resource-group "$resource_group" \
    --template-file "$SCRIPTPATH/azuredeploy.json" \
    --parameters PlaybookName=Cohesity_Delete_Incident_Blobs
