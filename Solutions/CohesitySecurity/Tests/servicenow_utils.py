"""
This script contains helper functions to interact with the ServiceNow API and manipulate incident data.
It provides the ability to query ServiceNow incidents, get short and full descriptions of incidents,
find the difference between two lists of system IDs, and verify incident fields.
"""

import requests


def get_short_description(trigger_body):
    """
    Get the short description of an incident from the trigger body.

    :param trigger_body: Dictionary containing incident details
    :return: Short description of the incident
    """
    short_description = trigger_body.get("title")
    return short_description


def get_description(trigger_body):
    """
    Get the full description of an incident from the trigger body.

    :param trigger_body: Dictionary containing incident details
    :return: Full description of the incident
    """
    # Extract incident details
    description = trigger_body.get("description", "")
    severity = trigger_body.get("severity", "")
    additional_data = trigger_body.get("additionalData", {})
    alert_product_names = additional_data.get("alertProductNames", [])

    # Create a string containing all alerts
    alerts = "; ".join(alert_product_names)

    # Construct the full description of the incident
    output = f"Incident description: {description};\nSeverity: {severity};\nAlerts: {alerts};"
    return output


def get_diff_snow_system_id(snow_system_ids, new_snow_system_ids):
    """
    Get the difference between two lists of ServiceNow system IDs.

    :param snow_system_ids: List of ServiceNow system IDs
    :param new_snow_system_ids: List of new ServiceNow system IDs
    :return: The first item in the list that is unique to new_snow_system_ids
    """
    return [
        item for item in new_snow_system_ids if item not in snow_system_ids
    ][0]


def verify_incident_fields(test_instance, incident, incident_details):
    """
    Verify the required fields of an incident.

    :param test_instance: The test instance to use for assertions
    :param incident: Dictionary containing incident data
    :param incident_details: Dictionary containing incident details
    """
    # Assert that required fields are not missing
    test_instance.assertIsNotNone(
        incident["number"], "Incident number is missing"
    )
    test_instance.assertIsNotNone(
        incident["sys_id"], "Incident sys_id is missing"
    )
    test_instance.assertIsNotNone(
        incident["state"], "Incident state is missing"
    )
    test_instance.assertIsNotNone(
        incident["description"], "Incident description is missing"
    )

    # Verify incident details
    servicenow_description = get_description(incident_details)
    short_description = get_short_description(incident_details)
    number = incident_details.get("name")

    # Assert that the incident details match
    test_instance.assertEqual(incident["description"], servicenow_description)
    test_instance.assertEqual(incident["number"], number)
    test_instance.assertEqual(incident["short_description"], short_description)


def query_servicenow_incidents(
    service_now_username,
    service_now_password,
    service_now_instance_url,
    snow_id,
):
    """
    Queries ServiceNow incident using the provided snow_id and returns
    the status code and incident.

    Parameters:
        - service_now_username: Username for authentication with the ServiceNow API
        - service_now_password: Password for authentication with the ServiceNow API
        - service_now_instance_url: Base URL for the ServiceNow instance
        - snow_id: Client tracking ID used to filter incident in the query

    Returns:
        - Tuple containing the status code and incident
    """

    # Set up headers for the API request
    headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
    }

    # Set up credentials for authentication
    credentials = (service_now_username, service_now_password)

    # Create the URL for the API request
    url = f"{service_now_instance_url}/api/now/v2/table/incident/{snow_id}"

    # Send the GET request to the ServiceNow API
    response = requests.get(url, headers=headers, auth=credentials)

    # If the response status code is 200, extract the incident from the response
    if response.status_code == 200:
        incident = response.json()["result"]
    else:
        incident = None

    # Return the status code and the incident
    return response.status_code, incident


__all__ = [
    "query_servicenow_incidents",
    "get_short_description",
    "get_description",
    "get_diff_snow_system_id",
    "verify_incident_fields",
]
