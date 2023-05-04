#!/bin/zsh
#
# Description: This script deploys Azure Sentinel playbooks for Cohesity

# Source error handling script
. ./error_handling.sh

# Deploy Cohesity_Close_Helios_Incident playbook
. ../../Playbooks/Cohesity_Close_Helios_Incident/azuredeploy.json.sh || error_handler

# Deploy Cohesity_CreateOrUpdate_ServiceNow_Incident playbook
. ../../Playbooks/Cohesity_CreateOrUpdate_ServiceNow_Incident/azuredeploy.json.sh || error_handler

# Deploy Cohesity_Delete_Incident_Blobs playbook
. ../../Playbooks/Cohesity_Delete_Incident_Blobs/azuredeploy.json.sh || error_handler
