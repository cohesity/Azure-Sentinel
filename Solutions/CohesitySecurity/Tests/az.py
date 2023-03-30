#!/usr/bin/env python3

"""
This module provides wrapper functions for Azure CLI to interact with Azure
Sentinel.
"""

import json
import requests
import time
import random
import subprocess


def run_az_command(command):
    """
    Runs an Azure CLI command and returns the output as a Python object.
    """
    result = subprocess.run(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        shell=True,
    )
    if result.returncode == 0:
        return json.loads(result.stdout)
    else:
        print(f"Error: {result.stderr}")
        return None


def list_folder_content(
    storage_account, storage_account_key, container_name, folder_name
):
    """
    Returns a list of blobs in the specified folder within the container.
    """
    folder_content_cmd = (
        f"az storage blob list --account-name {storage_account} "
        f"--account-key {storage_account_key} --container-name {container_name} "
        f"--prefix {folder_name} --output json"
    )
    return run_az_command(folder_content_cmd)


def get_validated_storage_account(resource_group, name_prefix):
    """
    Returns the storage account name for the specified resource group if it
    meets the specified conditions: only 1 storage account is present and
    the name starts with the given name_prefix.

    :param resource_group: The resource group to search for the storage account
    :param name_prefix: The expected storage account name prefix
    :return: The storage account name if it meets the conditions, otherwise None
    """
    storage_account_cmd = (
        f"az storage account list "
        f"--resource-group {resource_group} "
        f"--output json"
    )
    storage_accounts = run_az_command(storage_account_cmd)

    # Check if there is only one storage account in the resource group
    if len(storage_accounts) != 1:
        print(
            f"Error: {resource_group} has {len(storage_accounts)} storage "
            f"accounts. Exactly 1 storage account is expected."
        )
        return None

    storage_account_name = storage_accounts[0]["name"]

    # Check if the storage account name starts with the given name_prefix
    if not storage_account_name.startswith(name_prefix):
        print(
            f"Error: The storage account name '{storage_account_name}' "
            f"does not start with '{name_prefix}'."
        )
        return None

    return storage_account_name


def get_storage_account_key(resource_group, storage_account):
    """
    Returns the storage account key for the specified storage account.
    """
    storage_account_key_cmd = (
        f"az storage account keys list --resource-group {resource_group} "
        f'--account-name {storage_account} --query "[0].value" --output json'
    )
    return run_az_command(storage_account_key_cmd)


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
    subscription_id,
    incident_id,
    resource_group,
    workspace_name,
    playbook_name,
    access_token,
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

    start_time = time.time()
    timeout = 5 * 60  # Timeout in seconds (5 minutes)

    while True:
        playbook_run = get_latest_playbook_run(
            access_token,
            subscription_id,
            resource_group,
            playbook_name,
        )
        if playbook_run["value"][0]["properties"]["status"] != "Running":
            break
        elapsed_time = time.time() - start_time
        if elapsed_time > timeout:
            print("Timeout reached: 5 minutes have passed.")
            break

        time.sleep(5)  # Sleep for 5 seconds between status checks

    assert (
        playbook_run["value"][0]["properties"]["status"] == "Succeeded"
        or print(
            "Assertion failed. Status: "
            f"{playbook_run['value'][0]['properties']['status']}, "
            "Playbook Run: "
            f"{json.dumps(playbook_run['value'][0], indent=2)}"
        )
        or False
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
    """
    This function retrieves the latest playbook run in Azure
    Logic Apps. It makes a request to the Azure Management API, parses the
    response, and returns the JSON object containing details of the latest run.

    Parameters:
        - access_token (str): Azure access token for authentication
        - subscription_id (str): Azure subscription ID
        - resource_group (str): Azure resource group containing the playbook
        - playbook_name (str): Name of the playbook in the Logic App

    Returns:
        - dict: A JSON object containing details of the latest playbook run,
            or None if an error occurs
    """

    headers = {
        "Authorization": "Bearer " + access_token,
        "Content-Type": "application/json",
    }
    url = (
        "https://management.azure.com/subscriptions/{}/resourceGroups/{}/"
        "providers/Microsoft.Logic/workflows/{}/runs?api-version=2016-06-01"
        "&$top=1"
    ).format(subscription_id, resource_group, playbook_name)

    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(
            f"An error occurred while retrieving the playbook run status: {e}"
        )
        return None


def get_azure_access_token(
    tenant_id, client_id, client_secret, resource_url, scope
):
    """
    Obtains an access token from Azure Active Directory (Azure AD) using the
    OAuth 2.0 client credentials grant flow. Access tokens are used to
    authenticate requests made to Azure services.
    Parameters:
        - tenant_id (str): The ID of the Azure AD tenant where the application
            is registered.
        - client_id (str): The application's client ID in Azure AD.
        - client_secret (str): The application's client secret.
        - resource_url (str): The URL of the resource or service you want to
            access.
        - scope (str): The desired scope of permissions for the access token.

    Returns:
        - access_token (str): The access token that can be used to authenticate
            requests to Azure services.
    """
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
    "get_validated_storage_account",
    "get_storage_account_key",
    "list_folder_content",
]
