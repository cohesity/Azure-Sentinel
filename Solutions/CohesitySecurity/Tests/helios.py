#!/usr/bin/env python3
'''
provide functions to interact with helios cluster.
'''

import requests
import datetime
import time


def create_headers(api_key):
    headers = {
        "Content-Type": "application/json",
        "authority": "helios.cohesity.com",
        "apiKey": api_key
    }
    return headers


'''
get details of a batch of alert_ids, in json format.
'''


def get_alerts_details(alert_ids, api_key):
    max_alerts = len(alert_ids)
    assert max_alerts > 0
    alert_ids = ",".join(alert_ids)
    api_url = "https://helios.cohesity.com/mcm/alerts?maxAlerts=" + str(max_alerts) + "&alertIdList=" + alert_ids
    headers = create_headers(api_key)
    response = requests.get(api_url, headers=headers)
    return response.json() if response.json() else None


'''
get details of a alert_id, in json format.
'''


def get_alert_details(alert_id, api_key):
    api_url = "https://helios.cohesity.com/mcm/alerts?maxAlerts=1&alertIdList=" + alert_id
    headers = create_headers(api_key)
    response = requests.get(api_url, headers=headers)
    return response.json()[0] if response.json() else None


'''
get a time range of alert ids.
'''


def get_alerts(api_key, start_days_ago=30, end_days_ago=0):
    def get_days_ago_timestamp(days_ago=10):
        days_ago = datetime.datetime.now() - datetime.timedelta(days=days_ago)
        days_ago_timestamp = int(time.mktime(days_ago.timetuple()) * 1000000)
        return str(days_ago_timestamp)

    api_url = "https://helios.cohesity.com/mcm/alerts?alertCategoryList=kSecurity&startDateUsecs=" + get_days_ago_timestamp(start_days_ago) + "&endDateUsecs=" + get_days_ago_timestamp(end_days_ago)
    headers = create_headers(api_key)
    response = requests.get(api_url, headers=headers)
    return [jsObj["id"] for jsObj in response.json()]


__all__ = [
    'get_alert_details',
    'get_alerts',
    'get_alerts_details',
]
