# Cohesity SIEM/SOAR Integration with Sentinel
This is a Cohesity authored integration for use with Sentinel, Microsoft’s cloud-native security information and event manager (SIEM) platform, to enable Security Operators and ITOps the automation and operational simplicity to respond to threats and recover from ransomware incidents, from inside Sentinel. Below demonstrates the key workflows 
* Ransomware alerts into Sentinel via RESTful APIs integration
* Automatic Incidents with details of the alerts 
* Escalate to ITSM tool via included Playbook
* Initiate recovery of clean snapshot via included Playbook
* Closed loop integration closes out the alert in Helios via included Playbook

### Package Building and Validation Instructions
__Disclaimer:__ You can skip these steps and use one of the pre-built packages from [this directory](https://github.com/cohesity/Azure-Sentinel/tree/CohesitySecurity.internal/Solutions/CohesitySecurity/Package) (TBD). These steps are required _only_ if you'd like to rebuild the package yourself.
1. Follow this [readme.md](https://github.com/cohesity/Azure-Sentinel/blob/CohesitySecurity.internal/Solutions/README.md) for setup build prerequisites
2. Edit [cohesity.config](https://github.com/cohesity/Azure-Sentinel/blob/CohesitySecurity.internal/Solutions/CohesitySecurity/cohesity.config) to replace these values with your own
* your_email_for_playbook@your_domain.com
* your_support_email@your_domain.com
* 11111111-2222-3333-4444-555555555555
3. Run [build.ps1](https://github.com/cohesity/Azure-Sentinel/blob/CohesitySecurity.internal/Solutions/CohesitySecurity/build.ps1) to build the package
4. Follow [readme.md](https://github.com/cohesity/Azure-Sentinel/blob/CohesitySecurity.internal/Solutions/README.md) for post-build manual validation

### Deployment
The package consists of the following Azure functions
* _IncidentProducer_ to retrieve Helios alerts via a special REST API (deployment steps - TBD)
* _IncidentConsumer_ to create incidents in MS Sentinel (deployment steps - TBD)

It also has a few playbooks for automation.
* *Close_Helios_Incident* to resolve alerts on Cohesity Helios (deployment steps - TBD).
* *Send_Incident_Email* to send an email to the recipient with the incident details ([deployment steps](https://github.com/cohesity/Azure-Sentinel/tree/CohesitySecurity.internal/Solutions/CohesitySecurity/Playbooks/Incident_Email_Playbook#readme.md)).
* *CreateOrUpdate_ServiceNow_Incident* to create and update the incident in the ServiceNow platform ([deployment steps](https://github.com/cohesity/Azure-Sentinel/tree/CohesitySecurity.internal/Solutions/CohesitySecurity/Playbooks/SNOW-CreateAndUpdateIncident#readme.md)). 
* *Restore_From_Last_Snapshot* to restore data from the latest clean snapshot in Helios ([deployment steps](https://github.com/cohesity/Azure-Sentinel/tree/CohesitySecurity.internal/Solutions/CohesitySecurity/Playbooks/Incident_VM_Playbook#readme.md))