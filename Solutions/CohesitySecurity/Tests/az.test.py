#!/usr/bin/env python3

import subprocess
import json
import time
from az import *
from helios import *
import os

os.chdir(os.path.dirname(os.path.abspath(__file__)))
f = open('../cohesity.json',)
data = json.load(f)
resource_group = data['resource_group']
workspace_name = data['workspace_name']
apiKey = data['apiKey']
f.close()

assert has_dup_incidents(resource_group, workspace_name) == False


def test_cohesity_close_helios_incident():
    playbook_name = "Cohesity_Close_Helios_Incident"
    subscriptionId = get_subscriptionId()
    vid, alert_id = get_one_incident_id(resource_group, workspace_name)

    alert_details = get_alert_details(alert_id, apiKey)
    assert alert_details['alertState'] == "kOpen"  # maybe we need to close incident after close helios alert, otherwise, this assert might fail.
    returncode = run_playbook(subscriptionId, vid, resource_group, workspace_name, playbook_name)
    assert returncode == 0

    time.sleep(30)  # Sleep for 30 seconds

    alert_details = get_alert_details(alert_id, apiKey)
    print("alert_id --> %s" % alert_id)
    print("apiKey --> %s" % apiKey)
    assert alert_details['alertState'] == "kSuppressed"


def test_all_incidents_in_helios():
    ids = get_incident_ids(resource_group, workspace_name)
    alert_ids = [alert_id for (vid, alert_id) in ids]
    for alert_id in alert_ids:
        assert get_alert_details(alert_id, apiKey) is not None, f"alert_id --> {alert_id} doesn't exist in helios."
    alerts_details = get_alerts_details(alert_ids, apiKey)
    assert len(alert_ids) == len(alerts_details)

def test_alerts_in_sentinel():
    alert_ids = get_alerts(apiKey)
    for alert_id in alert_ids:
        assert search_alert_id_in_incident(alert_id, resource_group, workspace_name) is not None, f"alert_id --> {alert_id} doesn't exist in sentinel."

bash_command = "./deploy_playbooks.sh"
process = subprocess.Popen(bash_command.split(), stdout=subprocess.PIPE)
output, error = process.communicate()

if output:
    print("output --> %s" % output.decode())

if error:
    print("error --> %s" % error.decode())


test_cohesity_close_helios_incident()
test_all_incidents_in_helios()
test_alerts_in_sentinel()
