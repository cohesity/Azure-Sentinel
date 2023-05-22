import requests


class ServiceNow:
    """
    This class provides helper functions to interact with the ServiceNow API and manipulate incident data.
    It provides the ability to query ServiceNow incidents, get short and full descriptions of incidents,
    find the difference between two lists of system IDs, and verify incident fields.
    """

    def __init__(
        self,
        service_now_username,
        service_now_password,
        service_now_instance_url,
    ):
        self.service_now_username = service_now_username
        self.service_now_password = service_now_password
        self.service_now_instance_url = service_now_instance_url

    def construct_short_description(self, incident_details):
        """
        Get the short description of an incident from the trigger body.

        :param incident_details: Dictionary containing incident details
        :return: Short description of the incident
        """
        short_description = incident_details.get("title")
        return short_description

    def construct_description(self, incident_details):
        """
        Get the full description of an incident from the trigger body.

        :param incident_details: Dictionary containing incident details
        :return: Full description of the incident
        """
        description = incident_details.get("description", "")
        severity = incident_details.get("severity", "")
        additional_data = incident_details.get("additionalData", {})
        alert_product_names = additional_data.get("alertProductNames", [])
        alerts = "; ".join(alert_product_names)
        output = f"Incident description: {description};\nSeverity: {severity};\nAlerts: {alerts};"
        return output

    def get_diff_snow_system_id(self, snow_system_ids, new_snow_system_ids):
        """
        Get the difference between two lists of ServiceNow system IDs.

        :param snow_system_ids: List of ServiceNow system IDs
        :param new_snow_system_ids: List of new ServiceNow system IDs
        :return: The first item in the list that is unique to new_snow_system_ids
        """
        return [
            item for item in new_snow_system_ids if item not in snow_system_ids
        ][0]

    def verify_incident_fields(
        self, test_instance, incident, incident_details
    ):
        """
        Verify the required fields of an incident.

        :param test_instance: The test instance to use for assertions
        :param incident: Dictionary containing incident data
        :param incident_details: Dictionary containing incident details
        """
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

        servicenow_description = self.construct_description(incident_details)
        short_description = self.construct_short_description(incident_details)
        number = incident_details.get("name")

        test_instance.assertEqual(
            incident["description"], servicenow_description
        )
        test_instance.assertEqual(incident["number"], number)
        test_instance.assertEqual(
            incident["short_description"], short_description
        )

    def query_servicenow_incidents(self, snow_id):
        """
        Queries ServiceNow incident using the provided snow_id and returns
        the status code and incident.

        Parameters:
            - snow_id: Client tracking ID used to filter incident in the query

        Returns:
            - Tuple containing the status code and incident
        """
        headers = {
            "Accept": "application/json",
            "Content-Type": "application/json",
        }

        credentials = (self.service_now_username, self.service_now_password)

        url = f"{self.service_now_instance_url}/api/now/v2/table/incident/{snow_id}"

        response = requests.get(url, headers=headers, auth=credentials)

        if response.status_code == 200:
            incident = response.json()["result"]
        else:
            incident = None

        return response.status_code, incident
