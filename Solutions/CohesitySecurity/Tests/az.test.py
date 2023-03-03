#!/usr/bin/env python3

from az import *
from helios import *
import json
import numpy as np
import os
import subprocess
import time
import unittest


class TestCohesity(unittest.TestCase):
    def setUp(self):
        # Load config from JSON file
        with open('../cohesity.json') as f:
            config = json.load(f)
            self.resource_group = config['resource_group']
            self.workspace_name = config['workspace_name']
            self.api_key = config['api_key']

        # Deploy playbooks
        bash_command = "./deploy_playbooks.sh"
        process = subprocess.Popen(bash_command.split(), stdout=subprocess.PIPE)
        output, error = process.communicate()

        if output:
            print("output --> %s" % output.decode())

        if error:
            print("error --> %s" % error.decode())

    def test_cohesity_close_helios_incident(self):
        # self.skipTest("Skipping test_cohesity_close_helios_incident")
        playbook_name = "Cohesity_Close_Helios_Incident"
        subscription_id = get_subscription_id()
        vid, alert_id = get_one_incident_id(self.resource_group, self.workspace_name)

        alert_details = get_alert_details(alert_id, self.api_key)
        self.assertEqual(alert_details['alertState'], "kOpen")  # maybe we need to close incident after close helios alert, otherwise, this assert might fail.
        returncode = run_playbook(subscription_id, vid, self.resource_group, self.workspace_name, playbook_name)
        self.assertEqual(returncode, 0)

        time.sleep(30)  # Sleep for 30 seconds

        alert_details = get_alert_details(alert_id, self.api_key)
        print("alert_id --> %s" % alert_id)
        print("api_key --> %s" % self.api_key)
        self.assertEqual(alert_details['alertState'], "kSuppressed")

    def test_all_incidents_in_helios(self):
        ids = get_incident_ids(self.resource_group, self.workspace_name)
        alert_ids = [alert_id for (vid, alert_id) in ids]
        for alert_id in alert_ids:
            self.assertIsNotNone(get_alert_details(alert_id, self.api_key), f"alert_id --> {alert_id} doesn't exist in helios.")
        alerts_details = get_alerts_details(alert_ids, self.api_key)
        self.assertEqual(len(alert_ids), len(alerts_details))

    def test_no_dup_incidents(self):
        ids = get_incident_ids(self.resource_group, self.workspace_name)
        alert_ids = [alert_id for (vid, alert_id) in ids]
        return len(alert_ids) != len(np.unique(np.array(alert_ids)))

    def test_alerts_in_sentinel(self):
        alert_ids = get_alerts(self.api_key)
        for alert_id in alert_ids:
            self.assertIsNotNone(search_alert_id_in_incident(alert_id, self.resource_group, self.workspace_name), f"alert_id --> {alert_id} doesn't exist in sentinel.")


if __name__ == '__main__':
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    unittest.main()
