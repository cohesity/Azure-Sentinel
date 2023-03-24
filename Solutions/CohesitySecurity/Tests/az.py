#!/usr/bin/env python3

"""
This module provides wrapper functions for Azure CLI to interact with Azure
Sentinel.
"""

import json
import requests
import random
import subprocess


def get_subscription_id():
    """
    Returns the subscription ID of the current Azure account.
    """
    result = subprocess.run(
        ["az", "account", "subscription", "list"], stdout=subprocess.PIPE
    )
    jsObj = json.loads(result.stdout)
    subscription_id = jsObj[0]["subscriptionId"]
    return subscription_id


def incident_show(incident_id, resource_group, workspace_name):
    """
    Returns the details of a specific incident in JSON format.
    """
    result = subprocess.run(
        [
            "az",
            "sentinel",
            "incident",
            "show",
            "--incident-id",
            incident_id,
            "--resource-group",
            resource_group,
            "--workspace-name",
            workspace_name,
        ],
        stdout=subprocess.PIPE,
    )
    jsObj = json.loads(result.stdout)
    return jsObj


def run_playbook(
    subscription_id, incident_id, resource_group, workspace_name, playbook_name
):
    """
    Runs a playbook by name, resource group, and workspace name.
    Note: The return code is always 0. It cannot be relied upon to indicate
    success.
    """
    logic_apps_resource_id = (
        "/subscriptions/"
        + subscription_id
        + "/resourceGroups/"
        + resource_group
        + "/providers/Microsoft.Logic/workflows/"
        + playbook_name
    )
    result = subprocess.run(
        [
            "az",
            "sentinel",
            "incident",
            "run-playbook",
            "--incident-identifier",
            incident_id,
            "--resource-group",
            resource_group,
            "--workspace-name",
            workspace_name,
            "--logic-apps-resource-id",
            logic_apps_resource_id,
        ],
        stdout=subprocess.PIPE,
    )
    return result.returncode


def get_one_incident_id(resource_group, workspace_name):
    """
    Returns the ID and alert ID of a random incident from the list of incidents.
    """
    result = subprocess.run(
        [
            "az",
            "sentinel",
            "incident",
            "list",
            "--resource-group",
            resource_group,
            "--workspace-name",
            workspace_name,
        ],
        stdout=subprocess.PIPE,
    )
    jsObj = random.choice(json.loads(result.stdout))
    alert_id = jsObj["description"].split("Helios ID: ")[-1]
    incident_id = jsObj["id"].split("/")[-1]
    return incident_id, alert_id


def get_incident_ids(resource_group, workspace_name):
    """
    Returns a list of tuples containing the incident ID and alert ID of each
    incident.
    """
    result = subprocess.run(
        [
            "az",
            "sentinel",
            "incident",
            "list",
            "--resource-group",
            resource_group,
            "--workspace-name",
            workspace_name,
        ],
        stdout=subprocess.PIPE,
    )
    return [
        (
            jsObj["id"].split("/")[-1],
            jsObj["description"].split("Helios ID: ")[-1],
        )
        for jsObj in json.loads(result.stdout)
    ]


def search_alert_id_in_incident(alert_id, resource_group, workspace_name):
    """
    Searches through the list of incidents and returns those whose description
    contains the specified alert ID.
    """
    query = "[?contains(description, '" + alert_id + "')]"
    result = subprocess.run(
        [
            "az",
            "sentinel",
            "incident",
            "list",
            "--resource-group",
            resource_group,
            "--workspace-name",
            workspace_name,
            "--query",
            query,
        ],
        stdout=subprocess.PIPE,
    )
    return json.loads(result.stdout) if json.loads(result.stdout) else None


def get_latest_playbook_run(
    access_token, subscription_id, resource_group, playbook_name
):
    headers = {
        "Authorization": "Bearer " + access_token,
        "Content-Type": "application/json",
    }
    url = (
        "https://management.azure.com/subscriptions/{}/resourceGroups/{}/"
        "providers/Microsoft.Logic/workflows/{}/runs?api-version=2016-06-01"
        "&$top=1"
    ).format(subscription_id, resource_group, playbook_name)
    response = requests.get(url, headers=headers)
    return response.json()


def get_azure_access_token(
    tenant_id, client_id, client_secret, resource_url, scope
):
    authority_url = "https://login.microsoftonline.com/{}/oauth2/token".format(
        tenant_id
    )
    response = requests.post(
        authority_url,
        data={
            "grant_type": "client_credentials",
            "client_id": client_id,
            "client_secret": client_secret,
            "resource": resource_url,
            "scope": scope,
        },
    )
    access_token = response.json()["access_token"]
    return access_token


__all__ = [
    "get_incident_ids",
    "get_one_incident_id",
    "get_subscription_id",
    "incident_show",
    "run_playbook",
    "search_alert_id_in_incident",
    "get_azure_access_token",
    "get_latest_playbook_run",
]
