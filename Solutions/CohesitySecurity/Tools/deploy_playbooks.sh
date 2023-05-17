#!/bin/zsh
set -e

# Description: This script deploys Azure Sentinel playbooks for Cohesity

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

# Validate input variables
if [[ -z "$resource_group" ]]; then
    echo "Error: Resource Group is not set. Please set the 'resource_group' variable."
    exit 1
fi

# Function to deploy the playbook
deploy_playbook() {
    playbook_name="$1"
    template_file="../Playbooks/$playbook_name/azuredeploy.json"

    if [ -f "$template_file" ]; then
        echo "Deploying $playbook_name..."
        az deployment group create \
            --name "${playbook_name}_Deployment" \
            --resource-group "$resource_group" \
            --template-file "$template_file" \
            --parameters PlaybookName="$playbook_name"
        echo "$playbook_name deployment complete."
    else
        echo "Error: Template file for $playbook_name not found."
    fi
}

# Deploy the playbooks
playbook_names=("Cohesity_Close_Helios_Incident" "Cohesity_CreateOrUpdate_ServiceNow_Incident" "Cohesity_Delete_Incident_Blobs" "Cohesity_Restore_From_Last_Snapshot")

for playbook_name in "${playbook_names[@]}"; do
    deploy_playbook "$playbook_name"
done

cd -
