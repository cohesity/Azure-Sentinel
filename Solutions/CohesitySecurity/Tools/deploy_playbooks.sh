#!/bin/zsh

# Description: This script deploys Azure Sentinel playbooks for Cohesity

set -e
SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

# Validate input variables
if [[ -z "$resource_group" ]]; then
    echo "Error: Resource Group is not set. Please set the 'resource_group' variable."
    exit 1
fi

if [[ -z "$user_email" ]]; then
    echo "Error: User Email is not set. Please set the 'user_email' variable."
    exit 1
fi

# Function to deploy the playbook
deploy_playbook() {
    playbook_name="$1"
    if [ -n "$2" ]; then
        email_id="$2"
    fi
    template_file="../Playbooks/$playbook_name/azuredeploy.json"

    if [ -f "$template_file" ]; then
        echo "Deploying $playbook_name..."
        if [ "$playbook_name" = "Cohesity_Send_Incident_Email" ]; then
            az deployment group create \
                --name "${playbook_name}_Deployment" \
                --resource-group "$resource_group" \
                --template-file "$template_file" \
                --parameters EmailID="$email_id"
        else
            az deployment group create \
                --name "${playbook_name}_Deployment" \
                --resource-group "$resource_group" \
                --template-file "$template_file" \
                --parameters PlaybookName="$playbook_name"
        fi
        echo "$playbook_name deployment complete."
    else
        echo "Error: Template file for $playbook_name not found."
    fi
}

# Deploy the playbooks
playbook_names=("Cohesity_Close_Helios_Incident" "Cohesity_CreateOrUpdate_ServiceNow_Incident" "Cohesity_Delete_Incident_Blobs" "Cohesity_Restore_From_Last_Snapshot" "Cohesity_Send_Incident_Email")

for playbook_name in "${playbook_names[@]}"; do
    deploy_playbook "$playbook_name" "$user_email"
done

cd -
