#!/bin/zsh
#
# Description: This script deploys Azure Sentinel playbooks for Cohesity

# Deploy Cohesity_Close_Helios_Incident playbook
source ../Playbooks/Cohesity_Close_Helios_Incident/azuredeploy.json.sh

# Deploy Cohesity_CreateOrUpdate_ServiceNow_Incident playbook
source ../Playbooks/Cohesity_CreateOrUpdate_ServiceNow_Incident/azuredeploy.json.sh

# Deploy Cohesity_Delete_Incident_Blobs playbook
source ../Playbooks/Cohesity_Delete_Incident_Blobs/azuredeploy.json.sh
