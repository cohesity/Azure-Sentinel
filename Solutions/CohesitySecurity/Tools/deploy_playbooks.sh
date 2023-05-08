#!/bin/zsh

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"
#
# Description: This script deploys Azure Sentinel playbooks for Cohesity

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
        error_handler "Failed to deploy the $playbook_name."
        echo "$playbook_name deployment complete."
    else
        echo "Error: Template file for $playbook_name not found."
    fi
}

# Deploy the playbooks
playbook_names=("Cohesity_Close_Helios_Incident" "Cohesity_CreateOrUpdate_ServiceNow_Incident" "Cohesity_Delete_Incident_Blobs" "Cohesity_Restore_From_Last_Snapshot" "Cohesity_Send_Incident_Email")

for playbook_name in "${playbook_names[@]}"; do
    deploy_playbook "$playbook_name"
done

cd -
