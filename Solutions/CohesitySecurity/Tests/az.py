#!/usr/bin/env python3
'''
provide wrapper functions for azure cli to interact with azure sentinel.
'''

import json
import numpy as np
import random
import random
import json
import subprocess


'''
As the function name say, get subscription id of an account.
'''
def get_subscription_id():
    result = subprocess.run(['az', 'account', 'subscription', 'list'], stdout=subprocess.PIPE)
    jsObj = json.loads(result.stdout)
    subscription_id = jsObj[0]["subscriptionId"]
    return subscription_id


'''
As the function name say, return incident details in json format.
'''
def incident_show(vid, resource_group, workspace_name):
    result = subprocess.run(['az', 'sentinel', 'incident', 'show', '--incident-id', vid, '--resource-group', resource_group, '--workspace-name', workspace_name], stdout=subprocess.PIPE)
    jsObj = json.loads(result.stdout)


'''
run a playbook by name, resource_group and workspace_name
please note the returncode is always 0.
we could not rely on that code to assert a success
'''
def run_playbook(subscription_id, vid, resource_group, workspace_name, playbook_name):
    result = subprocess.run(['az', 'sentinel', 'incident', 'run-playbook', '--incident-identifier', vid, '--resource-group', resource_group, '--workspace-name', workspace_name, '--logic-apps-resource-id', "/subscriptions/" + subscription_id + "/resourceGroups/" + resource_group + "/providers/Microsoft.Logic/workflows/" + playbook_name], stdout=subprocess.PIPE)
    return result.returncode


'''
randomly get one incident from list, return its incident id and alert_id.
'''
def get_one_incident_id(resource_group, workspace_name):
    result = subprocess.run(['az', 'sentinel', 'incident', 'list', '--resource-group', resource_group, '--workspace-name', workspace_name], stdout=subprocess.PIPE)
    jsObj = random.choice(json.loads(result.stdout))
    alert_id = jsObj["description"].split("Helios ID: ")[-1]
    vid = jsObj["id"].split("/")[-1]
    return vid, alert_id


'''
to check whether there is any dup incident in the specified resource_group and workspace_name.
'''
def has_dup_incidents(resource_group, workspace_name):
    ids = get_incident_ids(resource_group, workspace_name)
    alert_ids = [alert_id for (vid, alert_id) in ids]
    return len(alert_ids) != len(np.unique(np.array(alert_ids)))


'''
get a list of (incident id, alert_id)
'''
def get_incident_ids(resource_group, workspace_name):
    result = subprocess.run(['az', 'sentinel', 'incident', 'list', '--resource-group', resource_group, '--workspace-name', workspace_name], stdout=subprocess.PIPE)
    return [(jsObj["id"].split("/")[-1], jsObj["description"].split("Helios ID: ")[-1]) for jsObj in json.loads(result.stdout)]


'''
search through incident list, return those whose description contains the specified alert_id.
'''
def search_alert_id_in_incident(alert_id, resource_group, workspace_name):
    response = subprocess.run(['az', 'sentinel', 'incident', 'list',
                               '--resource-group', resource_group,
                              '--workspace-name', workspace_name,
                               '--query', "[?contains(description, '" + alert_id + "')]"], stdout=subprocess.PIPE)
    return json.loads(response.stdout) if json.loads(response.stdout) else None


__all__ = [
    'get_incident_ids',
    'get_one_incident_id',
    'get_subscription_id',
    'has_dup_incidents',
    'incident_show',
    'run_playbook',
    'search_alert_id_in_incident',
]
